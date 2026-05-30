// Ferramancy major aspect — blade magic. Distinct from elemental schools: piercing
// metal projectiles, ground-eruption blades, and a self/ally armor buff.

/datum/magic_aspect/ferramancy
	name = "Ferramancy"
	latin_name = "Maior Aspectus Ferri"
	desc = "Ferramancy is a second-order magical school, conceptualizing primal matters rendered \
		unto weapons and tools by humen hands, materializing them, and sending them out to slash and \
		rend foes apart. Of the major aspects, the only one often associated with Ravox instead of \
		Noc — likely from the myth that he slew Graggar by hurling weapons at him."
	aspect_type = ASPECT_MAJOR
	attuned_name = ASPECT_NAME_FERRAMANCY
	school_color = GLOW_COLOR_METAL
	binding_chants = list(
		"Invoco chalybem indomitum!",
		"I call upon the forge within, create!",
		"Chalybs, imperio meo parere!",
	)
	unbinding_chants = list(
		"Exstinguo fornacem internam!",
		"I silence the ring of hammer and steel, grow cold.",
		"Chalybs, ad quietem redire!",
	)
	// Upstream Magi 2 splits the projectile picks into choice_spells (arcyne_lance,
	// stygian_efflorescence). Grimoire MVP has no choice picker, so both are flattened
	// into fixed_spells for the pilot.
	fixed_spells = list(
		/datum/action/cooldown/spell/projectile/sawblade_volley_magi2,
		/datum/action/cooldown/spell/blade_burst_magi2,
		/datum/action/cooldown/spell/projectile/iron_tempest_magi2,
		/datum/action/cooldown/spell/iron_skin_magi2,
		/datum/action/cooldown/spell/arcyne_forge_magi2,
		/datum/action/cooldown/spell/readomen_magi2,
		/datum/action/cooldown/spell/projectile/arcyne_lance_magi2,
		/datum/action/cooldown/spell/projectile/stygian_efflorescence_magi2,
	)
	variants = list(
		"mastery" = list(
			VARIANT_ADDITIVE = /datum/action/cooldown/spell/blade_dance_magi2,
		),
	)
