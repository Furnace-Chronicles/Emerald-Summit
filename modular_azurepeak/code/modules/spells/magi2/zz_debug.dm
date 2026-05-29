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

// Bind/unbind helpers (_magi2_aspect_is_bound / _magi2_bind_aspect /
// _magi2_unbind_aspect / _magi2_unbind_all) now live in magic_aspect.dm so the
// Grimoire item can share them.
