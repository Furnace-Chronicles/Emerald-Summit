// Magi 2 debug verbs — admin-only, for pilot smoke-testing the action-spell base.
// Hooked into GLOB.admin_verbs_debug_mapping at world init so they appear in the
// "Debug" tab after the admin clicks "Debug verbs - Enable".

GLOBAL_LIST_INIT(magi2_test_spell_paths, list(
	/datum/action/cooldown/spell/projectile/spitfire_magi2,
	/datum/action/cooldown/spell/projectile/fireball_magi2,
	/datum/action/cooldown/spell/fire_blast_magi2,
	/datum/action/cooldown/spell/fire_curtain_magi2,
))

/client/proc/cmd_give_magi2_test_spell()
	set name = "Give Magi 2 Test Spell (Pyromancy)"
	set category = "Debug"
	set desc = "Grants the caller mob the full Magi 2 Pyromancy spell set. Re-run to remove."

	if(!holder)
		to_chat(src, span_warning("Admin-only debug verb."))
		return
	if(!mob)
		return
	if(!mob.mind)
		to_chat(src, span_warning("Target mob has no mind."))
		return

	// If any are present, remove ALL of them (toggle behavior).
	var/removed_any = FALSE
	for(var/spell_path in GLOB.magi2_test_spell_paths)
		for(var/datum/action/cooldown/spell/existing in mob.mind.spell_list)
			if(existing.type == spell_path)
				mob.mind.spell_list -= existing
				qdel(existing)
				removed_any = TRUE
	if(removed_any)
		to_chat(src, span_notice("Removed Magi 2 Pyromancy spell set."))
		return

	// Otherwise grant them all.
	for(var/spell_path in GLOB.magi2_test_spell_paths)
		var/datum/action/cooldown/spell/S = new spell_path
		mob.mind.spell_list += S
		S.Grant(mob)
	to_chat(src, span_notice("Granted Magi 2 Pyromancy: Spitfire, Fireball, Fire Blast, Fire Curtain. Action buttons appear bottom-left."))
