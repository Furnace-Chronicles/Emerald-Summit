/datum/job/roguetown/jester
	title = "Jester"
	flag = JESTER
	department_flag = PEASANTS
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	allowed_races = RACES_ALL_KINDS
	disallowed_races = list(
		/datum/species/lamia,
	)
	allowed_ages = ALL_AGES_LIST
	tutorial = "The Grenzelhofts were known for their Jesters, wisemen with a tongue just as sharp as their wit. \
		You command a position of a fool, envious of the position your superiors have upon you. \
		Your cheap tricks and illusions of intelligence will only work for so long, \
		and someday you'll find yourself at the end of something sharper than you."
	outfit = /datum/outfit/job/jester
	display_order = JDO_JESTER
	give_bank_account = TRUE
	min_pq = -4 //silly jesters are funny so low PQ requirement
	max_pq = null
	round_contrib_points = 2
	social_rank = SOCIAL_RANK_NOBLE

/datum/outfit/job/jester/pre_equip(mob/living/carbon/human/H)
	..()
	shoes = /obj/item/clothing/shoes/roguetown/jester
	pants = /obj/item/clothing/under/roguetown/tights
	armor = /obj/item/clothing/suit/roguetown/shirt/jester
	belt = /obj/item/storage/belt/rogue/leather
	beltr = /obj/item/storage/keyring/servant
	beltl = /obj/item/storage/belt/rogue/pouch
	head = /obj/item/clothing/head/roguetown/jester
	neck = /obj/item/clothing/neck/roguetown/coif
	H.adjust_skillrank(/datum/skill/combat/knives, rand(1,4), TRUE)
	H.adjust_skillrank(/datum/skill/misc/reading, rand(0,1), TRUE) // might just be an illiterate fuck, more likely than not
	H.adjust_skillrank(/datum/skill/misc/sneaking, rand(1,6), TRUE)
	H.adjust_skillrank(/datum/skill/misc/stealing, rand(1,6), TRUE)
	H.adjust_skillrank(/datum/skill/misc/climbing, rand(2,6), TRUE)
	H.adjust_skillrank(/datum/skill/misc/athletics, rand(4,6), TRUE) //a showman like no other. you need to be fit to perform.
	H.adjust_skillrank(/datum/skill/misc/music, rand(1,6), TRUE)
	H.adjust_skillrank(/datum/skill/combat/unarmed, rand(1,5), TRUE) // is this a good idea? Probably not, but the idea of a master fighter jester with 20 str is too good to pass on, this can only go well
	H.adjust_skillrank(/datum/skill/combat/wrestling, rand(1,5), TRUE)
	H.adjust_skillrank(/datum/skill/misc/lockpicking, rand(1,4), TRUE)
	H.adjust_skillrank(/datum/skill/craft/cooking, rand(1,3), TRUE)
	H.STASTR = rand(1, 21)
	H.STAEND = rand(1, 21)
	H.STACON = rand(1, 21)
	H.STAINT = rand(1, 21)
	H.STAPER = rand(1, 21)
	H.STALUC = rand(1, 21)
	H.cmode_music = 'sound/music/combat_jester.ogg'
	if(H.mind)
		// Mime vs Jester. 
		// As a mute jester you cannot cast Tell Joke/Tragedy, so why even have them?
		if(HAS_TRAIT(H, TRAIT_PERMAMUTE)) // I considered adding a check for Xylix patron but in the off chance there's a mute non-xylix jester I don't want to fuck them over.
			H.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/conjure/mime_wall)
			H.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/conjure/mime_chair)
		else
			H.mind.AddSpell(new /obj/effect/proc_holder/spell/self/telljoke)
			H.mind.AddSpell(new /obj/effect/proc_holder/spell/self/telltragedy)
	H.verbs |= /mob/living/carbon/human/proc/ventriloquate
	H.verbs |= /mob/living/carbon/human/proc/ear_trick
	if(!istype(H.getorganslot(ORGAN_SLOT_TONGUE), /obj/item/organ/tongue/wild_tongue))
		H.internal_organs_slot[ORGAN_SLOT_TONGUE] = new /obj/item/organ/tongue/wild_tongue
	ADD_TRAIT(H, TRAIT_ZJUMP, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_LEAPER, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_NUTCRACKER, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_NOFALLDAMAGE1, TRAIT_GENERIC)
	if(prob(50))
		ADD_TRAIT(H, TRAIT_EMPATH, TRAIT_GENERIC) // Jester :3
	else
		ADD_TRAIT(H, TRAIT_STEELHEARTED, TRAIT_GENERIC) // Joker >:(

