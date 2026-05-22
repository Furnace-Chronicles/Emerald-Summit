/datum/migrant_wave
	abstract_type = /datum/migrant_wave
	/// Name of the wave
	var/name = "MIGRANT WAVE"
	/// Assoc list of roles types to amount
	var/list/roles = list()
	/// If defined, this is the minimum active migrants required to roll the wave
	var/min_active = null
	/// If defined, this is the maximum active migrants required to roll the wave
	var/max_active = null
	/// If defined, this is the minimum population playing the game that is required for wave to roll
	var/min_pop = null
	/// If defined, this is the maximum population playing the game that is required for wave to roll
	var/max_pop = null
	/// If defined, this is the maximum amount of times this wave can spawn
	var/max_spawns = null
	/// The relative probability this wave will be picked, from all available waves
	var/weight = 30
	/// Name of the latejoin spawn landmark for the wave to decide where to spawn
	var/spawn_landmark = "Pilgrim"
	/// Text to greet all players in the wave with
	var/greet_text
	/// Whether this wave can roll at all. If not, it can still be forced to be ran, or used as "downgrade" wave
	var/can_roll = TRUE
	/// What type of wave to downgrade to on failure
	var/downgrade_wave
	/// If defined, this will be the wave type to increment for purposes of checking `max_spawns`
	var/shared_wave_type = null
	/// Whether we want to spawn people on the rolled location, this may not be desired for bandits or other things that set the location
	var/spawn_on_location = TRUE
	/// Triumph contributions for this wave type (ckey -> amount)
	var/list/triumph_contributions = list()
	/// Total triumph invested in this wave
	var/triumph_total = 0
	/// Threshold at which this wave is guaranteed to be next
	var/triumph_threshold = 25
	/// Whether triumph contributions reset after wave spawns
	var/reset_contributions_on_spawn = TRUE


/datum/migrant_wave/proc/get_roles_amount()
	var/amount = 0
	for(var/role_type in roles)
		amount += roles[role_type]
	return amount

/// Called when this wave is first announced to the round (admin force or natural roll).
/// NOT called for downgrades — override to fire one-shot side effects like faction scaling
/// adjustments or population broadcasts.
/datum/migrant_wave/proc/announce_wave()
	return

// /datum/migrant_wave/pilgrim
// 	name = "Pilgrimage"
// 	downgrade_wave = /datum/migrant_wave/pilgrim_down_one
// 	roles = list(
// 		/datum/migrant_role/pilgrim = 4,
// 	)
// 	greet_text = "Fleeing from misfortune and hardship, you and a handful of survivors get closer to Emerald Summit, looking for refuge and work, finally almost being there, almost..."

// /datum/migrant_wave/pilgrim_down_one
// 	name = "Pilgrimage"
// 	downgrade_wave = /datum/migrant_wave/pilgrim_down_two
// 	can_roll = FALSE
// 	roles = list(
// 		/datum/migrant_role/pilgrim = 3,
// 	)
// 	greet_text = "Fleeing from misfortune and hardship, you and a handful of survivors get closer to Emerald Summit, looking for refuge and work, finally almost being there, almost..."

// /datum/migrant_wave/pilgrim_down_two
// 	name = "Pilgrimage"
// 	downgrade_wave = /datum/migrant_wave/pilgrim_down_three
// 	can_roll = FALSE
// 	roles = list(
// 		/datum/migrant_role/pilgrim = 2,
// 	)
// 	greet_text = "Fleeing from misfortune and hardship, you and a handful of survivors get closer to Emerald Summit, looking for refuge and work, finally almost being there, almost..."

// /datum/migrant_wave/pilgrim_down_three
// 	name = "Pilgrimage"
// 	can_roll = FALSE
// 	roles = list(
// 		/datum/migrant_role/pilgrim = 1,
// 	)
// 	greet_text = "Fleeing from misfortune and hardship, you and a handful of survivors get closer to Emerald Summit, looking for refuge and work, finally almost being there, almost..."

/datum/migrant_wave/adventurer
	name = "Adventure Party"
	downgrade_wave = /datum/migrant_wave/adventurer_down_one
	roles = list(
		/datum/migrant_role/adventurer = 4,
	)
	greet_text = "Together with a party of trusted friends we decided to venture out, seeking thrills, glory and treasure, ending up in the misty and damp bog underneath Emerald Summit, perhaps getting ourselves into more than what we bargained for."

/datum/migrant_wave/adventurer_down_one
	name = "Adventure Party"
	downgrade_wave = /datum/migrant_wave/adventurer_down_two
	can_roll = FALSE
	roles = list(
		/datum/migrant_role/adventurer = 3,
	)
	greet_text = "Together with a party of trusted friends we decided to venture out, seeking thrills, glory and treasure, ending up in the misty and damp bog underneath Emerald Summit, perhaps getting ourselves into more than what we bargained for."

/datum/migrant_wave/adventurer_down_two
	name = "Adventure Party"
	downgrade_wave = /datum/migrant_wave/adventurer_down_three
	can_roll = FALSE
	roles = list(
		/datum/migrant_role/adventurer = 2,
	)
	greet_text = "Together with a party of trusted friends we decided to venture out, seeking thrills, glory and treasure, ending up in the misty and damp bog underneath Emerald Summit, perhaps getting ourselves into more than what we bargained for."

/datum/migrant_wave/adventurer_down_three
	name = "Adventure Party"
	can_roll = FALSE
	roles = list(
		/datum/migrant_role/adventurer = 1,
	)
	greet_text = "Together with a party of trusted friends we decided to venture out, seeking thrills, glory and treasure, ending up in the misty and damp bog underneath Emerald Summit, perhaps getting ourselves into more than what we bargained for."

/datum/migrant_wave/bandit
	name = "Bandit Raid"
	downgrade_wave = /datum/migrant_wave/bandit_down_one
	can_roll = FALSE
	weight = 16
	spawn_landmark = "Bandit"
	roles = list(
		/datum/migrant_role/bandit = 4,
	)

/datum/migrant_wave/bandit_down_one
	name = "Bandit Raid"
	downgrade_wave = /datum/migrant_wave/bandit_down_two
	can_roll = FALSE
	spawn_landmark = "Bandit"
	roles = list(
		/datum/migrant_role/bandit = 3,
	)

/datum/migrant_wave/bandit_down_two
	name = "Bandit Raid"
	downgrade_wave = /datum/migrant_wave/bandit_down_three
	can_roll = FALSE
	spawn_landmark = "Bandit"
	roles = list(
		/datum/migrant_role/bandit = 2,
	)

/datum/migrant_wave/bandit_down_three
	name = "Bandit Raid"
	can_roll = FALSE
	spawn_landmark = "Bandit"
	roles = list(
		/datum/migrant_role/bandit = 1,
	)

/datum/migrant_wave/gnolls
	name = "Gnoll raid"
	downgrade_wave = /datum/migrant_wave/gnolls/down_one
	spawn_landmark = "Gnoll"
	can_roll = FALSE
	weight = 12
	roles = list(
		/datum/migrant_role/gnoll = 4,
	)

/datum/migrant_wave/gnolls/announce_wave()
	var/datum/job/gnoll_job = SSjob.GetJob("Gnoll")
	if(!gnoll_job)
		return
	gnoll_job.total_positions = min(gnoll_job.total_positions + 2, 6)
	gnoll_job.spawn_positions = min(gnoll_job.spawn_positions + 2, 6)
	if(SSgnoll_scaling)
		SSgnoll_scaling.note_external_slot_adjustment(gnoll_job.total_positions, gnoll_job.spawn_positions)
	if(gnoll_job.total_positions < 6)
		for(var/mob/dead/new_player/player as anything in GLOB.new_player_list)
			if(!player.client)
				continue
			to_chat(player, span_danger("Graggar demands blood, gnolls flock to the Vale!"))

/datum/migrant_wave/gnolls/down_one
	downgrade_wave = /datum/migrant_wave/gnolls/down_two
	roles = list(
		/datum/migrant_role/gnoll = 3,
	)

/datum/migrant_wave/gnolls/down_two
	downgrade_wave = /datum/migrant_wave/gnolls/down_three
	roles = list(
		/datum/migrant_role/gnoll = 2,
	)

/datum/migrant_wave/gnolls/down_three
	downgrade_wave = null
	roles = list(
		/datum/migrant_role/gnoll = 1,
	)

