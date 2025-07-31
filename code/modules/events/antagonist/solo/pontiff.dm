/datum/round_event_control/antagonist/solo/pontiff
	name = "Pontiff"
	tags = list(
		TAG_COMBAT,
		TAG_VILLIAN,
		TAG_LOOT
	)
	roundstart = TRUE
	antag_flag = ROLE_PONTIFF
	shared_occurence_type = SHARED_MINOR_THREAT

	restricted_roles = list(
		"Grand Duke",
		"Grand Duchess",
		"Consort",
		"Dungeoneer",
		"Sergeant",
		"Men-at-arms",
		"Marshal",
		"Merchant",
		"Priest",
		"Acolyte",
		"Martyr",
		"Templar",
		"Councillor",
		"Prince",
		"Princess",
		"Hand",
		"Steward",
		"Court Physician",
		"Town Elder",
		"Captain",
		"Archivist",
		"Knight",
		"Court Magician",
		"Inquisitor",
		"Orthodoxist",
		"Warden",
		"Squire",
		"Veteran",
		"Apothecary"
	)

	base_antags = 1
	maximum_antags = 3

	earliest_start = 0 SECONDS

	weight = 2

	typepath = /datum/round_event/antagonist/solo/pontiff
	antag_datum = /datum/antagonist/pontiff

/datum/round_event_control/antagonist/solo/pontiff/canSpawnEvent(players_amt, gamemode, fake_check)
	. = ..()
	if(!.)
		return
	var/list/candidates = get_candidates()

	// Allow the event to run if there's at least 1 candidate, even if fewer than desired
	if(length(candidates) < 1)
		return FALSE

	return TRUE

/datum/round_event/antagonist/solo/pontiff
	var/leader = FALSE

/datum/round_event/antagonist/solo/pontiff/start()
	var/datum/job/pontiff_job = SSjob.GetJob("Pontiff")
	pontiff_job.total_positions = length(setup_minds)
	pontiff_job.spawn_positions = length(setup_minds)
	for(var/datum/mind/antag_mind as anything in setup_minds)
		var/datum/job/J = SSjob.GetJob(antag_mind.current?.job)
		J?.current_positions = max(J?.current_positions-1, 0)
		antag_mind.current.unequip_everything()
		SSjob.AssignRole(antag_mind.current, "Pontiff")
		SSmapping.retainer.pontiffs |= antag_mind.current
		antag_mind.add_antag_datum(/datum/antagonist/pontiff)

		SSrole_class_handler.setup_class_handler(antag_mind.current, list(CTAG_PONTIFF = 20))
		antag_mind.current:advsetup = TRUE
		antag_mind.current.hud_used?.set_advclass()
