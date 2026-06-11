// Displacement — minor aspect, port of Azure-Peak's `/datum/magic_aspect/displacement`.
// Single spell: Blink (short-range line-of-sight teleport).

/datum/magic_aspect/displacement
	name = "Displacement"
	latin_name = "Minor Aspectus Translationis"
	desc = "The art of stepping between the spaces between the realms. Displacement mages cannot \
		match the raw reach of a true teleporter — they only blink five paces at a time — but a \
		well-timed blink can save a life or close a duel."
	aspect_type = ASPECT_MINOR
	school_color = GLOW_COLOR_DISPLACEMENT
	binding_chants = list(
		"Let me step between the spaces between the realms.",
		"Translatio, mihi adesse!",
	)
	unbinding_chants = list(
		"I close the paths I have opened. I walk the realms no longer.",
		"Translatio, me relinquere!",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/blink_magi2,
	)
