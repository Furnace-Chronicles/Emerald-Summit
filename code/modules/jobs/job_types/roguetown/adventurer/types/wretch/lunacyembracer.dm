/datum/advclass/wretch/lunacyembracer
	name = "Lunacy Embracer"
	tutorial = "You have rejected and terrorized civilization in the name of nature. You run wild under the moon, a terror to the townsfolk and a champion of Dendor's wild domain."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	outfit = /datum/outfit/job/roguetown/wretch/lunacyembracer
	category_tags = list(CTAG_WRETCH)

	traits_applied = list(
		TRAIT_NUDIST,
		TRAIT_CRITICAL_RESISTANCE,
		TRAIT_NOPAIN,
		TRAIT_DODGEEXPERT,
		TRAIT_CIVILIZEDBARBARIAN,
		TRAIT_STRONGBITE,
		TRAIT_WOODWALKER,
		TRAIT_NASTY_EATER,
		TRAIT_ORGAN_EATER
		TRAIT_DARKVISION
		TRAIT_CALTROPIMMUNE,
		TRAIT_LONGSTRIDER,
		TRAIT_OUTDOORSMAN,
		TRAIT_WOODSMAN

	)
	subclass_stats = list(
		STATKEY_STR = 3,
		STATKEY_CON = 2,
		STATKEY_END = 2,
		STATKEY_SPD = 2,
		STATKEY_LCK = 2,
		STATKEY_INT = -2,
		STATKEY_PER = -2
	)

	subclass_skills = list(
		/datum/skill/combat/wrestling = SKILL_LEVEL_MASTER,
		/datum/skill/combat/unarmed = SKILL_LEVEL_MASTER,
		/datum/skill/misc/athletics = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/climbing = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/swimming = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/tracking = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/sneaking = SKILL_LEVEL_APPRENTICE
		/datum/skill/craft/crafting = SKILL_LEVEL_APPRENTICE,
		/datum/skill/labor/butchering = SKILL_LEVEL_NOVICE
		/datum/skill/labor/fishing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/magic/holy = SKILL_LEVEL_JOURNEYMAN,
	)

/datum/outfit/job/roguetown/wretch/lunacyembracer/pre_equip(mob/living/carbon/human/H)
	var/datum/devotion/C = new /datum/devotion(H, H.patron)
	C.grant_miracles(H, cleric_tier = CLERIC_T3, passive_gain = CLERIC_REGEN_MAJOR)

	H.cmode_music = 'sound/music/combat_berserker.ogg'
	to_chat(H, span_danger("You have abandoned your humanity to run wild under the moon. The call of nature fills your soul!"))
	wretch_select_bounty(H)
