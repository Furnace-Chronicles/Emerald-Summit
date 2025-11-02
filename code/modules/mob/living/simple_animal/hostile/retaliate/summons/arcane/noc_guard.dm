/mob/living/simple_animal/hostile/retaliate/rogue/arcane/noc_guard
	name = "noc guard"
	desc = "???? DELUSE ???? MISGOT </br> \
	*** ALICIT REIFICATE *** </br> \
	</br> \
	INTERDICTORATE PROACT: UNFABRICATE"
	icon = 'icons/mob/summonable/32x32.dmi'
	icon_state = "noc_guard"
	icon_living = "noc_guard"
	icon_dead = "head_s"
	turns_per_move = 1
	response_help_continuous = "passes through"
	response_help_simple = "pass through"
	response_disarm_continuous = "flails at"
	response_disarm_simple = "flail at"
	gender = FEMALE

/// watcher copypaste with some adjustments, health and stats

	emote_hear = null
	emote_see = list("floats hauntingly","ponders", "chuckles softly", "stares longingly")
	speak_emote = list("proposes", "denounces", "whispers")
	speak_chance = 100
	turns_per_move = 2
	see_in_dark = 12
	move_to_delay = 5
	base_intents = list(/datum/intent/simple/claw/wraith)
	butcher_results = list()
	mob_biotypes = MOB_SPIRIT
	health = 400 // WATCHER is 600
	maxHealth = 400
	melee_damage_lower = 20
	melee_damage_upper = 30
	vision_range = 9
	aggro_vision_range = 12
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	simple_detect_bonus = 20
	retreat_distance = 4
	minimum_distance = 3
	food_type = list()
	footstep_type = null
	pooptype = null
	STACON = 10
	STASTR = 8
	STASPD = 14
	STAINT = 14
	simple_detect_bonus = 20
	deaggroprob = 0
	defprob = 40
	retreat_health = 0.3
	food = 0
	attack_sound = list('sound/misc/lava_death.ogg')
	dodgetime = 20
	aggressive = 0
	ranged = TRUE
	ranged_cooldown = 30 
	projectiletype = /obj/projectile/magic/aoe/fireball/rogue/fireball_noc

/// custom stuff

	ranged_message = "glares"
	is_flying_animal = TRUE
	mob_size = MOB_SIZE_TINY
	ventcrawler = VENTCRAWLER_ALWAYS
	pass_flags = PASSTABLE|PASSGRILLE
	faction = list("noc")
	alpha = 10
//	var/mob/living/simple_animal/hostile/retaliate/rogue/summoned_target
	var/summoned_slaughter = TRUE
	see_invisible = TRUE
	light_power = 1
	light_outer_range =  2
	light_color = "#243453"
	minbodytemp = 0
	incorporeal_move = INCORPOREAL_MOVE_BASIC
	dodging = TRUE
	spacewalk = TRUE
	stat_attack = UNCONSCIOUS // do we kill till they are dead?.
	patron = /datum/patron/divine/noc
	density = FALSE // oh mama? might be problematic idk
	limb_destroyer = TRUE

/// STUFF THAT SUMMONS DIRECTLY UPON USE, GYATT DAYUMN!! ///

/obj/item/summoner_relics/noc_guard_crystal
	name = "lua shard"
	desc = "It is cold, yet gentle."
	icon = 'icons/roguetown/items/gems.dmi'
	icon_state = "quartz_fail"
	hitsound = 'sound/blank.ogg'
	dropshrink = 0.6
	grid_height = 32
	grid_width = 32

/mob/living/simple_animal/hostile/retaliate/rogue/arcane/noc_guard/New()
	. = ..()
	animate(src, alpha = 135, time = 25, easing = EASE_IN, flags = ANIMATION_PARALLEL)
	spawn(30)
		src.alpha = 135

/obj/item/summoner_relics/noc_guard_crystal/attack_self(mob/living/user)
	..()
	var/choice = alert(user,"SUMMON?", , "YES", "NO" )
	if(choice == "YES")
		var/turf/invoker_turf = get_step(get_turf(user), user.dir)
		var/mob/living/carbon/human/invoker = user
		to_chat(invoker, span_warning("A crack forms on the surface of the shard! It shatters within your grasp!"))
		invoker.flash_fullscreen("redflash1")
		new /obj/item/natural/glass_shard(invoker_turf)
		playsound(src, 'modular_azurepeak/sound/spellbooks/crystal.ogg', 70, TRUE)

		invoker.mind.current.faction += "[invoker.real_name]_faction"
		var/mob/living/simple_animal/hostile/retaliate/rogue/arcane/noc_guard/guard = new /mob/living/simple_animal/hostile/retaliate/rogue/arcane/noc_guard(invoker_turf)
		qdel(src)

		sleep(25)

		guard.summoned_slaughter = FALSE

		if(((invoker.get_skill_level(/datum/skill/magic/arcane)) == SKILL_LEVEL_NONE) || (invoker.summons_under.len >= 2))
			to_chat(invoker, span_hierophant("The apparition is before me, yet it does not recognize me as it's master!"))
			guard.Retaliate()
			guard.GiveTarget(invoker)
			return

		guard.faction += "[invoker.real_name]_faction"
		invoker.summons_under += guard
		guard.summoner = invoker

		if(!invoker.mind.has_spell(/obj/effect/proc_holder/spell/invoked/noc_guard_attack))
			invoker.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/noc_guard_attack)
			invoker.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/noc_guard_relocate)
			invoker.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/noc_guard_pacify)
	else
		return

/mob/living/simple_animal/hostile/retaliate/rogue/arcane/noc_guard/death(gibbed)
	..()
	var/turf/deathspot = get_turf(src)
	if(summoned_slaughter)
		new /obj/item/summoner_relics/noc_guard_crystal(deathspot)
	if(src.summoner)
		var/mob/living/carbon/human/invoker = src.summoner
		invoker.summons_under -= src
		if(invoker.summons_under.len == 0)
			invoker.mind.RemoveSpell(/obj/effect/proc_holder/spell/invoked/noc_guard_attack)
			invoker.mind.RemoveSpell(/obj/effect/proc_holder/spell/invoked/noc_guard_relocate)
			invoker.mind.RemoveSpell(/obj/effect/proc_holder/spell/invoked/noc_guard_pacify)
	var/obj/effect/particle_effect/blueshatter/shatter = new /obj/effect/particle_effect/blueshatter(deathspot)
	src.say("S T A T U S: C R I T I C A L", spans = list(SPAN_MACHINA))
	playsound(deathspot, 'sound/misc/carriage2.ogg', 100)
	update_icon()
	sleep(1)
	qdel(src)
	sleep(8)
	qdel(shatter)

/mob/living/simple_animal/hostile/retaliate/rogue/arcane/noc_guard/beckoned(mob/user)
	if((src.summoner == user) && !stop_automated_movement)
		stop_automated_movement = TRUE
		Goto(user, move_to_delay)
		addtimer(CALLBACK(src, PROC_REF(return_action)), 3 SECONDS)
	else if(src.summoner != user)
		Retaliate()
		GiveTarget(user)


/mob/living/simple_animal/hostile/retaliate/rogue/arcane/noc_guard/proc/apply_guard_stuff()
	ADD_TRAIT(src, TRAIT_PACIFISM, TRAIT_GENERIC)	//can't kill while planar bound.
	status_flags += GODMODE//It's not meant to be killable until released from it's planar binding.
	candodge = FALSE
	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	binded = TRUE
	SetParalyzed(900)

/mob/living/simple_animal/hostile/retaliate/rogue/arcane/noc_guard/proc/remove_guard_stuff()
	REMOVE_TRAIT(src, TRAIT_PACIFISM, TRAIT_GENERIC)	//can't kill while planar bound.
	status_flags -= GODMODE //remove godmode
	candodge = TRUE
	binded = FALSE
	move_resist = MOVE_RESIST_DEFAULT
	SetParalyzed(0)
/*
/mob/living/simple_animal/hostile/retaliate/rogue/arcane/noc_guard/Life()
	..()
	if(!summoned_target && allowed_to_die)
		say("T A S K: C O M P L E T E", spans = list(SPAN_MACHINA))
		sleep(20)
		death()
*/
/obj/effect/proc_holder/spell/invoked/noc_guard_attack
	name = "Guard Deconstruct"
	overlay_state = "transfix"
	range = 7
	invocation = "Claustritumi, Destruere!"
	invocation_type = "shout"
	associated_skill = /datum/skill/magic/arcane

/obj/effect/proc_holder/spell/invoked/noc_guard_attack/cast(list/targets, mob/living/user)
	. = ..()
	var/mob/living/carbon/human/invoker = user
	if(isliving(targets[1]))
		var/mob/living/target = targets[1]
		for(var/mob/living/simple_animal/hostile/retaliate/rogue/arcane/noc_guard/guard in invoker.summons_under)
			guard.Retaliate()
			guard.GiveTarget(target)
			guard.say("S T A T U S: E N G A G E D", spans = list(SPAN_MACHINA))

/obj/effect/proc_holder/spell/invoked/noc_guard_relocate
	name = "Guard Relocate"
	overlay_state = "hierophant"
	range = 7
	invocation = "Claustritumi, Movereadme!"
	invocation_type = "shout"
	associated_skill = /datum/skill/magic/arcane

/obj/effect/proc_holder/spell/invoked/noc_guard_relocate/cast(list/targets, mob/living/user)
	. = ..()
	var/mob/living/carbon/human/invoker = user
	if(isopenturf(targets[1]))
		var/turf/target = targets[1]
		for(var/mob/living/simple_animal/hostile/retaliate/rogue/arcane/noc_guard/guard in invoker.summons_under)
			guard.forceMove(target)
			playsound(target, 'modular_azurepeak/sound/spellbooks/crystal.ogg', 75)
			guard.say("R E L O C A T I N G", spans = list(SPAN_MACHINA))

/obj/effect/proc_holder/spell/invoked/noc_guard_pacify
	name = "Guard Pacify"
	overlay_state = "bliss"
	range = 7
	invocation = "Claustritumi, Cessare!"
	invocation_type = "shout"
	associated_skill = /datum/skill/magic/arcane

/obj/effect/proc_holder/spell/invoked/noc_guard_pacify/cast(list/targets, mob/living/user)
	. = ..()
	var/mob/living/carbon/human/invoker = user
	if(isliving(targets[1]))
		var/mob/living/simple_animal/hostile/retaliate/rogue/target = targets[1]
		if(istype(target, /mob/living/simple_animal/hostile/retaliate/rogue/arcane/noc_guard))
			if(target in invoker.summons_under)
				target.enemies = list()
				target.LoseTarget()
				target.say("S T A T U S: D I S E N G A G E D", spans = list(SPAN_MACHINA))
			else
				to_chat(user, "The apparition defies me, for I am not it's master!")
		else
			to_chat(user, "I can't control it!")
