/datum/advclass/trader
	name = "Jeweler"
	tutorial = "You make your coin peddling exotic jewelry, gems, and shiny things."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	outfit = /datum/outfit/job/roguetown/adventurer/trader
	category_tags = list(CTAG_ADVENTURER, CTAG_COURTAGENT)
	traits_applied = list(TRAIT_OUTLANDER, TRAIT_SEEPRICES)
	subclass_stats = list(
		STATKEY_INT = 3,
		STATKEY_PER = 1,
		STATKEY_STR = 1,
		STATKEY_WIL = 1
	)

/datum/outfit/job/roguetown/adventurer/trader/pre_equip(mob/living/carbon/human/H)
	..()
	to_chat(H, span_warning("You make your coin peddling exotic jewelry, gems, and shiny things."))
	H.adjust_skillrank(/datum/skill/combat/wrestling, 1, TRUE)
	H.adjust_skillrank(/datum/skill/combat/unarmed, 1, TRUE)
	H.adjust_skillrank(/datum/skill/misc/reading, 3, TRUE)
	H.adjust_skillrank(/datum/skill/craft/blacksmithing, 3, TRUE)
	H.adjust_skillrank(/datum/skill/craft/weaponsmithing, 2, TRUE)
	H.adjust_skillrank(/datum/skill/craft/crafting, 2, TRUE)
	H.adjust_skillrank(/datum/skill/labor/mining, 2, TRUE)
	H.adjust_skillrank(/datum/skill/craft/smelting, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/swimming, 1, TRUE)
	H.adjust_skillrank(/datum/skill/misc/climbing, 1, TRUE)
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
		/obj/item/recipe_book/survival = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1
		)

/datum/advclass/trader/doomsayer
	name = "Doomsayer"
	tutorial = "You make your coin peddling exotic jewelry, gems, and shiny things."
	outfit = /datum/outfit/job/roguetown/adventurer/doomsayer
	subclass_stats = list(
		STATKEY_INT = 3,
		STATKEY_PER = 1,
		STATKEY_STR = 1,
		STATKEY_CON = 1
	)

/datum/outfit/job/roguetown/adventurer/doomsayer/pre_equip(mob/living/carbon/human/H)
	..()
	to_chat(H, span_warning("THE WORLD IS ENDING!!! At least, that's what you want your clients to believe. You'll offer them a safe place in the new world, of course - built by yours truly."))
	H.adjust_skillrank(/datum/skill/combat/wrestling, 1, TRUE)
	H.adjust_skillrank(/datum/skill/combat/axes, 1, TRUE)
	H.adjust_skillrank(/datum/skill/combat/unarmed, 1, TRUE)
	H.adjust_skillrank(/datum/skill/misc/reading, 2, TRUE)
	H.adjust_skillrank(/datum/skill/craft/carpentry, 3, TRUE)
	H.adjust_skillrank(/datum/skill/craft/masonry, 3, TRUE)
	H.adjust_skillrank(/datum/skill/craft/crafting, 2, TRUE)
	H.adjust_skillrank(/datum/skill/labor/lumberjacking, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/swimming, 1, TRUE)
	H.adjust_skillrank(/datum/skill/misc/climbing, 2, TRUE)
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
		/obj/item/recipe_book/survival = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1
		)

/datum/advclass/trader/scholar
	name = "Scholar"
	tutorial = "You are a scholar traveling the world in order to write a book about your ventures. You trade in stories and tales of your travels."
	outfit = /datum/outfit/job/roguetown/adventurer/scholar
	subclass_stats = list(
		STATKEY_INT = 3,
		STATKEY_PER = 1,
		STATKEY_SPD = 1,
		STATKEY_WIL = 1
	)

/datum/outfit/job/roguetown/adventurer/scholar/pre_equip(mob/living/carbon/human/H)
	..()
	to_chat(H, span_warning("You are a scholar traveling the world in order to write a book about your ventures. You trade in stories and tales of your travels."))
	H.adjust_skillrank(/datum/skill/combat/knives, 1, TRUE)
	H.adjust_skillrank(/datum/skill/combat/wrestling, 1, TRUE)
	H.adjust_skillrank(/datum/skill/combat/unarmed, 1, TRUE)
	H.adjust_skillrank(/datum/skill/misc/reading, 6, TRUE)
	H.adjust_skillrank(/datum/skill/craft/crafting, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/swimming, 1, TRUE)
	H.adjust_skillrank(/datum/skill/misc/climbing, 1, TRUE)
	H.adjust_skillrank(/datum/skill/craft/alchemy, 4, TRUE)
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
	if(H.mind)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/touch/prestidigitation)
	backpack_contents = list(
		/obj/item/paper/scroll = 3,
		/obj/item/book/rogue/knowledge1 = 1,
		/obj/item/reagent_containers/glass/bottle/rogue/manapot = 1,
		/obj/item/reagent_containers/glass/bottle/rogue/strongmanapot = 1,
		/obj/item/natural/feather = 1,
		/obj/item/roguegem/amethyst = 1,
		/obj/item/recipe_book/survival = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1
		)

/datum/advclass/trader/harlequin
	name = "Harlequin"
	tutorial = "You are a travelling entertainer - a jester by trade. Where you go, chaos follows - and mischief is made."
	outfit = /datum/outfit/job/roguetown/adventurer/harlequin
	subclass_stats = list(
		STATKEY_SPD = 2,
		STATKEY_PER = 1,
		STATKEY_WIL = 1,
		STATKEY_INT = 1
	)

/datum/outfit/job/roguetown/adventurer/harlequin/pre_equip(mob/living/carbon/human/H)
	..()
	to_chat(H, span_warning ("You are a travelling entertainer - a jester by trade. Where you go, chaos follows - and mischief is made."))
	shoes = /obj/item/clothing/shoes/roguetown/jester
	pants = /obj/item/clothing/under/roguetown/tights
	armor = /obj/item/clothing/suit/roguetown/shirt/jester
	belt = /obj/item/storage/belt/rogue/leather
	beltr = /obj/item/rogueweapon/huntingknife/idagger
	beltl = /obj/item/flashlight/flare/torch/lantern
	backl = /obj/item/storage/backpack/rogue/satchel
	head = /obj/item/clothing/head/roguetown/jester
	neck = /obj/item/storage/belt/rogue/pouch/coins/mid
	H.cmode_music = 'sound/music/combat_jester.ogg'
	backpack_contents = list(
		/obj/item/smokebomb = 3,
		/obj/item/storage/pill_bottle/dice = 1,
		/obj/item/toy/cards/deck = 1,
		/obj/item/recipe_book/survival = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1
		)
	H.adjust_skillrank(/datum/skill/combat/knives, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/reading, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/sneaking, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/stealing, 4, TRUE)
	H.adjust_skillrank(/datum/skill/misc/climbing, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/music, 4, TRUE)
	H.adjust_skillrank(/datum/skill/misc/lockpicking, 2, TRUE)
	ADD_TRAIT(H, TRAIT_NUTCRACKER, TRAIT_GENERIC)
	var/weapons = list("Harp","Lute","Accordion","Guitar","Hurdy-Gurdy","Viola","Vocal Talisman")
	var/weapon_choice = input("Choose your instrument.", "TAKE UP ARMS") as anything in weapons
	H.set_blindness(0)
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

/obj/item/clothing/mask/rogue/ragmask/black
	color = CLOTHING_BLACK
