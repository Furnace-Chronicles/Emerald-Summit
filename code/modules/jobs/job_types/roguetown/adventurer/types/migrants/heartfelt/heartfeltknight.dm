
/datum/job/roguetown/heartfelt/knight
	title = "Knight of Heartfelt"
	tutorial = "You are a Knight of Heartfelt, once part of a brotherhood in service to your Lord. \
	Now, alone and committed to safeguarding what remains of your court, you ride to the Peak, resolved to ensure their safe arrival."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_NO_GOLEM
	total_positions = 1
	spawn_positions = 1
	job_traits = list(TRAIT_NOBLE, TRAIT_HEAVYARMOR, TRAIT_HEARTFELT)
	advclass_cat_rolls = list(CTAG_HFT_KNIGHT)
	social_rank = SOCIAL_RANK_NOBLE
	job_subclasses = list(
		/datum/advclass/heartfelt/knight
		)

/datum/advclass/heartfelt/knight
	name = "Knight of Heartfelt"
	tutorial = "You are a Knight of Heartfelt, once part of a brotherhood in service to your Lord. \
	Now, alone and committed to safeguarding what remains of your court, you ride to the Peak, resolved to ensure their safe arrival."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_NO_GOLEM
	outfit = /datum/outfit/job/heartfelt/knight
	maximum_possible_slots = 1
	pickprob = 100
	category_tags = list(CTAG_HFT_KNIGHT)
	class_select_category = CLASS_CAT_HFT_COURT
	subclass_social_rank = SOCIAL_RANK_NOBLE
	traits_applied = list(TRAIT_NOBLE, TRAIT_HEAVYARMOR, TRAIT_STEELHEARTED, TRAIT_HEARTFELT)
	subclass_stats = list(
		STATKEY_STR = 3,
		STATKEY_PER = 1,
		STATKEY_INT = 2,
		STATKEY_CON = 2,
		STATKEY_END = 2,
		STATKEY_SPD = -1,
	)

	subclass_skills = list(
	/datum/skill/combat/polearms = SKILL_LEVEL_EXPERT,
	/datum/skill/combat/swords = SKILL_LEVEL_EXPERT,
	/datum/skill/combat/maces = SKILL_LEVEL_EXPERT,
	/datum/skill/combat/axes = SKILL_LEVEL_EXPERT,
	/datum/skill/combat/whipsflails = SKILL_LEVEL_EXPERT,
	/datum/skill/combat/wrestling = SKILL_LEVEL_JOURNEYMAN,
	/datum/skill/combat/unarmed =SKILL_LEVEL_JOURNEYMAN,
	/datum/skill/combat/crossbows = SKILL_LEVEL_JOURNEYMAN,
	/datum/skill/combat/bows = SKILL_LEVEL_JOURNEYMAN,
	/datum/skill/misc/athletics = SKILL_LEVEL_JOURNEYMAN,
	/datum/skill/misc/swimming = SKILL_LEVEL_JOURNEYMAN,
	/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
	/datum/skill/misc/reading = SKILL_LEVEL_JOURNEYMAN,
	/datum/skill/misc/riding = SKILL_LEVEL_EXPERT,
	)

/datum/outfit/job/heartfelt/knight/pre_equip(mob/living/carbon/human/H)
	..()

	gloves = /obj/item/clothing/gloves/roguetown/plate
	pants = /obj/item/clothing/under/roguetown/platelegs
	cloak = /obj/item/clothing/cloak/tabard/knight/guard
	head = /obj/item/clothing/head/roguetown/helmet/heavy/knight
	neck = /obj/item/clothing/neck/roguetown/bevor
	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail
	armor = /obj/item/clothing/suit/roguetown/armor/plate/full
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor
	beltr = /obj/item/rogueweapon/scabbard/sword
	l_hand = /obj/item/rogueweapon/sword/long
	r_hand = /obj/item/rogueweapon/mace/goden/steel
	beltl = /obj/item/flashlight/flare/torch/lantern
	belt = /obj/item/storage/belt/rogue/leather/steel
	backr = /obj/item/storage/backpack/rogue/satchel/black
	head = /obj/item/clothing/head/roguetown/helmet/heavy/knight
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1,
		/obj/item/rope/chain = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
	)
	// This code is broken but also not, I assume because it has 1 Advanced Class at the moment DO NOT UNCOMMENT. 
	// IT WORKS :TM: still gives them a helm and grandmace, just not the choice
	
	H.adjust_blindness(-3)
	var/weapons = list("Zweihander","Great Mace","Battle Axe","Greataxe","Estoc","Lucerne", "Partizan")
	var/weapon_choice = input(H, "Choose your weapon.", "TAKE UP ARMS") as anything in weapons
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
		else //In case they DC or don't choose close the panel, etc
			r_hand = /obj/item/rogueweapon/eaglebeak/lucerne

	var/helmet = list("Pigface Bascinet","Guard Helmet","Barred Helmet","Bucket Helmet","Knight Helmet","Volf Plate Helmet" ,"Visored Sallet","Armet","Hounskull Bascinet", "Etruscan Bascinet", "Slitted Kettle")
	var/helmet_choice = input(H, "Choose your Helm.", "TAKE UP HELMS") as anything in helmet
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
