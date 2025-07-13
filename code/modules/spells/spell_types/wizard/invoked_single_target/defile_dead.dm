/obj/effect/proc_holder/spell/invoked_single_target/defile_dead
	name = "Defile Dead"
	desc = "A forbidden, heretical spell that desecrates the dead, raising corpses as deadites. Shunned by the Ten and feared by the living."
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
	invocation_type = "whisper"
	glow_color = "#7e2d7e" // purple/necromantic
	glow_intensity = GLOW_INTENSITY_HIGH

/obj/effect/proc_holder/spell/invoked_single_target/defile_dead/cast(list/targets, mob/user)
	. = ..()
	if(!length(targets))
		to_chat(user, span_warning("No target selected."))
		return FALSE
	var/target = targets[1]
	if(!isliving(target))
		to_chat(user, span_warning("That is not a valid target! The spell fizzles."))
		return FALSE
	var/mob/living/carbon/human/H = target
	if(!istype(H))
		to_chat(user, span_warning("Only human corpses can be defiled! The spell fizzles."))
		return FALSE
	if(H.stat < DEAD || QDELETED(H))
		to_chat(user, span_warning("[H] is not a corpse! The spell fizzles."))
		return FALSE
	if(H.mind)
		H.zombie_check_can_convert()
		var/datum/antagonist/zombie/Z = H.mind.has_antag_datum(/datum/antagonist/zombie)
		if(Z)
			Z.wake_zombie(TRUE)
			user.visible_message(span_danger("[user] raises [H] as a zombie!"), span_danger("You raise [H] as a zombie!"))
			return TRUE
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
		user.visible_message(span_danger("[user] raises a corpse as a zombie!"), span_danger("You raise a corpse as a zombie!"))
		return TRUE
	return FALSE 
