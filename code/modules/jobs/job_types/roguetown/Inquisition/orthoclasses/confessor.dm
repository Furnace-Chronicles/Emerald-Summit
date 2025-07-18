/datum/advclass/confessor
	name = "Confessor"
	tutorial = "Church of the Ten holy hunters, unmatched in the fields of subterfuge and investigation. There is no suspect too powerful to investigate, no room too guarded to infiltrate, and no weakness too hidden to exploit."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	outfit = /datum/outfit/job/roguetown/confessor
	category_tags = list(CTAG_INQUISITION)
	cmode_music = 'sound/music/combat_rogue.ogg'

/datum/outfit/job/roguetown/confessor
	job_bitflag = BITFLAG_CHURCH

/datum/outfit/job/roguetown/confessor/pre_equip(mob/living/carbon/human/H)
	..()

	// Both subclasses get the same skills
	switch(H.patron?.type)
		if(/datum/patron/divine/astrata)
			wrists = /obj/item/clothing/neck/roguetown/psicross/astrata
		if(/datum/patron/divine/abyssor)
			wrists = /obj/item/clothing/neck/roguetown/psicross/abyssor
		if(/datum/patron/divine/xylix)
			wrists = /obj/item/clothing/neck/roguetown/psicross/silver
		if(/datum/patron/divine/dendor)
			wrists = /obj/item/clothing/neck/roguetown/psicross/dendor
		if(/datum/patron/divine/necra)
			wrists = /obj/item/clothing/neck/roguetown/psicross/necra
		if(/datum/patron/divine/pestra)
			wrists = /obj/item/clothing/neck/roguetown/psicross/pestra
		if(/datum/patron/divine/eora)
			wrists = /obj/item/clothing/neck/roguetown/psicross/eora
		if(/datum/patron/divine/noc)
			wrists = /obj/item/clothing/neck/roguetown/psicross/noc
		if(/datum/patron/divine/ravox)
			wrists = /obj/item/clothing/neck/roguetown/psicross/ravox
		if(/datum/patron/divine/malum)
			wrists = /obj/item/clothing/neck/roguetown/psicross/malum

	H.adjust_skillrank(/datum/skill/combat/maces, 3, TRUE) // Cudgellin - Nonlethals
	H.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/unarmed, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/knives, 4, TRUE) // Stabbin - Lethals
	H.adjust_skillrank(/datum/skill/misc/reading, 1, TRUE)
	H.adjust_skillrank(/datum/skill/misc/athletics, 4, TRUE) // Quick
	H.adjust_skillrank(/datum/skill/misc/climbing, 4, TRUE)
	H.adjust_skillrank(/datum/skill/misc/medicine, 3, TRUE) // Stitch up your prey
	H.adjust_skillrank(/datum/skill/misc/sneaking, 5, TRUE)
	H.adjust_skillrank(/datum/skill/misc/stealing, 5, TRUE)
	H.adjust_skillrank(/datum/skill/misc/lockpicking, 5, TRUE)
	H.adjust_skillrank(/datum/skill/misc/tracking, 4, TRUE)

	var/classes = list("Standard Confessor", "Confessor-Javelinier")
	var/classchoice = input("Choose your archetype", "Available archetypes") as anything in classes
	if(classchoice == "Confessor-Javelinier")
		backl = /obj/item/quiver/javelin
		beltr = null
		// After outfit is equipped, fill the quiver with silver javelins
		spawn(0)
			for(var/obj/item/quiver/javelin/Q in H)
				Q.arrows.Cut()
				for(var/i in 1 to Q.max_storage)
					var/obj/item/ammo_casing/caseless/rogue/javelin/silver/S = new /obj/item/ammo_casing/caseless/rogue/javelin/silver(Q)
					Q.arrows += S
				Q.update_icon()
		H.adjust_skillrank(/datum/skill/combat/polearms, 4, TRUE)
		H.change_stat("perception", -2)
		H.change_stat("intelligence", -2)
		H.change_stat("strength", 3)
		H.change_stat("endurance", 2)
		H.change_stat("speed", 3)
	else
		// Standard confessor: original ranged weapon logic and stats
		var/weapons = list("Crossbow & Bolts", "Recurve Bow & Arrows")
		var/weapon_choice = input("Choose your ranged weapon.", "TAKE UP ARMS") as anything in weapons
		switch(weapon_choice)
			if("Crossbow & Bolts")
				beltr = /obj/item/quiver/bolts
				backl = /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow
				H.adjust_skillrank(/datum/skill/combat/crossbows, 4, TRUE)
			if("Recurve Bow & Arrows")
				backl = /obj/item/gun/ballistic/revolver/grenadelauncher/bow/recurve
				beltr = /obj/item/quiver/arrows
				H.adjust_skillrank(/datum/skill/combat/bows, 4, TRUE)
		H.change_stat("strength", -1) // weasel
		H.change_stat("endurance", 3)
		H.change_stat("perception", 2)
		H.change_stat("speed", 3)
	H.set_blindness(0)		

	cloak = /obj/item/clothing/suit/roguetown/armor/longcoat
	gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
	beltl = /obj/item/rogueweapon/mace/cudgel
	backr = /obj/item/storage/backpack/rogue/satchel/black
	belt = /obj/item/storage/belt/rogue/leather/knifebelt/black/psydon
	pants = /obj/item/clothing/under/roguetown/trou/leather
	armor = /obj/item/clothing/suit/roguetown/armor/leather/studded
	shirt = /obj/item/clothing/suit/roguetown/shirt/shortshirt/random
	shoes = /obj/item/clothing/shoes/roguetown/boots
	mask = /obj/item/clothing/mask/rogue/facemask/psydonmask
	head = /obj/item/clothing/head/roguetown/roguehood/psydon
	backpack_contents = list(/obj/item/roguekey/inquisition = 1, /obj/item/lockpickring/mundane = 1, /obj/item/rogueweapon/huntingknife/idagger/silver/psydagger/preblessed, /obj/item/grapplinghook = 1)
	H.change_stat("strength", -1) // weasel
	H.change_stat("endurance", 3)
	H.change_stat("perception", 2)
	H.change_stat("speed", 3)
	ADD_TRAIT(H, TRAIT_DODGEEXPERT, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_STEELHEARTED, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_INQUISITION, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_PERFECT_TRACKER, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_OUTLANDER, TRAIT_GENERIC)		//You're a foreigner, a guest of the realm.
	ADD_TRAIT(H, TRAIT_SILVER_BLESSED, TRAIT_GENERIC)//Given they don't have the psyblessed silver cross. Puts them in line with the Inquisitor.
	var/datum/devotion/C = new /datum/devotion(H, H.patron)
	C.grant_miracles(H, cleric_tier = CLERIC_T1, passive_gain = FALSE, devotion_limit = CLERIC_REQ_1)
	H.grant_language(/datum/language/otavan)
