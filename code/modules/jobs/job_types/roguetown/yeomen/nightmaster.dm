/datum/job/roguetown/niteman
	title = "Nightmaster"
	f_title = "Nightmistress"
	flag = NITEMASTER
	department_flag = YEOMEN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	allowed_races = RACES_ALL_KINDS
	tutorial = "You own the brothel in the city. You provide security to the nightmaidens and help them to find work-- when you're not being a trouble-making rake that others suffer to tolerate."
	allowed_sexes = list(MALE, FEMALE)
	outfit = /datum/outfit/job/roguetown/niteman
	display_order = JDO_NITEMASTER
	give_bank_account = 150
	min_pq = 1
	max_pq = null
	bypass_lastclass = TRUE
	round_contrib_points = 3

/datum/outfit/job/roguetown/niteman/pre_equip(mob/living/carbon/human/H)
	..()
	head = /obj/item/lockpick/goldpin/silver
	shoes = /obj/item/clothing/shoes/roguetown/boots
	belt = /obj/item/storage/belt/rogue/leather/black
	shirt = /obj/item/clothing/suit/roguetown/shirt/tunic/purple
	wrists = /obj/item/storage/keyring/nightman
	neck = /obj/item/storage/belt/rogue/pouch/coins/rich
	pants = /obj/item/clothing/under/roguetown/trou/leather
	beltl = /obj/item/rogueweapon/whip

	backl = /obj/item/storage/backpack/rogue/satchel
	backpack_contents = list(/obj/item/reagent_containers/food/snacks/grown/rogue/swampweeddry = 2, /obj/item/reagent_containers/powder/moondust = 2, /obj/item/reagent_containers/powder/spice = 1)
	H.grant_language(/datum/language/thievescant)
	ADD_TRAIT(H, TRAIT_GOODLOVER, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_SEEPRICES_SHITTY, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_NUTCRACKER, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_CICERONE, TRAIT_GENERIC)
	H.adjust_skillrank(/datum/skill/combat/wrestling, 4, TRUE)
	H.adjust_skillrank(/datum/skill/combat/unarmed, 4, TRUE)
	H.adjust_skillrank(/datum/skill/combat/whipsflails, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/reading, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/sneaking, 4, TRUE)
	H.adjust_skillrank(/datum/skill/misc/stealing, 4, TRUE)
	H.adjust_skillrank(/datum/skill/misc/lockpicking, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/climbing, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/medicine, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/riding, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/swimming, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/knives, 3, TRUE)
	H.change_stat("strength", 1)
	H.change_stat("intelligence", -1)
	H.change_stat("constitution", 1)
	H.change_stat("endurance", 2)

	if(should_wear_masc_clothes(H))
		armor = /obj/item/clothing/suit/roguetown/armor/leather/vest/sailor/nightman
		H.dna.species.soundpack_m = new /datum/voicepack/male/zeth()
	else if(should_wear_femme_clothes(H))
		armor = /obj/item/clothing/suit/roguetown/armor/armordress/alt

/obj/effect/proc_holder/spell/self/convertrole/prostitute
	name = "Hire Prostitute"
	new_role = "Nightswain"
	overlay_state = "recruit_servant"
	recruitment_faction = "Prostitute"
	recruitment_message = "Work for me, %RECRUIT."
	accept_message = "I will."
	refuse_message = "I refuse."
