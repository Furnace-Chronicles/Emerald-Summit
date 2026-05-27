// Magi 2 Court Magician — clone of /datum/job/roguetown/magician that spawns the player
// with the Pyromancy aspect already bound, no in-round spell learning required.
// Lives as a separate lobby slot so the existing Court Magician is untouched.

#define CTAG_COURTMAGE_MAGI2 "CAT_COURTMAGE_MAGI2"

/datum/job/roguetown/magician_magi2
	title = "Court Magician (Magi 2 Pilot)"
	flag = WIZARD
	department_flag = COURTIERS
	selection_color = JCOLOR_COURTIER
	faction = "Station"
	total_positions = 1
	spawn_positions = 1

	allowed_races = RACES_SECOND_CLASS_UP
	allowed_sexes = list(MALE, FEMALE)
	display_order = JDO_MAGICIAN + 1
	tutorial = "Pilot Court Magician using the Magi 2 aspect system from Azure-Peak PR #6406. \
		You spawn with the Pyromancy aspect already bound — no spell learning step. \
		Cast Spitfire, Fireball, Fire Blast, and Fire Curtain from your action bar. \
		The classic Court Magician's free-pick spell pool is replaced by the fixed aspect spell set."
	// Job-level outfit is the bare parent (no gear vars set) — gear lives in the advclass
	// outfit. Setting both to the magi2 variant would apply the gear twice.
	outfit = /datum/outfit/job/magician
	whitelist_req = TRUE
	give_bank_account = 47
	min_pq = 15
	max_pq = null
	round_contrib_points = 2
	cmode_music = 'sound/music/combat_bandit_mage.ogg'
	advclass_cat_rolls = list(CTAG_COURTMAGE_MAGI2 = 1)
	social_rank = SOCIAL_RANK_NOBLE

	vice_restrictions = list(/datum/charflaw/mute)

	job_traits = list(TRAIT_NOBLE, TRAIT_MAGEARMOR, TRAIT_ARCYNE_T4, TRAIT_SEEPRICES, TRAIT_INTELLECTUAL, TRAIT_TALENTED_ALCHEMIST)
	job_subclasses = list(/datum/advclass/courtmage_magi2)

/datum/advclass/courtmage_magi2
	name = "Court Magician (Magi 2 Pilot)"
	tutorial = "Pyromancy aspect auto-bound on spawn. Pilot of aspect-based magic."
	outfit = /datum/outfit/job/magician/basic/magi2
	category_tags = list(CTAG_COURTMAGE_MAGI2)

	subclass_stats = list(
		STATKEY_INT = 4,
		STATKEY_STR = -1,
		STATKEY_CON = -1,
	)

	// Aspect spells are auto-granted via the outfit; the player doesn't spend points.
	subclass_spellpoints = 0

	subclass_skills = list(
		/datum/skill/misc/reading = SKILL_LEVEL_LEGENDARY,
		/datum/skill/craft/alchemy = SKILL_LEVEL_MASTER,
		/datum/skill/magic/arcane = SKILL_LEVEL_MASTER,
		/datum/skill/misc/riding = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/polearms = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/swimming = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/climbing = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/athletics = SKILL_LEVEL_NOVICE,
		/datum/skill/combat/swords = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/knives = SKILL_LEVEL_APPRENTICE,
		/datum/skill/craft/crafting = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/medicine = SKILL_LEVEL_APPRENTICE,
	)

// Inherits all equipment from /datum/outfit/job/magician/basic — we just bind the
// Pyromancy aspect on top of the normal Court Magician gear.
/datum/outfit/job/magician/basic/magi2/pre_equip(mob/living/carbon/human/H)
	. = ..()
	if(H?.mind)
		var/datum/magic_aspect/pyromancy/A = new
		A.grant_spells(H.mind)
