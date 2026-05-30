// Azure-Peak-style scroll backplate for legacy proc_holder spells.
//
// Every /obj/effect/proc_holder/spell now renders with the "spell" scroll state
// from roguespells.dmi as its action-button background. When the spell becomes
// the active click intercept (ranged_ability), the scroll swaps to "spell1"
// (the glowing variant) so the player can see at a glance which spell is about
// to fire on next click. The touch-spell branch (Darkvision, Nondetection, etc.)
// uses the in-hand focus as its "selected" indicator instead of ranged_ability;
// the matching swap for that path lives in core touch_attacks.dm's ChargeHand
// and on_hand_destroy (the procs already exist in core and can't be safely
// modular-overridden because of proc-collision rules).
//
// Foreground icons set elsewhere — utility_buff_icons.dm for Augmentation buffs,
// the individual spell files for everything else — sit on top of this backplate.

/obj/effect/proc_holder/spell
	action_background_icon_state = "spell"

// Prestidigitation and Orison have action icons that are already scroll-shaped sprites, so the
// "spell"/"spell1" scroll backplate would sit under them as a second scroll. Give them the neutral
// "bg_spell" frame (ES's pre-backplate spell background) in both idle and selected states. Core
// spells stay untouched.
/obj/effect/proc_holder/spell/targeted/touch/prestidigitation
	action_background_icon_state = "bg_spell"
	active_background_icon_state = "bg_spell" // keep the neutral frame when selected too (no scroll)

/obj/effect/proc_holder/spell/targeted/touch/orison
	action_background_icon_state = "bg_spell"
	active_background_icon_state = "bg_spell"

/obj/effect/proc_holder/spell/add_ranged_ability(mob/living/user, msg, forced)
	. = ..()
	if(action)
		action.background_icon_state = "spell1"
		action.UpdateButtonIcon()

/obj/effect/proc_holder/spell/remove_ranged_ability(msg)
	. = ..()
	if(action)
		action.background_icon_state = action_background_icon_state
		action.UpdateButtonIcon()
