#define ZOMBIE_FIRST_BITE_CHANCE 15
#define ZOMBIE_BITE_CONVERSION_TIME 1.5 MINUTES

/datum/antagonist/zombie
	name = "Deadite"
	antag_hud_type = ANTAG_HUD_ZOMBIE
	antag_hud_name = "zombie_hud"
	show_in_roundend = FALSE
	rogue_enabled = TRUE
	/// SET TO FALSE IF WE DON'T TURN INTO ROTMEN WHEN REMOVED
	var/become_rotman = FALSE
	var/zombie_start
	var/revived = FALSE
	var/next_idle_sound

	antag_flags = FLAG_FAKE_ANTAG

	// CACHE VARIABLES SO ZOMBIFICATION CAN BE CURED
	var/was_i_undead = FALSE
	var/special_role
	var/ambushable = TRUE
	var/soundpack_m
	var/soundpack_f
	/// Saved sources for traits forcibly stripped at transform time (restored on cure)
	var/list/stripped_traits

	var/cmode_music
	var/list/base_intents

	/// Whether or not we have been turned
	var/has_turned = FALSE
	/// Last time we bit someone - Zombies will try to bite after 10 seconds of not biting
	var/last_bite
	/// Traits applied to the owner mob when we turn into a zombie
	var/static/list/traits_zombie = list(
		TRAIT_LIMBATTACHMENT,
		TRAIT_BREADY,
		TRAIT_NOMOOD,
		TRAIT_NOHUNGER,
		TRAIT_EASYDISMEMBER,
		TRAIT_NOPAIN,
		TRAIT_NOBREATH,
		TRAIT_NOBREATH,
		TRAIT_TOXIMMUNE,
		TRAIT_CHUNKYFINGERS,
		TRAIT_NOSLEEP,
		TRAIT_BASHDOORS,
		TRAIT_SPELLCOCKBLOCK,
		TRAIT_BLOODLOSS_IMMUNE,
		TRAIT_ZOMBIE_SPEECH,
		TRAIT_ZOMBIE_IMMUNE,
		TRAIT_ROTMAN,
		//TRAIT_NORUN, // applied only during the deadite_grace period now; re-add here if zombies become too problematic
		TRAIT_SILVER_WEAK,
		TRAIT_CALTROPIMMUNE, // shamblers don't stumble over glass shards or caltrops
		TRAIT_DEADITE
	)
	/// Traits applied to the owner when we are cured and turn into just "rotmen"
	var/static/list/traits_rotman = list(
		TRAIT_EASYDISMEMBER,
		TRAIT_NOPAIN,
		TRAIT_NOPAINSTUN,
		TRAIT_NOBREATH,
		TRAIT_TOXIMMUNE,
		TRAIT_ZOMBIE_IMMUNE,
		TRAIT_ROTMAN,
		TRAIT_SILVER_WEAK,
	)

/datum/antagonist/zombie/examine_friendorfoe(datum/antagonist/examined_datum,mob/examiner,mob/examined)
	if(istype(examined_datum, /datum/antagonist/vampire))
		if(!SEND_SIGNAL(examined_datum.owner, COMSIG_DISGUISE_STATUS))
			return span_boldnotice("Another deadite.")
	if(istype(examined_datum, /datum/antagonist/zombie))
		var/datum/antagonist/zombie/fellow_zombie = examined_datum
		return span_boldnotice("Another deadite. [fellow_zombie.has_turned ? "My ally." : span_warning("Hasn't turned yet.")]")
	if(istype(examined_datum, /datum/antagonist/skeleton))
		return span_boldnotice("Another deadite.")

// --- Deadite statline (ported from AP #7325) -----------------------------------------------------
// Rather than snapshotting/restoring the player's stats, a buff forces a fixed deadite statline by
// computing the delta from the owner's current stats at apply time; removing the buff reverts it.
// ES note: AP's willpower stat maps to ES endurance, so WIL 13 -> END 13.
/atom/movable/screen/alert/status_effect/buff/zombified
	name = "zombified"
	desc = "HUNGER. MUST. HAVE. FLESH."
	icon_state = "poison"

/datum/status_effect/buff/zombified
	id = "zombified"
	alert_type = /atom/movable/screen/alert/status_effect/buff/zombified

/datum/status_effect/buff/zombified/on_apply()
	effectedstats = list(
		STATKEY_STR = (14 - owner.STASTR),
		STATKEY_SPD = (5 - owner.STASPD),
		STATKEY_INT = (1 - owner.STAINT),
		STATKEY_CON = (12 - owner.STACON),
		STATKEY_END = (13 - owner.STAEND),
		STATKEY_PER = (13 - owner.STAPER)
		)
	. = ..()
	return TRUE

//Housekeeping/saving variables from pre-zombie

/*Death transformation process goes:
	death -> 
	/mob/living/carbon/human/death(gibbed) -> 
	zombie_check_can_convert() -> 
	zombie.on_gain() -> 
	rotting.dm process -> 
	time passes -> 
	zombie.wake_zombie() -> 
	transform
*/
/*
	Deadite transformation is 2 ways. First is on the initial bite (low chance) and second is on being chewed on.

	Initial bite is: other_mobs.dm, /mob/living/carbon/onbite(mob/living/carbon/human/user) ->
	bite_victim.zombie_infect_attempt() -> 
	attempt_zombie_infection(src, "bite", ZOMBIE_BITE_CONVERSION_TIME) -> rng check here
	time passes ->
	wake_zombie.

	Wound transformation goes: grabbing.dm, /obj/item/grabbing/bite/proc/bitelimb(mob/living/carbon/human/user) ->
	/datum/wound/proc/zombie_infect_attempt() -> 
	human_owner.attempt_zombie_infection(src, "wound", zombie_infection_time) ->
	time passes -> 
	wake_zombie

	Infection transformation process goes -> infection -> timered transform in zombie_infect_attempt() [drink red/holy water and kill timer?] -> /datum/antagonist/zombie/proc/wake_zombie -> zombietransform
*/
/datum/antagonist/zombie/on_gain(admin_granted = FALSE)
	var/mob/living/carbon/human/zombie = owner?.current
	if(zombie)
		var/obj/item/bodypart/head = zombie.get_bodypart(BODY_ZONE_HEAD)
		if(!head)
			qdel(src)
			return
	zombie_start = world.time
	was_i_undead = zombie.mob_biotypes & MOB_UNDEAD
	special_role = zombie.mind?.special_role
	ambushable = zombie.ambushable
	if(zombie.dna?.species)
		soundpack_m = zombie.dna.species.soundpack_m
		soundpack_f = zombie.dna.species.soundpack_f
	base_intents = zombie.base_intents

	cmode_music = zombie.cmode_music

	//Special because deadite status is latent as opposed to the others. 
	if(admin_granted)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(wake_zombie), zombie, FALSE, TRUE), 5 SECONDS, TIMER_STOPPABLE)
	return ..()

/*
	CHECK HERE IF ANY UN-ZOMBIFICATION ISSUES.
*/
///Remove zombification - cure rot, surgical rot remove
/datum/antagonist/zombie/on_removal()
	var/mob/living/carbon/human/zombie = owner?.current
	if(zombie)
		remove_antag_hud(antag_hud_type, owner.current) //No more HUD.
		zombie.verbs -= /mob/living/carbon/human/proc/zombie_seek
		zombie.mind?.special_role = special_role
		zombie.ambushable = ambushable
		
		if(zombie.dna?.species)
			zombie.dna.species.soundpack_m = soundpack_m
			zombie.dna.species.soundpack_f = soundpack_f
		zombie.base_intents = base_intents
		zombie.update_a_intents()
		zombie.aggressive = FALSE
		zombie.mode = NPC_AI_OFF
		zombie.npc_jump_chance = initial(zombie.npc_jump_chance)
		zombie.rude = initial(zombie.rude)
		zombie.tree_climber = initial(zombie.tree_climber)
		if(zombie.charflaw)
			zombie.charflaw.ephemeral = FALSE
		zombie.update_body()

		GLOB.dead_mob_list -= zombie // Remove it from global dead/alive mob list here here, if they're a zombie they probably died.
									 // There is a better way to maintain it but needs overhaul. Will cover the two methods of zombie
		GLOB.alive_mob_list += zombie// in both cure rot and medicine.

		zombie.remove_status_effect(/datum/status_effect/buff/zombified)
		zombie.cmode_music = cmode_music

		for(var/trait in traits_zombie)
			REMOVE_TRAIT(zombie, trait, "[type]")
		if(stripped_traits)
			for(var/trait in stripped_traits)
				for(var/source in stripped_traits[trait])
					ADD_TRAIT(zombie, trait, source)
			stripped_traits = null
		zombie.remove_client_colour(/datum/client_colour/monochrome)

		if(has_turned && become_rotman)
			for(var/trait in traits_rotman)
				ADD_TRAIT(zombie, trait, "[type]")
			to_chat(zombie, span_green("I no longer crave for flesh... <i>But I still feel ill.</i>"))
		else
			if(!was_i_undead)
				zombie.mob_biotypes &= ~MOB_UNDEAD
			zombie.faction -= "undead"
			zombie.faction -= "zombie"
			zombie.faction += "neutral"
			zombie.regenerate_organs()
			if(has_turned)
				to_chat(zombie, span_green("I no longer crave for flesh..."))

		for(var/obj/item/bodypart/zombie_part as anything in zombie.bodyparts) //Cure all limbs
			zombie_part.rotted = FALSE
			zombie_part.update_disabled()
			zombie_part.update_limb()
		zombie.update_body()
	// Bandaid to fix the zombie ghostizing not allowing you to re-enter
	if(zombie)
		var/mob/dead/observer/ghost = zombie.get_ghost(TRUE)
		if(ghost)
			ghost.can_reenter_corpse = TRUE
	return ..()

//Housekeeping's done. Transform into zombie.
/datum/antagonist/zombie/proc/transform_zombie(quiet = FALSE)
	var/mob/living/carbon/human/zombie = owner.current
	if(!zombie)
		qdel(src)
		return
	var/obj/item/bodypart/head = zombie.get_bodypart(BODY_ZONE_HEAD)
	if(!head) //If no head then unable to become zombie
		qdel(src)
		return

	// The mind grows numb and empty: purge lingering status effects before applying our own.
	// Otherwise buffs like Necra's Vow (and its permanent passive healing) survive zombification,
	// leaving deadites that regenerate and can't be revived/cured properly.
	for(var/datum/status_effect/effect as anything in zombie.status_effects?.Copy())
		qdel(effect) // qdel directly: remove_status_effect() resolves by id and would miss same-id duplicates

	revived = TRUE //so we can die for real later
	add_antag_hud(antag_hud_type, antag_hud_name, owner.current) //Easier for fellow zombies to tell.
	zombie.apply_status_effect(/datum/status_effect/buff/zombified) //Force the deadite statline.
	// ES note: no /datum/language/undead here -- ES zombie speech is handled by TRAIT_ZOMBIE_SPEECH (in traits_zombie).

	for(var/trait_applied in traits_zombie)
		ADD_TRAIT(zombie, trait_applied, "[type]")
	// Deadites must not have critical resistance or enduring (pain stun immunity) from any prior source.
	// Necra's Vow is broken by undeath too: its healing buff is purged above, but the trait is granted
	// separately and would otherwise keep blocking revival. Save the sources so they can be restored
	// if the player is cured.
	for(var/forbidden in list(TRAIT_CRITICAL_RESISTANCE, TRAIT_NOPAINSTUN, TRAIT_NECRAS_VOW))
		if(zombie.status_traits?[forbidden])
			if(!stripped_traits)
				stripped_traits = list()
			stripped_traits[forbidden] = zombie.status_traits[forbidden].Copy()
			REMOVE_TRAIT(zombie, forbidden, zombie.status_traits[forbidden].Copy())
	if(zombie.mind)
		special_role = zombie.mind.special_role
		zombie.mind.special_role = name
	if(zombie.dna?.species)
		soundpack_m = zombie.dna.species.soundpack_m
		soundpack_f = zombie.dna.species.soundpack_f
		zombie.dna.species.soundpack_m = new /datum/voicepack/zombie/m()
		zombie.dna.species.soundpack_f = new /datum/voicepack/zombie/f()
	base_intents = zombie.base_intents
	zombie.base_intents = list(INTENT_HELP, INTENT_DISARM, INTENT_GRAB, /datum/intent/unarmed/claw)
	zombie.update_a_intents()
	zombie.aggressive = TRUE
	zombie.mode = NPC_AI_IDLE
	zombie.enemies = list() // old grudges die with the mind -- stops fresh zombies feuding with fellow undead
	zombie.handle_ai()
	ambushable = zombie.ambushable
	zombie.ambushable = FALSE

	if(zombie.charflaw)
		zombie.charflaw.ephemeral = TRUE
	zombie.mob_biotypes |= MOB_UNDEAD
	zombie.faction |= "undead" // |= not +=: NPC deadites already spawn with these factions
	zombie.faction |= "zombie"
	zombie.faction -= "neutral"
	zombie.verbs |= /mob/living/carbon/human/proc/zombie_seek
	for(var/obj/item/bodypart/zombie_part as anything in zombie.bodyparts)
		if(!zombie_part.rotted && !zombie_part.skeletonized)
			zombie_part.rotted = TRUE
		zombie_part.update_disabled()

	zombie.add_client_colour(/datum/client_colour/monochrome)
	var/obj/item/organ/eyes/eyes = zombie.getorganslot(ORGAN_SLOT_EYES) //Add zombie eyes(nightvision)
	if(eyes)
		eyes.Remove(zombie,1)
		QDEL_NULL(eyes)
	eyes = new /obj/item/organ/eyes/night_vision/zombie
	eyes.Insert(zombie)

//Drop held items

	zombie.dropItemToGround(zombie.get_active_held_item(), TRUE)
	zombie.dropItemToGround(zombie.get_inactive_held_item(), TRUE)

//Add claws here if wanted.

	zombie.update_body()
	zombie.cmode_music = 'sound/music/combat_weird.ogg'

	last_bite = world.time
	has_turned = TRUE
	// Drop whatever's in the mouth -- a workaround for being gagged.
	var/static/list/removed_slots = list(
		SLOT_MOUTH,
	)
	for(var/slot in removed_slots)
		zombie.dropItemToGround(zombie.get_item_by_slot(slot), TRUE)

	record_round_statistic(STATS_DEADITES_WOKEN_UP)

	if(quiet) // spawned NPC deadites skip the rising cutscene and the grace period entirely
		return

	zombie.playsound_local(get_turf(zombie), 'sound/music/wolfintro.ogg', 80, FALSE, pressure_affected = FALSE) //Extra AURA on transform
	to_chat(zombie, span_infection("My mind grows numb and empty as unlyfe takes ahold of my body..."))
	zombie.apply_status_effect(/datum/status_effect/debuff/deadite_grace)

	// Small rising "cutscene"; deadite_grace's GODMODE protects us through the vulnerable sleeps.
	sleep(0.1)
	zombie.Knockdown(33)
	zombie.Immobilize(33)
	zombie.Stun(33)
	zombie.Jitter(15)
	zombie.emote("groan")
	zombie.drop_all_held_items()
	zombie.Unconscious(15)
	zombie.flash_fullscreen("redflash3")
	zombie.visible_message(span_warning("[zombie] convulses on the floor momentarily, skin rotting away unnaturally fast..."))
	sleep(2 SECONDS)
	zombie.visible_message(span_warning("[zombie]'s lyfeless eyes begin to light up with an eerie glow."))
	zombie.vomit(1, blood = TRUE, stun = FALSE)
	playsound(get_turf(zombie), 'sound/magic/woundheal_crunch.ogg', 80, FALSE, -1)
	to_chat(zombie, span_narsie("Death is not the end..."))
	sleep(2 SECONDS)
	if(zombie.resting)
		zombie.set_resting(FALSE, FALSE)
	zombie.visible_message(span_danger("[zombie] stands back up."))
	zombie.emote("rage")
	playsound(get_turf(zombie), 'sound/magic/woundheal_crunch.ogg', 80, FALSE, -1)
	to_chat(zombie, span_narsie(pick("SO... HUNGRY... CRAVE FLESH!", "FLESH... MUST HAVE FLESH!", "HUNGER... KILL... FLESH!")))
	zombie.set_blurriness(0)
	if(!zombie.cmode)
		zombie.toggle_cmode()

// Infected wake param is just a transition from living to zombie, via zombie_infect()
// Prevoously you just died without warning in ~3 min, now you just become an antag instead of having to die first if infected.
/datum/antagonist/zombie/proc/wake_zombie(infected_wake = FALSE, quiet = FALSE)
	if(!owner.current)
		return
	var/mob/living/carbon/human/zombie = owner.current
	if(!zombie || !istype(zombie))
		return
	var/obj/item/bodypart/head = zombie.get_bodypart(BODY_ZONE_HEAD)
	if(!head)
		qdel(src)
		return
	if(zombie.stat != DEAD && !infected_wake)
		qdel(src)
		return
	if(istype(zombie.loc, /obj/structure/closet/dirthole) || istype(zombie.loc, /obj/structure/closet/crate/coffin))
		qdel(src)
		return

	zombie.can_do_sex = FALSE	//no fuck off

	zombie.blood_volume = BLOOD_VOLUME_NORMAL
	zombie.setOxyLoss(0, updating_health = FALSE, forced = TRUE)
	zombie.setToxLoss(0, updating_health = FALSE, forced = TRUE)
	// Always heal on the rise, matching the global wake_zombie() ("flesh knits itself back
	// together"). Rising with pre-turn wounds intact left players bleeding out as deadites.
	zombie.adjustBruteLoss(-INFINITY, updating_health = FALSE, forced = TRUE)
	zombie.adjustFireLoss(-INFINITY, updating_health = FALSE, forced = TRUE)
	zombie.heal_wounds(INFINITY)
	zombie.stat = UNCONSCIOUS
	zombie.updatehealth()
	zombie.update_mobility()
	zombie.update_sight()
	zombie.reload_fullscreen()
	transform_zombie(quiet)
	if(zombie.stat >= DEAD)
		//could not revive
		qdel(src)

/datum/antagonist/zombie/greet()
	to_chat(owner.current, span_userdanger("Death is not the end..."))
	return ..()

/*
	Check for zombie infection post bite
		Bite chance is checked here
		Wound chance is checked in zombie_wound_infection.dm
*/
/mob/living/carbon/human/proc/attempt_zombie_infection(mob/living/carbon/human/source, infection_type, wake_delay = 0)
	var/mob/living/carbon/human/victim = src
	if (QDELETED(src) || stat >= DEAD)
		return FALSE

	var/datum/antagonist/zombie/victim_zombie = victim.mind?.has_antag_datum(/datum/antagonist/zombie)
	if (victim_zombie) //Check that the victim isn't already a zombie or on the way to becoming one
		return FALSE

	var/datum/antagonist/zombie/zombie_antag = source.mind?.has_antag_datum(/datum/antagonist/zombie)
	if (!zombie_antag || !zombie_antag.has_turned) //Check that the zombie who bit us is real
		return FALSE

	//How did the victim get infected
	switch (infection_type)
		if ("bite")
			if (!prob(ZOMBIE_FIRST_BITE_CHANCE)) // Chance to infect via first bite (rare)
				return FALSE
			to_chat(victim, span_danger("A growing cold seeps into my body. I feel horrible... REALLY horrible..."))
			mob_timers["puke"] = world.time
			vomit(1, blood = TRUE, stun = FALSE)

		if ("wound")	//Chance to infect via chewing to open wound
			flash_fullscreen("redflash3")
			to_chat(victim, span_danger("Ow! It hurts. I feel horrible... REALLY horrible..."))

	victim.zombie_check_can_convert() //They are given zombie antag mind here unless they're already an antag.

//Delay on waking up as a zombie. /proc/wake_zombie(mob/living/carbon/zombie, infected_wake = FALSE, converted = FALSE)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(wake_zombie), victim, FALSE, TRUE), wake_delay, TIMER_STOPPABLE)
	return zombie_antag

/*
	Proc for our newly infected to wake up as a zombie
*/
/proc/wake_zombie(mob/living/carbon/zombie, infected_wake = FALSE, converted = FALSE)
	if (!zombie || QDELETED(zombie)) 
		return

	if (!istype(zombie, /mob/living/carbon/human)) // Ensure the zombie is human
		return

	var/obj/item/bodypart/head = zombie.get_bodypart(BODY_ZONE_HEAD)
	if (!head) // Missing head
		qdel(zombie)
		return

	if (zombie.stat != DEAD && infected_wake) // Died too hard
		qdel(zombie)
		return

	if (istype(zombie.loc, /obj/structure/closet/dirthole) || istype(zombie.loc, /obj/structure/closet/crate/coffin)) // Buried
		qdel(zombie)
		return

	// Heal the zombie
	zombie.blood_volume = BLOOD_VOLUME_NORMAL
	zombie.setOxyLoss(0, updating_health = FALSE, forced = TRUE) // Zombies don't breathe
	zombie.setToxLoss(0, updating_health = FALSE, forced = TRUE) // Zombies are immune to poison

	if (infected_wake || converted)
		zombie.adjustBruteLoss(-INFINITY, updating_health = FALSE, forced = TRUE)
		zombie.adjustFireLoss(-INFINITY, updating_health = FALSE, forced = TRUE)
		zombie.heal_wounds(INFINITY) // Heal all non-permanent wounds
		to_chat(zombie, span_userdanger("Your bones snap back into place and your flesh knits itself back together as you rise again in undeath."))

	zombie.stat = UNCONSCIOUS // Start unconscious
	zombie.updatehealth() // Then check if the mob should wake up
	zombie.update_mobility()
	zombie.update_sight()
	zombie.reload_fullscreen()

	var/datum/antagonist/zombie/zombie_antag = zombie.mind?.has_antag_datum(/datum/antagonist/zombie)
	if(zombie_antag)
		zombie_antag.transform_zombie()
	else
		CRASH("[zombie] tried to wake up as a zombie but did not have the antag set.")

	if (zombie.stat >= DEAD) // We couldn't bring them back to life as a zombie. Nothing we can do.
		qdel(zombie)
		return

///Making sure they're not any other antag as well as adding the zombie datum to their mind
/mob/living/carbon/human/proc/zombie_check_can_convert()
	if(!mind)
		return
	if(mind.has_antag_datum(/datum/antagonist/vampire))
		return
	if(mind.has_antag_datum(/datum/antagonist/werewolf))
		return
	if(mind.has_antag_datum(/datum/antagonist/zombie))
		return
	if(mind.has_antag_datum(/datum/antagonist/skeleton))
		return
	if(HAS_TRAIT(src, TRAIT_ZOMBIE_IMMUNE))
		return
	return mind.add_antag_datum(/datum/antagonist/zombie)

// --- Deadite grace period (ported from AP #7325) -------------------------------------------------
// Brief invulnerability + mobility kit applied as a deadite rises, so the rising "cutscene" can't be
// interrupted by death. Also the only place TRAIT_NORUN is applied now (deadites can run once it ends).
/atom/movable/screen/alert/status_effect/debuff/deadite_grace
	name = "Unlyfe's Grace"
	desc = "Dark tendrils knit my rotting flesh together. I cannot be slain while it lasts."
	icon_state = "debuff"

/datum/status_effect/debuff/deadite_grace
	id = "deadite_grace_period"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/deadite_grace
	duration = 3 MINUTES

/datum/status_effect/debuff/deadite_grace/on_apply()
	. = ..()
	var/mob/living/carbon/human/H = owner
	H.status_flags |= GODMODE
	ADD_TRAIT(owner, TRAIT_NORUN, id)
	ADD_TRAIT(owner, TRAIT_IGNORESLOWDOWN, id)
	ADD_TRAIT(owner, TRAIT_LONGSTRIDER, id)
	ADD_TRAIT(owner, TRAIT_STRONG_GRABBER, id)
	to_chat(owner, span_userdanger("I feel my body tense up immensely in response to this hunger, tendrils of darkness crawling under my skin."))
	RegisterSignal(owner, COMSIG_HUMAN_MELEE_UNARMED_ATTACK, PROC_REF(attack_ends_grace)) //committing to an attack ends the grace early

// "As soon as you attack something you regain the ability to sprint at the cost of your short-term immortality."
/datum/status_effect/debuff/deadite_grace/proc/attack_ends_grace(datum/source, atom/target)
	SIGNAL_HANDLER
	if(isliving(target))
		to_chat(owner, span_warning("I lash out -- my unnatural vigor fades, but my legs are my own again."))
		qdel(src)

/datum/status_effect/debuff/deadite_grace/on_remove()
	. = ..()
	UnregisterSignal(owner, COMSIG_HUMAN_MELEE_UNARMED_ATTACK)
	var/mob/living/carbon/human/H = owner
	H.status_flags -= GODMODE
	REMOVE_TRAIT(owner, TRAIT_NORUN, id)
	REMOVE_TRAIT(owner, TRAIT_IGNORESLOWDOWN, id)
	REMOVE_TRAIT(owner, TRAIT_LONGSTRIDER, id)
	REMOVE_TRAIT(owner, TRAIT_STRONG_GRABBER, id)
	to_chat(owner, span_userdanger("I feel my body relax a little, and that is the last thing I feel as my Lux wanes... I am fading."))

