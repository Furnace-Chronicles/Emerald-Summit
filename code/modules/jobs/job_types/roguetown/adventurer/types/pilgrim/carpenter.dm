/datum/advclass/carpenter
	name = "Kunstmeister"
	tutorial = "You are a skilled artisan; Trained in various arts of your craft, be it stonework or woodwork, you are a useful service to the town in need of new homes to be built, or repairs from sieges."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	outfit = /datum/outfit/job/roguetown/adventurer/kunstmeister
	subclass_social_rank = SOCIAL_RANK_YEOMAN

	category_tags = list(CTAG_PILGRIM, CTAG_TOWNER)
	traits_applied = list(TRAIT_PEASANTMILITIA)

	subclass_stats = list(
		STATKEY_INT = 2,
		STATKEY_END = 2,
		STATKEY_STR = 2, // No extra fortune, doesn't make much of a difference in building
		STATKEY_CON = 2, // they could reasonably shrug off a fall from a short distance, 
	)

	subclass_skills = list(
		/datum/skill/combat/axes = SKILL_LEVEL_APPRENTICE, // these skills can probably stay, they won't be combat viable
		/datum/skill/combat/maces = SKILL_LEVEL_APPRENTICE, 
		/datum/skill/combat/wrestling = SKILL_LEVEL_JOURNEYMAN, 
		/datum/skill/combat/unarmed = SKILL_LEVEL_APPRENTICE,
		/datum/skill/labor/lumberjacking = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/labor/mining = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/athletics = SKILL_LEVEL_EXPERT, 
		/datum/skill/craft/crafting = SKILL_LEVEL_EXPERT,
		/datum/skill/craft/carpentry = SKILL_LEVEL_EXPERT,
		/datum/skill/craft/masonry = SKILL_LEVEL_EXPERT,
		/datum/skill/craft/engineering = SKILL_LEVEL_APPRENTICE, // the actual architect can have better engineering, not needed here
		/datum/skill/misc/swimming = SKILL_LEVEL_NOVICE, // why could they swim so well?
		/datum/skill/misc/climbing = SKILL_LEVEL_EXPERT, // it has always annoyed me that you couldn't climb the stone walls you made yourself
		/datum/skill/misc/reading = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/ceramics = SKILL_LEVEL_APPRENTICE, // needed to work with glass, 
	)
/datum/outfit/job/roguetown/adventurer/kunstmeister/pre_equip(mob/living/carbon/human/H)
	..()

	head = /obj/item/clothing/head/roguetown/hatfur // more fitting hat
	armor = /obj/item/clothing/suit/roguetown/armor/leather/vest
	cloak = /obj/item/clothing/cloak/apron/waist/bar
	pants = /obj/item/clothing/under/roguetown/trou
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/random
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	belt = /obj/item/storage/belt/rogue/leather
	beltr = /obj/item/flashlight/flare/torch/lantern
	beltl = /obj/item/rogueweapon/pick // give them an iron pickaxe for balance reasons
	backr = /obj/item/rogueweapon/stoneaxe/woodcut/steel/woodcutter // woodcutter already gets a woodcutting axe, this should be fine to stay
	backl = /obj/item/storage/backpack/rogue/backpack
	backpack_contents = list(
						/obj/item/rogueweapon/hammer/steel = 1,
						/obj/item/rogueweapon/handsaw = 1,
						/obj/item/storage/belt/rogue/pouch/coins/mid = 1,
						/obj/item/rogueweapon/chisel = 1,
						/obj/item/flashlight/flare/torch = 1,
						/obj/item/flint = 1,
						/obj/item/rogueweapon/huntingknife = 1,
						/obj/item/rogueweapon/handsaw = 1,
						/obj/item/dye_brush = 1, // does this even have a use?
						/obj/item/recipe_book/engineering = 1,
						/obj/item/recipe_book/builder = 1,
						/obj/item/recipe_book/survival = 1,
						)
	ADD_TRAIT(H, TRAIT_MASTER_CARPENTER, TRAIT_GENERIC) // makes it not ass to get planks for building
	ADD_TRAIT(H, TRAIT_MASTER_MASON, TRAIT_GENERIC)	// likewise here
