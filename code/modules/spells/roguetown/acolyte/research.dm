#undef  MIRACLE_RADIAL_DMI
#define MIRACLE_RADIAL_DMI 'icons/mob/actions/roguespells.dmi'

#ifndef TRAIT_CLERGY
#define TRAIT_CLERGY "clergy"
#endif

#ifndef CLERIC_PRICE_PATRON
#define CLERIC_PRICE_PATRON 1
#endif
#ifndef CLERIC_PRICE_DIVINE
#define CLERIC_PRICE_DIVINE 3
#endif
#ifndef CLERIC_PRICE_SHUNNED
#define CLERIC_PRICE_SHUNNED 3
#endif

/mob/living/carbon/human
	var/miracle_points = 0

var/global/list/divine_miracles_cache  = list()
var/global/list/inhumen_miracles_cache = list()
var/global/miracle_caches_built = FALSE

/proc/build_miracle_caches()
	if(miracle_caches_built) return
	build_cache_for_root(/datum/patron/divine,  divine_miracles_cache)
	build_cache_for_root(/datum/patron/inhumen, inhumen_miracles_cache)
	miracle_caches_built = TRUE

/proc/build_cache_for_root(root_type, list/cache)
	for(var/p_type in typesof(root_type))
		if(p_type == root_type) continue
		var/datum/patron/P = new p_type
		if(length(P.miracles))
			for(var/st in P.miracles)
				cache[st] = TRUE
		qdel(P)

/proc/is_patron_spell(datum/devotion/D, obj/effect/proc_holder/spell/S)
	if(!D || !D.patron || !length(D.patron.miracles))
		return FALSE
	return (S.type in D.patron.miracles)

/proc/is_divine_spell(obj/effect/proc_holder/spell/S)
	if(!miracle_caches_built) build_miracle_caches()
	return !!divine_miracles_cache[S.type]

/proc/is_inhumen_spell(obj/effect/proc_holder/spell/S)
	if(!miracle_caches_built) build_miracle_caches()
	return !!inhumen_miracles_cache[S.type]

// ==== УМЕНИЕ ====
/obj/effect/proc_holder/spell/self/learnmiracle
	name = "Miracles"
	desc = "Open miracle actions."
	overlay_state = "startmiracle"

/obj/effect/proc_holder/spell/self/learnmiracle/proc/do_learn_miracle(mob/user)
	if(!user || !user.mind) return
	var/mob/living/carbon/human/H = istype(user, /mob/living/carbon/human) ? user : null
	if(!H) return

	if(!HAS_TRAIT(user, TRAIT_CLERGY))
		to_chat(user, span_warning("Only clergy may contemplate new miracles."))
		return

	var/datum/devotion/D = H.devotion
	if(!D || !D.patron)
		to_chat(user, span_warning("Your faith has no patron."))
		return

	if(!miracle_caches_built) build_miracle_caches()

	var/tier = 0
	if(("clergy_learn_tier" in D.vars) && isnum(D.vars["clergy_learn_tier"]))
		tier = D.vars["clergy_learn_tier"]

	var/list/spell_types = list()
	if(length(D.patron.miracles))
		for(var/st in D.patron.miracles)
			spell_types[st] = TRUE
	if(tier >= 1)
		for(var/st in divine_miracles_cache)
			spell_types[st] = TRUE
	if(tier >= 2)
		for(var/st in inhumen_miracles_cache)
			spell_types[st] = TRUE

	var/list/choices = list()
	for(var/st in spell_types)
		var/already = FALSE
		for(var/obj/effect/proc_holder/spell/K in user.mind.spell_list)
			if(K.type == st) { already = TRUE; break }
		if(already) continue

		var/obj/effect/proc_holder/spell/S = new st

		var/own     = is_patron_spell(D, S)
		var/divine  = is_divine_spell(S)
		var/inhumen = is_inhumen_spell(S)

		var/allow = FALSE
		var/cost = 0

		switch(tier)
			if(0)
				if(own) { allow = TRUE; cost = CLERIC_PRICE_PATRON }
			if(1)
				if(own) { allow = TRUE; cost = CLERIC_PRICE_PATRON }
				else if(divine) { allow = TRUE; cost = CLERIC_PRICE_DIVINE }
			if(2)
				if(own) { allow = TRUE; cost = CLERIC_PRICE_PATRON }
				else if(divine) { allow = TRUE; cost = CLERIC_PRICE_DIVINE }
				else if(inhumen) { allow = TRUE; cost = CLERIC_PRICE_SHUNNED }

		if(!allow)
			qdel(S)
			continue

		choices["[S.name] ([cost])"] = list("type" = st, "cost" = cost, "desc" = S.desc, "name" = S.name)
		qdel(S)

	if(!choices.len)
		to_chat(user, span_warning("No miracles available to learn right now."))
		return

	var/left = max(0, H.miracle_points)
	var/pick = input(user, "Choose a miracle to learn. Miracle points left: [left]", "Learn a Miracle") as null|anything in choices
	if(!pick) return

	var/sel = choices[pick]
	var/typepath = sel["type"]
	var/calc_cost = sel["cost"]
	var/sname = sel["name"]
	var/sdesc = sel["desc"]

	if(calc_cost > H.miracle_points)
		to_chat(user, span_warning("Not enough miracle points."))
		return

	if(alert(user, "[sdesc]", "[sname]", "Learn", "Cancel") == "Cancel")
		return

	for(var/obj/effect/proc_holder/spell/K2 in user.mind.spell_list)
		if(K2.type == typepath)
			to_chat(user, span_warning("You already know this one!"))
			return

	H.miracle_points = max(0, H.miracle_points - calc_cost)
	var/obj/effect/proc_holder/spell/new_spell = new typepath
	user.mind.AddSpell(new_spell)
	to_chat(user, span_notice("You have learned [new_spell.name]."))
	return

/obj/effect/proc_holder/spell/self/learnmiracle/cast(list/targets, mob/user)
	if(!..()) return
	if(!user) return

	var/list/rad = list()
	rad["Learn"]    = icon(icon = MIRACLE_RADIAL_DMI, icon_state = "learnmiracle")
	rad["Upgrade"]  = icon(icon = MIRACLE_RADIAL_DMI, icon_state = "upgrademiracle")
	rad["Quests"]   = icon(icon = MIRACLE_RADIAL_DMI, icon_state = "questmiracle")
	rad["Research"] = icon(icon = MIRACLE_RADIAL_DMI, icon_state = "researchmiracle")

	var/choice = show_radial_menu(user, user, rad, require_near = FALSE)
	if(choice == "Learn")
		do_learn_miracle(user)
	return
