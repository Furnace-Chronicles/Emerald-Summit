/obj/item/clothing
	name = "clothing"
	resistance_flags = FLAMMABLE
	obj_flags = CAN_BE_HIT | UNIQUE_RENAME
	break_sound = 'sound/foley/cloth_rip.ogg'
	blade_dulling = DULLING_CUT
	max_integrity = 200
	integrity_failure = 0.1
	drop_sound = 'sound/foley/dropsound/cloth_drop.ogg'
	///What level of bright light protection item has.
	var/flash_protect = FLASH_PROTECTION_NONE
	var/tint = 0				//Sets the item's level of visual impairment tint, normally set to the same as flash_protect
	var/up = 0					//but separated to allow items to protect but not impair vision, like space helmets
	var/visor_flags = 0			//flags that are added/removed when an item is adjusted up/down
	var/visor_flags_inv = 0		//same as visor_flags, but for flags_inv
	var/visor_flags_cover = 0	//same as above, but for flags_cover
//what to toggle when toggled with weldingvisortoggle()
	var/visor_vars_to_toggle = VISOR_FLASHPROTECT | VISOR_TINT | VISOR_VISIONFLAGS | VISOR_DARKNESSVIEW | VISOR_INVISVIEW
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'
	var/alt_desc = null
	var/toggle_message = null
	var/alt_toggle_message = null
	var/active_sound = null
	var/toggle_cooldown = null
	var/cooldown = 0

	var/emote_environment = -1
	var/list/prevent_crits

	var/clothing_flags = NONE

	salvage_result = /obj/item/natural/cloth
	salvage_amount = 2
	fiber_salvage = TRUE

	var/toggle_icon_state = TRUE //appends _t to our icon state when toggled

	//Var modification - PLEASE be careful with this I know who you are and where you live
	var/list/user_vars_to_edit //VARNAME = VARVALUE eg: "name" = "butts"
	var/list/user_vars_remembered //Auto built by the above + dropped() + equipped()

	var/pocket_storage_component_path

	//These allow head/mask items to dynamically alter the user's hair
	// and facial hair, checking hair_extensions.dmi and facialhair_extensions.dmi
	// for a state matching hair_state+dynamic_hair_suffix
	// THESE OVERRIDE THE HIDEHAIR FLAGS
	var/dynamic_hair_suffix = ""//head > mask for head hair
	var/dynamic_fhair_suffix = ""//mask > head for facial hair
	edelay_type = 0
	var/list/allowed_sex = list(MALE,FEMALE)
	var/list/allowed_race = CLOTHED_RACES_TYPES
	var/immune_to_genderswap = FALSE
	var/armor_class = ARMOR_CLASS_NONE
	var/integ_armor_mod = ARMOR_CLASS_NONE  // Used for blunt AP and armor degradation calculation when armor_class is ARMOR_CLASS_NONE

	sellprice = 1
	var/naledicolor = FALSE

	var/cansnout = FALSE //for masks - can we MMB this to change it into a snouty sprite?
	var/snouting = FALSE //do we have the snout-snug sprite toggled?

	// Per-zone durability tracking for armor pieces
	var/zone_integrity_chest
	var/zone_integrity_groin
	var/zone_integrity_l_arm
	var/zone_integrity_r_arm
	var/zone_integrity_l_leg
	var/zone_integrity_r_leg

	var/list/broken_zones

/obj/item
	var/blocking_behavior
	var/wetness = 0
	var/block2add
	var/detail_tag
	var/altdetail_tag
	var/detail_color
	var/altdetail_color
	var/boobed_detail = TRUE
	var/sleeved_detail = TRUE
	var/list/original_armor //For restoring broken armor
	var/shoddy_repair = FALSE // if we've been field repaired by an unskilled person, set this to true

/obj/item/clothing/New()
	..()
	if(armor_class)
		has_inspect_verb = TRUE
	initialize_zone_durability()

/obj/item/clothing/examine(mob/user)
	. = ..()
	if(torn_sleeve_number)
		if(torn_sleeve_number == 1)
			. += span_notice("It has one torn sleeve.")
		else
			. += span_notice("Both its sleeves have been torn!")

/// Helper proc to count covered body parts and calculate integrity multiplier
/obj/item/clothing/proc/get_coverage_integrity_mult()
	var/covered_parts = 0

	if(body_parts_covered & CHEST)
		covered_parts++
	if(body_parts_covered & GROIN)
		covered_parts++
	if(body_parts_covered & (ARM_LEFT | HAND_LEFT))
		covered_parts++
	if(body_parts_covered & (ARM_RIGHT | HAND_RIGHT))
		covered_parts++
	if(body_parts_covered & (LEG_LEFT | FOOT_LEFT))
		covered_parts++
	if(body_parts_covered & (LEG_RIGHT | FOOT_RIGHT))
		covered_parts++

	if(covered_parts == 0)
		return 1.0

	return covered_parts

/obj/item/clothing/proc/calculate_zone_integrity(zone)
	var/integrity_mult = get_coverage_integrity_mult()
	if(integrity_mult >= 3)
		integrity_mult *= 0.5
	else if(integrity_mult == 2)
		integrity_mult *= 0.75

	var/amount = round(max_integrity * (1 / integrity_mult), 10)

	if(zone)
		switch(zone)
			if(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
				if(!(slot_flags & (ITEM_SLOT_HANDS | ITEM_SLOT_WRISTS)))
					amount = round((max_integrity * (1 / integrity_mult)) * 0.75, 10)
			if(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
				if(!(slot_flags & (ITEM_SLOT_SHOES | ITEM_SLOT_PANTS)))
					amount = round((max_integrity * (1 / integrity_mult)) * 0.85, 10)
				
	return amount

/obj/item/clothing/proc/initialize_zone_durability()
	broken_zones = list()
	var/limb_coverage = body_parts_covered & (CHEST | GROIN | ARMS | LEGS | HANDS | FEET)
	if(!limb_coverage)
		return

	// Assign durability to each covered zone
	if(body_parts_covered & CHEST)
		zone_integrity_chest = calculate_zone_integrity()
	if(body_parts_covered & GROIN)
		zone_integrity_groin = calculate_zone_integrity()
	if(body_parts_covered & (ARM_LEFT | HAND_LEFT))
		zone_integrity_l_arm = calculate_zone_integrity(BODY_ZONE_L_ARM)
	if(body_parts_covered & (ARM_RIGHT | HAND_RIGHT))
		zone_integrity_r_arm = calculate_zone_integrity(BODY_ZONE_R_ARM)
	if(body_parts_covered & (LEG_LEFT | FOOT_LEFT))
		zone_integrity_l_leg = calculate_zone_integrity(BODY_ZONE_L_LEG)
	if(body_parts_covered & (LEG_RIGHT | FOOT_RIGHT))
		zone_integrity_r_leg = calculate_zone_integrity(BODY_ZONE_R_LEG)

/// Check if this clothing uses zone-specific integrity tracking at all
/obj/item/clothing/proc/uses_zone_integrity()
	return (zone_integrity_chest != null || zone_integrity_groin != null || \
	        zone_integrity_l_arm != null || zone_integrity_r_arm != null || \
	        zone_integrity_l_leg != null || zone_integrity_r_leg != null)

/// Check if this clothing has zone-specific integrity tracking for a given body zone
/obj/item/clothing/proc/has_zone_integrity(def_zone)
	switch(def_zone)
		if(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_STOMACH)
			return zone_integrity_chest != null
		if(BODY_ZONE_PRECISE_GROIN)
			return zone_integrity_groin != null
		if(BODY_ZONE_L_ARM, BODY_ZONE_PRECISE_L_HAND)
			return zone_integrity_l_arm != null
		if(BODY_ZONE_R_ARM, BODY_ZONE_PRECISE_R_HAND)
			return zone_integrity_r_arm != null
		if(BODY_ZONE_L_LEG, BODY_ZONE_PRECISE_L_FOOT)
			return zone_integrity_l_leg != null
		if(BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_R_FOOT)
			return zone_integrity_r_leg != null
	return FALSE

/// Modify zone integrity by a delta amount, clamping to [0, max]
/// Returns the new integrity value, or null if the zone doesn't exist
/obj/item/clothing/proc/modify_zone_integrity(def_zone, delta)
	if(!has_zone_integrity(def_zone))
		return null

	var/zone_max = get_zone_max_integrity(def_zone)

	switch(def_zone)
		if(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_STOMACH)
			zone_integrity_chest = clamp(zone_integrity_chest + delta, 0, zone_max)
			return zone_integrity_chest
		if(BODY_ZONE_PRECISE_GROIN)
			zone_integrity_groin = clamp(zone_integrity_groin + delta, 0, zone_max)
			return zone_integrity_groin
		if(BODY_ZONE_L_ARM, BODY_ZONE_PRECISE_L_HAND)
			zone_integrity_l_arm = clamp(zone_integrity_l_arm + delta, 0, zone_max)
			return zone_integrity_l_arm
		if(BODY_ZONE_R_ARM, BODY_ZONE_PRECISE_R_HAND)
			zone_integrity_r_arm = clamp(zone_integrity_r_arm + delta, 0, zone_max)
			return zone_integrity_r_arm
		if(BODY_ZONE_L_LEG, BODY_ZONE_PRECISE_L_FOOT)
			zone_integrity_l_leg = clamp(zone_integrity_l_leg + delta, 0, zone_max)
			return zone_integrity_l_leg
		if(BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_R_FOOT)
			zone_integrity_r_leg = clamp(zone_integrity_r_leg + delta, 0, zone_max)
			return zone_integrity_r_leg

	return null

/// Get a human-readable name for a body zone
/obj/item/clothing/proc/get_zone_name(def_zone)
	switch(def_zone)
		if(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_STOMACH)
			return "chest"
		if(BODY_ZONE_PRECISE_GROIN)
			return "groin"
		if(BODY_ZONE_L_ARM, BODY_ZONE_PRECISE_L_HAND)
			return "left arm"
		if(BODY_ZONE_R_ARM, BODY_ZONE_PRECISE_R_HAND)
			return "right arm"
		if(BODY_ZONE_L_LEG, BODY_ZONE_PRECISE_L_FOOT)
			return "left leg"
		if(BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_R_FOOT)
			return "right leg"
	return "unknown"

/// Get the current integrity for a specific body zone
/// Returns the zone-specific integrity if tracked, otherwise returns obj_integrity
/obj/item/clothing/proc/get_zone_integrity(def_zone)
	switch(def_zone)
		if(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_STOMACH)
			if(zone_integrity_chest != null)
				return zone_integrity_chest
		if(BODY_ZONE_PRECISE_GROIN)
			if(zone_integrity_groin != null)
				return zone_integrity_groin
		if(BODY_ZONE_L_ARM, BODY_ZONE_PRECISE_L_HAND)
			if(zone_integrity_l_arm != null)
				return zone_integrity_l_arm
		if(BODY_ZONE_R_ARM, BODY_ZONE_PRECISE_R_HAND)
			if(zone_integrity_r_arm != null)
				return zone_integrity_r_arm
		if(BODY_ZONE_L_LEG, BODY_ZONE_PRECISE_L_FOOT)
			if(zone_integrity_l_leg != null)
				return zone_integrity_l_leg
		if(BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_R_FOOT)
			if(zone_integrity_r_leg != null)
				return zone_integrity_r_leg
	return obj_integrity

/// Get the maximum integrity for a specific body zone
/// Returns the zone-specific max if tracked, otherwise returns max_integrity
/obj/item/clothing/proc/get_zone_max_integrity(def_zone)
	var/zone_max = calculate_zone_integrity(def_zone)

	switch(def_zone)
		if(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_STOMACH)
			if(zone_integrity_chest != null)
				return zone_max
		if(BODY_ZONE_PRECISE_GROIN)
			if(zone_integrity_groin != null)
				return zone_max
		if(BODY_ZONE_L_ARM, BODY_ZONE_PRECISE_L_HAND)
			if(zone_integrity_l_arm != null)
				return zone_max
		if(BODY_ZONE_R_ARM, BODY_ZONE_PRECISE_R_HAND)
			if(zone_integrity_r_arm != null)
				return zone_max
		if(BODY_ZONE_L_LEG, BODY_ZONE_PRECISE_L_FOOT)
			if(zone_integrity_l_leg != null)
				return zone_max
		if(BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_R_FOOT)
			if(zone_integrity_r_leg != null)
				return zone_max
	return max_integrity

/// Show armor damage notification based on integrity change
/obj/item/clothing/proc/show_damage_notification(old_integrity, new_integrity)
	var/eff_maxint = max_integrity - (max_integrity * integrity_failure)
	var/eff_currint_old = max(old_integrity - (max_integrity * integrity_failure), 0)
	var/eff_currint_new = max(new_integrity - (max_integrity * integrity_failure), 0)
	var/ratio = (eff_currint_old / eff_maxint)
	var/ratio_newinteg = (eff_currint_new / eff_maxint)
	var/text
	var/y_offset
	if(ratio > 0.75 && ratio_newinteg < 0.75)
		text = "Armor <br><font color = '#8aaa4d'>marred</font>"
		y_offset = -5
	if(ratio > 0.5 && ratio_newinteg < 0.5)
		text = "Armor <br><font color = '#d4d36c'>damaged</font>"
		y_offset = 15
	if(ratio > 0.25 && ratio_newinteg < 0.25)
		text = "Armor <br><font color = '#a8705a'>sundered</font>"
		y_offset = 30
	if(text)
		filtered_balloon_alert(TRAIT_COMBAT_AWARE, text, -20, y_offset)

/// Damage a specific body zone on this armor piece
/// Handles zone-specific damage and triggers all the normal take_damage effects
/obj/item/clothing/proc/damage_zone(def_zone, damage_amount, damage_type = BRUTE, damage_flag = "", sound_effect = TRUE)
	var/old_integrity = obj_integrity

	var/new_zone_int = modify_zone_integrity(def_zone, -damage_amount)
	if(new_zone_int != null && new_zone_int <= 0)
		var/canonical_zone = def_zone
		switch(def_zone)
			if(BODY_ZONE_PRECISE_STOMACH)
				canonical_zone = BODY_ZONE_CHEST
			if(BODY_ZONE_PRECISE_L_HAND)
				canonical_zone = BODY_ZONE_L_ARM
			if(BODY_ZONE_PRECISE_R_HAND)
				canonical_zone = BODY_ZONE_R_ARM
			if(BODY_ZONE_PRECISE_L_FOOT)
				canonical_zone = BODY_ZONE_L_LEG
			if(BODY_ZONE_PRECISE_R_FOOT)
				canonical_zone = BODY_ZONE_R_LEG
		
		broken_zones |= canonical_zone

	update_overall_integrity()
	show_damage_notification(old_integrity, obj_integrity)

/// Update the overall obj_integrity based on zone-specific durabilities
/// For torso armor (has chest zone), uses chest integrity for visual state
/// For other items (gloves, boots, pants), uses maximum of zones
/obj/item/clothing/proc/update_overall_integrity()
	if(zone_integrity_chest != null)
		obj_integrity = zone_integrity_chest
		return

	if(zone_integrity_groin != null)
		obj_integrity = zone_integrity_groin
		return

	var/max_integrity = 0

	if(zone_integrity_l_arm != null)
		max_integrity = max(max_integrity, zone_integrity_l_arm)
	if(zone_integrity_r_arm != null)
		max_integrity = max(max_integrity, zone_integrity_r_arm)
	if(zone_integrity_l_leg != null)
		max_integrity = max(max_integrity, zone_integrity_l_leg)
	if(zone_integrity_r_leg != null)
		max_integrity = max(max_integrity, zone_integrity_r_leg)

	obj_integrity = max_integrity

/// Copy zone-specific integrity from another clothing item
/// Used when transforming items (e.g., combining armor pieces)
/obj/item/clothing/proc/copy_zone_integrity(obj/item/clothing/source)
	if(!istype(source))
		return

	if(source.zone_integrity_chest != null && zone_integrity_chest != null)
		zone_integrity_chest = source.zone_integrity_chest
	if(source.zone_integrity_groin != null && zone_integrity_groin != null)
		zone_integrity_groin = source.zone_integrity_groin
	if(source.zone_integrity_l_arm != null && zone_integrity_l_arm != null)
		zone_integrity_l_arm = source.zone_integrity_l_arm
	if(source.zone_integrity_r_arm != null && zone_integrity_r_arm != null)
		zone_integrity_r_arm = source.zone_integrity_r_arm
	if(source.zone_integrity_l_leg != null && zone_integrity_l_leg != null)
		zone_integrity_l_leg = source.zone_integrity_l_leg
	if(source.zone_integrity_r_leg != null && zone_integrity_r_leg != null)
		zone_integrity_r_leg = source.zone_integrity_r_leg

	update_overall_integrity()

/// Override obj_fix for clothing to restore all zone integrities
/obj/item/clothing/obj_fix(mob/user)
	if(zone_integrity_chest != null)
		zone_integrity_chest = get_zone_max_integrity(BODY_ZONE_CHEST)
	if(zone_integrity_groin != null)
		zone_integrity_groin = get_zone_max_integrity(BODY_ZONE_PRECISE_GROIN)
	if(zone_integrity_l_arm != null)
		zone_integrity_l_arm = get_zone_max_integrity(BODY_ZONE_L_ARM)
	if(zone_integrity_r_arm != null)
		zone_integrity_r_arm = get_zone_max_integrity(BODY_ZONE_R_ARM)
	if(zone_integrity_l_leg != null)
		zone_integrity_l_leg = get_zone_max_integrity(BODY_ZONE_L_LEG)
	if(zone_integrity_r_leg != null)
		zone_integrity_r_leg = get_zone_max_integrity(BODY_ZONE_R_LEG)

	broken_zones.len = 0
	..()

	update_overall_integrity()

/obj/item/proc/get_detail_tag() //this is for extra layers on clothes
	return detail_tag

/obj/item/proc/get_altdetail_tag() //this is for extra layers on clothes
	return altdetail_tag

/obj/item/proc/get_detail_color() //this is for extra layers on clothes
	return detail_color

/obj/item/proc/get_altdetail_color() //this is for extra layers on clothes
	return altdetail_color

/obj/item/clothing/ShiftRightClick(mob/user, params)
	..()
	var/mob/living/L = user
	var/altheld //Is the user pressing alt?
	var/list/modifiers = params2list(params)
	if(modifiers["alt"])
		altheld = TRUE
	if(!isliving(user))
		return
	if(nodismemsleeves)
		return
	if(altheld)
		if(user.zone_selected == l_sleeve_zone)
			if(l_sleeve_status == SLEEVE_ROLLED)
				l_sleeve_status = SLEEVE_NORMAL
				if(l_sleeve_zone == BODY_ZONE_L_ARM)
					body_parts_covered |= ARM_LEFT
				if(l_sleeve_zone == BODY_ZONE_L_LEG)
					body_parts_covered |= LEG_LEFT
			else
				if(l_sleeve_zone == BODY_ZONE_L_ARM)
					body_parts_covered &= ~ARM_LEFT
				if(l_sleeve_zone == BODY_ZONE_L_LEG)
					body_parts_covered &= ~LEG_LEFT
				l_sleeve_status = SLEEVE_ROLLED
			return
		else if(user.zone_selected == r_sleeve_zone)
			if(r_sleeve_status == SLEEVE_ROLLED)
				if(r_sleeve_zone == BODY_ZONE_R_ARM)
					body_parts_covered |= ARM_RIGHT
				if(r_sleeve_zone == BODY_ZONE_R_LEG)
					body_parts_covered |= LEG_RIGHT
				r_sleeve_status = SLEEVE_NORMAL
			else
				if(r_sleeve_zone == BODY_ZONE_R_ARM)
					body_parts_covered &= ~ARM_RIGHT
				if(r_sleeve_zone == BODY_ZONE_R_LEG)
					body_parts_covered &= ~LEG_RIGHT
				r_sleeve_status = SLEEVE_ROLLED
			return
	else
		if(user.zone_selected == r_sleeve_zone)
			if(r_sleeve_status == SLEEVE_NOMOD)
				return
			if(r_sleeve_status == SLEEVE_TORN)
				to_chat(user, span_info("It's torn away."))
				return
			if(!do_after(user, 20, target = user))
				return
			if(prob(L.STASTR * 8))
				torn_sleeve_number += 1
				r_sleeve_status = SLEEVE_TORN
				user.visible_message(span_notice("[user] tears [src]."))
				playsound(src, 'sound/foley/cloth_rip.ogg', 50, TRUE)
				if(r_sleeve_zone == BODY_ZONE_R_ARM)
					body_parts_covered &= ~ARM_RIGHT
				if(r_sleeve_zone == BODY_ZONE_R_LEG)
					body_parts_covered &= ~LEG_RIGHT
				var/obj/item/Sr = new salvage_result(get_turf(src))
				Sr.color = color
				user.put_in_hands(Sr)
				return
			else
				user.visible_message(span_warning("[user] tries to tear [src]."))
				return
		if(user.zone_selected == l_sleeve_zone)
			if(l_sleeve_status == SLEEVE_NOMOD)
				return
			if(l_sleeve_status == SLEEVE_TORN)
				to_chat(user, span_info("It's torn away."))
				return
			if(!do_after(user, 20, target = user))
				return
			if(prob(L.STASTR * 8))
				torn_sleeve_number += 1
				l_sleeve_status = SLEEVE_TORN
				user.visible_message(span_notice("[user] tears [src]."))
				playsound(src, 'sound/foley/cloth_rip.ogg', 50, TRUE)
				if(l_sleeve_zone == BODY_ZONE_L_ARM)
					body_parts_covered &= ~ARM_LEFT
				if(l_sleeve_zone == BODY_ZONE_L_LEG)
					body_parts_covered &= ~LEG_LEFT
				var/obj/item/Sr = new salvage_result(get_turf(src))
				Sr.color = color
				user.put_in_hands(Sr)
				return
			else
				user.visible_message(span_warning("[user] tries to tear [src]."))
				return
	if(loc == L)
		L.regenerate_clothes()


/obj/item/clothing/mob_can_equip(mob/M, mob/equipper, slot, disable_warning = 0)
	. = ..()
	if(!.)
		return FALSE
	var/list/allowed_sexes = list()
	if(length(allowed_sex))
		allowed_sexes |= allowed_sex
	var/mob/living/carbon/human/H
	if(ishuman(M))
		H = M
		if(!immune_to_genderswap && H.dna?.species?.gender_swapping)
			if(MALE in allowed_sex)
				allowed_sexes -= MALE
				allowed_sexes += FEMALE
			if(FEMALE in allowed_sex)
				allowed_sexes -= FEMALE
				allowed_sexes += MALE
	if(slot_flags & slotdefine2slotbit(slot))
		if(!length(allowed_sexes) || (M.gender in allowed_sex))
			if(length(allowed_race) && H)
				if(H.dna.species.type in allowed_race)
					return TRUE
				return FALSE
			return TRUE
		return FALSE

/obj/item/clothing/Initialize()
	if(CHECK_BITFIELD(clothing_flags, VOICEBOX_TOGGLABLE))
		actions_types += /datum/action/item_action/toggle_voice_box
	. = ..()
	if(ispath(pocket_storage_component_path))
		LoadComponent(pocket_storage_component_path)
	if(prevent_crits)
		if(prevent_crits.len)
			has_inspect_verb = TRUE

/obj/item/clothing/MouseDrop(atom/over_object)
	. = ..()
	var/mob/M = usr

	if(!M.incapacitated() && loc == M && istype(over_object, /atom/movable/screen/inventory/hand))
		var/atom/movable/screen/inventory/hand/H = over_object
		if(M.putItemFromInventoryInHandIfPossible(src, H.held_index))
			add_fingerprint(usr)

/obj/item/reagent_containers/food/snacks/clothing
	name = "temporary moth clothing snack item"
	desc = ""
	list_reagents = list(/datum/reagent/consumable/nutriment = 1)
	tastes = list("dust" = 1, "lint" = 1)
	foodtype = CLOTH

/obj/item/clothing/attack(mob/living/M, mob/living/user, def_zone)
	if(user.used_intent.type != INTENT_HARM && ismoth(M))
		var/obj/item/reagent_containers/food/snacks/clothing/clothing_as_food = new
		clothing_as_food.name = name
		if(clothing_as_food.attack(M, user, def_zone))
			take_damage(15, sound_effect=FALSE)
		qdel(clothing_as_food)
	else if(M.on_fire)
		if(user == M)
			return
		user.changeNext_move(CLICK_CD_MELEE)
		M.visible_message(span_warning("[user] pats out the flames on [M] with [src]!"))
		M.adjust_fire_stacks(-2, /datum/status_effect/fire_handler/fire_stacks/divine)
		M.adjust_fire_stacks(-2)
		M.adjust_fire_stacks(-2, /datum/status_effect/fire_handler/fire_stacks/sunder)
		M.adjust_fire_stacks(-2, /datum/status_effect/fire_handler/fire_stacks/sunder/blessed)
		take_damage(10, BURN, "fire")
	else
		return ..()


/*	if(damaged_clothes && istype(W, /obj/item/stack/sheet/cloth))
		var/obj/item/stack/sheet/cloth/C = W
		C.use(1)
		update_clothes_damaged_state(FALSE)
		obj_integrity = max_integrity
		to_chat(user, span_notice("I fix the damage on [src] with [C]."))
		return 1*/
	return ..()

/obj/item/clothing/Destroy()
	user_vars_remembered = null //Oh god somebody put REFERENCES in here? not to worry, we'll clean it up
	return ..()

/obj/item/clothing/dropped(mob/user)
	..()
	if(!istype(user))
		return
	if(LAZYLEN(user_vars_remembered))
		for(var/variable in user_vars_remembered)
			if(variable in user.vars)
				if(user.vars[variable] == user_vars_to_edit[variable]) //Is it still what we set it to? (if not we best not change it)
					user.vars[variable] = user_vars_remembered[variable]
		user_vars_remembered = initial(user_vars_remembered) // Effectively this sets it to null.

/obj/item/clothing/equipped(mob/user, slot)
	..()
	if (!istype(user))
		return
	if(slot_flags & slotdefine2slotbit(slot)) //Was equipped to a valid slot for this item?
		if (LAZYLEN(user_vars_to_edit))
			for(var/variable in user_vars_to_edit)
				if(variable in user.vars)
					LAZYSET(user_vars_remembered, variable, user.vars[variable])
					user.vv_edit_var(variable, user_vars_to_edit[variable])

/obj/item/clothing/examine(mob/user)
	. = ..()
//	switch (max_heat_protection_temperature)
//		if (400 to 1000)
/*			. += "[src] offers the wearer limited protection from fire."
		if (1001 to 1600)
			. += "[src] offers the wearer some protection from fire."
		if (1601 to 35000)
			. += "[src] offers the wearer robust protection from fire."
	if(damaged_clothes)
		. += span_warning("It looks damaged!")
	var/datum/component/storage/pockets = GetComponent(/datum/component/storage)
	if(pockets)
		var/list/how_cool_are_your_threads = list("<span class='notice'>")
		if(pockets.attack_hand_interact)
			how_cool_are_your_threads += "[src]'s storage opens when clicked.\n"
		else
			how_cool_are_your_threads += "[src]'s storage opens when dragged to myself.\n"
		if (pockets.can_hold?.len) // If pocket type can hold anything, vs only specific items
			how_cool_are_your_threads += "[src] can store [pockets.max_items] <a href='?src=[REF(src)];show_valid_pocket_items=1'>item\s</a>.\n"
		else
			how_cool_are_your_threads += "[src] can store [pockets.max_items] item\s that are [weightclass2text(pockets.max_w_class)] or smaller.\n"
		if(pockets.quickdraw)
			how_cool_are_your_threads += "You can quickly remove an item from [src] using Alt-Click.\n"
		if(pockets.silent)
			how_cool_are_your_threads += "Adding or removing items from [src] makes no noise.\n"
		how_cool_are_your_threads += "</span>"
		. += how_cool_are_your_threads.Join()
*/

/obj/item/clothing/take_damage(damage_amount, damage_type = BRUTE, damage_flag = "", sound_effect = TRUE, attack_dir, armor_penetration = 0)
	var/actual_damage = ..()
	if(actual_damage && uses_zone_integrity())
		for(var/zone in GLOB.armor_check_zones)
			if(has_zone_integrity(zone))
				var/new_int = modify_zone_integrity(zone, -actual_damage)
				if(new_int != null && new_int <= 0)
					broken_zones |= zone
		update_overall_integrity()
	return actual_damage

/obj/item/clothing/obj_break(damage_flag)
	original_armor = armor
	var/list/armorlist = armor.getList()
	for(var/x in armorlist)
		if(armorlist[x] > 0)
			armorlist[x] = 0
	..()

/obj/item/clothing/obj_fix()
	..()
	armor = original_armor

/*
SEE_SELF  // can see self, no matter what
SEE_MOBS  // can see all mobs, no matter what
SEE_OBJS  // can see all objs, no matter what
SEE_TURFS // can see all turfs (and areas), no matter what
SEE_PIXELS// if an object is located on an unlit area, but some of its pixels are
          // in a lit area (via pixel_x,y or smooth movement), can see those pixels
BLIND     // can't see anything
*/

/proc/generate_female_clothing(index,t_color,icon,type)
	var/icon/female_clothing_icon	= icon("icon"=icon, "icon_state"=t_color)
	var/icon/female_s				= icon("icon"='icons/mob/clothing/under/masking_helpers.dmi', "icon_state"="[(type == FEMALE_UNIFORM_FULL) ? "female_full" : "female_top"]")
	female_clothing_icon.Blend(female_s, ICON_MULTIPLY)
	female_clothing_icon 			= fcopy_rsc(female_clothing_icon)
	GLOB.female_clothing_icons[index] = female_clothing_icon

/proc/generate_dismembered_clothing(index, t_color, icon, sleeveindex, sleevetype)
	testing("GDC [index]")
	if(sleevetype)
		var/icon/dismembered		= icon("icon"=icon, "icon_state"=t_color)
		var/icon/r_mask				= icon("icon"='icons/roguetown/clothing/onmob/helpers/dismemberment.dmi', "icon_state"="r_[sleevetype]")
		var/icon/l_mask				= icon("icon"='icons/roguetown/clothing/onmob/helpers/dismemberment.dmi', "icon_state"="l_[sleevetype]")
		switch(sleeveindex)
			if(1)
				dismembered.Blend(r_mask, ICON_MULTIPLY)
				dismembered.Blend(l_mask, ICON_MULTIPLY)
			if(2)
				dismembered.Blend(l_mask, ICON_MULTIPLY)
			if(3)
				dismembered.Blend(r_mask, ICON_MULTIPLY)
		dismembered 			= fcopy_rsc(dismembered)
		testing("GDC added [index]")
		GLOB.dismembered_clothing_icons[index] = dismembered

/obj/item/clothing/under/verb/toggle()
	set name = "Adjust Suit Sensors"
	set hidden = 1
	set src in usr
	if(!usr.client.holder)
		return
	var/mob/M = usr
	if (istype(M, /mob/dead/))
		return
	if (!can_use(M))
		return
	if(src.has_sensor == LOCKED_SENSORS)
		to_chat(usr, "The controls are locked.")
		return 0
	if(src.has_sensor == BROKEN_SENSORS)
		to_chat(usr, "The sensors have shorted out!")
		return 0
	if(src.has_sensor <= NO_SENSORS)
		to_chat(usr, "This suit does not have any sensors.")
		return 0

	var/list/modes = list("Off", "Binary vitals", "Exact vitals", "Tracking beacon")
	var/switchMode = input("Select a sensor mode:", "Suit Sensor Mode", modes[sensor_mode + 1]) in modes
	if(get_dist(usr, src) > 1)
		to_chat(usr, span_warning("I have moved too far away!"))
		return
	sensor_mode = modes.Find(switchMode) - 1

	if (src.loc == usr)
		switch(sensor_mode)
			if(0)
				to_chat(usr, span_notice("I disable my suit's remote sensing equipment."))
			if(1)
				to_chat(usr, span_notice("My suit will now only report whether you are alive or dead."))
			if(2)
				to_chat(usr, span_notice("My suit will now only report my exact vital lifesigns."))
			if(3)
				to_chat(usr, span_notice("My suit will now report my exact vital lifesigns as well as my coordinate position."))

/obj/item/clothing/under/AltClick(mob/user)
	if(..())
		return 1

	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		return
	else
		if(attached_accessory)
			remove_accessory(user)
		else
			rolldown()

/obj/item/clothing/under/verb/jumpsuit_adjust()
	set name = "Adjust Jumpsuit Style"
	set category = null
	set src in usr
	rolldown()

/obj/item/clothing/under/proc/rolldown()
	if(!can_use(usr))
		return
	if(!can_adjust)
		to_chat(usr, span_warning("I cannot wear this suit any differently!"))
		return
	if(toggle_jumpsuit_adjust())
		to_chat(usr, span_notice("I adjust the suit to wear it more casually."))
	else
		to_chat(usr, span_notice("I adjust the suit back to normal."))
	if(ishuman(usr))
		var/mob/living/carbon/human/H = usr
		H.update_inv_w_uniform()
		H.update_body()

/obj/item/clothing/under/proc/toggle_jumpsuit_adjust()
	if(adjusted == DIGITIGRADE_STYLE)
		return
	adjusted = !adjusted
	if(adjusted)
		if(fitted != FEMALE_UNIFORM_TOP)
			fitted = NO_FEMALE_UNIFORM
		if(!alt_covers_chest) // for the special snowflake suits that expose the chest when adjusted
			body_parts_covered &= ~CHEST
	else
		fitted = initial(fitted)
		if(!alt_covers_chest)
			body_parts_covered |= CHEST
	return adjusted

/obj/item/clothing/proc/weldingvisortoggle(mob/user) //proc to toggle welding visors on helmets, masks, goggles, etc.
	if(!can_use(user))
		return FALSE

	visor_toggling()

	to_chat(user, span_notice("I adjust \the [src] [up ? "up" : "down"]."))

	if(iscarbon(user))
		var/mob/living/carbon/C = user
		C.head_update(src, forced = 1)
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()
	return TRUE

/obj/item/clothing/proc/visor_toggling() //handles all the actual toggling of flags
	up = !up
	clothing_flags ^= visor_flags
	flags_inv ^= visor_flags_inv
	flags_cover ^= initial(flags_cover)
	icon_state = "[initial(icon_state)][up ? "up" : ""]"
	if(visor_vars_to_toggle & VISOR_FLASHPROTECT)
		flash_protect ^= initial(flash_protect)
	if(visor_vars_to_toggle & VISOR_TINT)
		tint ^= initial(tint)

/obj/item/clothing/head/helmet/space/plasmaman/visor_toggling() //handles all the actual toggling of flags
	up = !up
	clothing_flags ^= visor_flags
	flags_inv ^= visor_flags_inv
	icon_state = "[initial(icon_state)]"
	if(visor_vars_to_toggle & VISOR_FLASHPROTECT)
		flash_protect ^= initial(flash_protect)
	if(visor_vars_to_toggle & VISOR_TINT)
		tint ^= initial(tint)

/obj/item/clothing/proc/can_use(mob/user)
	if(user && ismob(user))
		if(!user.incapacitated())
			return 1
	return 0

/obj/item/clothing/take_damage(damage_amount, damage_type = BRUTE, damage_flag, sound_effect, attack_dir, armor_penetration)
	var/old_integrity = obj_integrity

	if(uses_zone_integrity())
		// Damage all zones when take_damage is called (non-targeted damage like fire/acid)
		var/integrity_mult = get_coverage_integrity_mult()
		if(integrity_mult > 3)
			integrity_mult = 3
		var/split_damage = round(damage_amount / integrity_mult, 1)
		var/list/all_zones = list(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_GROIN, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
		for(var/zone in all_zones)
			if(has_zone_integrity(zone))
				modify_zone_integrity(zone, -split_damage)

		update_overall_integrity()
		show_damage_notification(old_integrity, obj_integrity)

		// Call parent but reset obj_integrity to the old value to avoid double damage
		var/current_integrity = obj_integrity
		. = ..()
		obj_integrity = current_integrity
		update_overall_integrity()
	else
		. = ..()
		show_damage_notification(old_integrity, obj_integrity)


/obj/proc/generate_tooltip(examine_text, showcrits)
	return examine_text

/obj/item/clothing/generate_tooltip(examine_text, showcrits)
	if(!armor)	// No armor
		return examine_text

	// Fake armor
	if(armor.getRating("slash") == 0 && armor.getRating("stab") == 0 && armor.getRating("blunt") == 0 && armor.getRating("piercing") == 0)
		return examine_text

	var/str
	str += "[colorgrade_rating("🔨 BLUNT ", armor.blunt, elaborate = TRUE)] | "
	str += "[colorgrade_rating("🪓 SLASH ", armor.slash, elaborate = TRUE)]"
	str += "<br>"
	str += "[colorgrade_rating("🗡️ STAB ", armor.stab, elaborate = TRUE)] | "
	str += "[colorgrade_rating("🏹 PIERCE ", armor.piercing, elaborate = TRUE)] "

	if(showcrits && prevent_crits)
		str += "<br>———————————————<br>"
		str += "<font color = '#afaeae'><text-align: center>STOPS CRITS: <br>"
		var/linebreak_count = 0
		var/index = 0
		for(var/flag in prevent_crits)
			index++
			if(flag == BCLASS_PICK)	//BCLASS_PICK is named "stab", and "stabbing" is its own damage class. Prevents confusion.
				flag = "pick"
			str += ("[capitalize(flag)] ")
			linebreak_count++
			if(linebreak_count >= 3)
				str += "<br>"
				linebreak_count = 0
			else if(index != length(prevent_crits))
				str += " | "
		str += "</font>"

	//This makes it appear a faint off-blue from the rest of examine text. Draws the cursor to it like to a Wetsquires.rt link.
	examine_text = "<font color = '#aabdbe'>[examine_text]</font>"
	return SPAN_TOOLTIP_DANGEROUS_HTML(str, examine_text)
