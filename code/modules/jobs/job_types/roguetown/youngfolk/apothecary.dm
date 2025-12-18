/datum/job/roguetown/apothecary
	title = "Apothecary"
	flag = APOTHECARY
	department_flag = YOUNGFOLK
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	allowed_races = RACES_ALL_KINDS
	allowed_ages = list(AGE_ADULT, AGE_MIDDLEAGED)
	tutorial = "Working under the tutelage of the court physician, you still remain a mere apprentice in the medical arts. Woe is the one who has to suffer your hand holding the scalpel when your master is out."
	outfit = /datum/outfit/job/apothecary
	cmode_music = 'sound/music/combat_physician.ogg'
	display_order = JDO_APOTHECARY
	give_bank_account = 30
	min_pq = 5
	max_pq = null
	round_contrib_points = 2
	social_rank = SOCIAL_RANK_YEOMAN

	advclass_cat_rolls = list(CTAG_APOTH = 2)
	job_traits = list(TRAIT_NOSTINK, TRAIT_EMPATH)
	job_subclasses = list(
		/datum/advclass/apothecary
	)

/datum/advclass/apothecary
	name = "Apothecary"
	tutorial = "Working under the tutelage of the court physician, you still remain a mere apprentice in the medical arts. \
	Woe is the one who has to suffer your hand holding the scalpel when your master is out."
	outfit = /datum/outfit/job/apothecary/basic
	category_tags = list(CTAG_APOTH)

	subclass_stats = list(
		STATKEY_INT = 3,
		STATKEY_PER = 2,
	)

	subclass_skills = list(
		/datum/skill/combat/knives = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/polearms = SKILL_LEVEL_NOVICE,
		/datum/skill/combat/wrestling = SKILL_LEVEL_NOVICE,
		/datum/skill/craft/crafting = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/athletics = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/reading = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/medicine = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/sewing = SKILL_LEVEL_APPRENTICE,
		/datum/skill/craft/alchemy = SKILL_LEVEL_EXPERT,
		/datum/skill/labor/farming = SKILL_LEVEL_APPRENTICE,
	)

/datum/outfit/job/apothecary/basic/pre_equip(mob/living/carbon/human/H)
	..()
	H.adjust_blindness(-3)
	head = /obj/item/clothing/head/roguetown/roguehood/black
	pants = /obj/item/clothing/under/roguetown/trou/apothecary
	shirt = /obj/item/clothing/suit/roguetown/shirt/apothshirt
	armor = /obj/item/clothing/suit/roguetown/shirt/robe/black
	belt = /obj/item/storage/belt/rogue/leather/rope
	neck = /obj/item/storage/belt/rogue/pouch/coins/mid
	beltl = /obj/item/storage/belt/rogue/surgery_bag/full/physician
	beltr = /obj/item/roguekey/physician
	id = /obj/item/scomstone/bad
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	backr = /obj/item/storage/backpack/rogue/satchel
	backpack_contents = list(
		/obj/item/natural/worms/leech/cheele = 1,
		/obj/item/recipe_book/alchemy = 1,
	)

	if(H.mind)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/diagnose/secular)
		if(H.patron?.type == /datum/patron/divine/pestra)
			backpack_contents += /obj/item/clothing/mask/rogue/facemask/steel/pestra_beakmask
		else
			backpack_contents += /obj/item/clothing/mask/rogue/physician
