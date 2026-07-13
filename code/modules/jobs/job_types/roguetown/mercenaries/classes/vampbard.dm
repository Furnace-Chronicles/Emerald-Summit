/datum/advclass/mercenary/vampbard
	name = "Vampiric Bard"
	tutorial = "Betwixt an occasional visit to a brothel, tavern or flophouse for your thirst for blood, you once told legends and myths of yills untold. One that someone could only dream of lyving, except you; yet now you've a prophecy to fulfil. Your lord's will be done."
	outfit = /datum/outfit/job/mercenary/vampbard
	category_tags = list(CTAG_MERCENARY)
	traits_applied = list(TRAIT_STEELHEARTED, TRAIT_DODGEEXPERT, TRAIT_GOODLOVER, TRAIT_EMPATH)
	subclass_stats = list(
		STATKEY_INT = 2,
		STATKEY_SPD = 2,
		STATKEY_WIL = 2,
	)
	subclass_skills = list(
		/datum/skill/combat/wrestling = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/unarmed = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/swimming = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/athletics = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/swords = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/knives = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/reading = SKILL_LEVEL_MASTER,
		/datum/skill/misc/medicine = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/sneaking = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/stealing = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/music = SKILL_LEVEL_LEGENDARY,
		/datum/skill/misc/lockpicking = SKILL_LEVEL_EXPERT,
	)

/datum/outfit/job/mercenary/vampbard/pre_equip(mob/living/carbon/human/H)
	..()
	to_chat(H, span_warning("Betwixt an occasional visit to a brothel, tavern or flophouse for your thirst for blood, you once told legends and myths of yills untold. One that someone could only dream of lyving, except you; yet now you've a prophecy to fulfil. Your lord's will be done."))
	head = /obj/item/clothing/head/roguetown/bardhat
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	neck = /obj/item/clothing/neck/roguetown/chaincoif/paalloy
	pants = /obj/item/clothing/under/roguetown/heavy_leather_pants
	mask = /obj/item/clothing/mask/rogue/ragmask/black
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
	gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
	belt = /obj/item/storage/belt/rogue/leather
	beltr = /obj/item/rogueweapon/huntingknife/idagger/steel
	beltl = /obj/item/rogueweapon/scabbard/sword
	backr = /obj/item/rogueweapon/sword
	armor = /obj/item/clothing/suit/roguetown/armor/leather/vest
	backl = /obj/item/storage/backpack/rogue/satchel/black
	cloak = /obj/item/clothing/cloak/half
	backpack_contents = list(
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/rope/chain = 1,
		/obj/item/lockpick = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1
	)

	var/datum/inspiration/I = new /datum/inspiration(H)
	I.grant_inspiration(H, bard_tier = BARD_T2)
	if(H.mind)
		H.mind.AddSpell(new /datum/action/cooldown/spell/projectile/vicious_mockery)
		var/instruments = list("Harp","Lute","Accordion","Guitar","Hurdy-Gurdy","Viola","Vocal Talisman","Flute","Psyaltery")
		var/instrument_choice = input(H, "Choose your instrument.", "STRINGS TO PLAY LYKE MORTALS.") as anything in instruments
		H.set_blindness(0)
		switch(instrument_choice)
			if("Harp")
				l_hand = /obj/item/rogue/instrument/harp
			if("Lute")
				l_hand = /obj/item/rogue/instrument/lute
			if("Accordion")
				l_hand = /obj/item/rogue/instrument/accord
			if("Guitar")
				l_hand = /obj/item/rogue/instrument/guitar
			if("Hurdy-Gurdy")
				l_hand = /obj/item/rogue/instrument/hurdygurdy
			if("Viola")
				l_hand = /obj/item/rogue/instrument/viola
			if("Vocal Talisman")
				l_hand = /obj/item/rogue/instrument/vocals
			if("Flute")
				l_hand = /obj/item/rogue/instrument/flute
			if("Psyaltery")
				l_hand = /obj/item/rogue/instrument/psyaltery
