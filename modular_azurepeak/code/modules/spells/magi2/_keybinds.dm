// Magi 2 keybinds — port of Azure-Peak's toggle_arc_mode keybind (code/datums/keybinding/carbon.dm).
// Adapter notes:
//  - Azure-Peak splits this into toggle_arc_mode (projectiles) + toggle_alt_mode (generic). Emerald
//    Summit's projectile base routes everything through toggle_alt_mode(), so a single dispatch off
//    click_intercept covers Fireball/Greater Fireball arc mode AND Battle Ward's mode cycling.
//  - Magi2 spells set owner.click_intercept = src while active (spell_cooldown.dm), so the active
//    spell is whatever the player currently has armed.

/datum/keybinding/carbon/toggle_alt_mode
	hotkey_keys = list("CtrlG")
	classic_keys = list("CtrlG")
	name = "toggle_alt_mode"
	full_name = "Toggle Spell Alt Mode"
	description = "Toggle alt mode on the currently active spell — arc mode for projectiles, ward type cycling, etc."
	category = CATEGORY_CARBON

/datum/keybinding/carbon/toggle_alt_mode/down(client/user)
	if(!ishuman(user.mob))
		return FALSE
	var/mob/living/carbon/human/H = user.mob
	var/datum/action/cooldown/spell/active = H.click_intercept
	if(!istype(active))
		to_chat(H, span_warning("No active spell with an alt mode."))
		return TRUE
	// The spell's own toggle_alt_mode() handles all user feedback (arc toggle, ward
	// cycling, or a "cannot be arced" warning), so don't double up with a fallback here.
	active.toggle_alt_mode(H)
	return TRUE
