/mob/living/carbon/human/proc/try_tackle(mob/living/carbon/target)
	if(!target || !iscarbon(target))
		return FALSE

	if(!Adjacent(target))
		return FALSE

	if(target == src)
		return FALSE

	if(stat || target.stat)
		return FALSE

	var/tackle_dir = get_dir(src, target)
	var/target_dir = target.dir

	var/direction_bonus = 0
	var/angle_diff = abs(dir2angle(tackle_dir) - dir2angle(target_dir))
	if(angle_diff > 180)
		angle_diff = 360 - angle_diff

	if(angle_diff <= 45)
		direction_bonus = 50
	else if(angle_diff <= 135)
		direction_bonus = 25

	var/tackler_wrestling = 0
	var/target_wrestling = 0
	if(mind)
		tackler_wrestling = get_skill_level(/datum/skill/combat/wrestling)
	if(target.mind)
		target_wrestling = target.get_skill_level(/datum/skill/combat/wrestling)

	var/tackler_armor_weight = highest_ac_worn()
	var/target_armor_weight = ishuman(target) ? target:highest_ac_worn() : 0
	var/armor_bonus = (tackler_armor_weight - target_armor_weight) * 5

	var/tackle_chance = 50 + direction_bonus
	tackle_chance += (STASTR - target.STASTR) * 3
	tackle_chance += (STACON - target.STACON) * 3
	tackle_chance += (tackler_wrestling - target_wrestling) * 8
	tackle_chance += armor_bonus
	tackle_chance = clamp(tackle_chance, 5, 99)

	if(client?.prefs.showrolls)
		to_chat(src, span_info("Tackle chance: [tackle_chance]%"))

	visible_message(span_danger("[src] charges at [target]!"), span_danger("I charge at [target]!"))

	if(!prob(tackle_chance))
		Knockdown(30)
		Immobilize(2 SECONDS)
		stamina_add(-20)
		visible_message(span_warning("[src] fails to tackle [target] and falls!"), span_warning("I fail to tackle [target] and fall!"))
		playsound(get_turf(src), "bodyfall", 100, TRUE)
		return FALSE

	var/turf/target_turf = get_turf(target)
	if(target_turf && target_turf != get_turf(src))
		forceMove(target_turf)

	target.Knockdown(30)
	Knockdown(30)

	target.drop_all_held_items()
	drop_all_held_items()

	visible_message(span_boldwarning("[src] tackles [target] to the ground!"), span_boldwarning("I tackle [target] to the ground!"))
	playsound(get_turf(src), "punch_hard", 100, TRUE)
	playsound(get_turf(src), "bodyfall", 100, TRUE)

	target.grabbedby(src, supress_message = TRUE)

	spawn(1)
		tackle_grapple_check(target)

	return TRUE

/mob/living/carbon/human/proc/tackle_grapple_check(mob/living/carbon/human/target)
	if(!target || QDELETED(target))
		return

	if(!pulling || pulling != target)
		return

	var/obj/item/grabbing/G
	if(active_hand_index == 1 && r_grab)
		G = r_grab
	else if(active_hand_index == 2 && l_grab)
		G = l_grab

	if(!G || G.grabbed != target)
		return

	target.grippedby(src, instant = FALSE)
