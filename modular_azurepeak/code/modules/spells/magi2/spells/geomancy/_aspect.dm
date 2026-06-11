// Geomancy major aspect — earth/stone control. Heavy AOE telegraph + pin-down + ricochet stones.

/datum/magic_aspect/geomancy
	name = "Geomancy"
	latin_name = "Maior Aspectus Terrae"
	desc = "A first-order school focused on controlling the very ground. Rock was the oldest \
		weapon known to man, and Geomancy is just as ancient as the earth. Heavy and weighty - \
		a nimble opponent might dodge one stone, but the geomancer will pin them down with another."
	aspect_type = ASPECT_MAJOR
	attuned_name = ASPECT_NAME_GEOMANCY
	school_color = GLOW_COLOR_EARTHEN
	binding_chants = list(
		"Invoco terram perennem!",
		"I entreat the stone that stands unyielding, answer!",
		"Terra, in me ligare!",
	)
	unbinding_chants = list(
		"Solvo terram vinctam!",
		"I relinquish the stone that fortifies me, crumble.",
		"Terra, a me discedere!",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/projectile/gravel_blast_magi2,
		/datum/action/cooldown/spell/emergence_magi2,
		/datum/action/cooldown/spell/projectile/boulder_strike_magi2,
		/datum/action/cooldown/spell/ensnare_magi2,
		/obj/effect/proc_holder/spell/self/magicians_brick, // swapped in for Magician's Stone (proc_holder spell — aspect grant handles both families)
		/datum/action/cooldown/spell/magicians_rock_magi2, // ported from AP PR #6666 — boulder cousin of Magician's Stone
	)
	variants = list(
		"mastery" = list(
			VARIANT_ADDITIVE = /datum/action/cooldown/spell/meteor_strike_magi2,
		),
	)
