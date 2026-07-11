/*	.................   Griddle   ................... */
/obj/item/reagent_containers/food/snacks/rogue/griddle
	name = "griddles"
	desc = "Fluffy griddlecakes fried to perfection, plain yet delicious. They take well to a topping of sliced butter, honey, or a slice of chocolate left to melt atop them."
	icon = 'modular/Neu_Food/icons/cooked/cooked_griddles.dmi'
	icon_state = "griddle"
	faretype = FARE_NEUTRAL
	list_reagents = list(/datum/reagent/consumable/nutriment = MEAL_AVERAGE)
	w_class = WEIGHT_CLASS_NORMAL
	bitesize = 4
	eat_effect = /datum/status_effect/buff/snackbuff
	tastes = list("fluffy and soft dough" = 1)
	rotprocess = SHELFLIFE_LONG
	var/syrup_kind = null
	var/syrup_overlay_state = FALSE
	var/butter = FALSE

/obj/item/reagent_containers/food/snacks/rogue/griddle/proc/rebuild_overlays()
	cut_overlays()
	var/syrup_state = null
	switch(syrup_kind)
		if("chocolate")
			syrup_state = "griddle_chocolatesyrup"
		if("honey")
			syrup_state = "griddle_honeysyrup"
	if(syrup_overlay_state)
		var/mutable_appearance/syrup_overlay = mutable_appearance(icon, syrup_state)
		add_overlay(syrup_overlay)
	if(butter)
		var/mutable_appearance/butter_overlay = mutable_appearance(icon, "griddle_butter")
		add_overlay(butter_overlay)

/obj/item/reagent_containers/food/snacks/rogue/griddle/proc/update_faretype()
	faretype = initial(faretype)
	if(syrup_kind || butter)
		faretype = FARE_FINE

/obj/item/reagent_containers/food/snacks/rogue/griddle/proc/finish_topping(obj/item/ingredient)
	rebuild_overlays()
	update_faretype()
	qdel(ingredient)

/obj/item/reagent_containers/food/snacks/rogue/griddle/proc/copy_customization(obj/item/reagent_containers/food/snacks/rogue/griddle/target)
	if(!target)
		return
	target.syrup_kind = syrup_kind
	target.butter = butter
	target.rebuild_overlays()
	target.update_faretype()

/obj/item/reagent_containers/food/snacks/rogue/griddle/attackby(obj/item/I, mob/living/user, params)
	update_cooktime(user)
	if(!isturf(loc) || !locate(/obj/structure/table) in loc)
		return ..()
	if(istype(I, /obj/item/reagent_containers/food/snacks/chocolate/slice))
		if(syrup_kind == "honey")
			to_chat(user, span_warning("Even the finest things in life can have too much."))
			return TRUE
		if(syrup_kind == "chocolate")
			to_chat(user, span_warning("[src] is already topped with [I]."))
			return TRUE
		playsound(get_turf(user), 'sound/foley/dropsound/food_drop.ogg', 40, TRUE, -1)
		to_chat(user, span_notice("You place [I] atop [src] and let it melt..."))
		syrup_kind = "chocolate"
		syrup_overlay_state = TRUE
		finish_topping(I)
		return TRUE
	if(istype(I, /obj/item/reagent_containers/food/snacks/rogue/honey))
		if(syrup_kind == "chocolate")
			to_chat(user, span_warning("Even the finest things in life can have too much."))
			return TRUE
		if(syrup_kind == "honey")
			to_chat(user, span_warning("[src] is already topped with [I]."))
			return TRUE
		playsound(get_turf(user), 'sound/foley/dropsound/food_drop.ogg', 40, TRUE, -1)
		to_chat(user, span_notice("You place [I] atop [src] and let it melt..."))
		syrup_kind = "honey"
		syrup_overlay_state = TRUE
		finish_topping(I)
		return TRUE
	if(istype(I, /obj/item/reagent_containers/food/snacks/butterslice))
		if(butter)
			to_chat(user, span_warning("[src] is already topped with [I]."))
			return TRUE
		playsound(get_turf(user), 'sound/foley/dropsound/food_drop.ogg', 40, TRUE, -1)
		to_chat(user, span_notice("You place [I] atop [src] and let it melt..."))
		butter = TRUE
		finish_topping(I)
		return TRUE
	return ..()

/obj/item/reagent_containers/food/snacks/rogue/griddle/On_Consume(mob/living/eater)
	..()
	if(syrup_kind)
		eater.apply_status_effect(/datum/status_effect/buff/sweet)
	if(butter)
		eater.adjust_nutrition(5)

/*	.................   Fruit Griddles   ................... */
/obj/item/reagent_containers/food/snacks/rogue/griddle/fruit/lemon
	name = "lemongriddles"
	desc = "Fluffy griddlecakes fried to perfection and enough to make a bishop feel sour!"
	icon_state = "griddlelemon"
	faretype = FARE_FINE
	tastes = list("soft and fluffy dough" = 1, "sour lemon pulp" = 1)

/obj/item/reagent_containers/food/snacks/rogue/griddle/fruit/berry
	name = "berrygriddles"
	desc = "Fluffy griddlecakes fried to perfection, the area around each berry stained as if many beady eyes were staring back. Splendid!"
	icon_state = "griddleberry"
	faretype = FARE_FINE
	tastes = list("soft and fluffy dough" = 1, "sweet berry mash" = 1)

/obj/item/reagent_containers/food/snacks/rogue/griddle/fruit/poisonberry
	name = "berrygriddles"
	desc = "Fluffy griddlecakes fried to perfection, the area around each berry stained as if many beady eyes were staring back. Splendid!"
	icon_state = "griddleberry"
	faretype = FARE_FINE
	list_reagents = list(/datum/reagent/consumable/nutriment = MEAL_AVERAGE, /datum/reagent/toxin/berrypoison = 5)
	tastes = list("soft and fluffy dough" = 1, "bitter berry mash" = 1)

/obj/item/reagent_containers/food/snacks/rogue/griddle/fruit/apple
	name = "applegriddles"
	desc = "Fluffy griddlecakes fried to perfection, with a blanket of crunchy apple slices tucking the griddles in."
	icon_state = "griddleapple"
	faretype = FARE_FINE
	tastes = list("soft and fluffy dough" = 1, "caramelized apple slices" = 1)
