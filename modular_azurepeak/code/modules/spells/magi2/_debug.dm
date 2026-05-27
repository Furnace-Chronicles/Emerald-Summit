// Magi 2 debug verbs — admin-only, for pilot smoke-testing the action-spell base.
// Hooked into GLOB.admin_verbs_debug_mapping at world init so it appears in the
// "Debug" tab after the admin clicks "Debug verbs - Enable".

/client/proc/cmd_give_magi2_test_spell()
	set name = "Give Magi 2 Test Spell (Spitfire)"
	set category = "Debug"
	set desc = "Grants the caller mob a Magi 2 Spitfire action."

	if(!holder)
		to_chat(src, span_warning("Admin-only debug verb."))
		return
	if(!mob)
		return
	if(!mob.mind)
		to_chat(src, span_warning("Target mob has no mind."))
		return
	for(var/datum/action/cooldown/spell/projectile/spitfire_magi2/existing in mob.mind.spell_list)
		to_chat(src, span_notice("Already have Spitfire — removing."))
		mob.mind.spell_list -= existing
		qdel(existing)
		return
	var/datum/action/cooldown/spell/projectile/spitfire_magi2/S = new
	mob.mind.spell_list += S
	S.Grant(mob)
	// Diagnostic: report what the HUD ended up with.
	var/in_actions = (S in mob.actions)
	var/atom/movable/screen/movable/action_button/btn = S.button
	var/in_screen = (btn && mob.client && (btn in mob.client.screen))
	var/btn_loc = btn ? "[btn.screen_loc]" : "no button"
	var/btn_icon = btn ? "[btn.icon][btn.icon ? "/[btn.icon_state]" : ""]" : "n/a"
	var/btn_overlays_count = btn ? length(btn.overlays) : 0
	to_chat(src, span_notice("Granted Magi 2 Spitfire."))
	to_chat(src, span_notice("  in actions=[in_actions] | in screen=[in_screen] | screen_loc=[btn_loc]"))
	to_chat(src, span_notice("  button icon=[btn_icon] | overlays=[btn_overlays_count] | hud_used=[mob.hud_used ? "yes" : "NO"]"))
	if(mob.hud_used)
		to_chat(src, span_notice("  hud_shown=[mob.hud_used.hud_shown] | action_buttons_hidden=[mob.hud_used.action_buttons_hidden]"))
