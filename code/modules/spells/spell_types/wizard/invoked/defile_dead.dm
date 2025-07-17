/obj/effect/proc_holder/spell/invoked/defile_dead
	name = "Defile Dead"
	desc = "A forbidden, heretical spell that desecrates the dead, raising corpses as deadites. Shunned by the Ten and feared by the living."
	cost = 1
	releasedrain = 80
	overlay_state = "raiseskele"
	chargedrain = 0
	chargetime = 50
	recharge_time = 2 MINUTES
	warnie = "spellwarning"
	no_early_release = TRUE
	movement_interrupt = TRUE
	charging_slowdown = 3
	chargedloop = /datum/looping_sound/invokegen
	associated_skill = /datum/skill/magic/arcane
	gesture_required = FALSE
	spell_tier = 2 
	invocation = "Defile mortem!"
	invocation_type = "whisper"
	glow_color = "#7e2d7e" // purple/necromantic
	glow_intensity = GLOW_INTENSITY_HIGH

/obj/effect/proc_holder/spell/invoked/defile_dead/cast(list/targets, mob/user)
	. = ..()
	if(!length(targets))
		to_chat(user, span_warning("No target selected."))
		return FALSE
	var/target = targets[1]

	// Handle volf corpse
	if(istype(target, /obj/effect/decal/remains/wolf))
		var/obj/effect/decal/remains/wolf/W = target
		var/turf/T = get_turf(W)
		to_chat(user, span_warning("You feel a surge of necromantic power as the remains begin to twitch and convulse..."))
		sleep(3 SECONDS)
		to_chat(user, span_warning("The bones contort and crack with sickening sounds!"))
		sleep(3 SECONDS)
		to_chat(user, span_danger("The skull warps into a monstrous visage as it rises!"))
		sleep(3 SECONDS)
		to_chat(user, span_danger("The transformation is complete. The remains rise as a deadite volf!"))
		sleep(1 SECONDS)
		var/mob/living/simple_animal/hostile/retaliate/rogue/wolf_undead/N = new /mob/living/simple_animal/hostile/retaliate/rogue/wolf_undead(T)
		N.real_name = "Deadite Volf"
		QDEL_NULL(W)
		to_chat(user, span_danger("You raise a deadite volf!"))
		return TRUE

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
		// Player corpse: send transformation messages, then convert
		to_chat(user, span_warning("You feel a surge of necromantic power as the corpse begins to twitch and convulse..."))
		sleep(3 SECONDS)
		to_chat(user, span_warning("The corpse's limbs contort and bones crack with sickening sounds!"))
		sleep(3 SECONDS)
		to_chat(user, span_danger("The corpse's face warps into a monstrous visage as it rises!"))
		sleep(3 SECONDS)
		to_chat(user, span_danger("The transformation is complete. The corpse rises as a zombie!"))
		sleep(1 SECONDS)
		H.zombie_check_can_convert()
		var/datum/antagonist/zombie/Z = H.mind.has_antag_datum(/datum/antagonist/zombie)
		if(Z)
			Z.wake_zombie(TRUE)
			to_chat(user, span_danger("You raise [H] as a zombie!"))
			return TRUE
	else
		// No mind: send transformation messages, then spawn an NPC deadite and delete the corpse
		to_chat(user, span_warning("You feel a surge of necromantic power as the corpse begins to twitch and convulse..."))
		sleep(3 SECONDS)
		to_chat(user, span_warning("The corpse's limbs contort and bones crack with sickening sounds!"))
		sleep(3 SECONDS)
		to_chat(user, span_danger("The corpse's face warps into a monstrous visage as it rises!"))
		sleep(3 SECONDS)
		to_chat(user, span_danger("The transformation is complete. The corpse rises as a zombie!"))
		sleep(1 SECONDS)
		var/mob/living/carbon/human/species/npc/deadite/N = new /mob/living/carbon/human/species/npc/deadite(get_turf(H))
		N.real_name = "Defiled Corpse"
		N.update_body()
		QDEL_NULL(H)
		to_chat(user, span_danger("You raise a corpse as a zombie!"))
		return TRUE
	return FALSE 
