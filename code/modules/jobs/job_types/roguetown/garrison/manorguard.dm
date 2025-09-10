/datum/job/roguetown/manorguard
	title = "Man at Arms"
	f_title = "Woman at Arms"
	flag = MANATARMS
	department_flag = GARRISON
	faction = "Station"
	total_positions = 8
	spawn_positions = 8
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_FEARED_UP
	disallowed_races = list(
		/datum/species/lamia,
	)
	allowed_patrons = ALL_PATRONS
	allowed_ages = list(AGE_ADULT, AGE_MIDDLEAGED)
	tutorial = "Having proven yourself loyal and capable, you are entrusted to defend the town and enforce its laws. \
				Trained regularly in combat and siege warfare, you deal with threats - both within and without. \
				Obey your Sergeant-at-Arms, the Marshal, and the Crown. Show the nobles and knights your respect, so that you may earn it in turn. Not as a commoner, but as a soldier.."
	display_order = JDO_CASTLEGUARD
	whitelist_req = TRUE
	outfit = /datum/outfit/job/roguetown/manorguard
	advclass_cat_rolls = list(CTAG_MENATARMS = 20)
	give_bank_account = 22
	min_pq = 3
	max_pq = null
	round_contrib_points = 2
	cmode_music = 'sound/music/combat_ManAtArms.ogg'

	job_traits = list(TRAIT_GUARDSMAN, TRAIT_STEELHEARTED)

	job_subclasses = list(
		/datum/advclass/manorguard/footsman,
		/datum/advclass/manorguard/skirmisher,
		/datum/advclass/manorguard/cavalry
	)

/datum/outfit/job/roguetown/manorguard
	job_bitflag = BITFLAG_GARRISON

/datum/job/roguetown/manorguard/after_spawn(mob/living/L, mob/M, latejoin = TRUE)
	. = ..()
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		H.advsetup = 1
		H.invisibility = INVISIBILITY_MAXIMUM
		H.become_blind("advsetup")
		if(istype(H.cloak, /obj/item/clothing/cloak/stabard/surcoat/guard))
			var/obj/item/clothing/S = H.cloak
			var/index = findtext(H.real_name, " ")
			if(index)
				index = copytext(H.real_name, 1,index)
			if(!index)
				index = H.real_name
			S.name = "man-at-arms jupon ([index])"

/datum/outfit/job/roguetown/manorguard
	cloak = /obj/item/clothing/cloak/stabard/surcoat/guard
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	beltl = /obj/item/rogueweapon/mace/cudgel
	belt = /obj/item/storage/belt/rogue/leather/black
	backr = /obj/item/storage/backpack/rogue/satchel/black
	id = /obj/item/scomstone/bad/garrison

// Melee goon
/datum/advclass/manorguard/footsman
	name = "Footman"
	tutorial = "You are a professional soldier of the realm, specializing in melee warfare. Stalwart and hardy, your body can both withstand and dish out powerful strikes.."
	outfit = /datum/outfit/job/roguetown/manorguard/footsman

	category_tags = list(CTAG_MENATARMS)

	traits_applied = list(TRAIT_MEDIUMARMOR)
	subclass_stats = list(
		STATKEY_STR = 2,// seems kinda lame but remember guardsman bonus!!
		STATKEY_INT = 1,
		STATKEY_CON = 1,
		STATKEY_END = 1
	)

	subclass_skills = list(
	/datum/skill/combat/polearms = SKILL_LEVEL_EXPERT,
	/datum/skill/combat/swords = SKILL_LEVEL_EXPERT,
	/datum/skill/combat/maces = SKILL_LEVEL_EXPERT,
	/datum/skill/combat/axes = SKILL_LEVEL_EXPERT,
	/datum/skill/combat/knives = SKILL_LEVEL_JOURNEYMAN,
	/datum/skill/combat/whipsflails = SKILL_LEVEL_APPRENTICE,
	/datum/skill/combat/slings = SKILL_LEVEL_NOVICE,
	/datum/skill/combat/shields = SKILL_LEVEL_JOURNEYMAN,
	/datum/skill/combat/wrestling = SKILL_LEVEL_EXPERT,
	/datum/skill/combat/unarmed = SKILL_LEVEL_EXPERT,
	/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
	/datum/skill/misc/sneaking = SKILL_LEVEL_APPRENTICE,
	/datum/skill/misc/reading = SKILL_LEVEL_NOVICE,
	/datum/skill/misc/athletics = SKILL_LEVEL_JOURNEYMAN,
	/datum/skill/misc/riding = SKILL_LEVEL_NOVICE,
	/datum/skill/misc/tracking = SKILL_LEVEL_NOVICE,
	)

/datum/outfit/job/roguetown/manorguard/footsman/pre_equip(mob/living/carbon/human/H)
	..()

	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/lord		//Bit worse shirt protection than the archer
	armor = /obj/item/clothing/suit/roguetown/armor/plate/scale			//Makes up for worse shirt protection with kinda better armor protection
	pants = /obj/item/clothing/under/roguetown/chainlegs
	neck = /obj/item/clothing/neck/roguetown/gorget

	H.adjust_blindness(-3)
	var/weapons = list("Warhammer & Shield","Axe & Shield","Halberd","Greataxe")
	var/weapon_choice = input("Choose your weapon.", "TAKE UP ARMS") as anything in weapons
	H.set_blindness(0)
	switch(weapon_choice)
		if("Warhammer & Shield")
			beltr = /obj/item/rogueweapon/mace/warhammer
			backl = /obj/item/rogueweapon/shield/iron
		if("Axe & Shield")
			beltr = /obj/item/rogueweapon/stoneaxe/woodcut/steel
			backl = /obj/item/rogueweapon/shield/iron
		if("Halberd")
			r_hand = /obj/item/rogueweapon/halberd
		if("Greataxe")
			r_hand = /obj/item/rogueweapon/greataxe
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1,
		/obj/item/rope/chain = 1,
		/obj/item/storage/keyring/guardcastle,
		/obj/item/rogueweapon/scabbard/sheath = 1,
	)
	H.verbs |= /mob/proc/haltyell

	var/helmets = list(
	"Simple Helmet" 	= /obj/item/clothing/head/roguetown/helmet,
	"Kettle Helmet" 	= /obj/item/clothing/head/roguetown/helmet/kettle,
	"Bascinet Helmet"		= /obj/item/clothing/head/roguetown/helmet/bascinet,
	"Sallet Helmet"		= /obj/item/clothing/head/roguetown/helmet/sallet,
	"Winged Helmet" 	= /obj/item/clothing/head/roguetown/helmet/winged,
	"None"
	)
	var/helmchoice = input("Choose your Helm.", "TAKE UP HELMS") as anything in helmets
	if(helmchoice != "None")
		head = helmets[helmchoice]

// Ranged weapons and daggers on the side - lighter armor, but fleet!
/datum/advclass/manorguard/skirmisher
	name = "Skirmisher"
	tutorial = "You are a professional soldier of the realm, specializing in ranged implements and daggers. You sport a keen eye, looking for your enemies weaknesses."
	outfit = /datum/outfit/job/roguetown/manorguard/skirmisher

	category_tags = list(CTAG_MENATARMS)

	//Garrison ranged/speed class. Time to go wild
	traits_applied = list(TRAIT_DODGEEXPERT)
	subclass_stats = list(
		STATKEY_SPD = 2,// seems kinda lame but remember guardsman bonus!!
		STATKEY_PER = 2,
		STATKEY_END = 1
	)
	extra_context = "Chooses between Light Armor (Dodge Expert) & Medium Armor."

	subclass_skills = list(
		/datum/skill/combat/swords = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/knives = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/maces = SKILL_LEVEL_APPRENTICE, 		// Still have a cugel.
		/datum/skill/combat/crossbows = SKILL_LEVEL_MASTER,		//Only effects draw and reload time.
		/datum/skill/combat/bows = SKILL_LEVEL_MASTER,			//Only effects draw times.
		/datum/skill/combat/slings = SKILL_LEVEL_MASTER,
		/datum/skill/misc/climbing = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/sneaking = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/athletics = SKILL_LEVEL_EXPERT, // A little better; run fast, weak boy.
		/datum/skill/combat/wrestling = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/unarmed = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/reading = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/riding = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/tracking = SKILL_LEVEL_APPRENTICE,
	)

/datum/outfit/job/roguetown/manorguard/skirmisher/pre_equip(mob/living/carbon/human/H)
	..()

	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/lord			// Cant wear chainmail anymoooree
	armor = /obj/item/clothing/suit/roguetown/armor/leather/studded		//Helps against arrows; makes sense for a ranged-type role.
	neck = /obj/item/clothing/neck/roguetown/chaincoif
	pants = /obj/item/clothing/under/roguetown/trou/leather

	H.adjust_blindness(-3)
	var/weapons = list("Crossbow","Bow","Sling")
	var/weapon_choice = input("Choose your weapon.", "TAKE UP ARMS") as anything in weapons
	H.set_blindness(0)
	switch(weapon_choice)
		if("Crossbow")
			beltr = /obj/item/quiver/bolts
			backl = /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow
		if("Bow") // They can head down to the armory to sideshift into one of the other bows.
			beltr = /obj/item/quiver/arrows
			backl = /obj/item/gun/ballistic/revolver/grenadelauncher/bow/recurve
		if("Sling")
			beltr = /obj/item/quiver/sling/iron
			r_hand = /obj/item/gun/ballistic/revolver/grenadelauncher/sling // Both are belt slots and it's not worth setting where the cugel goes for everyone else, sad.

	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1,
		/obj/item/rope/chain = 1,
		/obj/item/storage/keyring/guardcastle,
		/obj/item/rogueweapon/scabbard/sheath = 1,
	)
	H.verbs |= /mob/proc/haltyell

	var/helmets = list(
	"Simple Helmet" 	= /obj/item/clothing/head/roguetown/helmet,
	"Kettle Helmet" 	= /obj/item/clothing/head/roguetown/helmet/kettle,
	"Bascinet Helmet"		= /obj/item/clothing/head/roguetown/helmet/bascinet,
	"Sallet Helmet"		= /obj/item/clothing/head/roguetown/helmet/sallet,
	"Winged Helmet" 	= /obj/item/clothing/head/roguetown/helmet/winged,
	"None"
	)
	var/helmchoice = input("Choose your Helm.", "TAKE UP HELMS") as anything in helmets
	if(helmchoice != "None")
		head = helmets[helmchoice]

/datum/advclass/manorguard/cavalry
	name = "Cavalryman"
	tutorial = "You are a professional soldier of the realm, specializing in the steady beat of hoof falls. Lighter and more expendable then the knights, you charge with lance in hand."
	outfit = /datum/outfit/job/roguetown/manorguard/cavalry
	horse = /mob/living/simple_animal/hostile/retaliate/rogue/saiga/tame/saddled //Since knights start with the Buck

	category_tags = list(CTAG_MENATARMS)

	traits_applied = list(TRAIT_MEDIUMARMOR)
	//Garrison mounted class; charge and charge often.
	subclass_stats = list(
		STATKEY_CON = 2,// seems kinda lame but remember guardsman bonus!!
		STATKEY_END = 2,// Your name is speed, and speed is running.
		STATKEY_STR = 1,
		STATKEY_INT = 1, // No strength to account for the nominally better weapons. We'll see.
	)

	subclass_skills = list(
	/datum/skill/combat/polearms = SKILL_LEVEL_EXPERT,
	/datum/skill/combat/swords = SKILL_LEVEL_EXPERT,
	/datum/skill/combat/knives = SKILL_LEVEL_APPRENTICE,
	/datum/skill/combat/maces = SKILL_LEVEL_JOURNEYMAN, 		// Still have a cugel.
	/datum/skill/combat/shields = SKILL_LEVEL_JOURNEYMAN,
	/datum/skill/combat/whipsflails = SKILL_LEVEL_JOURNEYMAN,	//Best whip training out of MAAs, they're strong.
	/datum/skill/combat/bows = SKILL_LEVEL_NOVICE,			// We discourage horse archers, though.
	/datum/skill/combat/slings = SKILL_LEVEL_NOVICE,
	/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
	/datum/skill/misc/athletics = SKILL_LEVEL_JOURNEYMAN, 
	/datum/skill/combat/wrestling = SKILL_LEVEL_EXPERT,
	/datum/skill/combat/unarmed = SKILL_LEVEL_EXPERT,
	/datum/skill/misc/reading = SKILL_LEVEL_NOVICE,
	/datum/skill/misc/riding = SKILL_LEVEL_EXPERT, 		// Like the other horselords.
	/datum/skill/misc/tracking = SKILL_LEVEL_JOURNEYMAN,	//Best tracker. Might as well give it something to stick-out utility wise.
	)

/datum/outfit/job/roguetown/manorguard/cavalry/pre_equip(mob/living/carbon/human/H)
	..()

	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/lord		//Bit worse shirt protection than the archer -- as foot soldier.
	armor = /obj/item/clothing/suit/roguetown/armor/plate/scale			//Makes up for worse shirt protection with kinda better armor protection
	pants = /obj/item/clothing/under/roguetown/chainlegs
	neck = /obj/item/clothing/neck/roguetown/gorget

	H.adjust_blindness(-3)
	var/weapons = list("Bardiche","Sword & Shield")
	var/weapon_choice = input("Choose your weapon.", "TAKE UP ARMS") as anything in weapons
	H.set_blindness(0)
	switch(weapon_choice)
		if("Bardiche")
			r_hand = /obj/item/rogueweapon/halberd/bardiche
		if("Sword & Shield")
			beltr = /obj/item/rogueweapon/sword/sabre
			backl = /obj/item/rogueweapon/shield/wood
			r_hand = /obj/item/rogueweapon/scabbard/sword
	
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1,
		/obj/item/rope/chain = 1,
		/obj/item/storage/keyring/guardcastle,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)
	H.verbs |= /mob/proc/haltyell

	var/helmets = list(
	"Simple Helmet" 	= /obj/item/clothing/head/roguetown/helmet,
	"Kettle Helmet" 	= /obj/item/clothing/head/roguetown/helmet/kettle,
	"Bascinet Helmet"		= /obj/item/clothing/head/roguetown/helmet/bascinet,
	"Sallet Helmet"		= /obj/item/clothing/head/roguetown/helmet/sallet,
	"Winged Helmet" 	= /obj/item/clothing/head/roguetown/helmet/winged,
	"Studded Leather Hood" = /obj/item/clothing/head/roguetown/helmet/leather/armorhood/advanced,
	"None"
	)
	var/helmchoice = input("Choose your Helm.", "TAKE UP HELMS") as anything in helmets
	if(helmchoice != "None")
		head = helmets[helmchoice]
