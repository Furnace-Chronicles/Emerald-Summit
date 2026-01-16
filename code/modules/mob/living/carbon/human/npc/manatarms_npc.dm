// Base NPC man-at-arms type
/mob/living/carbon/human/species/npc/manatarms
	name = "man-at-arms"
	race = /datum/species/human/northern
	gender = MALE
	bodyparts = list(/obj/item/bodypart/chest, /obj/item/bodypart/head, /obj/item/bodypart/l_arm,
					/obj/item/bodypart/r_arm, /obj/item/bodypart/r_leg, /obj/item/bodypart/l_leg)
	faction = list("Station")
	ambushable = FALSE

	base_intents = list(INTENT_HELP, INTENT_DISARM, INTENT_GRAB, INTENT_HARM)
	a_intent = INTENT_HELP
	possible_mmb_intents = list(INTENT_STEAL, INTENT_JUMP, INTENT_KICK, INTENT_BITE)
	possible_rmb_intents = list(/datum/rmb_intent/feint, /datum/rmb_intent/aimed, /datum/rmb_intent/strong, /datum/rmb_intent/weak, /datum/rmb_intent/swift, /datum/rmb_intent/riposte)
	aggressive = 1
	mode = NPC_AI_IDLE
	wander = FALSE
	cmode_music = FALSE

	var/manatarms_outfit = /datum/outfit/job/roguetown/manorguard/footsman/npc

/mob/living/carbon/human/species/npc/manatarms/Initialize()
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(after_creation)), 1 SECONDS)

/mob/living/carbon/human/species/npc/manatarms/after_creation()
	..()

	ADD_TRAIT(src, TRAIT_GUARDSMAN, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_STEELHEARTED, TRAIT_GENERIC)

	possible_rmb_intents = list(/datum/rmb_intent/feint,\
	/datum/rmb_intent/aimed,\
	/datum/rmb_intent/strong,\
	/datum/rmb_intent/swift,\
	/datum/rmb_intent/riposte,\
	/datum/rmb_intent/weak)
	swap_rmb_intent(num=1)

	if(manatarms_outfit)
		var/datum/outfit/O = new manatarms_outfit
		if(O)
			equipOutfit(O)

	update_hair()
	update_body()
	update_body_parts()

	var/obj/item/weapon = get_item_by_slot(SLOT_BELT_R)
	var/obj/item/offhand = get_item_by_slot(SLOT_BACK_L)

	if(weapon)
		put_in_hands(weapon, forced = TRUE)
	if(offhand)
		put_in_hands(offhand, forced = TRUE)

// Footsman man-at-arms NPC
/mob/living/carbon/human/species/npc/manatarms/footsman
	name = "footman"
	manatarms_outfit = /datum/outfit/job/roguetown/manorguard/footsman/npc

/datum/outfit/job/roguetown/manorguard/footsman/npc/pre_equip(mob/living/carbon/human/H)
	H.verbs |= /mob/proc/haltyell

	H.STASTR = 12
	H.STAINT = 11
	H.STACON = 11
	H.STAEND = 11
	H.STASPD = 10
	H.STAPER = 10

	H.adjust_skillrank(/datum/skill/combat/polearms, 4, TRUE)
	H.adjust_skillrank(/datum/skill/combat/swords, 4, TRUE)
	H.adjust_skillrank(/datum/skill/combat/maces, 4, TRUE)
	H.adjust_skillrank(/datum/skill/combat/axes, 4, TRUE)
	H.adjust_skillrank(/datum/skill/combat/knives, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/whipsflails, 2, TRUE)
	H.adjust_skillrank(/datum/skill/combat/slings, 1, TRUE)
	H.adjust_skillrank(/datum/skill/combat/shields, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/wrestling, 4, TRUE)
	H.adjust_skillrank(/datum/skill/combat/unarmed, 4, TRUE)
	H.adjust_skillrank(/datum/skill/misc/climbing, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/sneaking, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/reading, 1, TRUE)
	H.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/riding, 1, TRUE)
	H.adjust_skillrank(/datum/skill/misc/tracking, 1, TRUE)

	ADD_TRAIT(H, TRAIT_MEDIUMARMOR, TRAIT_GENERIC)

	// Default to warhammer and shield
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/lord
	armor = /obj/item/clothing/suit/roguetown/armor/plate/scale
	pants = /obj/item/clothing/under/roguetown/chainlegs
	neck = /obj/item/clothing/neck/roguetown/gorget
	cloak = /obj/item/clothing/cloak/stabard/surcoat/guard
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	beltl = /obj/item/rogueweapon/mace/cudgel
	belt = /obj/item/storage/belt/rogue/leather/black
	backr = /obj/item/storage/backpack/rogue/satchel/black

	beltr = /obj/item/rogueweapon/mace/warhammer
	backl = /obj/item/rogueweapon/shield/iron
	head = /obj/item/clothing/head/roguetown/helmet

	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1,
		/obj/item/rope/chain = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
	)

// Skirmisher
/mob/living/carbon/human/species/npc/manatarms/skirmisher
	name = "skirmisher"
	manatarms_outfit = /datum/outfit/job/roguetown/manorguard/skirmisher/npc

/datum/outfit/job/roguetown/manorguard/skirmisher/npc/pre_equip(mob/living/carbon/human/H)
	H.verbs |= /mob/proc/haltyell

	H.STASTR = 10
	H.STAINT = 11
	H.STACON = 10
	H.STAEND = 11
	H.STASPD = 12
	H.STAPER = 12

	H.adjust_skillrank(/datum/skill/combat/crossbows, 4, TRUE)
	H.adjust_skillrank(/datum/skill/combat/bows, 4, TRUE)
	H.adjust_skillrank(/datum/skill/combat/knives, 4, TRUE)
	H.adjust_skillrank(/datum/skill/combat/slings, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/swords, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/maces, 2, TRUE)
	H.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/unarmed, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/climbing, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/sneaking, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/reading, 1, TRUE)
	H.adjust_skillrank(/datum/skill/misc/athletics, 4, TRUE)
	H.adjust_skillrank(/datum/skill/misc/riding, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/tracking, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/swimming, 2, TRUE)

	ADD_TRAIT(H, TRAIT_DODGEEXPERT, TRAIT_GENERIC)

	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/light
	armor = /obj/item/clothing/suit/roguetown/armor/leather/studded
	pants = /obj/item/clothing/under/roguetown/trou/leather
	cloak = /obj/item/clothing/cloak/stabard/surcoat/guard
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	beltl = /obj/item/rogueweapon/mace/cudgel
	belt = /obj/item/storage/belt/rogue/leather/black
	backr = /obj/item/storage/backpack/rogue/satchel/black

	beltr = /obj/item/quiver/bolts
	beltl = /obj/item/rogueweapon/huntingknife/idagger/steel/special
	head = /obj/item/clothing/head/roguetown/helmet

	backpack_contents = list(
		/obj/item/rope/chain = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
	)
