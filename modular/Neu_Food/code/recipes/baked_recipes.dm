// Hardtack + Chocolate -> Half Cookie (Chocolate)
/datum/food_recipe/half_cookie_chocolate
	name = "Chocolate Cookie Dough"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/foodbase/hardtack_raw
	ingredients = list(
		/obj/item/reagent_containers/food/snacks/chocolate/slice
	)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/foodbase/halfcookie_raw

// Hardtack + Raisins -> Half Cookie (Raisin)
/datum/food_recipe/half_cookie_raisin
	name = "Raisin Cookie Dough"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/foodbase/hardtack_raw
	ingredients = list(
		/obj/item/reagent_containers/food/snacks/rogue/raisins
	)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/foodbase/halfcookier_raw

// Hardtack + Caramel -> Half Cookie (Caramel)
/datum/food_recipe/half_cookie_caramel
	name = "Caramel Cookie Dough"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/foodbase/hardtack_raw
	ingredients = list(
		/obj/item/reagent_containers/food/snacks/caramel
	)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/foodbase/halfcookiec_raw

// Hardtack + Dragée -> Half Cookie (Dragée)
/datum/food_recipe/half_cookie_dragee
	name = "Dragée Cookie Dough"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/foodbase/hardtack_raw
	ingredients = list(
		/obj/item/reagent_containers/food/snacks/dragee
	)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/foodbase/halfcookied_raw

// Bread Slice + Salami -> Salumoi Sandwich
/datum/food_recipe/sandwich_salami
	name = "Salumoi Bread"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/breadslice
	ingredients = list(
		/obj/item/reagent_containers/food/snacks/rogue/meat/salami/slice
	)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/sandwich/salami

// Bread Slice + Cheese Slice -> Cheese Bread
/datum/food_recipe/sandwich_cheese
	name = "Cheese Bread"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/breadslice
	ingredients = list(
		/obj/item/reagent_containers/food/snacks/rogue/cheddarslice
	)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/sandwich/cheese

// Bread Slice + Salo -> Salo Bread
/datum/food_recipe/sandwich_salo
	name = "Salo Bread"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/breadslice
	ingredients = list(
		/obj/item/reagent_containers/food/snacks/fat/salo/slice
	)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/sandwich/salo

// Bread Slice + Bacon -> Bacon Bread
/datum/food_recipe/sandwich_bacon
	name = "Bacon Bread"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/breadslice
	ingredients = list(
		/obj/item/reagent_containers/food/snacks/rogue/meat/bacon/fried
	)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/sandwich/bacon

// Toast + Butter -> Buttered Toast
/datum/food_recipe/buttered_toast
	name = "Buttered Toast"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/breadslice/toast
	ingredients = list(
		/obj/item/reagent_containers/food/snacks/butterslice
	)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/breadslice/toast/buttered

// Toast + Fried Egg -> Egg Toast
/datum/food_recipe/egg_toast
	name = "Egg Toast"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/breadslice/toast
	ingredients = list(
		/obj/item/reagent_containers/food/snacks/rogue/friedegg/fried
	)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/sandwich/egg

// Toast + Jamtallow Slice -> Jamtallowed Toast
/datum/food_recipe/jamtallowed_toast
	name = "Jamtallowed Toast"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/breadslice/toast
	ingredients = list(
		/obj/item/reagent_containers/food/snacks/jamtallowslice
	)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/breadslice/toast/jamtallowed_slice

// Toast + Marmalade Slice -> Marmaladed Toast
/datum/food_recipe/marmaladed_toast
	name = "Marmaladed Toast"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/breadslice/toast
	ingredients = list(
		/obj/item/reagent_containers/food/snacks/marmaladeslice
	)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/breadslice/toast/marmaladed_slice

// Toast + Ham -> Ham Bread
/datum/food_recipe/ham_bread
	name = "Ham Bread"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/breadslice/toast
	ingredients = list(
		/obj/item/reagent_containers/food/snacks/rogue/meat/ham/sliced
	)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/sandwich/ham

// Bun + Sausage -> Grenzelbun (Hotdog)
/datum/food_recipe/grenzelbun
	name = "Grenzelbun"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/bun
	ingredients = list(
		/obj/item/reagent_containers/food/snacks/rogue/meat/sausage/cooked
	)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/bun_grenz

// Bun + Cheese Wedge -> Raston
/datum/food_recipe/raston
	name = "Raston"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/bun
	ingredients = list(
		/obj/item/reagent_containers/food/snacks/rogue/cheddarwedge
	)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/bun_raston

// Bun + Jamtallow Slice -> Jamtallowed Bun
/datum/food_recipe/jamtallowed_bun
	name = "Jamtallowed Bun"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/bun
	ingredients = list(
		/obj/item/reagent_containers/food/snacks/jamtallowslice
	)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/bun_jamtallow

// Bun + Marmalade Slice -> Marmaladed Bun
/datum/food_recipe/marmaladed_bun
	name = "Marmaladed Bun"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/bun
	ingredients = list(
		/obj/item/reagent_containers/food/snacks/marmaladeslice
	)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/bun_marmalade

// Crossbun + Jamtallow -> Jamtallowed Crossbun
/datum/food_recipe/jamtallowed_crossbun
	name = "Jamtallowed Crossbun"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/crossbun
	ingredients = list(
		/obj/item/reagent_containers/food/snacks/jamtallowslice
	)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/crossbun_jamtallowed

// Crossbun + Marmalade -> Marmaladed Crossbun
/datum/food_recipe/marmaladed_crossbun
	name = "Marmaladed Crossbun"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/crossbun
	ingredients = list(
		/obj/item/reagent_containers/food/snacks/marmaladeslice
	)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/crossbun_marmaladed

// Psycrossbun + Jamtallow -> Jamtallowed Psycrossbun
/datum/food_recipe/jamtallowed_psycrossbun
	name = "Jamtallowed Psycrossbun"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/psycrossbun
	ingredients = list(
		/obj/item/reagent_containers/food/snacks/jamtallowslice
	)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/psycrossbun_jamtallowed

// Psycrossbun + Marmalade -> Marmaladed Psycrossbun
/datum/food_recipe/marmaladed_psycrossbun
	name = "Marmaladed Psycrossbun"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/psycrossbun
	ingredients = list(
		/obj/item/reagent_containers/food/snacks/marmaladeslice
	)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/psycrossbun_marmaladed

// Half Raisin Dough + Raisins -> Raw Raisin Loaf
/datum/food_recipe/raisin_bread_complete
	name = "Complete Raisin Dough"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/rbread_half
	ingredients = list(
		/obj/item/reagent_containers/food/snacks/rogue/raisins
	)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/rbreaduncooked

// Half Apple Dough + Apple Slices -> Raw Apple Loaf
/datum/food_recipe/apple_bread_complete
	name = "Complete Apple Dough"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/abread_half
	ingredients = list(
		/obj/item/reagent_containers/food/snacks/rogue/fruit/apple_sliced
	)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/abreaduncooked

/*	.................   Lasagna assembly   ................... */
/datum/food_recipe/baked/lasagna_white
	name = "white lasagna"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/eggdoughsheetnoodles
	ingredients = list(
		/obj/item/reagent_containers/food/snacks/rogue/cheese
	)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/eggdoughsheetnoodles_white
	time_per_step = 3 SECONDS
	inline_ancestry = TRUE

/datum/food_recipe/baked/lasagna_red
	name = "red lasagna"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/eggdoughsheetnoodles
	ingredients = list(
		/obj/item/reagent_containers/food/snacks/grown/fruit/tomato_sauce
	)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/eggdoughsheetnoodles_red
	time_per_step = 3 SECONDS
	inline_ancestry = TRUE

/datum/food_recipe/baked/lasagna_pesto
	name = "pesto lasagna"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/eggdoughsheetnoodles
	ingredients = list(
		/obj/item/reagent_containers/food/snacks/rogue/pesto
	)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/eggdoughsheetnoodles_pesto
	time_per_step = 3 SECONDS
	inline_ancestry = TRUE

/datum/food_recipe/baked/lasagna_redwhite_from_red
	name = "cheesy lasagna"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/eggdoughsheetnoodles_red
	ingredients = list(
		/obj/item/reagent_containers/food/snacks/rogue/cheese
	)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/eggdoughsheetnoodles_redwhite
	time_per_step = 3 SECONDS
	inline_ancestry = TRUE

/datum/food_recipe/baked/lasagna_redwhite_from_white
	name = "cheesy lasagna"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/eggdoughsheetnoodles_white
	ingredients = list(
		/obj/item/reagent_containers/food/snacks/grown/fruit/tomato_sauce
	)
	result_type = /obj/item/reagent_containers/food/snacks/rogue/eggdoughsheetnoodles_redwhite
	time_per_step = 3 SECONDS
	inline_ancestry = TRUE

/*	.................   Griddle fruit cakes   ................... */
/datum/food_recipe/baked/griddle_lemon
	name = "lemongriddles"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/griddle_uncooked
	ingredients = list(
		/obj/item/reagent_containers/food/snacks/grown/fruit/lemon
	)
	step_visuals = list(list('modular/Neu_Food/icons/raw/raw_dough.dmi', "griddlelemon_uncooked"))
	cook_method = COOK_FRY
	result_type = /obj/item/reagent_containers/food/snacks/rogue/griddle/fruit/lemon
	inline_ancestry = TRUE

/datum/food_recipe/baked/griddle_berry
	name = "berrygriddles"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/griddle_uncooked
	ingredients = list(
		list(
			/obj/item/reagent_containers/food/snacks/grown/fruit/blackberry,
			/obj/item/reagent_containers/food/snacks/grown/fruit/raspberry,
			/obj/item/reagent_containers/food/snacks/grown/berries/rogue,
		)
	)
	step_visuals = list(list('modular/Neu_Food/icons/raw/raw_dough.dmi', "griddleberry_uncooked"))
	cook_method = COOK_FRY
	result_type = /obj/item/reagent_containers/food/snacks/rogue/griddle/fruit/berry
	inline_ancestry = TRUE

/datum/food_recipe/baked/griddle_poisonberry
	name = "berrygriddles"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/griddle_uncooked
	ingredients = list(
		/obj/item/reagent_containers/food/snacks/grown/berries/rogue/poison
	)
	step_visuals = list(list('modular/Neu_Food/icons/raw/raw_dough.dmi', "griddleberry_uncooked"))
	cook_method = COOK_FRY
	result_type = /obj/item/reagent_containers/food/snacks/rogue/griddle/fruit/poisonberry
	inline_ancestry = TRUE
	hidden = TRUE

/datum/food_recipe/baked/griddle_apple
	name = "applegriddles"
	base_item = /obj/item/reagent_containers/food/snacks/rogue/griddle_uncooked
	ingredients = list(
		/obj/item/reagent_containers/food/snacks/rogue/fruit/apple_sliced
	)
	step_visuals = list(list('modular/Neu_Food/icons/raw/raw_dough.dmi', "griddleapple_uncooked"))
	cook_method = COOK_FRY
	result_type = /obj/item/reagent_containers/food/snacks/rogue/griddle/fruit/apple
	inline_ancestry = TRUE
