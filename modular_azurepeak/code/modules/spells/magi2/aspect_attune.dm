// Magi 2 staged-attune backend — port of Azure-Peak's /datum/mind aspect system.
//
// This is the model the upstream GrimoireAspectPicker is built on: the mind tracks
// live aspect DATUM INSTANCES in major_aspects/minor_aspects (not path strings), and
// attune_aspect()/remove_aspect() are the canonical grant/revoke entry points.
//
// PHASE A: this file is additive and DORMANT — nothing calls attune_aspect() yet. The
// existing magi2_bound_aspects path (magic_aspect.dm) + Magi2Grimoire still drive binding.
// Phase D switches the spellbook + spawn over to this model and retires the old path.
//
// Adapter notes:
//  - attune_aspect() calls aspect.grant_choice_spell/grant_spells/apply_variant, which in
//    our fork already dispatch /datum/action/cooldown/spell vs /obj/effect/proc_holder/spell
//    through the inlined helpers in magic_aspect.dm. So no spell-list widening needed here.
//  - ensure_mage_basics() is trimmed vs upstream: gated on mage_aspect_config (we have no
//    standalone TRAIT_ARCYNE), ward-only (no datum prestidigitation in ES), and drops the
//    regen_action button refresh (our ward spell has no regen_action var).

/datum/mind
	/// Live attuned aspect datum instances (not paths).
	var/list/major_aspects
	var/list/minor_aspects
	/// Per-class config. Keys: "major", "minor", "utilities", "mastery", "ward".
	/// Optional: "variants" (assoc aspect_path = variant_name), "locked_aspects", "post_aspect_spells".
	var/list/mage_aspect_config

// The aspect picker reads source_aspect / utility_learned on BOTH spell families to track
// pointbuy ownership and player-learned utilities. Our /datum/action/cooldown/spell base
// already has them; mirror them onto the proc_holder base so the picker compiles and can
// account for proc_holder utility spells (message, darkvision, fetch, ...).
/obj/effect/proc_holder/spell
	var/source_aspect
	var/utility_learned = FALSE

/// Find a live spell instance by type (handles both spell families). FALSE if absent.
/datum/mind/proc/get_spell(spell_type, specific = FALSE)
	var/spell_path = spell_type
	if(istype(spell_type, /obj/effect/proc_holder))
		var/obj/effect/proc_holder/instanced_spell = spell_type
		spell_path = instanced_spell.type
	else if(istype(spell_type, /datum/action/cooldown/spell))
		var/datum/action/cooldown/spell/instanced_spell = spell_type
		spell_path = instanced_spell.type
	for(var/datum/spell as anything in spell_list)
		if(specific && spell.type == spell_path)
			return spell
		else if(!specific && istype(spell, spell_path))
			return spell
	return FALSE

/datum/mind/proc/attune_aspect(datum/magic_aspect/aspect, variant, choice_spell)
	if(!aspect)
		return FALSE
	var/max_majors = LAZYLEN(mage_aspect_config) ? mage_aspect_config["major"] : MAX_MAJOR_ASPECTS
	var/max_minors = LAZYLEN(mage_aspect_config) ? mage_aspect_config["minor"] : MAX_MINOR_ASPECTS
	var/has_mastery = LAZYLEN(mage_aspect_config) ? mage_aspect_config["mastery"] : FALSE
	switch(aspect.aspect_type)
		if(ASPECT_MAJOR)
			if(LAZYLEN(major_aspects) >= max_majors)
				if(current)
					to_chat(current, span_warning("I cannot attune to another major aspect."))
				return FALSE
			LAZYADD(major_aspects, aspect)
		if(ASPECT_MINOR)
			if(LAZYLEN(minor_aspects) >= max_minors)
				if(current)
					to_chat(current, span_warning("I cannot attune to another minor aspect."))
				return FALSE
			LAZYADD(minor_aspects, aspect)
	// Grant choice spell first so it appears first on the action bar. If no explicit choice,
	// auto-resolve: prefer one the player already has, else first in list.
	if(!choice_spell && length(aspect.choice_spells))
		for(var/candidate in aspect.choice_spells)
			if(has_spell(candidate))
				choice_spell = candidate
				break
		if(!choice_spell)
			choice_spell = aspect.choice_spells[1]
	if(choice_spell)
		aspect.grant_choice_spell(src, choice_spell)
	aspect.grant_spells(src)
	// Variant swaps — explicit variant wins, else mastery config grants "mastery".
	if(variant)
		aspect.apply_variant(src, variant)
	else if(has_mastery)
		aspect.apply_variant(src, "mastery")
	ensure_mage_basics()
	return TRUE

/datum/mind/proc/remove_aspect(datum/magic_aspect/aspect, list/skip_spells)
	if(!aspect)
		return FALSE
	aspect.revoke_spells(src, skip_spells)
	switch(aspect.aspect_type)
		if(ASPECT_MAJOR)
			LAZYREMOVE(major_aspects, aspect)
		if(ASPECT_MINOR)
			LAZYREMOVE(minor_aspects, aspect)
	return TRUE

/datum/mind/proc/remove_all_aspects()
	for(var/datum/magic_aspect/aspect in major_aspects)
		remove_aspect(aspect)
	for(var/datum/magic_aspect/aspect in minor_aspects)
		remove_aspect(aspect)

/datum/mind/proc/has_aspect(aspect_type_path)
	for(var/datum/magic_aspect/aspect in major_aspects)
		if(aspect.type == aspect_type_path)
			return TRUE
	for(var/datum/magic_aspect/aspect in minor_aspects)
		if(aspect.type == aspect_type_path)
			return TRUE
	return FALSE

/datum/mind/proc/get_aspect_color()
	if(LAZYLEN(major_aspects))
		var/datum/magic_aspect/first = major_aspects[1]
		return first.school_color
	return GLOW_COLOR_ARCANE

/// Ensure the universal arcyne ward is present (or stripped) per class config.
/// Trimmed from upstream: ward-only, gated on mage_aspect_config, no prestidigitation.
/datum/mind/proc/ensure_mage_basics()
	if(!current)
		return
	var/allow_ward = mage_aspect_config && mage_aspect_config["ward"]
	if(allow_ward)
		var/datum/action/cooldown/spell/conjure_arcyne_ward_magi2/base_ward
		var/has_variant = FALSE
		for(var/datum/action/cooldown/spell/conjure_arcyne_ward_magi2/ward in spell_list)
			if(ward.type == /datum/action/cooldown/spell/conjure_arcyne_ward_magi2)
				base_ward = ward
			else
				has_variant = TRUE // dragonhide/crystalhide upgrade replaces the base ward
		if(has_variant)
			if(base_ward)
				RemoveSpell(base_ward)
		else if(!base_ward)
			AddSpell(new /datum/action/cooldown/spell/conjure_arcyne_ward_magi2)
	else
		// Class doesn't qualify for a ward — strip any base ward present.
		for(var/datum/action/cooldown/spell/conjure_arcyne_ward_magi2/ward in spell_list)
			if(ward.type != /datum/action/cooldown/spell/conjure_arcyne_ward_magi2)
				continue
			if(ward.conjured_ward && !QDELETED(ward.conjured_ward))
				qdel(ward.conjured_ward)
			RemoveSpell(ward)

/datum/mind/proc/setup_mage_aspects(list/config)
	mage_aspect_config = config
	ensure_mage_basics()

// ---- Utility-spell registry ----
// Paths offered in the picker's Utilities tab. Starter set of confirmed-present spells
// (mix of Magi 2 datum spells + existing ES proc_holders). Expand as more utility spells
// are ported/confirmed. Spells read their budget cost from point_cost (datum) / cost (proc_holder).
GLOBAL_LIST_INIT(utility_spells, list(
	/datum/action/cooldown/spell/light_magi2,
	/datum/action/cooldown/spell/mending_magi2,
	/datum/action/cooldown/spell/create_campfire_magi2,
	/obj/effect/proc_holder/spell/self/message,
	/obj/effect/proc_holder/spell/targeted/touch/darkvision,
	/obj/effect/proc_holder/spell/targeted/touch/nondetection,
	/obj/effect/proc_holder/spell/invoked/projectile/fetch,
	/obj/effect/proc_holder/spell/invoked/projectile/repel,
))
