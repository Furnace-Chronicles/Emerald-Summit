/datum/job/roguetown/gatemaster
	title = "Gatemaster"
	flag = GATEMASTER
	department_flag = GARRISON
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_FEARED_UP
	disallowed_races = list(
		/datum/species/lamia,
	)
	allowed_patrons = ALL_DIVINE_PATRONS
	tutorial = "Tales speak of the Gatemaster's legendary ability to stand still at a gate and ask people questions."
	display_order = JDO_GATEMASTER

	outfit = /datum/outfit/job/gatemaster
	advclass_cat_rolls = list(CTAG_GATEMASTER = 20)
	give_bank_account = 3
	min_pq = 4
	max_pq = null
	round_contrib_points = 3
	social_rank = SOCIAL_RANK_YEOMAN

	virtue_restrictions = list(
		/datum/virtue/utility/failed_squire,
	)
	cmode_music = 'sound/music/combat_guard.ogg'

	job_traits = list(TRAIT_GUARDSMAN, TRAIT_STEELHEARTED, TRAIT_MEDIUMARMOR)
	job_subclasses = list(
		/datum/advclass/gatemaster
	)

/datum/job/roguetown/gatemaster/after_spawn(mob/living/L, mob/M, latejoin = TRUE)
	..()
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		H.advsetup = 1
		H.invisibility = INVISIBILITY_MAXIMUM
		H.become_blind("advsetup")

/datum/advclass/gatemaster
	name = "Gatemaster"
	tutorial = "Tales speak of the Gatemaster's legendary ability to stand still at a gate and ask people questions."
	outfit = /datum/outfit/job/gatemaster
	category_tags = list(CTAG_GATEMASTER)
	subclass_stats = list(
		STATKEY_STR = 2,
		STATKEY_INT = 1,
		STATKEY_CON = 1,
		STATKEY_PER = 2,
	)

	subclass_skills = list(
		/datum/skill/combat/polearms = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/swords = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/knives = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/maces = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/crossbows = SKILL_LEVEL_MASTER,
		/datum/skill/combat/bows = SKILL_LEVEL_NOVICE,
		/datum/skill/combat/slings = SKILL_LEVEL_NOVICE,
		/datum/skill/combat/wrestling = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/unarmed = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/craft/traps = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/reading = SKILL_LEVEL_EXPERT, //Paperwork RP
		/datum/skill/misc/athletics = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/craft/crafting = SKILL_LEVEL_NOVICE,
		/datum/skill/craft/carpentry = SKILL_LEVEL_JOURNEYMAN, //For fixing the door.
		/datum/skill/craft/engineering = SKILL_LEVEL_JOURNEYMAN, //lets them change stuff like the levers and gate
	)

/datum/outfit/job/gatemaster
	name = "Gatemaster"
	has_loadout = TRUE
	jobtype = /datum/job/roguetown/gatemaster
	job_bitflag = BITFLAG_GARRISON

/datum/outfit/job/gatemaster/pre_equip(mob/living/carbon/human/H)
	..()
	head = /obj/item/clothing/head/roguetown/roguehood/red
	neck = /obj/item/clothing/neck/roguetown/gorget
	cloak = /obj/item/clothing/cloak/stabard/surcoat/guard
	armor = /obj/item/clothing/suit/roguetown/armor/chainmail
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
	pants = /obj/item/clothing/under/roguetown/chainlegs
	gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots
	belt = /obj/item/storage/belt/rogue/leather/black
	beltl = /obj/item/storage/keyring/guardcastle
	beltr = /obj/item/quiver/bolts
	backr = /obj/item/storage/backpack/rogue/satchel/black
	backl = /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow
	id = /obj/item/scomstone/bad/garrison
	backpack_contents = list(/obj/item/rope/chain = 1)
