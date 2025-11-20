/datum/job/roguetown/knight
	title = "Knight"
	f_title = "Dame"
	flag = KNIGHT
	department_flag = NOBLEMEN
	faction = "Station"
	total_positions = 4
	spawn_positions = 4
	allowed_races = RACES_NOBILITY_ELIGIBLE_UP
	allowed_patrons = NON_PSYDON_PATRONS
	allowed_sexes = list(MALE, FEMALE)
	allowed_ages = list(AGE_ADULT, AGE_MIDDLEAGED)
	tutorial = "Having proven yourself both loyal and capable, you have been knighted to serve the realm as the royal family's sentry. \
				You listen to your Liege and the Marshal, defending your Lord and realm - the last beacon of chivalry in these dark times."
	display_order = JDO_KNIGHT
	whitelist_req = TRUE
	outfit = /datum/outfit/job/roguetown/knight
	advclass_cat_rolls = list(CTAG_ROYALGUARD = 20)

	give_bank_account = 22
	noble_income = 10
	min_pq = 10
	max_pq = null
	round_contrib_points = 2
	social_rank = SOCIAL_RANK_MINOR_NOBLE

	cmode_music = 'sound/music/combat_knight.ogg'

	job_traits = list(TRAIT_NOBLE, TRAIT_STEELHEARTED, TRAIT_GOODTRAINER, TRAIT_GUARDSMAN)
	job_subclasses = list(
		/datum/advclass/knight/heavy,
		/datum/advclass/knight/footknight,
		/datum/advclass/knight/mountedknight,
		/datum/advclass/knight/irregularknight
		)

/datum/outfit/job/roguetown/knight
	job_bitflag = BITFLAG_GARRISON

/datum/job/roguetown/knight/after_spawn(mob/living/L, mob/M, latejoin = TRUE)
	..()
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		if(istype(H.cloak, /obj/item/clothing/cloak/stabard/surcoat/guard))
			var/obj/item/clothing/S = H.cloak
			var/index = findtext(H.real_name, " ")
			if(index)
				index = copytext(H.real_name, 1,index)
			if(!index)
				index = H.real_name
			S.name = "knight's tabard ([index])"
		var/prev_real_name = H.real_name
		var/prev_name = H.name
		var/honorary = "Ser"
		if(should_wear_femme_clothes(H))
			honorary = "Dame"
		H.real_name = "[honorary] [prev_real_name]"
		H.name = "[honorary] [prev_name]"

		for(var/X in peopleknowme)
			for(var/datum/mind/MF in get_minds(X))
				if(MF.known_people)
					MF.known_people -= prev_real_name
					H.mind.person_knows_me(MF)

/datum/outfit/job/roguetown/knight
	cloak = /obj/item/clothing/cloak/captain
	neck = /obj/item/clothing/neck/roguetown/bevor
	gloves = /obj/item/clothing/gloves/roguetown/plate
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor
	belt = /obj/item/storage/belt/rogue/leather/steel
	backr = /obj/item/storage/backpack/rogue/satchel
	id = /obj/item/scomstone/bad/garrison
	backpack_contents = list(/obj/item/storage/keyring/guardknight = 1)

/datum/advclass/knight/heavy
	name = "Heavy Knight"
	tutorial = "You've trained thoroughly and hit far harder than most - adept with massive swords, axes, maces, and polearms. People may fear the mounted knights, but they should truly fear those who come off their mount..."
	outfit = /datum/outfit/job/roguetown/knight/heavy
	category_tags = list(CTAG_ROYALGUARD)

	traits_applied = list(TRAIT_HEAVYARMOR)
	subclass_stats = list(
		STATKEY_STR = 3,//Heavy hitters. Less con/end, high strength.
		STATKEY_INT = 4,
		STATKEY_CON = 1,
		STATKEY_END = 1,
		STATKEY_SPD = -1)

	subclass_skills = list(
		/datum/skill/combat/polearms = SKILL_LEVEL_EXPERT, //Polearms are pretty much explicitly a two-handed weapon, so I gave them a polearm option.
		/datum/skill/combat/swords = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/axes = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/maces = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/riding = SKILL_LEVEL_NOVICE,	//Too heavy for horses.
		/datum/skill/combat/wrestling = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/unarmed = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/reading = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/athletics = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/knives = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/tracking = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/swimming = SKILL_LEVEL_APPRENTICE,
	)

/datum/outfit/job/roguetown/knight/heavy/pre_equip(mob/living/carbon/human/H)
	..()
	H.dna.species.soundpack_m = new /datum/voicepack/male/knight()	
	H.verbs |= /mob/proc/haltyell

	H.adjust_blindness(-3)
	var/weapons = list("Zweihander","Great Mace","Battle Axe","Greataxe","Estoc","Lucerne", "Partizan")
	var/weapon_choice = input("Choose your weapon.", "TAKE UP ARMS") as anything in weapons
	H.set_blindness(0)
	switch(weapon_choice)
		if("Zweihander")
			r_hand = /obj/item/rogueweapon/greatsword/zwei
		if("Great Mace")
			r_hand = /obj/item/rogueweapon/mace/goden/steel
		if("Battle Axe")
			r_hand = /obj/item/rogueweapon/stoneaxe/battle
		if("Greataxe")
			r_hand = /obj/item/rogueweapon/greataxe/steel
		if("Estoc")
			r_hand = /obj/item/rogueweapon/estoc
		if("Lucerne")
			r_hand = /obj/item/rogueweapon/eaglebeak/lucerne
		if("Partizan")
			r_hand = /obj/item/rogueweapon/spear/partizan

	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail
	pants = /obj/item/clothing/under/roguetown/platelegs/captain

	var/helmets = list(
		"Pigface Bascinet" 	= /obj/item/clothing/head/roguetown/helmet/bascinet/pigface,
		"Guard Helmet"		= /obj/item/clothing/head/roguetown/helmet/heavy/guard,
		"Barred Helmet"		= /obj/item/clothing/head/roguetown/helmet/heavy/sheriff,
		"Bucket Helmet"		= /obj/item/clothing/head/roguetown/helmet/heavy/bucket,
		"Knight Helmet"		= /obj/item/clothing/head/roguetown/helmet/heavy/knight,
		"Visored Sallet"	= /obj/item/clothing/head/roguetown/helmet/sallet/visored,
		"Armet"				= /obj/item/clothing/head/roguetown/helmet/heavy/knight/armet,
		"Hounskull Bascinet" = /obj/item/clothing/head/roguetown/helmet/bascinet/pigface/hounskull,
		"Etruscan Bascinet" = /obj/item/clothing/head/roguetown/helmet/bascinet/etruscan,
		"Slitted Kettle" = /obj/item/clothing/head/roguetown/helmet/heavy/knight/skettle,
		"Knight's Barbute"	= /obj/item/clothing/head/roguetown/helmet/visored/captain
	)
	var/helmchoice = input("Choose your Helm.", "TAKE UP HELMS") as anything in helmets
	if(helmchoice != "None")
		head = helmets[helmchoice]

	armor = /obj/item/clothing/suit/roguetown/armor/captain

	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1,
		/obj/item/rope/chain = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1
	)

/datum/advclass/knight/footknight
	name = "Foot Knight"
	tutorial = "You are accustomed to traditional foot-soldier training in one-handed weapons such as flails, swords, and maces. Your fortitude and mastery with the versatile combination of a shield and weapon makes you a fearsome opponent to take down!"
	outfit = /datum/outfit/job/roguetown/knight/footknight

	category_tags = list(CTAG_ROYALGUARD)

	traits_applied = list(TRAIT_HEAVYARMOR)
	subclass_stats = list(
		STATKEY_STR = 1,//Tanky, less strength, but high con/end.
		STATKEY_INT = 3,
		STATKEY_CON = 3,
		STATKEY_END = 3,
	)

	subclass_skills = list(
		/datum/skill/combat/swords = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/whipsflails = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/maces = SKILL_LEVEL_EXPERT, 
		/datum/skill/combat/shields = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/riding = SKILL_LEVEL_APPRENTICE,	
		/datum/skill/combat/wrestling = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/unarmed = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/reading = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/athletics = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/knives = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/tracking = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/swimming = SKILL_LEVEL_APPRENTICE,
	)

/datum/outfit/job/roguetown/knight/footknight/pre_equip(mob/living/carbon/human/H)
	..()

	H.dna.species.soundpack_m = new /datum/voicepack/male/knight()
	H.verbs |= /mob/proc/haltyell

	H.adjust_blindness(-3)
	var/weapons = list("Longsword","Flail","Warhammer","Sabre")
	var/weapon_choice = input("Choose your weapon.", "TAKE UP ARMS") as anything in weapons
	H.set_blindness(0)
	switch(weapon_choice)
		if("Longsword")
			beltl = /obj/item/rogueweapon/scabbard/sword
			l_hand = /obj/item/rogueweapon/sword/long
		if("Flail")
			beltr = /obj/item/rogueweapon/flail/sflail
		if ("Warhammer")
			beltr = /obj/item/rogueweapon/mace/warhammer //Iron warhammer. This is one-handed and pairs well with shields. They can upgrade to steel in-round.
		if("Sabre")
			beltl = /obj/item/rogueweapon/scabbard/sword
			l_hand = /obj/item/rogueweapon/sword/sabre

	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail
	pants = /obj/item/clothing/under/roguetown/platelegs/captain
	backl = /obj/item/rogueweapon/shield/tower/metal

	var/helmets = list(
		"Pigface Bascinet" 	= /obj/item/clothing/head/roguetown/helmet/bascinet/pigface,
		"Guard Helmet"		= /obj/item/clothing/head/roguetown/helmet/heavy/guard,
		"Barred Helmet"		= /obj/item/clothing/head/roguetown/helmet/heavy/sheriff,
		"Bucket Helmet"		= /obj/item/clothing/head/roguetown/helmet/heavy/bucket,
		"Knight Helmet"		= /obj/item/clothing/head/roguetown/helmet/heavy/knight,
		"Visored Sallet"	= /obj/item/clothing/head/roguetown/helmet/sallet/visored,
		"Armet"				= /obj/item/clothing/head/roguetown/helmet/heavy/knight/armet,
		"Hounskull Bascinet" = /obj/item/clothing/head/roguetown/helmet/bascinet/pigface/hounskull,
		"Etruscan Bascinet" = /obj/item/clothing/head/roguetown/helmet/bascinet/etruscan,
		"Slitted Kettle"	= /obj/item/clothing/head/roguetown/helmet/heavy/knight/skettle,
		"Knight's Barbute"	= /obj/item/clothing/head/roguetown/helmet/visored/captain
	)
	var/helmchoice = input("Choose your Helm.", "TAKE UP HELMS") as anything in helmets
	if(helmchoice != "None")
		head = helmets[helmchoice]

	armor = /obj/item/clothing/suit/roguetown/armor/captain

	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1,
		/obj/item/rope/chain = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
	)

/datum/advclass/knight/mountedknight
	name = "Mounted Knight"
	tutorial = "You are the picture-perfect knight from a high tale, knowledgeable in riding steeds into battle. You specialize in weapons most useful on a saiga including spears, swords, maces, and a variety of ranged weaponry."
	outfit = /datum/outfit/job/roguetown/knight/mountedknight
	horse = /mob/living/simple_animal/hostile/retaliate/rogue/saiga/saigabuck/tame/saddled
	category_tags = list(CTAG_ROYALGUARD)

	traits_applied = list(TRAIT_HEAVYARMOR)
	//Decent all-around stats. Nothing spectacular. Ranged/melee hybrid class on horseback.
	subclass_stats = list(
		STATKEY_STR = 2,
		STATKEY_INT = 3,
		STATKEY_CON = 1,
		STATKEY_END = 1,
		STATKEY_PER = 2
	)

	subclass_skills = list(
		/datum/skill/combat/polearms = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/swords = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/maces = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/riding = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/crossbows = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/bows = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/wrestling = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/unarmed = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/reading = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/athletics = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/knives = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/tracking = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/swimming = SKILL_LEVEL_APPRENTICE,
	)

/datum/outfit/job/roguetown/knight/mountedknight/pre_equip(mob/living/carbon/human/H)
	..()
	H.dna.species.soundpack_m = new /datum/voicepack/male/knight()
	H.verbs |= /mob/proc/haltyell

	H.adjust_blindness(-3)
	var/weapons = list(
		"Longsword",
		"Halberd",
		"Grand Mace",
		"Sabre",
		"Lance"
	)
	var/sidearms = list(
		"Crossbow",
		"Recurve Bow",
		"Longbow",
		"Recurve Bow",
		"Kite Shield"
	)
	var/weapon_choice_one = input("Choose your weapon.", "TAKE UP ARMS") as anything in weapons
	var/weapon_choice_two = input("Choose your sidearm.", "TAKE UP SIDEARMS") as anything in sidearms
	H.set_blindness(0)
	switch(weapon_choice_one)
		if("Longsword")
			beltl = /obj/item/rogueweapon/scabbard/sword
			r_hand = /obj/item/rogueweapon/sword/long
		if("Halberd")
			r_hand = /obj/item/rogueweapon/halberd
		if("Grand Mace")
			beltl = /obj/item/rogueweapon/mace/goden/steel
		if("Sabre")
			l_hand = /obj/item/rogueweapon/scabbard/sword
			r_hand = /obj/item/rogueweapon/sword/sabre
		if("Lance")
			r_hand = /obj/item/rogueweapon/spear/lance

	switch(weapon_choice_two)
		if("Crossbow")
			beltr = /obj/item/quiver/bolts
			backl = /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow
		if("Recurve Bow")
			beltr = /obj/item/quiver/arrows
			beltl = /obj/item/gun/ballistic/revolver/grenadelauncher/bow/recurve
		if("Longbow")
			backl = /obj/item/gun/ballistic/revolver/grenadelauncher/bow/longbow
			beltr = /obj/item/quiver/arrows
		if("Recurve Bow")
			beltr = /obj/item/quiver/arrows
			beltl = /obj/item/gun/ballistic/revolver/grenadelauncher/bow/recurve
		if("Kite Shield")
			backl = /obj/item/rogueweapon/shield/tower/metal
			H.adjust_skillrank_up_to(/datum/skill/combat/shields, 2, TRUE) // Let them skip dummy hitting

	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail
	pants = /obj/item/clothing/under/roguetown/platelegs/captain

	var/helmets = list(
		"Pigface Bascinet" 	= /obj/item/clothing/head/roguetown/helmet/bascinet/pigface,
		"Guard Helmet"		= /obj/item/clothing/head/roguetown/helmet/heavy/guard,
		"Barred Helmet"		= /obj/item/clothing/head/roguetown/helmet/heavy/sheriff,
		"Bucket Helmet"		= /obj/item/clothing/head/roguetown/helmet/heavy/bucket,
		"Knight Helmet"		= /obj/item/clothing/head/roguetown/helmet/heavy/knight,
		"Visored Sallet"	= /obj/item/clothing/head/roguetown/helmet/sallet/visored,
		"Armet"				= /obj/item/clothing/head/roguetown/helmet/heavy/knight/armet,
		"Hounskull Bascinet" = /obj/item/clothing/head/roguetown/helmet/bascinet/pigface/hounskull,
		"Etruscan Bascinet" = /obj/item/clothing/head/roguetown/helmet/bascinet/etruscan,
		"Slitted Kettle"	= /obj/item/clothing/head/roguetown/helmet/heavy/knight/skettle,
		"Knight's Barbute"	= /obj/item/clothing/head/roguetown/helmet/visored/captain
	)
	var/helmchoice = input("Choose your Helm.", "TAKE UP HELMS") as anything in helmets
	if(helmchoice != "None")
		head = helmets[helmchoice]

	armor = /obj/item/clothing/suit/roguetown/armor/captain

	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1,
		/obj/item/rope/chain = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
	)


/datum/advclass/knight/irregularknight
	name = "Royal Champion"
	tutorial = "Your skillset is abnormal for a knight. Your swift maneuvers and masterful technique impress both lords and ladies alike, and you have a preference for quicker, more elegant blades. While you are an effective fighting force in medium armor, your evasive skills will only truly shine if you don even lighter protection."
	outfit = /datum/outfit/job/roguetown/knight/irregularknight

	category_tags = list(CTAG_ROYALGUARD)

	traits_applied = list(TRAIT_MEDIUMARMOR, TRAIT_DODGEEXPERT)
	subclass_stats = list(
		STATKEY_STR = 1,
		STATKEY_INT = 3,
		STATKEY_END = 2,
		STATKEY_SPD = 2)

	subclass_skills = list(
		/datum/skill/combat/swords = SKILL_LEVEL_EXPERT, //Swords and knives class.
		/datum/skill/combat/knives = SKILL_LEVEL_EXPERT,	
		/datum/skill/combat/whipsflails = SKILL_LEVEL_EXPERT, //Whips can work as a light class weapon.	
		/datum/skill/combat/shields = SKILL_LEVEL_JOURNEYMAN,	
		/datum/skill/misc/riding = SKILL_LEVEL_APPRENTICE,	
		/datum/skill/combat/crossbows = SKILL_LEVEL_EXPERT, //Bows fit a light/speedy class pretty well, gave them ranged options.
		/datum/skill/combat/bows = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/climbing = SKILL_LEVEL_MASTER,		
		/datum/skill/combat/wrestling = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/athletics = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/unarmed = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/sneaking = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/reading = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/tracking = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/swimming = SKILL_LEVEL_APPRENTICE,
	)

/datum/outfit/job/roguetown/knight/irregularknight/pre_equip(mob/living/carbon/human/H)
	..()
	H.dna.species.soundpack_m = new /datum/voicepack/male/knight()
	H.verbs |= /mob/proc/haltyell

	H.adjust_blindness(-3)
	var/weapons = list("Rapier","Estoc","Sabre","Whip","Greataxe")
	var/sidearms = list("Longbow","Recurve Bow","Buckler","Crossbow","Sling")
	var/armor_options = list("Light Armor", "Medium Armor", "Medium Cuirass")
	var/weapon_choice_one = input("Choose your weapon.", "TAKE UP ARMS") as anything in weapons
	var/weapon_choice_two = input("Choose your sidearm.", "TAKE UP SIDEARMS") as anything in sidearms
	var/armor_choice = input("Choose your armor.", "TAKE UP ARMS") as anything in armor_options
	H.set_blindness(0)
	switch(weapon_choice_one)
		if("Rapier")
			r_hand = /obj/item/rogueweapon/sword/rapier
			beltl = /obj/item/rogueweapon/scabbard/sword

		if("Estoc")
			r_hand = /obj/item/rogueweapon/estoc

		if("Sabre")
			beltl = /obj/item/rogueweapon/scabbard/sword
			r_hand = /obj/item/rogueweapon/sword/sabre

		if("Whip")
			beltl = /obj/item/rogueweapon/whip

		if("Greataxe")
			H.adjust_skillrank_up_to(/datum/skill/combat/axes, 4, TRUE)
			r_hand = /obj/item/rogueweapon/greataxe/steel

	switch(weapon_choice_two)
		if("Longbow")
			backl = /obj/item/gun/ballistic/revolver/grenadelauncher/bow/longbow
			beltr = /obj/item/quiver/arrows

		if("Recurve Bow")
			beltr = /obj/item/quiver/arrows
			beltl = /obj/item/gun/ballistic/revolver/grenadelauncher/bow/recurve

		if("Knight's Buckler")
			backl = /obj/item/rogueweapon/shield/buckler

		if("Crossbow")
			backl = /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow
			beltr = /obj/item/quiver/bolts

		if("Sling")
			H.adjust_skillrank(/datum/skill/combat/slings, 4, TRUE)
			beltr = /obj/item/quiver/sling/iron
			beltl = /obj/item/gun/ballistic/revolver/grenadelauncher/sling

	switch(armor_choice)
		if("Light Armor")
			shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
			pants = /obj/item/clothing/under/roguetown/heavy_leather_pants
			armor = /obj/item/clothing/suit/roguetown/armor/leather/heavy/coat
		if("Medium Armor")
			shirt = /obj/item/clothing/suit/roguetown/armor/chainmail
			pants = /obj/item/clothing/under/roguetown/platelegs/captain
			armor = /obj/item/clothing/suit/roguetown/armor/brigandine/light
		if("Medium Cuirass")
			shirt = /obj/item/clothing/suit/roguetown/armor/chainmail
			pants = /obj/item/clothing/under/roguetown/platelegs/captain
			armor = /obj/item/clothing/suit/roguetown/armor/plate/half/fluted

	var/helmets = list(
		"Pigface Bascinet" 	= /obj/item/clothing/head/roguetown/helmet/bascinet/pigface,
		"Guard Helmet"		= /obj/item/clothing/head/roguetown/helmet/heavy/guard,
		"Barred Helmet"		= /obj/item/clothing/head/roguetown/helmet/heavy/sheriff,
		"Bucket Helmet"		= /obj/item/clothing/head/roguetown/helmet/heavy/bucket,
		"Knight Helmet"		= /obj/item/clothing/head/roguetown/helmet/heavy/knight,
		"Visored Sallet"	= /obj/item/clothing/head/roguetown/helmet/sallet/visored,
		"Armet"				= /obj/item/clothing/head/roguetown/helmet/heavy/knight/armet,
		"Hounskull Bascinet" = /obj/item/clothing/head/roguetown/helmet/bascinet/pigface/hounskull,
		"Etruscan Bascinet" = /obj/item/clothing/head/roguetown/helmet/bascinet/etruscan,
		"Slitted Kettle" = /obj/item/clothing/head/roguetown/helmet/heavy/knight/skettle,
		"Knight's Barbute"	= /obj/item/clothing/head/roguetown/helmet/visored/captain
	)

	var/helmchoice = input("Choose your Helm.", "TAKE UP HELMS") as anything in helmets
	if(helmchoice != "None")
		head = helmets[helmchoice]
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1,
		/obj/item/rope/chain = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
	)
