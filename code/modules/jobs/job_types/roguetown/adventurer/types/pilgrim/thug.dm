/datum/job/roguetown/thug
	title = "Thug"
	tutorial = "Maybe you've never been the smartest person in town, but you may have been the sturdiest; Good enough for soilers to pay you to cart around saigashit, good enough for miners to offload some of their work to you, good enough for a carpenter who doesn't want to pay top mams for chopped wood, and good enough for just about anyone who wants a meathead to look scary with."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	outfit = /datum/outfit/job/thug
	cmode_music = 'sound/music/combat_bum.ogg'
	total_positions = 8 // i dont want an army of towner thugs
	social_rank = SOCIAL_RANK_DIRT

	job_subclasses = list(
		/datum/advclass/thug/goon,
		/datum/advclass/thug/wiseguy,
		/datum/advclass/thug/bigman
	)

/datum/outfit/job/thug
	belt = /obj/item/storage/belt/rogue/leather/rope
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/random
	pants = /obj/item/clothing/under/roguetown/tights/random
	shoes = /obj/item/clothing/shoes/roguetown/shortboots
	backr = /obj/item/storage/backpack/rogue/satchel
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	gloves = /obj/item/clothing/gloves/roguetown/fingerless
	neck = /obj/item/storage/belt/rogue/pouch/coins/poor
	armor = /obj/item/clothing/suit/roguetown/armor/leather

/datum/job/roguetown/thug/after_spawn(mob/living/L, mob/M, latejoin = TRUE)
	. = ..()
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		H.advsetup = 1
		H.invisibility = INVISIBILITY_MAXIMUM
		H.become_blind("advsetup")

/datum/advclass/thug/goon
	name = "Goon"
	tutorial = "You're a goon, a low-lyfe thug in a painful world - not good enough for war, not smart enough for peace. What you lack in station you make up for in daring."
	outfit = /datum/outfit/job/thug/goon
	category_tags = list(CTAG_TOWNER)

	subclass_languages = list(/datum/language/thievescant)

	traits_applied = list(TRAIT_SEEPRICES_SHITTY)
	subclass_stats = list(
		STATKEY_STR = 2,
		STATKEY_END = 1,
		STATKEY_CON = 3,
		STATKEY_SPD = -1,
		STATKEY_INT = -1
	)

	subclass_skills = list(
		/datum/skill/combat/wrestling = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/unarmed = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/axes = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/knives = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/maces = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/craft/cooking = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/athletics = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/swimming = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN, 
		/datum/skill/labor/mining = SKILL_LEVEL_NOVICE,
		/datum/skill/labor/lumberjacking = SKILL_LEVEL_APPRENTICE,
		/datum/skill/labor/farming = SKILL_LEVEL_NOVICE,
		/datum/skill/labor/fishing = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/sneaking = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/stealing = SKILL_LEVEL_JOURNEYMAN,
	)

/datum/outfit/job/thug/goon/pre_equip(mob/living/carbon/human/H)
	to_chat(H, span_warning("You're a goon, a low-lyfe thug in a painful world - not good enough for war, not smart enough for peace. What you lack in station you make up for in daring."))
	H.set_blindness(0)
	var/options = list("Frypan", "Knuckles", "Navaja", "Bare Hands", "Whatever I Can Find")
	var/option_choice = input(H, "Choose your means.", "TAKE UP ARMS") as anything in options
	switch(option_choice)
		if("Frypan")
			H.adjust_skillrank_up_to(/datum/skill/craft/cooking, SKILL_LEVEL_EXPERT, TRUE)
			r_hand = /obj/item/cooking/pan
		if("Knuckles")
			H.adjust_skillrank_up_to(/datum/skill/combat/unarmed, SKILL_LEVEL_EXPERT, TRUE)
			r_hand = /obj/item/rogueweapon/knuckles
		if("Navaja")
			H.adjust_skillrank_up_to(/datum/skill/combat/knives, SKILL_LEVEL_APPRENTICE, TRUE)
			r_hand = /obj/item/rogueweapon/huntingknife/idagger/navaja
		if("Bare Hands")
			H.adjust_skillrank_up_to(/datum/skill/combat/unarmed, SKILL_LEVEL_EXPERT, TRUE)
			ADD_TRAIT(H, TRAIT_CIVILIZEDBARBARIAN, TRAIT_GENERIC)
		if("Whatever I Can Find") // random weapon from the dungeon table; could be a wooden club, could be a halberd
			H.adjust_skillrank_up_to(/datum/skill/combat/swords, SKILL_LEVEL_APPRENTICE, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/combat/polearms, SKILL_LEVEL_APPRENTICE, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/combat/whipsflails, SKILL_LEVEL_APPRENTICE, TRUE)
			r_hand = /obj/effect/spawner/lootdrop/roguetown/dungeon/weapons

/datum/advclass/thug/wiseguy
	name = "Miscreant"
	tutorial = "You're smarter than the rest, by a stone's throw - and you know better than to get up close and personal. Unlike most others, you can read."
	outfit = /datum/outfit/job/thug/wiseguy
	category_tags = list(CTAG_TOWNER)
	subclass_social_rank = SOCIAL_RANK_PEASANT

	subclass_languages = list(/datum/language/thievescant)

	traits_applied = list(TRAIT_NUTCRACKER, TRAIT_CICERONE, TRAIT_SEEPRICES_SHITTY)
	subclass_stats = list(
		STATKEY_END = -2,
		STATKEY_CON = -2,
		STATKEY_SPD = 2,
		STATKEY_INT = 2
	)

	subclass_skills = list(
		/datum/skill/combat/wrestling = SKILL_LEVEL_NOVICE,
		/datum/skill/combat/unarmed = SKILL_LEVEL_NOVICE,
		/datum/skill/craft/alchemy = SKILL_LEVEL_APPRENTICE, // vaguely smart, capable of making pyrotechnics
		/datum/skill/craft/crafting = SKILL_LEVEL_APPRENTICE,
		/datum/skill/craft/weaponsmithing = SKILL_LEVEL_NOVICE,
		/datum/skill/craft/armorsmithing = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/athletics = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/swimming = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/climbing = SKILL_LEVEL_APPRENTICE, 
		/datum/skill/labor/farming = SKILL_LEVEL_APPRENTICE,
		/datum/skill/labor/fishing = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/reading = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/sneaking = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/stealing = SKILL_LEVEL_JOURNEYMAN,
	)

/datum/outfit/job/thug/wiseguy/pre_equip(mob/living/carbon/human/H)
	to_chat(H, span_warning("You're smarter than the rest, by a stone's throw - and you know better than to get up close and personal. Unlike most others, you can read."))
	H.set_blindness(0)
	var/options = list("Stone Sling", "Magic Bricks", "Lockpicking Equipment")
	var/option_choice = input(H, "Choose your means.", "TAKE UP ARMS") as anything in options
	switch(option_choice)
		if("Stone Sling")
			H.adjust_skillrank_up_to(/datum/skill/combat/slings, SKILL_LEVEL_EXPERT, TRUE)
			r_hand = /obj/item/gun/ballistic/revolver/grenadelauncher/sling
			l_hand = /obj/item/quiver/sling
		if("Magic Bricks")
			H.adjust_skillrank_up_to(/datum/skill/magic/arcane, SKILL_LEVEL_EXPERT, TRUE)// i fear not the man that has practiced a thousand moves one time, but the man that has practiced one move a thousand times
			H.mind.AddSpell(new /obj/effect/proc_holder/spell/self/magicians_brick)
		if("Lockpicking Equipment")
			H.adjust_skillrank_up_to(/datum/skill/misc/sneaking, SKILL_LEVEL_EXPERT, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/misc/stealing, SKILL_LEVEL_EXPERT, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/misc/lockpicking, SKILL_LEVEL_JOURNEYMAN, TRUE)
			ADD_TRAIT(H, TRAIT_LIGHT_STEP, TRAIT_GENERIC)
			r_hand = /obj/item/lockpickring/mundane

/datum/advclass/thug/bigman
	name = "Big Man"
	tutorial = "More akin to a corn-fed monster than a normal man, your size and strength are your greatest weapons; though they hardly supplement what's missing of your brains."
	outfit = /datum/outfit/job/thug/bigman
	category_tags = list(CTAG_TOWNER)

	subclass_languages = list(/datum/language/thievescant)

	traits_applied = list(TRAIT_STEELHEARTED, TRAIT_HARDDISMEMBER, TRAIT_SEEPRICES_SHITTY)
	subclass_stats = list(
		STATKEY_STR = 3,
		STATKEY_END = 2,
		STATKEY_CON = 5,
		STATKEY_SPD = -4,
		STATKEY_INT = -6,
		STATKEY_PER = -3
	)

	subclass_skills = list(
		/datum/skill/combat/wrestling = SKILL_LEVEL_JOURNEYMAN, // knows very few practical skills; you're a moron
		/datum/skill/combat/unarmed = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/athletics = SKILL_LEVEL_MASTER, // absolutely unrelenting
		/datum/skill/misc/swimming = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/climbing = SKILL_LEVEL_APPRENTICE, 
		/datum/skill/labor/mining = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/labor/lumberjacking = SKILL_LEVEL_JOURNEYMAN,
	)

/datum/outfit/job/thug/bigman/pre_equip(mob/living/carbon/human/H)
	to_chat(H, span_warning("More akin to a corn-fed monster than a normal man, your size and strength are your greatest weapons; though they hardly supplement what's missing of your brains."))
	H.set_blindness(0)
	var/options = list("Hands-On", "Big Axe")
	var/option_choice = input(H, "Choose your means.", "TAKE UP ARMS") as anything in options
	switch(option_choice) // you are big dumb guy, none of your options give you expert-level weapons skill
		if("Hands-On")
			ADD_TRAIT(H, TRAIT_BASHDOORS, TRAIT_GENERIC) // deal 200 damage to a door you sprint-charge into
			ADD_TRAIT(H, TRAIT_CIVILIZEDBARBARIAN, TRAIT_GENERIC)
		if("Big Axe")
			H.adjust_skillrank_up_to(/datum/skill/combat/axes, SKILL_LEVEL_JOURNEYMAN, TRUE)
			r_hand = /obj/item/rogueweapon/greataxe // not steel
	var/prev_real_name = H.real_name
	var/prev_name = H.name
	var/prefix = "Big" // if i see someone named "Boss" pick big man for this bit i will kill them
	H.real_name = "[prefix] [prev_real_name]"
	H.name = "[prefix] [prev_name]"
	if(H.real_name == "Big Boss")
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/invisibility) //NO ONE HEARS A WORD. THEY SAY
