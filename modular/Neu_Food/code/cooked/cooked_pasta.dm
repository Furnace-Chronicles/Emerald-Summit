/*	.................   Noodles   ................... */
/obj/item/reagent_containers/food/snacks/rogue/noodles
	name = "noodles"
	desc = "Tasteless wet noodles, while the truly desperate could eat this as is, some sauce might be in order."
	icon = 'modular/Neu_Food/icons/cooked/cooked_pasta.dmi'
	icon_state = "noodle"
	list_reagents = list(/datum/reagent/consumable/nutriment = SNACK_DECENT)
	faretype = FARE_NEUTRAL
	w_class = WEIGHT_CLASS_TINY
	foodtype = GRAIN
	tastes = list("bland noodles" = 1)
	bitesize = 2
	rotprocess = SHELFLIFE_EXTREME

/obj/item/reagent_containers/food/snacks/rogue/noodles/examine(mob/user)
	. = ..()
	. += span_smallnotice("Worked on a table: add <b>tomato sauce</b> for spaghetti, or <b>pesto</b> for pesto spaghetti.")

/obj/item/reagent_containers/food/snacks/rogue/noodles/attackby(obj/item/I, mob/living/user, params)
	var/found_table = locate(/obj/structure/table) in (loc)
	update_cooktime(user)
	if(istype(I, /obj/item/reagent_containers/food/snacks/grown/fruit/tomato_sauce))
		if(isturf(loc) && (found_table))
			playsound(get_turf(user), 'sound/foley/dropsound/food_drop.ogg', 40, TRUE, -1)
			to_chat(user, span_notice("Mixing the noodles with tomato sauce..."))
			if(do_after(user, short_cooktime, target = src))
				add_sleep_experience(user, /datum/skill/craft/cooking, user.STAINT)
				new /obj/item/reagent_containers/food/snacks/rogue/spaghetti(loc)
				qdel(I)
				qdel(src)
		else
			to_chat(user, span_warning("You need to put [src] on a table to mix it!"))
	else if(istype(I, /obj/item/reagent_containers/food/snacks/rogue/pesto))
		if(isturf(loc) && (found_table))
			playsound(get_turf(user), 'sound/foley/dropsound/food_drop.ogg', 40, TRUE, -1)
			to_chat(user, span_notice("Mixing the noodles with pesto..."))
			if(do_after(user, short_cooktime, target = src))
				add_sleep_experience(user, /datum/skill/craft/cooking, user.STAINT)
				new /obj/item/reagent_containers/food/snacks/rogue/spaghetti_pesto(loc)
				qdel(I)
				qdel(src)
		else
			to_chat(user, span_warning("You need to put [src] on a table to mix it!"))
	else
		return ..()

/obj/item/reagent_containers/food/snacks/rogue/sheetnoodles
	name = "sheet noodles"
	desc = "Tasteless wet sheet noodles. Oh. You can't stack cheese or sauce on this... It's ruined."
	icon = 'modular/Neu_Food/icons/cooked/cooked_pasta.dmi'
	icon_state = "sheetnoodle"
	list_reagents = list(/datum/reagent/consumable/nutriment = SNACK_DECENT)
	faretype = FARE_NEUTRAL
	w_class = WEIGHT_CLASS_TINY
	foodtype = GRAIN
	tastes = list("bland disappointment" = 1)
	bitesize = 2
	rotprocess = SHELFLIFE_EXTREME

/*	.................   Spaghetti   ................... */
/obj/item/reagent_containers/food/snacks/rogue/spaghetti
	name = "spaghetti"
	desc = "Noodles mixed with fresh marinara, beloved by the Etruscan isles. It's said that Navarno cuisine is as rich as it is poor, and it's scarce ingredients was necessary before it's unification with Montecarina."
	icon = 'modular/Neu_Food/icons/cooked/cooked_pasta.dmi'
	icon_state = "spaghetti"
	faretype = FARE_FINE
	list_reagents = list(/datum/reagent/consumable/nutriment = SNACK_CHUNKY)
	tastes = list("richly smooth and salty tomatoes" = 1, "al dente noodles" = 1)
	w_class = WEIGHT_CLASS_NORMAL
	foodtype = GRAIN | FRUIT
	eat_effect = /datum/status_effect/buff/snackbuff
	rotprocess = SHELFLIFE_DECENT

/obj/item/reagent_containers/food/snacks/rogue/spaghetti_pesto
	name = "pesto spaghetti"
	desc = "Noodles mixed with a spiced refined sauce made from smoky rocknut and garlick. A cultural blend of Azurian improvisation and Navarno ingenuity."
	icon = 'modular/Neu_Food/icons/cooked/cooked_pasta.dmi'
	icon_state = "spaghetti_pesto"
	list_reagents = list(/datum/reagent/consumable/nutriment = SNACK_CHUNKY, /datum/reagent/consumable/acorn_powder = 4, /datum/reagent/drug/nicotine = 1)
	faretype = FARE_LAVISH
	w_class = WEIGHT_CLASS_NORMAL
	tastes = list("nutty, herby, and garlicky sauce" = 1, "al dente noodles" = 1)
	foodtype = GRAIN | VEGETABLES
	eat_effect = /datum/status_effect/buff/greatsnackbuff
	rotprocess = SHELFLIFE_DECENT

/*	.................   Lasagna   ................... */
/obj/item/reagent_containers/food/snacks/rogue/lasagna
	name = "lasagna"
	desc = "Stacked pasta sheets layered with fresh marinara, made with limited ingredients. One might call this Navarno, but even there the Montecarinan style is the norm."
	icon = 'modular/Neu_Food/icons/cooked/cooked_pasta.dmi'
	icon_state = "lasagna"
	faretype = FARE_NEUTRAL
	list_reagents = list(/datum/reagent/consumable/nutriment = MEAL_MEAGRE)
	tastes = list("richly smooth and salty tomatoes" = 1, "soft noodle sheets" = 1)
	w_class = WEIGHT_CLASS_NORMAL
	foodtype = GRAIN | FRUIT
	eat_effect = /datum/status_effect/buff/mealbuff
	rotprocess = SHELFLIFE_LONG

/obj/item/reagent_containers/food/snacks/rogue/lasagna_white
	name = "white lasagna"
	desc = "Stacked pasta sheets layered with bechamel sauce and melted cheese. Lasagna was brought to Valoria by a Montecarinan royal chef, but the price of tomatoes made locals forgo it for a very Otavan white sauce."
	icon = 'modular/Neu_Food/icons/cooked/cooked_pasta.dmi'
	icon_state = "lasagna_white"
	faretype = FARE_FINE
	list_reagents = list(/datum/reagent/consumable/nutriment = MEAL_MEAGRE)
	tastes = list("smooth bechamel sauce" = 1, "cheesy noodle sheets" = 1)
	w_class = WEIGHT_CLASS_NORMAL
	foodtype = GRAIN | DAIRY
	eat_effect = /datum/status_effect/buff/mealbuff
	rotprocess = SHELFLIFE_LONG

/obj/item/reagent_containers/food/snacks/rogue/lasagna_redwhite
	name = "cheesy lasagna"
	desc = "Pasta sheets decadently stacked with marinara and cheese, something so simple has no right to be so rich. The condottieri and captains of Montecarina's royal navy hate leaving port, not knowing when next they can gorge on this soldiery pasta loaf of cheese and sauce."
	icon = 'modular/Neu_Food/icons/cooked/cooked_pasta.dmi'
	icon_state = "lasagna_redwhite"
	faretype = FARE_LAVISH
	list_reagents = list(/datum/reagent/consumable/nutriment = MEAL_GOOD)
	tastes = list("richly smooth and salty tomatoes" = 1, "melted cheese between noodle sheets" = 1)
	w_class = WEIGHT_CLASS_NORMAL
	foodtype = GRAIN | DAIRY | FRUIT
	eat_effect = /datum/status_effect/buff/greatmealbuff
	rotprocess = SHELFLIFE_LONG

/obj/item/reagent_containers/food/snacks/rogue/lasagna_pesto
	name = "pesto lasagna"
	desc = "Pasta sheets elegantly stacked with pesto neatly spread between. It's taste can only be described as 'zig-like', the rocknut in the pesto seeming to boil from the heat. This version is even more loved by Azurian nobles, though visiting Montecarinan signoria-bloods are known occasionally to be offended at the taste."
	icon = 'modular/Neu_Food/icons/cooked/cooked_pasta.dmi'
	icon_state = "lasagna_pesto"
	faretype = FARE_LAVISH
	list_reagents = list(/datum/reagent/consumable/nutriment = MEAL_MEAGRE, /datum/reagent/consumable/acorn_powder = 4, /datum/reagent/drug/nicotine = 4)
	tastes = list("richly smooth and salty tomatoes" = 1, "melted cheese between noodle sheets" = 1)
	w_class = WEIGHT_CLASS_NORMAL
	foodtype = GRAIN | VEGETABLES
	eat_effect = /datum/status_effect/buff/greatmealbuff
	rotprocess = SHELFLIFE_LONG
