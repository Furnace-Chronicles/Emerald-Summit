/datum/language/undersign
	name = "Undersign"
	desc = "A language native to the Underdark. Undersign conveys meaning through posture, hand-shapes, and controlled hand movements. Designed for communication in darkness where sound invites death, it is widely used by drow and other subterranean species."
	speech_verb = "gestures"
	ask_verb = "signals"
	exclaim_verb = "emphatically signs"
	key = "t"

	flags = LANGUAGE_HIDE_ICON_IF_UNDERSTOOD | LANGUAGE_HIDE_ICON_IF_NOT_UNDERSTOOD | TONGUELESS_SPEECH | SIGNLANG

	space_chance = 65
	default_priority = 92
	icon_state = "asse"
	spans = list(SPAN_ITALICS)

	//used instead of spoken dialogue
	signlang_verb = list(
		"lowers their posture",
		"draws a sharp sign in the air",
		"taps two fingers against their palm",
		"angles their head slightly",
		"narrows their eyes",
		"flares their fingers briefly",
		"rotates their wrist in a tight motion",
		"cuts a line downward with their hand",
		"pauses, then resumes motion",
		"touches two fingers to their throat",
		"points subtly and retracts their hand",
		"spreads their fingers wide, then closes them",
		"traces a slow arc",
		"snaps their fingers softly",
		"crosses their wrists briefly",
		"leans forward just enough to be noticed",
		"still their hands completely",
		"makes a short, deliberate motion",
		"flicks their fingers outward",
		"draws a tight circle, then stops")
