/datum/advclass
	var/name
	var/list/classes
	var/outfit
	var/tutorial = "Choose me!"
	var/list/allowed_sexes
	var/list/allowed_races = RACES_ALL_KINDS
	var/list/disallowed_races = null
	var/list/allowed_patrons
	var/list/allowed_ages
	var/pickprob = 100
	var/maximum_possible_slots = -1
	var/total_slots_occupied = 0
	var/min_pq = -100

	var/class_select_category

	var/horse = FALSE
	var/vampcompat = TRUE
	var/list/traits_applied
	var/cmode_music

	var/noble_income = FALSE //Passive income every day from noble estate

	/// This class is immune to species-based swapped gender locks
	var/immune_to_genderswap = FALSE

	//What categories we are going to sort it in
	var/list/category_tags = list(CTAG_DISABLED)

	/// Subclass stat bonuses.
	var/list/subclass_stats

	/// Extra fluff added to the role explanation in class selection.
	var/extra_context

	/// Set to FALSE to skip apply_character_post_equipment() which applies virtue, flaw, loadout
	var/applies_post_equipment = TRUE

	/// Subclass skills. Levelled UP TO.
	var/list/subclass_skills

	/// Subclass languages.
	var/list/subclass_languages

	/// Spellpoints. If More than 0, Gives Prestidigitation & the Learning Spell.
	var/subclass_spellpoints = 0

	/// Subclass social rank, used to overwrite the job social rank
	var/subclass_social_rank

	/// Virtue restrictions for this subclass
	var/list/virtue_restrictions

/datum/advclass/proc/equipme(mob/living/carbon/human/H)
	// input sleeps....
	set waitfor = FALSE
	if(!H)
		return FALSE

	// ALL OF THIS FUCKING SLOP IS TEMPORARY TO PREVENT RUNTIMES DURING INPUT() CALLS OF LOADOUT SELECTION
	// IT SHOULD BE REMOVED ONCE THE LOADOUT SELECTION IS TGUI BASED AND NO LONGER USES INPUT()
	// Store client reference before equipment (input() can cause disconnect)
	var/client/original_client = H.client
	var/original_ckey = H.ckey

	if(outfit)
		// Wrap in try/catch to handle "bad client" runtime during input()
		try
			H.equipOutfit(outfit)
		catch(var/exception/e)
			// Runtime occurred (likely "bad client" from disconnect during input())
			log_game("LOADOUT RUNTIME: [original_ckey] caused runtime during [name] equipment: [e]")
			
			// Always cleanup on runtime - client may be detached
			log_game("LOADOUT CLEANUP: Cleaning up [original_ckey] after runtime")
			
			// Free up the job slot
			var/job_name = H.job || "Unknown"
			if(H.job)
				var/datum/job/J = SSjob.GetJob(H.job)
				if(J)
					J.current_positions = max(0, J.current_positions - 1)
					log_game("LOADOUT CLEANUP: Freed [H.job] slot (now [J.current_positions]/[J.total_positions])")
			
			// Delete the character
			if(H.mind)
				H.mind.current = null
			log_game("LOADOUT CLEANUP: Deleting mob for [original_ckey]")
			qdel(H)
			
			// Notify admins
			message_admins(span_boldwarning("Player [original_ckey] has disconnected during loadout equipment. Their mob has been deleted and a [job_name] slot has been opened up."))
			
			return FALSE
	
	// Check if client disconnected during equipOutfit (input() calls)
	if(original_client && !H.client)
		log_game("LOADOUT DISCONNECT: [original_ckey] disconnected during [name] equipment, cleaning up")
		
		// Free up the job slot
		if(H.job)
			var/datum/job/J = SSjob.GetJob(H.job)
			if(J)
				J.current_positions = max(0, J.current_positions - 1)
				log_game("LOADOUT DISCONNECT: Freed [H.job] slot (now [J.current_positions]/[J.total_positions])")
		
		// Delete the character
		if(H.mind)
			H.mind.current = null
		qdel(H)
		
		return FALSE

	post_equip(H)

	H.advjob = name

	var/turf/TU = get_turf(H)
	if(TU)
		if(horse)
			new horse(TU)

	for(var/trait in traits_applied)
		ADD_TRAIT(H, trait, ADVENTURER_TRAIT)

	if(noble_income)
		SStreasury.noble_incomes[H] = noble_income

	if(length(subclass_languages))
		for(var/lang in subclass_languages)
			H.grant_language(lang)

	if(length(subclass_stats))
		for(var/stat in subclass_stats)
			H.change_stat(stat, subclass_stats[stat])

	if(length(subclass_skills))
		for(var/skill in subclass_skills)
			H.adjust_skillrank_up_to(skill, subclass_skills[skill], TRUE)

	if(subclass_spellpoints > 0)
		H.mind?.adjust_spellpoints(subclass_spellpoints)

	if(subclass_social_rank)
		H.social_rank = subclass_social_rank

	// After the end of adv class equipping, apply a SPECIAL trait if able

	if(applies_post_equipment)
		apply_character_post_equipment(H)

/datum/advclass/proc/post_equip(mob/living/carbon/human/H)
	addtimer(CALLBACK(H,TYPE_PROC_REF(/mob/living/carbon/human, add_credit), TRUE), 20)
	if(cmode_music)
		H.cmode_music = cmode_music

/*
	Whoa! we are checking requirements here!
	On the datum! Wow!
*/
/datum/advclass/proc/check_requirements(mob/living/carbon/human/H)

	var/datum/species/pref_species = H.dna.species
	var/list/local_allowed_sexes = list()
	if(length(allowed_sexes))
		local_allowed_sexes |= allowed_sexes
	if(!immune_to_genderswap && pref_species?.gender_swapping)
		if(MALE in allowed_sexes)
			local_allowed_sexes -= MALE
			local_allowed_sexes += FEMALE
		if(FEMALE in allowed_sexes)
			local_allowed_sexes -= FEMALE
			local_allowed_sexes += MALE
	if(length(local_allowed_sexes) && !(H.gender in local_allowed_sexes))
		return FALSE

	if(length(allowed_races) && !(H.dna.species.type in allowed_races))
		return FALSE

	if(length(disallowed_races) && (H.dna.species.type in disallowed_races))
		return FALSE

	if(length(allowed_ages) && !(H.age in allowed_ages))
		return FALSE

	if(length(allowed_patrons) && !(H.patron in allowed_patrons))
		return FALSE

	if(length(virtue_restrictions) && H.client)
		if((H.client.prefs.virtue?.type in virtue_restrictions) || (H.client.prefs.virtuetwo?.type in virtue_restrictions) || (H.client.prefs.virtue_origin?.type in virtue_restrictions))
			return FALSE

	if(maximum_possible_slots > -1)
		if(total_slots_occupied >= maximum_possible_slots)
			return FALSE

	if(min_pq != -100) // If someone sets this we actually do the check.
		if(!(get_playerquality(H.client.ckey) >= min_pq))
			return FALSE

	if(prob(pickprob))
		return TRUE

// Basically the handler has a chance to plus up a class, heres a generic proc you can override to handle behavior related to it.
// For now you just get an extra stat in everything depending on how many plusses you managed to get.
/datum/advclass/proc/boost_by_plus_power(plus_factor, mob/living/carbon/human/H)
	for(var/S in MOBSTATS)
		H.change_stat(S, plus_factor)


//Final proc in the set for really silly shit
///datum/advclass/proc/extra_slop_proc_ending(mob/living/carbon/human/H)

