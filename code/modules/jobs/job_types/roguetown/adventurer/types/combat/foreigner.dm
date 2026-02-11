/datum/advclass/foreigner
	name = "Roughneck"
	tutorial = "You are a foreign swordsman, carrying nothing but your sword and your skill."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = NON_DWARVEN_RACE_TYPES //roughneck & custodian sprites dont have dwarf variants - adjust if/when a second update comes out with dwarf sprites
	outfit = /datum/outfit/job/adventurer/foreigner
	category_tags = list(CTAG_ADVENTURER, CTAG_COURTAGENT, CTAG_LICKER_WRETCH)
	class_select_category = CLASS_CAT_NOMAD
	cmode_music = 'sound/music/combat_kazengite.ogg'
	subclass_languages = list(/datum/language/kazengunese)

	traits_applied = list(TRAIT_STEELHEARTED, TRAIT_CRITICAL_RESISTANCE, TRAIT_NOPAINSTUN)
	subclass_stats = list(
		STATKEY_STR = 2,
		STATKEY_CON = 2,
		STATKEY_END = 1
	)

	subclass_skills = list(
		/datum/skill/combat/swords = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/shields = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/wrestling = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/unarmed = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/swimming = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/athletics = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/reading = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/sewing = SKILL_LEVEL_APPRENTICE,
	)

/datum/outfit/job/adventurer/foreigner/pre_equip(mob/living/carbon/human/H)
	..()
	to_chat(H, span_warning("You are a foreign swordsman, carrying nothing but your sword and your skill."))
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

	backpack_contents = list(
		/obj/item/recipe_book/survival = 1,
		/obj/item/flashlight/flare/torch/lantern,
		)
	H.set_blindness(0)
	H.cmode_music = 'sound/music/combat_kazengite.ogg'

/datum/advclass/foreigner/custodian
	name = "Custodian"
	tutorial = "You are an ex-guardian, whenever that be for a petty noble, or a small shrine. You excel in defense with quarterstaffs, or have taken up the Naginata's offensive martial capabilities."
	allowed_races = NON_DWARVEN_RACE_TYPES //roughneck & custodian sprites dont have dwarf variants - adjust if/when a second update comes out with dwarf sprites
	outfit = /datum/outfit/job/adventurer/custodian
	cmode_music = 'sound/music/combat_kazengite.ogg'
	subclass_languages = list(/datum/language/kazengunese)

	traits_applied = list(TRAIT_STEELHEARTED, TRAIT_CRITICAL_RESISTANCE, TRAIT_NOPAINSTUN)
	subclass_stats = list(
		STATKEY_STR = 2,
		STATKEY_CON = 2,
		STATKEY_END = 1
	)

	subclass_skills = list(
		/datum/skill/combat/polearms = SKILL_LEVEL_EXPERT,		
		/datum/skill/combat/wrestling = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/unarmed = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/swimming = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/athletics = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/reading = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/sewing = SKILL_LEVEL_APPRENTICE,
	)

/datum/outfit/job/adventurer/custodian/pre_equip(mob/living/carbon/human/H)
	..()
	to_chat(H, span_warning("You are an ex-guardian, whenever that be for a petty noble, or a small shrine. You excel in defense with quarterstaffs, or have taken up the Naginata's offensive martial capabilities."))
	head = /obj/item/clothing/head/roguetown/mentorhat
	gloves = /obj/item/clothing/gloves/roguetown/eastgloves1
	pants = /obj/item/clothing/under/roguetown/heavy_leather_pants/eastpants1
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/eastshirt2
	armor = /obj/item/clothing/suit/roguetown/armor/basiceast/mentorsuit
	shoes = /obj/item/clothing/shoes/roguetown/boots
	belt = /obj/item/storage/belt/rogue/leather/
	beltl = /obj/item/flashlight/flare/torch/lantern
	backl = /obj/item/storage/backpack/rogue/satchel

	backpack_contents = list(/obj/item/recipe_book/survival = 1)
	H.set_blindness(0)
	var/weapons = list("Naginata","Quarterstaff")
	var/weapon_choice = input(H, "Choose your weapon.", "TAKE UP ARMS") as anything in weapons
	switch(weapon_choice)
		if("Naginata")
			r_hand = /obj/item/rogueweapon/spear/naginata
		if("Quarterstaff")
			backr = /obj/item/rogueweapon/woodstaff/quarterstaff/steel
	H.cmode_music = 'sound/music/combat_kazengite.ogg'


/datum/advclass/foreigner/yoruku
	name = "Yoruku"
	tutorial = "You are a Kazengunese agent trained in assassination, sabotage, and irregular combat. You are armed with daggers or a short sword, perfect \
	for combat in the tight confines of castles and back alleys."
	allowed_races = NON_DWARVEN_RACE_TYPES //Clothing has no dwarf sprites.
	outfit = /datum/outfit/job/adventurer/yoruku
	subclass_languages = list(/datum/language/kazengunese)
	cmode_music = 'sound/music/combat_kazengite.ogg'
	traits_applied = list(TRAIT_STEELHEARTED, TRAIT_DODGEEXPERT, TRAIT_LIGHT_STEP, TRAIT_KEENEARS)
	subclass_stats = list(
		STATKEY_SPD = 3,
		STATKEY_PER = 1,
		STATKEY_END = 1,
	)
	subclass_skills = list(
		/datum/skill/misc/climbing = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/tracking = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/swimming = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/bows = SKILL_LEVEL_APPRENTICE,
		/datum/skill/craft/alchemy = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/wrestling = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/unarmed = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/athletics = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/reading = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/sneaking = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/lockpicking = SKILL_LEVEL_APPRENTICE,
		/datum/skill/craft/traps = SKILL_LEVEL_EXPERT,
	)

/datum/outfit/job/adventurer/yoruku/pre_equip(mob/living/carbon/human/H)
	..()
	to_chat(H, span_warning("You are a Kazengunese agent trained in assassination, sabotage, and irregular combat. You are armed with daggers or a short sword, perfect \
	for combat in the tight confines of castles and back alleys."))
	head = /obj/item/clothing/head/roguetown/roguehood/shalal/hijab/yoruku
	backr = /obj/item/storage/backpack/rogue/satchel
	backpack_contents = list(
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/recipe_book/survival = 1,
		/obj/item/reagent_containers/glass/bottle/rogue/berrypoison = 1,
		)
	belt = /obj/item/storage/belt/rogue/leather/knifebelt/black/kazengun
	gloves = /obj/item/clothing/gloves/roguetown/eastgloves1
	pants = /obj/item/clothing/under/roguetown/heavy_leather_pants/eastpants1
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/eastshirt1
	cloak = /obj/item/clothing/cloak/thief_cloak/yoruku
	shoes = /obj/item/clothing/shoes/roguetown/boots
	H.set_blindness(0)
	var/weapons = list("Tanto","Kodachi")
	var/weapon_choice = input(H, "Choose your weapon.", "TAKE UP ARMS") as anything in weapons
	switch(weapon_choice)
		if("Tanto")
			beltr = /obj/item/rogueweapon/huntingknife/idagger/steel/kazengun
			beltl = /obj/item/rogueweapon/scabbard/sheath/kazengun
			H.adjust_skillrank_up_to(/datum/skill/combat/knives, 4, TRUE)
		if("Kodachi")
			beltr = /obj/item/rogueweapon/sword/short/kazengun
			beltl = /obj/item/rogueweapon/scabbard/sword/kazengun/kodachi
			H.adjust_skillrank_up_to(/datum/skill/combat/swords, 4, TRUE)
	var/masks = list("Oni","Kitsune")
	var/mask_choice = input(H, "Choose your mask.", "HIDE YOURSELF") as anything in masks
	switch(mask_choice)
		if("Oni")
			mask = /obj/item/clothing/mask/rogue/facemask/hound/yoruku_oni
		if("Kitsune")
			mask = /obj/item/clothing/mask/rogue/facemask/hound/yoruku_kitsune

	var/belts = list("Shurikens","Smokebombs")
	var/belt_choice = input(H, "Choose your belt.", "BELT YOURSELF") as anything in belts
	switch(belt_choice)
		if("Shurikens")
			belt = /obj/item/storage/belt/rogue/leather/knifebelt/black/kazengun
		if("Smokebombs")
			belt = /obj/item/storage/belt/rogue/leather/smokebelt/black

/datum/advclass/foreigner/shepherd
	name = "Szöréndnížine Shepherd"
	tutorial = "You're a simple shepherd hailing from Aavnr's Free City, taking a pilgrimage or having fled for one reason or another. You can easily fend for yourself in the wilderness, and with enough practice, fend for yourself in combat against even armoured opponents with your traditional axe."
	extra_context = "This class is for experienced adventurers with a solid grasp on footwork and stamina management. Your weapon has special intents you can juggle through to make fights easier... Sometimes."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	subclass_languages = list(/datum/language/aavnic)
	outfit = /datum/outfit/job/roguetown/adventurer/freishepherd
	traits_applied = list()
	cmode_music = 'sound/music/frei_shepherd.ogg'
	subclass_stats = list(
		STATKEY_END = 2,
		STATKEY_PER = 2,
		STATKEY_CON = 1,
	)

	subclass_skills = list(
		/datum/skill/combat/knives = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/wrestling = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/axes = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/craft/crafting = SKILL_LEVEL_NOVICE,
		/datum/skill/craft/carpentry = SKILL_LEVEL_APPRENTICE,
		/datum/skill/labor/lumberjacking = SKILL_LEVEL_NOVICE,
		/datum/skill/labor/farming = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/labor/butchering = SKILL_LEVEL_APPRENTICE,
		/datum/skill/craft/cooking = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/athletics = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/reading = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/sewing = SKILL_LEVEL_JOURNEYMAN,
	)

/datum/outfit/job/roguetown/adventurer/freishepherd/pre_equip(mob/living/carbon/human/H)
	..()
	mask = /obj/item/clothing/head/roguetown/armingcap
	head = /obj/item/clothing/head/roguetown/chaperon/greyscale/shepherd
	neck = /obj/item/clothing/neck/roguetown/psicross/reform
	armor = /obj/item/clothing/suit/roguetown/armor/leather/heavy/shepherd
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/freifechter
	belt = /obj/item/storage/belt/rogue/leather/sash
	beltl = /obj/item/rogueweapon/stoneaxe/battle/steppesman/chupa
	beltr = /obj/item/rogueweapon/huntingknife/idagger/navaja/freifechter
	pants = /obj/item/clothing/under/roguetown/heavy_leather_pants/otavan/shepherd
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced/short
	backl = /obj/item/storage/backpack/rogue/backpack
	backpack_contents = list(
		/obj/item/flashlight/flare/torch = 1,
	)

/datum/advclass/foreigner/fencerguy
	name = "Foreign Fencer"
	tutorial = "You're an itinerant weapons expert that was trained in a Grenzelhoftian fencing school, carrying with you your weapon, your skillset, your pride... And not much else, frankly."
	extra_context = "This is a freeform class that's meant to evoke a similar feeling to playing a Freifechter, your equipment and skillset is limited compared to other classes - this is by design - but you start with cool weapons."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	outfit = /datum/outfit/job/roguetown/adventurer/fencerguy
	subclass_languages = list(/datum/language/grenzelhoftian)
	cmode_music = 'sound/music/frei_shepherd.ogg'
	traits_applied = list(TRAIT_INTELLECTUAL, TRAIT_FENCERDEXTERITY)
	subclass_stats = list(
		STATKEY_INT = 2,
		STATKEY_PER = 3,
	)
	subclass_skills = list(
		/datum/skill/combat/swords = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/athletics = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/knives = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/wrestling = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/reading = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/climbing = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/sewing = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/medicine = SKILL_LEVEL_APPRENTICE
	)

/datum/outfit/job/roguetown/adventurer/fencerguy/pre_equip(mob/living/carbon/human/H)
	..()
	to_chat(H, span_warning("You're an itinerant weapons expert that was trained in a Grenzelhoftian fencing school, carrying with you your weapon, your skillset, and your pride."))
	H.set_blindness(0)
	if(H.mind)
		var/weapons = list("Balanced Longsword","Spear & Punch Dagger","Sabre")
		var/weapon_choice = input(H, "Choose your expertise.", "TAKE UP ARMS") as anything in weapons
		switch(weapon_choice)
			if("Balanced Longsword")
				H.adjust_skillrank_up_to(/datum/skill/combat/swords, SKILL_LEVEL_EXPERT, TRUE)
				l_hand = /obj/item/rogueweapon/sword/long/fencerguy
				r_hand = /obj/item/rogueweapon/huntingknife/combat
				backr = /obj/item/rogueweapon/scabbard/sword
			if("Spear & Punch Dagger")
				H.adjust_skillrank_up_to(/datum/skill/combat/polearms, SKILL_LEVEL_EXPERT, TRUE)
				H.adjust_skillrank_up_to(/datum/skill/combat/unarmed, SKILL_LEVEL_JOURNEYMAN, TRUE)
				l_hand = /obj/item/rogueweapon/spear/boar
				r_hand = /obj/item/rogueweapon/katar/punchdagger/frei
			if("Sabre")
				H.adjust_skillrank_up_to(/datum/skill/combat/swords, SKILL_LEVEL_EXPERT, TRUE)
				l_hand = /obj/item/rogueweapon/sword/sabre/freifechter
				r_hand = /obj/item/rogueweapon/huntingknife/idagger/navaja/freifechter
				beltr = /obj/item/rogueweapon/scabbard/sword
	armor = /obj/item/clothing/suit/roguetown/armor/leather
	shirt = /obj/item/clothing/suit/roguetown/shirt/freifechter
	gloves = /obj/item/clothing/gloves/roguetown/angle/grenzelgloves
	neck = /obj/item/clothing/neck/roguetown/fencerguard/generic
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	pants = /obj/item/clothing/under/roguetown/heavy_leather_pants/otavan
	shoes = /obj/item/clothing/shoes/roguetown/boots/grenzelhoft
	backl = /obj/item/storage/backpack/rogue/satchel
	belt = /obj/item/storage/belt/rogue/leather
	backpack_contents = list(
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/recipe_book/survival = 1,
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
	)
