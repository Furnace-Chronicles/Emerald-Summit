/datum/round_event_control/antagonist/solo/vampires
	name = "Vampires"
	tags = list(
		TAG_COMBAT,
		TAG_HAUNTED,
		TAG_VILLIAN,
	)
	roundstart = TRUE
	antag_flag = ROLE_NBEAST
	shared_occurence_type = SHARED_HIGH_THREAT

	weight = 4 // frag out boy
	max_occurrences = 2
	denominator = 50

	base_antags = 1
	maximum_antags = 2

	earliest_start = 0 SECONDS

	typepath = /datum/round_event/antagonist/solo/vampire
	antag_datum = /datum/antagonist/vampirelord

	restricted_roles = list( // basically just keep and church roles
		"Grand Duke",
		"Grand Duchess",
		"Knight Captain",
		"Consort",
		"Dungeoneer",
		"Sergeant",
		"Men-at-Arms",
		"Woman-at-Arms",
		"Marshal",
		"Merchant",
		"Priest",
		"Priestess",
		"Acolyte",
		"Martyr",
		"Templar",
		"Councillor",
		"Bandit",
		"Prince",
		"Princess",
		"Hand",
		"Steward",
		"Clerk",
		"Magos Thrall",
		"Jester",
		"Servant",
		"Seneschal",
		"Court Physician",
		"Town Elder",
		"Captain",
		"Loudmouth",
		"Knight",
		"Dame",
		"Court Magician",
		"Inquisitor",
		"Orthodoxist",
		"Absolver",
		"Warden",
		"Squire",
		"Veteran",
		"Apothecary"
	)

/datum/round_event/antagonist/solo/vampire
	var/leader = FALSE

/datum/round_event/antagonist/solo/vampire/add_datum_to_mind(datum/mind/antag_mind)
	if(!leader)
		var/datum/job/J = SSjob.GetJob(antag_mind.current?.job)
		J?.current_positions = max(J?.current_positions-1, 0)
		antag_mind.current.unequip_everything()
		antag_mind.add_antag_datum(antag_datum)
		leader = TRUE
		return
	else
		if(!antag_mind.has_antag_datum(antag_datum))
			var/datum/job/J = SSjob.GetJob(antag_mind.current?.job)
			J?.current_positions = max(J?.current_positions-1, 0)
			antag_mind.current.unequip_everything()
			antag_mind.add_antag_datum(/datum/antagonist/vampirelord/lesser)
			return
