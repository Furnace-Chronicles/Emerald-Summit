/datum/advclass/ogre/avatar
	name = "Avatar of Graggar" 
	tutorial = "A foul stench of death spreads from the bog across the entire land, none can escape it. For the Avatar of Graggar arises from the muck to devour in the name of his father. Prepare now!"
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = /datum/species/ogre
	outfit = /datum/outfit/job/roguetown/ogre/avatar
	category_tags = list(CTAG_OGRE)
	cmode_music = 'sound/music/combat_maniac.ogg' // this one is good
	maximum_possible_slots = 1

	traits_applied = list(TRAIT_BASHDOORS, TRAIT_STEELHEARTED, TRAIT_STRENGTH_UNCAPPED, TRAIT_CALTROPIMMUNE, TRAIT_STRONGBITE, TRAIT_MEDIUMARMOR) //strongbite might be funny
	subclass_stats = list( 
		STATKEY_STR = 3, 
		STATKEY_CON = 6,
		STATKEY_END = 5,
	) 

	subclass_skills = list(
		/datum/skill/combat/maces = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/polearms = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/axes = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/swords = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/knives = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/wrestling = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/unarmed = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/athletics = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/climbing = SKILL_LEVEL_APPRENTICE,
	) //trust me this'll be fine - they'll only have a cuirass and a hauberk for armor i swear

/datum/outfit/job/roguetown/ogre/avatar/pre_equip(mob/living/carbon/human/H)
	..()
	if(H.mind)
		H.set_patron(/datum/patron/inhumen/graggar) // why would you be an avatar of graggar without following graggar
		to_chat(H, span_warning("Do what comes naturally."))
		shoes = /obj/item/clothing/shoes/roguetown/armor/ogre
		neck = /obj/item/clothing/neck/roguetown/gorget/ogre
		pants = /obj/item/clothing/under/roguetown/chainlegs/ogre
		shirt = /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk/ogre
		gloves = /obj/item/clothing/gloves/roguetown/plate/ogre
		wrists = /obj/item/clothing/wrists/roguetown/bracers/ogre
		head = /obj/item/clothing/head/roguetown/helmet/heavy/graggar/ogre
		belt = /obj/item/storage/belt/rogue/leather/ogre
		armor = /obj/item/clothing/suit/roguetown/armor/plate/half/ogre
		beltr = /obj/item/rogueweapon/huntingknife/cleaver/ogre
		backl = /obj/item/rogueweapon/greatsword/zwei/ogre
		backr = /obj/item/storage/backpack/rogue/satchel
		backpack_contents = list(
			/obj/item/rogueweapon/mace/cudgel/ogre = 1,
			/obj/item/rope/chain = 1,
			/obj/item/flashlight/flare/torch/lantern = 1
		)
		var/weapons = list(
			"CRUSHER"	= /obj/item/rogueweapon/mace/goden/steel/ogre/graggar,
			"EXECUTIONER" 	= /obj/item/rogueweapon/greataxe/steel/doublehead/graggar/ogre,
			"None"
		)
		var/weaponchoice = input(H,"Choose your weapon.", "WEAPON SELECTION") as anything in weapons
		if(weaponchoice != "None")
			r_hand = weapons[weaponchoice] // doing it this way cuz the normal way runtimes for some fucking reason, despite it being a 1 to 1 copy/paste of trollslayer
