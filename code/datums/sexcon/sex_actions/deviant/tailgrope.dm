/datum/sex_action/tailgrope
	name = "Grope them with your tail"
	check_same_tile = FALSE

/datum/sex_action/tailgrope/shows_on_menu(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user == target)
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_TAIL) && !islamia(user))
		return FALSE
	return TRUE

/datum/sex_action/tailgrope/can_perform(mob/living/user, mob/living/carbon/human/target)
	if(user == target)
		return FALSE
	if(!user.Adjacent(target))
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_TAIL) && !islamia(user))
		return FALSE
	return TRUE

/datum/sex_action/tailgrope/on_start(mob/living/carbon/human/user, mob/living/carbon/human/target)
	user.visible_message(span_warning("[user] edges closer and reaches toward [target] with their tail..."), vision_distance = 1)
	user.sexcon.show_progress = 0

/datum/sex_action/tailgrope/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/do_subtle
	var/zone_text
	if(user.sexcon.force < SEX_FORCE_MID && user.sexcon.speed < SEX_SPEED_MID) // always subtle
		do_subtle = 1
	else if(user.sexcon.force < SEX_FORCE_EXTREME && user.sexcon.speed < SEX_SPEED_EXTREME)
		do_subtle = !prob(user.sexcon.force > SEX_FORCE_MID ? 4 : 2)
	else
		do_subtle = 0 // louder
	zone_text = lowertext(parse_zone(user.zone_selected))

	user.sexcon.show_progress = !do_subtle
	
	// if they have boobs, uses diff. message!
	var/perform_message
	var/action_verb
	if(user.zone_selected == BODY_ZONE_CHEST && target.getorganslot(ORGAN_SLOT_BREASTS))
		action_verb = pick("gropes","fondles","caresses","squeezes","massages","slithers inbetween","slithers over")
		zone_text = "breasts"
	else
		action_verb = pick("strokes","fondles","caresses")
	perform_message = "[user] [do_subtle ? pick("subtly","gently","carefully") : user.sexcon.get_generic_force_adjective()] [action_verb] [target]'s [zone_text] with their tail..."
	
	user.visible_message(user.sexcon.spanify_force(perform_message), vision_distance = (do_subtle ? 1 : DEFAULT_MESSAGE_RANGE))

	if(!do_subtle)
		if(user.sexcon.force > SEX_FORCE_HIGH)
			playsound(target, 'sound/misc/mat/fingering.ogg', 35, TRUE, -2, ignore_walls = FALSE)
		else
			user.make_sucking_noise()
		user.sexcon.do_thrust_animate(target)

	user.sexcon.perform_sex_action(user, 0.5, 0.2, TRUE)
	user.sexcon.handle_passive_ejaculation()

	user.sexcon.perform_sex_action(target, 1, 0.5, TRUE)
	target.sexcon.handle_passive_ejaculation()

/datum/sex_action/tailgrope/on_finish(mob/living/carbon/human/user, mob/living/carbon/human/target)
	user.visible_message(span_warning("[user] releases [target] and withdraws their tail..."), vision_distance = 1)

/datum/sex_action/tailgrope/is_finished(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(target.sexcon.finished_check())
		return TRUE
	return FALSE
