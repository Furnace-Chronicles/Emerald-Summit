// TGUI replacement for /mob/dead/new_player/proc/LateChoices(). Mirrors the
// classic categorized job picker (Nobles, Courtiers, Garrison, Churchmen,
// Inquisition, Yeomen, Peasants, Mercenaries, Sidefolk) including category
// colors, slot counts, priority highlighting, command-bold for noble jobs, and
// the skeleton/goblin siege special cases. Routes selection back through
// /mob/dead/new_player/Topic({SelectedJob}) so AttemptLateSpawn + all
// eligibility checks (flavortext minimum, queue, migrant block) are reused.

/datum/late_join_choices
	var/mob/dead/new_player/np

/datum/late_join_choices/New(mob/dead/new_player/owner)
	. = ..()
	np = owner

/datum/late_join_choices/Destroy()
	np = null
	return ..()

/datum/late_join_choices/ui_state(mob/user)
	return GLOB.always_state

/datum/late_join_choices/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LateJoinChoices", "Choose Class")
		ui.open()

/datum/late_join_choices/ui_data(mob/user)
	var/list/data = list()
	if(!np)
		return data

	data["round_duration"] = DisplayTimeText(world.time - SSticker.round_start_time, 1)
	data["siege_skeleton"] = has_world_trait(/datum/world_trait/skeleton_siege)
	data["siege_goblin"] = has_world_trait(/datum/world_trait/goblin_siege)

	// Garrison list with Veteran appended — mirrors the Class Selection
	// override. GLOB.garrison_positions stays untouched so other consumers
	// (ban subsystem, ban-checks, etc.) aren't affected.
	var/list/garrison_with_extras = GLOB.garrison_positions?.Copy() || list()
	garrison_with_extras |= "Veteran"

	// Order matches Class Selection's column ordering: Nobles, Courtiers,
	// Garrison, Churchmen, Inquisition, Yeomen, Peasants, Sidefolk,
	// Mercenaries. (Sidefolk now renders before Mercenaries.)
	var/list/omegalist = list()
	omegalist += list(GLOB.noble_positions)
	omegalist += list(GLOB.courtier_positions)
	omegalist += list(garrison_with_extras)
	omegalist += list(GLOB.church_positions)
	omegalist += list(GLOB.inquisition_positions)
	omegalist += list(GLOB.yeoman_positions)
	omegalist += list(GLOB.peasant_positions)
	omegalist += list(GLOB.youngfolk_positions)
	omegalist += list(GLOB.mercenary_positions)

	var/list/categories = list()
	for(var/list/category as anything in omegalist)
		if(!SSjob.name_occupations[category[1]])
			continue
		var/datum/job/cat_head = SSjob.name_occupations[category[1]]
		var/cat_name = late_join_category_name(cat_head.department_flag)
		if(!cat_name)
			continue
		var/list/job_entries = list()
		for(var/job in category)
			var/datum/job/job_datum = SSjob.name_occupations[job]
			if(!job_datum)
				continue
			// Show every role, even ineligible ones. Unavailable rows render
			// disabled with a short reason ("Race restriction", "Patron
			// required", etc.) so players know why they can't pick it.
			var/unavailable_code = np.IsJobUnavailable(job_datum.title, TRUE)
			var/is_job_available = (unavailable_code == JOB_AVAILABLE)
			if(job_datum.always_show_on_latechoices)
				is_job_available = TRUE
				unavailable_code = JOB_AVAILABLE
			var/used_name = job_datum.title
			if(np.client?.prefs?.pronouns == SHE_HER && job_datum.f_title)
				used_name = job_datum.f_title
			job_entries += list(list(
				"title" = job_datum.title,
				"display_name" = used_name,
				"current" = job_datum.current_positions,
				"total" = job_datum.total_positions,
				"prioritized" = (job_datum in SSjob.prioritized_jobs),
				"command_bold" = (job in GLOB.noble_positions),
				"has_subclass_info" = job_datum.has_limited_subclasses(),
				"available" = is_job_available,
				"unavailable_reason" = is_job_available ? null : late_join_unavailable_reason(unavailable_code),
			))
		if(!length(job_entries))
			continue
		categories += list(list(
			"name" = cat_name,
			"color" = cat_head.selection_color,
			"jobs" = job_entries,
		))
	data["categories"] = categories
	return data

/// Short human-readable reason for a JOB_UNAVAILABLE_* code. Mirrors the
/// Class Selection's unavailable_reason_text — kept here as a sibling proc
/// so /datum/late_join_choices isn't coupled to /datum/preferences_menu.
/datum/late_join_choices/proc/late_join_unavailable_reason(reason)
	switch(reason)
		if(JOB_UNAVAILABLE_GENERIC)
			return "Not available this round"
		if(JOB_UNAVAILABLE_BANNED)
			return "Banned"
		if(JOB_UNAVAILABLE_PLAYTIME)
			return "Playtime required"
		if(JOB_UNAVAILABLE_ACCOUNTAGE)
			return "Account too new"
		if(JOB_UNAVAILABLE_PATRON)
			return "Patron required"
		if(JOB_UNAVAILABLE_RACE)
			return "Race restriction"
		if(JOB_UNAVAILABLE_SEX)
			return "Sex restriction"
		if(JOB_UNAVAILABLE_AGE)
			return "Character age restriction"
		if(JOB_UNAVAILABLE_WTEAM)
			return "World team restriction"
		if(JOB_UNAVAILABLE_LASTCLASS)
			return "Played last round"
		if(JOB_UNAVAILABLE_JOB_COOLDOWN)
			return "Job on cooldown"
		if(JOB_UNAVAILABLE_VIRTUESVICE)
			return "Virtue/Vice restriction"
		if(JOB_UNAVAILABLE_SLOTFULL)
			return "Slots full"
	return "Unavailable"

/datum/late_join_choices/proc/late_join_category_name(department_flag)
	switch(department_flag)
		if(NOBLEMEN)
			return "Nobles"
		if(COURTIERS)
			return "Courtiers"
		if(GARRISON)
			return "Garrison"
		if(CHURCHMEN)
			return "Churchmen"
		if(YEOMEN)
			return "Yeomen"
		if(PEASANTS)
			return "Peasants"
		if(YOUNGFOLK)
			return "Sidefolk"
		if(MERCENARIES)
			return "Mercenaries"
		if(INQUISITION)
			return "Inquisition"
	return null

/datum/late_join_choices/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	if(!np)
		return

	switch(action)
		if("select_job")
			var/job_title = params["job"]
			if(!job_title)
				return TRUE
			// Reuse the new_player Topic handler — preserves every eligibility
			// check (flavortext minimum, queue, migrant block, enter_allowed,
			// active migrant) without duplication. On successful spawn,
			// close_spawn_windows() (inside create_character) closes this UI;
			// on rejection (e.g. min-flavortext), the window stays open and
			// the user can adjust + try again.
			np.Topic(null, list("SelectedJob" = job_title))
			return TRUE

		if("select_skeleton")
			np.Topic(null, list("SelectedJob" = "Besieger Skeleton"))
			return TRUE

		if("select_goblin")
			np.Topic(null, list("SelectedJob" = "Goblin"))
			return TRUE

		if("subclass_info")
			var/job_title = params["job"]
			var/datum/job/job_datum = SSjob.name_occupations[job_title]
			if(job_datum)
				job_datum.Topic(null, list("jobsubclassinfo" = "1"))
			return TRUE

/// Lazy-init wrapper so /mob/dead/new_player owns one TGUI late-join window
/// per session. Mirrors the /datum/preferences/preferences_menu pattern.
/mob/dead/new_player/proc/open_late_join_choices()
	if(!late_join_choices)
		late_join_choices = new(src)
	late_join_choices.ui_interact(src)
