// TGUI replacement for /mob/dead/new_player/proc/LateChoices(). Mirrors the
// classic categorized job picker (Nobles, Courtiers, Garrison, Churchmen,
// Inquisition, Yeomen, Peasants, Mercenaries, Sidefolk) including category
// colors, slot counts, priority highlighting, command-bold for noble jobs, and
// the skeleton/goblin siege special cases. Routes selection back through
// /mob/dead/new_player/Topic({SelectedJob}) so AttemptLateSpawn + all
// eligibility checks (flavortext minimum, queue, migrant block) are reused.

/// Every open LateJoinChoices ui registers here so notify_late_join_slots_changed()
/// can push fresh availability data when a player joins (current_positions++).
/// Added in ui_interact, removed in ui_close + Destroy.
GLOBAL_LIST_EMPTY(open_late_join_choices)

/datum/late_join_choices
	var/mob/dead/new_player/np
	/// Cached static_data payload (categories + per-job static fields).
	/// Built once on the first ui_static_data call (TGUI invokes this during
	/// send_full_update at window open); never invalidated mid-window
	/// because the catalog is round-stable.
	var/list/static_data_cache

/datum/late_join_choices/New(mob/dead/new_player/owner)
	. = ..()
	np = owner

/datum/late_join_choices/Destroy()
	GLOB.open_late_join_choices -= src
	np = null
	return ..()

/datum/late_join_choices/ui_state(mob/user)
	return GLOB.always_state

/datum/late_join_choices/ui_close(mob/user)
	. = ..()
	GLOB.open_late_join_choices -= src

/datum/late_join_choices/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LateJoinChoices", "Choose Class")
		// Autoupdate would re-poll availability every 0.9s for every open
		// late-join window — wasted work since slot counts only change when
		// another player actually takes a slot. Push instead via
		// notify_late_join_slots_changed() on join.
		ui.set_autoupdate(FALSE)
		ui.open()
	GLOB.open_late_join_choices |= src

/datum/late_join_choices/ui_static_data(mob/user)
	if(!static_data_cache)
		static_data_cache = build_static_data(user)
	return static_data_cache

/// Build the round-stable catalog: categories + per-job static fields.
/// The catalog is fixed for the round (job names, NOBLES membership,
/// subclass eligibility, category colors all settle at SS init). Display
/// name flips with pronouns, but pronouns rarely change mid-window — if
/// they do, the user closes & reopens the picker, naturally rebuilding.
/datum/late_join_choices/proc/build_static_data(mob/user)
	var/list/data = list()
	if(!np)
		return data

	data["siege_skeleton"] = has_world_trait(/datum/world_trait/skeleton_siege)
	data["siege_goblin"] = has_world_trait(/datum/world_trait/goblin_siege)

	// Garrison list with Veteran appended — mirrors the Class Selection
	// override. GLOB.garrison_positions stays untouched so other consumers
	// (ban subsystem, ban-checks, etc.) aren't affected.
	var/list/garrison_with_extras = GLOB.garrison_positions?.Copy() || list()
	garrison_with_extras |= "Veteran"

	// Peasants minus the Wanderer-family titles (Adventurer / Wretch /
	// Court Agent / Bandit / Gnoll / Lunatic).
	var/list/peasants_filtered = GLOB.peasant_positions?.Copy() || list()
	var/list/wanderer_titles = GLOB.prefs_menu_wanderer_titles?.Copy() || list()
	for(var/title in wanderer_titles)
		peasants_filtered -= title

	// Order matches Class Selection's column ordering: Nobles, Courtiers,
	// Garrison, Churchmen, Inquisition, Yeomen, Peasants, Sidefolk,
	// Mercenaries, Wanderers. Each entry is list(name_override, titles).
	var/list/omegalist = list(
		list(null, GLOB.noble_positions),
		list(null, GLOB.courtier_positions),
		list(null, garrison_with_extras),
		list(null, GLOB.church_positions),
		list(null, GLOB.inquisition_positions),
		list(null, GLOB.yeoman_positions),
		list(null, peasants_filtered),
		list(null, GLOB.youngfolk_positions),
		list(null, GLOB.mercenary_positions),
		list("Wanderers", wanderer_titles),
	)

	var/list/categories = list()
	for(var/list/cat_entry as anything in omegalist)
		var/name_override = cat_entry[1]
		var/list/category = cat_entry[2]
		if(!length(category) || !SSjob.name_occupations[category[1]])
			continue
		var/datum/job/cat_head = SSjob.name_occupations[category[1]]
		var/cat_name = name_override || late_join_category_name(cat_head.department_flag)
		if(!cat_name)
			continue
		var/list/job_entries = list()
		for(var/job in category)
			var/datum/job/job_datum = SSjob.name_occupations[job]
			if(!job_datum)
				continue
			// Skip slotless roles (e.g. migrant/wanderer-wave-only jobs like Pilgrim) unless they're
			// explicitly flagged to always appear on the late-join list.
			if(job_datum.total_positions <= 0 && !job_datum.always_show_on_latechoices)
				continue
			var/used_name = job_datum.title
			if(np.client?.prefs?.pronouns == SHE_HER && job_datum.f_title)
				used_name = job_datum.f_title
			job_entries += list(list(
				"title" = job_datum.title,
				"display_name" = used_name,
				"command_bold" = (job in GLOB.noble_positions),
				"has_subclass_info" = job_datum.has_limited_subclasses(),
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

/datum/late_join_choices/ui_data(mob/user)
	// Only the per-job availability state + round_duration change at runtime.
	// Returned as an assoc map keyed by job.title so React can spread it onto
	// each static catalog entry by title in one pass.
	var/list/data = list()
	if(!np)
		return data
	data["round_duration"] = DisplayTimeText(world.time - SSticker.round_start_time, 1)
	var/list/availability = list()
	var/player_pq = get_playerquality(np.ckey)
	for(var/datum/job/job_datum as anything in SSjob.occupations)
		if(!job_datum?.title)
			continue
		var/unavailable_code = np.IsJobUnavailable(job_datum.title, TRUE)
		var/is_job_available = (unavailable_code == JOB_AVAILABLE)
		var/is_cooldown = (unavailable_code == JOB_UNAVAILABLE_JOB_COOLDOWN)
		availability[job_datum.title] = list(
			"current" = job_datum.current_positions,
			"total" = job_datum.total_positions,
			"prioritized" = (job_datum in SSjob.prioritized_jobs),
			"available" = is_job_available,
			"is_cooldown" = is_cooldown,
			"unavailable_reason" = is_job_available ? null : late_join_unavailable_reason(unavailable_code, job_datum, player_pq),
		)
	data["availability"] = availability
	return data

/// Push a fresh availability ui_data to every open LateJoinChoices window.
/// Called from the late-join slot-increment hook (AttemptLateSpawn success
/// path) so picker windows update the moment another player takes a slot,
/// without polling.
/proc/notify_late_join_slots_changed()
	for(var/datum/late_join_choices/ljc as anything in GLOB.open_late_join_choices)
		SStgui.update_uis(ljc)

/// Short human-readable reason for a JOB_UNAVAILABLE_* code. Mirrors the
/// Class Selection's unavailable_reason_text — kept here as a sibling proc
/// so /datum/late_join_choices isn't coupled to /datum/preferences_menu.
/datum/late_join_choices/proc/late_join_unavailable_reason(reason, datum/job/job, pq)
	switch(reason)
		if(JOB_UNAVAILABLE_PQ)
			if(!isnull(job?.min_pq) && !isnull(pq) && pq < job.min_pq)
				return "Requires PQ [job.min_pq]"
			if(!isnull(job?.max_pq) && !isnull(pq) && pq > job.max_pq)
				return "PQ must be [job.max_pq] or below"
			return "PQ requirement"
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
