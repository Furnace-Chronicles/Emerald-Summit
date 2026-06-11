// Exowardry — minor aspect, port of Azure-Peak's `/datum/magic_aspect/exowardry`.
// Single spell: Forcewall (already ported in augmentation/forcewall.dm and shared
// with Battlewardry). Exowardry grants only Forcewall — a defensive utility option
// for non-Battlewardens who still want a wall.

/datum/magic_aspect/exowardry
	name = "Exowardry"
	latin_name = "Minor Aspectus Exotutelae"
	desc = "The art of raising walls. Where the Battle-warden weaves runes and personal wards, the \
		Exowarden simply throws up an arcyne barricade — a single, swift conjuration when cover \
		is needed and no honest stone is at hand."
	aspect_type = ASPECT_MINOR
	school_color = GLOW_COLOR_ARCANE
	binding_chants = list(
		"Let me raise walls against my foes.",
		"Exotutela, mihi adesse!",
	)
	unbinding_chants = list(
		"I lower the walls I have raised.",
		"Exotutela, me relinquere!",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/forcewall_magi2,
	)
