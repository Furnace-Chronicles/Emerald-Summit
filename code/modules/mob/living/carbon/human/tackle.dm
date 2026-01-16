/mob/living/carbon/human/proc/try_tackle(mob/living/carbon/target, datum/thrownthing/throwingdatum)
	if(!target || !iscarbon(target))
		return FALSE

	if(!Adjacent(target))
		return FALSE

	if(target == src)
		return FALSE

	if(stat || target.stat)
		return FALSE

	// Auto-fail if target is using defense intent (Guard active)
	if(target.has_status_effect(/datum/status_effect/buff/clash))
		Knockdown(30)
		Immobilize(2 SECONDS)
		drop_all_held_items()
		stamina_add(-20)
		visible_message(span_warning("[src] charges at [target], but is repelled by their guard!"), span_warning("I charge at [target] but am repelled by their guard!"))
		playsound(get_turf(src), "bodyfall", 100, TRUE)
		return FALSE

	var/tackle_dir = get_dir(src, target)
	var/target_dir = target.dir

	var/direction_bonus = 0
	var/angle_diff = abs(dir2angle(tackle_dir) - dir2angle(target_dir))
	if(angle_diff > 180)
		angle_diff = 360 - angle_diff

	if(angle_diff <= 45)
		direction_bonus = 50 // Huge bonus for tackling from the rear
	else if(angle_diff <= 135)
		direction_bonus = 10 // Very minor bonus for side taklces
	else if(target.cmode)
		direction_bonus = -50 // Huge penalty when tackling head-on against someone in combat mode
	else
		direction_bonus = -25 // Smaller penalty if they're facing you but not combat ready

	var/tackler_wrestling = 0
	var/target_wrestling = 0
	if(mind)
		tackler_wrestling = get_skill_level(/datum/skill/combat/wrestling)
	if(target.mind)
		target_wrestling = target.get_skill_level(/datum/skill/combat/wrestling)

	var/tackler_armor_weight = highest_ac_worn()
	var/target_armor_weight = ishuman(target) ? target:highest_ac_worn() : 0
	var/tackler_is_lighter = target_armor_weight > tackler_armor_weight
	var/armor_bonus = tackler_is_lighter ? ((target_armor_weight - tackler_armor_weight) * 5) : ((tackler_armor_weight - target_armor_weight) * 5)

	var/tackle_chance = 50 + direction_bonus // Becomes 0 if tackling someone in combat mode from the front
	tackle_chance += (STASTR - target.STASTR) * 3
	tackle_chance += (STACON - target.STACON) * 3
	tackle_chance += (tackler_wrestling - target_wrestling) * 8
	tackle_chance = tackler_is_lighter ? tackle_chance + armor_bonus : tackle_chance - armor_bonus
	tackle_chance = clamp(tackle_chance, 5, 95)

	if(client?.prefs.showrolls)
		to_chat(src, span_info("Tackle chance: [tackle_chance]%!"))

	visible_message(span_danger("[src] charges at [target]!"), span_danger("I charge at [target]!"))

	if(!prob(tackle_chance))
		Knockdown(30)
		Immobilize(2 SECONDS)
		drop_all_held_items()
		stamina_add(-20)
		visible_message(span_warning("[src] fails to tackle [target] and falls!"), span_warning("I fail to tackle [target] and fall!"))
		playsound(get_turf(src), "bodyfall", 100, TRUE)
		return FALSE

	var/turf/target_turf = get_turf(target)

	is_jumping = FALSE
	throwing = null
	forceMove(target_turf)

	target.Knockdown(30)
	Knockdown(30)

	var/resist_chance = 50
	resist_chance += (target.STASTR - STASTR) * 3
	resist_chance += (target.STACON - STACON) * 3
	resist_chance += (target_wrestling - tackler_wrestling) * 8
	resist_chance = tackler_is_lighter ? resist_chance - armor_bonus : resist_chance + armor_bonus
	resist_chance = clamp(resist_chance, 5, 95)

	if(target.client?.prefs.showrolls)
		to_chat(target, span_info("Tackle resistance chance: [resist_chance]%!"))

	if(prob(resist_chance))
		visible_message(span_boldwarning("[src] tackles [target] to the ground, but [target] resists the grapple!"), span_boldwarning("I tackle [target] to the ground, but they resist my grapple!"))
		playsound(get_turf(src), "punch_hard", 100, TRUE)
		playsound(get_turf(src), "bodyfall", 100, TRUE)
	else
		target.Stun(15)
		target.drop_all_held_items()

		visible_message(span_boldwarning("[src] tackles [target] to the ground!"), span_boldwarning("I tackle [target] to the ground!"))
		playsound(get_turf(src), "punch_hard", 100, TRUE)
		playsound(get_turf(src), "bodyfall", 100, TRUE)

		spawn(1)
			tackle_grapple_check(target)

	return TRUE

/mob/living/carbon/human/proc/tackle_grapple_check(mob/living/carbon/human/target)
	if(!target || QDELETED(target))
		return

	if(!target.grabbedby(src, TRUE))
		return

	target.grippedby(src, TRUE)
