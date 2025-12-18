SUBSYSTEM_DEF(job)
	name = "Jobs"
	init_order = INIT_ORDER_JOBS
	flags = SS_NO_FIRE

	var/list/occupations = list()		//List of all jobs
	var/list/datum/job/name_occupations = list()	//Dict of all jobs, keys are titles
	var/list/type_occupations = list()	//Dict of all jobs, keys are types
	var/list/unassigned = list()		//Players who need jobs
	var/initial_players_to_assign = 0 	//used for checking against population caps

	// Knowledge system optimization - caches job category lookups
	var/list/job_minds_cache = null	// job_title => list(minds)
	
	var/list/landmark_errors_logged = null	// Tracks which job landmarks have had errors logged (prevents spam)

	var/list/prioritized_jobs = list()
	var/list/latejoin_trackers = list()	//Don't read this list, use GetLateJoinTurfs() instead

	var/overflow_role = "Fuckyou"
	var/list/level_order = list(JP_HIGH,JP_MEDIUM,JP_LOW)

/datum/controller/subsystem/job/Initialize(timeofday)
	SSmapping.HACK_LoadMapConfig()
	if(!occupations.len)
		SetupOccupations()
	if(CONFIG_GET(flag/load_jobs_from_txt))
		LoadJobs()
	set_overflow_role(CONFIG_GET(string/overflow_job))
	return ..()

/datum/controller/subsystem/job/proc/set_overflow_role(new_overflow_role)
	var/datum/job/new_overflow = GetJob(new_overflow_role)
	if(!new_overflow)
		return
	var/cap = CONFIG_GET(number/overflow_cap)

	new_overflow.spawn_positions = cap
	new_overflow.total_positions = cap

	if(new_overflow_role != overflow_role)
		var/datum/job/old_overflow = GetJob(overflow_role)
		old_overflow.spawn_positions = initial(old_overflow.spawn_positions)
		old_overflow.total_positions = initial(old_overflow.total_positions)
		overflow_role = new_overflow_role
		JobDebug("Overflow role set to : [new_overflow_role]")

/datum/controller/subsystem/job/proc/SetupOccupations(faction = "Station")
	occupations = list()
	var/list/all_jobs = subtypesof(/datum/job/roguetown)
	if(!all_jobs.len)
		to_chat(world, span_boldannounce("Error setting up jobs, no job datums found"))
		return 0

	for(var/J in all_jobs)
		var/datum/job/job = new J()
		if(!job)
			continue
		if(job.faction != faction)
			continue
		if(!job.config_check())
			continue
		if(!job.map_check())	//Even though we initialize before mapping, this is fine because the config is loaded at new
			testing("Removed [job.type] due to map config");
			continue
		occupations += job
		name_occupations[job.title] = job
		type_occupations[J] = job

	return 1


/datum/controller/subsystem/job/proc/GetJob(rank)
	if(!occupations.len)
		SetupOccupations()
	return name_occupations[rank]

/datum/controller/subsystem/job/proc/GetJobType(jobtype)
	if(!occupations.len)
		SetupOccupations()
	return type_occupations[jobtype]

/datum/controller/subsystem/job/proc/AssignRole(mob/player, rank, latejoin = FALSE)
	JobDebug("Running AR, Player: [player], Rank: [rank], LJ: [latejoin]")
	if(player && player.mind && rank)
		var/datum/job/job = GetJob(rank)
		if(!job)
			return FALSE
		if(is_banned_from(player.ckey, rank) || QDELETED(player))
			return FALSE
		if(!job.player_old_enough(player.client))
			return FALSE
		if(job.required_playtime_remaining(player.client))
			return FALSE
		var/position_limit = job.total_positions
		if(!latejoin)
			position_limit = job.spawn_positions
		JobDebug("Player: [player] is now Rank: [rank], JCP:[job.current_positions], JPL:[position_limit]")
		if(player.mind.assigned_role)
			var/datum/job/old_job = SSjob.GetJob(player.mind.assigned_role)
			if(old_job)
				old_job.current_positions = max(old_job.current_positions - 1, 0)
		player.mind.assigned_role = rank
		unassigned -= player
		job.current_positions++
		if(!latejoin)
			if(player.client)
				if(job.bypass_lastclass)
					player.client.prefs.lastclass = null
				else
					player.client.prefs.lastclass = job.title
				player.client.prefs.save_preferences()
		else
			if(player.client)
				player.client.prefs.lastclass = null
				player.client.prefs.save_preferences()
		GLOB.round_join_times[player.ckey] = world.time
		addtimer(CALLBACK(player.client, TYPE_PROC_REF(/client, job_greet), job), 5 SECONDS)
		return TRUE
	JobDebug("AR has failed, Player: [player], Rank: [rank]")
	return FALSE


/datum/controller/subsystem/job/proc/FindOccupationCandidates(datum/job/job, level, flag)
	JobDebug("Running FOC, Job: [job], Level: [level], Flag: [flag]")
	var/list/candidates = list()
	for(var/mob/dead/new_player/player in unassigned)
		if(is_banned_from(player.ckey, job.title) || QDELETED(player))
			JobDebug("FOC isbanned failed, Player: [player]")
			continue
		if(!job.player_old_enough(player.client))
			JobDebug("FOC player not old enough, Player: [player]")
			continue
		if(job.required_playtime_remaining(player.client))
			JobDebug("FOC player not enough xp, Player: [player]")
			continue
		if(flag && (!(flag in player.client.prefs.be_special)))
			JobDebug("FOC flag failed, Player: [player], Flag: [flag], ")
			continue
		if(player.mind && (job.title in player.mind.restricted_roles))
			JobDebug("FOC incompatible with antagonist role, Player: [player]")
			continue
		if(length(job.allowed_races) && !(player.client.prefs.pref_species.type in job.allowed_races))
			JobDebug("FOC incompatible with species, Player: [player], Job: [job.title], Race: [player.client.prefs.pref_species.name]")
			continue
		if(length(job.allowed_patrons) && !(player.client.prefs.selected_patron.type in job.allowed_patrons))
			JobDebug("FOC incompatible with patron, Player: [player], Job: [job.title], Race: [player.client.prefs.pref_species.name]")
			continue
		if(length(job.virtue_restrictions) && ((player.client.prefs.virtue.type in job.virtue_restrictions) || (player.client.prefs.virtuetwo?.type in job.virtue_restrictions) || (player.client.prefs.virtue_origin?.type in job.virtue_restrictions)))
			JobDebug("FOC incompatible with virtues, Player: [player], Job: [job.title], Virtue 1: [player.client.prefs.virtue.name]")
			continue
		if(length(job.vice_restrictions) && (player.client.prefs.charflaw.type in job.vice_restrictions))
			JobDebug("FOC incompatible with vices, Player: [player], Job: [job.title], Vice: [player.client.prefs.charflaw.name]")
			continue
		if(job.plevel_req > player.client.patreonlevel())
			JobDebug("FOC incompatible with PATREON LEVEL, Player: [player], Job: [job.title], Race: [player.client.prefs.pref_species.name]")
			continue
		if(!isnull(job.min_pq) && (get_playerquality(player.ckey) < job.min_pq))
			continue
		if(!isnull(job.max_pq) && (get_playerquality(player.ckey) > job.max_pq))
			continue
		if(!(player.client.prefs.gender in job.allowed_sexes))
			JobDebug("FOC incompatible with sex, Player: [player], Job: [job.title]")
			continue
		if(length(job.allowed_ages) && !(player.client.prefs.age in job.allowed_ages))
			JobDebug("FOC incompatible with age, Player: [player], Job: [job.title], Age: [player.client.prefs.age]")
			continue
		if(check_blacklist(player.client.ckey) && !job.bypass_jobban)
			JobDebug("FOC incompatible with blacklist, Player: [player], Job: [job.title]")
			continue
		if((player.client.prefs.lastclass == job.title) && !job.bypass_lastclass)
			JobDebug("FOC incompatible with lastclass, Player: [player], Job: [job.title]")
			continue
		if(!job.special_job_check(player))
			JobDebug("FOC player did not pass special check, Player: [player], Job:[job.title]")
			continue
		if(CONFIG_GET(flag/usewhitelist))
			if(job.whitelist_req && (!player.client.whitelisted()))
				continue
		if(player.client.prefs.job_preferences[job.title] == level)
			JobDebug("FOC pass, Player: [player], Level:[level]")
			candidates += player
	return candidates

/datum/controller/subsystem/job/proc/GiveRandomJob(mob/dead/new_player/player)
	JobDebug("GRJ Giving random job, Player: [player]")
	. = FALSE
	for(var/datum/job/job in shuffle(occupations))
		if(!job)
			continue

//		if(istype(job, GetJob(SSjob.overflow_role))) // We don't want to give him assistant, that's boring!
//			continue

		if(job.title in GLOB.noble_positions) //If you want a command position, select it!
			continue

		if(is_banned_from(player.ckey, job.title) || QDELETED(player))
			if(QDELETED(player))
				JobDebug("GRJ isbanned failed, Player deleted")
				break
			JobDebug("GRJ isbanned failed, Player: [player], Job: [job.title]")
			continue

		if(!job.can_random)
			JobDebug("GRJ can't random into this job, Job: [job.title], Player: [player]")
			continue

		if(!job.player_old_enough(player.client))
			JobDebug("GRJ player not old enough, Player: [player]")
			continue

		if(job.required_playtime_remaining(player.client))
			JobDebug("GRJ player not enough xp, Player: [player]")
			continue

		if(player.mind && (job.title in player.mind.restricted_roles))
			JobDebug("GRJ incompatible with antagonist role, Player: [player], Job: [job.title]")
			continue

		if(length(job.allowed_races) && !(player.client.prefs.pref_species.type in job.allowed_races))
			JobDebug("GRJ incompatible with species, Player: [player], Job: [job.title], Race: [player.client.prefs.pref_species.name]")
			continue

		if(length(job.allowed_patrons) && !(player.client.prefs.selected_patron.type in job.allowed_patrons))
			JobDebug("GRJ incompatible with patron, Player: [player], Job: [job.title], Race: [player.client.prefs.pref_species.name]")
			continue

		if(length(job.virtue_restrictions) && ((player.client.prefs.virtue.type in job.virtue_restrictions) || (player.client.prefs.virtuetwo?.type in job.virtue_restrictions) || (player.client.prefs.virtue_origin?.type in job.virtue_restrictions)))
			JobDebug("GRJ incompatible with virtues, Player: [player], Job: [job.title], Virtue 1: [player.client.prefs.virtue.name]")
			continue

		if(length(job.vice_restrictions) && (player.client.prefs.charflaw.type in job.vice_restrictions))
			JobDebug("GRJ incompatible with vices, Player: [player], Job: [job.title], Vice: [player.client.prefs.charflaw.name]")
			continue

		if(job.plevel_req > player.client.patreonlevel())
			JobDebug("GRJ incompatible with PATREON LEVEL, Player: [player], Job: [job.title], Race: [player.client.prefs.pref_species.name]")
			continue

		if(length(job.allowed_ages) && !(player.client.prefs.age in job.allowed_ages))
			JobDebug("GRJ incompatible with age, Player: [player], Job: [job.title], Race: [player.client.prefs.pref_species.name]")
			continue

		if(length(job.allowed_sexes) && !(player.client.prefs.gender in job.allowed_sexes))
			JobDebug("GRJ incompatible with sex, Player: [player], Job: [job.title]")
			continue

		if(!isnull(job.min_pq) && (get_playerquality(player.ckey) < job.min_pq))
			JobDebug("GRJ incompatible with minPQ, Player: [player], Job: [job.title]")
			continue

		if(!isnull(job.max_pq) && (get_playerquality(player.ckey) > job.max_pq))
			JobDebug("GRJ incompatible with maxPQ, Player: [player], Job: [job.title]")
			continue

		if(check_blacklist(player.client.ckey) && !job.bypass_jobban)
			JobDebug("GRJ incompatible with blacklist, Player: [player], Job: [job.title]")
			continue

		if(!job.special_job_check(player))
			JobDebug("GRJ player did not pass special check, Player: [player], Job:[job.title]")
			continue

		if(CONFIG_GET(flag/usewhitelist))
			if(job.whitelist_req && (!player.client.whitelisted()))
				continue

//		if((player.client.prefs.lastclass == job.title) && (!job.bypass_lastclass))
//			JobDebug("GRJ incompatible with lastclass, Player: [player], Job: [job.title]")
//			continue

		if(job.spawn_positions)
			if((job.current_positions < job.spawn_positions) || job.spawn_positions == -1)
				JobDebug("GRJ Random job given, Player: [player], Job: [job]")
				if(AssignRole(player, job.title))
					return TRUE

/datum/controller/subsystem/job/proc/ResetOccupations()
	JobDebug("Occupations reset.")
	
	// Invalidate knowledge cache for new round
	invalidate_job_minds_cache()
	
	for(var/i in GLOB.new_player_list)
		var/mob/dead/new_player/player = i
		if((player) && (player.mind))
			player.mind.assigned_role = null
			player.mind.special_role = null
			player.mind.job_bitflag = NONE
			SSpersistence.antag_rep_change[player.ckey] = 0
	SetupOccupations()
	unassigned = list()
	return


//This proc is called before the level loop of DivideOccupations() and will try to select a head, ignoring ALL non-head preferences for every level until
//it locates a head or runs out of levels to check
//This is basically to ensure that there's atleast a few heads in the round
/datum/controller/subsystem/job/proc/FillHeadPosition()
	for(var/level in level_order)
		for(var/noble_position in GLOB.noble_positions)
			var/datum/job/job = GetJob(noble_position)
			if(!job)
				continue
			if(job.current_positions >= job.spawn_positions)
				continue
			var/list/candidates = FindOccupationCandidates(job, level)
			if(!candidates.len)
				continue
			var/mob/dead/new_player/candidate = pick(candidates)
			if(AssignRole(candidate, noble_position))
				return 1
	return 0


//This proc is called at the start of the level loop of DivideOccupations() and will cause head jobs to be checked before any other jobs of the same level
//This is also to ensure we get as many heads as possible
/datum/controller/subsystem/job/proc/CheckHeadPositions(level)
	for(var/noble_position in GLOB.noble_positions)
		var/datum/job/job = GetJob(noble_position)
		if(!job)
			continue
		if(job.current_positions >= job.spawn_positions)
			continue
		var/list/candidates = FindOccupationCandidates(job, level)
		if(!candidates.len)
			continue
		var/mob/dead/new_player/candidate = pick(candidates)
		AssignRole(candidate, noble_position)

/datum/controller/subsystem/job/proc/FillAIPosition()
	var/ai_selected = 0
	var/datum/job/job = GetJob("AI")
	if(!job)
		return 0
	for(var/i = job.total_positions, i > 0, i--)
		for(var/level in level_order)
			var/list/candidates = list()
			candidates = FindOccupationCandidates(job, level)
			if(candidates.len)
				var/mob/dead/new_player/candidate = pick(candidates)
				if(AssignRole(candidate, "AI"))
					ai_selected++
					break
	if(ai_selected)
		return 1
	return 0

/datum/controller/subsystem/job/proc/sort_male_female(inputlist)
	if(!inputlist)
		return null
	var/list/putty = inputlist
	var/list/newlist = list()
	for(var/mob/dead/new_player/player in putty)
		if(player.client.prefs.gender == MALE)
			newlist += player
			putty -= player
	for(var/mob/dead/new_player/player in putty)
		if(player.client.prefs.gender == FEMALE)
			newlist += player
			putty -= player
	return newlist

/** Proc DivideOccupations
 *  fills var "assigned_role" for all ready players.
 *  This proc must not have any side effect besides of modifying "assigned_role".
 **/
/datum/controller/subsystem/job/proc/DivideOccupations(list/required_jobs)
	//Setup new player list and get the jobs list
	JobDebug("Running DO")
	var/timing_start = world.timeofday

	//Get the players who are ready
	for(var/i in GLOB.new_player_list)
		var/mob/dead/new_player/player = i
		if(player.ready == PLAYER_READY_TO_PLAY && player.check_preferences() && player.mind && !player.mind.assigned_role)
			unassigned += player

	initial_players_to_assign = unassigned.len
	log_game("DO: [unassigned.len] unassigned players")

	JobDebug("DO, Len: [unassigned.len]")
	if(unassigned.len == 0)
		return validate_required_jobs(required_jobs)

	//Scale number of open security officer slots to population
//	setup_officer_positions()

	//Jobs will have fewer access permissions if the number of players exceeds the threshold defined in game_options.txt
	var/mat = CONFIG_GET(number/minimal_access_threshold)
	if(mat)
		if(mat > unassigned.len)
			CONFIG_SET(flag/jobs_have_minimal_access, FALSE)
		else
			CONFIG_SET(flag/jobs_have_minimal_access, TRUE)

	//Shuffle players and jobs
	unassigned = shuffle(unassigned)

	var/feedback_start = world.timeofday
	HandleFeedbackGathering()
	log_game("DO: Feedback gathering took [DisplayTimeText((world.timeofday - feedback_start) * 0.1)]")

	//People who wants to be the overflow role, sure, go on.
//	JobDebug("DO, Running Overflow Check 1")
//	var/datum/job/overflow = GetJob(SSjob.overflow_role)
//	var/list/overflow_candidates = FindOccupationCandidates(overflow, JP_LOW)
//	JobDebug("AC1, Candidates: [overflow_candidates.len]")
//	for(var/mob/dead/new_player/player in overflow_candidates)
//		JobDebug("AC1 pass, Player: [player]")
//		AssignRole(player, SSjob.overflow_role)
//		overflow_candidates -= player
//	JobDebug("DO, AC1 end")

	//Select one head
	JobDebug("DO, Running Head Check")
	var/required_start = world.timeofday
//	FillHeadPosition()
	do_required_jobs()
	log_game("DO: Required jobs took [DisplayTimeText((world.timeofday - required_start) * 0.1)]")
	JobDebug("DO, Head Check end")

	//Check for an AI
//	JobDebug("DO, Running AI Check")
//	FillAIPosition()
//	JobDebug("DO, AI Check end")

	//Other jobs are now checked
	JobDebug("DO, Running Standard Check")
	var/assignment_start = world.timeofday


	// New job giving system by Donkie
	// This will cause lots of more loops, but since it's only done once it shouldn't really matter much at all.
	// Hopefully this will add more randomness and fairness to job giving.

	// Loop through all levels from high to low
	var/list/shuffledoccupations = shuffle(occupations)
	var/assignments_made = 0
	
	// Cache blacklist checks (expensive)
	var/list/blacklisted_players = list()
	for(var/mob/dead/new_player/player in unassigned)
		if(check_blacklist(player.ckey))
			blacklisted_players[player] = TRUE
	
	for(var/level in level_order)
		// Loop through all unassigned players
		for(var/mob/dead/new_player/player in unassigned)
			if(PopcapReached())
				RejectPlayer(player)
				continue

			var/client/C = player.client
			if(!C)
				continue
			
			var/is_blacklisted = blacklisted_players[player]

			// Loop through all jobs
			for(var/datum/job/job in shuffledoccupations)
				if(!job)
					continue

				// Quick filter: Does player want this job at this level?
				if(C.prefs.job_preferences[job.title] != level)
					continue
				
				// Quick filter: Is job full?
				if(job.spawn_positions != -1 && job.current_positions >= job.spawn_positions)
					continue

				// Cached checks first
				if(is_blacklisted && !job.bypass_jobban)
					continue

				// Ban check (relatively expensive)
				if(is_banned_from(player.ckey, job.title))
					continue

				if(QDELETED(player))
					break

				// Age/XP checks
				if(!job.player_old_enough(C) || job.required_playtime_remaining(C))
					continue

				// Mind checks
				if(player.mind && (job.title in player.mind.restricted_roles))
					continue

				// Preference checks (use cached client prefs)
				var/datum/preferences/P = C.prefs
				if(length(job.allowed_races) && !(P.pref_species.type in job.allowed_races))
					continue

				if(length(job.allowed_patrons) && !(P.selected_patron.type in job.allowed_patrons))
					continue

				if(length(job.virtue_restrictions) && ((P.virtue.type in job.virtue_restrictions) || (P.virtuetwo?.type in job.virtue_restrictions) || (P.virtue_origin?.type in job.virtue_restrictions)))
					continue

				if(length(job.vice_restrictions) && (P.charflaw.type in job.vice_restrictions))
					continue

				if(job.plevel_req > C.patreonlevel())
					continue

				// PQ checks
				if(!isnull(job.min_pq) || !isnull(job.max_pq))
					var/pq = get_playerquality(player.ckey)
					if(!isnull(job.min_pq) && pq < job.min_pq)
						continue
					if(!isnull(job.max_pq) && pq > job.max_pq)
						continue

				if((P.lastclass == job.title) && (!job.bypass_lastclass))
					continue

				if(CONFIG_GET(flag/usewhitelist) && job.whitelist_req && !C.whitelisted())
					continue

				if(length(job.allowed_ages) && !(P.age in job.allowed_ages))
					continue

				if(length(job.allowed_sexes) && !(P.gender in job.allowed_sexes))
					continue

				if(!job.special_job_check(player))
					continue

				// All checks passed - assign the job!
				testing("DO pass, Player: [player], Level:[level], Job:[job.title]")
				AssignRole(player, job.title)
				unassigned -= player
				assignments_made++
				break
	
	log_game("DO: Made [assignments_made] job assignments in [DisplayTimeText((world.timeofday - assignment_start) * 0.1)]")


	JobDebug("DO, Handling unassigned.")
	var/unassigned_start = world.timeofday
	// Hand out random jobs to the people who didn't get any in the last check
	// Also makes sure that they got their preference correct
	for(var/mob/dead/new_player/player in unassigned)
		HandleUnassigned(player)
	log_game("DO: Handling unassigned took [DisplayTimeText((world.timeofday - unassigned_start) * 0.1)]")

	JobDebug("DO, Handling unrejectable unassigned")
	//Mop up people who can't leave.
	for(var/mob/dead/new_player/player in unassigned) //Players that wanted to back out but couldn't because they're antags (can you feel the edge case?)
		RejectPlayer(player)
//		if(!GiveRandomJob(player))
//			if(!AssignRole(player, SSjob.overflow_role)) //If everything is already filled, make them an assistant
//				return FALSE //Living on the edge, the forced antagonist couldn't be assigned to overflow role (bans, client age) - just reroll

	var/total_time = world.timeofday - timing_start
	log_game("DO: Total DivideOccupations took [DisplayTimeText(total_time * 0.1)]")
	return validate_required_jobs(required_jobs)


/datum/controller/subsystem/job/proc/do_required_jobs()
	var/amt_picked = 0
	var/require = list()
	for(var/datum/job/job in occupations)
		if(job.required)
			require += job
	for(var/datum/job/job in require)
		for(var/level in level_order)
			for(var/mob/dead/new_player/player in unassigned)
				if(player.client.prefs.job_preferences[job.title] != level)
					continue

				if(is_banned_from(player.ckey, job.title))
					continue

				if(QDELETED(player))
					break

				if(!job.player_old_enough(player.client))
					continue

				if(job.required_playtime_remaining(player.client))
					continue

				if(player.mind && (job.title in player.mind.restricted_roles))
					continue

				if(length(job.allowed_races) && !(player.client.prefs.pref_species.type in job.allowed_races))
					continue
				
				if(length(job.allowed_patrons) && !(player.client.prefs.selected_patron.type in job.allowed_patrons))
					continue

				if(length(job.virtue_restrictions) && ((player.client.prefs.virtue.type in job.virtue_restrictions) || (player.client.prefs.virtuetwo?.type in job.virtue_restrictions) || (player.client.prefs.virtue_origin?.type in job.virtue_restrictions)))
					continue
					
				if(length(job.vice_restrictions) && (player.client.prefs.charflaw.type in job.vice_restrictions))
					continue

				if(job.plevel_req > player.client.patreonlevel())
					continue

				if(!isnull(job.min_pq) && (get_playerquality(player.ckey) < job.min_pq) && level != JP_LOW) //since its required people on low can roll for it
					continue

				if((player.client.prefs.lastclass == job.title) && (!job.bypass_lastclass))
					continue

				if(check_blacklist(player.client.ckey) && !job.bypass_jobban)
					continue

				if(CONFIG_GET(flag/usewhitelist))
					if(job.whitelist_req && (!player.client.whitelisted()))
						continue

				if(length(job.allowed_ages) && !(player.client.prefs.age in job.allowed_ages))
					continue

				if(length(job.allowed_sexes) && !(player.client.prefs.gender in job.allowed_sexes))
					continue

				if(!job.special_job_check(player))
					continue

				// We only need 1 person for the required job, the rest can use the normal system
				if((job.current_positions < 1))
					AssignRole(player, job.title)
					unassigned -= player
					amt_picked++
	return amt_picked

/datum/controller/subsystem/job/proc/validate_required_jobs(list/required_jobs)
	if(!required_jobs.len)
		return TRUE
	for(var/required_group in required_jobs)
		var/group_ok = TRUE
		for(var/rank in required_group)
			var/datum/job/J = GetJob(rank)
			if(!J)
				return FALSE
			if(J.current_positions < required_group[rank])
				group_ok = FALSE
				break
		if(group_ok)
			return TRUE
	return FALSE

//We couldn't find a job from prefs for this guy.
/datum/controller/subsystem/job/proc/HandleUnassigned(mob/dead/new_player/player)
	if(PopcapReached())
		RejectPlayer(player)
	else
		if(player.client.prefs.joblessrole == BEOVERFLOW)
			var/allowed_to_be_a_loser = !is_banned_from(player.ckey, SSjob.overflow_role)
			if(QDELETED(player) || !allowed_to_be_a_loser)
				RejectPlayer(player)
			else
				if(!AssignRole(player, SSjob.overflow_role))
					RejectPlayer(player)
		else if(player.client.prefs.joblessrole == BERANDOMJOB)
			if(!GiveRandomJob(player))
				RejectPlayer(player)
		else if(player.client.prefs.joblessrole == RETURNTOLOBBY)
			RejectPlayer(player)
		else //Something gone wrong if we got here.
			var/message = "DO: [player] fell through handling unassigned"
			JobDebug(message)
			log_game(message)
			message_admins(message)
			RejectPlayer(player)

//Gives the player the stuff he should have with his rank
/datum/controller/subsystem/job/proc/EquipRank(mob/M, rank, joined_late = FALSE)
	var/debug_timing = (SSticker.current_state == GAME_STATE_STARTUP && !joined_late)
	var/equip_start = world.timeofday
	
	var/mob/dead/new_player/N
	var/mob/living/H
	if(!joined_late)
		N = M
		H = N.new_character
	else
		H = M

	var/datum/job/job = GetJob(rank)

	H.job = rank

	SEND_SIGNAL(H, COMSIG_JOB_RECEIVED, H.job)


	//If we joined at roundstart we should be positioned at our workstation
	if(!joined_late)
		var/obj/S = null
		
		// Jobs that can stack on same landmark (don't mark as used)
		var/static/list/stackable_jobs = list("Adventurer", "Mercenary", "Wretch", "Bandit")
		var/can_stack = (rank in stackable_jobs)
		
		// Single loop - find first matching landmark (used or unused based on can_stack)
		for(var/obj/effect/landmark/start/sloc in GLOB.start_landmarks_list)
			if(sloc.name != rank)
				continue
			if(!can_stack && (sloc.used || locate(/mob/living) in sloc.loc))
				continue
			S = sloc
			if(!can_stack)
				sloc.used = TRUE
			break
		
		if(!S)//danger will robinson something went wrong
			// Don't spam - only log once per rank
			if(!(rank in SSjob.landmark_errors_logged))
				LAZYINITLIST(SSjob.landmark_errors_logged)
				SSjob.landmark_errors_logged[rank] = TRUE
				log_game("Could not find a landmark for [rank] - check map for missing spawn points")
		if(length(GLOB.jobspawn_overrides[rank]))
			S = pick(GLOB.jobspawn_overrides[rank])
		if(S)
			S.JoinPlayerHere(H, FALSE)
		if(!S) //if there isn't a spawnpoint send them to latejoin, if there's no latejoin go yell at your mapper
			log_world("Couldn't find a round start spawn point for [rank]")
			SendToLateJoin(H)


	if(H.mind)
		H.mind.assigned_role = rank

	if(job)
		var/new_mob = job.equip(H, null, null, joined_late , null, M.client)
		if(ismob(new_mob))
			H = new_mob
			if(!joined_late)
				N.new_character = H
			else
				M = H

		if(M.client) // Client may have disconnected during processing
			SSpersistence.antag_rep_change[M.client.ckey] += job.GetAntagRep()
		else
			// TODO: TEMPORARY WORKAROUND - Remove once roundstart hang issue is fixed
			// Client disconnected - defer equipment until they reconnect
			if(H.mind)
				H.mind.pending_equipment_job = rank
				H.mind.pending_equipment_latejoin = joined_late
				var/player_ckey = H.ckey || "UNKNOWN"
				log_game("EQUIP DEFERRED: [rank] for [player_ckey] will complete on reconnect")
			return // Don't continue processing without client

		if(M.client?.holder)
			if(CONFIG_GET(flag/auto_deadmin_players) || (M.client.prefs?.toggles & DEADMIN_ALWAYS))
				M.client.holder.auto_deadmin()
			else
				handle_auto_deadmin_roles(M.client, rank)

//	if(job)
//		to_chat(M, "<b>As the [rank] you answer directly to [job.supervisors]. Special circumstances may change this.</b>")
//		job.radio_help_message(M)
////		if(job.req_admin_notify)
//			to_chat(M, "<b>I are playing a job that is important for Game Progression. If you have to disconnect, please notify the admins via adminhelp.</b>")
//		if(CONFIG_GET(number/minimal_access_threshold))
//			to_chat(M, span_notice("<B>As this station was initially staffed with a [CONFIG_GET(flag/jobs_have_minimal_access) ? "full crew, only your job's necessities" : "skeleton crew, additional access may"] have been added to your ID card.</B>"))
//		if(job.tutorial)
//			to_chat(M, job.tutorial)
	var/related_policy = get_policy(rank)
	if(related_policy)
		to_chat(M,related_policy)
//	if(ishuman(H))
//		var/mob/living/carbon/human/wageslave = H
//		H.add_memory("Your account ID is [wageslave.account_id].")
	if(job && H)
		if(debug_timing)
			var/phase_time = world.timeofday - equip_start
			if(phase_time > 5)
				log_game("EQUIP PHASE: Pre-equip for [rank] took [phase_time/10]s")
		
		job.after_spawn(H, M, joined_late) // note: this happens before the mob has a key! M will always have a client, H might not.
		
		if(debug_timing)
			var/after_spawn_time = world.timeofday - equip_start
			if(after_spawn_time > 10)
				log_game("EQUIP PHASE: after_spawn for [rank] took [after_spawn_time/10]s total")
		
		// Send signal that equipment is complete and knowledge can be populated
		// For jobs with advclasses, this signal is sent from finish_class_handler() instead
		if(!job.job_subclasses || !length(job.job_subclasses))
			SEND_SIGNAL(H, COMSIG_JOB_EQUIPPED, joined_late)

	return H

/datum/controller/subsystem/job/proc/handle_auto_deadmin_roles(client/C, rank)
	if(!C?.holder)
		return TRUE
	var/datum/job/job = GetJob(rank)
	if(!job)
		return
	if((job.auto_deadmin_role_flags & DEADMIN_POSITION_HEAD) && (CONFIG_GET(flag/auto_deadmin_heads) || (C.prefs?.toggles & DEADMIN_POSITION_HEAD)))
		return C.holder.auto_deadmin()

/datum/controller/subsystem/job/proc/setup_officer_positions()
	var/datum/job/J = SSjob.GetJob("Security Officer")
	if(!J)
		CRASH("setup_officer_positions(): Security officer job is missing")

	var/ssc = CONFIG_GET(number/security_scaling_coeff)
	if(ssc > 0)
		if(J.spawn_positions > 0)
			var/officer_positions = min(12, max(J.spawn_positions, round(unassigned.len / ssc))) //Scale between configured minimum and 12 officers
			JobDebug("Setting open security officer positions to [officer_positions]")
			J.total_positions = officer_positions
			J.spawn_positions = officer_positions

/datum/controller/subsystem/job/proc/LoadJobs()
	var/jobstext = file2text("[global.config.directory]/jobs.txt")
	for(var/datum/job/J in occupations)
		var/regex/jobs = new("[J.title]=(-1|\\d+),(-1|\\d+)")
		jobs.Find(jobstext)
		J.total_positions = text2num(jobs.group[1])
		J.spawn_positions = text2num(jobs.group[2])

/datum/controller/subsystem/job/proc/HandleFeedbackGathering()
	for(var/datum/job/job in occupations)
		var/high = 0 //high
		var/medium = 0 //medium
		var/low = 0 //low
		var/never = 0 //never
		var/banned = 0 //banned
		var/young = 0 //account too young
		for(var/i in GLOB.new_player_list)
			var/mob/dead/new_player/player = i
			if(!(player.ready == PLAYER_READY_TO_PLAY && player.mind && !player.mind.assigned_role))
				continue //This player is not ready
			if(is_banned_from(player.ckey, job.title) || QDELETED(player))
				banned++
				continue
			if(!job.player_old_enough(player.client))
				young++
				continue
			if(job.required_playtime_remaining(player.client))
				young++
				continue
			switch(player.client.prefs.job_preferences[job.title])
				if(JP_HIGH)
					high++
				if(JP_MEDIUM)
					medium++
				if(JP_LOW)
					low++
				else
					never++
		SSblackbox.record_feedback("nested tally", "job_preferences", high, list("[job.title]", "high"))
		SSblackbox.record_feedback("nested tally", "job_preferences", medium, list("[job.title]", "medium"))
		SSblackbox.record_feedback("nested tally", "job_preferences", low, list("[job.title]", "low"))
		SSblackbox.record_feedback("nested tally", "job_preferences", never, list("[job.title]", "never"))
		SSblackbox.record_feedback("nested tally", "job_preferences", banned, list("[job.title]", "banned"))
		SSblackbox.record_feedback("nested tally", "job_preferences", young, list("[job.title]", "young"))

/datum/controller/subsystem/job/proc/PopcapReached()
	var/hpc = CONFIG_GET(number/hard_popcap)
	var/epc = CONFIG_GET(number/extreme_popcap)
	if(hpc || epc)
		var/relevent_cap = max(hpc, epc)
		if((initial_players_to_assign - unassigned.len) >= relevent_cap)
			return 1
	return 0

/datum/controller/subsystem/job/proc/RejectPlayer(mob/dead/new_player/player)
	if(player.mind && player.mind.special_role)
		return
	if(PopcapReached())
		JobDebug("Popcap overflow Check observer located, Player: [player]")
	JobDebug("Player rejected :[player]")
	to_chat(player, "<b>I couldn't find a job to be..</b>")
	unassigned -= player
	player.ready = PLAYER_NOT_READY


/datum/controller/subsystem/job/Recover()
	set waitfor = FALSE
	var/oldjobs = SSjob.occupations
	sleep(20)
	for (var/datum/job/J in oldjobs)
		INVOKE_ASYNC(src, PROC_REF(RecoverJob), J)

/datum/controller/subsystem/job/proc/RecoverJob(datum/job/J)
	var/datum/job/newjob = GetJob(J.title)
	if (!istype(newjob))
		return
	newjob.total_positions = J.total_positions
	newjob.spawn_positions = J.spawn_positions
	newjob.current_positions = J.current_positions

/atom/proc/JoinPlayerHere(mob/M, buckle)
	// By default, just place the mob on the same turf as the marker or whatever.
	M.forceMove(get_turf(src))
	M.dir = dir

/obj/structure/chair/JoinPlayerHere(mob/M, buckle)
	// Placing a mob in a chair will attempt to buckle it, or else fall back to default.
	if (buckle && isliving(M) && buckle_mob(M, FALSE, FALSE))
		return
	..()

/datum/controller/subsystem/job/proc/SendToLateJoin(mob/M, buckle = TRUE)
	var/atom/destination
	if(M.mind && M.mind.assigned_role && length(GLOB.jobspawn_overrides[M.mind.assigned_role])) //We're doing something special today.
		destination = pick(GLOB.jobspawn_overrides[M.mind.assigned_role])
		destination.JoinPlayerHere(M, FALSE)
		return

	if(latejoin_trackers.len)
		destination = pick(latejoin_trackers)
		destination.JoinPlayerHere(M, buckle)
		return

	var/msg = "Unable to send mob [M] to late join!"
	message_admins(msg)
	CRASH(msg)


///////////////////////////////////
//Keeps track of all living heads//
///////////////////////////////////
/datum/controller/subsystem/job/proc/get_living_heads()
	. = list()
	for(var/i in GLOB.human_list)
		var/mob/living/carbon/human/player = i
		if(player.stat != DEAD && player.mind && (player.mind.assigned_role in GLOB.command_positions))
			. |= player.mind


////////////////////////////
//Keeps track of all heads//
////////////////////////////
/datum/controller/subsystem/job/proc/get_all_heads()
	. = list()
	for(var/i in GLOB.mob_list)
		var/mob/player = i
		if(player.mind && (player.mind.assigned_role in GLOB.command_positions))
			. |= player.mind

//////////////////////////////////////////////
//Keeps track of all living security members//
//////////////////////////////////////////////
/datum/controller/subsystem/job/proc/get_living_sec()
	. = list()
	for(var/i in GLOB.human_list)
		var/mob/living/carbon/human/player = i
		if(player.stat != DEAD && player.mind && (player.mind.assigned_role in GLOB.security_positions))
			. |= player.mind

////////////////////////////////////////
//Keeps track of all  security members//
////////////////////////////////////////
/datum/controller/subsystem/job/proc/get_all_sec()
	. = list()
	for(var/i in GLOB.human_list)
		var/mob/living/carbon/human/player = i
		if(player.mind && (player.mind.assigned_role in GLOB.security_positions))
			. |= player.mind

/datum/controller/subsystem/job/proc/JobDebug(message)
	log_job_debug(message)

/// Builds a cache of job title => minds for fast knowledge population
/// Called explicitly in ticker.dm after transfer_characters() for roundstart
/// Called explicitly in populate_job_knowledge() for latejoin (after invalidation)
/datum/controller/subsystem/job/proc/build_job_minds_cache()
	if(job_minds_cache)
		return // Already built
	
	job_minds_cache = list()
	var/mind_count = 0
	
	// Build job title => list of minds mapping
	for(var/datum/mind/M in SSticker.minds)
		if(!M.assigned_role)
			continue
		
		LAZYINITLIST(job_minds_cache[M.assigned_role])
		job_minds_cache[M.assigned_role] += M
		mind_count++
	
	log_game("KNOWLEDGE CACHE: Built with [mind_count] minds, [job_minds_cache.len] unique jobs")

/// Adds a single mind to the existing job cache (for latejoin)
/datum/controller/subsystem/job/proc/add_mind_to_cache(datum/mind/M)
	if(!job_minds_cache)
		return // Cache doesn't exist, shouldn't happen
	
	if(!M || !M.assigned_role)
		return
	
	if(!job_minds_cache[M.assigned_role])
		job_minds_cache[M.assigned_role] = list()
	
	job_minds_cache[M.assigned_role] += M
	log_game("KNOWLEDGE CACHE: Added [M.assigned_role] to cache")

/// Removes a single mind from the job cache (for far travel)
/datum/controller/subsystem/job/proc/remove_mind_from_cache(datum/mind/M)
	if(!job_minds_cache)
		return
	
	if(!M || !M.assigned_role)
		return
	
	if(job_minds_cache[M.assigned_role])
		job_minds_cache[M.assigned_role] -= M
		log_game("KNOWLEDGE CACHE: Removed [M.assigned_role] from cache")

/// Invalidates the job minds cache (called when someone joins or changes job)
/datum/controller/subsystem/job/proc/invalidate_job_minds_cache()
	job_minds_cache = null
