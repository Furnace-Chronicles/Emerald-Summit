// Pyromancy major aspect — datum that wraps the five ported Pyromancy spells.
// Mastery variant (Greater Fireball) is granted additively to T4 casters. The
// Grenzelhoftian variant (Artillery Fireball) is deferred until the Grenzmage class ports.

/datum/magic_aspect/pyromancy
	name = "Pyromancy"
	latin_name = "Maior Aspectus Ignis"
	desc = "A first-order school focused on roasting the Magi's enemy alive with the primal fury of fire. \
		Its heritage is ancient, and it is often considered a sacred magick associated with Astrata's light. \
		Pyromancers are notorious for rivalry with Cryomancers."
	aspect_type = ASPECT_MAJOR
	attuned_name = ASPECT_NAME_PYROMANCY
	school_color = GLOW_COLOR_FIRE
	binding_chants = list(
		"Invoco flammam aeternam!",
		"I implore the flame within to burn bright, rise!",
		"Ignis, in me ligare!",
	)
	unbinding_chants = list(
		"Solvo flammam vinctam!",
		"I becalm the flame that dwells within, rest.",
		"Ignis, a me discedere!",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/projectile/spitfire_magi2,
		/datum/action/cooldown/spell/projectile/fireball_magi2,
		/datum/action/cooldown/spell/fire_blast_magi2,
		/datum/action/cooldown/spell/fire_curtain_magi2,
		/datum/action/cooldown/spell/create_campfire_magi2,
	)
	variants = list(
		"mastery" = list(
			VARIANT_ADDITIVE = /datum/action/cooldown/spell/projectile/fireball_magi2/greater,
		),
		// ported from AP PR #6666 — grenzelhoftian-trained pyromancers swap Fireball for Artillery Fireball.
		// Only applies to a mage class whose mage_aspect_config sets "variants" = list(<pyromancy> = "grenzelhoftian").
		"grenzelhoftian" = list(
			/datum/action/cooldown/spell/projectile/fireball_magi2 = /datum/action/cooldown/spell/projectile/fireball_magi2/artillery,
		),
	)
