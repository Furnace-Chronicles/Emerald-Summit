// Cornmeal + Water -> wet cornmeal (handled by parent flour attackby)
// Wet cornmeal + hand knead -> corndough_base (handled by cornmeal attack_hand override)

// Unfinished Corn Dough + Cornmeal -> Corn Dough
/datum/food_recipe/corn_dough
	name = "Corn Dough"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/corndough_base
	ingredients = list(
		/obj/item/reagent_containers/powder/flour/cornmeal
	)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/corndough

// Corn Dough + Rolling Pin -> Corn Flatbread x2 (handled via attackby on corndough)

// Corn Dough + Honey -> Honeyed Corn Dough
/datum/food_recipe/corn_honey
	name = "Honeyed Corn Dough"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/corndough
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/honey)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/corndough_honey

// Corn Dough + Cornmeal -> Corn Dough Balls x3 (handled via attackby on corndough)

// Corn Frybread + Tomato -> Salsa Frybread
/datum/food_recipe/cornfrybread_salsa
	name = "Salsa Frybread"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/cornfrybread
	ingredients = list(/obj/item/reagent_containers/food/snacks/grown/fruit/tomato)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/cornfrybread_salsa

// Corn Frybread + Pesto -> Pesto Frybread
/datum/food_recipe/cornfrybread_guac
	name = "Pesto Frybread"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/cornfrybread
	ingredients = list(/obj/item/reagent_containers/food/snacks/rogue/pesto)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/cornfrybread_guac
