// Battlewardry major aspect — arcyne wards, runes, and shielding.

/datum/magic_aspect/battlewardry
	name = "Battlewardry"
	latin_name = "Maior Aspectus Tutela"
	desc = "A third-order school focused on the abstract concept of protection — the Magi's will \
		manifest as runes, walls, and personal wards. Battle-wardens are the steel core around which \
		any wizarding strike-force forms. Where pyromancers attack and telomancers harry, the warden holds."
	aspect_type = ASPECT_MAJOR
	attuned_name = ASPECT_NAME_BATTLEWARDRY
	school_color = GLOW_COLOR_WARD
	binding_chants = list(
		"Invoco tutelam invisibilem!",
		"I call upon the wards that guard the hearth, hold!",
		"Tutela, in me ligare!",
	)
	unbinding_chants = list(
		"Solvo tutelam vinctam!",
		"I release the wards I have woven, fall.",
		"Tutela, a me discedere!",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/battle_ward_magi2,
		/datum/action/cooldown/spell/forcewall_magi2,
		/datum/action/cooldown/spell/arrow_ward_magi2,
		/datum/action/cooldown/spell/bestow_ward_magi2,
		/datum/action/cooldown/spell/touch/rune_ward_magi2,
		/datum/action/cooldown/spell/projectile/soulshot_magi2,
		/datum/action/cooldown/spell/projectile/greater_arcyne_bolt_magi2,
	)
	variants = list(
		"mastery" = list(
			VARIANT_ADDITIVE = /datum/action/cooldown/spell/arcyne_fortress_magi2,
		),
	)
