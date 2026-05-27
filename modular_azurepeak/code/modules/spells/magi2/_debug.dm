// Magi 2 debug verbs — admin-only, for pilot smoke-testing the action-spell base
// and the aspect system. Hooked into GLOB.admin_verbs_debug_mapping in mapping.dm.

/client/proc/cmd_give_magi2_test_spell()
	set name = "Bind Magi 2 Aspect (Pilot)"
	set category = "Debug"
	set desc = "Bind or unbind a Magi 2 magic aspect on the caller mob. Grants/revokes \
		the aspect's spell set via the magic_aspect machinery."

	if(!holder)
		to_chat(src, span_warning("Admin-only debug verb."))
		return
	if(!mob)
		return
	if(!mob.mind)
		to_chat(src, span_warning("Target mob has no mind."))
		return

	// Build the list of options: every aspect + an "Unbind All" choice.
	var/list/all_aspects = GLOB.magic_aspects_major + GLOB.magic_aspects_minor
	if(!length(all_aspects))
		to_chat(src, span_warning("No magic aspects registered."))
		return

	var/list/choices = list()
	for(var/aspect_path in all_aspects)
		var/datum/magic_aspect/A = aspect_path
		var/marker = _magi2_aspect_is_bound(mob.mind, aspect_path) ? " (bound)" : ""
		choices["[initial(A.name)] ([initial(A.aspect_type) == ASPECT_MAJOR ? "Major" : "Minor"])[marker]"] = aspect_path
	choices["-- Unbind All Magi 2 Aspects --"] = "unbind_all"

	var/picked = input(src, "Pick an aspect to toggle on [mob]:", "Magi 2 Aspect Pilot") as null|anything in choices
	if(!picked)
		return
	var/payload = choices[picked]

	if(payload == "unbind_all")
		_magi2_unbind_all(mob.mind)
		to_chat(src, span_notice("Unbound all Magi 2 aspects from [mob]."))
		return

	if(_magi2_aspect_is_bound(mob.mind, payload))
		_magi2_unbind_aspect(mob.mind, payload)
		to_chat(src, span_notice("Unbound [initial(payload:name)] from [mob]."))
		return

	_magi2_bind_aspect(mob.mind, payload)
	to_chat(src, span_notice("Bound [initial(payload:name)] to [mob]. Spells should appear in the action bar."))

// ---- Aspect bind/unbind helpers (file-private; underscore prefix) ----
// These wrap the /datum/magic_aspect API so the debug verb keeps the picking logic
// at the client layer and the per-aspect spell grant/revoke stays in the aspect datum.

/proc/_magi2_aspect_is_bound(datum/mind/target, aspect_path)
	if(!istype(target) || !aspect_path)
		return FALSE
	var/datum/magic_aspect/A = aspect_path
	// An aspect is "bound" if any of its fixed_spells is already in the spell list.
	// (Choice/pointbuy spells are not in scope for the pilot.)
	for(var/spell_path in initial(A.fixed_spells))
		for(var/datum/action/cooldown/spell/S in target.spell_list)
			if(S.type == spell_path)
				return TRUE
	return FALSE

/proc/_magi2_bind_aspect(datum/mind/target, aspect_path)
	if(!istype(target) || !aspect_path)
		return
	var/datum/magic_aspect/A = new aspect_path
	A.grant_spells(target)

/proc/_magi2_unbind_aspect(datum/mind/target, aspect_path)
	if(!istype(target) || !aspect_path)
		return
	var/datum/magic_aspect/A = new aspect_path
	A.revoke_spells(target)

/proc/_magi2_unbind_all(datum/mind/target)
	if(!istype(target))
		return
	for(var/aspect_path in GLOB.magic_aspects_major + GLOB.magic_aspects_minor)
		_magi2_unbind_aspect(target, aspect_path)
