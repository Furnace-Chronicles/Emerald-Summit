/datum/sex_action/double_penetration_sex
	name = "Fuck both their holes"
	stamina_cost = 1.0

/datum/sex_action/double_penetration_sex/shows_on_menu(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user == target)
		return FALSE
	if(!target.getorganslot(ORGAN_SLOT_VAGINA))
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_PENIS))
		return FALSE
	return TRUE

/datum/sex_action/double_penetration_sex/can_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user == target)
		return FALSE
	if(!check_location_accessible(user, user, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(!target.getorganslot(ORGAN_SLOT_VAGINA))
		return FALSE
	var/obj/item/organ/penis/penis = user.getorganslot(ORGAN_SLOT_PENIS)
	if(!penis)
		return FALSE
	if(penis.penis_type != PENIS_TYPE_TAPERED_DOUBLE && penis.penis_type != PENIS_TYPE_TAPERED_DOUBLE_KNOTTED)
		return FALSE
	if(!user.sexcon.can_use_penis())
		return
	return TRUE

/datum/sex_action/double_penetration_sex/on_start(mob/living/carbon/human/user, mob/living/carbon/human/target)
	user.visible_message(span_warning("[user] slides [user.p_their()] cocks into [target]'s holes!"))
	playsound(target, list('sound/misc/mat/insert (1).ogg','sound/misc/mat/insert (2).ogg'), 20, TRUE, ignore_walls = FALSE)

/datum/sex_action/double_penetration_sex/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	user.visible_message(user.sexcon.spanify_force("[user] [user.sexcon.get_generic_force_adjective()] fucks [target]'s holes together."))
	playsound(target, 'sound/misc/mat/segso.ogg', 50, TRUE, -2, ignore_walls = FALSE)
	do_thrust_animate(user, target)

	user.sexcon.perform_sex_action(user, 3, 0, TRUE)
	if(user.sexcon.check_active_ejaculation())
		user.visible_message(span_love("[user] cums into [target]'s holes at the same time!"))
		user.sexcon.cum_into(splashed_user = target)
		user.try_impregnate(target)
		user.virginity = FALSE
		target.virginity = FALSE

	if(user.sexcon.considered_limp())
		user.sexcon.perform_sex_action(target, 1.4, 4, FALSE)
	else
		user.sexcon.perform_sex_action(target, 2.7, 9, FALSE)
	target.sexcon.handle_passive_ejaculation()

/datum/sex_action/double_penetration_sex/on_finish(mob/living/carbon/human/user, mob/living/carbon/human/target)
	user.visible_message(span_warning("[user] pulls [user.p_their()] twin cocks out of [target]'s holes."))

/datum/sex_action/double_penetration_sex/is_finished(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user.sexcon.finished_check())
		return TRUE
	return FALSE

/datum/sex_action/double_penetration_sex/knot
	name = "Knot both their holes"
	knot_on_finish = TRUE

/datum/sex_action/double_penetration_sex/knot/shows_on_menu(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(!user.sexcon.knot_penis_type(TRUE))
		return FALSE
	return ..()

/datum/sex_action/double_penetration_sex/knot/can_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(!user.sexcon.knot_penis_type(TRUE))
		return FALSE
	return ..()

/datum/sex_action/double_penetration_sex/knot/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	user.visible_message(user.sexcon.spanify_force("[user] [user.sexcon.get_generic_force_adjective()] knot-fucks [target]'s holes together."))
	playsound(target, 'sound/misc/mat/segso.ogg', 50, TRUE, -2, ignore_walls = FALSE)
	do_thrust_animate(user, target)

	user.sexcon.perform_sex_action(user, 3, 0, TRUE)
	if(user.sexcon.check_active_ejaculation())
		user.visible_message(span_love("[user] cums into [target]'s holes at the same time!"))
		user.sexcon.cum_into(splashed_user = target)
		user.try_impregnate(target)
		user.virginity = FALSE
		target.virginity = FALSE

	if(user.sexcon.considered_limp())
		user.sexcon.perform_sex_action(target, 1.4, 4, FALSE)
	else
		user.sexcon.perform_sex_action(target, 2.7, 9*1.5, FALSE)
	target.sexcon.handle_passive_ejaculation()
