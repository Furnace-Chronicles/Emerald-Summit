/datum/job/roguetown/physician
	title = "Court Physician"
	flag = PHYSICIAN
	department_flag = NOBLEMEN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	allowed_races = RACES_APPOINTED_OUTCASTS_UP
	allowed_sexes = list(MALE, FEMALE)
	display_order = JDO_PHYSICIAN
	tutorial = "You were a child born into good wealth--but poor health. \
		Perhaps in another life, you would have turned out to be a powerful mage, wise archivist or a shrewd steward, \
		but leprosy took away your younger years. \
		Out of desperation, you followed the ways of Pestra and managed to be cured. \
		Now you serve in the Duke's court ensuring the good health of those inhabiting the keep."
	outfit = /datum/outfit/job/roguetown/physician
	whitelist_req = TRUE
	give_bank_account = 30
	min_pq = 3 //Please don't kill the duke by operating on strong intent. Play apothecary until you're deserving of the great white beak of doom
	max_pq = null
	round_contrib_points = 3
	cmode_music = 'sound/music/combat_physician.ogg'

	job_traits = list(TRAIT_MEDICINE_EXPERT, TRAIT_NOSTINK, TRAIT_EMPATH)

	job_stats = list(
		STATKEY_INT = 4,
		STATKEY_WIL = 1,
		STATKEY_LCK = 1,
		STATKEY_SPD = 1,
		STATKEY_STR = -1,
		STATKEY_CON = -1,
	)

/datum/outfit/job/roguetown/physician
	job_bitflag = BITFLAG_ROYALTY

/datum/outfit/job/roguetown/physician
	name = "Physician"
	jobtype = /datum/job/roguetown/physician

/datum/outfit/job/roguetown/physician/pre_equip(mob/living/carbon/human/H)
	..()
	head = /obj/item/clothing/head/roguetown/physician
	mask = /obj/item/clothing/mask/rogue/physician
	neck = /obj/item/clothing/neck/roguetown/psicross/pestra
	armor = /obj/item/clothing/suit/roguetown/shirt/robe/physician
	shirt = /obj/item/clothing/suit/roguetown/shirt/tunic/black
	gloves = /obj/item/clothing/gloves/roguetown/leather
	pants = /obj/item/clothing/under/roguetown/trou/leather/mourning
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	belt = /obj/item/storage/belt/rogue/leather/black
	beltl = /obj/item/storage/belt/rogue/surgery_bag/full/physician
	beltr = /obj/item/storage/keyring/physician
	id = /obj/item/scomstone/bad
	r_hand = /obj/item/rogueweapon/woodstaff
	backl = /obj/item/storage/backpack/rogue/satchel/black
	backpack_contents = list(
		/obj/item/reagent_containers/glass/bottle/rogue/healthpot = 2,
		/obj/item/natural/worms/leech/cheele = 1, //little buddy
		/obj/item/reagent_containers/glass/bottle/waterskin = 1,
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/recipe_book/alchemy = 1,
	)
	H.adjust_skillrank(/datum/skill/misc/reading, 5, TRUE)
	H.adjust_skillrank(/datum/skill/combat/polearms, 2, TRUE)
	H.adjust_skillrank(/datum/skill/combat/wrestling, 2, TRUE)
	H.adjust_skillrank(/datum/skill/craft/alchemy, 5, TRUE)
	H.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/knives, 3, TRUE)
	H.adjust_skillrank(/datum/skill/craft/crafting, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/sewing, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/medicine, 6, TRUE)
	if(H.mind)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/diagnose/secular)
	if(H.age == AGE_MIDDLEAGED)
		H.adjust_skillrank(/datum/skill/misc/sewing, 1, TRUE)
	if(H.age == AGE_OLD)
		H.change_stat("speed", -1)
		H.change_stat("intelligence", 1)
		H.change_stat("perception", 1)
