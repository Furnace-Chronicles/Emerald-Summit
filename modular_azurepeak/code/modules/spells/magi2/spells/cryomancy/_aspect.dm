// Cryomancy major aspect — port of Azure-Peak's /datum/magic_aspect/cryomancy.
// Mastery variant (Frozen Mist) is granted additively to T4 casters. Skips upstream's
// chill_food redundant utility (Fridigitation already covers the food-freeze niche).

/datum/magic_aspect/cryomancy
	name = "Cryomancy"
	latin_name = "Maior Aspectus Glaciei"
	desc = "A first-order school focused on degrading its opponents with every strike. What it lacks for in pure destruction \
		or speed, it makes up for in building, debilitating effects as the Magi's opponent shudders, slows, then finally freezes under every blow. \
		Cryomancers are notorious for rivalry with Pyromancers."
	aspect_type = ASPECT_MAJOR
	attuned_name = ASPECT_NAME_CRYOMANCY
	school_color = GLOW_COLOR_ICE
	binding_chants = list(
		"Invoco glaciem aeternam!",
		"I invoke the cold that lingers deep, come forth!",
		"Glacies, in me ligare!",
	)
	unbinding_chants = list(
		"Solvo glaciem vinctam!",
		"I release the chill that grips my veins, thaw.",
		"Glacies, a me discedere!",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/projectile/frost_bolt_magi2,
		/datum/action/cooldown/spell/frost_blast_magi2,
		/datum/action/cooldown/spell/projectile/ice_burst_magi2,
		/datum/action/cooldown/spell/snap_freeze_magi2,
		/datum/action/cooldown/spell/fridigitation_magi2,
	)
	variants = list(
		"mastery" = list(
			VARIANT_ADDITIVE = /datum/action/cooldown/spell/frozen_mist_magi2,
		),
	)
