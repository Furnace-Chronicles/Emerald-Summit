/datum/advclass/psyaltrist
	name = "Psyaltrist"
	tutorial = "You spent some time with cathedral choirs and psyaltrists. Now you spend your days applying the musical arts to the practical on behalf of His most Holy of Inquisitions."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	outfit = /datum/outfit/job/psyaltrist
	category_tags = list(CTAG_INQUISITION)
	cmode_music = 'sound/music/combat_holy.ogg'
	origin_override_type = /datum/virtue/origin/otava
	custom_origin_wording = "Holy order"

	subclass_languages = list(/datum/language/otavan)

	traits_applied = list(
		TRAIT_DODGEEXPERT,
		TRAIT_EMPATH,
		TRAIT_STEELHEARTED,
		TRAIT_INQUISITION,
		TRAIT_OUTLANDER,
		TRAIT_PSYDONITE
	)
	subclass_stats = list(
		STATKEY_STR = 1,
		STATKEY_WIL = 1,
		STATKEY_SPD = 3,
	)
	subclass_skills = list(
		/datum/skill/misc/music = SKILL_LEVEL_MASTER,
		/datum/skill/magic/holy = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/knives = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/wrestling = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/unarmed = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/swimming = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/athletics = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/reading = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/medicine = SKILL_LEVEL_APPRENTICE,
		/datum/skill/craft/crafting = SKILL_LEVEL_NOVICE,
		/datum/skill/craft/cooking = SKILL_LEVEL_APPRENTICE
	)

/datum/outfit/job/psyaltrist
	job_bitflag = BITFLAG_CHURCH

/datum/outfit/job/psyaltrist/pre_equip(mob/living/carbon/human/H)
	..()
	has_loadout = TRUE
	head = /obj/item/clothing/head/roguetown/roguehood/psydon
	neck = /obj/item/clothing/neck/roguetown/leather
	armor = /obj/item/clothing/suit/roguetown/armor/leather/studded
	backl = /obj/item/storage/backpack/rogue/satchel/otavan
	cloak = /obj/item/clothing/cloak/psydontabard
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/inq
	gloves = /obj/item/clothing/gloves/roguetown/otavan/psygloves
	wrists = /obj/item/clothing/neck/roguetown/psicross/silver
	pants = /obj/item/clothing/under/roguetown/heavy_leather_pants/otavan
	shoes = /obj/item/clothing/shoes/roguetown/boots/psydonboots
	belt = /obj/item/storage/belt/rogue/leather/knifebelt/black/psydon
	beltr = /obj/item/storage/belt/rogue/pouch/coins/mid
	id = /obj/item/clothing/ring/signet/silver
	backpack_contents = list(
		/obj/item/roguekey/inquisition = 1,
		/obj/item/paper/inqslip/arrival/ortho = 1,
		/obj/item/rogueweapon/huntingknife/idagger/silver/psydagger = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1
	)

	var/datum/devotion/C = new /datum/devotion(H, H.patron)
	C.grant_miracles(H, cleric_tier = CLERIC_T2, passive_gain = CLERIC_REGEN_MINOR, devotion_limit = CLERIC_REQ_2)
	var/datum/inspiration/I = new /datum/inspiration(H)
	I.grant_inspiration(H, bard_tier = BARD_T2)
	H.mind?.AddSpell(new /datum/action/cooldown/spell/projectile/vicious_mockery)

	if(H.mind)
		var/instruments = list("Harp","Lute","Accordion","Guitar","Hurdy-Gurdy","Viola","Vocal Talisman","Flute","Drum","Shamisen","Psyaltery")
		var/instrument_choice = input(H, "Choose your instrument.", "TAKE UP SONG") as anything in instruments
		H.set_blindness(0)
		switch(instrument_choice)
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
			if("Flute")
				backr = /obj/item/rogue/instrument/flute
			if("Drum")
				backr = /obj/item/rogue/instrument/drum
			if("Shamisen")
				backr = /obj/item/rogue/instrument/shamisen
			if("Psyaltery")
				backr = /obj/item/rogue/instrument/psyaltery

/datum/outfit/job/psyaltrist/choose_loadout(mob/living/carbon/human/H)
	. = ..()
	var/weapons = list("Psydonic Whip", "Psydonic Shortsword", "Psydonic Cudgel")
	var/weapon_choice = input(H, "Choose your PSYDONIAN weapon.", "TAKE UP PSYDON'S ARMS") as anything in weapons
	switch(weapon_choice)
		if("Psydonic Whip")
			H.put_in_hands(new /obj/item/rogueweapon/whip/psywhip_lesser(H))
			H.adjust_skillrank_up_to(/datum/skill/combat/whipsflails, 4, TRUE)
		if("Psydonic Shortsword")
			H.put_in_hands(new /obj/item/rogueweapon/sword/short/psy(H))
			H.put_in_hands(new /obj/item/rogueweapon/scabbard/sword(H))
			H.adjust_skillrank_up_to(/datum/skill/combat/swords, 4, TRUE)
		if("Psydonic Cudgel")
			l_hand = /obj/item/rogueweapon/mace/cudgel/psy
			H.adjust_skillrank_up_to(/datum/skill/combat/maces, 4, TRUE)
