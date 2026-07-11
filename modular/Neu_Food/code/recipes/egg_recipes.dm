// Two Fried Eggs (Egg + Egg)
/datum/food_recipe/twin_fried_eggs
	name = "Twin Fried Eggs"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/friedegg/fried
	ingredients = list(
		/obj/item/reagent_containers/food/snacks/rogue/friedegg/fried
	)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/friedegg/two
	time_per_step = 3 SECONDS

// Fried Egg + Sausage -> Wiener Egg
/datum/food_recipe/wiener_egg
	name = "Wiener Egg"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/friedegg/fried
	ingredients = list(
		/obj/item/reagent_containers/food/snacks/rogue/meat/sausage/cooked
	)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/friedegg/sausage
	time_per_step = 3 SECONDS

// Twin Eggs + Cheese -> Valerian Omelette
/datum/food_recipe/valerian_omelette
	name = "Valerian Omelette"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/friedegg/two
	ingredients = list(
		/obj/item/reagent_containers/food/snacks/rogue/cheddarwedge
	)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/friedegg/tiberian
	time_per_step = 5 SECONDS

// Twin Eggs + Bacon -> Bacon & Eggs
/datum/food_recipe/bacon_and_eggs
	name = "Bacon and Eggs"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/friedegg/two
	ingredients = list(
		/obj/item/reagent_containers/food/snacks/rogue/meat/bacon/fried
	)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/friedegg/bacon
	time_per_step = 5 SECONDS

// Bacon & Eggs + Sausage -> Wiener Egg with Bacon
/datum/food_recipe/wiener_egg_bacon
	name = "Wiener Egg with Bacon"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/friedegg/bacon
	ingredients = list(
		/obj/item/reagent_containers/food/snacks/rogue/meat/sausage/cooked
	)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/friedegg/sausagebacon
	time_per_step = 5 SECONDS

// Wiener Egg + Bacon -> Wiener Egg with Bacon (alternative path)
/datum/food_recipe/wiener_egg_bacon_alt
	name = "Wiener Egg with Bacon (Alt)"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/friedegg/sausage
	ingredients = list(
		/obj/item/reagent_containers/food/snacks/rogue/meat/bacon/fried
	)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/friedegg/sausagebacon
	time_per_step = 5 SECONDS

// Wiener Egg with Bacon + Toast -> Hammerholdian Breakfast
/datum/food_recipe/hammerholdian_breakfast
	name = "Hammerholdian Breakfast"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/friedegg/sausagebacon
	ingredients = list(
		/obj/item/reagent_containers/food/snacks/rogue/breadslice/toast
	)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/friedegg/hammerhold
	time_per_step = 5 SECONDS

// Egg + Cheese -> Stuffed Egg
/datum/food_recipe/stuffed_egg
	name = "Stuffed Egg"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/egg
	ingredients = list(
		/obj/item/reagent_containers/food/snacks/rogue/cheddarwedge
	)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/stuffedegg
	time_per_step = 3 SECONDS

// Egg + Egg -> Raw Omelette
/datum/food_recipe/omelette_raw
	name = "Raw Omelette"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/egg
	ingredients = list(
		/obj/item/reagent_containers/food/snacks/rogue/egg
	)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/omelette_raw
	time_per_step = 3 SECONDS

// Raw Omelette + Sliced Onion -> Raw Onion Omelette
/datum/food_recipe/omelette_onion
	name = "Raw Onion Omelette"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/omelette_raw
	ingredients = list(
		/obj/item/reagent_containers/food/snacks/rogue/veg/onion_sliced
	)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/omelette_raw_onion
	time_per_step = 3 SECONDS

// Raw Onion Omelette + Sliced Cucumber or Cabbage -> Raw Vegetable Omelette
/datum/food_recipe/omelette_veggie
	name = "Raw Vegetable Omelette"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/omelette_raw_onion
	ingredients = list(
		list(
			/obj/item/reagent_containers/food/snacks/rogue/veg/cucumber_sliced,
			/obj/item/reagent_containers/food/snacks/rogue/veg/cabbage_sliced,
		)
	)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/omelette_raw_veggie
	time_per_step = 3 SECONDS

// Raw Omelette + Mince -> Raw Meat Omelette
/datum/food_recipe/omelette_meat
	name = "Raw Meat Omelette"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/omelette_raw
	ingredients = list(
		/obj/item/reagent_containers/food/snacks/rogue/meat/mince
	)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/omelette_raw_meat
	time_per_step = 3 SECONDS
