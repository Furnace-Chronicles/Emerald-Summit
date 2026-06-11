// Subtype of crafting_recipe for cooking

// ES's /datum/crafting_recipe uses `category` (string) for recipe-book grouping; Azure-Peak renamed it
// to `display_category` + ITEM_CAT_* constants. ES never adopted that rename, so we add display_category
// as a cooking-recipe field + the two food ITEM_CAT defines so the ported recipes compile. (Inert label
// unless/until the AP recipe-book category UI is ported — ES groups by `category`.)
#ifndef ITEM_CAT_FOODSTUFF_PRESERVED
#define ITEM_CAT_FOODSTUFF_PRESERVED "Foodstuffs (Preserved)"
#endif

/datum/crafting_recipe/roguetown/cooking
	abstract_type = /datum/crafting_recipe/roguetown/cooking
	var/display_category = ITEM_CAT_FOODSTUFF_FRESH
	subtype_reqs = TRUE // Cooking recipes do not require specific subtypes of ingredients.
	skillcraft = /datum/skill/craft/cooking // All cooking recipes use the cooking skill.
	craftdiff = 0 // Default difficulty for cooking recipes.
	req_table = FALSE // Cooking recipes generally require a table to work on. /or so you would think apparently they all use drying rack.
