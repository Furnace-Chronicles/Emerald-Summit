/datum/food_recipe
	abstract_type = /datum/food_recipe
	var/name = "Generic Recipe"
	/// What item is used to start a recipe, e.g a piece of raw steak
	var/base_item = null
	/// Ingredients in order of completion
	var/list/ingredients = list()
	/// Resulting item
	var/result_type = null
	/// Legacy flag: Use cook_method for new recipes instead. If TRUE, it sets fried_type and cooked_type
	var/needs_cooking = FALSE
	/// One of COOK_BAKE, COOK_FRY, COOK_DEEPFRY, COOK_BOIL. Set what station is used to finish cooking the item
	var/cook_method = null
	/// How many copies of result_type to spawn
	var/result_amount = 1
	/// Where the recipe must be performed. Null for anywhere
	var/required_station = /obj/structure/table
	/// Excluded from the encyclopedia's top-level list (surfaced only inline under a parent dish).
	var/hidden = FALSE
	/// step_visuals[i] = list(icon_file, icon_state). Icon used after Step 1
	var/list/step_visuals = list()
	/// step_overlays[i] = list(icon_file, icon_state) added as an overlay after step i.
	var/list/step_overlays = list()
	/// How long it takes to add items
	var/time_per_step = 2 SECONDS
	/// Experience per step per int
	var/experience_per_step = 0.5
	/// Economy bucket used by the pricing engine.
	var/display_category = ITEM_CAT_FOODSTUFF_FRESH
	/// Encyclopedia sidebar bucket. One of the FOOD_CAT_* defines.
	var/book_category = FOOD_CAT_COMBINATION
	/// Minimum cooking skill required to recall this recipe by examining an ingredient/precursor.
	var/min_skill = SKILL_LEVEL_APPRENTICE
	var/restricted_message = null
	var/list/extra_steps = list()
	var/result_smell = null
	/// If TRUE, the encyclopedia inlines this recipe's entire prerequisite chain as one step list instead of linking out.
	var/inline_ancestry = FALSE

/datum/food_recipe/proc/user_can_make(mob/user)
	return TRUE

/datum/food_recipe/proc/get_wiki_key()
	return "[type]"

/datum/food_recipe/single_cook
	required_station = null
	var/wiki_key

/datum/food_recipe/single_cook/get_wiki_key()
	return wiki_key

/datum/food_recipe/proc/step_accepts(entry, obj/item/I)
	if(!entry || !I)
		return FALSE
	if(entry == COOKSTEP_SHARP)
		return I.get_sharpness()
	if(ispath(entry, /datum/reagent))
		var/amt = ingredients[entry]
		return (I.reagents && I.reagents.has_reagent(entry, amt))
	if(islist(entry))
		for(var/p in entry)
			if(istype(I, p))
				return TRUE
		return FALSE
	return istype(I, entry)

/datum/food_recipe/proc/step_label(entry)
	if(entry == COOKSTEP_SHARP)
		return "a sharp tool"
	if(ispath(entry, /datum/reagent))
		var/datum/reagent/R = entry
		return "[ingredients[entry]]u of [initial(R.name)]"
	if(islist(entry))
		var/list/names = list()
		for(var/atom/p as anything in entry)
			names += initial(p.name)
		return "one of: [names.Join(", ")]"
	var/atom/A = entry
	return initial(A.name)

/datum/food_recipe/proc/render_step_li(entry, mob/user)
	if(entry == COOKSTEP_SHARP)
		return "<li>Score it with <b>any sharp tool</b></li>"
	if(ispath(entry, /datum/reagent))
		var/amt = ingredients[entry]
		var/datum/reagent/R = entry
		return "<li>Add [amt]u of [initial(R.name)]</li>"
	if(islist(entry))
		var/list/options = list()
		for(var/atom/opt as anything in entry)
			options += "[icon2html(new opt, user)] [initial(opt.name)]"
		return "<li>Add one of: [options.Join(", ")]</li>"
	if(ingredients[entry] == COOKSTEP_TOOL)
		var/atom/A = entry
		return "<li>Apply [icon2html(new A, user)] [initial(A.name)]</li>"
	var/atom/A = entry
	return "<li>Add [icon2html(new A, user)] [initial(A.name)]</li>"

/datum/food_recipe/proc/cook_step_li()
	switch(cook_method)
		if(COOK_BAKE)
			return "<li><b>Bake</b> it in an oven</li>"
		if(COOK_FRY)
			return "<li><b>Fry</b> it in a pan over a hearth</li>"
		if(COOK_DEEPFRY)
			return "<li><b>Deep-fry</b> it in a pot of hot oil</li>"
		if(COOK_BOIL)
			return "<li><b>Boil</b> it in a pot of water</li>"
	if(needs_cooking)
		return "<li><b>Cook</b> it over a hearth, or in an oven</li>"
	return ""

/datum/food_recipe/proc/build_journey(mob/user, depth = 0, full = FALSE)
	full ||= inline_ancestry
	var/list/steps = list()
	var/atom/base = islist(base_item) ? base_item[1] : base_item
	if(depth < 10)
		var/datum/food_recipe/pre = SScooking?.get_producing_recipe(base)
		if(pre && pre != src && (full || pre.hidden))
			var/list/pre_data = pre.build_journey(user, depth + 1, full)
			base = pre_data["base"]
			steps += pre_data["steps"]
	for(var/i in 1 to length(ingredients))
		steps += render_step_li(ingredients[i], user)
	for(var/note in extra_steps)
		steps += "<li>[note]</li>"
	if(depth > 0)
		var/cook_li = cook_step_li()
		if(cook_li)
			steps += cook_li
	return list("base" = base, "steps" = steps)

/datum/food_recipe/proc/generate_html(mob/user)
	var/html = "<h2>[name]</h2>"

	var/list/journey = build_journey(user)
	var/atom/base = journey["base"]
	if(islist(base_item) && length(base_item) > 1)
		var/list/base_names = list()
		for(var/atom/b as anything in base_item)
			base_names += "[icon2html(new b, user)] [initial(b.name)]"
		html += "<p><b>Start with any of:</b> [base_names.Join(", ")]</p>"
	else if(base)
		html += "<p><b>Start with:</b> [icon2html(new base, user)] [initial(base.name)]</p>"

	var/list/steps = journey["steps"]
	var/cook_li = cook_step_li()
	if(cook_li)
		steps += cook_li
	if(length(steps))
		html += "<h3>Then, in order:</h3><ul>[steps.Join()]</ul>"

	var/atom/result = result_type
	if(result)
		html += "<p><b>Produces:</b> [icon2html(new result, user)] [initial(result.name)]</p>"
		var/result_details = describe_food_result(result)
		if(result_details)
			html += result_details

	html += "<p>Each step takes about [time_per_step / 10] seconds before cooking skill modifiers.</p>"

	if(SScooking?.recipe_index && result_type)
		var/list/follow_ups = SScooking.recipe_index[result_type]
		if(length(follow_ups))
			var/follow_html = ""
			for(var/datum/food_recipe/F in follow_ups)
				if(F.hidden) continue
				follow_html += "<li>[F.name]</li>"
			if(follow_html)
				html += "<h3>Can be further prepared into:</h3><ul>[follow_html]</ul>"

	return html

/proc/describe_food_result(atom/result_path)
	if(!ispath(result_path, /obj/item/reagent_containers/food/snacks))
		return ""
	var/obj/item/reagent_containers/food/snacks/proto = new result_path()
	var/list/lines = list()

	switch(proto.faretype)
		if(FARE_IMPOVERISHED)
			lines += "Quality: Impoverished (fit for the desperate)."
		if(FARE_POOR)
			lines += "Quality: Poor (fit for the poor)."
		if(FARE_NEUTRAL)
			lines += "Quality: Neutral (decent food)."
		if(FARE_FINE)
			lines += "Quality: Fine."
		if(FARE_LAVISH)
			lines += "Quality: Lavish."

	var/list/declared_reagents = proto.list_reagents
	var/total_nutrition = 0
	if(islist(declared_reagents))
		total_nutrition = declared_reagents[/datum/reagent/consumable/nutriment]
	if(total_nutrition > 0)
		lines += "Nutrition: [total_nutrition]."

	var/list/other_reagents = list()
	if(islist(declared_reagents))
		for(var/r_path in declared_reagents)
			if(r_path == /datum/reagent/consumable/nutriment)
				continue
			var/datum/reagent/R = r_path
			other_reagents += "[initial(R.name)] ([declared_reagents[r_path]]u)"
	if(length(other_reagents))
		lines += "Also contains: [other_reagents.Join(", ")]."

	var/buff_desc = describe_food_effect(proto.eat_effect)
	if(buff_desc)
		lines += "Effect on eating: [buff_desc]."
	var/extra_desc = describe_food_effect(proto.extra_eat_effect)
	if(extra_desc)
		lines += "Bonus effect: [extra_desc]."

	var/atom/baked_target = proto.cooked_type
	var/atom/fried_target = proto.fried_type
	if(baked_target == proto.type)
		baked_target = null
	if(fried_target == proto.type)
		fried_target = null
	if(baked_target && baked_target == fried_target)
		lines += "Cooks into [initial(baked_target.name)] in an oven or pan."
	else
		if(baked_target)
			lines += "Bakes into [initial(baked_target.name)]."
		if(fried_target)
			lines += "Fries into [initial(fried_target.name)]."
	var/atom/deep_target = proto.deep_fried_type
	if(deep_target && deep_target != proto.type)
		lines += "Deep-fries into [initial(deep_target.name)]."

	var/atom/slice_target = proto.slice_path
	if(slice_target)
		var/count = proto.slices_num || 1
		lines += "Can be cut into [count] x [initial(slice_target.name)]."

	qdel(proto)

	if(!length(lines))
		return ""
	return "<p>[lines.Join("<br>")]</p>"

/proc/describe_food_effect(effect_path)
	if(!ispath(effect_path, /datum/status_effect))
		return null
	var/datum/status_effect/S = effect_path
	var/label
	var/alert_path = initial(S.alert_type)
	if(ispath(alert_path, /atom))
		var/atom/A = alert_path
		label = initial(A.name)
	if(!label)
		label = initial(S.id) || "[effect_path]"

	var/list/parts = list("<b>[label]</b>")
	var/duration = initial(S.duration)
	if(duration && duration > 0)
		parts += "for [duration_label(duration)]"
	return parts.Join(" ")

/proc/duration_label(deciseconds)
	var/seconds = deciseconds / 10
	if(seconds >= 60)
		var/minutes = round(seconds / 60)
		return "[minutes] minute[minutes == 1 ? "" : "s"]"
	return "[seconds] seconds"
