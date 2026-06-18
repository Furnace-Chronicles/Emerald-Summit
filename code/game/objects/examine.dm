/datum/examine_effect/proc/trigger(mob/user)
	return

/datum/examine_effect/proc/get_examine_line(mob/user)
	return

/obj/item/examine(mob/user) //This might be spammy. Remove?
	. = ..()

	. += integrity_check(FALSE, user)

	if(istype(src, /mob/living))
		var/mob/living/L = src
		if(L.has_status_effect(/datum/status_effect/leash_pet))
			. += "<A href='?src=[REF(src)];'><span class='warning'>A leash is hooked to a collar!</span></A>"

	var/real_value = get_real_price()
	if(real_value > 0)
		if(HAS_TRAIT(user, TRAIT_SEEPRICES) || simpleton_price)
			. += span_info("Value: [real_value] mammon")
		else if(HAS_TRAIT(user, TRAIT_SEEPRICES_SHITTY))
			//you can get up to 50% of the value if you have shitty see prices
			var/static/fumbling_seed = text2num(GLOB.round_id)
			var/fumbled_value = max(1, round(real_value + (real_value * clamp(noise_hash(real_value, fumbling_seed) - 0.25, -0.25, 0.25)), 1))
			. += span_info("Value: [fumbled_value] mammon... <i>I think</i>")
	if(item_flags & PEASANT_WEAPON && HAS_TRAIT(user, TRAIT_PEASANTMILITIA))
		. += span_notice("Well suited for peasant hands.")

	for(var/datum/examine_effect/E in examine_effects)
		E.trigger(user)

// Lazily-built map of buildable result type -> the craft skill that builds it, limited to
// the trade skills whose practitioners should be able to read exact integrity (carpentry,
// masonry, engineering). Derived from the crafting recipe list, so it covers anything those
// trades can build, whether mapped or player-made, with no per-type tagging.
GLOBAL_LIST_EMPTY(build_skill_by_type)
GLOBAL_VAR_INIT(build_skill_lookup_ready, FALSE)

/// Returns the craft-skill typepath that builds `atom_type`, or null if it isn't a tradesman build.
/proc/get_build_skill(atom_type)
	if(!GLOB.build_skill_lookup_ready && length(GLOB.crafting_recipes))
		populate_build_skill_lookup()
	return GLOB.build_skill_by_type[atom_type]

/proc/populate_build_skill_lookup()
	GLOB.build_skill_lookup_ready = TRUE
	var/static/list/eligible_skills = list(
		/datum/skill/craft/carpentry,
		/datum/skill/craft/masonry,
		/datum/skill/craft/engineering,
	)
	var/list/exacts = list()
	for(var/rec in GLOB.crafting_recipes)
		var/datum/crafting_recipe/R = rec
		if(!(R.skillcraft in eligible_skills))
			continue
		var/res = R.result
		if(!res)
			continue
		var/list/results = islist(res) ? res : list(res)
		for(var/result_type in results)
			if(ispath(result_type))
				exacts[result_type] = R.skillcraft
	// Expand to subtypes so e.g. a reinforced wood wall inherits its parent's build skill,
	// without clobbering a more specific recipe's exact mapping.
	for(var/exact_type in exacts)
		var/skill = exacts[exact_type]
		for(var/subtype in typesof(exact_type))
			if(!(subtype in exacts) && !GLOB.build_skill_by_type[subtype])
				GLOB.build_skill_by_type[subtype] = skill
		GLOB.build_skill_by_type[exact_type] = skill

/// The build/repair skill that lets someone read this atom's exact integrity, or null.
/// Default: whatever craft builds it (from the recipe lookup). Repairable types override
/// to use their own repair skill, so anything repairable is covered.
/atom/proc/get_integrity_skill()
	return get_build_skill(type)

/obj/item/get_integrity_skill()
	return anvilrepair || ..()

/obj/structure/mineral_door/get_integrity_skill()
	return repair_skill || ..()

/// TRUE if `user` practices the trade that builds/repairs this atom well enough to read exact integrity.
/atom/proc/can_show_exact_integrity(mob/user)
	if(!user)
		return FALSE
	var/datum/skill/skill = get_integrity_skill()
	return skill && (user.get_skill_level(skill) >= SKILL_LEVEL_JOURNEYMAN)

/obj/item/proc/integrity_check(elaborate = FALSE, mob/user = null)
	if(!max_integrity)
		return
	// A tradesman of the building/repairing craft reads the exact integrity, even at full.
	if(can_show_exact_integrity(user))
		return span_notice("Integrity: [obj_integrity]/[max_integrity]")
	if(obj_integrity == max_integrity)
		return

	var/int_percent = round(((obj_integrity / max_integrity) * 100), 1)
	var/result
	if(elaborate && int_percent < 100)
		return span_warning("([int_percent]%)")
	if(obj_broken)
		return span_warning("It's broken.")
	switch(int_percent)
		if(1 to 15)
			result = span_warning("It's nearly broken.")
		if(16 to 30)
			result = span_warning("It's severely damaged.")
		if(31 to 80)
			result = span_warning("It's damaged.")
		if(80 to 99)
			result = span_warning("It's a little damaged.")
	return result

/obj/item/clothing/integrity_check(elaborate = FALSE, mob/user = null)
	if(obj_broken)
		return span_warning("It's broken.")

	// A smith of the craft that repairs this reads its exact integrity.
	if(max_integrity && can_show_exact_integrity(user))
		return span_notice("Integrity: [obj_integrity]/[max_integrity]")

	var/eff_maxint = max_integrity - (max_integrity * integrity_failure)
	var/eff_currint = max(obj_integrity - (max_integrity * integrity_failure), 0)
	var/ratio =	(eff_currint / eff_maxint)
	var/percent = round((ratio * 100), 1)
	var/result
	if(percent < 100)
		if(elaborate)
			return span_warning("([percent]%)")
		else
			switch(percent)
				if(1 to 15)
					result = span_warning("It's nearly broken.")
				if(16 to 30)
					result = span_warning("It's severely damaged.")
				if(31 to 80)
					result = span_warning("It's damaged.")
				if(80 to 99)
					result = span_warning("It's a little damaged.")
	return result
