/datum/advclass/mercenary/kashira //shitcode approved by free
	name = "Kashira"
	tutorial = "You are one of the finer examples of swordsmanship stemming from Kazengun. A singular representative of the Ruma Clan, and generally a respected leader."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = NON_DWARVEN_RACE_TYPES
	outfit = /datum/outfit/job/roguetown/mercenary/kashira
	category_tags = list(CTAG_MERCENARY)
	class_select_category = CLASS_CAT_KAZENGUN
	cmode_music = 'sound/music/combat_kazengite.ogg'
	maximum_possible_slots = 1

	subclass_languages = list(/datum/language/kazengunese)

	traits_applied = list(TRAIT_CRITICAL_RESISTANCE, TRAIT_NOPAINSTUN)
	subclass_stats = list(
		STATKEY_CON = 3,
		STATKEY_END = 3,
		STATKEY_STR = 2,
		STATKEY_PER = 1,
		STATKEY_SPD = -1
	)

	subclass_skills = list(
		/datum/skill/misc/swimming = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/climbing = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/sneaking = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/wrestling = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/unarmed = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/swords = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/shields = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/knives = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/reading = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/athletics = SKILL_LEVEL_JOURNEYMAN,
	)

/datum/outfit/job/roguetown/mercenary/kashira/pre_equip(mob/living/carbon/human/H)
	..()
	belt = /obj/item/storage/belt/rogue/leather
	beltr = /obj/item/rogueweapon/sword/sabre/mulyeog/rumacaptain
	beltl = /obj/item/rogueweapon/scabbard/sword/kazengun/gold
	backr = /obj/item/storage/backpack/rogue/satchel
	backpack_contents = list(/obj/item/roguekey/mercenary, /obj/item/flashlight/flare/torch, /obj/item/flashlight/flare/torch/lantern)
	H.adjust_blindness(-3)

	if(should_wear_masc_clothes(H))
		shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/eastshirt1
		cloak = /obj/item/clothing/cloak/eastcloak1
		/obj/item/clothing/under/roguetown/heavy_leather_pants/eastpants1
		gloves = /obj/item/clothing/gloves/roguetown/eastgloves2
		armor = /obj/item/clothing/suit/roguetown/armor/skin_armor/easttats
		shoes = /obj/item/clothing/shoes/roguetown/boots
		H.change_stat("endurance", 1)
		H.change_stat("constitution", 1) //to compensate for the permanent lack of armor
		H.dna.species.soundpack_m = new /datum/voicepack/male/evil()
	else if(should_wear_femme_clothes(H))
		armor = /obj/item/clothing/suit/roguetown/armor/basiceast/captainrobe
		shirt = /obj/item/clothing/suit/roguetown/armor/skin_armor/easttats
		shoes = /obj/item/clothing/shoes/roguetown/armor/rumaclan
