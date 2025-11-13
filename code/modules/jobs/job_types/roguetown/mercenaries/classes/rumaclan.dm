/datum/advclass/mercenary/rumaclan
	name = "Ruma Clan Kyodai"
	tutorial = "A band of foreign Kazengites. The Ruma Clan isn't an organized group of soldiers - rather a loose collection of fighters, with strange tattoos that act as armor."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = NON_DWARVEN_NON_GOLEM_RACE_TYPES //no dwarf sprites
	outfit = /datum/outfit/job/roguetown/mercenary/rumaclan
	subclass_languages = list(/datum/language/kazengunese)
	class_select_category = CLASS_CAT_KAZENGUN
	category_tags = list(CTAG_MERCENARY)
	traits_applied = list(TRAIT_CRITICAL_RESISTANCE, TRAIT_HARDDISMEMBER, TRAIT_NOPAINSTUN)
	cmode_music = 'sound/music/combat_kazengite.ogg'
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
	extra_context = "This subclass is race-limited from: Dwarves."

/datum/outfit/job/roguetown/mercenary/rumaclan/pre_equip(mob/living/carbon/human/H)
	..()
	to_chat(H, span_warning("You are relatively versed in the art of \"swinging a sword until enemy death.\" - You would gladly take up most jobs for money, or a chance to cut loose."))
	head = /obj/item/clothing/head/roguetown/mentorhat
	belt = /obj/item/storage/belt/rogue/leather
	beltr = /obj/item/rogueweapon/scabbard/sword/kazengun/steel
	beltl = /obj/item/rogueweapon/sword/sabre/mulyeog/rumahench
	armor = /obj/item/clothing/suit/roguetown/shirt/undershirt/eastshirt2
	cloak = /obj/item/clothing/cloak/eastcloak1
	shirt = /obj/item/clothing/suit/roguetown/armor/skin_armor/easttats
	pants = /obj/item/clothing/under/roguetown/heavy_leather_pants/eastpants2
	shoes = /obj/item/clothing/shoes/roguetown/armor/rumaclan
	gloves = /obj/item/clothing/gloves/roguetown/eastgloves2
	backr = /obj/item/storage/backpack/rogue/satchel
	backpack_contents = list(
		/obj/item/roguekey/mercenary,
		/obj/item/flashlight/flare/torch/lantern,
		)

	change_origin(H, /datum/virtue/origin/kazengun)

/datum/advclass/mercenary/rumaclan/ishu
	name = "Ruma Clan Ishu"
	tutorial = "A band of foreign Kazengites. The Ruma Clan isn't an organized group of soldiers - rather a loose collection of fighters, with strange tattoos that act as armor."
	outfit = /datum/outfit/job/roguetown/mercenary/rumaclan_ishu
	subclass_stats = list(
		STATKEY_SPD = 4,
		STATKEY_PER = 2,
		STATKEY_END = 2,
		STATKEY_STR = -1,
		STATKEY_CON = -1
	)
	subclass_skills = list(
		/datum/skill/combat/bows = SKILL_LEVEL_MASTER,
		/datum/skill/combat/knives = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/athletics = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/tracking = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/sneaking = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/climbing = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/unarmed = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/wrestling = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/swimming = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/reading = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/craft/carpentry = SKILL_LEVEL_APPRENTICE,
	)

/datum/outfit/job/roguetown/mercenary/rumaclan_ishu/pre_equip(mob/living/carbon/human/H)
	..()
	H.set_blindness(0)
	to_chat(H, span_warning("You are an archer. Pretty good in the art of \"pelting until enemy death.\" - You would gladly take up most jobs for money, or a chance to shoot loose."))
	beltr = /obj/item/quiver/arrows
	head = /obj/item/clothing/head/roguetown/roguehood/shalal/hijab/kazengunese
	beltl = /obj/item/flashlight/flare/torch/lantern
	armor = /obj/item/clothing/suit/roguetown/shirt/undershirt/eastshirt1
	shirt = /obj/item/clothing/suit/roguetown/armor/skin_armor/easttats
	pants = /obj/item/clothing/under/roguetown/heavy_leather_pants/eastpants2
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	gloves = /obj/item/clothing/gloves/roguetown/eastgloves2
	backl = /obj/item/gun/ballistic/revolver/grenadelauncher/bow/recurve
	backr = /obj/item/storage/backpack/rogue/satchel
	backpack_contents = list(
		/obj/item/roguekey/mercenary,
		/obj/item/storage/belt/rogue/pouch/coins/poor,
		/obj/item/rogueweapon/huntingknife/idagger/steel/kazengun,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

	var/belts = list("Shurikens","Smokebombs")
	var/belt_choice = input("Choose your belt.", "BELT YOURSELF") as anything in belts
	switch(belt_choice)
		if("Shurikens")
			belt = /obj/item/storage/belt/rogue/leather/knifebelt/black/kazengun
		if("Smokebombs")
			belt = /obj/item/storage/belt/rogue/leather/smokebelt/black

	change_origin(H, /datum/virtue/origin/kazengun)
