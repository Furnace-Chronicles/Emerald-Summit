GLOBAL_LIST_INIT(zizoconstruct_aggro, world.file2list("strings/rt/zconstructaggrolines.txt"))

/mob/living/carbon/human/species/construct/metal/zizoconstruct

	race = /datum/species/golem/metal
	name_override = "Bronze Golem"
	desc = "A bio-mechanical Golem given life by dubious magics. This one is made almost entirely of bronze. It seems poorly made."
	faction = list("dundead")
	var/zc_outfit = /datum/outfit/job/human/species/construct/metal/zizoconstruct
	ambushable = FALSE
	mode = NPC_AI_IDLE
	wander = FALSE
	cmode = 1
	setparrytime = 30
	a_intent = INTENT_HELP
	d_intent = INTENT_PARRY //knocks your weapon away with with their big scary metal arms
	possible_mmb_intents = list(INTENT_BITE, INTENT_JUMP, INTENT_KICK, INTENT_STEAL) //intents given incase of player controlled
	possible_rmb_intents = list(/datum/rmb_intent/feint, /datum/rmb_intent/aimed, /datum/rmb_intent/strong, /datum/rmb_intent/weak)
	resize = 1.2

/mob/living/carbon/human/species/construct/metal/zizoconstruct/ambush
	aggressive=1
	wander = TRUE

/mob/living/carbon/human/species/construct/metal/zizoconstruct/retaliate(mob/living/L)
	.=..()
	if(prob(5))
		say(pick(GLOB.zizoconstruct_aggro))
		pointed(target)

/mob/living/carbon/human/species/construct/metal/zizoconstruct/should_target(mob/living/L)
	if(L.stat != CONSCIOUS)
		return FALSE
	. = ..()

/mob/living/carbon/human/species/construct/metal/zizoconstruct/Initialize()
	. = ..()
	cut_overlays()
	spawn(10)
		after_creation()

/mob/living/carbon/human/species/construct/metal/zizoconstruct/after_creation()
	..()
	job = "Zizo Golem"
	ADD_TRAIT(src, TRAIT_NOMOOD, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_INFINITE_ENERGY, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_NOPAIN, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_TOXIMMUNE, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_CIVILIZEDBARBARIAN, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_CRITICAL_RESISTANCE, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_MEDIUMARMOR, TRAIT_GENERIC)
	gender = pick(MALE, FEMALE)
	regenerate_icons()
	skin_tone = "e2a670"

	if(gender == FEMALE)
		real_name = pick("Bronze Golem")
	else
		real_name = pick("Bronze Golem")
	update_body()
	if(zc_outfit)
		var/datum/outfit/OU = new zc_outfit
		if(OU)
			equipOutfit(OU)

/datum/outfit/job/human/species/construct/metal/zizoconstruct/pre_equip(mob/living/carbon/human/H)
	..()
	shirt = /obj/item/clothing/suit/roguetown/armor/skin_armor/zizoconstructarmor
	gloves = /obj/item/clothing/gloves/roguetown/knuckles/bronze/zizoconstruct

	H.STASTR = 20
	H.STASPD = 8
	H.STACON = 20
	H.STAEND = 20
	H.STAPER = 8
	H.STAINT = 1
	H.adjust_skillrank(/datum/skill/combat/unarmed, 5, TRUE)
	H.adjust_skillrank(/datum/skill/combat/wrestling, 5, TRUE)
	H.adjust_skillrank(/datum/skill/misc/swimming, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/climbing, 2, TRUE)

/obj/item/clothing/suit/roguetown/armor/skin_armor/zizoconstructarmor //ww armor but for golem
	slot_flags = SHIRT_LAYER
	name = "golem plating"
	desc = ""
	icon_state = null
	body_parts_covered = FULL_BODY
	armor = ARMOR_ZIZOCONCSTRUCT
	prevent_crits = list(BCLASS_CUT, BCLASS_CHOP, BCLASS_STAB, BCLASS_BLUNT, BCLASS_TWIST)
	blocksound = PLATEHIT
	blade_dulling = DULLING_BASHCHOP
	sewrepair = FALSE
	max_integrity = 600
	item_flags = DROPDEL
