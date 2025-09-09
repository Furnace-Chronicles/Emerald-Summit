/datum/advclass/mercenary/kashira //shitcode approved by free
	name = "Kashira"
	tutorial = "You are one of the finer examples of swordsmanship stemming from Kazengun. A singular representative of the Ruma Clan, and generally a respected leader."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = NON_DWARVEN_RACE_TYPES
	outfit = /datum/outfit/job/roguetown/mercenary/kashira
	category_tags = list(CTAG_MERCENARY)
	traits_applied = list(TRAIT_OUTLANDER)
	cmode_music = 'sound/music/combat_kazengite.ogg'
	maximum_possible_slots = 1

/datum/outfit/job/roguetown/mercenary/kashira/pre_equip(mob/living/carbon/human/H)
	..()
	armor = /obj/item/clothing/suit/roguetown/armor/basiceast/captainrobe
	shirt = /obj/item/clothing/suit/roguetown/armor/skin_armor/easttats
	cloak = /obj/item/clothing/cloak/eastcloak1
	shoes = /obj/item/clothing/shoes/roguetown/armor/rumaclan
	gloves = /obj/item/clothing/gloves/roguetown/eastgloves2
	pants = /obj/item/clothing/under/roguetown/trou/eastpants1
	belt = /obj/item/storage/belt/rogue/leather
	beltr = /obj/item/rogueweapon/sword/sabre/mulyeog/rumacaptain
	beltl = /obj/item/scabbard/rumacaptain
	backr = /obj/item/storage/backpack/rogue/satchel
	backpack_contents = list(/obj/item/roguekey/mercenary, /obj/item/flashlight/flare/torch/lantern)
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
	H.change_stat("strength", 2) 
	H.change_stat("endurance", 3)
	H.change_stat("constitution", 3)
	H.change_stat("perception", 1)
	H.change_stat("speed", -1)
	H.adjust_blindness(-3)
	ADD_TRAIT(H, TRAIT_STEELHEARTED, TRAIT_GENERIC)	
	ADD_TRAIT(H, TRAIT_CRITICAL_RESISTANCE, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_NOPAINSTUN, TRAIT_GENERIC) //i swear this isn't as good as it sounds
	H.grant_language(/datum/language/kazengunese)
