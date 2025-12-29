/datum/advclass/ogre/mercenary
	name = "Mercenary" 
	tutorial = "Hailing from Gronn, you've learned that ogres are tolerated if they provide their massive strength to others, and coin can help you get more ale and meat if you got enough of it. You've come to Scarlet Reach with a simple goal. Get paid, get food."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = /datum/species/ogre
	outfit = /datum/outfit/job/roguetown/ogre/mercenary
	category_tags = list(CTAG_OGRE)
	cmode_music = 'sound/music/combat_fullplate.ogg'
	maximum_possible_slots = 1


	traits_applied = list(TRAIT_BASHDOORS, TRAIT_STEELHEARTED, TRAIT_CALTROPIMMUNE, TRAIT_STRONGBITE, TRAIT_MEDIUMARMOR) //strongbite might be funny
	subclass_stats = list( 
		STATKEY_STR = 3, 
		STATKEY_CON = 3,
		STATKEY_END = 3,
		STATKEY_SPD = -1,
		STATKEY_INT = -1,
	) 

	subclass_skills = list(
		/datum/skill/combat/maces = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/polearms = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/swords = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/axes = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/wrestling = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/knives = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/unarmed = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/athletics = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/climbing = SKILL_LEVEL_APPRENTICE,
	) //trust me this'll be fine - they'll only have a cuirass and a hauberk for armor i swear

/datum/outfit/job/roguetown/ogre/mercenary/pre_equip(mob/living/carbon/human/H)
	..()
	if(H.mind)
		to_chat(H, span_warning("Hailing from Gronn, you've learned that ogres are tolerated if they provide their massive strength to others, and coin can help you get more ale and meat if you got enough of it. You've come to Scarlet Reach with a simple goal. Get paid, get food."))
		shoes = /obj/item/clothing/shoes/roguetown/armor/ogre
		shirt = /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk/ogre
		neck = /obj/item/clothing/neck/roguetown/gorget/ogre
		pants = /obj/item/clothing/under/roguetown/chainlegs/ogre
		gloves = /obj/item/clothing/gloves/roguetown/plate/ogre
		wrists = /obj/item/clothing/wrists/roguetown/bracers/ogre
		head = /obj/item/clothing/head/roguetown/helmet/heavy/ogre
		belt = /obj/item/storage/belt/rogue/leather/ogre
		armor = /obj/item/clothing/suit/roguetown/armor/plate/half/ogre
		beltr = /obj/item/rogueweapon/huntingknife/cleaver/ogre
		backr = /obj/item/storage/backpack/rogue/satchel
		backpack_contents = list(
			/obj/item/rogueweapon/mace/cudgel/ogre = 1,
			/obj/item/rope/chain = 1,
			/obj/item/flashlight/flare/torch/lantern = 1
		)
		var/weapons = list(
			"Big Stick"	= /obj/item/rogueweapon/mace/goden/steel/ogre,
			"Choppa" 	= /obj/item/rogueweapon/greatsword/zwei/ogre,
			"None"
		)
		var/weaponchoice = input(H,"Choose your weapon.", "WEAPON SELECTION") as anything in weapons
		if(weaponchoice != "None")
			backl = weapons[weaponchoice] // doing it this way cuz the normal way runtimes for some fucking reason, despite it being a 1 to 1 copy/paste of trollslayer
