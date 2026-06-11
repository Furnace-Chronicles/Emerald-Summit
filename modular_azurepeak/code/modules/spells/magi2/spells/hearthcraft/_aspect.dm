// Hearthcraft — minor aspect, port of Azure-Peak's `/datum/magic_aspect/hearthcraft`.
// Spells:
//   - Great Shelter (conjure a 4x4 prefab house with bed/hearth/oven, 15-min duration)
//   - Create Campfire (already ported in pyromancy/create_campfire.dm and shared with
//     Lesser Augmentation's pointbuy filler pool)

/datum/magic_aspect/hearthcraft
	name = "Hearthcraft"
	latin_name = "Minor Aspectus Domus"
	desc = "The school of home and hearth. A travelling mage who has bound this aspect can raise \
		a cramped shelter from arcyne force itself — bed, hearth, oven — at the cost of a heavy \
		conjuration. Useful for long expeditions or desperate retreats."
	aspect_type = ASPECT_MINOR
	school_color = GLOW_COLOR_HEARTH
	binding_chants = list(
		"Let me tend the hearth and home.",
		"Domus, mihi adesse!",
	)
	unbinding_chants = list(
		"I let the hearthfire fade.",
		"Domus, me relinquere!",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/great_shelter_magi2,
		/datum/action/cooldown/spell/create_campfire_magi2,
	)
