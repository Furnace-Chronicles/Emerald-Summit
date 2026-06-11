// Autowardry minor aspect — unlocks the upgraded Arcyne Ward variants.
//
// Pilot deviation from upstream: upstream uses `choice_spells = list(dragonhide, crystalhide)`
// so the player picks ONE at binding time. Our Grimoire doesn't have choice-spell UI yet, so
// we grant both as fixed_spells; the existing arcyne_armor_tier check prevents downgrading
// from one upgrade to the other, and the base ward is replaced when either is cast.

/datum/magic_aspect/autowardry
	name = "Autowardry"
	latin_name = "Minor Aspectus Autotutelae"
	desc = "Augment your existing arcyne ward with additional properties. Grants two upgraded ward \
		variants: dragonhide for fire resistance and constitution, or crystalhide for brigandine-tier \
		protection and intellect. Cast one to replace your base ward; cast it again to dismiss."
	aspect_type = ASPECT_MINOR
	school_color = GLOW_COLOR_METAL
	binding_chants = list(
		"Let me clad myself in an armor of arcyne.",
		"Autotutela, mihi adesse!",
	)
	unbinding_chants = list(
		"I bare myself and shed the arcyne mantle.",
		"Autotutela, me relinquere!",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/conjure_arcyne_ward_magi2/dragonhide,
		/datum/action/cooldown/spell/conjure_arcyne_ward_magi2/crystalhide,
	)
