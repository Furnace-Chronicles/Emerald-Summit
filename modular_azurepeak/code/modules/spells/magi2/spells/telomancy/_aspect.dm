// Telomancy major aspect — pure-arcana ballistics. Closely related to Kinesis but
// focused entirely on shaping mana into projectiles. Shares greater_arcyne_bolt and
// greater_cleaning with Kinesis.

/datum/magic_aspect/telomancy
	name = "Telomancy"
	latin_name = "Maior Aspectus Teli"
	desc = "Telomancers consider themselves a sub-branch of Kinesis, and deserving of the title \
		'Origin School'. Where Kinesis focuses on shaping mana and the power of force, Telomancy \
		focuses almost entirely on shaping mana into deadly projectiles."
	aspect_type = ASPECT_MAJOR
	attuned_name = ASPECT_NAME_TELOMANCY
	school_color = GLOW_COLOR_ARCANE
	binding_chants = list(
		"Invoco telum destinatum!",
		"I send my purpose toward its mark, let it arrive.",
		"Telum, in me ligare!",
	)
	unbinding_chants = list(
		"Solvo telum vinctum!",
		"I release the mark I had chosen, go free.",
		"Telum, a me discedere!",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/projectile/greater_arcyne_bolt_magi2,
		/datum/action/cooldown/spell/projectile/arcyne_salvo_magi2,
		/datum/action/cooldown/spell/energetic_blast_magi2,
		/datum/action/cooldown/spell/projectile/seeker_volley_magi2,
		/datum/action/cooldown/spell/greater_cleaning_magi2,
	)
	variants = list(
		"mastery" = list(
			VARIANT_ADDITIVE = /datum/action/cooldown/spell/projectile/arcyne_barrage_magi2, // ported from AP PR #7402 (telomancy ultimate)
		),
	)
