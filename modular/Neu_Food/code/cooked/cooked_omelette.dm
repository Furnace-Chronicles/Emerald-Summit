/*	.................   Omelettes   ................... */
/obj/item/reagent_containers/food/snacks/rogue/omelette_raw
	name = "raw omelette"
	desc = "Beaten eggs, ready for the pan."
	icon = 'modular/Neu_Food/icons/cooked/cooked_omelette.dmi'
	icon_state = "omeletteraw"
	foodtype = MEAT
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/omelette
	rotprocess = SHELFLIFE_SHORT
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/reagent_containers/food/snacks/rogue/omelette_raw_onion
	name = "raw onion omelette"
	desc = "Beaten eggs with chopped onion, ready for the pan."
	icon = 'modular/Neu_Food/icons/cooked/cooked_omelette.dmi'
	icon_state = "omeletteraw_onion"
	foodtype = MEAT | VEGETABLES
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/omelette_veggie
	rotprocess = SHELFLIFE_SHORT
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/reagent_containers/food/snacks/rogue/omelette_raw_veggie
	name = "raw vegetable omelette"
	desc = "Beaten eggs loaded with onion and greens, ready for the pan."
	icon = 'modular/Neu_Food/icons/cooked/cooked_omelette.dmi'
	icon_state = "omeletteraw_veggie"
	foodtype = MEAT | VEGETABLES
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/omelette_veggie
	rotprocess = SHELFLIFE_SHORT
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/reagent_containers/food/snacks/rogue/omelette_raw_meat
	name = "raw meat omelette"
	desc = "Beaten eggs mixed with meat, ready for the pan."
	icon = 'modular/Neu_Food/icons/cooked/cooked_omelette.dmi'
	icon_state = "omeletteraw_meat"
	foodtype = MEAT
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/omelette_meat
	rotprocess = SHELFLIFE_SHORT
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/reagent_containers/food/snacks/rogue/omelette
	name = "omelette"
	desc = "A fluffy omelette."
	icon = 'modular/Neu_Food/icons/cooked/cooked_omelette.dmi'
	icon_state = "omelette"
	foodtype = MEAT
	faretype = FARE_NEUTRAL
	list_reagents = list(/datum/reagent/consumable/nutriment = SNACK_CHUNKY)
	rotprocess = SHELFLIFE_DECENT
	slices_num = 4
	slice_batch = TRUE
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/omelette_slice
	slice_sound = TRUE
	eat_effect = /datum/status_effect/buff/snackbuff
	tastes = list("egg" = 1)

/obj/item/reagent_containers/food/snacks/rogue/omelette_slice
	name = "omelette slice"
	desc = "A wedge of fluffy omelette."
	icon = 'modular/Neu_Food/icons/cooked/cooked_omelette.dmi'
	icon_state = "omelette_slice"
	foodtype = MEAT
	faretype = FARE_NEUTRAL
	list_reagents = list(/datum/reagent/consumable/nutriment = SNACK_POOR)
	rotprocess = SHELFLIFE_DECENT
	tastes = list("egg" = 1)

/obj/item/reagent_containers/food/snacks/rogue/omelette_veggie
	name = "vegetable omelette"
	desc = "An omelette packed with onion and greens."
	icon = 'modular/Neu_Food/icons/cooked/cooked_omelette.dmi'
	icon_state = "omelette_veggie"
	foodtype = MEAT | VEGETABLES
	faretype = FARE_FINE
	list_reagents = list(/datum/reagent/consumable/nutriment = MEAL_MEAGRE)
	rotprocess = SHELFLIFE_DECENT
	slices_num = 4
	slice_batch = TRUE
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/omelette_veggie_slice
	slice_sound = TRUE
	eat_effect = /datum/status_effect/buff/mealbuff
	tastes = list("egg" = 1, "vegetables" = 1)

/obj/item/reagent_containers/food/snacks/rogue/omelette_veggie_slice
	name = "vegetable omelette slice"
	desc = "A hearty wedge of vegetable omelette."
	icon = 'modular/Neu_Food/icons/cooked/cooked_omelette.dmi'
	icon_state = "omelette_veggie_slice"
	foodtype = MEAT | VEGETABLES
	faretype = FARE_FINE
	list_reagents = list(/datum/reagent/consumable/nutriment = SNACK_POOR)
	rotprocess = SHELFLIFE_DECENT
	tastes = list("egg" = 1, "vegetables" = 1)

/obj/item/reagent_containers/food/snacks/rogue/omelette_meat
	name = "meat omelette"
	desc = "An omelette rich with meat."
	icon = 'modular/Neu_Food/icons/cooked/cooked_omelette.dmi'
	icon_state = "omelette_meat"
	foodtype = MEAT
	faretype = FARE_FINE
	list_reagents = list(/datum/reagent/consumable/nutriment = MEAL_AVERAGE)
	rotprocess = SHELFLIFE_DECENT
	slices_num = 4
	slice_batch = TRUE
	slice_path = /obj/item/reagent_containers/food/snacks/rogue/omelette_meat_slice
	slice_sound = TRUE
	eat_effect = /datum/status_effect/buff/mealbuff
	tastes = list("egg" = 1, "minced meat" = 1)

/obj/item/reagent_containers/food/snacks/rogue/omelette_meat_slice
	name = "meat omelette slice"
	desc = "A savory wedge of minced meat omelette."
	icon = 'modular/Neu_Food/icons/cooked/cooked_omelette.dmi'
	icon_state = "omelette_meat_slice"
	foodtype = MEAT
	faretype = FARE_FINE
	list_reagents = list(/datum/reagent/consumable/nutriment = SNACK_POOR)
	rotprocess = SHELFLIFE_DECENT
	tastes = list("egg" = 1, "minced meat" = 1)
