// Kinesis major aspect — pure force / gravitational control. Distinct from Geomancy's earth
// theme: piercing beams and gravitational crushes that gate CC behind an adaptation timer.

/datum/magic_aspect/kinesis
	name = "Kinesis"
	latin_name = "Maior Aspectus Vis"
	desc = "Pure motional force, unaligned with any element. Kinesis is the magick of soul-purified \
		expression — a piercing soulshot, a crushing weight of gravity. Where other schools rely on \
		fire or ice, the kinesist needs nothing but the will to move space itself."
	aspect_type = ASPECT_MAJOR
	attuned_name = ASPECT_NAME_KINESIS
	school_color = GLOW_COLOR_KINESIS
	binding_chants = list(
		"Invoco vim absolutam!",
		"I call upon the force that binds all things, answer my will.",
		"Vis, in me ligare!",
	)
	unbinding_chants = list(
		"Solvo vim vinctam!",
		"I release the force I have grasped, scatter.",
		"Vis, a me discedere!",
	)
	// Upstream Magi 2 splits these across fixed_spells (crush/gravity/gravity_anchor/
	// greater_cleaning) + choice_spells (soulshot/greater_arcyne_bolt). Grimoire MVP has
	// no choice picker yet, so they all live in fixed_spells for the pilot. mass_gravity
	// is upstream-orphaned (file exists but isn't referenced by any aspect) — keep file
	// in repo but unreferenced here to match upstream.
	fixed_spells = list(
		/datum/action/cooldown/spell/crush_magi2,
		/datum/action/cooldown/spell/gravity_magi2,
		/datum/action/cooldown/spell/gravity_anchor_magi2,
		/datum/action/cooldown/spell/greater_cleaning_magi2,
		/datum/action/cooldown/spell/projectile/soulshot_magi2,
		/datum/action/cooldown/spell/projectile/greater_arcyne_bolt_magi2,
	)
	variants = list(
		"mastery" = list(
			VARIANT_ADDITIVE = /datum/action/cooldown/spell/mass_crush_magi2,
		),
	)
