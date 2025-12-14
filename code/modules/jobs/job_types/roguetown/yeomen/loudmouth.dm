/datum/job/roguetown/loudmouth
	title = "Loudmouth"
	tutorial = "Keeper of the Horn, Master of the Jabberline, and self-appointed Voice of Reason. From your desk in the SCOM atelier, you decide which words will thunder across the realm and which will die in the throats of petitioners who didn�t pay enough ratfeed. Nobles and cutpurses alike shuffle up to your counter, coins in hand, desperate for a moment in the golden glow of the broadcast horn. In your upstairs �studio,� you host debates, recite gossip, and spin tales that will ripple through every corner of town. After all, you hold the true power: the power to decide what all of the city hears... and how loudly. You work closely with the Archivist, though it's obvious which of you the people truly respect."
	flag = LOUDMOUTH
	department_flag = YEOMEN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	spells = list(/obj/effect/proc_holder/spell/targeted/touch/prestidigitation)
	allowed_races = RACES_MANMADE_UP
	allowed_ages = ALL_AGES_LIST
	social_rank = SOCIAL_RANK_YEOMAN

	outfit = /datum/outfit/job/loudmouth
	display_order = JDO_LOUDMOUTH
	give_bank_account = 15
	min_pq = 5 // Now has actual responsibility and is a key figure in town.
	max_pq = null
	round_contrib_points = 3

	job_traits = list(TRAIT_INTELLECTUAL, TRAIT_ARCYNE_T2, TRAIT_MAGEARMOR, TRAIT_SEEPRICES_SHITTY)

	advclass_cat_rolls = list(CTAG_LOUDMOUTH = 2)
	job_subclasses = list(
		/datum/advclass/loudmouth
	)

/datum/advclass/loudmouth
	name = "Loudmouth"
	tutorial = "Keeper of the Horn, Master of the Jabberline, and self-appointed Voice of Reason. From your desk in the SCOM atelier, you decide which words will thunder across the realm and which will die in the throats of petitioners who didn�t pay enough ratfeed. Nobles and cutpurses alike shuffle up to your counter, coins in hand, desperate for a moment in the golden glow of the broadcast horn. In your upstairs �studio,� you host debates, recite gossip, and spin tales that will ripple through every corner of town. After all, you hold the true power: the power to decide what all of the city hears... and how loudly. You work closely with the Archivist, though it's obvious which of you the people truly respect."
	outfit = /datum/outfit/job/loudmouth/basic
	category_tags = list(CTAG_LOUDMOUTH)

	subclass_languages = list(
		/datum/language/elvish,
		/datum/language/dwarvish,
		/datum/language/celestial,
		/datum/language/hellspeak,
		/datum/language/orcish,
		/datum/language/grenzelhoftian,
		/datum/language/otavan,
		/datum/language/etruscan,
		/datum/language/gronnic,
		/datum/language/kazengunese,
		/datum/language/draconic,
		/datum/language/aavnic, // All but beast, which is associated with werewolves.
	)

	subclass_stats = list(
		STATKEY_END = 3,
		STATKEY_INT = 3,
		STATKEY_SPD = 1
	)

	subclass_skills = list(
		/datum/skill/misc/reading = SKILL_LEVEL_LEGENDARY,
		/datum/skill/craft/alchemy = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/medicine = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/riding = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/wrestling = SKILL_LEVEL_NOVICE,
		/datum/skill/combat/unarmed = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/swimming = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/climbing = SKILL_LEVEL_NOVICE,
		/datum/skill/magic/arcane = SKILL_LEVEL_APPRENTICE,
	)

/datum/outfit/job/loudmouth/basic/pre_equip(mob/living/carbon/human/H)
	..()
	H.adjust_blindness(-3)
	if(should_wear_femme_clothes(H))
		pants = /obj/item/clothing/under/roguetown/tights/sailor //Booty shorts because I needed to replace the stockings with something.
	else
		pants = /obj/item/clothing/under/roguetown/tights/black
	shirt = /obj/item/clothing/suit/roguetown/shirt/tunic/black
	armor = /obj/item/clothing/suit/roguetown/shirt/dress/silkdress/loudmouth
	head = /obj/item/clothing/head/roguetown/loudmouth
	backr = /obj/item/storage/backpack/rogue/satchel
	shoes = /obj/item/clothing/shoes/roguetown/shortboots
	belt = /obj/item/storage/belt/rogue/leather/plaquesilver
	beltl = /obj/item/storage/keyring/archivist
	beltr = /obj/item/storage/belt/rogue/pouch/coins/mid
	id = /obj/item/scomstone
	backpack_contents = list(
		/obj/item/recipe_book/alchemy
	)

	if (H && H.mind)
		H.mind.adjust_spellpoints(6)
	if(H.age == AGE_OLD)
		H.change_stat("speed", -1)
		H.change_stat("intelligence", 1)
