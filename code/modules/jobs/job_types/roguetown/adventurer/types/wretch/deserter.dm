/datum/advclass/wretch/deserter
	name = "Disgraced Knight"
	tutorial = "You were once a venerated and revered knight - now, a traitor who abandoned your liege. You lyve the lyfe of an outlaw, shunned and looked down upon by society."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	outfit = /datum/outfit/job/roguetown/wretch/deserter
	horse = /mob/living/simple_animal/hostile/retaliate/rogue/saiga/saigabuck/tame/saddled
	category_tags = list(CTAG_WRETCH)
	traits_applied = list(TRAIT_HEAVYARMOR, TRAIT_DISGRACED_NOBLE)

	disallowed_races = list(
		/datum/species/harpy,
	)

	cmode_music = 'sound/music/combat_bandit.ogg' // same as new hedgeknight music
	// Deserter are the knight-equivalence. They get a balanced, straightforward 2 2 3 statspread to endure and overcome.
	subclass_stats = list(
		STATKEY_END = 3,
		STATKEY_CON = 2,
		STATKEY_STR = 2
	)

	subclass_skills = list(
		/datum/skill/combat/polearms = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/maces = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/axes = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/swords = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/knives = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/shields = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/whipsflails = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/wrestling = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/swimming = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/unarmed = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/athletics = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/climbing = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/riding = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/reading = SKILL_LEVEL_JOURNEYMAN,
	)

/datum/outfit/job/roguetown/wretch/deserter/pre_equip(mob/living/carbon/human/H)
	..()
	to_chat(H, span_warning("You were once a venerated and revered knight - now, a traitor who abandoned your liege. You lyve the lyfe of an outlaw, shunned and looked down upon by society."))
	H.dna.species.soundpack_m = new /datum/voicepack/male/warrior()
	H.verbs |= list(/mob/living/carbon/human/mind/proc/setorderswretch)
	if(H.mind)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/order/retreat)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/order/bolster)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/order/brotherhood)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/order/charge)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/self/convertrole/brotherhood)

	var/weapons = list(
		"Estoc",
		"Mace + Shield",
		"Flail + Shield",
		"Longsword + Shield", 
		"Lucerne",
		"Battle Axe",
		"Lance + Kite Shield",
		"Samshir",
	)
	var/weapon_choice = input("Choose your weapon.", "TAKE UP ARMS") as anything in weapons
	H.set_blindness(0)
	switch(weapon_choice)
		if("Estoc")
			r_hand = /obj/item/rogueweapon/estoc
		if("Longsword + Shield")
			beltr = /obj/item/rogueweapon/scabbard/sword
			r_hand = /obj/item/rogueweapon/sword/long
			backr = /obj/item/rogueweapon/shield/tower/metal
		if("Mace + Shield")
			beltr = /obj/item/rogueweapon/mace/steel
			backr = /obj/item/rogueweapon/shield/tower/metal
		if("Flail + Shield")
			beltr = /obj/item/rogueweapon/flail/sflail
			backr = /obj/item/rogueweapon/shield/tower/metal
		if("Lucerne")
			r_hand = /obj/item/rogueweapon/eaglebeak/lucerne
		if("Battle Axe")
			backr = /obj/item/rogueweapon/stoneaxe/battle
		if("Lance + Kite Shield")
			r_hand = /obj/item/rogueweapon/spear/lance
			backr = /obj/item/rogueweapon/shield/tower/metal
		if("Samshir")
			r_hand = /obj/item/rogueweapon/sword/sabre/shamshir
	var/helmets = list(
		"Pigface Bascinet" 	= /obj/item/clothing/head/roguetown/helmet/bascinet/pigface,
		"Guard Helmet"		= /obj/item/clothing/head/roguetown/helmet/heavy/guard,
		"Barred Helmet"		= /obj/item/clothing/head/roguetown/helmet/heavy/sheriff,
		"Bucket Helmet"		= /obj/item/clothing/head/roguetown/helmet/heavy/bucket,
		"Knight Helmet"		= /obj/item/clothing/head/roguetown/helmet/heavy/knight,
		"Visored Sallet"			= /obj/item/clothing/head/roguetown/helmet/sallet/visored,
		"Armet"				= /obj/item/clothing/head/roguetown/helmet/heavy/knight/armet,
		"Hounskull Bascinet" 		= /obj/item/clothing/head/roguetown/helmet/bascinet/pigface/hounskull,
		"Etruscan Bascinet" 		= /obj/item/clothing/head/roguetown/helmet/bascinet/etruscan,
		"Slitted Kettle"		= /obj/item/clothing/head/roguetown/helmet/heavy/knight/skettle,
		"Kulah Khud"	= /obj/item/clothing/head/roguetown/helmet/sallet/raneshen,
		"None"
	)
	var/helmchoice = input("Choose your Helm.", "TAKE UP HELMS") as anything in helmets
	if(helmchoice != "None")
		head = helmets[helmchoice]

	var/armors = list(
		"Brigandine"		= /obj/item/clothing/suit/roguetown/armor/brigandine,
		"Coat of Plates"	= /obj/item/clothing/suit/roguetown/armor/brigandine/coatplates,
		"Steel Cuirass"		= /obj/item/clothing/suit/roguetown/armor/plate/half,				
		"Fluted Cuirass"	= /obj/item/clothing/suit/roguetown/armor/plate/half/fluted,
		"Scalemail"		= /obj/item/clothing/suit/roguetown/armor/plate/scale,
	)
	var/armorchoice = input("Choose your armor.", "TAKE UP ARMOR") as anything in armors
	armor = armors[armorchoice]
	gloves = /obj/item/clothing/gloves/roguetown/plate 
	pants = /obj/item/clothing/under/roguetown/chainlegs
	neck = /obj/item/clothing/neck/roguetown/bevor
	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor
	belt = /obj/item/storage/belt/rogue/leather/steel
	beltl = /obj/item/storage/belt/rogue/pouch/coins/poor
	backl = /obj/item/storage/backpack/rogue/satchel //gwstraps landing on backr asyncs with backpack_contents
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1,
		/obj/item/flashlight/flare/torch/lantern/prelit = 1,
		/obj/item/rope/chain = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/reagent_containers/glass/bottle/alchemical/healthpot = 1,	//Small health vial
		)

	wretch_select_bounty(H)

/datum/advclass/wretch/deserter/maa
	name = "Deserter"
	tutorial = "You had your post. You had your duty. Dissatisfied, lacking in morale, or simply thinking yourself better than it. - You decided to walk. Now it follows you everywhere you go."
	outfit = /datum/outfit/job/roguetown/wretch/desertermaa

	disallowed_races = list()

	cmode_music = 'sound/music/combat_bandit.ogg' // same as new hedgeknight music
	// Slightly more rounded. These can be nudged as needed.
	traits_applied = list(TRAIT_MEDIUMARMOR)
	subclass_stats = list(
		STATKEY_STR = 2,
		STATKEY_END = 2,
		STATKEY_INT = 1,
		STATKEY_CON = 1,
		STATKEY_PER = 1,
	)

	subclass_skills = list(
		/datum/skill/combat/polearms = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/swords = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/maces = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/axes = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/knives = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/whipsflails = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/shields = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/wrestling = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/unarmed = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/climbing = SKILL_LEVEL_EXPERT, // Better at climbing away than your average MaA. Only slightly.
		/datum/skill/misc/swimming = SKILL_LEVEL_JOURNEYMAN, // Worse at swimming than the above class.
		/datum/skill/misc/reading = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/athletics = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/riding = SKILL_LEVEL_JOURNEYMAN, // That saiga was stolen. Probably.
		/datum/skill/misc/tracking = SKILL_LEVEL_NOVICE,
	)

/datum/outfit/job/roguetown/wretch/desertermaa/pre_equip(mob/living/carbon/human/H)
	..()
	var/weapons = list("Warhammer & Shield","Sabre & Shield","Axe & Shield","Billhook","Greataxe","Halberd",)
	var/weapon_choice = input("Choose your weapon.", "TAKE UP ARMS") as anything in weapons
	H.set_blindness(0)
	switch(weapon_choice)
		if("Warhammer & Shield")
			beltr = /obj/item/rogueweapon/mace/warhammer
			backl = /obj/item/rogueweapon/shield/iron
		if("Sabre & Shield")
			beltr = /obj/item/rogueweapon/scabbard/sword
			r_hand = /obj/item/rogueweapon/sword/sabre
			backl = /obj/item/rogueweapon/shield/wood
		if("Axe & Shield")
			beltr = /obj/item/rogueweapon/stoneaxe/woodcut/steel
			backl = /obj/item/rogueweapon/shield/iron
		if("Billhook")
			r_hand = /obj/item/rogueweapon/spear/billhook 
		if("Halberd")
			r_hand = /obj/item/rogueweapon/halberd
		if("Greataxe")
			r_hand = /obj/item/rogueweapon/greataxe
	H.verbs |= list(/mob/living/carbon/human/mind/proc/setorderswretch)
	if(H.mind)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/order/retreat)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/order/bolster)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/order/brotherhood)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/order/charge)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/self/convertrole/brotherhood)


	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
	armor = /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk	
	pants = /obj/item/clothing/under/roguetown/chainlegs
	neck = /obj/item/clothing/neck/roguetown/chaincoif
	cloak = /obj/item/clothing/cloak/stabard/surcoat 
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	gloves = /obj/item/clothing/gloves/roguetown/chain 
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor/iron 
	beltl = /obj/item/rogueweapon/mace/cudgel
	belt = /obj/item/storage/belt/rogue/leather
	backr = /obj/item/storage/backpack/rogue/satchel
	backpack_contents = list(
		/obj/item/natural/cloth = 1,
		/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1,
		/obj/item/rope/chain = 1,
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/flashlight/flare/torch/lantern/prelit = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1
	)

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

	var/masks = list(
	"Steel Houndmask" 	= /obj/item/clothing/mask/rogue/facemask/steel/hound,
	"Steel Mask"		= /obj/item/clothing/mask/rogue/facemask/steel,
	"Wildguard"			= /obj/item/clothing/mask/rogue/wildguard,
	"None"
	)
	var/maskchoice = input("Choose your Mask.", "MASK MASK MASK") as anything in masks // Run from it. MASK. MASK. MASK.
	if(maskchoice != "None")
		mask = masks[maskchoice]	

	wretch_select_bounty(H)

/datum/advclass/wretch/mastermind
	name = "Mastermind"
	tutorial = "You're a puppeteer with a finger in every pie. You live in the shadows you entice others to cast."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	outfit = /datum/outfit/job/roguetown/wretch/mastermind
	category_tags = list(CTAG_WRETCH)
	traits_applied = list(TRAIT_DODGEEXPERT, TRAIT_RITUALIST, TRAIT_HERESIARCH) // Ritualist for greater undead, dodge expert to survive the valid hunters.
	maximum_possible_slots = 1
	subclass_languages = list(/datum/language/thievescant)

	subclass_skills = list(
		/datum/skill/craft/blacksmithing = SKILL_LEVEL_EXPERT, //Masterminds makes themselves useful to people. Buy their loyalty.
		/datum/skill/craft/armorsmithing = SKILL_LEVEL_EXPERT,
		/datum/skill/craft/weaponsmithing = SKILL_LEVEL_EXPERT,
		/datum/skill/craft/smelting = SKILL_LEVEL_EXPERT,
		/datum/skill/craft/engineering = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/sewing = SKILL_LEVEL_EXPERT,
		/datum/skill/craft/carpentry = SKILL_LEVEL_EXPERT,
		/datum/skill/craft/crafting = SKILL_LEVEL_EXPERT,
		/datum/skill/craft/masonry = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/medicine = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/wrestling = SKILL_LEVEL_JOURNEYMAN, //So you don't die to the first grab
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/swimming = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/reading = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/tracking = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/lockpicking = SKILL_LEVEL_EXPERT,
	)

/datum/outfit/job/roguetown/wretch/mastermind/pre_equip(mob/living/carbon/human/H)
	..()

	H.set_blindness(0)

	var/cleric_loadouts = list("Paladin", "Monk", "Missionary", "Cantor"),
	var/rogue_loadouts = list("Treasure Hunter", "Thief", "Bard", "Swashbuckler"),
	var/foreigner_loadouts = list("Roughneck", "Custodian"),
	var/mage_loadouts = list("Sorcerer, Spellblade, Spellsinger"),
	var/noble_loadouts = list("Aristocrat, Knight Errant, Squire Errant"),
	var/ranger_loadouts = list("Sentinel, Assassin, Bombadier, Biome Wanderer"),
	var/trader_loadouts = list("Peddler","Brewer","Jeweler","Doomsayer","Scholar","Harlequin"),
	var/warrior_loadouts = list("Battlemaster","Duelist","Barbarian","Monster Hunter","Flagellant","Leather Kini","Hide Armor Kini","Studded Leather Kini")

	var/loadout_type = input("Choose your guise type.", "Who am I pretending to be?") as anything in list("Cleric", "Rogue", "Foreigner", "Mage", "Noble", "Ranger", "Trader", "Warrior")

	if(loadout_type == "Cleric")
		var/loadout_choice = input("Choose your guise.", "My mask") as anything in cleric_loadouts
		switch(loadout_choice)
			if("Paladin")
				belt = /obj/item/storage/belt/rogue/leather
				backl = /obj/item/storage/backpack/rogue/satchel
				backr = /obj/item/rogueweapon/shield/iron
				armor = /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk
				shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt
				wrists = /obj/item/clothing/wrists/roguetown/bracers
				pants = /obj/item/clothing/under/roguetown/chainlegs
				shoes = /obj/item/clothing/shoes/roguetown/boots
				gloves = /obj/item/clothing/gloves/roguetown/chain
				beltl = /obj/item/storage/belt/rogue/pouch/coins/poor

				var/weapons = list("Longsword", "Mace", "Flail")
				var/weapon_choice = input("Choose your weapon.", "Take up arms") as anything in weapons
				switch(weapon_choice)
					if("Longsword")
						beltr = /obj/item/rogueweapon/sword/long
					if("Mace")
						beltr = /obj/item/rogueweapon/mace
					if("Flail")
						beltr = /obj/item/rogueweapon/flail

			if("Monk")
				shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/priest
				armor = /obj/item/clothing/suit/roguetown/shirt/robe/monk
				pants = /obj/item/clothing/under/roguetown/tights/black
				wrists = /obj/item/clothing/wrists/roguetown/bracers/leather/heavy
				shoes = /obj/item/clothing/shoes/roguetown/sandals
				backl = /obj/item/storage/backpack/rogue/satchel
				belt = /obj/item/storage/belt/rogue/leather/rope
				beltl = /obj/item/storage/belt/rogue/pouch/coins/poor

			if("Missionary")
				shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/priest
				pants = /obj/item/clothing/under/roguetown/trou/leather
				shoes = /obj/item/clothing/shoes/roguetown/boots
				backr = /obj/item/rogueweapon/woodstaff
				belt = /obj/item/storage/belt/rogue/leather
				beltr = /obj/item/flashlight/flare/torch/lantern
				backpack_contents = list(
					/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
					/obj/item/flashlight/flare/torch = 1
				)

			if("Cantor")
				head = /obj/item/clothing/head/roguetown/bardhat
				armor = /obj/item/clothing/suit/roguetown/armor/leather/vest
				backl = /obj/item/storage/backpack/rogue/satchel
				shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
				gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
				wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
				pants = /obj/item/clothing/under/roguetown/trou/leather
				shoes = /obj/item/clothing/shoes/roguetown/boots/leather
				belt = /obj/item/storage/belt/rogue/leather/knifebelt/iron
				beltr = /obj/item/rogueweapon/huntingknife/idagger/steel/special
				beltl = /obj/item/storage/belt/rogue/pouch/coins/poor

				var/instruments = list("Lute", "Harp", "Viola", "Trumpet")
				var/instrument_choice = input("Choose your instrument.", "Your weapon of influence") as anything in instruments
				switch(instrument_choice)
					if("Lute")
						backr = /obj/item/rogue/instrument/lute
					if("Harp")
						backr = /obj/item/rogue/instrument/harp
					if("Viola")
						backr = /obj/item/rogue/instrument/viola
					if("Trumpet")
						backr = /obj/item/rogue/instrument/trumpet

	if(loadout_type == "Rogue")
		var/loadout_choice = input("Choose your rogue archetype.", "My mask") as anything in rogue_loadouts
		switch(loadout_choice)
			if("Treasure Hunter")
				pants = /obj/item/clothing/under/roguetown/trou/leather
				armor = /obj/item/clothing/suit/roguetown/armor/leather/vest/sailor
				backl = /obj/item/storage/backpack/rogue/satchel
				belt = /obj/item/storage/belt/rogue/leather
				gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
				shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
				shoes = /obj/item/clothing/shoes/roguetown/boots/leather
				neck = /obj/item/storage/belt/rogue/pouch/coins/poor
				backr = /obj/item/rogueweapon/shovel
				head = /obj/item/clothing/head/roguetown/fedora
				beltl = /obj/item/flashlight/flare/torch/lantern
				wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
				backpack_contents = list(/obj/item/lockpick = 1, /obj/item/rogueweapon/huntingknife = 1, /obj/item/recipe_book/survival = 1)

			if("Thief")
				pants = /obj/item/clothing/under/roguetown/trou/leather
				armor = /obj/item/clothing/suit/roguetown/armor/leather
				cloak = /obj/item/clothing/cloak/raincloak/mortus
				shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
				backl = /obj/item/storage/backpack/rogue/backpack
				backr = /obj/item/gun/ballistic/revolver/grenadelauncher/bow
				belt = /obj/item/storage/belt/rogue/leather/knifebelt/iron
				gloves = /obj/item/clothing/gloves/roguetown/fingerless
				shoes = /obj/item/clothing/shoes/roguetown/boots
				neck = /obj/item/storage/belt/rogue/pouch/coins/poor
				wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
				beltl = /obj/item/rogueweapon/mace/cudgel
				beltr = /obj/item/quiver/Warrows
				backpack_contents = list(/obj/item/flashlight/flare/torch = 1, /obj/item/rogueweapon/huntingknife/idagger/steel = 2, /obj/item/lockpickring/mundane = 1, /obj/item/recipe_book/survival = 1)
				

			if("Bard")
				head = /obj/item/clothing/head/roguetown/bardhat
				shoes = /obj/item/clothing/shoes/roguetown/boots
				neck = /obj/item/storage/belt/rogue/pouch/coins/poor
				pants = /obj/item/clothing/under/roguetown/trou/leather
				shirt = /obj/item/clothing/suit/roguetown/shirt/shortshirt
				gloves = /obj/item/clothing/gloves/roguetown/fingerless
				belt = /obj/item/storage/belt/rogue/leather
				beltl = /obj/item/flashlight/flare/torch/lantern
				beltr = /obj/item/rogueweapon/huntingknife/idagger/steel
				armor = /obj/item/clothing/suit/roguetown/armor/leather/vest
				backl = /obj/item/storage/backpack/rogue/satchel
				cloak = /obj/item/clothing/cloak/half/red
				backpack_contents = list(/obj/item/lockpick = 1, /obj/item/recipe_book/survival = 1)

			if("Swashbuckler")
				head = /obj/item/clothing/head/roguetown/helmet/tricorn
				pants = /obj/item/clothing/under/roguetown/tights/sailor
				armor = /obj/item/clothing/suit/roguetown/armor/leather/vest/sailor
				shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/sailor/red
				backl = /obj/item/storage/backpack/rogue/satchel
				backr = /obj/item/rogue/instrument/hurdygurdy
				belt = /obj/item/storage/belt/rogue/leather/knifebelt/iron
				shoes = /obj/item/clothing/shoes/roguetown/boots/leather
				neck = /obj/item/storage/belt/rogue/pouch/coins/poor
				wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
				beltl = /obj/item/flashlight/flare/torch/lantern
				beltr = /obj/item/rogueweapon/sword/cutlass
				backpack_contents = list(/obj/item/bomb = 1, /obj/item/lockpick = 1, /obj/item/rogueweapon/huntingknife/idagger/steel/parrying = 1, /obj/item/recipe_book/survival = 1)

	if(loadout_type == "Foreigner")
		var/loadout_choice = input("Choose your archetype.", "My mask") as anything in foreigner_loadouts
		switch(loadout_choice)
			if("Roughneck")
				head = /obj/item/clothing/head/roguetown/mentorhat
				gloves = /obj/item/clothing/gloves/roguetown/eastgloves1
				pants = /obj/item/clothing/under/roguetown/heavy_leather_pants/eastpants1
				shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/eastshirt1
				armor = /obj/item/clothing/suit/roguetown/armor/basiceast
				shoes = /obj/item/clothing/shoes/roguetown/boots
				neck = /obj/item/storage/belt/rogue/pouch/coins/poor
				beltr = /obj/item/rogueweapon/scabbard/sword/kazengun
				beltl = /obj/item/rogueweapon/sword/sabre/mulyeog
				belt = /obj/item/storage/belt/rogue/leather/black
				backr = /obj/item/storage/backpack/rogue/satchel

			if("Custodian")
				head = /obj/item/clothing/head/roguetown/mentorhat
				gloves = /obj/item/clothing/gloves/roguetown/eastgloves1
				pants = pants = /obj/item/clothing/under/roguetown/heavy_leather_pants/eastpants1
				shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/eastshirt2
				armor = /obj/item/clothing/suit/roguetown/armor/basiceast/mentorsuit
				shoes = /obj/item/clothing/shoes/roguetown/boots
				belt = /obj/item/storage/belt/rogue/leather/
				beltl = /obj/item/flashlight/flare/torch/lantern
				backl = /obj/item/storage/backpack/rogue/satchel

	if(loadout_type == "Mage")
		var/loadout_choice = input("Choose your archetype.", "My mask") as anything in mage_loadouts
		switch(loadout_choice)
			if("Sorcerer")
				head = /obj/item/clothing/head/roguetown/roguehood/mage
				shoes = /obj/item/clothing/shoes/roguetown/boots
				pants = /obj/item/clothing/under/roguetown/trou/leather
				shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
				armor = /obj/item/clothing/suit/roguetown/shirt/robe/mage
				belt = /obj/item/storage/belt/rogue/leather
				beltr = /obj/item/reagent_containers/glass/bottle/rogue/manapot
				neck = /obj/item/storage/belt/rogue/pouch/coins/poor
				beltl = /obj/item/rogueweapon/huntingknife
				backl = /obj/item/storage/backpack/rogue/satchel
				backr = /obj/item/rogueweapon/woodstaff

			if("Spellblade")
				head = /obj/item/clothing/head/roguetown/bucklehat
				shoes = /obj/item/clothing/shoes/roguetown/boots
				pants = /obj/item/clothing/under/roguetown/trou/leather
				shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
				gloves = /obj/item/clothing/gloves/roguetown/angle
				belt = /obj/item/storage/belt/rogue/leather
				neck = /obj/item/clothing/neck/roguetown/chaincoif
				backl = /obj/item/storage/backpack/rogue/satchel
				beltl = /obj/item/storage/belt/rogue/pouch/coins/poor
				wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
				backpack_contents = list(/obj/item/flashlight/flare/torch = 1, /obj/item/recipe_book/survival = 1)
				var/weapons = list("Bastard Sword", "Falchion & Wooden Shield", "Messer & Wooden Shield")
				var/weapon_choice = input("Choose your weapon.", "TAKE UP ARMS") as anything in weapons
				switch(weapon_choice)
					if("Bastard Sword")
						beltr = /obj/item/rogueweapon/sword/long
					if("Falchion & Wooden Shield")
						beltr = /obj/item/rogueweapon/sword/falchion
						backr = /obj/item/rogueweapon/shield/wood
					if("Messer & Wooden Shield")
						beltr = /obj/item/rogueweapon/sword/iron/messer
						backr = /obj/item/rogueweapon/shield/wood

			if("Spellsinger")
				head = /obj/item/clothing/head/roguetown/spellcasterhat
				shoes = /obj/item/clothing/shoes/roguetown/boots
				pants = /obj/item/clothing/under/roguetown/trou/leather
				shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/councillor
				gloves = /obj/item/clothing/gloves/roguetown/angle
				belt = /obj/item/storage/belt/rogue/leather
				neck = /obj/item/clothing/neck/roguetown/gorget/steel
				armor = /obj/item/clothing/suit/roguetown/shirt/robe/spellcasterrobe
				backl = /obj/item/storage/backpack/rogue/satchel
				beltl = /obj/item/storage/belt/rogue/pouch/coins/poor
				wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
				beltr = /obj/item/rogueweapon/sword/sabre
				backpack_contents = list(/obj/item/flashlight/flare/torch = 1, /obj/item/recipe_book/survival = 1)
				var/weapons = list("Harp","Lute","Accordion","Guitar","Hurdy-Gurdy","Viola","Vocal Talisman","Trumpet")
				var/weapon_choice = input("Choose your instrument.", "TAKE UP ARMS") as anything in weapons
				switch(weapon_choice)
					if("Harp")
						backr = /obj/item/rogue/instrument/harp
					if("Lute")
						backr = /obj/item/rogue/instrument/lute
					if("Accordion")
						backr = /obj/item/rogue/instrument/accord
					if("Guitar")
						backr = /obj/item/rogue/instrument/guitar
					if("Hurdy-Gurdy")
						backr = /obj/item/rogue/instrument/hurdygurdy
					if("Viola")
						backr = /obj/item/rogue/instrument/viola
					if("Vocal Talisman")
						backr = /obj/item/rogue/instrument/vocals
					if("Trumpet")
						backr = /obj/item/rogue/instrument/trumpet

	if(loadout_type == "Noble")
		var/loadout_choice = input("Choose your noble archetype.", "My mask") as anything in noble_loadouts
		switch(loadout_choice)
			if("Aristocrat")
				to_chat(H, span_warning("You are a traveling noble visiting foreign lands. With wealth, come the poor, ready to pilfer you of your hard earned (inherited) coin, so tread lightly unless you want to meet a grizzly end."))
				shoes = /obj/item/clothing/shoes/roguetown/boots
				belt = /obj/item/storage/belt/rogue/leather/black
				beltr = /obj/item/flashlight/flare/torch/lantern
				backl = /obj/item/storage/backpack/rogue/satchel
				neck = /obj/item/storage/belt/rogue/pouch/coins/rich
				id = /obj/item/clothing/ring/silver
				beltl = /obj/item/rogueweapon/sword/sabre/dec
				if(should_wear_masc_clothes(H))
					cloak = /obj/item/clothing/cloak/half/red
					shirt = /obj/item/clothing/suit/roguetown/shirt/tunic/red
					pants = /obj/item/clothing/under/roguetown/tights/black
				if(should_wear_femme_clothes(H))
					shirt = /obj/item/clothing/suit/roguetown/shirt/dress/gen/purple
					cloak = /obj/item/clothing/cloak/raincloak/purple
				var/turf/TU = get_turf(H)
				if(TU)
					new /mob/living/simple_animal/hostile/retaliate/rogue/saiga/tame/saddled(TU)
				H.set_blindness(0)

			if("Knight Errant")
				var/helmets = list(
					"Pigface Bascinet" 	= /obj/item/clothing/head/roguetown/helmet/bascinet/pigface,
					"Guard Helmet"		= /obj/item/clothing/head/roguetown/helmet/heavy/guard,
					"Barred Helmet"		= /obj/item/clothing/head/roguetown/helmet/heavy/sheriff,
					"Bucket Helmet"		= /obj/item/clothing/head/roguetown/helmet/heavy/bucket,
					"Knight Helmet"		= /obj/item/clothing/head/roguetown/helmet/heavy/knight,
					"Visored Sallet"	= /obj/item/clothing/head/roguetown/helmet/sallet/visored,
					"Armet"				= /obj/item/clothing/head/roguetown/helmet/heavy/knight/armet,
					"Hounskull Bascinet"= /obj/item/clothing/head/roguetown/helmet/bascinet/pigface/hounskull,
					"Etruscan Bascinet"	= /obj/item/clothing/head/roguetown/helmet/bascinet/etruscan,
					"Slitted Kettle"	= /obj/item/clothing/head/roguetown/helmet/heavy/knight/skettle,
					"None"
				)
				var/helmchoice = input("Choose your Helm.", "TAKE UP HELMS") as anything in helmets
				if(helmchoice != "None")
					head = helmets[helmchoice]

				var/armors2 = list(
					"Brigandine"	= /obj/item/clothing/suit/roguetown/armor/brigandine,
					"Coat of Plates"= /obj/item/clothing/suit/roguetown/armor/brigandine/coatplates,
					"Steel Cuirass"= /obj/item/clothing/suit/roguetown/armor/plate/half
				)
				var/armorchoice = input("Choose your armor.", "TAKE UP ARMOR") as anything in armors2
				armor = armors2[armorchoice]

				gloves = /obj/item/clothing/gloves/roguetown/chain
				pants = /obj/item/clothing/under/roguetown/chainlegs
				cloak = /obj/item/clothing/cloak/stabard
				neck = /obj/item/clothing/neck/roguetown/bevor
				shirt = /obj/item/clothing/suit/roguetown/armor/chainmail
				wrists = /obj/item/clothing/wrists/roguetown/bracers
				shoes = /obj/item/clothing/shoes/roguetown/boots/armor
				belt = /obj/item/storage/belt/rogue/leather/steel/tasset
				backl = /obj/item/storage/backpack/rogue/satchel
				beltl = /obj/item/flashlight/flare/torch/lantern
				backpack_contents = list(/obj/item/storage/belt/rogue/pouch/coins/poor = 1, /obj/item/recipe_book/survival = 1)

			if("Squire Errant")
				head = /obj/item/clothing/head/roguetown/roguehood
				wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
				cloak = /obj/item/clothing/cloak/stabard
				neck = /obj/item/clothing/neck/roguetown/chaincoif/iron
				shoes = /obj/item/clothing/shoes/roguetown/boots
				belt = /obj/item/storage/belt/rogue/leather
				backr = /obj/item/storage/backpack/rogue/satchel
				beltl = /obj/item/flashlight/flare/torch/lantern
				backpack_contents = list(/obj/item/storage/belt/rogue/pouch/coins/poor = 1, /obj/item/rogueweapon/hammer/iron = 1, /obj/item/rogueweapon/tongs = 1, /obj/item/recipe_book/survival = 1)
				var/armors = list("Light Armor","Medium Armor")
				var/armor_choice = input("Choose your armor.", "TAKE UP ARMS") as anything in armors
				switch(armor_choice)
					if("Light Armor")
						shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
						pants = /obj/item/clothing/under/roguetown/trou/leather
						gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
						beltr = /obj/item/rogueweapon/huntingknife/idagger
					if("Medium Armor")
						shirt = /obj/item/clothing/suit/roguetown/armor/chainmail/iron
						pants = /obj/item/clothing/under/roguetown/chainlegs/iron
						gloves = /obj/item/clothing/gloves/roguetown/chain/iron
						beltr = /obj/item/rogueweapon/sword/iron

	if(loadout_type == "Ranger")
		var/loadout_choice = input("Choose your guise.", "My mask") as anything in ranger_loadouts
		switch(loadout_choice)
			if("Sentinel")
				shoes = /obj/item/clothing/shoes/roguetown/boots/leather
				shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt
				neck = /obj/item/storage/belt/rogue/pouch/coins/poor
				pants = /obj/item/clothing/under/roguetown/trou/leather
				gloves = /obj/item/clothing/gloves/roguetown/leather
				wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
				belt = /obj/item/storage/belt/rogue/leather
				armor = /obj/item/clothing/suit/roguetown/armor/leather/hide
				cloak = /obj/item/clothing/cloak/raincloak/green
				backl = /obj/item/storage/backpack/rogue/satchel
				beltr = /obj/item/flashlight/flare/torch/lantern
				backpack_contents = list(/obj/item/bait = 1, /obj/item/rogueweapon/huntingknife = 1, /obj/item/recipe_book/survival = 1)
				var/weapons = list("Recurve Bow","Crossbow")
				var/weapon_choice = input("Choose your weapon.", "TAKE UP ARMS") as anything in weapons
				switch(weapon_choice)
					if("Recurve Bow")
						backr = /obj/item/gun/ballistic/revolver/grenadelauncher/bow/recurve
						beltl = /obj/item/quiver/arrows
					if("Crossbow")
						backr = /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow
						beltl = /obj/item/quiver/bolts

			if("Assassin")
				shoes = /obj/item/clothing/shoes/roguetown/boots
				neck = /obj/item/storage/belt/rogue/pouch/coins/poor
				pants = /obj/item/clothing/under/roguetown/trou/leather
				shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/black
				gloves = /obj/item/clothing/gloves/roguetown/fingerless
				wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
				belt = /obj/item/storage/belt/rogue/leather/knifebelt/iron
				armor = /obj/item/clothing/suit/roguetown/armor/leather
				cloak = /obj/item/clothing/cloak/raincloak/mortus
				backl = /obj/item/storage/backpack/rogue/satchel
				beltl = /obj/item/rogueweapon/huntingknife/idagger/steel
				beltr = /obj/item/quiver/bolts
				backr = /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow
				backpack_contents = list(/obj/item/flashlight/flare/torch = 1, /obj/item/recipe_book/survival = 1)

			if("Bombadier")
				shoes = /obj/item/clothing/shoes/roguetown/boots
				neck = /obj/item/storage/belt/rogue/pouch/coins/poor
				head = /obj/item/clothing/head/roguetown/roguehood
				wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
				gloves = /obj/item/clothing/gloves/roguetown/fingerless
				pants = /obj/item/clothing/under/roguetown/chainlegs/iron
				armor = /obj/item/clothing/suit/roguetown/shirt/robe/mageorange
				shirt = /obj/item/clothing/suit/roguetown/armor/chainmail/iron
				belt = /obj/item/storage/belt/rogue/leather
				backl = /obj/item/storage/backpack/rogue/satchel
				beltr = /obj/item/flashlight/flare/torch/lantern
				beltl = /obj/item/rogueweapon/mace/cudgel
				backpack_contents = list(/obj/item/bomb = 4, /obj/item/rogueweapon/huntingknife = 1, /obj/item/recipe_book/survival = 1)

			if("Biome Wanderer")
				head = /obj/item/clothing/head/roguetown/helmet/leather/volfhelm
				shoes = /obj/item/clothing/shoes/roguetown/boots/leather
				shirt = /obj/item/clothing/suit/roguetown/shirt/tunic
				neck = /obj/item/storage/belt/rogue/pouch/coins/poor
				wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
				belt = /obj/item/storage/belt/rogue/leather
				cloak = /obj/item/clothing/cloak/raincloak/green
				backl = /obj/item/storage/backpack/rogue/satchel
				beltr = /obj/item/rogueweapon/stoneaxe/woodcut
				backpack_contents = list(/obj/item/rogueweapon/huntingknife = 1, /obj/item/flashlight/flare/torch/lantern = 1)
				var/weapons = list("Recurve Bow","Billhook","Sling","Crossbow")
				var/weapon_choice = input("Choose your weapon.", "TAKE UP ARMS") as anything in weapons
				switch(weapon_choice)
					if("Recurve Bow")
						backr = /obj/item/gun/ballistic/revolver/grenadelauncher/bow/recurve
						beltl = /obj/item/quiver/arrows
					if("Billhook")
						r_hand = /obj/item/rogueweapon/spear/billhook
					if("Sling")
						r_hand = /obj/item/gun/ballistic/revolver/grenadelauncher/sling
						beltl = /obj/item/quiver/sling/iron
					if("Crossbow")
						backr = /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow
						beltl = /obj/item/quiver/bolts
				var/armors = list("Light Armor","Medium Armor")
				var/armor_choice = input("Choose your armor.", "TAKE UP ARMS") as anything in armors
				switch(armor_choice)
					if("Light Armor")
						armor = /obj/item/clothing/suit/roguetown/armor/leather/hide
						pants = /obj/item/clothing/under/roguetown/heavy_leather_pants
						gloves = /obj/item/clothing/gloves/roguetown/fingerless
					if("Medium Armor")
						armor = /obj/item/clothing/suit/roguetown/armor/chainmail/iron
						pants = /obj/item/clothing/under/roguetown/chainlegs/iron
						gloves = /obj/item/clothing/gloves/roguetown/chain/iron

	if(loadout_type == "Trader")
		var/loadout_choice = input("Choose your guise.", "My mask") as anything in trader_loadouts
		switch(loadout_choice)
			if("Peddler")
				head = /obj/item/clothing/head/roguetown/roguehood
				mask = /obj/item/clothing/mask/rogue/facemask/steel
				shoes = /obj/item/clothing/shoes/roguetown/boots
				neck = /obj/item/storage/belt/rogue/pouch/coins/mid
				pants = /obj/item/clothing/under/roguetown/tights/black
				shirt = /obj/item/clothing/suit/roguetown/shirt/robe
				belt = /obj/item/storage/belt/rogue/leather
				backl = /obj/item/storage/backpack/rogue/satchel
				backr = /obj/item/storage/backpack/rogue/satchel
				beltr = /obj/item/storage/belt/rogue/surgery_bag/full
				beltl = /obj/item/flashlight/flare/torch/lantern
				backpack_contents = list(
					/obj/item/reagent_containers/powder/spice = 2,
					/obj/item/reagent_containers/powder/ozium = 1,
					/obj/item/reagent_containers/powder/moondust = 2,
					/obj/item/rogueweapon/huntingknife = 1,
					/obj/item/recipe_book/survival = 1
				)

			if("Brewer")
				mask = /obj/item/clothing/mask/rogue/ragmask/black
				shoes = /obj/item/clothing/shoes/roguetown/boots
				neck = /obj/item/storage/belt/rogue/pouch/coins/mid
				pants = /obj/item/clothing/under/roguetown/tights/black
				cloak = /obj/item/clothing/suit/roguetown/armor/longcoat
				shirt = /obj/item/clothing/suit/roguetown/shirt/tunic/red
				belt = /obj/item/storage/belt/rogue/leather/black
				backl = /obj/item/storage/backpack/rogue/satchel
				backr = /obj/item/storage/backpack/rogue/satchel
				beltr = /obj/item/rogueweapon/mace/cudgel
				beltl = /obj/item/flashlight/flare/torch/lantern
				backpack_contents = list(
					/obj/item/reagent_containers/glass/bottle/rogue/beer/gronnmead = 1,
					/obj/item/reagent_containers/glass/bottle/rogue/beer/voddena = 1,
					/obj/item/reagent_containers/glass/bottle/rogue/beer/blackgoat = 1,
					/obj/item/reagent_containers/glass/bottle/rogue/elfred = 1,
					/obj/item/reagent_containers/glass/bottle/rogue/elfblue = 1,
					/obj/item/rogueweapon/huntingknife = 1,
					/obj/item/ingot/copper = 2,
					/obj/item/roguegear = 1,
					/obj/item/recipe_book/survival = 1
				)

			if("Jeweler")
				mask = /obj/item/clothing/mask/rogue/lordmask
				shoes = /obj/item/clothing/shoes/roguetown/boots
				pants = /obj/item/clothing/under/roguetown/tights/black
				shirt = /obj/item/clothing/suit/roguetown/shirt/tunic/purple
				belt = /obj/item/storage/belt/rogue/leather/black
				cloak = /obj/item/clothing/cloak/raincloak/purple
				backl = /obj/item/storage/backpack/rogue/satchel
				backr = /obj/item/storage/backpack/rogue/satchel
				neck = /obj/item/storage/belt/rogue/pouch/coins/mid
				beltl = /obj/item/flashlight/flare/torch/lantern
				beltr = /obj/item/rogueweapon/huntingknife
				backpack_contents = list(
					/obj/item/clothing/ring/silver = 2,
					/obj/item/clothing/ring/gold = 1,
					/obj/item/rogueweapon/tongs = 1,
					/obj/item/rogueweapon/hammer/steel = 1,
					/obj/item/roguegem/yellow = 1,
					/obj/item/roguegem/green = 1,
					/obj/item/recipe_book/survival = 1
				)

			if("Doomsayer")
				head = /obj/item/clothing/head/roguetown/roguehood/black
				mask = /obj/item/clothing/mask/rogue/skullmask
				shoes = /obj/item/clothing/shoes/roguetown/boots
				pants = /obj/item/clothing/under/roguetown/tights/black
				shirt = /obj/item/clothing/suit/roguetown/shirt/tunic/black
				belt = /obj/item/storage/belt/rogue/leather/black
				cloak = /obj/item/clothing/cloak/half
				backl = /obj/item/storage/backpack/rogue/satchel
				backr = /obj/item/storage/backpack/rogue/satchel
				neck = /obj/item/storage/belt/rogue/pouch/coins/mid
				beltl = /obj/item/flashlight/flare/torch/lantern
				beltr = /obj/item/rogueweapon/stoneaxe/woodcut
				backpack_contents = list(
					/obj/item/clothing/neck/roguetown/psicross/silver = 3,
					/obj/item/clothing/neck/roguetown/psicross = 2,
					/obj/item/clothing/neck/roguetown/psicross/wood = 1,
					/obj/item/rogueweapon/huntingknife = 1,
					/obj/item/recipe_book/survival = 1
				)

			if("Scholar")
				head = /obj/item/clothing/head/roguetown/roguehood/black
				mask = /obj/item/clothing/mask/rogue/spectacles/golden
				shoes = /obj/item/clothing/shoes/roguetown/boots
				pants = /obj/item/clothing/under/roguetown/tights/black
				shirt = /obj/item/clothing/suit/roguetown/shirt/robe/mageyellow
				belt = /obj/item/storage/belt/rogue/leather/black
				backl = /obj/item/storage/backpack/rogue/satchel
				backr = /obj/item/storage/backpack/rogue/satchel
				neck = /obj/item/storage/belt/rogue/pouch/coins/mid
				beltl = /obj/item/flashlight/flare/torch/lantern
				beltr = /obj/item/rogueweapon/huntingknife/idagger
				backpack_contents = list(
					/obj/item/paper/scroll = 3,
					/obj/item/book/rogue/knowledge1 = 1,
					/obj/item/reagent_containers/glass/bottle/rogue/manapot = 1,
					/obj/item/reagent_containers/glass/bottle/rogue/strongmanapot = 1,
					/obj/item/natural/feather = 1,
					/obj/item/roguegem/amethyst = 1,
					/obj/item/recipe_book/survival = 1
				)

			if("Harlequin")
				shoes = /obj/item/clothing/shoes/roguetown/jester
				pants = /obj/item/clothing/under/roguetown/tights
				armor = /obj/item/clothing/suit/roguetown/shirt/jester
				belt = /obj/item/storage/belt/rogue/leather
				beltr = /obj/item/rogueweapon/huntingknife/idagger
				beltl = /obj/item/flashlight/flare/torch/lantern
				backl = /obj/item/storage/backpack/rogue/satchel
				head = /obj/item/clothing/head/roguetown/jester
				neck = /obj/item/storage/belt/rogue/pouch/coins/mid
				backpack_contents = list(
					/obj/item/smokebomb = 3,
					/obj/item/storage/pill_bottle/dice = 1,
					/obj/item/toy/cards/deck = 1,
					/obj/item/recipe_book/survival = 1
				)
				var/weapons = list("Harp","Lute","Accordion","Guitar","Hurdy-Gurdy","Viola","Vocal Talisman","Trumpet")
				var/weapon_choice = input("Choose your instrument.", "TAKE UP ARMS") as anything in weapons
				switch(weapon_choice)
					if("Harp")
						backr = /obj/item/rogue/instrument/harp
					if("Lute")
						backr = /obj/item/rogue/instrument/lute
					if("Accordion")
						backr = /obj/item/rogue/instrument/accord
					if("Guitar")
						backr = /obj/item/rogue/instrument/guitar
					if("Hurdy-Gurdy")
						backr = /obj/item/rogue/instrument/hurdygurdy
					if("Viola")
						backr = /obj/item/rogue/instrument/viola
					if("Vocal Talisman")
						backr = /obj/item/rogue/instrument/vocals
					if("Trumpet")
						backr = /obj/item/rogue/instrument/trumpet

	if(loadout_type == "Warrior")
		var/loadout_choice = input("Choose your guise.", "My mask") as anything in warrior_loadouts
		switch(loadout_choice)
			if("Battlemaster")
				var/weapons = list("Longsword","Mace","Billhook","Battle Axe","Short Sword & Iron Shield")
				var/weapon_choice = input("Choose your weapon.", "TAKE UP ARMS") as anything in weapons
				switch(weapon_choice)
					if("Longsword")
						backr = /obj/item/rogueweapon/sword/long
					if("Mace")
						beltr = /obj/item/rogueweapon/mace
					if("Billhook")
						r_hand = /obj/item/rogueweapon/spear/billhook
					if("Battle Axe")
						backr = /obj/item/rogueweapon/stoneaxe/battle
					if("Short Sword & Iron Shield")
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

			if("Duelist")
				var/weapons = list("Rapier","Dagger")
				var/weapon_choice = input("Choose your weapon.", "TAKE UP ARMS") as anything in weapons
				switch(weapon_choice)
					if("Rapier")
						beltr = /obj/item/rogueweapon/sword/rapier
					if("Dagger")
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
				gloves = /obj/item/clothing/gloves/roguetown/fingerless
				backl = /obj/item/storage/backpack/rogue/satchel
				backr = /obj/item/rogueweapon/shield/buckler
				belt = /obj/item/storage/belt/rogue/leather

			if("Barbarian")
				var/weapons = list("Katar","Axe","Sword","Club","Spear")
				var/weapon_choice = input("Choose your weapon.", "TAKE UP ARMS") as anything in weapons
				switch(weapon_choice)
					if("Katar")
						beltr = /obj/item/rogueweapon/katar
					if("Axe")
						beltr = /obj/item/rogueweapon/stoneaxe/boneaxe
					if("Sword")
						beltr = /obj/item/rogueweapon/sword/short
					if("Club")
						beltr = /obj/item/rogueweapon/mace/woodclub
					if("Spear")
						r_hand = /obj/item/rogueweapon/spear/bonespear
				backl = /obj/item/storage/backpack/rogue/satchel
				belt = /obj/item/storage/belt/rogue/leather
				neck = /obj/item/storage/belt/rogue/pouch/coins/poor
				beltl = /obj/item/rogueweapon/huntingknife
				head = /obj/item/clothing/head/roguetown/helmet/leather/volfhelm
				wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
				pants = /obj/item/clothing/under/roguetown/heavy_leather_pants
				shoes = /obj/item/clothing/shoes/roguetown/boots
				gloves = /obj/item/clothing/gloves/roguetown/fingerless

			if("Monster Hunter")
				beltr = /obj/item/rogueweapon/sword/silver
				backr = /obj/item/rogueweapon/sword
				backl = /obj/item/storage/backpack/rogue/satchel/black
				wrists = /obj/item/clothing/neck/roguetown/psicross/silver
				armor = /obj/item/clothing/suit/roguetown/shirt/undershirt/puritan
				shirt = /obj/item/clothing/suit/roguetown/armor/chainmail
				belt = /obj/item/storage/belt/rogue/leather/knifebelt/black/steel
				shoes = /obj/item/clothing/shoes/roguetown/boots
				pants = /obj/item/clothing/under/roguetown/tights/black
				cloak = /obj/item/clothing/cloak/cape/puritan
				neck = /obj/item/storage/belt/rogue/pouch/coins/poor
				head = /obj/item/clothing/head/roguetown/bucklehat
				gloves = /obj/item/clothing/gloves/roguetown/angle
				backpack_contents = list(/obj/item/flashlight/flare/torch = 1, /obj/item/rogueweapon/huntingknife = 1, /obj/item/recipe_book/survival = 1)
				beltl = pick(
					/obj/item/reagent_containers/glass/bottle/alchemical/strpot,
					/obj/item/reagent_containers/glass/bottle/alchemical/conpot,
					/obj/item/reagent_containers/glass/bottle/alchemical/endpot,
					/obj/item/reagent_containers/glass/bottle/alchemical/spdpot,
					/obj/item/reagent_containers/glass/bottle/alchemical/perpot,
					/obj/item/reagent_containers/glass/bottle/alchemical/intpot,
					/obj/item/reagent_containers/glass/bottle/alchemical/lucpot)

			if("Flagellant")
				pants = /obj/item/clothing/under/roguetown/tights/black
				shirt = /obj/item/clothing/suit/roguetown/shirt/tunic/black
				shoes = /obj/item/clothing/shoes/roguetown/boots
				backl = /obj/item/storage/backpack/rogue/satchel
				belt = /obj/item/storage/belt/rogue/leather
				beltr = /obj/item/rogueweapon/whip
				beltl = /obj/item/storage/belt/rogue/pouch/coins/poor
				backpack_contents = list(/obj/item/recipe_book/survival = 1, /obj/item/flashlight/flare/torch = 1)
			
			if("Leather Kini")
				armor = /obj/item/clothing/suit/roguetown/armor/leather/bikini
				pants = /obj/item/clothing/under/roguetown/heavy_leather_pants/shorts
				wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
				shoes = /obj/item/clothing/shoes/roguetown/boots/furlinedboots
				gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
				backl = /obj/item/storage/backpack/rogue/satchel
				belt = /obj/item/storage/belt/rogue/leather
				neck = /obj/item/storage/belt/rogue/pouch/coins/poor
				backpack_contents = list(/obj/item/flashlight/flare/torch = 1, /obj/item/rogueweapon/huntingknife = 1)
				var/weapons = list("Steel Knuckles","Axe","Sword","Whip","Spear")
				var/weapon_choice = input("Choose your weapon.", "TAKE UP ARMS") as anything in weapons
				switch(weapon_choice)
					if("Steel Knuckles")
						beltr = /obj/item/rogueweapon/knuckles
					if("Axe")
						beltr = /obj/item/rogueweapon/stoneaxe/boneaxe
					if("Sword")
						beltr = /obj/item/rogueweapon/sword/short
					if("Whip")
						beltr = /obj/item/rogueweapon/whip
					if("Spear")
						r_hand = /obj/item/rogueweapon/spear/bonespear

			if("Hide Armor Kini")
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
					if("Steel Knuckles")
						beltr = /obj/item/rogueweapon/knuckles
					if("Axe")
						beltr = /obj/item/rogueweapon/stoneaxe/boneaxe
					if("Sword")
						beltr = /obj/item/rogueweapon/sword/short
					if("Whip")
						beltr = /obj/item/rogueweapon/whip
					if("Spear")
						r_hand = /obj/item/rogueweapon/spear/bonespear
			
			if("Studded Leather Kini")
				armor = /obj/item/clothing/suit/roguetown/armor/leather/studded/bikini
				pants = /obj/item/clothing/under/roguetown/tights/black
				wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
				shoes = /obj/item/clothing/shoes/roguetown/boots
				gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
				backl = /obj/item/storage/backpack/rogue/satchel
				belt = /obj/item/storage/belt/rogue/leather
				neck = /obj/item/storage/belt/rogue/pouch/coins/poor
				backpack_contents = list(/obj/item/flashlight/flare/torch = 1, /obj/item/rogueweapon/huntingknife/idagger/steel = 1)
				var/weapons = list("Katar","Rapier","Whip","Billhook")
				var/weapon_choice = input("Choose your weapon.", "TAKE UP ARMS") as anything in weapons
				switch(weapon_choice)
					if ("Katar")
						beltr = /obj/item/rogueweapon/katar
					if("Rapier")
						beltr = /obj/item/rogueweapon/sword/rapier
					if("Whip")
						beltr = /obj/item/rogueweapon/whip
					if("Billhook")
						r_hand = /obj/item/rogueweapon/spear/billhook


	H.adjust_blindness(-3)
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/order/retreat)
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/order/bolster)
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/order/brotherhood)
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/order/charge)
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/self/convertrole/brotherhood)
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/mockery)
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/eyebite)
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/bonechill)
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/stoneskin)
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/hawks_eyes)
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/giants_strength)
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/guidance)
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/bonechill)
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/haste)
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/mindlink)
	var/datum/devotion/C = new /datum/devotion(H, H.patron)
	C.grant_miracles(H, cleric_tier = CLERIC_T2, passive_gain = CLERIC_REGEN_DEVOTEE, devotion_limit = CLERIC_REQ_2)
	H.change_stat("speed", 3) /// Not a fighter, even with a virtue, built to be able to escape from fights.
	H.change_stat("constitution", 3)

	wretch_select_bounty(H)
	
/obj/effect/proc_holder/spell/invoked/order
	name = ""
	range = 5
	associated_skill = /datum/skill/misc/athletics
	devotion_cost = 0
	chargedrain = 1
	chargetime = 15
	releasedrain = 80 // 
	recharge_time = 2 MINUTES
	miracle = FALSE
	sound = 'sound/magic/inspire_02.ogg'


/obj/effect/proc_holder/spell/invoked/order/retreat
	name = "Tactical Retreat!"
	overlay_state = "movemovemove"

/obj/effect/proc_holder/spell/invoked/order/retreat/cast(list/targets, mob/living/user)
	. = ..()
	if(isliving(targets[1]))
		var/mob/living/target = targets[1]
		var/msg = user.mind.retreattext
		if(!msg)
			to_chat(user, span_alert("I must say something to give an order!"))
			return
		if(user.job == "Deserter")
			if(!(target.job in list("Brotherhood")))
				to_chat(user, span_alert("I cannot order one not of the brotherhood cause!"))
				return		
		if(target == user)
			to_chat(user, span_alert("I cannot order myself!"))
			return
		user.say("[msg]")
		target.apply_status_effect(/datum/status_effect/buff/order/retreat)
		return TRUE
	revert_cast()
	return FALSE

/datum/status_effect/buff/order/retreat/nextmove_modifier()
	return 0.85

/datum/status_effect/buff/order/retreat
	id = "movemovemove"
	alert_type = /atom/movable/screen/alert/status_effect/buff/order/retreat
	effectedstats = list(STATKEY_SPD = 3)
	duration = 0.5 / 1 MINUTES

/atom/movable/screen/alert/status_effect/buff/order/retreat
	name = "Tactical Retreat!!"
	desc = "My commander has ordered me to fall back!"
	icon_state = "buff"

/datum/status_effect/buff/order/retreat/on_apply()
	. = ..()
	to_chat(owner, span_blue("My commander orders me to fall back!"))

/obj/effect/proc_holder/spell/invoked/order/bolster
	name = "Hold the Line!"
	overlay_state = "takeaim"

/datum/status_effect/buff/order/bolster
	id = "takeaim"
	alert_type = /atom/movable/screen/alert/status_effect/buff/order/bolster
	effectedstats = list(STATKEY_CON = 5)
	duration = 1 MINUTES

/atom/movable/screen/alert/status_effect/buff/order/bolster
	name = "Hold the Line!"
	desc = "My commander inspires me to endure, and last a little longer!"
	icon_state = "buff"

/datum/status_effect/buff/order/bolster/on_apply()
	. = ..()
	to_chat(owner, span_blue("My commander orders me to hold the line!"))

/obj/effect/proc_holder/spell/invoked/order/bolster/cast(list/targets, mob/living/user)
	. = ..()
	if(isliving(targets[1]))
		var/mob/living/target = targets[1]
		var/msg = user.mind.bolstertext
		if(!msg)
			to_chat(user, span_alert("I must say something to give an order!"))
			return
		if(user.job == "Deserter")
			if(!(target.job in list("Brotherhood")))
				to_chat(user, span_alert("I cannot order one not of the brotherhood cause!"))
				return		
		if(target == user)
			to_chat(user, span_alert("I cannot order myself!"))
			return
		user.say("[msg]")
		target.apply_status_effect(/datum/status_effect/buff/order/bolster)
		return TRUE
	revert_cast()
	return FALSE

/obj/effect/proc_holder/spell/invoked/order/brotherhood
	name = "For the Brotherhood!"
	overlay_state = "onfeet"

/obj/effect/proc_holder/spell/invoked/order/brotherhood/cast(list/targets, mob/living/user)
	. = ..()
	if(isliving(targets[1]))
		var/mob/living/target = targets[1]
		var/msg = user.mind.brotherhoodtext
		if(!msg)
			to_chat(user, span_alert("I must say something to give an order!"))
			return
		if(user.job == "Deserter")
			if(!(target.job in list("Brotherhood")))
				to_chat(user, span_alert("I cannot order one not of the brotherhood cause!"))
				return		
		if(target == user)
			to_chat(user, span_alert("I cannot order myself!"))
			return
		user.say("[msg]")
		target.apply_status_effect(/datum/status_effect/buff/order/brotherhood)
		if(!(target.mobility_flags & MOBILITY_STAND))
			target.SetUnconscious(0)
			target.SetSleeping(0)
			target.SetParalyzed(0)
			target.SetImmobilized(0)
			target.SetStun(0)
			target.SetKnockdown(0)
			target.set_resting(FALSE)
		return TRUE
	revert_cast()
	return FALSE

/datum/status_effect/buff/order/brotherhood
	id = "onfeet"
	alert_type = /atom/movable/screen/alert/status_effect/buff/order/brotherhood
	duration = 30 SECONDS

/atom/movable/screen/alert/status_effect/buff/order/brotherhood
	name = "Stand your Ground!"
	desc = "My commander has ordered me to stand proud for the brotherhood!"
	icon_state = "buff"

/datum/status_effect/buff/order/brotherhood/on_apply()
	. = ..()
	to_chat(owner, span_blue("My commander orders me to stand proud for the brotherhood!"))
	ADD_TRAIT(owner, TRAIT_NOPAIN, MAGIC_TRAIT)

/datum/status_effect/buff/order/brotherhood/on_remove()
	REMOVE_TRAIT(owner, TRAIT_NOPAIN, MAGIC_TRAIT)
	. = ..()


/obj/effect/proc_holder/spell/invoked/order/charge
	name = "Charge!"
	overlay_state = "hold"


/obj/effect/proc_holder/spell/invoked/order/charge/cast(list/targets, mob/living/user)
	. = ..()
	if(isliving(targets[1]))
		var/mob/living/target = targets[1]
		var/msg = user.mind.holdtext
		if(!msg)
			to_chat(user, span_alert("I must say something to give an order!"))
			return
		if(user.job == "Deserter")
			if(!(target.job in list("Brotherhood")))
				to_chat(user, span_alert("I cannot order one not of the brotherhood cause!"))
				return		
		if(target == user)
			to_chat(user, span_alert("I cannot order myself!"))
			return
		user.say("[msg]")
		target.apply_status_effect(/datum/status_effect/buff/order/charge)
		return TRUE
	revert_cast()
	return FALSE


/datum/status_effect/buff/order/charge
	id = "hold"
	alert_type = /atom/movable/screen/alert/status_effect/buff/order/charge
	effectedstats = list(STATKEY_STR = 2, STATKEY_LCK = 2)
	duration = 1 MINUTES

/atom/movable/screen/alert/status_effect/buff/order/charge
	name = "Charge!"
	desc = "My commander wills it - now is the time to charge!"
	icon_state = "buff"

/datum/status_effect/buff/order/charge/on_apply()
	. = ..()
	to_chat(owner, span_blue("My commander orders me to charge! For the brotherhood!"))



/mob/living/carbon/human/mind/proc/setorderswretch()
	set name = "Rehearse Orders"
	set category = "Voice of Command"
	mind.retreattext = input("Send a message.", "Tactical Retreat!!") as text|null
	if(!mind.retreattext)
		to_chat(src, "I must rehearse something for this order...")
		return
	mind.chargetext = input("Send a message.", "Chaaaaarge!!") as text|null
	if(!mind.chargetext)
		to_chat(src, "I must rehearse something for this order...")
		return
	mind.bolstertext = input("Send a message.", "Hold the line!!") as text|null
	if(!mind.bolstertext)
		to_chat(src, "I must rehearse something for this order...")
		return
	mind.brotherhoodtext = input("Send a message.", "Stand proud, for the brotherhood!!") as text|null
	if(!mind.brotherhoodtext)
		to_chat(src, "I must rehearse something for this order...")
		return



/obj/effect/proc_holder/spell/self/convertrole/brotherhood
	name = "Recruit Brotherhood Militia"
	new_role = "Brother"
	overlay_state = "recruit_brotherhood"
	recruitment_faction = "Brother"
	recruitment_message = "We're in this together now, %RECRUIT!"
	accept_message = "For the Brotherhood!"
	refuse_message = "I refuse."

/obj/effect/proc_holder/spell/self/convertrole/brotherhood/cast(list/targets,mob/user = usr)
	. = ..()
	var/list/recruitment = list()
	for(var/mob/living/carbon/human/recruit in (get_hearers_in_view(recruitment_range, user) - user))
		//not allowed
		if(!can_convert(recruit))
			continue
		recruitment[recruit.name] = recruit
	if(!length(recruitment))
		to_chat(user, span_warning("There are no potential recruits in range."))
		return
	var/inputty = input(user, "Select a potential recruit!", "[name]") as anything in recruitment
	if(inputty)
		var/mob/living/carbon/human/recruit = recruitment[inputty]
		if(!QDELETED(recruit) && (recruit in get_hearers_in_view(recruitment_range, user)))
			INVOKE_ASYNC(src, PROC_REF(convert), recruit, user)
		else
			to_chat(user, span_warning("Recruitment failed!"))
	else
		to_chat(user, span_warning("Recruitment cancelled."))


/obj/effect/proc_holder/spell/self/convertrole/brother
	name = "Recruit Brother"
	new_role = "Brother"
	overlay_state = "recruit_brother"
	recruitment_faction = "Brother"
	recruitment_message = "We're in this together now, %RECRUIT!"
	accept_message = "All for one and one for all!"
	refuse_message = "I refuse."
