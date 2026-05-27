// Pyromancy major aspect — datum that wraps the four ported Pyromancy spells.
// Subset port: skips upstream's `create_campfire` (utility spell not ported yet),
// `fireball/greater` and `fireball/artillery` variants (mastery / Grenzelhoftian).

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
	)
