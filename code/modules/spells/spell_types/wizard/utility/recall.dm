/obj/effect/proc_holder/spell/self/recall
	name = "Recall"
	desc = "Memorize your current location, allowing you to return to it after a delay."
	school = "transmutation"
	charge_type = "recharge"
	recharge_time = 3 MINUTES
	clothes_req = FALSE
	cost = 4
	spell_tier = 2
	cooldown_min = 3 MINUTES
	associated_skill = /datum/skill/magic/arcane
	xp_gain = TRUE
	invocation = ""
	invocation_type = "whisper"
	action_icon_state = "spell0"

	var/turf/marked_location = null
	var/recall_delay = 15 SECONDS
	var/casted_with_eyes_open = FALSE

/obj/effect/proc_holder/spell/self/recall/cast(mob/user = usr)
	if(!istype(user, /mob/living/carbon/human))
		return

	var/mob/living/carbon/human/H = user

	// First cast - mark the location
	if(!marked_location)
		var/turf/T = get_turf(H)
		marked_location = T
		to_chat(H, span_notice("You attune yourself to this location. Future casts will return you here."))
		start_recharge()
		revert_cast()
		return TRUE

	// Subsequent casts - begin channeling
	H.visible_message(span_warning("[H] closes [H.p_their()] eyes and begins to focus intently..."))
	H.apply_status_effect(/datum/status_effect/buff/recalling)
	// Actually close their eyes
	casted_with_eyes_open = H.eyesclosed == 0
	if (casted_with_eyes_open)
		H.eyesclosed = 1
		H.become_blind("eyelids")
		H.toggle_eye_intent(H)
	if(do_after(H, recall_delay, target = H, progress = TRUE, extra_checks = CALLBACK(src, PROC_REF(eyes_check), H)))
		// Get any grabbed mobs
		var/list/to_teleport = list(H)
		if(H.pulling && isliving(H.pulling))
			to_teleport += H.pulling

		// Teleport caster and grabbed mob if any
		for(var/mob/living/L in to_teleport)
			do_teleport(L, marked_location, no_effects = FALSE, channel = TELEPORT_CHANNEL_MAGIC)

		H.visible_message(span_warning("[H] vanishes in a swirl of energy!"))
		playsound(H, 'sound/magic/unmagnet.ogg', 50, TRUE)

		// Visual effects at both locations
		var/datum/effect_system/smoke_spread/smoke = new
		smoke.set_up(3, marked_location)
		smoke.start()
		H.remove_status_effect(/datum/status_effect/buff/recalling)
		start_recharge()
	else
		H.remove_status_effect(/datum/status_effect/buff/recalling)
		to_chat(H, span_warning("Your concentration was broken!"))
		start_recharge()
		revert_cast()
	if(casted_with_eyes_open) // if we started to cast with them open, open our eyes
		H.eyesclosed = 0
		H.cure_blind("eyelids")
		H.toggle_eye_intent(H)

/obj/effect/proc_holder/spell/self/recall/proc/eyes_check(mob/living/carbon/human/H) //for the do_after, this checks if the user opened their eyes during the recall
	if(!H.eyesclosed) // user opened their eyes, abort
		casted_with_eyes_open = FALSE // don't bother reopening their eyes
		return FALSE
	return TRUE
