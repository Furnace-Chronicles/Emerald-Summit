/*
Not quite an 'adventurer' in the same sense that bandits might be.
But there's really no better, more fitting place to slap them into.
Stat spread of 7. Better skills than contemporaries. Depending. Chunky starting equipment.
Many, many traits and a 'unique' gameplay loop. Hopefully.
Three in total, with no doubling of subclasses. There will always be one of each.
Artefacts should push them towards being an adventurer party, I hope.
*/
/datum/job/roguetown/pontiff
	title = "Pontiff"
	flag = PONTIFF
	department_flag = PEASANTS
	faction = "Station"
	total_positions = 3
	spawn_positions = 3
	antag_job = TRUE
	allowed_races = RACES_CHURCH_FAVORED_UP
	allowed_patrons = PSYDON_PATRONS
	tutorial = "Once four, now three. Part of an old-world vigil over an altar, you're more corpse than man. Held aloft by faith alone. Yet, you must ENDURE. \
	The altar calls to you, after centuries of silence, and you now know what must be done."

	outfit = null
	outfit_female = null

	obsfuscated_job = TRUE

	display_order = JDO_PONTIFF
	announce_latejoin = FALSE
	min_pq = 20//Do we really trust new players with objective based gameplay? I'd think not. Same as Wretch.
	max_pq = null
	round_contrib_points = 5

	advclass_cat_rolls = list(CTAG_PONTIFF = 20)
	PQ_boost_divider = 10

	wanderer_examine = TRUE
	advjob_examine = TRUE
	always_show_on_latechoices = TRUE
	job_reopens_slots_on_death = FALSE
	same_job_respawn_delay = 1 MINUTES

//For the casting and yapping.
	vice_restrictions = list(/datum/charflaw/mute)
//NO, THANKS.
	virtue_restrictions = list(/datum/virtue/heretic/zchurch_keyholder)

/datum/job/roguetown/pontiff/after_spawn(mob/living/L, mob/M, latejoin = TRUE)
	..()
	if(L)
		var/mob/living/carbon/human/H = L
		if(!H.mind)
			return
		H.advsetup = 1
		H.invisibility = INVISIBILITY_MAXIMUM
		H.become_blind("advsetup")
		H.ambushable = FALSE

/datum/outfit/job/roguetown/pontiff/post_equip(mob/living/carbon/human/H)
	..()
	var/datum/antagonist/new_antag = new /datum/antagonist/pontiff()
	H.mind.add_antag_datum(new_antag)
	addtimer(CALLBACK(H, TYPE_PROC_REF(/mob/living/carbon/human, choose_name_popup), "PONTIFF"), 5 SECONDS)
	var/wanted = list("I have suffered the long dark", "I have remained of sound mind")
	var/wanted_choice = input("Is my mind clear? My soul untainted?") as anything in wanted
	switch(wanted_choice)
		if("I have suffered the long dark")
			ADD_TRAIT(H, TRAIT_SCHIZO_AMBIENCE, TRAIT_GENERIC)
		if("I have remained of sound mind")
			return
