/datum/job/roguetown/councillor
	title = "Councillor"
	flag = COUNCILLOR
	department_flag = NOBLEMEN
	faction = "Station"
	total_positions = 3
	spawn_positions = 3
	allowed_races = RACES_SECOND_CLASS_UP
	disallowed_races = list(
		/datum/species/lamia,
		/datum/species/harpy,
		/datum/species/golem/metal,
	)
	allowed_sexes = list(MALE, FEMALE)
	display_order = JDO_COUNCILLOR
	tutorial = "You may have inherited this position, bought your way into it, or were appointed to it by merit--perish the thought! Whatever the case though, you work as an assistant and agent of the crown in matters of state. Whether this be aiding the steward, the sheriff, or the crown itself, or simply enjoying the free food of the keep, your duties vary day by day. You may be the lowest rung of the ladder, but that rung still towers over everyone else in town."
	whitelist_req = FALSE
	outfit = /datum/outfit/job/councillor
	advclass_cat_rolls = list(CTAG_COUNCILLOR = 2)


	give_bank_account = 40
	noble_income = 20
	min_pq = 6 //Probably a bad idea to have a complete newbie advising the monarch. Also Poison.
	max_pq = null
	round_contrib_points = 2
	cmode_music = 'sound/music/combat_noble.ogg'
	social_rank = SOCIAL_RANK_NOBLE

	job_traits = list(TRAIT_NOBLE)
	job_subclasses = list(
		/datum/advclass/councillor/admin,
		/datum/advclass/councillor/intrigue,
		/datum/advclass/councillor/ambassador
	)

/datum/outfit/job/councillor
	job_bitflag = BITFLAG_ROYALTY


/datum/advclass/councillor/admin
	name = "Administrator"
	tutorial = "You are adroit in the art of bureaucracy. Paperwork, record-keeping, and the endless red tape of noble life are your specialties. You make an excellent assistant to the men in charge, ensuring that everything runs smoothly behind the scenes. Assisting the Steward and Marshal in maintaining the economy and security of the realm sees you presented with pleanty of opportunities to prove your dilligence... or line your own pockets."
	outfit = /datum/outfit/job/councillor/admin
	category_tags = list(CTAG_COUNCILLOR)
	traits_applied = list(TRAIT_SEEPRICES, TRAIT_INTELLECTUAL, TRAIT_PERFECT_TRACKER)
	subclass_stats = list(
		STATKEY_PER = 1,
		STATKEY_CON = 2,
		STATKEY_INT = 2,
		STATKEY_END = 2,
		STATKEY_STR = 1,
		STATKEY_LCK = 1,
	)

	subclass_skills = list(
		/datum/skill/misc/riding = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/unarmed = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/swimming = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/climbing = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/athletics = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/reading = SKILL_LEVEL_MASTER, //Sovfvl
		/datum/skill/combat/swords = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/tracking = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/knives = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/crossbows = SKILL_LEVEL_NOVICE,
		/datum/skill/combat/bows = SKILL_LEVEL_NOVICE, //Hunting
	)

/datum/outfit/job/councillor/admin/pre_equip(mob/living/carbon/human/H)
	..()
	if(should_wear_masc_clothes(H))
		armor = /obj/item/clothing/suit/roguetown/shirt/tunic/noblecoat/councillor
		shoes = /obj/item/clothing/shoes/roguetown/boots/nobleboot
	if(should_wear_femme_clothes(H))
		armor = /obj/item/clothing/suit/roguetown/shirt/dress/gown/wintergown/councillor
		shoes = /obj/item/clothing/shoes/roguetown/shortboots
	neck = /obj/item/storage/belt/rogue/pouch/coins/rich
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/royal
	cloak = /obj/item/clothing/cloak/stabard/guardhood
	pants = /obj/item/clothing/under/roguetown/tights/black
	backl = /obj/item/storage/backpack/rogue/satchel
	belt = /obj/item/storage/belt/rogue/leather/plaquesilver
	beltr = /obj/item/storage/keyring/steward
	beltl = /obj/item/rogueweapon/scabbard/sword
	r_hand = /obj/item/rogueweapon/sword/short/messer //A burgher's sword
	head = /obj/item/clothing/head/roguetown/chaperon/councillor
	id = /obj/item/scomstone
	backpack_contents = list(/obj/item/book/rogue/law, /obj/item/paper/scroll, /obj/item/natural/feather, /obj/item/rogueweapon/huntingknife/idagger/steel)

/datum/advclass/councillor/intrigue
	name = "Intriguer"
	tutorial = "You are adroit in the art of scheming. Eaves-dropping, poisoning, and the endless courtly gossip of noble life are your specialties. You make an excellent ear and mouth for the court's shadowier leaders, ensuring that no secrets escape the ever present paranoia of the Court. A knowledge of poison and keen ears allow you to see your lords' schemes fufilled... but surely something slipped into their own goblets would see you rise."
	outfit = /datum/outfit/job/councillor/intrigue
	category_tags = list(CTAG_COUNCILLOR)
	traits_applied = list(TRAIT_KEENEARS, TRAIT_LIGHT_STEP, TRAIT_CICERONE)
	subclass_stats = list(
		STATKEY_PER = 3,
		STATKEY_INT = 2,
		STATKEY_END = 2,
		STATKEY_SPD = 3,
		STATKEY_STR = -1,
		STATKEY_LCK = 1,
	)

	subclass_skills = list(
		/datum/skill/misc/riding = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/unarmed = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/swimming = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/athletics = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/reading = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/swords = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/knives = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/sneaking = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/stealing = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/lockpicking = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/crossbows = SKILL_LEVEL_NOVICE,
		/datum/skill/combat/bows = SKILL_LEVEL_NOVICE, //Hunting
		/datum/skill/craft/alchemy = SKILL_LEVEL_JOURNEYMAN,
	)

/datum/outfit/job/councillor/intrigue/pre_equip(mob/living/carbon/human/H)
	..()
	if(should_wear_masc_clothes(H))
		armor = /obj/item/clothing/suit/roguetown/shirt/tunic/noblecoat/councillor
		shoes = /obj/item/clothing/shoes/roguetown/boots/nobleboot
	if(should_wear_femme_clothes(H))
		armor = /obj/item/clothing/suit/roguetown/shirt/dress/gown/wintergown/councillor
		shoes = /obj/item/clothing/shoes/roguetown/shortboots
	neck = /obj/item/storage/belt/rogue/pouch/coins/rich
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/royal
	cloak = /obj/item/clothing/cloak/stabard/guardhood
	pants = /obj/item/clothing/under/roguetown/tights/black
	backl = /obj/item/storage/backpack/rogue/satchel
	belt = /obj/item/storage/belt/rogue/leather/plaquesilver
	beltr = /obj/item/storage/keyring/steward
	beltl = /obj/item/rogueweapon/scabbard/sheath
	r_hand = /obj/item/rogueweapon/huntingknife/idagger/silver/elvish/drow //A fancy evil cunt dagger for a fancy evil cunt. It is silver, so if it is abused, it shall have to be changed out. I doubt it will be, considering they have terrible skills/traits for combat.
	head = /obj/item/clothing/head/roguetown/chaperon/councillor
	id = /obj/item/scomstone
	backpack_contents = list(/obj/item/reagent_containers/glass/bottle/rogue/strongpoison, /obj/item/paper/scroll, /obj/item/natural/feather)

/datum/advclass/councillor/ambassador
	name = "Ambassador"
	tutorial = "You are adroit in the art of diplomacy. A silver-tongue, sharp wit, and a capacity for empathy - peculier for a member of the court! - are your specialities. You make an excellent diplomat for the court's interests, ensuring that trouble in the Duchy is smoothed over. Your charisma has certainly made your liege a lot of friends... but one must wonder what you could do if you made those allies your own."
	outfit = /datum/outfit/job/councillor/ambassador
	category_tags = list(CTAG_COUNCILLOR)
	traits_applied = list(TRAIT_EMPATH, TRAIT_GOODLOVER, TRAIT_NUTCRACKER)
	subclass_stats = list(
		STATKEY_PER = 3,
		STATKEY_INT = 2,
		STATKEY_END = 2,
		STATKEY_SPD = 1,
		STATKEY_STR = 1,
		STATKEY_LCK = 1,
	)

	subclass_skills = list(
		/datum/skill/misc/riding = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/unarmed = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/swimming = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/climbing = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/athletics = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/reading = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/swords = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/knives = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/crossbows = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/medicine = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/bows = SKILL_LEVEL_NOVICE, //Hunting
	)

/datum/outfit/job/councillor/ambassador/pre_equip(mob/living/carbon/human/H)
	..()
	if(should_wear_masc_clothes(H))
		armor = /obj/item/clothing/suit/roguetown/shirt/tunic/noblecoat/councillor
		shoes = /obj/item/clothing/shoes/roguetown/boots/nobleboot
	if(should_wear_femme_clothes(H))
		armor = /obj/item/clothing/suit/roguetown/shirt/dress/gown/wintergown/councillor
		shoes = /obj/item/clothing/shoes/roguetown/shortboots
	neck = /obj/item/storage/belt/rogue/pouch/coins/rich
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/royal
	cloak = /obj/item/clothing/cloak/stabard/guardhood
	pants = /obj/item/clothing/under/roguetown/tights/black
	backl = /obj/item/storage/backpack/rogue/satchel
	belt = /obj/item/storage/belt/rogue/leather/plaquesilver
	beltr = /obj/item/storage/keyring/steward
	beltl = /obj/item/rogueweapon/scabbard/sword
	r_hand = /obj/item/rogueweapon/sword/decorated //A fancy CEREMONIAL sword.
	head = /obj/item/clothing/head/roguetown/chaperon/councillor
	id = /obj/item/scomstone
	backpack_contents = list(/obj/item/paper/scroll, /obj/item/paper/scroll, /obj/item/natural/feather)
