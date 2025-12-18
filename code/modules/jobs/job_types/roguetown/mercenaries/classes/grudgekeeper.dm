//Dwarf-exclusive mercenary class with unique armor setups.
/datum/advclass/mercenary/grudgekeeper
	name = "Grudgekeeper"
	tutorial = "The Bearer of Grudges. Well-Respected among your fellow Keepers, chosen to be the one who never forgets." //Writing is not my forte
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = list(
		/datum/species/dwarf,
		/datum/species/dwarf/mountain
	)
	outfit = /datum/outfit/job/mercenary/grudgekeeper
	maximum_possible_slots = 1
	category_tags = list(CTAG_MERCENARY)
	class_select_category = CLASS_CAT_RACIAL
	cmode_music = 'sound/music/combat_dwarf.ogg'
	extra_context = "This subclass is race-limited to: Dwarves."

	traits_applied = list(TRAIT_HEAVYARMOR, TRAIT_BREADY)
	subclass_stats = list(
		STATKEY_CON = 5,
		STATKEY_END = 4,
		STATKEY_STR = 2,
		STATKEY_SPD = -2
	)

	subclass_skills = list(
		/datum/skill/combat/polearms = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/axes = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/maces = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/shields = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/reading = SKILL_LEVEL_MASTER, // The master reader. Reading those grudges!
		/datum/skill/misc/athletics = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/swimming = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/unarmed = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/wrestling = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/tracking = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/craft/armorsmithing = SKILL_LEVEL_APPRENTICE,	//Only here so they'd be able to repair their own armor integrity
		/datum/skill/misc/climbing = SKILL_LEVEL_NOVICE,
	)

/datum/outfit/job/mercenary/grudgekeeper/pre_equip(mob/living/carbon/human/H)
	..()
	if(H.mind)

		shoes = /obj/item/clothing/shoes/roguetown/boots/armor/dwarvencapt
		cloak = /obj/item/clothing/cloak/forrestercloak/snow
		belt = /obj/item/storage/belt/rogue/leather/steel/tasset
		beltl = /obj/item/flashlight/flare/torch
		backl = /obj/item/storage/backpack/rogue/satchel
		shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/black
		gloves = /obj/item/clothing/gloves/roguetown/plate/dwarvencapt
		pants = /obj/item/clothing/under/roguetown/trou/leather
		armor = /obj/item/clothing/suit/roguetown/armor/plate/full/dwarvencapt
		head = /obj/item/clothing/head/roguetown/helmet/heavy/dwarvencapt
		mask = /obj/item/clothing/head/roguetown/paddedcap
		backpack_contents = list(
			/obj/item/roguekey/mercenary,
			/obj/item/storage/belt/rogue/pouch/coins/poor,
			/obj/item/rogueweapon/hammer/iron,
			/obj/item/paper/scroll/grudge/grand,
			/obj/item/natural/feather,
			)
		var/weapons = list("Warpick + Dwarven Shield", "Warhammer + Dwarven Shield", "Battle Axe + Dwarven Shield", "Great Axe", "Grandmace")
		var/wepchoice = input(H, "Choose your weapon", "Available weapons") as anything in weapons
		switch(wepchoice)

			if("Warpick + Dwarven Shield")
				backr = /obj/item/rogueweapon/shield/tower/metal/dwarf
				r_hand = /obj/item/rogueweapon/stoneaxe/battle
				H.adjust_skillrank(/datum/skill/combat/axes, 1, TRUE) //It uses axe skill instead of mining.
			if("Warhammer + Dwarven Shield")
				backr = /obj/item/rogueweapon/shield/tower/metal/dwarf
				r_hand = /obj/item/rogueweapon/stoneaxe/battle
				H.adjust_skillrank(/datum/skill/combat/axes, 1, TRUE)
			if("Battle Axe + Dwarven Shield")
				backr = /obj/item/rogueweapon/shield/tower/metal/dwarf
				r_hand = /obj/item/rogueweapon/stoneaxe/battle
				H.adjust_skillrank(/datum/skill/combat/axes, 1, TRUE)
			if("Great Axe") //No special shield, however gains flexibility in polearms for upgrades.
				r_hand = /obj/item/rogueweapon/greataxe/steel
				H.adjust_skillrank(/datum/skill/combat/axes, 1, TRUE)
				H.adjust_skillrank(/datum/skill/combat/polearms, 1, TRUE)
			if("Grandmace")
				r_hand = /obj/item/rogueweapon/mace/goden/steel
				H.adjust_skillrank(/datum/skill/combat/maces, 1, TRUE)
				H.adjust_skillrank(/datum/skill/combat/polearms, 1, TRUE)

/obj/item/clothing/suit/roguetown/armor/plate/full/dwarvencapt
	name = "grudgekeeper dwarven plate"
	desc = "A standard, layered plate worn by many dwarven troops. It cannot be worked on without intrinsic dwarven knowledge."
	icon = 'icons/roguetown/clothing/special/race_armor.dmi'
	mob_overlay_icon = 'icons/roguetown/clothing/special/onmob/race_armor.dmi'
	allowed_race = list(/datum/species/dwarf, /datum/species/dwarf/mountain)
	icon_state = "dwarfchest_red"
	item_state = "dwarfchest_red"
	armor = ARMOR_GRUDGEBEARER
	prevent_crits = list(BCLASS_TWIST)
	body_parts_covered = CHEST|GROIN|VITALS|ARMS|LEGS
	equip_delay_self = 5 SECONDS
	unequip_delay_self = 5 SECONDS
	equip_delay_other = 4 SECONDS
	strip_delay = 12 SECONDS
	smelt_bar_num = 4
	max_integrity = 1000	//They have their own unique integrity

/obj/item/clothing/suit/roguetown/armor/plate/full/dwarvencapt/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/layeredarmor/grudgekeeper)

/obj/item/clothing/head/roguetown/helmet/heavy/dwarvencapt
	name = "grudgekeeper dwarven helm"
	body_parts_covered = (HEAD | MOUTH | NOSE | EYES | EARS | NECK)	//This specifically omits hair so you could hang your beard out of the helm
	armor = ARMOR_GRUDGEBEARER
	prevent_crits = list(BCLASS_TWIST)
	allowed_race = list(/datum/species/dwarf, /datum/species/dwarf/mountain)
	icon = 'icons/roguetown/clothing/special/race_armor.dmi'
	mob_overlay_icon = 'icons/roguetown/clothing/special/onmob/race_armor.dmi'
	icon_state = "dwarfhead_red"
	item_state = "dwarfhead_red"
	block2add = FOV_BEHIND
	bloody_icon = 'icons/effects/blood64.dmi'
	smeltresult = /obj/item/ingot/steel
	max_integrity = 1000
	experimental_inhand = FALSE
	experimental_onhip = FALSE

/obj/item/clothing/head/roguetown/helmet/heavy/dwarvencapt/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/layeredarmor/grudgekeeper/helmet)

/obj/item/clothing/gloves/roguetown/plate/dwarvencapt
	name = "grudgekeeper dwarven gauntlets"
	icon = 'icons/roguetown/clothing/special/race_armor.dmi'
	mob_overlay_icon = 'icons/roguetown/clothing/special/onmob/race_armor.dmi'
	allowed_race = list(/datum/species/dwarf, /datum/species/dwarf/mountain)
	prevent_crits = list(BCLASS_TWIST)
	icon_state = "dwarfhand_red"
	item_state = "dwarfhand_red"
	armor = ARMOR_GRUDGEBEARER
	max_integrity = 1000

/obj/item/clothing/gloves/roguetown/plate/dwarvencapt/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/layeredarmor/grudgekeeper/limbs)

/obj/item/clothing/shoes/roguetown/boots/armor/dwarvencapt	
	name = "grudgebearer dwarven boots"
	desc = "Clatters mightily. It is covered in protective layers."
	icon = 'icons/roguetown/clothing/special/race_armor.dmi'
	mob_overlay_icon = 'icons/roguetown/clothing/special/onmob/race_armor.dmi'
	allowed_race = list(/datum/species/dwarf, /datum/species/dwarf/mountain)
	prevent_crits = list(BCLASS_TWIST)
	icon_state = "dwarfshoe_red"
	item_state = "dwarfshoe_red"
	armor = ARMOR_GRUDGEBEARER
	max_integrity = 1000

/obj/item/clothing/shoes/roguetown/boots/armor/dwarvencapt/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/layeredarmor/grudgekeeper/limbs)


// ARMOR COMPONENTS DOWN HERE

/datum/component/layeredarmor/grudgekeeper
	layer_repair = 2

	layer_max = list(
		"blunt" = 60, // Bit more blunt
		"slash" = 200,
		"stab" = 200,
		"piercing" = 100,
	)

	hits_to_shred = list(
		"blunt" = 3,
		"slash" = 3,
		"stab" = 3,
		"piercing" = 6,
	)

	damtype_shred_ratio = list(
		"blunt" = 1,
		"slash" = 1,
		"stab" = 1,
		"piercing" = 3, // Half as Succeptible to ranged attacks. 
	)

	hits_per_layer = list(
		"200"	= 5, // Two more at max.
		"100" 	= 4,
		"90" 	= 4,
		"80" 	= 6,
		"70" 	= 6, // One more up to 70% 
		"60" 	= 5,
		"50"	= 10,
		"40"	= 10,
		"30"	= 20,
		"20"	= 30,
		"10"	= 50,
	)

	repair_items = list(/obj/machinery/anvil)

	repair_skills = list(
		/datum/skill/craft/armorsmithing = 2,
	)

	race_repair = list(
		/datum/species/dwarf,
		/datum/species/dwarf/mountain,
	)

/datum/component/layeredarmor/grudgekeeper/helmet

/datum/component/layeredarmor/grudgekeeper/limbs
	hits_to_shred = list(
		"blunt" = 2,
		"slash" = 2,
		"stab" = 2,
		"piercing" = 2,
	)

	layer_max = list(
		"blunt" = 60, //Bit more Blunt
		"slash" = 200,
		"stab" = 200,
		"piercing" = 100, //Bit more Pierce
	)

	hits_per_layer = list(
		"200"	= 3, 
		"100" 	= 3,
		"90" 	= 3, 
		"80" 	= 3, // One more hit for LIMBS.
		"70" 	= 3,
		"60" 	= 3,
		"50"	= 3,
		"40"	= 3,
		"30"	= 4,
		"20"	= 20,
		"10"	= 30,
	)

	shred_amt = 20	//Limbs lose 2 grades per layer shred, but also repair 4.
	layer_repair = 2
