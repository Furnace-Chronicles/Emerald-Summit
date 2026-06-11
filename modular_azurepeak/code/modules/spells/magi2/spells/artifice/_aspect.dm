// Artifice — minor aspect, port of Azure-Peak's `/datum/magic_aspect/artifice`.
// Single spell: Arcyne Forge (already ported in ferramancy/arcyne_forge.dm).
// This aspect just registers the datum so the Grimoire lists it and binding
// grants the spell.

/datum/magic_aspect/artifice
	name = "Artifice"
	latin_name = "Minor Aspectus Artificii"
	desc = "The craftsman's school. The Magi who binds Artifice may conjure a working forge from \
		nowhere — turning raw stone and iron into worked goods on the field, far from any smithy."
	aspect_type = ASPECT_MINOR
	school_color = GLOW_COLOR_METAL
	binding_chants = list(
		"Grant me the craftsman's eye.",
		"Artificium, mihi adesse!",
	)
	unbinding_chants = list(
		"I set down the craftsman's tools.",
		"Artificium, me relinquere!",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/arcyne_forge_magi2,
	)
