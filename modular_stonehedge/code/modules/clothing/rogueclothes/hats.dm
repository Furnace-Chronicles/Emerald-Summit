
//studded hood and shit brought to you by vide noir
//it requires sewing to make the padded hood and blacksmithing to make studded hood, like studded armor.
//this is an upgrade to leather helmet cause it's more bothersome and (there is literally no reason to have leather helmets cause there is no weight class for them anyway.)
//but this atleast hides your identity and looks cool, have more crit resist types.
/obj/item/clothing/head/roguetown/helmet/leather/armorhood
	name = "padded leather hood"
	desc = "A padded leather hood with buckles."
	icon = 'modular_stonehedge/icons/clothing/armor/head.dmi'
	mob_overlay_icon = 'modular_stonehedge/icons/clothing/armor/onmob/head.dmi'
	icon_state = "studhood"
	item_state = "studhood"
	flags_inv =	HIDEHAIR|HIDEEARS|HIDEFACE
	slot_flags = ITEM_SLOT_NECK|ITEM_SLOT_HEAD
	body_parts_covered = HEAD|EARS|HAIR|NOSE|EYES|NECK
	//Something between leather and metal helmet, worse than metal helmet by far.
	armor = list("blunt" = 70, "slash" = 65, "stab" = 60, "piercing" = 20, "fire" = 0, "acid" = 0)
	prevent_crits = list(BCLASS_CUT, BCLASS_BLUNT, BCLASS_TWIST)
	adjustable = CAN_CADJUST
	toggle_icon_state = TRUE

/obj/item/clothing/head/roguetown/helmet/leather/armorhood/advanced

	name = "studded leather hood"
	desc = "A thick studded leather hood with buckles."
	icon_state = "studhood" //make into new sprite
	item_state = "studhood"
	max_integrity = 280
	//closer to metal helmet but still quite behind, same blunt resist of hardened leather helmet though.
	armor = list("blunt" = 90, "slash" = 80, "stab" = 70, "piercing" = 20, "fire" = 0, "acid" = 0)
	prevent_crits = list(BCLASS_CUT, BCLASS_STAB, BCLASS_BLUNT, BCLASS_TWIST, BCLASS_CHOP, BCLASS_SMASH) //studded armor values with stab prot too

/obj/item/clothing/head/roguetown/helmet/leather/armorhood/AdjustClothes(mob/user)
	if(loc == user)
		if(adjustable == CAN_CADJUST)
			adjustable = CADJUSTED
			if(toggle_icon_state)
				icon_state = "[initial(icon_state)]_t"
			flags_inv = null
			body_parts_covered = NECK
			if(ishuman(user))
				var/mob/living/carbon/H = user
				H.update_inv_head()
				H.update_inv_neck()
		else if(adjustable == CADJUSTED)
			ResetAdjust(user)
			flags_inv =	initial(flags_inv)
			if(user)
				if(ishuman(user))
					var/mob/living/carbon/H = user
					H.update_inv_head()
					H.update_inv_neck()

//RECIPES
/datum/crafting_recipe/roguetown/leather/studhood
	name = "leather padded hood"
	result = /obj/item/clothing/head/roguetown/helmet/leather/armorhood
	reqs = list(/obj/item/natural/hide/cured = 2)
	craftdiff = 2

/datum/anvil_recipe/armor/studdedhood
	name = "Studded Leather Hood"
	req_bar = /obj/item/ingot/iron
	additional_items = list(/obj/item/clothing/head/roguetown/helmet/leather/armorhood)
	created_item = /obj/item/clothing/head/roguetown/helmet/leather/armorhood/advanced
	i_type = "Armor"
