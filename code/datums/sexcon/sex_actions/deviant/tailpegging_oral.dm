/datum/sex_action/tailpegging_oral
	name = "Use tail on their mouth"
	stamina_cost = 1.0
	category = SEX_CATEGORY_PENETRATE
	target_sex_part = SEX_PART_JAWS

/datum/sex_action/tailpegging_oral/shows_on_menu(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user == target)
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_TAIL) && !islamia(user))
		return FALSE
	return TRUE

/datum/sex_action/tailpegging_oral/can_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user == target)
		return FALSE
	if(!user.Adjacent(target))
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_TAIL) && !islamia(user))
		return FALSE
	return TRUE

/datum/sex_action/tailpegging_oral/on_start(mob/living/carbon/human/user, mob/living/carbon/human/target)
	user.visible_message(span_warning("[user] presses their tail against [target]'s mouth!"))
	playsound(target, list('sound/misc/mat/insert (1).ogg','sound/misc/mat/insert (2).ogg'), 20, TRUE, ignore_walls = FALSE)

/datum/sex_action/tailpegging_oral/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	// gentle vs rough variants for lip/mouth force-based
	var/is_gentle = user.sexcon.force < SEX_FORCE_MID
	var/perform_message
	
	if(is_gentle)
		perform_message = "[user] [pick("caresses","strokes","teases")] [target]'s lips with their tail."
		playsound(target, 'sound/misc/mat/fingering.ogg', 30, TRUE, -2, ignore_walls = FALSE)
	else
		perform_message = "[user] [pick("fucks","violates")] [target]'s throat with their tail."
		playsound(target, 'sound/misc/mat/segso.ogg', 50, TRUE, -2, ignore_walls = FALSE)
		user.make_sucking_noise()
	
	user.visible_message(user.sexcon.spanify_force(perform_message))
	
	user.sexcon.do_thrust_animate(target)

	if(is_gentle)
		user.sexcon.perform_sex_action(target, 0.8, 2.3, TRUE)
	else
		user.sexcon.perform_sex_action(target, 2.4, 7, TRUE)
	user.sexcon.handle_passive_ejaculation()

/datum/sex_action/tailpegging_oral/on_finish(mob/living/carbon/human/user, mob/living/carbon/human/target)
	user.visible_message(span_warning("[user] pulls their tail away from [target]'s mouth."))

/datum/sex_action/tailpegging_oral/is_finished(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(target.sexcon.finished_check())
		return TRUE
	return FALSE
