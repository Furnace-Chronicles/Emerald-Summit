/datum/advclass/ogre/cook
	name = "Gourmand"
	tutorial = "Having travelled most of the known world, and serving in the noble courts of both humans and dwarves, you are among the truly legendary chefs of the modern era! You have no qualms working alongside the stunties, for they keep the ingredients flowing to your beautiful art."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = /datum/species/ogre
	outfit = /datum/outfit/job/roguetown/ogre/cook
	category_tags = list(CTAG_OGRE)

	subclass_stats = list(
		STATKEY_CON = 2,
		STATKEY_END = 1,
		STATKEY_STR = 2,
		STATKEY_INT = 2,
		STATKEY_SPD = -1
	)

	traits_applied = list(TRAIT_BASHDOORS, TRAIT_CRITICAL_RESISTANCE, TRAIT_CALTROPIMMUNE, TRAIT_STRONGBITE)
	subclass_skills = list(
		/datum/skill/misc/athletics = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/knives = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/axes = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/reading = SKILL_LEVEL_NOVICE,
		/datum/skill/craft/cooking = SKILL_LEVEL_MASTER,
		/datum/skill/combat/wrestling = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/unarmed = SKILL_LEVEL_APPRENTICE,
		/datum/skill/craft/tanning = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/riding = SKILL_LEVEL_NOVICE,
		/datum/skill/craft/crafting = SKILL_LEVEL_APPRENTICE,
		/datum/skill/labor/butchering = SKILL_LEVEL_MASTER,
	)

/datum/outfit/job/roguetown/ogre/cook/pre_equip(mob/living/carbon/human/H)
	..()
	cloak = /obj/item/clothing/cloak/apron/ogre
	shirt = /obj/item/clothing/suit/roguetown/shirt/ogre
	head = /obj/item/clothing/head/roguetown/cookhat/ogre
	gloves = /obj/item/clothing/gloves/roguetown/leather/ogre
	pants = /obj/item/clothing/under/roguetown/tights/ogre
	backl = /obj/item/storage/backpack/rogue/satchel
	belt = /obj/item/storage/belt/rogue/leather/ogre
	beltl = /obj/item/rogueweapon/huntingknife/cleaver/ogre
	beltr = /obj/item/cooking/pan
	shoes = /obj/item/clothing/shoes/roguetown/boots/ogre
	neck = /obj/item/storage/belt/rogue/pouch/coins/poor

	backpack_contents = list(
						/obj/item/kitchen/spoon,
						/obj/item/reagent_containers/food/snacks/rogue/truffles,
						/obj/item/flashlight/flare/torch/lantern = 1,
						/obj/item/recipe_book/survival = 1,
						/obj/item/reagent_containers/food/snacks/fat = 2, // make sausages :)
						)

