/////     ARMS     /////

/obj/item/bodypart/l_arm/prosthetic/woodleft
	name = "wooden left arm"
	desc = "A left arm made out of wood."
	icon = 'icons/roguetown/mob/bodies/prosthetics.dmi'
	icon_state = "pr_wood_arm_r"
	limb_material = "wood"
	resistance_flags = FLAMMABLE
	obj_flags = CAN_BE_HIT
	status = BODYPART_ROBOTIC
	brute_reduction = 0
	burn_reduction = 0
	max_damage = 20
	w_class = WEIGHT_CLASS_NORMAL
	max_integrity = 300
	sellprice = 30
	fingers = FALSE //can't swing weapons but can pick stuff up and punch
	anvilrepair = /datum/skill/craft/carpentry

/obj/item/bodypart/l_arm/prosthetic/bronzeleft
	name = "bronze left arm"
	desc = "A replacement left arm, engineered out of bronze."
	icon = 'icons/roguetown/mob/bodies/prosthetics.dmi' // copying here for clarity or whatever
	icon_state = "pr_bronze_arm_l"
	limb_material = "bronze" // swap it to fucking bronze if there's ever gonna be a bronze onmob sprite for it
	resistance_flags = FIRE_PROOF
	obj_flags = CAN_BE_HIT
	status = BODYPART_ROBOTIC
	brute_reduction = 0
	burn_reduction = 0
	max_damage = 220
	w_class = WEIGHT_CLASS_NORMAL
	max_integrity = 350
	sellprice = 30
	fingers = TRUE // it acts like a normal arm
	anvilrepair = /datum/skill/craft/engineering
	smeltresult = /obj/item/ingot/bronze

/obj/item/bodypart/l_arm/prosthetic/attack(mob/living/M, mob/user)
	if(!ishuman(M))
		return
	var/mob/living/carbon/human/H = M
	var/obj/item/bodypart/affecting = H.get_bodypart(check_zone(user.zone_selected))
	if(affecting)
		return
	if(user.zone_selected != body_zone) //so we can't replace a leg with an arm, or a human arm with a monkey arm.
		to_chat(user, span_warning("[src] isn't the right type for [parse_zone(user.zone_selected)]."))
		return -1
	if(user.temporarilyRemoveItemFromInventory(src))
		attach_limb(H)
		user.visible_message(span_notice("[user] attaches [src] to [H]."))
		return 1

/obj/item/bodypart/r_arm/prosthetic/woodright
	name = "wooden right arm"
	desc = "A right arm made out of wood."
	icon = 'icons/roguetown/mob/bodies/prosthetics.dmi'
	icon_state = "pr_wood_arm_r"
	limb_material = "wood"
	resistance_flags = FLAMMABLE
	obj_flags = CAN_BE_HIT
	status = BODYPART_ROBOTIC
	brute_reduction = 0
	burn_reduction = 0
	max_damage = 40
	w_class = WEIGHT_CLASS_NORMAL
	max_integrity = 300
	sellprice = 30
	fingers = FALSE //can't swing weapons but can pick stuff up and punch
	anvilrepair = /datum/skill/craft/carpentry

/obj/item/bodypart/r_arm/prosthetic/bronzeright // look here
	name = "bronze right arm"
	desc = "A replacement right arm, engineered out of bronze."
	icon = 'icons/roguetown/mob/bodies/prosthetics.dmi'
	icon_state = "pr_bronze_arm_r"
	limb_material = "bronze" // still need a different onmob sprite for bronze limbs brah
	resistance_flags = FIRE_PROOF
	obj_flags = CAN_BE_HIT
	status = BODYPART_ROBOTIC
	brute_reduction = 0
	burn_reduction = 0
	max_damage = 220
	w_class = WEIGHT_CLASS_NORMAL
	max_integrity = 350
	sellprice = 30
	fingers = TRUE // it acts like a normal arm
	anvilrepair = /datum/skill/craft/engineering
	smeltresult = /obj/item/ingot/bronze

/obj/item/bodypart/r_arm/prosthetic/attack(mob/living/M, mob/user)
	if(!ishuman(M))
		return
	var/mob/living/carbon/human/H = M
	var/obj/item/bodypart/affecting = H.get_bodypart(check_zone(user.zone_selected))
	if(affecting)
		return
	if(user.zone_selected != body_zone) //so we can't replace a leg with an arm, or a human arm with a monkey arm.
		to_chat(user, span_warning("[src] isn't the right type for [parse_zone(user.zone_selected)]."))
		return -1
	if(user.temporarilyRemoveItemFromInventory(src))
		attach_limb(H)
		user.visible_message(span_notice("[user] attaches [src] to [H]."))
		return 1

/////     LEGS     /////

/obj/item/bodypart/l_leg/prosthetic/woodleft
	name = "wooden left leg"
	desc = "A left leg made out of wood."
	icon = 'icons/roguetown/mob/bodies/prosthetics.dmi' // someone make fucking onmob sprites HOLY SHIT....
	icon_state = "pr_wood_leg_l"
	limb_material = "wood"
	resistance_flags = FLAMMABLE
	obj_flags = CAN_BE_HIT
	status = BODYPART_ROBOTIC
	brute_reduction = 0
	burn_reduction = 0
	max_damage = 40
	w_class = WEIGHT_CLASS_NORMAL
	max_integrity = 300
	sellprice = 30
	anvilrepair = /datum/skill/craft/carpentry

/obj/item/bodypart/l_leg/prosthetic/bronzeleft
	name = "bronze left leg"
	desc = "A replacement left leg, engineered out of bronze."
	icon = 'icons/roguetown/mob/bodies/prosthetics.dmi'
	icon_state = "pr_bronze_leg_l"
	limb_material = "bronze" // still have to make actually distinct onmbob from wood
	resistance_flags = FIRE_PROOF
	obj_flags = CAN_BE_HIT
	status = BODYPART_ROBOTIC
	brute_reduction = 0
	burn_reduction = 0
	max_damage = 220
	w_class = WEIGHT_CLASS_NORMAL
	max_integrity = 350
	sellprice = 30
	anvilrepair = /datum/skill/craft/engineering
	smeltresult = /obj/item/ingot/bronze

/obj/item/bodypart/l_leg/prosthetic/attack(mob/living/M, mob/user)
	if(!ishuman(M))
		return
	var/mob/living/carbon/human/H = M
	var/obj/item/bodypart/affecting = H.get_bodypart(check_zone(user.zone_selected))
	if(affecting)
		return
	if(user.zone_selected != body_zone) //so we can't replace a leg with an arm, or a human arm with a monkey arm.
		to_chat(user, span_warning("[src] isn't the right type for [parse_zone(user.zone_selected)]."))
		return -1
	if(user.temporarilyRemoveItemFromInventory(src))
		attach_limb(H)
		if(H.pegleg < 1)
			H.pegleg++
		user.visible_message(span_notice("[user] attaches [src] to [H]."))
		return 1

/obj/item/bodypart/r_leg/prosthetic/woodright
	name = "wooden right leg"
	desc = "A right leg made out of wood."
	icon = 'icons/roguetown/mob/bodies/prosthetics.dmi'
	icon_state = "pr_wood_leg_r"
	limb_material = "wood"
	resistance_flags = FLAMMABLE
	obj_flags = CAN_BE_HIT
	status = BODYPART_ROBOTIC
	brute_reduction = 0
	burn_reduction = 0
	max_damage = 40
	w_class = WEIGHT_CLASS_NORMAL
	max_integrity = 300
	sellprice = 30
	anvilrepair = /datum/skill/craft/carpentry

/obj/item/bodypart/r_leg/prosthetic/bronzeright
	name = "bronze right leg"
	desc = "A replacement right leg, engineered out of bronze."
	icon = 'icons/roguetown/mob/bodies/prosthetics.dmi'
	icon_state = "pr_bronze_leg_r"
	limb_material = "bronze" // still have to make actually distinct onmbob from wood
	resistance_flags = FIRE_PROOF
	obj_flags = CAN_BE_HIT
	status = BODYPART_ROBOTIC
	brute_reduction = 0
	burn_reduction = 0
	max_damage = 220
	w_class = WEIGHT_CLASS_NORMAL
	max_integrity = 350
	sellprice = 30
	anvilrepair = /datum/skill/craft/engineering
	smeltresult = /obj/item/ingot/bronze

/obj/item/bodypart/r_leg/prosthetic/attack(mob/living/M, mob/user)
	if(!ishuman(M))
		return
	var/mob/living/carbon/human/H = M
	var/obj/item/bodypart/affecting = H.get_bodypart(check_zone(user.zone_selected))
	if(affecting)
		return
	if(user.zone_selected != body_zone) //so we can't replace a leg with an arm, or a human arm with a monkey arm.
		to_chat(user, "<span class='warning'>[src] isn't the right type for [parse_zone(user.zone_selected)].</span>")
		return -1
	if(user.temporarilyRemoveItemFromInventory(src))
		attach_limb(H)
		if(H.pegleg < 1)
			H.pegleg++
		user.visible_message("<span class='notice'>[user] attaches [src] to [H].</span>")
		return 1

/////////////
/// HEAD ///
///////////

/obj/item/bodypart/head/prosthetic/continuity_head
	name = "continuity head"
	icon = 'icons/roguetown/mob/bodies/prosthetics.dmi'
	icon_state = "pr_gold_head"
	limb_material = "gold"
	dismemberable = TRUE
	resistance_flags = FIRE_PROOF
	obj_flags = CAN_BE_HIT
	status = BODYPART_ROBOTIC
	max_damage = 250 // +50 more hp compared to the normal ass head
	dismemberable = FALSE // ehh

/obj/item/bodypart/head/prosthetic/continuity_head/New()
	. = ..()
	src.visible_message(span_bloody("<b>I've done it... now only to graft the brain, eyes and ears...</b>"))

/obj/item/bodypart/head/prosthetic/continuity_head/update_icon_dropped() // this uses a different proc
	return

/obj/item/bodypart/head/prosthetic/continuity_head/attach_limb(mob/living/carbon/C, special)
	. = ..()
	head_real_name = "Husk of [C.real_name]"
	C.real_name = head_real_name
//	return ..()
