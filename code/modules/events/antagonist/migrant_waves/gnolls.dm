/datum/round_event_control/antagonist/migrant_wave/gnolls
	name = "Gnolls Migration"
	typepath = /datum/round_event/migrant_wave/gnolls
	wave_type = /datum/migrant_wave/gnolls
	max_occurrences = 2
	weight = 5
	earliest_start = 0 SECONDS
	tags = list(
		TAG_COMBAT,
		TAG_VILLIAN,
	)

/datum/round_event/migrant_wave/gnolls/start()
	. = ..()
	var/datum/migrant_wave/wave = MIGRANT_WAVE(wave_type)
	if(wave)
		wave.announce_wave()
