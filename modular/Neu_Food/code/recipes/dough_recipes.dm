/datum/food_recipe/dough
	abstract_type = /datum/food_recipe/dough
	book_category = FOOD_CAT_DOUGHS

/datum/food_recipe/dough/eggdough
	name = "eggdough"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/dough
	ingredients = list(
		/obj/item/reagent_containers/food/snacks/rogue/egg
	)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/eggdough

/datum/food_recipe/dough/griddle_dough
	name = "griddle dough"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/eggdough
	ingredients = list(/obj/item/kitchen/rollingpin = COOKSTEP_TOOL)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/griddle_uncooked
	time_per_step = 3 SECONDS

/datum/food_recipe/dough/noodles
	name = "uncooked noodles"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/eggdoughslice
	ingredients = list(/obj/item/kitchen/rollingpin = COOKSTEP_TOOL)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/eggdoughnoodles
