/datum/sex_action/tailmawuse
	name = "Fuck their tailmaw with your cock"
	check_same_tile = FALSE
	stamina_cost = 1.0
	category = SEX_CATEGORY_PENETRATE
	user_sex_part = SEX_PART_COCK

/datum/sex_action/tailmawuse/shows_on_menu(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user == target)
		return FALSE
	if(!user.getorganslot(ORGAN_SLOT_PENIS))
		return FALSE
	var/obj/item/organ/tail = target.getorganslot(ORGAN_SLOT_TAIL)
	if(!tail)
		return FALSE
	if(!tail.accessory_type:can_suck)
		return FALSE
	return TRUE

/datum/sex_action/tailmawuse/can_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user == target)
		return FALSE
	if(!check_location_accessible(user, user, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(!user.sexcon.can_use_penis())
		return FALSE
	var/obj/item/organ/tail = target.getorganslot(ORGAN_SLOT_TAIL)
	if(!tail)
		return FALSE
	if(!tail.accessory_type:can_suck)
		return FALSE
	return TRUE

/datum/sex_action/tailmawuse/on_start(mob/living/carbon/human/user, mob/living/carbon/human/target)
	user.visible_message(span_warning("[user] grabs [target]'s tail, and slides [user.p_their()] cock inside!"))
	playsound(target, list('sound/misc/mat/insert (1).ogg','sound/misc/mat/insert (2).ogg'), 20, TRUE, ignore_walls = FALSE)

/datum/sex_action/tailmawuse/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	user.visible_message(user.sexcon.spanify_force("[user] [user.sexcon.get_generic_force_adjective()] fucks [target]'s tailmaw."))
	playsound(target, 'sound/misc/mat/segso.ogg', 50, TRUE, -2, ignore_walls = FALSE)
	if(prob(50))
		user.make_sucking_noise()
	user.sexcon.do_thrust_animate(target)

	user.sexcon.perform_sex_action(user, 2, 0, TRUE)
	if(user.sexcon.check_active_ejaculation())
		user.visible_message(span_love("[user] cums into [target]'s tailmaw!"))
		user.sexcon.cum_into(oral = TRUE, splashed_user = target)
		user.virginity = FALSE
		target.virginity = FALSE

	user.sexcon.perform_sex_action(target, 2.4, 7, FALSE)
	target.sexcon.handle_passive_ejaculation()

/datum/sex_action/tailmawuse/on_finish(mob/living/carbon/human/user, mob/living/carbon/human/target)
	user.visible_message(span_warning("[user] pulls [user.p_their()] cock out of [target]'s tailmaw."))

/datum/sex_action/tailmawuse/is_finished(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user.sexcon.finished_check())
		return TRUE
	return FALSE

/datum/sex_action/tailmawblowjob
	name = "Suck on their cock with your tailmaw"
	check_same_tile = FALSE
	target_sex_part = SEX_PART_COCK

/datum/sex_action/tailmawblowjob/shows_on_menu(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(!target.getorganslot(ORGAN_SLOT_PENIS))
		return FALSE
	var/obj/item/organ/tail = user.getorganslot(ORGAN_SLOT_TAIL)
	if(!tail)
		return FALSE 
	if(!tail.accessory_type:can_suck)// Only show if user has a tail that can suck! check the new var.
		return FALSE
	return TRUE

/datum/sex_action/tailmawblowjob/can_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(!target.getorganslot(ORGAN_SLOT_PENIS))
		return FALSE
	var/obj/item/organ/tail = user.getorganslot(ORGAN_SLOT_TAIL)
	if(!tail)
		return FALSE
	if(!tail.accessory_type:can_suck)
		return FALSE
	return TRUE

/datum/sex_action/tailmawblowjob/on_start(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user == target)
		user.visible_message(span_warning("[user] moves their tail into place and begins to envelop their own cock..."))
	else
		user.visible_message(span_warning("[user] moves their tail into place and begins to envelop [target]'s cock..."))
	playsound(user, list('sound/misc/mat/insert (1).ogg','sound/misc/mat/insert (2).ogg'), 20, TRUE, ignore_walls = FALSE)

/datum/sex_action/tailmawblowjob/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/verb = pick("sucks","slurps","suckles","engulfs","twists around","massages")
	if(user == target)
		user.visible_message(user.sexcon.spanify_force("[user] [user.sexcon.get_generic_force_adjective()] [verb] their own cock with their tailmaw."))
	else
		user.visible_message(user.sexcon.spanify_force("[user] [user.sexcon.get_generic_force_adjective()] [verb] [target]'s cock with their tailmaw."))
	playsound(user, 'sound/misc/mat/segso.ogg', 30, TRUE, -2, ignore_walls = FALSE)
	if(prob(50))
		user.make_sucking_noise()

	user.sexcon.perform_sex_action(target, 2, 0, TRUE)

	target.sexcon.handle_passive_ejaculation(user)
	if(target.sexcon.check_active_ejaculation())
		target.visible_message(span_love("[target] ejaculates into [user]'s tailmaw!"))
		target.sexcon.cum_into(oral = TRUE, splashed_user = user)

/datum/sex_action/tailmawblowjob/on_finish(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user == target)
		user.visible_message(span_warning("[user] releases their own cock from their tailmaw."))
	else
		user.visible_message(span_warning("[user] releases [target]'s cock from their tailmaw."))

/datum/sex_action/tailmawblowjob/is_finished(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(target.sexcon.finished_check())
		return TRUE
	return FALSE


/datum/sex_action/tailmawcunnilingus
	name = "Suck their cunt with your tailmaw"
	check_same_tile = FALSE
	target_sex_part = SEX_PART_CUNT

/datum/sex_action/tailmawcunnilingus/shows_on_menu(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user == target)
		return FALSE
	if(!target.getorganslot(ORGAN_SLOT_VAGINA))
		return FALSE
	var/obj/item/organ/tail = user.getorganslot(ORGAN_SLOT_TAIL)
	if(!tail)
		return FALSE
	if(!tail.accessory_type:can_suck) // Only show if user has a tail that can suck! check the new var.
		return FALSE
	return TRUE

/datum/sex_action/tailmawcunnilingus/can_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user == target)
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_GROIN, TRUE))
		return FALSE
	if(!target.getorganslot(ORGAN_SLOT_VAGINA))
		return FALSE
	var/obj/item/organ/tail = user.getorganslot(ORGAN_SLOT_TAIL)
	if(!tail)
		return FALSE
	if(!tail.accessory_type:can_suck)
		return FALSE
	return TRUE

/datum/sex_action/tailmawcunnilingus/on_start(mob/living/carbon/human/user, mob/living/carbon/human/target)
	user.visible_message(span_warning("[user]'s tail moves into place and opens, beginning to envelop [target]'s groin..."))

/datum/sex_action/tailmawcunnilingus/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/verb = pick("sucks","slurps","suckles","engulfs","licks","teases")
	user.visible_message(user.sexcon.spanify_force("[user] [user.sexcon.get_generic_force_adjective()] [verb] [target]'s pussy with their tailmaw..."))
	user.make_sucking_noise()
	user.sexcon.do_thrust_animate(target)

	user.sexcon.perform_sex_action(target, 2, 3, TRUE)
	if(target.sexcon.check_active_ejaculation())
		target.visible_message(span_love("[target] ejaculates into [user]'s tailmaw!"))
		target.sexcon.cum_into(oral = TRUE, splashed_user = user)

/datum/sex_action/tailmawcunnilingus/on_finish(mob/living/carbon/human/user, mob/living/carbon/human/target)
	user.visible_message(span_warning("[user] withdraws their tail and releases [target]'s pussy..."))

/datum/sex_action/tailmawcunnilingus/is_finished(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(target.sexcon.finished_check())
		return TRUE
	return FALSE

/datum/sex_action/tailmawbreastsuckle
	name = "Suck their breasts with your tailmaw"
	check_same_tile = FALSE

/datum/sex_action/tailmawbreastsuckle/shows_on_menu(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user == target)
		return FALSE
	if(!target.getorganslot(ORGAN_SLOT_BREASTS))
		return FALSE
	var/obj/item/organ/tail = user.getorganslot(ORGAN_SLOT_TAIL)
	if(!tail)
		return FALSE
	if(!tail.accessory_type:can_suck)
		return FALSE
	return TRUE

/datum/sex_action/tailmawbreastsuckle/can_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user == target)
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_CHEST, TRUE))
		return FALSE
	if(!target.getorganslot(ORGAN_SLOT_BREASTS))
		return FALSE
	var/obj/item/organ/tail = user.getorganslot(ORGAN_SLOT_TAIL)
	if(!tail)
		return FALSE
	if(!tail.accessory_type:can_suck)
		return FALSE
	return TRUE

/datum/sex_action/tailmawbreastsuckle/on_start(mob/living/carbon/human/user, mob/living/carbon/human/target)
	user.visible_message(span_warning("[user] opens their tailmaw, raising and pressing it around one of [target]'s breast..."))

/datum/sex_action/tailmawbreastsuckle/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/verb = pick("sucks","slurps","suckles","engulfs","licks","teases","squeezes","massages")
	user.visible_message(user.sexcon.spanify_force("[user] [user.sexcon.get_generic_force_adjective()] [verb] [target]'s breasts with their tailmaw..."))
	if(prob(50))
		user.make_sucking_noise()
	user.sexcon.do_thrust_animate(target)

	user.sexcon.perform_sex_action(target, 2, 2, TRUE)

/datum/sex_action/tailmawbreastsuckle/on_finish(mob/living/carbon/human/user, mob/living/carbon/human/target)
	user.visible_message(span_warning("[user] pulls away, and releases [target]'s breasts..."))

/datum/sex_action/tailmawbreastsuckle/is_finished(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(target.sexcon.finished_check())
		return TRUE
	return FALSE
