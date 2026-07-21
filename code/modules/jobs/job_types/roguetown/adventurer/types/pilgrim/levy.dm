/datum/advclass/levy
	
	name = "Levy"
	tutorial = "Most crime in the City does not require a trained man at arms. Instead, a small group of townspeople help the Elder maintain order inside the city. You are one such member, subdue those who cause issue to bring them to the Elder for a scolding."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	outfit = /datum/outfit/job/levy
	category_tags = list(CTAG_TOWNER)

	subclass_social_rank = SOCIAL_RANK_PEASANT
	maximum_possible_slots = 3
	traits_applied = list(TRAIT_PEASANTMILITIA)
	subclass_stats = list(		
		STATKEY_STR = 2,
		STATKEY_CON = 2,
		STATKEY_LCK = 2,
		STATKEY_END = 1
	)

	subclass_skills = list(
		/datum/skill/combat/wrestling = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/unarmed = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/knives = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/polearms = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/slings = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/maces = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/craft/cooking = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/athletics = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/swimming = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN, 
		/datum/skill/labor/mining = SKILL_LEVEL_NOVICE,
		/datum/skill/labor/lumberjacking = SKILL_LEVEL_APPRENTICE,
		/datum/skill/labor/farming = SKILL_LEVEL_NOVICE,
		/datum/skill/labor/fishing = SKILL_LEVEL_APPRENTICE,
		/datum/skill/craft/carpentry = SKILL_EXP_APPRENTICE,
	)
/datum/outfit/job/levy
	belt = /obj/item/storage/belt/rogue/leather
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/lord
	pants = /obj/item/clothing/under/roguetown/tights
	shoes = /obj/item/clothing/shoes/roguetown/shortboots
	backr = /obj/item/storage/backpack/rogue/satchel
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	gloves = /obj/item/clothing/gloves/roguetown/fingerless
	neck = /obj/item/storage/belt/rogue/pouch/coins/poor
	armor = /obj/item/clothing/suit/roguetown/armor/leather
	backl = /obj/item/rogueweapon/woodstaff
	beltl = /obj/item/rogueweapon/mace/cudgel
	head = /obj/item/clothing/head/roguetown/helmet/coppercap
	backpack_contents = list(
		/obj/item/rope = 1,
		)
