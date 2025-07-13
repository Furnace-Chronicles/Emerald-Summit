/obj/effect/proc_holder/spell/invoked/defile_dead
	name = "Defile Dead"
	desc = "A forbidden, heretical spell that desecrates the dead, raising corpses as zombies bound to your will. Shunned by all decent faiths and feared by the living."
	cost = 1
	releasedrain = 80
	overlay_state = "eyebite"
	chargedrain = 4
	chargetime = 3 SECONDS
	recharge_time = 2 MINUTES
	warnie = "spellwarning"
	no_early_release = TRUE
	movement_interrupt = FALSE
	charging_slowdown = 3
	chargedloop = /datum/looping_sound/invokegen
	associated_skill = /datum/skill/magic/arcane
	gesture_required = FALSE
	spell_tier = 1 
	invocation = "Defile mortem!"
	invocation_type = "shout"
	glow_color = "#7e2d7e" // purple/necromantic
	glow_intensity = GLOW_INTENSITY_HIGH
	var/aoe_range = 7

/obj/effect/proc_holder/spell/invoked/defile_dead/cast(list/targets, mob/user)
	. = ..()
	var/raised = 0
	for(var/target in targets)
		if(!isliving(target))
			continue
		var/mob/living/carbon/human/H = target
		if(!istype(H))
			continue
		if(H.stat < DEAD || QDELETED(H))
			to_chat(user, span_warning("[H] is not a corpse! The spell fizzles."))
			continue
		if(H.mind)
			H.zombie_check_can_convert()
			var/datum/antagonist/zombie/Z = H.mind.has_antag_datum(/datum/antagonist/zombie)
			if(Z)
				Z.wake_zombie(TRUE)
				raised++
		else
			// No mind: send transformation messages, then spawn an NPC deadite and delete the corpse
			user.visible_message(span_warning("[H]'s corpse begins to twitch and convulse..."), span_warning("You feel a surge of necromantic power as the corpse begins to twitch and convulse..."))
			sleep(5)
			user.visible_message(span_warning("[H]'s body twists and distorts, bones cracking unnaturally!"), span_warning("The corpse's limbs contort and bones crack with sickening sounds!"))
			sleep(5)
			user.visible_message(span_danger("[H]'s face warps into a monstrous visage as it rises!"), span_danger("The corpse's face warps into a monstrous visage as it rises!"))
			var/mob/living/carbon/human/species/npc/deadite/N = new /mob/living/carbon/human/species/npc/deadite(get_turf(H))
			N.real_name = "Defiled Corpse"
			N.update_body()
			QDEL_NULL(H)
			raised++
	if(raised)
		var/suffix = (raised == 1) ? "" : "s"
		user.visible_message(span_danger("[user] raises [raised] corpse[suffix] as zombie[suffix]!"), span_danger("You raise [raised] corpse[suffix] as zombie[suffix]!"))
	else
		to_chat(user, span_warning("No corpses were found to defile."))
	return TRUE 
