// Aegiscraft — minor aspect, port of Azure-Peak's `/datum/magic_aspect/aegiscraft`.
// Pilot deviation from upstream: upstream uses `choice_spells = list(conjure_aegis)`
// but since there's currently only one option, we grant it as fixed_spells. When more
// aegis variants exist + the Grimoire gets a choice-pick UI, switch back to choice_spells.

/datum/magic_aspect/aegiscraft
	name = "Aegiscraft"
	latin_name = "Minor Aspectus Aegidis"
	desc = "The shield-conjurer's school. A bound Aegiscrafter can summon a wide, slow arcyne aegis \
		into their off-hand — superb against arrows and bolts, awkward against a deliberate sword. \
		Channeling the shield leaves the mage unable to parry or dodge."
	aspect_type = ASPECT_MINOR
	school_color = GLOW_COLOR_ARCANE
	binding_chants = list(
		"Let me the shield that will protect me.",
		"Aegis, mihi adesse!",
	)
	unbinding_chants = list(
		"I set aside the shield, peace be with me.",
		"Aegis, me relinquere!",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/conjure_aegis_magi2,
	)
