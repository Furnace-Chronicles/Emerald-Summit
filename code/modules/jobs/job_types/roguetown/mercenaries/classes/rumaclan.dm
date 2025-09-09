/datum/advclass/mercenary/rumaclan/kyodai
	name = "Kyodai"
	tutorial = "A band of foreign Kazengites. The Ruma Clan isn't an organized group of soldiers - rather a loose collection of fighters, with strange tattoos that act as armor."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = NON_DWARVEN_RACE_TYPES //no dwarf sprites
	outfit = /datum/outfit/job/roguetown/mercenary/rumaclan
	category_tags = list(CTAG_MERCENARY)
	class_select_category = CLASS_CAT_KAZENGUN
	cmode_music = 'sound/music/combat_kazengite.ogg'

	traits_applied = list(TRAIT_CRITICAL_RESISTANCE, TRAIT_NOPAINSTUN)
	subclass_stats = list(
		STATKEY_CON = 3,
		STATKEY_END = 3,
		STATKEY_STR = 2,
		STATKEY_PER = 1,
		STATKEY_SPD = -1
	)
	extra_context = "This subclass is race-limited from: Dwarves."

/datum/outfit/job/roguetown/mercenary/rumaclan/kyodai/pre_equip(mob/living/carbon/human/H)
	..()
	to_chat(H, span_warning("You are relatively versed in the art of \"swinging a sword until enemy death.\" - You would gladly take up most jobs for money, or a chance to cut loose."))
	belt = /obj/item/storage/belt/rogue/leather
	beltr = /obj/item/rogueweapon/scabbard/sword/kazengun/steel
	beltl = /obj/item/rogueweapon/sword/sabre/mulyeog/rumahench
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/eastshirt2
	cloak = /obj/item/clothing/cloak/eastcloak1
	armor = /obj/item/clothing/suit/roguetown/armor/skin_armor/easttats
	pants = /obj/item/clothing/under/roguetown/heavy_leather_pants/eastpants2
	shoes = /obj/item/clothing/shoes/roguetown/armor/rumaclan
	gloves = /obj/item/clothing/gloves/roguetown/eastgloves2
	backr = /obj/item/storage/backpack/rogue/satchel
	backpack_contents = list(
		/obj/item/roguekey/mercenary,
		/obj/item/flashlight/flare/torch/lantern,
		)
	H.adjust_skillrank(/datum/skill/misc/swimming, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/climbing, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/sneaking, 2, TRUE)
	H.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/unarmed, 2, TRUE)
	H.adjust_skillrank(/datum/skill/combat/swords, 4, TRUE)
	H.adjust_skillrank(/datum/skill/combat/shields, 4, TRUE)
	H.adjust_skillrank(/datum/skill/combat/knives, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/reading, 1, TRUE)
	H.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
	H.grant_language(/datum/language/kazengunese)

/datum/advclass/mercenary/rumaclan/ishu
	name = "Ishu"
	tutorial = "A band of foreign Kazengites. The Ruma Clan isn't an organized group of soldiers - rather a loose collection of fighters, with strange tattoos that act as armor."
	outfit = /datum/outfit/job/roguetown/mercenary/rumaclan/ishu
	traits_applied = list(TRAIT_CRITICAL_RESISTANCE, TRAIT_NOPAINSTUN)
	subclass_stats = list(
		STATKEY_SPD = 4,
		STATKEY_PER = 2,
		STATKEY_END = 2,
		STATKEY_STR = -1,
		STATKEY_CON = -1
	)

/datum/outfit/job/roguetown/mercenary/rumaclan/ishu/pre_equip(mob/living/carbon/human/H)
	..()
	H.set_blindness(0)
	to_chat(H, span_warning("You are an archer. Pretty good in the art of \"pelting until enemy death.\" - You would gladly take up most jobs for money, or a chance to shoot loose."))
	belt = /obj/item/storage/belt/rogue/leather
	beltr = /obj/item/quiver/arrows
	beltl = /obj/item/flashlight/flare/torch/lantern
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/eastshirt2
	cloak = /obj/item/clothing/cloak/eastcloak1
	armor = /obj/item/clothing/suit/roguetown/armor/skin_armor/easttats
	pants = /obj/item/clothing/under/roguetown/heavy_leather_pants/eastpants2
	shoes = /obj/item/clothing/shoes/roguetown/armor/rumaclan
	gloves = /obj/item/clothing/gloves/roguetown/eastgloves2
	backl = /obj/item/gun/ballistic/revolver/grenadelauncher/bow/recurve
	backr = /obj/item/storage/backpack/rogue/satchel
	backpack_contents = list(
		/obj/item/roguekey/mercenary,
		/obj/item/storage/belt/rogue/pouch/coins/poor,
		/obj/item/rogueweapon/huntingknife/idagger,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)
	H.adjust_skillrank(/datum/skill/combat/bows, 5, TRUE)
	H.adjust_skillrank(/datum/skill/combat/knives, 4, TRUE)
	H.adjust_skillrank(/datum/skill/misc/athletics, 4, TRUE)
	H.adjust_skillrank(/datum/skill/misc/tracking, 4, TRUE)
	H.adjust_skillrank(/datum/skill/misc/sneaking, 4, TRUE)
	H.adjust_skillrank(/datum/skill/misc/climbing, 4, TRUE)
	H.adjust_skillrank(/datum/skill/combat/unarmed, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/swimming, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/reading, 3, TRUE)
	H.adjust_skillrank(/datum/skill/craft/carpentry, 2, TRUE)
	H.grant_language(/datum/language/kazengunese)
