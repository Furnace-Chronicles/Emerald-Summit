/datum/advclass/sfighter
	name = "Battlemaster"
	tutorial = "You are a seasoned weapon specialist, clad in maille, with years of experience in warfare and battle under your belt."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	outfit = /datum/outfit/job/roguetown/adventurer/sfighter
	category_tags = list(CTAG_ADVENTURER, CTAG_COURTAGENT, CTAG_LICKER_WRETCH)
	class_select_category = CLASS_CAT_WARRIOR
	subclass_social_rank = SOCIAL_RANK_PEASANT

	traits_applied = list(TRAIT_STEELHEARTED, TRAIT_MEDIUMARMOR)
	subclass_stats = list(
		STATKEY_STR = 2,
		STATKEY_END = 1,
		STATKEY_CON = 2,
	)

	subclass_skills = list(
		/datum/skill/combat/polearms = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/maces = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/axes = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/swords = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/shields = SKILL_LEVEL_NOVICE,
		/datum/skill/combat/wrestling = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/unarmed = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/swimming = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/athletics = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/reading = SKILL_LEVEL_NOVICE,
	)

/datum/outfit/job/roguetown/adventurer/sfighter/pre_equip(mob/living/carbon/human/H)
	..()
	to_chat(H, span_warning("You are a seasoned weapon specialist, clad in maille, with years of experience in warfare and battle under your belt."))
	H.dna.species.soundpack_m = new /datum/voicepack/male/warrior()
	H.set_blindness(0)
	var/weapons = list("Longsword","Mace","Billhook","Battle Axe","Short Sword & Iron Shield")
	var/weapon_choice = input("Choose your weapon.", "TAKE UP ARMS") as anything in weapons
	switch(weapon_choice)
		if("Longsword")
			H.adjust_skillrank_up_to(/datum/skill/combat/swords, SKILL_LEVEL_EXPERT, TRUE)
			backr = /obj/item/rogueweapon/sword/long
		if("Mace")
			H.adjust_skillrank_up_to(/datum/skill/combat/maces, SKILL_LEVEL_EXPERT, TRUE)
			beltr = /obj/item/rogueweapon/mace
		if("Billhook")
			H.adjust_skillrank_up_to(/datum/skill/combat/polearms, SKILL_LEVEL_EXPERT, TRUE)
			r_hand = /obj/item/rogueweapon/spear/billhook
		if("Battle Axe")
			H.adjust_skillrank_up_to(/datum/skill/combat/axes, SKILL_LEVEL_EXPERT, TRUE)
			backr = /obj/item/rogueweapon/stoneaxe/battle
		if("Short Sword & Iron Shield")
			H.adjust_skillrank_up_to(/datum/skill/combat/swords, SKILL_LEVEL_EXPERT, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/combat/shields, SKILL_LEVEL_APPRENTICE, TRUE)
			backr = /obj/item/rogueweapon/shield/iron
			beltr = /obj/item/rogueweapon/sword/iron/short
	var/armors = list("Chainmaille Set","Iron Breastplate","Gambeson & Helmet")
	var/armor_choice = input("Choose your armor.", "TAKE UP ARMOR") as anything in armors
	switch(armor_choice)
		if("Chainmaille Set")
			shirt = /obj/item/clothing/suit/roguetown/armor/chainmail/iron
			pants = /obj/item/clothing/under/roguetown/chainlegs/iron
			neck = /obj/item/clothing/neck/roguetown/chaincoif/iron
			gloves = /obj/item/clothing/gloves/roguetown/chain/iron
		if("Iron Breastplate")
			armor = /obj/item/clothing/suit/roguetown/armor/plate/half/iron
			pants = /obj/item/clothing/under/roguetown/trou/leather
			gloves = /obj/item/clothing/gloves/roguetown/angle
		if("Gambeson & Helmet")
			shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
			pants = /obj/item/clothing/under/roguetown/trou/leather
			head = /obj/item/clothing/head/roguetown/helmet/kettle
			gloves = /obj/item/clothing/gloves/roguetown/angle
	belt = /obj/item/storage/belt/rogue/leather
	backl = /obj/item/storage/backpack/rogue/satchel
	beltl = /obj/item/storage/belt/rogue/pouch/coins/poor
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots
	cloak = /obj/item/clothing/cloak/raincloak/furcloak/brown
	backpack_contents = list(/obj/item/flashlight/flare/torch = 1, /obj/item/rogueweapon/huntingknife = 1, /obj/item/recipe_book/survival = 1)

/datum/advclass/sfighter/barbarian
	name = "Barbarian"
	tutorial = "YOU BREAK THE WEAK WITH YOUR HANDS AND VARIOUS OTHER SHARP OBJECTS IN YOUR IMMEDIATE VICINITY. NUMBERS DON'T WORK SO GOOD, BUT YOU CAN DO THE REAL MATH THAT MATTERS: DIVISION. WITH YOUR BARE HANDS!!!"
	outfit = /datum/outfit/job/roguetown/adventurer/barbarian
	traits_applied = list(TRAIT_STEELHEARTED, TRAIT_CRITICAL_RESISTANCE, TRAIT_NOPAINSTUN)
	subclass_stats = list(
		STATKEY_STR = 3,
		STATKEY_END = 1,
		STATKEY_CON = 2,
		STATKEY_INT = -2,
	)

	subclass_skills = list(
		/datum/skill/combat/maces = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/axes = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/swords = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/polearms = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/wrestling = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/unarmed = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/swimming = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/athletics = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
	)

/datum/outfit/job/roguetown/adventurer/barbarian/pre_equip(mob/living/carbon/human/H)
	var/weapons = list("Katar","Axe","Sword","Club","Spear","MY BARE HANDS!!!")
	var/weapon_choice = input("Choose your weapon.", "TAKE UP ARMS") as anything in weapons
	switch(weapon_choice)
		if ("Katar")
			H.adjust_skillrank_up_to(/datum/skill/combat/unarmed, SKILL_LEVEL_EXPERT, TRUE)
			beltr = /obj/item/rogueweapon/katar
		if("Axe")
			H.adjust_skillrank_up_to(/datum/skill/combat/axes, SKILL_LEVEL_JOURNEYMAN, TRUE)			
			beltr = /obj/item/rogueweapon/stoneaxe/boneaxe
		if("Sword")
			H.adjust_skillrank_up_to(/datum/skill/combat/swords, SKILL_LEVEL_JOURNEYMAN, TRUE)
			beltr = /obj/item/rogueweapon/sword/short
		if("Club")
			H.adjust_skillrank_up_to(/datum/skill/combat/maces, SKILL_LEVEL_JOURNEYMAN, TRUE)			
			beltr = /obj/item/rogueweapon/mace/woodclub
		if("Spear")
			H.adjust_skillrank_up_to(/datum/skill/combat/polearms, SKILL_LEVEL_JOURNEYMAN, TRUE)			
			r_hand = /obj/item/rogueweapon/spear/bonespear
		if ("MY BARE HANDS!!!")
			H.adjust_skillrank_up_to(/datum/skill/combat/unarmed, SKILL_LEVEL_EXPERT, TRUE)
			ADD_TRAIT(H, TRAIT_CIVILIZEDBARBARIAN, TRAIT_GENERIC)

	if(should_wear_masc_clothes(H))
		H.dna.species.soundpack_m = new /datum/voicepack/male/warrior()
		head = /obj/item/clothing/head/roguetown/helmet/leather/volfhelm
		wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
		pants = /obj/item/clothing/under/roguetown/heavy_leather_pants
		shoes = /obj/item/clothing/shoes/roguetown/boots/leather
		gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
		backl = /obj/item/storage/backpack/rogue/satchel
		belt = /obj/item/storage/belt/rogue/leather
		neck = /obj/item/storage/belt/rogue/pouch/coins/poor
		beltl = /obj/item/rogueweapon/huntingknife

	if(should_wear_femme_clothes(H))
		head = /obj/item/clothing/head/roguetown/helmet/leather/volfhelm
		armor = /obj/item/clothing/suit/roguetown/armor/leather/bikini
		pants = /obj/item/clothing/under/roguetown/heavy_leather_pants/shorts
		wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
		shoes = /obj/item/clothing/shoes/roguetown/boots/furlinedboots
		gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
		backl = /obj/item/storage/backpack/rogue/satchel
		belt = /obj/item/storage/belt/rogue/leather
		neck = /obj/item/storage/belt/rogue/pouch/coins/poor
		beltl = /obj/item/rogueweapon/huntingknife

	H.set_blindness(0)
	backpack_contents = list(/obj/item/flashlight/flare/torch = 1)


/datum/advclass/sfighter/duelist
	name = "Duelist"
	tutorial = "You are an esteemed swordsman who foregoes armor in exchange for a more nimble fighting style."
	outfit = /datum/outfit/job/roguetown/adventurer/duelist
	traits_applied = list(TRAIT_DODGEEXPERT, TRAIT_DECEIVING_MEEKNESS)
	subclass_stats = list(
		STATKEY_STR = 1,
		STATKEY_END = 1,
		STATKEY_INT = 2,
		STATKEY_SPD = 1,
	)

	subclass_skills = list(
		/datum/skill/combat/knives = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/wrestling = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/unarmed = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/swords = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/swimming = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/athletics = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/shields = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/reading = SKILL_LEVEL_APPRENTICE,
	)

/datum/outfit/job/roguetown/adventurer/duelist/pre_equip(mob/living/carbon/human/H)
	var/weapons = list("Rapier","Dagger")
	var/weapon_choice = input("Choose your weapon.", "TAKE UP ARMS") as anything in weapons
	switch(weapon_choice)
		if("Rapier")
			H.adjust_skillrank_up_to(/datum/skill/combat/swords, SKILL_LEVEL_EXPERT, TRUE)
			beltr = /obj/item/rogueweapon/sword/rapier
		if("Dagger")
			H.adjust_skillrank_up_to(/datum/skill/combat/knives, SKILL_LEVEL_EXPERT, TRUE)
			beltr = /obj/item/rogueweapon/huntingknife/idagger/steel
	armor = /obj/item/clothing/suit/roguetown/armor/leather
	head = /obj/item/clothing/head/roguetown/duelhat
	mask = /obj/item/clothing/mask/rogue/duelmask
	cloak = /obj/item/clothing/cloak/half
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/black
	pants = /obj/item/clothing/under/roguetown/trou/leather
	beltl = /obj/item/storage/belt/rogue/pouch/coins/poor
	shoes = /obj/item/clothing/shoes/roguetown/boots
	neck = /obj/item/clothing/neck/roguetown/gorget
	gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
	backl = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/shield/buckler
	belt = /obj/item/storage/belt/rogue/leather
	backpack_contents = list(/obj/item/flashlight/flare/torch = 1, /obj/item/rogueweapon/huntingknife/idagger/steel/parrying = 1, /obj/item/recipe_book/survival = 1)
	H.set_blindness(0)

/datum/advclass/sfighter/monster_hunter
	name = "Monster Hunter"
	tutorial = "Otavan lamplighters, Tennite Saintsmen and heathens looking to make their coin hunting the most dangerous game: all make up the profession known as being a 'Monster Hunter.' Warriors who carry two blades - one of silver for monsters, and one of steel for men."
	outfit = /datum/outfit/job/roguetown/adventurer/monster_hunter
	traits_applied = list(TRAIT_MEDIUMARMOR)
	subclass_social_rank = SOCIAL_RANK_YEOMAN
	subclass_stats = list(
		STATKEY_STR = 2,
		STATKEY_END = 1,
		STATKEY_CON = 1,
		STATKEY_INT = 1,
	)

	subclass_skills = list(
		/datum/skill/combat/swords = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/knives = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/crossbows = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/wrestling = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/unarmed = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/swimming = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/athletics = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/reading = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/tracking = SKILL_LEVEL_EXPERT,
		/datum/skill/craft/alchemy = SKILL_LEVEL_APPRENTICE,
		/datum/skill/labor/butchering = SKILL_LEVEL_JOURNEYMAN, //they hunt monsters. they should be able to get their trophies (heads) reasonably easy
		/datum/skill/magic/holy = SKILL_LEVEL_NOVICE,
	)

/datum/outfit/job/roguetown/adventurer/monster_hunter/pre_equip(mob/living/carbon/human/H)
	H.cmode_music = 'sound/music/inquisitorcombat.ogg'
	if(HAS_TRAIT(H, TRAIT_PSYDONIAN_GRIT)) 
		backl = /obj/item/storage/backpack/rogue/satchel/otavan
	else
		backl = /obj/item/storage/backpack/rogue/satchel/black
	wrists = /obj/item/clothing/neck/roguetown/psicross/silver //there's no silver crosses of the ten so we just give everyone a psicross
	armor = /obj/item/clothing/suit/roguetown/armor/plate/half/fluted/ornate //host request
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/inq //drippy, doesn't cover legs. Could be psydon-locked but the normal paddy gamby covers legs which is too much for an adv imo
	belt = /obj/item/storage/belt/rogue/leather/knifebelt/black/steel
	shoes = /obj/item/clothing/shoes/roguetown/boots/psydonboots //not actually blacksteel 
	pants = /obj/item/clothing/under/roguetown/splintlegs //these are worse iron chain pants that are cooler drip iirc
	neck = /obj/item/storage/belt/rogue/pouch/coins/poor
	gloves = /obj/item/clothing/gloves/roguetown/angle
	backpack_contents = list(/obj/item/flashlight/flare/torch = 1, /obj/item/rogueweapon/huntingknife = 1, /obj/item/recipe_book/survival = 1, pick(/obj/item/reagent_containers/glass/bottle/alchemical/strpot,
				/obj/item/reagent_containers/glass/bottle/alchemical/conpot,
				/obj/item/reagent_containers/glass/bottle/alchemical/endpot,
				/obj/item/reagent_containers/glass/bottle/alchemical/spdpot,
				/obj/item/reagent_containers/glass/bottle/alchemical/perpot,
				/obj/item/reagent_containers/glass/bottle/alchemical/intpot,
				/obj/item/reagent_containers/glass/bottle/alchemical/lucpot))
	if(HAS_TRAIT(H, TRAIT_PSYDONIAN_GRIT)) //psydonites get inquisition hood and tabard, everyone else gets old fit (hat has identical armor value to hood)
		head = /obj/item/clothing/head/roguetown/roguehood/psydon
		cloak = /obj/item/clothing/cloak/psydontabard
	else
		head = /obj/item/clothing/head/roguetown/bucklehat/monsterhunter
		cloak = /obj/item/clothing/cloak/cape/puritan
	//miracles 
	var/datum/devotion/C = new /datum/devotion(H, H.patron)
	C.grant_miracles(H, cleric_tier = CLERIC_T0, passive_gain = FALSE, devotion_limit = (CLERIC_REQ_1 - 20))
	var/steel = list("Arming Sword","Short Sword", "Dagger","Longsword","Slurbow")
	var/steel_choice = input("Choose your steel, for slaying men.", "TAKE UP ARMS") as anything in steel
	switch(steel_choice)
		if("Arming Sword") //flat worse than the longsword so you get a shield
			backr = /obj/item/rogueweapon/shield/wood // wood so you can carve a psycross/astratan cross on it
			beltl = /obj/item/rogueweapon/sword
		if("Short Sword") //swift balance option
			backr = /obj/item/rogueweapon/sword/short
		if("Dagger")
			r_hand = /obj/item/rogueweapon/huntingknife/idagger/steel
		if("Longsword") //both options have same stats
			if(HAS_TRAIT(H, TRAIT_PSYDONIAN_GRIT))
				backr = /obj/item/rogueweapon/sword/long/oldpsysword //desc calls it silver but it's not actually silver. sovl
			else
				backr = /obj/item/rogueweapon/sword/long //there's a church longsword but it has no sprite. we should give them it when theres a sprite tho
		if("Slurbow") //WHOA!! Don't worry, they don't start with any crossbow skill or bonus PER. The Slurbow's description implies it's a common weapon for highwaymen, so it's not impossible to see it in the hands of an adventurer.
			backr = /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow/slurbow/old //their powered-down version of the inquisition slurbow
			beltl = /obj/item/quiver/bolts
	var/silver = list("Arming Sword","Short Sword", "Dagger","Tossblades")
	var/silver_choice = input("Choose your silver, for slaying monsters.", "TAKE UP ARMS") as anything in silver
	switch(silver_choice)
		if("Arming Sword")
			beltr = /obj/item/rogueweapon/sword/silver
		if("Short Sword")
			beltr = /obj/item/rogueweapon/sword/short/psy //there's no generic short silver sword so everyone gets the psydon one. this is basically the arming sword but swift iirc
		if("Dagger")
			l_hand = /obj/item/rogueweapon/huntingknife/idagger/silver
		if("Tossblades") //funny inquisition tossblades
			belt = /obj/item/storage/belt/rogue/leather/knifebelt/black/psydon

/datum/advclass/sfighter/flagellant
	name = "Flagellant"
	tutorial = "You are a pacifistic warrior who embraces suffering, believing pain is the path to enlightenment. You take the suffering of others upon yourself."
	outfit = /datum/outfit/job/roguetown/adventurer/flagellant
	subclass_social_rank = SOCIAL_RANK_DIRT

	traits_applied = list(TRAIT_STEELHEARTED, TRAIT_CRITICAL_RESISTANCE, TRAIT_NOPAINSTUN, TRAIT_DODGEEXPERT)
	subclass_stats = list(
		STATKEY_CON = 5,
		STATKEY_END = 5,
		STATKEY_SPD = 1,
		STATKEY_STR = -2,
		STATKEY_INT = -2,
	)

	subclass_skills = list(
		/datum/skill/combat/wrestling = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/unarmed = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/whipsflails = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/swimming = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/athletics = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/climbing = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/reading = SKILL_LEVEL_APPRENTICE,
	)

/datum/outfit/job/roguetown/adventurer/flagellant/pre_equip(mob/living/carbon/human/H, visualsOnly)
	..()
	to_chat(H, span_warning("You are a pacifistic warrior who embraces suffering, believing pain is the path to enlightenment."))

	H.set_blindness(0)

	pants = /obj/item/clothing/under/roguetown/tights/black
	shirt = /obj/item/clothing/suit/roguetown/shirt/tunic/black
	shoes = /obj/item/clothing/shoes/roguetown/boots
	backl = /obj/item/storage/backpack/rogue/satchel
	belt = /obj/item/storage/belt/rogue/leather
	beltr = /obj/item/rogueweapon/whip
	beltl = /obj/item/storage/belt/rogue/pouch/coins/poor
	backpack_contents = list(
		/obj/item/recipe_book/survival = 1,
		/obj/item/flashlight/flare/torch = 1,
		)

/datum/advclass/sfighter/amazon
	name = "Amazon"
	tutorial = "Fierce warrior women from distant lands, Amazons choose their armor based on their preferred fighting style - from light and agile to heavily protected."
	outfit = /datum/outfit/job/roguetown/adventurer/amazon
	traits_applied = list(TRAIT_STEELHEARTED)
	subclass_stats = list()
	subclass_social_rank = SOCIAL_RANK_DIRT

/datum/outfit/job/roguetown/adventurer/amazon/pre_equip(mob/living/carbon/human/H, visualsOnly)

	var/armor_styles = list("Leather Kini","Hide Armor Kini","Studded Leather Kini","Half Plate Kini","Plate Kini")
	var/armor_choice = input("Choose your armor style", "Available armor styles") as anything in armor_styles

	switch(armor_choice)

		if("Leather Kini")
			to_chat(H, span_warning("You are a swift and agile warrior who relies on speed and evasion. Your light leather armor allows for maximum mobility."))
			H.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
			H.adjust_skillrank(/datum/skill/combat/unarmed, 3, TRUE)
			H.adjust_skillrank(/datum/skill/combat/whipsflails, 2, TRUE)
			H.adjust_skillrank(/datum/skill/combat/axes, 2, TRUE)
			H.adjust_skillrank(/datum/skill/combat/swords, 2, TRUE)
			H.adjust_skillrank(/datum/skill/combat/polearms, 2, TRUE)
			H.adjust_skillrank(/datum/skill/misc/athletics, 4, TRUE)
			H.adjust_skillrank(/datum/skill/misc/swimming, 3, TRUE)
			H.adjust_skillrank(/datum/skill/misc/climbing, 3, TRUE)
			H.adjust_skillrank(/datum/skill/misc/reading, 1, TRUE)
			H.adjust_skillrank(/datum/skill/misc/sewing, 2, TRUE)
			H.adjust_skillrank(/datum/skill/craft/tanning, 2, TRUE)
			ADD_TRAIT(H, TRAIT_DODGEEXPERT, TRAIT_GENERIC)
			H.set_blindness(0)
			H.change_stat("speed", 3)
			H.change_stat("endurance", 1)
			H.change_stat("strength", 1)
			armor = /obj/item/clothing/suit/roguetown/armor/leather/bikini
			pants = /obj/item/clothing/under/roguetown/heavy_leather_pants/shorts
			wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
			shoes = /obj/item/clothing/shoes/roguetown/boots/furlinedboots
			gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
			backl = /obj/item/storage/backpack/rogue/satchel
			belt = /obj/item/storage/belt/rogue/leather
			neck = /obj/item/storage/belt/rogue/pouch/coins/poor
			backpack_contents = list(/obj/item/flashlight/flare/torch = 1, /obj/item/rogueweapon/huntingknife = 1)
			var/weapons = list("Steel Knuckles","Axe","Sword","Whip","Spear","MY BARE HANDS!!!")
			var/weapon_choice = input("Choose your weapon.", "TAKE UP ARMS") as anything in weapons
			switch(weapon_choice)
				if ("Steel Knuckles")
					H.adjust_skillrank_up_to(/datum/skill/combat/unarmed, SKILL_LEVEL_JOURNEYMAN, TRUE)
					beltr = /obj/item/rogueweapon/knuckles
				if("Axe")
					H.adjust_skillrank_up_to(/datum/skill/combat/axes, SKILL_LEVEL_JOURNEYMAN, TRUE)
					beltr = /obj/item/rogueweapon/stoneaxe/boneaxe
				if("Sword")
					H.adjust_skillrank_up_to(/datum/skill/combat/swords, SKILL_LEVEL_JOURNEYMAN, TRUE)
					r_hand = /obj/item/rogueweapon/sword/short
					beltr = /obj/item/rogueweapon/scabbard/sword
				if("Whip")
					H.adjust_skillrank_up_to(/datum/skill/combat/whipsflails, SKILL_LEVEL_JOURNEYMAN, TRUE)
					beltr = /obj/item/rogueweapon/whip
				if("Spear")
					H.adjust_skillrank_up_to(/datum/skill/combat/polearms, SKILL_LEVEL_JOURNEYMAN, TRUE)
					r_hand = /obj/item/rogueweapon/spear/bonespear
				if ("MY BARE HANDS!!!")
					H.adjust_skillrank_up_to(/datum/skill/combat/wrestling, SKILL_LEVEL_EXPERT, TRUE)
					H.adjust_skillrank_up_to(/datum/skill/combat/unarmed, SKILL_LEVEL_EXPERT, TRUE)
					ADD_TRAIT(H, TRAIT_CIVILIZEDBARBARIAN, TRAIT_GENERIC)

		if("Hide Armor Kini")
			to_chat(H, span_warning("You are a swift and agile warrior who relies on speed and evasion. Your light leather armor allows for maximum mobility."))
			H.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
			H.adjust_skillrank(/datum/skill/combat/unarmed, 3, TRUE)
			H.adjust_skillrank(/datum/skill/combat/whipsflails, 2, TRUE)
			H.adjust_skillrank(/datum/skill/combat/axes, 2, TRUE)
			H.adjust_skillrank(/datum/skill/combat/swords, 2, TRUE)
			H.adjust_skillrank(/datum/skill/combat/polearms, 2, TRUE)
			H.adjust_skillrank(/datum/skill/misc/athletics, 4, TRUE)
			H.adjust_skillrank(/datum/skill/misc/swimming, 3, TRUE)
			H.adjust_skillrank(/datum/skill/misc/climbing, 3, TRUE)
			H.adjust_skillrank(/datum/skill/misc/reading, 1, TRUE)
			H.adjust_skillrank(/datum/skill/misc/sewing, 2, TRUE)
			H.adjust_skillrank(/datum/skill/craft/tanning, 2, TRUE)
			ADD_TRAIT(H, TRAIT_DODGEEXPERT, TRAIT_GENERIC)
			H.set_blindness(0)
			H.change_stat("speed", 3)
			H.change_stat("endurance", 1)
			H.change_stat("strength", 1)
			armor = /obj/item/clothing/suit/roguetown/armor/leather/hide/bikini
			pants = /obj/item/clothing/under/roguetown/heavy_leather_pants/shorts
			wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
			shoes = /obj/item/clothing/shoes/roguetown/boots/furlinedboots
			gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
			backl = /obj/item/storage/backpack/rogue/satchel
			belt = /obj/item/storage/belt/rogue/leather
			neck = /obj/item/storage/belt/rogue/pouch/coins/poor
			backpack_contents = list(/obj/item/flashlight/flare/torch = 1, /obj/item/rogueweapon/huntingknife = 1)
			var/weapons = list("Steel Knuckles","Axe","Sword","Whip","Spear","MY BARE HANDS!!!")
			var/weapon_choice = input("Choose your weapon.", "TAKE UP ARMS") as anything in weapons
			switch(weapon_choice)
				if ("Steel Knuckles")
					H.adjust_skillrank_up_to(/datum/skill/combat/unarmed, SKILL_LEVEL_JOURNEYMAN, TRUE)
					beltr = /obj/item/rogueweapon/knuckles
				if("Axe")
					H.adjust_skillrank_up_to(/datum/skill/combat/axes, SKILL_LEVEL_JOURNEYMAN, TRUE)
					beltr = /obj/item/rogueweapon/stoneaxe/boneaxe
				if("Sword")
					H.adjust_skillrank_up_to(/datum/skill/combat/swords, SKILL_LEVEL_JOURNEYMAN, TRUE)
					r_hand = /obj/item/rogueweapon/sword/short
					beltr = /obj/item/rogueweapon/scabbard/sword
				if("Whip")
					H.adjust_skillrank_up_to(/datum/skill/combat/whipsflails, SKILL_LEVEL_JOURNEYMAN, TRUE)
					beltr = /obj/item/rogueweapon/whip
				if("Spear")
					H.adjust_skillrank_up_to(/datum/skill/combat/polearms, SKILL_LEVEL_JOURNEYMAN, TRUE)
					r_hand = /obj/item/rogueweapon/spear/bonespear
				if ("MY BARE HANDS!!!")
					H.adjust_skillrank_up_to(/datum/skill/combat/wrestling, SKILL_LEVEL_EXPERT, TRUE)
					H.adjust_skillrank_up_to(/datum/skill/combat/unarmed, SKILL_LEVEL_EXPERT, TRUE)
					ADD_TRAIT(H, TRAIT_CIVILIZEDBARBARIAN, TRAIT_GENERIC)


		if("Studded Leather Kini")
			to_chat(H, span_warning("You are a refined warrior who combines light protection with precision striking weapons."))
			H.adjust_skillrank(/datum/skill/combat/knives, 2, TRUE)
			H.adjust_skillrank(/datum/skill/combat/whipsflails, 2, TRUE)
			H.adjust_skillrank(/datum/skill/combat/polearms, 2, TRUE)
			H.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
			H.adjust_skillrank(/datum/skill/combat/unarmed, 3, TRUE)
			H.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
			H.adjust_skillrank(/datum/skill/misc/swimming, 2, TRUE)
			H.adjust_skillrank(/datum/skill/combat/swords, 3, TRUE)
			H.adjust_skillrank(/datum/skill/misc/climbing, 2, TRUE)
			H.adjust_skillrank(/datum/skill/misc/reading, 2, TRUE)
			ADD_TRAIT(H, TRAIT_DODGEEXPERT, TRAIT_GENERIC)
			H.set_blindness(0)
			H.change_stat("speed", 2)
			H.change_stat("endurance", 1)
			H.change_stat("strength", 2)
			armor = /obj/item/clothing/suit/roguetown/armor/leather/studded/bikini
			pants = /obj/item/clothing/under/roguetown/tights/black
			wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
			shoes = /obj/item/clothing/shoes/roguetown/boots
			gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
			backl = /obj/item/storage/backpack/rogue/satchel
			belt = /obj/item/storage/belt/rogue/leather
			neck = /obj/item/storage/belt/rogue/pouch/coins/poor
			backpack_contents = list(/obj/item/flashlight/flare/torch = 1, /obj/item/rogueweapon/huntingknife/idagger/steel = 1)
			var/weapons = list("Katar","Rapier","Whip","Billhook","MY BARE HANDS!!!")
			var/weapon_choice = input("Choose your weapon.", "TAKE UP ARMS") as anything in weapons
			switch(weapon_choice)
				if ("Katar")
					H.adjust_skillrank_up_to(/datum/skill/combat/unarmed, SKILL_LEVEL_JOURNEYMAN, TRUE)
					beltr = /obj/item/rogueweapon/katar
				if("Rapier")
					H.adjust_skillrank_up_to(/datum/skill/combat/swords, SKILL_LEVEL_JOURNEYMAN, TRUE)
					beltr = /obj/item/rogueweapon/sword/rapier
				if("Whip")
					H.adjust_skillrank_up_to(/datum/skill/combat/whipsflails, SKILL_LEVEL_JOURNEYMAN, TRUE)
					beltr = /obj/item/rogueweapon/whip
				if("Billhook")
					H.adjust_skillrank_up_to(/datum/skill/combat/polearms, SKILL_LEVEL_JOURNEYMAN, TRUE)
					r_hand = /obj/item/rogueweapon/spear/billhook
				if ("MY BARE HANDS!!!")
					H.adjust_skillrank_up_to(/datum/skill/combat/wrestling, SKILL_LEVEL_EXPERT, TRUE)
					H.adjust_skillrank_up_to(/datum/skill/combat/unarmed, SKILL_LEVEL_EXPERT, TRUE)
					ADD_TRAIT(H, TRAIT_CIVILIZEDBARBARIAN, TRAIT_GENERIC)

		if("Half Plate Kini")
			to_chat(H, span_warning("You are a balanced warrior who wears medium armor and wields powerful weapons for devastating strikes."))
			H.adjust_skillrank(/datum/skill/combat/polearms, 2, TRUE)
			H.adjust_skillrank(/datum/skill/combat/maces, 2, TRUE)
			H.adjust_skillrank(/datum/skill/combat/axes, 2, TRUE)
			H.adjust_skillrank(/datum/skill/combat/swords, 2, TRUE)
			H.adjust_skillrank(/datum/skill/combat/shields, 2, TRUE)			
			H.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
			H.adjust_skillrank(/datum/skill/combat/unarmed, 3, TRUE)
			H.adjust_skillrank(/datum/skill/misc/swimming, 2, TRUE)
			H.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
			H.adjust_skillrank(/datum/skill/misc/climbing, 2, TRUE)
			H.adjust_skillrank(/datum/skill/misc/reading, 1, TRUE)
			ADD_TRAIT(H, TRAIT_MEDIUMARMOR, TRAIT_GENERIC)
			ADD_TRAIT(H, TRAIT_NOPAIN, TRAIT_GENERIC)
			H.set_blindness(0)
			H.change_stat("strength", 2)
			H.change_stat("endurance", 2)
			H.change_stat("constitution", 1)
			armor = /obj/item/clothing/suit/roguetown/armor/plate/bikini
			pants = /obj/item/clothing/under/roguetown/trou/leather
			wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
			shoes = /obj/item/clothing/shoes/roguetown/boots
			gloves = /obj/item/clothing/gloves/roguetown/angle
			backl = /obj/item/storage/backpack/rogue/satchel
			belt = /obj/item/storage/belt/rogue/leather
			neck = /obj/item/storage/belt/rogue/pouch/coins/poor
			var/weapons = list("Great Sword","Eagle's Beak","Battle Axe","MY BARE HANDS!!!")
			var/weapon_choice = input("Choose your weapon.", "TAKE UP ARMS") as anything in weapons
			switch(weapon_choice)
				if("Great Sword")
					H.adjust_skillrank_up_to(/datum/skill/combat/swords, SKILL_LEVEL_JOURNEYMAN, TRUE)
					r_hand = /obj/item/rogueweapon/greatsword
				if("Eagle's Beak")
					H.adjust_skillrank_up_to(/datum/skill/combat/polearms, SKILL_LEVEL_JOURNEYMAN, TRUE)
					r_hand = /obj/item/rogueweapon/eaglebeak
				if("Battle Axe")
					H.adjust_skillrank_up_to(/datum/skill/combat/axes, SKILL_LEVEL_JOURNEYMAN, TRUE)
					beltr = /obj/item/rogueweapon/stoneaxe/battle
				if ("MY BARE HANDS!!!")
					H.adjust_skillrank_up_to(/datum/skill/combat/wrestling, SKILL_LEVEL_EXPERT, TRUE)
					H.adjust_skillrank_up_to(/datum/skill/combat/unarmed, SKILL_LEVEL_EXPERT, TRUE)
					ADD_TRAIT(H, TRAIT_CIVILIZEDBARBARIAN, TRAIT_GENERIC)
			backpack_contents = list(/obj/item/flashlight/flare/torch = 1, /obj/item/rogueweapon/huntingknife = 1, /obj/item/recipe_book/survival = 1)

		if("Plate Kini")
			to_chat(H, span_warning("You are a heavily armored juggernaut who can withstand tremendous punishment behind your shield."))
			H.adjust_skillrank(/datum/skill/combat/polearms, 2, TRUE)
			H.adjust_skillrank(/datum/skill/combat/maces, 3, TRUE)
			H.adjust_skillrank(/datum/skill/combat/axes, 2, TRUE)
			H.adjust_skillrank(/datum/skill/combat/swords, 2, TRUE)
			H.adjust_skillrank(/datum/skill/combat/shields, 3, TRUE)			
			H.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
			H.adjust_skillrank(/datum/skill/combat/unarmed, 3, TRUE)
			H.adjust_skillrank(/datum/skill/misc/swimming, 1, TRUE)
			H.adjust_skillrank(/datum/skill/misc/athletics, 2, TRUE)
			H.adjust_skillrank(/datum/skill/misc/climbing, 1, TRUE)
			H.adjust_skillrank(/datum/skill/misc/reading, 1, TRUE)
			ADD_TRAIT(H, TRAIT_HEAVYARMOR, TRAIT_GENERIC)
			H.set_blindness(0)
			H.change_stat("strength", 3)
			H.change_stat("constitution", 3)
			H.change_stat("speed", -1)
			armor = /obj/item/clothing/suit/roguetown/armor/plate/full/bikini
			pants = /obj/item/clothing/under/roguetown/trou/leather
			wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
			shoes = /obj/item/clothing/shoes/roguetown/boots
			gloves = /obj/item/clothing/gloves/roguetown/angle
			backl = /obj/item/storage/backpack/rogue/satchel
			belt = /obj/item/storage/belt/rogue/leather
			neck = /obj/item/storage/belt/rogue/pouch/coins/poor
			backpack_contents = list(/obj/item/flashlight/flare/torch = 1, /obj/item/rogueweapon/huntingknife = 1, /obj/item/recipe_book/survival = 1)
			var/weapons = list("Sword and Tower Shield","Mace and Tower Shield","TWO TOWER SHIELDS!!!")
			var/weapon_choice = input("Choose your weapon.", "TAKE UP ARMS") as anything in weapons
			switch(weapon_choice)
				if("Sword and Tower Shield")
					H.adjust_skillrank_up_to(/datum/skill/combat/swords, SKILL_LEVEL_JOURNEYMAN, TRUE)
					r_hand = /obj/item/rogueweapon/sword/short
					backr = /obj/item/rogueweapon/shield/tower
					beltr = /obj/item/rogueweapon/scabbard/sword
				if("Mace and Tower Shield")
					H.adjust_skillrank_up_to(/datum/skill/combat/maces, SKILL_LEVEL_EXPERT, TRUE)
					beltr = /obj/item/rogueweapon/mace
					backr = /obj/item/rogueweapon/shield/tower
				if ("TWO TOWER SHIELDS!!!")
					H.adjust_skillrank_up_to(/datum/skill/combat/wrestling, SKILL_LEVEL_EXPERT, TRUE)
					H.adjust_skillrank_up_to(/datum/skill/combat/unarmed, SKILL_LEVEL_EXPERT, TRUE)
					H.adjust_skillrank_up_to(/datum/skill/combat/shields, SKILL_LEVEL_EXPERT, TRUE) //secret funny buff because no one can stop me. double shield meta now
					r_hand = /obj/item/rogueweapon/shield/tower
					l_hand = /obj/item/rogueweapon/shield/tower
					ADD_TRAIT(H, TRAIT_CIVILIZEDBARBARIAN, TRAIT_GENERIC)
