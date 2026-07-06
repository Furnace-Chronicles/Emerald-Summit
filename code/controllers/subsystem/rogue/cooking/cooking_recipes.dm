// Cookbook menu-category label. ES has no ITEM_CAT_ system; this is metadata only — the slap-craft
// /datum/food_recipe never appears in the recipe-book menu (that lists /datum/crafting_recipe by its
// own `category`/`subcategory`). Guarded so a future item_categories port won't clash.
#ifndef ITEM_CAT_FOODSTUFF_FRESH
#define ITEM_CAT_FOODSTUFF_FRESH "Foodstuffs (Fresh)"
#endif

/datum/food_recipe
	var/name = "Generic Recipe"
	/// What item is used to start a recipe, e.g a piece of raw steak
	var/base_item = null
	/// Ingredients in order of completion
	var/list/ingredients = list()
	/// Resulting item
	var/result_type = null
	/// Whether or not this needs to be cooked
	var/needs_cooking = FALSE
	/// How long it takes to add items
	var/time_per_step = 2 SECONDS
	/// Experience per step per int
	var/experience_per_step = 0.5
	/// Cookbook menu category (metadata; see ITEM_CAT_FOODSTUFF_FRESH note above).
	var/display_category = ITEM_CAT_FOODSTUFF_FRESH
	/// Minimum cooking skill required to recall this recipe by examining an ingredient/precursor.
	/// Apprentice-tier (the default) recipes surface at skill 2; flag fancier "improvement" recipes
	/// as SKILL_LEVEL_EXPERT so only Expert+ cooks can recall them.
	var/min_skill = SKILL_LEVEL_APPRENTICE
