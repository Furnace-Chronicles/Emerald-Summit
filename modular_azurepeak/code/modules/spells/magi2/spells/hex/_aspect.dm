// Hex minor aspect — port of Azure-Peak's `/datum/magic_aspect/hex`.
// Single-spell aspect (Wither) used to validate that aspect choice gates which
// spells the player gets — Pyromancers and Hexers see different action buttons.

/datum/magic_aspect/hex
	name = "Hex"
	latin_name = "Minor Aspectus Maleficii"
	desc = "Crooked words and lingering ill-will woven into magick. Hexers do not match the raw destruction \
		of a Pyromancer, but their curses sap the strength of any who stand before them."
	aspect_type = ASPECT_MINOR
	school_color = GLOW_COLOR_HEX
	binding_chants = list(
		"Let me speak the crooked word.",
		"Maleficium, mihi adesse!",
	)
	unbinding_chants = list(
		"I unsay the crooked word.",
		"Maleficium, me relinquere!",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/wither_magi2,
	)
