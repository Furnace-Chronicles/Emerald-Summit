// Fulgurmancy major aspect — port of Azure-Peak's /datum/magic_aspect/fulgurmancy.
// Mastery variant (Greater Thunderstrike) is granted additively to T4 casters.

/datum/magic_aspect/fulgurmancy
	name = "Fulgurmancy"
	latin_name = "Maior Aspectus Fulminis"
	desc = "A first-order school focused on striking with numbing speed and overwhelming force. \
		Fulgurmancers are valued for their reliability - their spells are fast, accurate, and consistent \
		in ways that flashier schools are not. It is said the most skilled Fulgurmancer has never once \
		seen their bolt go wide."
	aspect_type = ASPECT_MAJOR
	attuned_name = ASPECT_NAME_FULGURMANCY
	school_color = GLOW_COLOR_LIGHTNING
	binding_chants = list(
		"Invoco furorem tempestatis!",
		"I beckon the storm that churns above, strike!",
		"Fulmen, in me ligare!",
	)
	unbinding_chants = list(
		"Solvo tempestatem vinctam!",
		"I quiet the storm that rages within, be still.",
		"Fulmen, a me discedere!",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/projectile/arc_bolt_magi2,
		/datum/action/cooldown/spell/projectile/lightning_bolt_magi2,
		/datum/action/cooldown/spell/heavens_strike_magi2,
		/datum/action/cooldown/spell/thunderstrike_magi2,
		/datum/action/cooldown/spell/light_magi2,
	)
	variants = list(
		"mastery" = list(
			VARIANT_ADDITIVE = /datum/action/cooldown/spell/greater_thunderstrike_magi2,
		),
	)
