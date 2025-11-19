/datum/migrant_role/heartfelt/lord
	name = "Lord of Heartfelt"
	greet_text = "You are the Lord of Heartfelt, ruler of a once-prosperous barony now in ruin. Guided by your Magos, you journey to the Peak, seeking aid to restore your domain to its former glory, or perhaps claim a new throne."
	outfit = /datum/outfit/job/roguetown/heartfelt/lord
	allowed_races = RACES_NO_GOLEM
	grant_lit_torch = TRUE
	show_wanderer_examine = FALSE

/datum/outfit/job/roguetown/heartfelt/lord/pre_equip(mob/living/carbon/human/H)
	..()
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt
	belt = /obj/item/storage/belt/rogue/leather/black
	shoes = /obj/item/clothing/shoes/roguetown/boots/nobleboot
	pants = /obj/item/clothing/under/roguetown/tights/black
	cloak = /obj/item/clothing/cloak/heartfelt
	armor = /obj/item/clothing/suit/roguetown/armor/heartfelt/lord
	neck = /obj/item/storage/belt/rogue/pouch/coins/rich
	beltl =/obj/item/rogueweapon/scabbard/sword
	r_hand = /obj/item/rogueweapon/sword/long/marlin
	beltr = /obj/item/rogueweapon/huntingknife
	gloves = /obj/item/clothing/gloves/roguetown/leather/black
	backl = /obj/item/storage/backpack/rogue/satchel/heartfelt // Paper and Feather
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1)
	id = /obj/item/scomstone
	H.adjust_skillrank(/datum/skill/combat/crossbows, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/polearms, 2, TRUE)
	H.adjust_skillrank(/datum/skill/combat/maces, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/bows, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/wrestling, 2, TRUE)
	H.adjust_skillrank(/datum/skill/combat/unarmed, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/swimming, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/climbing, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/swords, 4, TRUE)
	H.adjust_skillrank(/datum/skill/combat/knives, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/reading, 4, TRUE)
	H.adjust_skillrank(/datum/skill/misc/sneaking, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/medicine, 1, TRUE)
	H.adjust_skillrank(/datum/skill/misc/riding, 3, TRUE)
	H.change_stat("strength", 2)
	H.change_stat("intelligence", 2)
	H.change_stat("endurance", 2)
	H.change_stat("speed", 1)
	H.change_stat("perception", 2)
	H.change_stat("fortune", 5)

	ADD_TRAIT(H, TRAIT_NOBLE, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_HEAVYARMOR, TRAIT_GENERIC)

/datum/migrant_role/heartfelt/lady
	name = "Lady of Heartfelt"
	greet_text = "You are the Lady of Heartfelt, once a respected noblewoman now struggling to survive in a desolate landscape. With your home in ruins, you look to the Peak, hoping to find new purpose or refuge amidst the chaos."
	outfit = /datum/outfit/job/roguetown/heartfelt/lady
	allowed_sexes = list(FEMALE)
	allowed_races = RACES_NO_GOLEM
	grant_lit_torch = TRUE
	show_wanderer_examine = FALSE

/datum/outfit/job/roguetown/heartfelt/lady/pre_equip(mob/living/carbon/human/H)
	..()
	head = /obj/item/clothing/head/roguetown/hennin
	neck = /obj/item/storage/belt/rogue/pouch/coins/rich
	cloak = /obj/item/clothing/cloak/heartfelt
	if(isdwarf(H))
		armor = /obj/item/clothing/suit/roguetown/shirt/dress
	else
		if(prob(66))
			armor = /obj/item/clothing/suit/roguetown/armor/armordress/alt
		else
			armor = /obj/item/clothing/suit/roguetown/armor/armordress
	belt = /obj/item/storage/belt/rogue/leather/cloth/lady
	beltl = /obj/item/flashlight/flare/torch/lantern
	beltr = /obj/item/rogueweapon/huntingknife/idagger/silver/elvish
	id = /obj/item/clothing/ring/silver
	shoes = /obj/item/clothing/shoes/roguetown/shortboots
	H.adjust_skillrank(/datum/skill/misc/stealing, 4, TRUE)
	H.adjust_skillrank(/datum/skill/misc/sneaking, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/knives, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/swimming, 1, TRUE)
	H.adjust_skillrank(/datum/skill/misc/climbing, 1, TRUE)
	H.adjust_skillrank(/datum/skill/misc/athletics, 4, TRUE)
	H.adjust_skillrank(/datum/skill/misc/reading, 4, TRUE)
	H.adjust_skillrank(/datum/skill/misc/medicine, 2, TRUE)
	H.change_stat("intelligence", 3)
	H.change_stat("endurance", 3)
	H.change_stat("speed", 2)
	H.change_stat("perception", 2)
	H.change_stat("fortune", 5)
	ADD_TRAIT(H, TRAIT_SEEPRICES, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_NOBLE, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_NUTCRACKER, TRAIT_GENERIC)

/datum/migrant_role/heartfelt/hand
	name = "Hand of Heartfelt"
	greet_text = "You are the Hand of Heartfelt, burdened by the perception of failure in protecting your Lord's domain. Despite doubts from others, your loyalty remains steadfast as you journey to the Peak, determined to fulfill your duties."
	outfit = /datum/outfit/job/roguetown/heartfelt/hand
	allowed_races = RACES_ALL_KINDS
	grant_lit_torch = TRUE
	show_wanderer_examine = FALSE

/datum/outfit/job/roguetown/heartfelt/hand/pre_equip(mob/living/carbon/human/H)
	..()
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt
	belt = /obj/item/storage/belt/rogue/leather/black
	shoes = /obj/item/clothing/shoes/roguetown/boots/nobleboot
	pants = /obj/item/clothing/under/roguetown/tights/black
	armor = /obj/item/clothing/suit/roguetown/armor/heartfelt/hand
	neck = /obj/item/storage/belt/rogue/pouch/coins/rich
	gloves =/obj/item/clothing/gloves/roguetown/angle
	r_hand = /obj/item/rogueweapon/sword/sabre/dec
	beltl = /obj/item/rogueweapon/scabbard/sword
	beltr = /obj/item/rogueweapon/huntingknife
	backr = /obj/item/storage/backpack/rogue/satchel/heartfelt // Paper and Feather
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1)
	mask = /obj/item/clothing/mask/rogue/spectacles/golden
	id = /obj/item/scomstone
	H.adjust_skillrank(/datum/skill/combat/maces, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/medicine, 4, TRUE)
	H.adjust_skillrank(/datum/skill/craft/cooking, 4, TRUE)
	H.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/unarmed, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/swords, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/swimming, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/climbing, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/reading, 4, TRUE)
	H.adjust_skillrank(/datum/skill/misc/riding, 2, TRUE)
	H.change_stat("strength", 2)
	H.change_stat("perception", 3)
	H.change_stat("intelligence", 3)
	ADD_TRAIT(H, TRAIT_NOBLE, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_HEAVYARMOR, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_SEEPRICES, TRAIT_GENERIC)

/datum/migrant_role/heartfelt/knight
	name = "Knight of Heartfelt"
	greet_text = "You are a Knight of Heartfelt, once part of a brotherhood in service to your Lord. Now, alone and committed to safeguarding what remains of your court, you ride to the Peak, resolved to ensure their safe arrival."
	outfit = /datum/outfit/job/roguetown/heartfelt/knight
	allowed_races = RACES_NO_GOLEM
	grant_lit_torch = TRUE
	show_wanderer_examine = FALSE

/datum/outfit/job/roguetown/heartfelt/knight/pre_equip(mob/living/carbon/human/H)
	..()
	gloves = /obj/item/clothing/gloves/roguetown/plate
	pants = /obj/item/clothing/under/roguetown/platelegs
	cloak = /obj/item/clothing/cloak/tabard/knight/guard
	neck = /obj/item/clothing/neck/roguetown/bevor
	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail
	armor = /obj/item/clothing/suit/roguetown/armor/plate/full
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor
	beltr = /obj/item/rogueweapon/scabbard/sword
	l_hand = /obj/item/rogueweapon/sword/long
	beltl = /obj/item/flashlight/flare/torch/lantern
	belt = /obj/item/storage/belt/rogue/leather/steel
	backr = /obj/item/storage/backpack/rogue/satchel/black
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1,
		/obj/item/rope/chain = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1)

	H.adjust_skillrank(/datum/skill/combat/polearms, 4, TRUE)
	H.adjust_skillrank(/datum/skill/combat/swords, 4, TRUE)
	H.adjust_skillrank(/datum/skill/combat/whipsflails, 4, TRUE)
	H.adjust_skillrank(/datum/skill/combat/maces, 4, TRUE)
	H.adjust_skillrank(/datum/skill/combat/axes, 4, TRUE)
	H.adjust_skillrank(/datum/skill/combat/wrestling, 4, TRUE)
	H.adjust_skillrank(/datum/skill/combat/unarmed, 4, TRUE)
	H.adjust_skillrank(/datum/skill/combat/crossbows, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/bows, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/swimming, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/climbing, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/reading, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/riding, 4, TRUE)
	H.change_stat("strength", 3)
	H.change_stat("perception", 1)
	H.change_stat("intelligence", 2)
	H.change_stat("constitution", 2)
	H.change_stat("endurance", 2)
	H.change_stat("speed", -1)
	H.dna.species.soundpack_m = new /datum/voicepack/male/knight()

	var/weapons = list("Zweihander","Great Mace","Battle Axe","Greataxe","Estoc","Lucerne", "Partizan")
	var/weapon_choice = input("Choose your weapon.", "TAKE UP ARMS") as anything in weapons
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
		else //In case they DC or don't choose close the panel, etc
			r_hand = /obj/item/rogueweapon/eaglebeak/lucerne

	var/helmet = list("Pigface Bascinet","Guard Helmet","Barred Helmet","Bucket Helmet","Knight Helmet","Volf Plate Helmet" ,"Visored Sallet"	,"Armet","Hounskull Bascinet", "Etruscan Bascinet", "Slitted Kettle",)
	var/helmet_choice = input("Choose your Helm.", "TAKE UP HELMS") as anything in helmet
	switch(helmet_choice)
		if("Pigface Bascinet") 
			head = /obj/item/clothing/head/roguetown/helmet/bascinet/pigface
		if("Guard Helmet")	
			head = /obj/item/clothing/head/roguetown/helmet/heavy/guard
		if("Barred Helmet")		
			head = /obj/item/clothing/head/roguetown/helmet/heavy/sheriff
		if("Bucket Helmet")		
			head = /obj/item/clothing/head/roguetown/helmet/heavy/bucket
		if("Knight Helmet")		
			head = /obj/item/clothing/head/roguetown/helmet/heavy/knight
		if("Volf Plate Helmet") 
			head = /obj/item/clothing/head/roguetown/helmet/heavy/volfplate
		if("Visored Sallet")	
			head = /obj/item/clothing/head/roguetown/helmet/sallet/visored
		if("Armet")			
			head = /obj/item/clothing/head/roguetown/helmet/heavy/knight/armet
		if("Hounskull Bascinet")
			head = /obj/item/clothing/head/roguetown/helmet/bascinet/pigface/hounskull
		if("Etruscan Bascinet")
			head = /obj/item/clothing/head/roguetown/helmet/bascinet/etruscan
		if("Slitted Kettle") 
			head = /obj/item/clothing/head/roguetown/helmet/heavy/knight/skettle
		else //In case they DC or don't choose close the panel, etc
			head = /obj/item/clothing/head/roguetown/helmet/heavy/knight

	ADD_TRAIT(H, TRAIT_NOBLE, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_HEAVYARMOR, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_STEELHEARTED, TRAIT_GENERIC)

/datum/migrant_role/heartfelt/knight/after_spawn(mob/living/L, mob/M, latejoin = TRUE)
	..()
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		if(istype(H.cloak, /obj/item/clothing/cloak/tabard/knight/guard))
			var/obj/item/clothing/S = H.cloak
			var/index = findtext(H.real_name, " ")
			if(index)
				index = copytext(H.real_name, 1,index)
			if(!index)
				index = H.real_name
			S.name = "knight tabard ([index])"
		var/prev_real_name = H.real_name
		var/prev_name = H.name
		var/honorary = "Ser"
		if(H.pronouns == SHE_HER || H.pronouns == THEY_THEM_F)
			honorary = "Dame"
		GLOB.chosen_names -= prev_real_name
		H.real_name = "[honorary] [prev_real_name]"
		H.name = "[honorary] [prev_name]"
		GLOB.chosen_names += H.real_name

		for(var/X in peopleknowme)
			for(var/datum/mind/MF in get_minds(X))
				if(MF.known_people)
					MF.known_people -= prev_real_name
					H.mind.person_knows_me(MF)

/datum/migrant_role/heartfelt/magos
	name = "Magos of Heartfelt"
	greet_text = "You are the Magos of Heartfelt, renowned for your arcane knowledge yet unable to foresee the tragedy that befell your home. Drawn by a guiding star to the Peak, you seek answers and perhaps a new purpose in the wake of destruction."
	outfit = /datum/outfit/job/roguetown/heartfelt/magos
	allowed_races = RACES_NO_GOLEM
	grant_lit_torch = TRUE
	show_wanderer_examine = FALSE

/datum/outfit/job/roguetown/heartfelt/magos/pre_equip(mob/living/carbon/human/H)
	..()
	neck = /obj/item/clothing/neck/roguetown/talkstone
	cloak = /obj/item/clothing/cloak/black_cloak
	armor = /obj/item/clothing/suit/roguetown/shirt/robe/black
	pants = /obj/item/clothing/under/roguetown/tights/random
	shoes = /obj/item/clothing/shoes/roguetown/shortboots
	belt = /obj/item/storage/belt/rogue/leather/plaquesilver
	beltl = /obj/item/flashlight/flare/torch/lantern
	beltr = /obj/item/storage/magebag/starter
	id = /obj/item/clothing/ring/gold
	r_hand = /datum/crafting_recipe/gemstaff/ruby_staff //Two Levels down from CW
	backl = /obj/item/storage/backpack/rogue/satchel
	backpack_contents = list(
		/obj/item/reagent_containers/glass/bottle/rogue/poison,
		/obj/item/reagent_containers/glass/bottle/rogue/healthpot,
		/obj/item/recipe_book/alchemy,
		/obj/item/roguegem/amethyst ,
		/obj/item/spellbook_unfinished/pre_arcyne,
		/obj/item/rogueweapon/huntingknife/idagger/silver/arcyne
		)

	ADD_TRAIT(H, TRAIT_SEEPRICES, "[type]")
	ADD_TRAIT(H, TRAIT_ARCYNE_T4, TRAIT_GENERIC)
	H.adjust_skillrank(/datum/skill/misc/reading, 6, TRUE)
	H.adjust_skillrank(/datum/skill/craft/alchemy, 3, TRUE)
	H.adjust_skillrank(/datum/skill/magic/arcane, 5, TRUE)
	H.adjust_skillrank(/datum/skill/misc/riding, 2, TRUE)
	H.adjust_skillrank(/datum/skill/combat/polearms, 1, TRUE)
	H.adjust_skillrank(/datum/skill/combat/wrestling, 1, TRUE)
	H.adjust_skillrank(/datum/skill/combat/unarmed, 1, TRUE)
	H.adjust_skillrank(/datum/skill/misc/swimming, 1, TRUE)
	H.adjust_skillrank(/datum/skill/misc/climbing, 1, TRUE)
	H.adjust_skillrank(/datum/skill/misc/athletics, 1, TRUE)
	H.adjust_skillrank(/datum/skill/combat/swords, 1, TRUE)
	H.adjust_skillrank(/datum/skill/combat/knives, 1, TRUE)
	H.adjust_skillrank(/datum/skill/craft/crafting, 1, TRUE)
	H.adjust_skillrank(/datum/skill/misc/medicine, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/riding, 1, TRUE)
	H.change_stat("strength", -1)
	H.change_stat("constitution", -1)
	H.change_stat("intelligence", 4)
	if(H.mind)
		H?.mind.adjust_spellpoints(36)
	ADD_TRAIT(H, TRAIT_MAGEARMOR, TRAIT_GENERIC)
	if(H.age == AGE_OLD)
		H.adjust_skillrank(/datum/skill/magic/arcane, 1, TRUE)
		H.change_stat("speed", -1)
		H.change_stat("intelligence", 1)
		H.change_stat("perception", 1)
	if(H.mind)
		H?.mind.adjust_spellpoints(6)
	if(ishumannorthern(H))
		belt = /obj/item/storage/belt/rogue/leather/plaquegold
		cloak = null
		head = /obj/item/clothing/head/roguetown/wizhat
		armor = /obj/item/clothing/suit/roguetown/shirt/robe/wizard
		H.dna.species.soundpack_m = new /datum/voicepack/male/wizard()
	var/list/spells = list(/obj/effect/proc_holder/spell/targeted/touch/prestidigitation)
	for(var/S in spells)
		H.mind.AddSpell(new S)

/datum/migrant_role/heartfelt/prior
	name = "Prior of Heartfelt"
	greet_text = "The Prior of Heartfelt, you were destined for ascension within the Church, but fate intervened with the barony's downfall, delaying it indefinitely. Still guided by the blessings of Astrata, you journey to the Peak, determined to offer what aid and solace you can."
	outfit = /datum/outfit/job/roguetown/heartfelt/prior
	allowed_races = RACES_NO_GOLEM
	grant_lit_torch = TRUE
	show_wanderer_examine = FALSE

/datum/outfit/job/roguetown/heartfelt/prior/pre_equip(mob/living/carbon/human/H)
	..()
	neck = /obj/item/clothing/neck/roguetown/psicross/astrata
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/priest
	pants = /obj/item/clothing/under/roguetown/tights/black
	shoes = /obj/item/clothing/shoes/roguetown/shortboots
	belt = /obj/item/storage/belt/rogue/leather/rope
	beltl = /obj/item/flashlight/flare/torch/lantern
	beltr = /obj/item/storage/belt/rogue/pouch/coins/rich
	armor = /obj/item/clothing/suit/roguetown/shirt/robe/priest
	cloak = /obj/item/clothing/cloak/chasuble
	backl = /obj/item/storage/backpack/rogue/satchel
	backpack_contents = list(
		/obj/item/needle/pestra = 1,
		/obj/item/ritechalk = 1,
	)

	ADD_TRAIT(H, TRAIT_CHOSEN, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_RITUALIST, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_SOUL_EXAMINE, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_GRAVEROBBER, TRAIT_GENERIC)
	H.adjust_skillrank(/datum/skill/combat/wrestling, 4, TRUE)
	H.adjust_skillrank(/datum/skill/combat/unarmed, 4, TRUE)
	H.adjust_skillrank(/datum/skill/combat/polearms, 4, TRUE)
	H.adjust_skillrank(/datum/skill/misc/reading, 6, TRUE)
	H.adjust_skillrank(/datum/skill/craft/cooking, 2, TRUE)
	H.adjust_skillrank(/datum/skill/craft/crafting, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/sewing , 2, TRUE)
	H.adjust_skillrank(/datum/skill/labor/farming, 2, TRUE)
	H.adjust_skillrank(/datum/skill/craft/alchemy, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/medicine, 4, TRUE)
	H.adjust_skillrank(/datum/skill/magic/holy, 5, TRUE)
	if(H.age == AGE_OLD)
		H.adjust_skillrank(/datum/skill/magic/holy, 1, TRUE)
	H.change_stat("strength", -1)
	H.change_stat("intelligence", 3)
	H.change_stat("constitution", -1)
	H.change_stat("endurance", 1)
	H.change_stat("speed", -1)
	var/datum/devotion/C = new /datum/devotion(H, H.patron)
	C.grant_miracles(H, cleric_tier = CLERIC_T4, passive_gain = CLERIC_REGEN_MAJOR, start_maxed = TRUE)	//Starts off maxed out.
