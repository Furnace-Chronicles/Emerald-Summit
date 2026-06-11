// Hand-style intents for Magi 2 touch spells. Rune Ward dispatches on caster.used_intent.type
// in cast_on_hand_hit to decide whether the click draws a rune, scrubs a rune, or opens the
// memorize-allies dialog.
//
// All three borrow the icon_state "inuse" from /datum/intent/use — the codebase doesn't have
// distinct draw/clean icons yet. They differ only in type for dispatch and balloon text.

/datum/intent/hand
	name = "hand"
	icon_state = "inuse"
	chargetime = 0
	noaa = TRUE
	candodge = FALSE
	canparry = FALSE
	misscost = 0
	no_attack = TRUE
	releasedrain = 0
	blade_class = BCLASS_PUNCH

/datum/intent/hand/draw
	name = "draw"
	icon_state = "inuse"

/datum/intent/hand/clean
	name = "clean"
	icon_state = "inuse"
