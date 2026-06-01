/* * * * * * * * * * * **
 *						*	-Cooking based on slapcrafting
 *		 NeuFood		*	-Uses defines to track nutrition
 *						*	-Meant to replace menu crafting completely for foods
 *						*
 * * * * * * * * * * * **/


/*	........   Templates / Base items   ................ */
/obj/item/reagent_containers // added vars used in neu cooking, might be used for other things too in the future. How it works is in each items attackby code.
	var/short_cooktime = 6 SECONDS
	var/long_cooktime = 10 SECONDS

/obj/item/reagent_containers/proc/update_cooktime(mob/user)
	if(user.mind)
		short_cooktime = (initial(short_cooktime) / get_cooktime_divisor(user.get_skill_level(/datum/skill/craft/cooking)))
		long_cooktime = (initial(long_cooktime) / get_cooktime_divisor(user.get_skill_level(/datum/skill/craft/cooking)))
	else
		short_cooktime = initial(short_cooktime)
		long_cooktime = initial(long_cooktime)

/obj/item/reagent_containers/food/snacks/rogue // base food type, for icons and cooktime, and to make it work with processes like pie making
	icon = 'modular/Neu_Food/icons/unused.dmi' // Still need a backup file lol
	desc = ""
	slices_num = 0
	list_reagents = list(/datum/reagent/consumable/nutriment = 1)
	foodtype = GRAIN
	drop_sound = 'sound/foley/dropsound/gen_drop.ogg'
	cooktime = 30 SECONDS
	var/process_step // used for pie making and other similar modular foods
	var/datum/food_recipe/active_recipe
	var/current_step = 1

/obj/item/reagent_containers/food/snacks/rogue/examine(mob/user)
	. = ..()
	if(active_recipe && current_step <= active_recipe.ingredients.len)
		var/next_path = active_recipe.ingredients[current_step]
		. += span_smallnotice("Recipe: <b>[active_recipe.name]</b>. Next step: Add [initial(next_path:name)].")

	var/list/possible = SScooking.recipe_index[src.type]
	if(possible && possible.len)
		var/list/recipe_names = list()
		for(var/datum/food_recipe/R in possible)
			var/ingredient = R.ingredients[1]
			recipe_names += "[R.name] (starts with [initial(ingredient:name)])"
		. += span_smallnotice("This could be used to prepare: [recipe_names.Join(", ")].")

	if(cooked_type && fried_type == cooked_type)
		// Most foods set cooked_type == fried_type; show one line instead of two duplicates.
		var/obj/item/CT = cooked_type
		. += span_smallnotice("It is prepared and ready to be <b>cooked or fried</b> into [initial(CT.name)].")
	else
		if(cooked_type)
			var/obj/item/CT = cooked_type
			. += span_smallnotice("It is prepared and ready to be <b>cooked</b> into [initial(CT.name)].")
		if(fried_type)
			var/obj/item/FT = fried_type
			. += span_smallnotice("It is prepared and ready to be <b>fried</b> into [initial(FT.name)].")
	if(slice_path)
		var/obj/item/ST = slice_path
		. += span_smallnotice("It is prepared and ready to be <b>sliced</b> into [initial(ST.name)].")

/obj/item/reagent_containers/food/snacks/rogue/MiddleClick(mob/user)
	. = ..()

	if(!active_recipe)
		to_chat(user, span_warning("There is no recipe currently active on [src]."))
		return

	var/confirmation = tgui_alert(user, "Are you sure you want to reset the preparation for [active_recipe.name]?", "Reset Recipe", list("Yes", "No"))
	if(confirmation != "Yes" || !active_recipe)
		return

	to_chat(user, span_notice("You clear the preparation progress for [active_recipe.name] from [src]."))
	active_recipe = null
	current_step = 1
	cut_overlays()

/obj/item/reagent_containers/food/snacks/rogue/attackby(obj/item/I, mob/living/user)
	if(!active_recipe)
		var/datum/food_recipe/R = SScooking.get_recipe(src, I)
		if(R)
			active_recipe = R
		else
			return ..()

	var/obj/structure/table/T = locate() in loc
	if(!T)
		to_chat(user, span_warning("You need a table to prepare [src.name]."))
		return

	var/requirement = active_recipe.ingredients[current_step]

	if(ispath(requirement, /datum/reagent))
		var/amt = active_recipe.ingredients[requirement]
		if(I.reagents && I.reagents.has_reagent(requirement, amt))
			do_cooking_step(I, user, requirement, amt)
			return
		else
			to_chat(user, span_warning("You need at least [amt] units of [initial(requirement:name)]!"))
			return

	if(current_step <= active_recipe.ingredients.len && istype(I, active_recipe.ingredients[current_step]))
		do_cooking_step(I, user)
		return

	return ..()

/obj/item/reagent_containers/food/snacks/rogue/proc/do_cooking_step(obj/item/I, mob/living/user, req_reagent, req_amt)
	if(!do_after(user, get_cooking_do_time(user, active_recipe.time_per_step), target = src))
		if(current_step == 1)
			active_recipe = null
		return

	playsound(src, 'sound/foley/dropsound/gen_drop.ogg', 30, TRUE)

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.mind.add_sleep_experience(/datum/skill/craft/cooking, H.STAINT * active_recipe.experience_per_step)
	if(req_reagent)
		// Re-verify reagent exists after the timer
		if(!I.reagents || !I.reagents.has_reagent(req_reagent, req_amt))
			return
		I.reagents.remove_reagent(req_reagent, req_amt)
		playsound(src, 'modular/Creechers/sound/milking1.ogg', 50, TRUE)
	else
		playsound(src, 'sound/foley/dropsound/gen_drop.ogg', 30, TRUE)
		I.moveToNullspace()

	if(current_step < active_recipe.ingredients.len || active_recipe.needs_cooking)
		var/image/over = image(I.icon, I.icon_state)
		over.transform = matrix() * 0.7
		switch(current_step)
			if(1) { over.pixel_x = -7; over.pixel_y = 7 }   // NW
			if(2) { over.pixel_x = 7;  over.pixel_y = 7 }   // NE
			if(3) { over.pixel_x = 7;  over.pixel_y = -7 }  // SE
			if(4) { over.pixel_x = -7; over.pixel_y = -7 }  // SW
		add_overlay(over)

	var/recipe_name = active_recipe.name
	if(!req_reagent)
		qdel(I)
	current_step++
	if(current_step > active_recipe.ingredients.len)
		if(!active_recipe.needs_cooking)
			finalize_cooking(user)
		else
			to_chat(user, span_nicegreen("[name] is ready to be cooked."))
			cooked_type = active_recipe.result_type
			fried_type = active_recipe.result_type
			active_recipe = null
			current_step = 1
	else
		var/next_path = active_recipe.ingredients[current_step]
		to_chat(user, span_notice("You add to the [recipe_name]. Next: add [initial(next_path:name)]."))

/obj/item/reagent_containers/food/snacks/rogue/proc/finalize_cooking(mob/living/user)
	var/res_type = active_recipe.result_type
	var/obj/item/RT = res_type
	var/turf/T = get_turf(src)
	cut_overlays()
	playsound(T, 'sound/foley/dropsound/food_drop.ogg', 50, TRUE)
	new res_type(T)
	if(user)
		user.visible_message(span_notice("[user] finishes preparing [initial(RT.name)]."), span_notice("I finish preparing [initial(RT.name)]."))
	active_recipe = null
	qdel(src)

/obj/item/reagent_containers/food/snacks/rogue/Initialize()
	. = ..()
	eatverb = pick("bite","chew","nibble","gobble","chomp")

/obj/item/reagent_containers/food/snacks/rogue/foodbase // root item for uncooked food thats disgusting when raw
	list_reagents = list(/datum/reagent/consumable/nutriment = SNACK_POOR)
	bitesize = 3
	eat_effect = /datum/status_effect/debuff/uncookedfood

/obj/item/reagent_containers/food/snacks/rogue/foodbase/New() // disables the random placement on creation for this object MAYBE OBSOLETE?
	..()
	pixel_x = 0
	pixel_y = 0

/obj/item/reagent_containers/food/snacks/rogue/preserved // just convenient way to group food with long rotprocess
	bitesize = 3
	list_reagents = list(/datum/reagent/consumable/nutriment = SNACK_POOR)
	rotprocess = SHELFLIFE_EXTREME

/obj/item/reagent_containers/food/snacks
	var/chopping_sound = FALSE // does it play a choppy sound when batch sliced?
	var/slice_sound = FALSE // does it play the slice sound when sliced?

/obj/item/reagent_containers/food/snacks/proc/changefood(path, mob/living/eater)
	if(!path || !eater)
		return
	var/turf/T = get_turf(eater)
	if(eater.dropItemToGround(src))
		qdel(src)
	var/obj/item/I = new path(T)
	eater.put_in_active_hand(I)

/obj/effect/decal/cleanable/food/mess // decal applied when throwing minced meat for example
	name = "mess"
	desc = ""
	color = "#ab9d9d"
	icon_state = "tomato_floor1"
	random_icon_states = list("tomato_floor1", "tomato_floor2", "tomato_floor3")

/obj/item/reagent_containers/food/snacks/attackby(obj/item/W, mob/user, params)
	if(user.used_intent.blade_class == slice_bclass && W.wlength == WLENGTH_SHORT)
		if(slice_bclass == BCLASS_CHOP)
			user.visible_message(span_notice("[user] chops [src]!"))
			slice(W, user)
			return 1
		else if(slice(W, user))
			return 1
	..()

/* added to proc
/obj/item/reagent_containers/food/snacks/proc/slice(obj/item/W, mob/user)
	if(slice_sound)
		playsound(user, 'modular/Neu_Food/sound/slicing.ogg', 60, TRUE, -1) // added some choppy sound
	if(chopping_sound)
		playsound(user, 'modular/Neu_Food/sound/chopping_block.ogg', 60, TRUE, -1) // added some choppy sound
*/
/*	........   Kitchen tools / items   ................ */


/obj/item/rogueweapon/huntingknife/cleaver
	lefthand_file = 'modular/Neu_Food/icons/food_lefthand.dmi'
	righthand_file = 'modular/Neu_Food/icons/food_righthand.dmi'
	item_state = "cleaver"
	experimental_inhand = FALSE
	experimental_onhip = FALSE
	experimental_onback = FALSE

/obj/item/book/rogue/yeoldecookingmanual // new book with some tips to learn
	name = "Ye olde ways of cookinge"
	desc = "Penned by Svend Fatbeard, butler in the fourth generation"
	icon_state ="book8_0"
	base_icon_state = "book8"
	bookfile = "Neu_cooking.json"

/* * * * * * * * * * * * * * *	*
 *								*
 *		Powder & Salt			*
 *					 			*
 *								*
 * * * * * * * * * * * * * * * 	*/

// -------------- Flour -----------------
/obj/item/reagent_containers/powder/flour
	name = "flour"
	desc = "With this ambition, we build an empire."
	gender = PLURAL
	icon_state = "flour"
	list_reagents = list(/datum/reagent/floure = 1)
	volume = 1
	sellprice = 0
	var/water_added

/obj/item/reagent_containers/powder/flour/throw_impact(atom/hit_atom, datum/thrownthing/thrownthing)
	new /obj/effect/decal/cleanable/food/flour(get_turf(src))
	..()
	qdel(src)

/obj/item/reagent_containers/powder/flour/attackby(obj/item/I, mob/living/user, params)
	var/found_table = locate(/obj/structure/table) in (loc)
	var/obj/item/reagent_containers/R = I
	update_cooktime(user)
	if(!istype(R) || (water_added))
		return ..()
	if(isturf(loc)&& (!found_table))
		to_chat(user, span_notice("Need a table..."))
		return ..()
	if(!R.reagents.has_reagent(/datum/reagent/water, 10))
		to_chat(user, span_notice("Needs more water to work it."))
		return TRUE
	to_chat(user, span_notice("Adding water, now its time to knead it..."))
	playsound(user, 'modular/Neu_Food/sound/splishy.ogg', 100, TRUE, -1)
	if(do_after(user, short_cooktime, target = src))
		add_sleep_experience(user, /datum/skill/craft/cooking, user.STAINT)
		name = "wet flour"
		desc = "Destined for greatness, at your hands."
		R.reagents.remove_reagent(/datum/reagent/water, 10)
		water_added = TRUE
		color = "#d9d0cb"
	return TRUE

/obj/item/reagent_containers/powder/flour/attack_hand(mob/living/user)
	if(water_added)
		playsound(user, 'modular/Neu_Food/sound/kneading_alt.ogg', 90, TRUE, -1)
		if(do_after(user, short_cooktime, target = src))
			add_sleep_experience(user, /datum/skill/craft/cooking, user.STAINT)
			new /obj/item/reagent_containers/food/snacks/rogue/dough_base(loc)
			qdel(src)
	else ..()


// -------------- SALT -----------------
/obj/item/reagent_containers/powder/salt
	name = "salt"
	desc = ""
	gender = PLURAL
	icon_state = "salt"
	list_reagents = list(/datum/reagent/floure = 1)
	volume = 1
	sellprice = 0

/obj/item/reagent_containers/powder/salt/throw_impact(atom/hit_atom, datum/thrownthing/thrownthing)
	new /obj/effect/decal/cleanable/food/flour(get_turf(src))
	..()
	qdel(src)

/* -------------- RICE ----------------- */
/obj/item/reagent_containers/food/snacks/grown/rice
	list_reagents = list(/datum/reagent/floure = 1)
	volume = 1
	sellprice = 3
	var/water_added

/obj/item/reagent_containers/food/snacks/grown/rice/attackby(obj/item/I, mob/living/user, params)
	var/found_table = locate(/obj/structure/table) in (loc)
	var/obj/item/reagent_containers/R = I
	update_cooktime(user)
	if(!istype(R) || (water_added))
		return ..()
	if(isturf(loc)&& (!found_table))
		to_chat(user, "<span class='notice'>Need a table...</span>")
		return ..()
	if(!R.reagents.has_reagent(/datum/reagent/water, 10))
		to_chat(user, "<span class='notice'>Needs more water to work it.</span>")
		return TRUE
	to_chat(user, "<span class='notice'>Adding water, now its time to hand wash it...</span>")
	playsound(user, 'modular/Neu_Food/sound/splishy.ogg', 100, TRUE, -1)
	if(do_after(user,2 SECONDS, target = src))
		user.adjust_experience(/datum/skill/craft/cooking, user.STAINT * 0.8)
		name = "wet rice"
		R.reagents.remove_reagent(/datum/reagent/water, 10)
		water_added = TRUE
		color = "#d9d0cb"
	return TRUE

/obj/item/reagent_containers/food/snacks/grown/rice/attack_hand(mob/living/user)
	if(water_added)
		playsound(user, 'modular/Neu_Food/sound/kneading_alt.ogg', 90, TRUE, -1)
		if(do_after(user,3 SECONDS, target = src))
			user.adjust_experience(/datum/skill/craft/cooking, user.STAINT * 0.8)
			new /obj/item/reagent_containers/food/snacks/rogue/ricewet(loc)
			qdel(src)
	else ..()

/* -------------- WET RICE ----------------- */
/obj/item/reagent_containers/food/snacks/rogue/ricewet
	name = "washed rice"
	desc = ""
	gender = PLURAL
	icon = 'icons/roguetown/items/produce.dmi'
	icon_state = "rice"
	list_reagents = list(/datum/reagent/floure = 1)
	cooked_type = /obj/item/reagent_containers/food/snacks/rogue/preserved/rice_cooked
	volume = 1
	sellprice = 0

/obj/item/reagent_containers/powder/mineral
	name = "coarse minerals"
	desc = "ground up rock, could be made into mineral salts with more work."
	gender = PLURAL
	icon_state = "salt"
	list_reagents = list(/datum/reagent/floure = 1)
	volume = 1
	sellprice = 0
	var/water_added

/obj/item/reagent_containers/powder/coarse_salt
	name = "coarse salt"
	desc = "somewhat gritty, coarse salt. Could be ground down into finer salt."
	gender = PLURAL
	icon_state = "salt"
	list_reagents = list(/datum/reagent/floure = 1)
	volume = 1
	sellprice = 0
	color = "#999797"
	mill_result = /obj/item/reagent_containers/powder/salt

/obj/item/reagent_containers/powder/mineral/throw_impact(atom/hit_atom, datum/thrownthing/thrownthing)
	new /obj/effect/decal/cleanable/food/flour(get_turf(src))
	..()
	qdel(src)

/obj/item/reagent_containers/powder/mineral/attackby(obj/item/I, mob/user, params)
	var/found_table = locate(/obj/structure/table) in (loc)
	var/obj/item/reagent_containers/R = I
	update_cooktime(user)
	if(!istype(R) || (water_added))
		return ..()
	if(isturf(loc)&& (!found_table))
		to_chat(user, span_notice("Need a table..."))
		return ..()
	if(!R.reagents.has_reagent(/datum/reagent/water, 10))
		to_chat(user, span_notice("Needs more water to work it."))
		return TRUE
	to_chat(user, span_notice("Adding water, now its time to sift it..."))
	playsound(user, 'modular/Neu_Food/sound/splishy.ogg', 100, TRUE, -1)
	if(do_after(user, short_cooktime, target = src))
		name = "prepared minerals"
		desc = "Still quite coarse, needs some sifting."
		R.reagents.remove_reagent(/datum/reagent/water, 10)
		water_added = TRUE
		color = "#666262"
	return TRUE

/obj/item/reagent_containers/powder/mineral/attackby(obj/item/I, mob/user, params)
	if(water_added)
		if(istype(I, /obj/item/natural/cloth))
			user.visible_message(span_info("[user] sifts the minerals..."))
			playsound(user, 'modular/Neu_Food/sound/peppermill.ogg', 90, TRUE, -1)
			if(do_after(user,3 SECONDS, target = src))
				new /obj/item/reagent_containers/powder/coarse_salt(loc)
				qdel(src)
	else ..()
