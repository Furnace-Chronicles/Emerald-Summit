/datum/advclass/ogre/irongut // a dodge and sneak styled ogre mercenary??
	name = "Irongut shadow"
	tutorial = "You are one of the strangest examples of ogres, instead of be in a horde of blades like your kind you have decided to learn the ways of the shadows, being one with them and using different methods to destroy your enemies, they may hear your steps and that's the last thing they do."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = OGRE_RACE_TYPES
	outfit = /datum/outfit/job/ogre/irongut
	category_tags = list(CTAG_MERCENARY)
	class_select_category = OGRE_RACE_TYPES
	cmode_music = 'sound/music/combat_kazengite.ogg'
	maximum_possible_slots = 8 // 8 mercenary slots = 8 ninjas no one will see.

	subclass_languages = list(/datum/language/kazengunese)

	traits_applied = list(TRAIT_LEAPER, TRAIT_STEELHEARTED, TRAIT_LIGHT_STEP, TRAIT_DODGEEXPERT, TRAIT_CRITICAL_RESISTANCE, TRAIT_NOPAINSTUN, TRAIT_HARDDISMEMBER)
	subclass_stats = list(
		STATKEY_CON = 1,
		STATKEY_END = 2,
		STATKEY_STR = 1, // weaker than other ogres in exchange for some speed
		STATKEY_PER = 1,
		STATKEY_SPD = 5 //they get a -3 racial debuff so a +2 in total without virtues
	)

	subclass_skills = list(
		/datum/skill/misc/swimming = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/climbing = SKILL_LEVEL_MASTER,
		/datum/skill/misc/sneaking = SKILL_LEVEL_MASTER,
		/datum/skill/combat/wrestling = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/unarmed = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/swords = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/whipsflails = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/knives = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/reading = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/athletics = SKILL_LEVEL_JOURNEYMAN,
	)

/datum/outfit/job/ogre/irongut/pre_equip(mob/living/carbon/human/H)
	..()
	neck = /obj/item/clothing/neck/roguetown/chaincoif/iron/ogre
	armor = /obj/item/clothing/suit/roguetown/armor/leather/studded/ogre
	shirt = /obj/item/clothing/suit/roguetown/shirt/ogre
	shoes = /obj/item/clothing/shoes/roguetown/boots/ogre
	gloves = /obj/item/clothing/gloves/roguetown/leather/ogre
	wrists = /obj/item/clothing/wrists/roguetown/bracers/ogre
	pants = /obj/item/clothing/under/roguetown/tights/ogre
	belt = /obj/item/storage/belt/rogue/leather/ogre
	beltr = /obj/item/rogueweapon/flail/kazenogre
	beltl = /obj/item/rogueweapon/knuckles/ogre
	backr = /obj/item/storage/backpack/rogue/satchel
	backpack_contents = list(
		/obj/item/roguekey/mercenary,
		/obj/item/flashlight/flare/torch/lantern,
	)
	H.adjust_blindness(-3)
