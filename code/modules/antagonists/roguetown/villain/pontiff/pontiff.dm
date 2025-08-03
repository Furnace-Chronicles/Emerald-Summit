//Ascendant, effectively.
//This is just reworking that into a team antag, with adjustments accordingly.
//Intended to scour the map for artefacts and relics.
//Secondary to that, purging the 'cursed' and 'tainted'.
//Reverse brigands and wretch, more-or-less.

/datum/antagonist/pontiff
	name = "Pontiff"
	roundend_category = "maniacs"
	antagpanel_category = "PONTIFF"
	antag_memory = "<b>PSYDON LIVES. I am one of the chosen, having clawed my way back to reality. This world is not in His image. I must set it right.</b>"
	job_rank = ROLE_PONTIFF
	antag_hud_type = ANTAG_HUD_TRAITOR
	antag_hud_name = "villain"
	confess_lines = list(
		"I live, I die, I live again!",
		"I set the stage for His return!",
		"His image, made manifest!",
		"I ENDURE in His name!",
	)
	rogue_enabled = TRUE

//We'll have the wide reaching traits handled by this, rather than the roles.
	var/static/list/applied_traits = list(
		TRAIT_PONTIFF,
		TRAIT_OUTLANDER,//Not of this land.
		TRAIT_STEELHEARTED,
		TRAIT_NOBREATH,//They're technically corpses.
		TRAIT_TOXIMMUNE,
		TRAIT_NOHUNGER,
		TRAIT_NOSTINK,
		TRAIT_ZOMBIE_IMMUNE,//They're immune to the rot by way of bites.
		TRAIT_COUNTERCOUNTERSPELL,//You are not going to shut them out from the power gifted to them. Sorry.
		TRAIT_SILVER_BLESSED,//Immunity to the cursed they hunt.
	)

//Knowledge of the cursed and tainted.
/datum/antagonist/pontiff/examine_friendorfoe(datum/antagonist/examined_datum,mob/examiner,mob/examined)
//Friend...
	if(istype(examined_datum, /datum/antagonist/pontiff))
		return span_boldnotice("One of my companions. Ancient as I.")
//Foes, cursed...
	if(istype(examined_datum, /datum/antagonist/werewolf))
		return span_boldnotice("One of Dendor's cursed. Old. Ready.")
	if(istype(examined_datum, /datum/antagonist/werewolf/lesser))
		return span_boldnotice("One of Dendor's cursed. Yet blooded.")
	if(istype(examined_datum, /datum/antagonist/vampirelord))
		return span_boldwarning("One of tainted blood. Dangerous.")
	if(istype(examined_datum, /datum/antagonist/vampirelord/lesser))
		return span_boldwarning("One of tainted blood. Weak. Afraid.")
//Foes, natural...
	if(istype(examined_datum, /datum/antagonist/bandit))
		return span_boldwarning("Inhumen freak...")

/datum/antagonist/pontiff/on_gain()
	. = ..()

	owner.special_role = ROLE_PONTIFF
	if(owner.current)
		if(ishuman(owner.current))

			for(var/trait in applied_traits)
				ADD_TRAIT(owner.current, trait, "[type]")

			SEND_SOUND(owner.current, 'sound/villain/ascendant_intro.ogg')
			to_chat(owner.current, span_danger("[antag_memory]"))
			forge_pontiff_objectives()

		equip_pontiff()
		move_to_spawnpoint()

/datum/antagonist/pontiff/proc/move_to_spawnpoint()
	owner.current.forceMove(pick(GLOB.pontiff_starts))

/datum/antagonist/pontiff/proc/equip_pontiff()

	owner.unknow_all_people()
	for(var/datum/mind/MF in get_minds())
		owner.become_unknown_to(MF)
	for(var/datum/mind/MF in get_minds("Pontiff"))
		owner.i_know_person(MF)
		owner.person_knows_me(MF)

	var/mob/living/carbon/human/L = owner.current
	L.mob_biotypes |= MOB_UNDEAD//They ARE corpses, after all.

	return TRUE

/datum/antagonist/pontiff/roundend_report()
	if(owner?.current)
		var/the_name = owner.name
		if(ishuman(owner.current))
			var/mob/living/carbon/human/H = owner.current
			the_name = H.real_name
//		to_chat(world, "[the_name] was one of Psydon's Pontiffs.")
		if(SSmapping.retainer.pontiff_stage >= SSmapping.retainer.pontiff_goal)
			for(var/datum/mind/M in SSmapping.retainer.pontiffs)
				if(considered_alive(M))
					M.adjust_triumphs(6)//Good work, trooper.
			to_chat(world, "[the_name] had been a Pontiff. Their party has recovered all relics!")
		else
			to_chat(world, "[the_name] had been a Pontiff. Their party had [SSmapping.retainer.pontiff_goal - SSmapping.retainer.pontiff_stage] relics left to recover.")

/datum/antagonist/pontiff/proc/add_objective(datum/objective/O)
	objectives += O

/datum/antagonist/pontiff/proc/remove_objective(datum/objective/O)
	objectives -= O

/datum/antagonist/pontiff/proc/forge_pontiff_objectives()
	if(!(locate(/datum/objective/pontiff) in objectives))
		var/datum/objective/pontiff/contrib_objective = new
		contrib_objective.owner = owner
		add_objective(contrib_objective)
		return
