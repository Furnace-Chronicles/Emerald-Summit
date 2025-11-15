/datum/job/roguetown/chaplain
	title = "Court Chaplain"
	flag = CHAPLAIN
	department_flag = COURTIERS
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	allowed_races = RACES_SECOND_CLASS_NO_GOLEM
	disallowed_races = list(
		/datum/species/lamia,
		/datum/species/harpy,
	)
	allowed_patrons = ALL_DIVINE_PATRONS
	allowed_sexes = list(MALE, FEMALE)
	display_order = JDO_CHAPLAIN
	tutorial = "You've earned your place as Court Chaplain, whether by faith, family connections, or sheer luck. Your job? To guide the spiritual health of the Duke and their court by offering prayers, advice and blessings. You'll lead mediations between the crown and the clergy and maybe even wield some political influence behind the scenes. You may not be a knight or a noble, but your words carry weight, and your position at the table ensures you're always in the loop of the Duchy's most important decisions."
	whitelist_req = FALSE
	outfit = /datum/outfit/job/roguetown/chaplain
	advclass_cat_rolls = list(CTAG_CHAPLAIN = 2)


	give_bank_account = 40
	min_pq = 15
	max_pq = null
	round_contrib_points = 2
	cmode_music = 'sound/music/combat_holy.ogg'
	social_rank = SOCIAL_RANK_NOBLE

	//No nobility for you, being a member of the clergy means you gave UP your nobility. It says this in many of the church tutorial texts.
	virtue_restrictions = list(
		/datum/virtue/utility/noble,
		/datum/virtue/utility/blueblooded,
		/datum/virtue/combat/hollow_life,
		/datum/virtue/combat/vampire,
	)

	job_traits = list(TRAIT_RITUALIST, TRAIT_CLERGY, TRAIT_CHOSEN)
	job_subclasses = list(
		/datum/advclass/chaplain
	)

/datum/advclass/chaplain
	name = "Court Chaplain"
	tutorial = "You've earned your place as Court Chaplain, whether by faith, family connections, or sheer luck. Your job? To guide the spiritual health of the Duke and their court by offering prayers, advice and blessings. You'll lead mediations between the crown and the clergy and maybe even wield some political influence behind the scenes. You may not be a knight or a noble, but your words carry weight, and your position at the table ensures you're always in the loop of the Duchy's most important decisions."
	outfit = /datum/outfit/job/roguetown/chaplain/basic
	category_tags = list(CTAG_CHAPLAIN)
	subclass_stats = list(
		STATKEY_INT = 2,
		STATKEY_END = 1,
		STATKEY_STR = -1,
	)

	subclass_skills = list(
		/datum/skill/combat/wrestling = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/unarmed = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/polearms = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/reading = SKILL_LEVEL_LEGENDARY,
		/datum/skill/misc/medicine = SKILL_LEVEL_EXPERT,
		/datum/skill/craft/cooking = SKILL_LEVEL_APPRENTICE,
		/datum/skill/craft/crafting = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/sewing = SKILL_LEVEL_APPRENTICE,
		/datum/skill/labor/farming = SKILL_LEVEL_APPRENTICE,
		/datum/skill/magic/holy = SKILL_LEVEL_EXPERT,
		/datum/skill/craft/alchemy = SKILL_LEVEL_JOURNEYMAN,
	)

/datum/outfit/job/roguetown/chaplain
	job_bitflag = BITFLAG_ROYALTY
	allowed_patrons = list(/datum/patron/divine/astrata)

/datum/outfit/job/roguetown/chaplain/basic/pre_equip(mob/living/carbon/human/H)
	..()
	neck = /obj/item/clothing/neck/roguetown/psicross/astrata
	head = /obj/item/clothing/head/roguetown/priesthat
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/priest
	pants = /obj/item/clothing/under/roguetown/tights/black
	shoes = /obj/item/clothing/shoes/roguetown/shortboots
	beltl = /obj/item/storage/keyring/councillor
	belt = /obj/item/storage/belt/rogue/leather/rope
	beltr = /obj/item/storage/belt/rogue/pouch/coins/rich
	cloak = /obj/item/clothing/cloak/chasuble
	backl = /obj/item/storage/backpack/rogue/satchel
	backpack_contents = list(
		/obj/item/needle/pestra = 1,
		/obj/item/ritechalk = 1,
		/obj/item/rogueweapon/huntingknife/idagger/steel = 1
	)
