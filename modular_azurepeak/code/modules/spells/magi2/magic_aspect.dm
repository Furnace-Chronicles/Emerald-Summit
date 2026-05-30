// Magi 2 magic aspects — port of Azure-Peak code/modules/spells/spell_types/wizard/magic_aspect.dm
// Adapter notes:
//  - Existing /datum/mind.AddSpell/RemoveSpell/has_spell are typed for /obj/effect/proc_holder/spell.
//    Magi 2 spells are /datum/action/cooldown/spell which the legacy helpers reject. To avoid
//    touching mind.dm globally we inline the list management here.
//  - When existing proc_holder spells need to coexist (e.g. divine spells on the same mind),
//    the proc_holder spell_list and the Magi 2 spells share the same list — both type families
//    live in mind.spell_list. Removal helpers filter by exact path.

/datum/magic_aspect
	var/name = "Aspect"
	var/latin_name = ""
	var/desc = "An arcyne discipline."
	var/aspect_type = ASPECT_MAJOR
	/// Appended to implements when attuned: "Fire" -> "Staff of Fire"
	var/attuned_name = ""
	/// Always granted spells
	var/list/fixed_spells = list()
	/// Choice spells — pick exactly one. Granted FIRST so they appear first on the action bar.
	var/list/choice_spells = list()
	/// Pointbuy optionals (used by future utility-aspect picker)
	var/list/pointbuy_spells = list()
	var/pointbuy_budget = 0
	/// Named variant spell swaps: list("mastery" = list(base_path = upgrade_path, ...))
	/// "mastery" is automatically applied for T4 casters.
	var/list/variants = list()
	var/school_color
	/// Major: Latin, English, Latin. Minor: Latin, English.
	var/list/binding_chants = list()
	var/list/unbinding_chants = list()
	/// The choice spell that was actually picked during attunement.
	var/chosen_spell

/datum/magic_aspect/proc/get_implement_name(base_name)
	if(!attuned_name)
		return base_name
	return "[base_name] of [attuned_name]"

/// Grant a single choice spell. Called before grant_spells() so it appears first on the action bar.
/datum/magic_aspect/proc/grant_choice_spell(datum/mind/target, spell_path)
	if(!spell_path || !(spell_path in choice_spells))
		return
	chosen_spell = spell_path
	if(_mind_has_magi2_spell(target, spell_path))
		return
	_mind_grant_magi2_spell(target, spell_path)

/datum/magic_aspect/proc/grant_spells(datum/mind/target)
	var/list/granted = list()
	for(var/spell_path in fixed_spells)
		if(_mind_has_magi2_spell(target, spell_path))
			continue
		var/datum/added = _mind_grant_magi2_spell(target, spell_path)
		if(added)
			granted += added
	return granted

/// Apply a named variant's spell swaps. T4 casters automatically get "mastery".
/datum/magic_aspect/proc/apply_variant(datum/mind/target, variant_name)
	if(!variant_name || !length(variants) || !(variant_name in variants))
		return
	var/list/swaps = variants[variant_name]
	if(!length(swaps))
		return
	for(var/base_path in swaps)
		var/upgrade_path = swaps[base_path]
		if(base_path == VARIANT_ADDITIVE)
			_mind_grant_magi2_spell(target, upgrade_path, variant_name)
			continue
		var/datum/existing = _mind_get_magi2_spell(target, base_path)
		if(existing)
			var/spell_index = target.spell_list.Find(existing)
			_mind_revoke_magi2_spell(target, base_path)
			if(spell_index && spell_index <= length(target.spell_list) + 1)
				var/datum/upgraded = _mind_make_magi2_spell(upgrade_path, src, variant_name)
				target.spell_list.Insert(spell_index, upgraded)
				_grant_to_owner(upgraded, target.current)
			else
				_mind_grant_magi2_spell(target, upgrade_path, variant_name)

/// Revoke all spells granted by this aspect.
/// skip_spells: flat list of spell paths that should NOT be removed.
/datum/magic_aspect/proc/revoke_spells(datum/mind/target, list/skip_spells)
	for(var/spell_path in choice_spells)
		if(LAZYLEN(skip_spells) && (spell_path in skip_spells))
			continue
		_mind_revoke_magi2_spell(target, spell_path)
	for(var/spell_path in fixed_spells)
		if(LAZYLEN(skip_spells) && (spell_path in skip_spells))
			continue
		_mind_revoke_magi2_spell(target, spell_path)
	for(var/variant_name in variants)
		var/list/swaps = variants[variant_name]
		for(var/base_path in swaps)
			var/upgrade_path = swaps[base_path]
			if(LAZYLEN(skip_spells) && (upgrade_path in skip_spells))
				continue
			_mind_revoke_magi2_spell(target, upgrade_path)
	for(var/spell_path in pointbuy_spells)
		if(LAZYLEN(skip_spells) && (spell_path in skip_spells))
			continue
		_mind_revoke_magi2_spell(target, spell_path)

/datum/magic_aspect/proc/mark_aspect_spell(datum/spell_instance)
	if(istype(spell_instance, /datum/action/cooldown/spell))
		var/datum/action/cooldown/spell/S = spell_instance
		S.refundable = FALSE
		S.source_aspect = type

/// Perform the binding or unbinding chant. Returns TRUE if completed, FALSE if interrupted.
/datum/magic_aspect/proc/perform_chant(mob/living/chanter, binding = TRUE)
	var/list/chant_lines = binding ? binding_chants : unbinding_chants
	if(!length(chant_lines) || chant_lines[1] == "TODO")
		return TRUE
	for(var/line in chant_lines)
		chanter.say(line, forced = "spell", language = /datum/language/common)
		if(!do_after(chanter, 2 SECONDS, target = chanter))
			return FALSE
	return TRUE

GLOBAL_LIST_INIT(magic_aspects_major, init_magic_aspects(ASPECT_MAJOR))
GLOBAL_LIST_INIT(magic_aspects_minor, init_magic_aspects(ASPECT_MINOR))

/proc/init_magic_aspects(filter_type)
	var/list/result = list()
	for(var/path in subtypesof(/datum/magic_aspect))
		var/datum/magic_aspect/A = path
		if(initial(A.aspect_type) == filter_type)
			result += path
	return result

// ---- Inlined Magi 2 spell-list helpers (file-private; underscore prefix) ----
// Magi 2 spells are /datum/action/cooldown/spell. The existing mind.AddSpell is typed
// for /obj/effect/proc_holder/spell so it can't accept them — we manage the list directly.
//
// Type dispatch: aspects also accept legacy /obj/effect/proc_holder/spell paths in
// their fixed/choice spell lists (e.g. Illusion grants the existing ES invisibility
// spell, Lesser Augmentation reuses the noc-bundle utility spells). For those, we
// route through mind.AddSpell / has_spell / RemoveSpell instead of touching spell_list
// directly. Variant rewriting and aspect-marking only apply to the Magi 2 family.

/datum/magic_aspect/proc/_mind_has_magi2_spell(datum/mind/target, spell_path)
	if(!istype(target) || !spell_path)
		return FALSE
	if(ispath(spell_path, /obj/effect/proc_holder/spell))
		return target.has_spell(spell_path, specific = TRUE)
	for(var/datum/action/cooldown/spell/S in target.spell_list)
		if(S.type == spell_path)
			return TRUE
	return FALSE

/datum/magic_aspect/proc/_mind_get_magi2_spell(datum/mind/target, spell_path)
	if(!istype(target) || !spell_path)
		return null
	if(ispath(spell_path, /obj/effect/proc_holder/spell))
		for(var/obj/effect/proc_holder/spell/S in target.spell_list)
			if(S.type == spell_path)
				return S
		return null
	for(var/datum/action/cooldown/spell/S in target.spell_list)
		if(S.type == spell_path)
			return S
	return null

/datum/magic_aspect/proc/_mind_make_magi2_spell(spell_path, datum/magic_aspect/source, variant_name)
	var/datum/action/cooldown/spell/S = new spell_path
	mark_aspect_spell(S)
	if(variant_name && istype(S))
		S.desc = "[S.desc]\n<b>Variant:</b> [capitalize(variant_name)]"
	return S

/datum/magic_aspect/proc/_mind_grant_magi2_spell(datum/mind/target, spell_path, variant_name)
	if(!istype(target) || !spell_path)
		return null
	if(ispath(spell_path, /obj/effect/proc_holder/spell))
		if(_mind_has_magi2_spell(target, spell_path))
			return null
		var/obj/effect/proc_holder/spell/legacy = new spell_path(null)
		target.AddSpell(legacy)
		return legacy
	var/datum/action/cooldown/spell/S = _mind_make_magi2_spell(spell_path, src, variant_name)
	target.spell_list += S
	_grant_to_owner(S, target.current)
	return S

/datum/magic_aspect/proc/_mind_revoke_magi2_spell(datum/mind/target, spell_path)
	if(!istype(target) || !spell_path)
		return
	if(ispath(spell_path, /obj/effect/proc_holder/spell))
		target.RemoveSpell(spell_path)
		return
	for(var/datum/action/cooldown/spell/S in target.spell_list)
		if(S.type == spell_path)
			target.spell_list -= S
			qdel(S)

/datum/magic_aspect/proc/_grant_to_owner(datum/action/cooldown/spell/S, mob/living/owner)
	if(!owner || !S)
		return
	S.Grant(owner)

// ---- Global bind/unbind helpers ----
// Used by the debug verb and the Grimoire TGUI to bind/unbind aspects on a mind
// through the standard /datum/magic_aspect API. Kept here (not in _debug.dm) so
// non-debug callers can rely on them.
//
// Bindings are tracked on mind.magi2_bound_aspects (added below). Inferring "bound"
// from spell presence breaks once aspects share spells — e.g. Augmentation, Telomancy
// and Battlewardry all carry soulshot + greater_arcyne_bolt as choice spells, so any
// one bound aspect would look like all three were bound.

/datum/mind
	var/list/magi2_bound_aspects

/proc/_magi2_aspect_is_bound(datum/mind/target, aspect_path)
	if(!istype(target) || !aspect_path)
		return FALSE
	return LAZYACCESS(target.magi2_bound_aspects, "[aspect_path]") ? TRUE : FALSE

/proc/_magi2_bind_aspect(datum/mind/target, aspect_path)
	if(!istype(target) || !aspect_path)
		return
	if(_magi2_aspect_is_bound(target, aspect_path))
		return
	var/datum/magic_aspect/A = new aspect_path
	A.grant_spells(target)
	// T4 casters (Lich, Court Magician) automatically gain this aspect's Mastery spell.
	// apply_variant("mastery") is a no-op for aspects with no mastery variant defined.
	if(target.current && HAS_TRAIT(target.current, TRAIT_ARCYNE_T4))
		A.apply_variant(target, "mastery")
	LAZYSET(target.magi2_bound_aspects, "[aspect_path]", TRUE)
	qdel(A)

/proc/_magi2_unbind_aspect(datum/mind/target, aspect_path)
	if(!istype(target) || !aspect_path)
		return
	if(!_magi2_aspect_is_bound(target, aspect_path))
		return
	LAZYREMOVE(target.magi2_bound_aspects, "[aspect_path]")
	// Build a skip-list of spells still wanted by other bound aspects so we don't
	// yank a shared spell (e.g. unbinding Telomancy must not take soulshot away if
	// Augmentation is also still bound).
	var/list/still_wanted = list()
	for(var/other_key in target.magi2_bound_aspects)
		var/other_path = text2path(other_key)
		if(!other_path)
			continue
		var/datum/magic_aspect/other = new other_path
		still_wanted |= other.fixed_spells
		still_wanted |= other.choice_spells
		qdel(other)
	var/datum/magic_aspect/A = new aspect_path
	A.revoke_spells(target, still_wanted)
	qdel(A)

/proc/_magi2_unbind_all(datum/mind/target)
	if(!istype(target))
		return
	// Snapshot the list — unbind mutates it.
	var/list/bound = target.magi2_bound_aspects?.Copy()
	for(var/aspect_key in bound)
		var/aspect_path = text2path(aspect_key)
		if(aspect_path)
			_magi2_unbind_aspect(target, aspect_path)
