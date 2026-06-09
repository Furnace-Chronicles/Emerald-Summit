// TGUI character-creation menu. Backed by /datum/preferences; mutates the same prefs
// vars as the classic /datum/preferences/Topic handlers. Savefile schema stays untouched.
// Reference pattern: /obj/structure/roguemachine/bathvend (Brassface).

// One source of truth for the collapsed "Wanderer" family. Used by the lobby
// snapshot's ready-by-job bucketing AND by Class Selection's category mapping.
GLOBAL_LIST_INIT(prefs_menu_wanderer_titles, list("Adventurer", "Wretch", "Court Agent", "Bandit", "Gnoll", "Lunatic"))

/datum/preferences_menu
	var/datum/preferences/prefs
	var/active_tab = "identity"
	/// Set by on_identity_change when the preview needs re-rendering.
	/// refresh_preview() composes a dummy mob and flattens an icon — heavy
	/// CPU work, so we debounce to once per ~0.5s burst instead of once per act.
	var/preview_dirty = FALSE
	/// Per-session cache of the immutable job gates (ban/playtime/agedays/PQ).
	/// Keyed by job.title. Built lazily on the first ui_data poll touching a
	/// given job; lifetime is the lifetime of this menu datum. See build_job_entry.
	var/list/cached_job_gates
	/// Per-session cache of the donator-filtered loadout item names. Donator
	/// status is per-user but stable for the menu's lifetime — cached on the
	/// datum rather than at module scope. Cleared if a triumph buy changes
	/// donator state (not currently a thing, but the hook is here if needed).
	var/list/cached_loadout_item_options
	/// Slot id (int) → display name (string). Built once from the savefile on
	/// window open; refreshed targeted-style on save_character so the dropdown
	/// reflects the freshly saved name without resending the full static payload.
	var/list/cached_slot_names
	/// The fully-assembled slot dropdown payload — `list(list("id" = N, "name" = ...), ...)`.
	/// Built once from cached_slot_names and reused on every ui_data poll so
	/// the 2s lobby tick doesn't re-allocate a 40-element list + 40 nested
	/// dicts each push. Nulled by save_character / change_slot / load_character
	/// so the next poll rebuilds against fresh names.
	var/list/cached_slot_options
	/// Job.title of the class whose full-details HTML the user requested via
	/// the Class Selection tutorial view. Cleared when they leave the view.
	var/active_class_explain_title
	/// HTML payload shipped to the React side and rendered via
	/// dangerouslySetInnerHTML directly below the tutorial blurb. Built by
	/// /datum/job/proc/build_class_explain_html() on demand.
	var/active_class_explain_html
	/// Cached ui_static_data payload — built once on the first ui_static_data
	/// call (which TGUI only invokes during send_full_update), reused forever
	/// until refresh_static_data() nulls it. Holds every option list and other
	/// session-stable data the React side renders, so partial pushes (lobby
	/// tick, on_identity_change) only carry the small ui_data delta.
	var/list/static_data_cache

/datum/preferences_menu/New(datum/preferences/owning_prefs)
	. = ..()
	prefs = owning_prefs

/datum/preferences_menu/Destroy()
	GLOB.open_preference_menus -= src
	prefs = null
	return ..()

/datum/preferences_menu/ui_close(mob/user)
	. = ..()
	GLOB.open_preference_menus -= src
	// Window closed — drop any owed preview work (no one to see it). In-memory
	// edits without an explicit Save click are intentionally discarded to
	// match the classic browser UI's "Save / Undo / nothing" semantics.
	preview_dirty = FALSE
	// The main menu is the only lobby UI a new_player has, and a new player may not know
	// how to reopen it. If they close it, force it back open after 10 seconds — at the
	// pregame title screen as well as for mid-round latejoiners. Once the round has ENDED,
	// let it stay closed (nothing left to join).
	if(isnewplayer(user) && SSticker.current_state < GAME_STATE_FINISHED)
		addtimer(CALLBACK(src, PROC_REF(reopen_main_menu), user), 10 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)

/datum/preferences_menu/proc/reopen_main_menu(mob/user)
	// Re-validate at fire time — user may have spawned in or disconnected
	// during the grace window. Only reopen if they're still a new_player
	// and we still have a live prefs link.
	if(!prefs || !user || !user.client)
		return
	if(!isnewplayer(user))
		return
	// Round ended during the grace window — don't pop it back open.
	if(SSticker.current_state >= GAME_STATE_FINISHED)
		return
	// Respect the Classic UI escape hatch — if the user toggled tgui_pref off
	// (which itself closes the TGUI window via SStgui.close_uis → ui_close →
	// this very timer), don't pop the TGUI back open on top of the classic
	// browser window.
	if(!prefs.tgui_pref)
		return
	ui_interact(user)

/datum/preferences_menu/ui_state(mob/user)
	return GLOB.always_state

/// Every open preferences_menu registers here so notify_preference_menus_lobby_changed()
/// can fan-out slim {lobby, header} pushes on actual events (ready toggles, round
/// transitions). Replaces the prior per-menu 2s addtimer chain, which under load
/// was firing at ~750 Hz and saturating the MC with timedevent allocations.
GLOBAL_LIST_EMPTY(open_preference_menus)

/datum/preferences_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PreferencesMenu", "Emerald Summit")
		// Autoupdate would call ui_interact every 0.9s (SStgui wait=9ds) and
		// rebuild the full ui_data payload. All option lists live in
		// ui_static_data (loaded once per window open) and every mutation
		// pushes via on_identity_change → SStgui.update_uis(src), so the
		// timer-driven path isn't needed.
		ui.set_autoupdate(FALSE)
		ui.open()
	// Register with the broadcast list. The countdown counts down locally
	// via React's setInterval, so the server doesn't need to push every 2s —
	// only when something actually changes (someone readies, round starts).
	GLOB.open_preference_menus |= src

/// Fan-out a slim {lobby, header} push to every open preferences_menu. Called
/// when global lobby state actually changes — a player toggling ready, the
/// round transitioning, etc. Invalidates the shared snapshot first so the
/// next build sees the change.
/proc/notify_preference_menus_lobby_changed()
	GLOB.cached_lobby_snapshot = list()
	GLOB.cached_lobby_snapshot_at = 0
	for(var/datum/preferences_menu/menu as anything in GLOB.open_preference_menus)
		if(!menu?.prefs)
			continue
		var/datum/tgui/open_ui = SStgui.get_open_ui(menu.prefs.parent?.mob, menu)
		if(!open_ui)
			continue
		// Round started and the player's mob is no longer a new_player — they
		// were readied and got spawned in. Close the window so it doesn't
		// linger over the game view. Latejoiners (still new_player) keep it.
		if(SSticker.HasRoundStarted() && !isnewplayer(menu.prefs.parent?.mob))
			SStgui.close_uis(menu)
			continue
		open_ui.send_update(list(
			"lobby" = menu.build_lobby_data(),
			"header" = menu.build_header_data(menu.prefs.parent?.mob),
		))

/datum/preferences_menu/proc/build_slot_options()
	// Read each slot's stored real_name from disk once, cache it, and serve
	// every subsequent poll from cache. save_character / change_slot /
	// load_character invalidate cached_slot_options (the assembled list) so
	// the next poll picks up the fresh name.
	if(cached_slot_options)
		return cached_slot_options

	if(!cached_slot_names)
		cached_slot_names = list()
		var/max_slots = prefs?.max_save_slots || 40
		var/savefile/S
		if(prefs?.path)
			S = new /savefile(prefs.path)
		for(var/i = 1, i <= max_slots, i++)
			var/slot_name
			if(S)
				S.cd = "/character[i]"
				S["real_name"] >> slot_name
			if(!slot_name)
				slot_name = "Slot [i]"
			cached_slot_names["[i]"] = slot_name

	cached_slot_options = list()
	var/max_slots = prefs?.max_save_slots || 40
	for(var/i = 1, i <= max_slots, i++)
		cached_slot_options += list(list("id" = i, "name" = cached_slot_names["[i]"] || "Slot [i]"))
	return cached_slot_options

/datum/preferences_menu/ui_static_data(mob/user)
	// TGUI only invokes ui_static_data during send_full_update (window open
	// or explicit refresh). Cache the entire payload on the datum so even
	// that one rebuild is amortized across the menu lifetime, and so
	// refresh_static_data() can null + rebuild atomically.
	if(!static_data_cache)
		static_data_cache = build_full_static_data(user)
	return static_data_cache

/// Rebuilds the entire static_data payload from scratch. Called lazily by
/// ui_static_data and re-called after refresh_static_data() nulls the cache
/// (e.g. when the user changes species/origin/faith/patron and the dependent
/// option lists become stale).
/datum/preferences_menu/proc/build_full_static_data(mob/user)
	var/list/data = list()

	// Always-static globals (never change at runtime).
	data["pronoun_options"] = GLOB.pronouns_list?.Copy() || list()
	data["voice_type_options"] = GLOB.voice_types_list?.Copy() || list()
	var/list/voice_packs = list()
	for(var/vp_name in GLOB.voice_packs_list)
		voice_packs += vp_name
	data["voice_pack_options"] = voice_packs
	var/list/statpacks = list()
	for(var/path as anything in GLOB.statpacks)
		var/datum/statpack/sp = GLOB.statpacks[path]
		if(!sp?.name)
			continue
		statpacks += list(list(
			"name" = sp.name,
			"desc" = sp.description_string(),
		))
	data["statpack_options"] = statpacks

	if(!prefs)
		return data

	// Per-tab static option blocks. Each is keyed by `<tab>_static` so the
	// React side can spread it alongside the dynamic `<tab>` block via
	// `{...data.identity_static, ...data.identity}`.
	data["identity_static"] = build_identity_static(user)
	data["culinary_static"] = build_culinary_static(user)
	data["body_static"] = build_body_static(user)
	data["markings_static"] = build_markings_static(user)
	data["descriptors_static"] = build_descriptors_static(user)
	data["customizers_static"] = build_customizers_static(user)
	data["loadout_static"] = build_loadout_static(user)
	data["jobs_static"] = build_jobs_static(user)
	data["keybinds_static"] = build_keybinds_static(user)
	data["familiar_static"] = build_familiar_static(user)
	data["gnoll_static"] = build_gnoll_static(user)
	data["game_prefs_static"] = build_game_prefs_static(user)

	return data

/// Build the header block. Shared by ui_data (full pushes) and the event-
/// driven notify_preference_menus_lobby_changed() broadcast. Cheap enough —
/// no list walks of any size — so we can rebuild it freely.
/datum/preferences_menu/proc/build_header_data(mob/user)
	if(!prefs)
		return list()
	var/pq_num = get_playerquality(user.ckey)
	var/list/pq_label = pq_tier_label(pq_num)
	var/mob/dead/new_player/np = user
	var/is_np = istype(np)
	return list(
		"real_name" = prefs.real_name,
		"triumphs" = user.get_triumphs(),
		"triumphs_roman" = user.get_triumphs() ? "\Roman[user.get_triumphs()]" : "None",
		"pq_text" = pq_label["text"],
		"pq_color" = pq_label["color"],
		"agevetted" = user.check_agevet(),
		"triumph_buys_enabled" = SStriumphs.triumph_buys_enabled,
		// Lobby / round-state flags driving the footer action bar.
		"is_new_player" = is_np,
		"is_pregame" = (SSticker.current_state <= GAME_STATE_PREGAME),
		"is_round_in_progress" = SSticker?.IsRoundInProgress(),
		"player_ready" = is_np ? (np.ready == PLAYER_READY_TO_PLAY) : FALSE,
		"is_active_migrant" = prefs.is_active_migrant(),
		"job_change_locked" = SSticker.job_change_locked,
		"is_guest" = IsGuestKey(user.key),
		"current_slot" = prefs.default_slot,
		"max_save_slots" = prefs.max_save_slots,
		"tgui_theme_name" = prefs.get_tgui_theme_display_name(),
		// Null when ready-up is allowed; non-null reason string disables the
		// Ready button on the React side and shows the reason as its tooltip.
		"ready_block_reason" = compute_ready_block_reason(),
	)

/// TRUE if at least one job in prefs.job_preferences has any priority set
/// (LOW/MEDIUM/HIGH). Absent / 0 / null all count as "never". Used by the
/// ready-up gate so RETURNTOLOBBY players can't ready with nothing picked.
/datum/preferences_menu/proc/has_any_class_selected()
	if(!prefs?.job_preferences)
		return FALSE
	for(var/title in prefs.job_preferences)
		if(prefs.job_preferences[title])
			return TRUE
	return FALSE

/// Returns a player-facing reason the Ready button must be blocked, or null
/// when ready-up is allowed. Same checks both ui_act (toggle_ready) and the
/// header data (so React can disable the button + show the reason in a
/// tooltip) — single source of truth.
///
/// joblessrole=BERANDOMJOB is an explicit opt-in to "any role", so we don't
/// require a class selection in that case. RETURNTOLOBBY without any class
/// selected is a no-op ready (player would just be rejected at round-start),
/// so we block it.
/datum/preferences_menu/proc/compute_ready_block_reason()
	if(!prefs)
		return null
	if(length(prefs.flavortext) < MINIMUM_FLAVOR_TEXT)
		return "Flavor text too short ([length(prefs.flavortext)]/[MINIMUM_FLAVOR_TEXT] characters)."
	if(length(prefs.ooc_notes) < MINIMUM_OOC_NOTES)
		return "OOC notes too short ([length(prefs.ooc_notes)]/[MINIMUM_OOC_NOTES] characters)."
	if(prefs.joblessrole == RETURNTOLOBBY && !has_any_class_selected())
		return "Pick at least one class in Class Selection (or set 'If Role Unavailable' to Random)."
	return null

/// Drop the cached static payload and push a full_update to every open ui on
/// this menu so the React side picks up the rebuilt option lists. Called from
/// ui_act branches whose mutations invalidate one or more option blocks (set
/// species/subspecies/origin/faith/patron/statpack/virtue/charflaw/age/pronouns,
/// randomize_all, load_character, change_slot). Cheap when no ui is open.
/datum/preferences_menu/proc/refresh_static_data()
	static_data_cache = null
	// cached_job_gates (ckey/PQ-only) and cached_loadout_item_options
	// (donator-only) are both ckey-stable, so they survive across these
	// refreshes — only species/origin/etc-dependent caches go in the parent
	// static_data_cache that's nulled above.
	for(var/datum/tgui/ui as anything in open_uis)
		ui.send_full_update()

/datum/preferences_menu/ui_data(mob/user)
	var/list/data = list()
	data["active_tab"] = active_tab
	if(!prefs)
		return data

	// Slot picker is in ui_data (not ui_static_data) so save/load/change_slot
	// can update the dropdown without resending the full static payload.
	data["slots"] = build_slot_options()

	data["header"] = build_header_data(user)

	data["lobby"] = build_lobby_data()

	// Per-tab gating: only build the active tab's DYNAMIC payload (current
	// selections / state). Option lists live in ui_static_data — see
	// build_full_static_data — so they're not rebuilt or reshipped on the
	// per-mutation push or the 2s lobby tick.
	var/static/list/known_tabs = list("identity", "features", "loadout", "jobs", "flavor", "gamepref", "oocpref", "keybinds", "familiar", "gnoll")
	if(!(active_tab in known_tabs))
		active_tab = "identity"
	switch(active_tab)
		if("identity")
			data["identity"] = build_identity_dynamic(user)
			data["culinary"] = build_culinary_dynamic(user)
		if("features")
			data["body"] = build_body_dynamic(user)
			data["markings"] = build_markings_dynamic(user)
			data["descriptors"] = build_descriptors_dynamic(user)
			data["customizers"] = build_customizers_dynamic(user)
		if("loadout")
			data["loadout"] = build_loadout_dynamic(user)
		if("jobs")
			data["jobs"] = build_jobs_dynamic(user)
		if("flavor")
			data["flavor"] = build_flavor_data(user)
		if("gamepref")
			// Combined view in the React side: GamePrefsTab stacked above OocPrefsTab.
			data["game_prefs"] = build_game_prefs_dynamic(user)
			data["ooc_prefs"] = build_ooc_prefs_data(user)
		if("oocpref")
			data["ooc_prefs"] = build_ooc_prefs_data(user)
		if("keybinds")
			data["keybinds"] = build_keybinds_dynamic(user)
		if("familiar")
			data["familiar"] = build_familiar_dynamic(user)
		if("gnoll")
			data["gnoll"] = build_gnoll_dynamic(user)
	return data

/// DYNAMIC half of the identity tab: current selections only. Built per
/// ui_data push. Pairs with build_identity_static (option lists) which only
/// rebuilds when the user picks a new species/origin/faith/patron/etc.
/datum/preferences_menu/proc/build_identity_dynamic(mob/user)
	var/list/id = list()
	id["real_name"] = prefs.real_name
	id["name_is_banned"] = check_nameban(user.ckey)
	id["appearance_banned"] = is_banned_from(user.ckey, "Appearance")
	id["nickname"] = prefs.nickname
	id["pronouns"] = prefs.pronouns
	id["voice_type"] = prefs.voice_type
	id["voice_pack"] = prefs.voice_pack || "Default"
	id["age"] = prefs.age

	id["species_name"] = prefs.pref_species?.base_name
	id["subspecies_name"] = prefs.pref_species?.sub_name
	id["species_psydonic"] = prefs.pref_species?.psydonic
	id["species_use_titles"] = prefs.pref_species?.use_titles
	id["selected_title"] = prefs.selected_title || "None"
	id["has_subspecies_options"] = count_other_subspecies(prefs.pref_species) > 0

	id["origin_name"] = prefs.virtue_origin ? "[prefs.virtue_origin]" : "None"
	id["origin_gives_language"] = prefs.virtue_origin?.extra_language

	id["statpack_name"] = prefs.statpack?.name
	id["statpack_label"] = prefs.statpack ? statpack_dropdown_label(prefs.statpack) : null
	id["virtue_name"] = prefs.virtue ? "[prefs.virtue]" : "None"
	id["virtuetwo_name"] = prefs.virtuetwo ? "[prefs.virtuetwo]" : "None"
	id["show_virtuetwo"] = (prefs.statpack?.name == "Virtuous")
	id["charflaw_name"] = prefs.charflaw ? "[prefs.charflaw]" : "None"

	var/datum/faith/faith = GLOB.faithlist[prefs.selected_patron?.associated_faith]
	id["faith_name"] = faith?.name
	id["patron_name"] = prefs.selected_patron?.name

	id["domhand"] = prefs.domhand
	id["dnr_pref"] = prefs.dnr_pref

	id["combat_music_name"] = prefs.combat_music?.shortname || prefs.combat_music?.name

	// Family system (only meaningful when agevetted)
	id["agevetted"] = user.check_agevet()
	id["family"] = prefs.family
	id["setspouse"] = prefs.setspouse
	id["gender_choice"] = prefs.gender_choice
	id["xenophobe_pref"] = prefs.xenophobe_pref
	id["xenophobe_label"] = (prefs.xenophobe_pref == 1) ? "Race only" : (prefs.xenophobe_pref == 2) ? "Subrace only" : "Unrestricted"

	// Body type / gender (only when species is not AGENDER)
	id["gender"] = prefs.gender
	id["agender_species"] = (AGENDER in prefs.pref_species?.species_traits)

	// Extra language — display "None" when origin doesn't grant the slot,
	// even if a stale value is stored (preserved in case origin swaps back).
	if(!prefs.virtue_origin?.extra_language)
		id["extra_language_name"] = "None"
	else if(ispath(prefs.extra_language, /datum/language))
		var/datum/language/L = prefs.extra_language
		id["extra_language_name"] = initial(L.name)
	else
		id["extra_language_name"] = "None"

	// Tail (only when LAMIAN_TAIL species trait)
	id["has_lamian_tail"] = (LAMIAN_TAIL in prefs.pref_species?.species_traits)
	if(id["has_lamian_tail"])
		var/obj/item/bodypart/lamian_tail/T = prefs.tail_type
		id["tail_type_name"] = ispath(T) ? T::name : "None"
		id["tail_color"] = prefs.tail_color
		id["tail_markings_color"] = prefs.tail_markings_color

	return id

/// STATIC half of the identity tab: every dropdown option list. Rebuilt only
/// when refresh_static_data() is called (set_species, set_origin, set_faith,
/// set_patron, set_statpack, set_pronouns, set_age, etc.). Shipped to the
/// React side once per window open via ui_static_data and persisted in the
/// backend reducer until the next full_update.
/datum/preferences_menu/proc/build_identity_static(mob/user)
	var/list/id = list()
	id["age_options"] = prefs.pref_species ? prefs.pref_species.possible_ages?.Copy() : list()
	id["species_options"] = build_species_options(user)
	id["subspecies_options"] = build_subspecies_options()
	id["origin_options"] = build_origin_options()
	id["race_title_options"] = build_race_title_options()
	id["statpack_options"] = build_statpack_options()
	id["extra_language_options"] = build_extra_language_options()
	id["virtue_options"] = build_virtue_options(user)
	id["charflaw_options"] = build_charflaw_options()
	id["faith_options"] = build_faith_options()
	id["patron_options"] = build_patron_options()
	id["combat_music_options"] = build_combat_music_options()
	id["family_options"] = build_family_options()
	id["gender_choice_options"] = list(ANY_GENDER, SAME_GENDER, DIFFERENT_GENDER)
	id["xenophobe_options"] = list("Unrestricted", "Race only", "Subrace only")
	id["tail_type_options"] = build_tail_type_options()
	return id

/datum/preferences_menu/proc/build_family_options()
	var/list/options = list(FAMILY_NONE, FAMILY_PARTIAL, FAMILY_NEWLYWED)
	if(prefs.age != AGE_ADULT)
		options += FAMILY_FULL
	return options

/datum/preferences_menu/proc/build_tail_type_options()
	var/list/names = list()
	if(!(LAMIAN_TAIL in prefs.pref_species?.species_traits))
		return names
	var/list/species_tail_list = prefs.pref_species.get_tail_list()
	for(var/obj/item/bodypart/lamian_tail/tt as anything in species_tail_list)
		names += tt::name
	return names

/datum/preferences_menu/proc/build_virtue_options(mob/user)
	var/list/names = list()
	for(var/key in build_virtue_picker_list(user, FALSE))
		names += key
	return names

/datum/preferences_menu/proc/build_charflaw_options()
	// GLOB.character_flaws is populated once and never mutates at runtime —
	// keep the sorted name list as a module-scope static so ui_data isn't
	// re-walking and re-sorting it on every poll.
	var/static/list/cached_options
	if(!cached_options)
		var/list/names = list()
		for(var/key in GLOB.character_flaws)
			names += key
		cached_options = sortList(names)
	return cached_options

/datum/preferences_menu/proc/build_faith_options()
	var/list/names = list()
	if(prefs.virtue_origin?.uniquefaith)
		for(var/path as anything in prefs.virtue_origin.uniquefaith)
			var/datum/faith/faith = GLOB.faithlist[path]
			if(!faith?.name)
				continue
			names += faith.name
	else
		for(var/path as anything in GLOB.preference_faiths)
			var/datum/faith/faith = GLOB.faithlist[path]
			if(!faith?.name)
				continue
			names += faith.name
	return sortList(names)

/datum/preferences_menu/proc/build_patron_options()
	var/list/names = list()
	var/faith_key = prefs.selected_patron?.associated_faith
	if(!faith_key)
		return names
	for(var/path as anything in GLOB.patrons_by_faith[faith_key])
		var/datum/patron/patron = GLOB.patronlist[path]
		if(!patron?.name)
			continue
		names += patron.name
	return sortList(names)

/datum/preferences_menu/proc/build_combat_music_options()
	// GLOB.cmode_tracks_by_name is populated once at SS init and never
	// mutates — cache the sorted keylist statically so ui_data isn't
	// re-walking ~100 tracks and re-sorting on every 1 Hz poll.
	var/static/list/cached_options
	if(!cached_options)
		cached_options = list()
		for(var/key in GLOB.cmode_tracks_by_name)
			cached_options += key
		cached_options = sortList(cached_options)
	return cached_options

/datum/preferences_menu/proc/build_species_options(mob/user)
	var/list/names = list()
	if(!user.client)
		return names
	for(var/A in GLOB.roundstart_races)
		var/datum/species/race = GLOB.species_list[A]
		race = new race()
		if(race.patreon_req > user.client.patreonlevel())
			continue
		if(race.is_subrace == TRUE)
			continue
		if(race.base_name == prefs.pref_species?.base_name)
			continue
		if(!(race.base_name in names))
			names += race.base_name
	return names

/datum/preferences_menu/proc/build_subspecies_options()
	var/list/names = list()
	for(var/A in GLOB.roundstart_races)
		var/datum/species/race = GLOB.species_list[A]
		race = new race()
		if(race.base_name != prefs.pref_species?.base_name)
			continue
		if(race.sub_name == prefs.pref_species?.sub_name)
			continue
		if(!(race.sub_name in names))
			names += race.sub_name
	return names

/datum/preferences_menu/proc/build_origin_options()
	var/list/names = list()
	for(var/path as anything in GLOB.virtues)
		var/datum/virtue/V = GLOB.virtues[path]
		if(!V?.name)
			continue
		if(prefs.virtue_origin && V.name == prefs.virtue_origin.name)
			continue
		if(!istype(V, /datum/virtue/origin))
			continue
		if(V.restricted && (prefs.pref_species?.type in V.races))
			continue
		if(istype(V, /datum/virtue/origin/racial) && !(prefs.pref_species?.type in V.races))
			continue
		names += V.name
	return names

/datum/preferences_menu/proc/build_race_title_options()
	var/list/names = list("None")
	if(!prefs.pref_species?.use_titles)
		return names
	for(var/title in prefs.pref_species.race_titles)
		if(title in names)
			continue
		names += title
	return names

/datum/preferences_menu/proc/build_statpack_options()
	// Statpack list is loaded at SS init and never mutates at runtime; the
	// labels embed generate_modifier_string output which is non-trivial to
	// rebuild per poll. Cache the labels keyed by pack name + a sorted name
	// list, then drop the currently-selected pack by exact name match — the
	// previous prefix-match approach would have silently dropped any pack
	// whose name shared a prefix with the selected one (e.g. "Hardy" filter
	// would also have removed a future "Hardy Veteran").
	var/static/list/cached_label_for_name
	var/static/list/cached_sorted_names
	if(!cached_sorted_names)
		cached_label_for_name = list()
		var/list/labels_for_sort = list()
		for(var/path as anything in GLOB.statpacks)
			var/datum/statpack/sp = GLOB.statpacks[path]
			if(!sp?.name)
				continue
			cached_label_for_name[sp.name] = statpack_dropdown_label(sp)
			labels_for_sort[statpack_dropdown_label(sp)] = sp.name
		// Sort by label so the dropdown order matches the visible text.
		var/list/sorted_labels = sortList(labels_for_sort)
		cached_sorted_names = list()
		for(var/label in sorted_labels)
			cached_sorted_names += labels_for_sort[label]
	var/selected_name = prefs.statpack?.name
	var/list/out = list()
	for(var/name in cached_sorted_names)
		if(name == selected_name)
			continue
		out += cached_label_for_name[name]
	return out

/// Dropdown label for a statpack: name + auto-generated stat modifier blurb,
/// e.g. "Trained (+1 STR, +1 CON, +1 END, -1 PER, -1 INT)". Used by both the
/// option list and the current-selection display so the picker text matches
/// what set_statpack_direct resolves back to.
///
/// Statpack datums are init-once singletons (GLOB.statpacks), and both name
/// and the generated modifier string are stable per statpack. The profile
/// flagged this as ~2.5s self CPU across 139K calls — memoize by sp ref so
/// each unique statpack is formatted exactly once for the lifetime of the
/// process.
/datum/preferences_menu/proc/statpack_dropdown_label(datum/statpack/sp)
	var/static/list/cached_labels
	if(!cached_labels)
		cached_labels = list()
	var/cached = cached_labels[sp]
	if(cached)
		return cached
	var/blurb = sp.generate_modifier_string()
	var/label = blurb ? "[sp.name] [blurb]" : sp.name
	cached_labels[sp] = label
	return label

/datum/preferences_menu/proc/build_extra_language_options()
	var/list/names = list()
	if(!prefs.virtue_origin?.extra_language)
		return names
	var/static/list/selectable_languages = list(
		/datum/language/grenzelhoftian,
		/datum/language/etruscan,
		/datum/language/gronnic,
		/datum/language/kazengunese,
		/datum/language/aavnic,
		/datum/language/celestial,
		/datum/language/otavan,
	)
	names += "None"
	for(var/language in selectable_languages)
		if(language in prefs.pref_species?.languages)
			continue
		var/datum/language/a_language = new language()
		names += a_language.name
	return names

/// DYNAMIC half of the body section. Current selections + boolean trait flags
/// that drive which controls render. The trait flags actually depend on
/// species, so technically static, but they're a handful of cheap bools — not
/// worth the ceremony of moving them. Skin tone + accent + size + voice
/// option lists live in build_body_static.
/datum/preferences_menu/proc/build_body_dynamic(mob/user)
	var/list/body = list()
	var/list/traits = prefs.pref_species?.species_traits

	body["use_skintones"] = prefs.pref_species?.use_skintones
	body["skin_tone_wording"] = prefs.pref_species?.skin_tone_wording
	body["species_id"] = prefs.pref_species?.id
	body["has_lamian_tail"] = (LAMIAN_TAIL in traits)
	body["has_harpy"] = (HARPY in traits)
	body["has_mutcolors"] = (MUTCOLORS in traits) || (MUTCOLORS_PARTSONLY in traits)

	body["skin_tone"] = prefs.skin_tone
	body["skin_tone_name"] = lookup_skin_tone_name(prefs.skin_tone)
	body["update_mutant_colors"] = prefs.update_mutant_colors

	body["mcolor"] = prefs.features?["mcolor"]
	body["mcolor2"] = prefs.features?["mcolor2"]
	body["mcolor3"] = prefs.features?["mcolor3"]

	body["voice_color"] = prefs.voice_color
	body["highlight_color"] = prefs.highlight_color
	body["voice_pitch"] = prefs.voice_pitch
	body["char_accent"] = prefs.char_accent
	body["body_size_pct"] = round((prefs.features?["body_size"] || BODY_SIZE_NORMAL) * 100, 1)
	body["body_size_locked"] = ((prefs.statpack?.name == "Virtuous" && istype(prefs.virtuetwo, /datum/virtue/size)) || istype(prefs.virtue, /datum/virtue/size))

	return body

/datum/preferences_menu/proc/build_body_static(mob/user)
	var/list/body = list()
	var/list/skin_tone_names = list()
	if(prefs.pref_species?.use_skintones)
		for(var/k in prefs.pref_species.get_skin_list())
			skin_tone_names += k
	body["skin_tone_options"] = skin_tone_names
	var/list/accent_names = list()
	for(var/k in GLOB.character_accents)
		accent_names += k
	body["accent_options"] = accent_names
	body["voice_pitch_min"] = MIN_VOICE_PITCH
	body["voice_pitch_max"] = MAX_VOICE_PITCH
	body["body_size_min_pct"] = round(BODY_SIZE_MIN * 100, 1)
	body["body_size_max_pct"] = round(BODY_SIZE_MAX * 100, 1)
	return body

/// DYNAMIC half of markings: per-zone CURRENT marking list (order matters,
/// changes on add/remove/move). The species-keyed candidate pool lives in
/// build_markings_static.
/datum/preferences_menu/proc/build_markings_dynamic(mob/user)
	var/list/data = list()
	var/list/zones_out = list()
	for(var/zone in GLOB.marking_zones)
		var/list/marking_list = prefs.body_markings?[zone]
		var/list/markings_out = list()
		if(islist(marking_list))
			var/total = length(marking_list)
			var/i = 0
			for(var/key in marking_list)
				i++
				markings_out += list(list(
					"name" = key,
					"color" = marking_list[key],
					"index" = i,
					"can_move_up" = (i > 1),
					"can_move_down" = (i < total),
				))
		zones_out += list(list(
			"key" = zone,
			"markings" = markings_out,
		))
	data["zones"] = zones_out
	return data

/datum/preferences_menu/proc/build_markings_static(mob/user)
	var/list/data = list()
	data["max_per_limb"] = MAXIMUM_MARKINGS_PER_LIMB
	data["has_presets"] = length(marking_sets_for_species(prefs.pref_species)) > 0

	// Whether ANY zone has candidates for this species. Gates the section.
	var/species_has_any_markings = FALSE
	for(var/zone in GLOB.marking_zones)
		if(length(marking_list_of_zone_for_species(zone, prefs.pref_species)))
			species_has_any_markings = TRUE
			break
	data["species_has_no_markings"] = !species_has_any_markings

	// Per-zone candidate pool (full set, NOT filtered against current
	// selections — React subtracts what's already picked at render time).
	// Stable per species so this only rebuilds on set_species/set_subspecies.
	var/list/zones_out = list()
	for(var/zone in GLOB.marking_zones)
		var/list/all_candidates = marking_list_of_zone_for_species(zone, prefs.pref_species)
		var/list/available_names = list()
		for(var/cand_name in all_candidates)
			available_names += cand_name
		zones_out += list(list(
			"key" = zone,
			"label" = zone_label(zone),
			"all_candidates" = available_names,
		))
	data["zones"] = zones_out
	return data

/// DYNAMIC half of descriptors: per-choice current selection + the custom
/// text content. Option name lists live in build_descriptors_static.
/datum/preferences_menu/proc/build_descriptors_dynamic(mob/user)
	var/list/data = list()
	prefs.validate_descriptors()

	var/list/entries_out = list()
	for(var/choice_type in prefs.pref_species?.descriptor_choices)
		var/datum/descriptor_entry/entry = prefs.get_descriptor_entry_for_choice(choice_type)
		var/datum/mob_descriptor/descriptor = MOB_DESCRIPTOR(entry?.descriptor_type)
		entries_out += list(list(
			"choice_type" = "[choice_type]",
			"current_name" = descriptor?.name,
		))
	data["entries"] = entries_out

	var/static/list/prefix_translation = CUSTOM_PREFIX_TRANSLATION_LIST
	var/list/custom_out = list()
	for(var/i in 1 to CUSTOM_DESCRIPTOR_AMOUNT)
		var/unlocked = FALSE
		if(i == 1)
			unlocked = prefs.has_descriptor_type_in_entries(/datum/mob_descriptor/prominent/custom/one)
		else if(i == 2)
			unlocked = prefs.has_descriptor_type_in_entries(/datum/mob_descriptor/prominent/custom/two)
		if(!unlocked)
			continue
		if(length(prefs.custom_descriptors) < i)
			continue
		var/datum/custom_descriptor_entry/custom_entry = prefs.custom_descriptors[i]
		custom_out += list(list(
			"index" = i,
			"prefix_text" = prefix_translation["[custom_entry.prefix_type]"],
			"content_text" = custom_entry.content_text,
		))
	data["custom_entries"] = custom_out
	return data

/datum/preferences_menu/proc/build_descriptors_static(mob/user)
	var/list/data = list()
	var/list/entries_out = list()
	for(var/choice_type in prefs.pref_species?.descriptor_choices)
		var/datum/descriptor_choice/choice = DESCRIPTOR_CHOICE(choice_type)
		var/list/option_names = list()
		if(choice)
			for(var/desc_type in choice.descriptors)
				var/datum/mob_descriptor/d = MOB_DESCRIPTOR(desc_type)
				if(d?.name)
					option_names += d.name
		entries_out += list(list(
			"choice_type" = "[choice_type]",
			"choice_name" = choice?.name,
			"options" = option_names,
		))
	data["entries"] = entries_out
	data["max_content_length"] = CUSTOM_DESCRIPTOR_TEXT_LENGTH
	return data

/// DYNAMIC half of customizers: per-entry current state (which choice is
/// selected, disabled flag, current pref_data values like hair color/style).
/// The available choice list per customizer + the accessory options lists
/// live in build_customizers_static.
///
/// Note: pref_data values DO change on every customizer interaction (color
/// pick, rotate hair style). The accessory_name list shipped INSIDE pref_data
/// rotate entries is stable per choice; we strip it here and ship it in the
/// static block to avoid re-shipping ~250 hair names on every mutation.
/datum/preferences_menu/proc/build_customizers_dynamic(mob/user)
	var/list/data = list()
	var/list/entries_out = list()
	for(var/customizer_type in prefs.pref_species?.customizers)
		var/datum/customizer/customizer = CUSTOMIZER(customizer_type)
		if(!customizer?.is_allowed(prefs))
			continue
		var/datum/customizer_entry/entry = prefs.get_customizer_entry_for_customizer_type(customizer_type)
		if(!entry)
			continue
		var/datum/customizer_choice/choice = CUSTOMIZER_CHOICE(entry.customizer_choice_type)
		var/list/pref_data = list()
		if(!entry.disabled && choice)
			pref_data = choice.get_pref_data(prefs, entry)
		entries_out += list(list(
			"customizer_type" = "[customizer_type]",
			"disabled" = entry.disabled,
			"choice_name" = choice?.name,
			"pref_data" = pref_data,
		))
	data["entries"] = entries_out
	return data

/datum/preferences_menu/proc/build_customizers_static(mob/user)
	var/list/data = list()
	var/list/entries_out = list()
	for(var/customizer_type in prefs.pref_species?.customizers)
		var/datum/customizer/customizer = CUSTOMIZER(customizer_type)
		if(!customizer?.is_allowed(prefs))
			continue
		var/list/choice_names = list()
		if(length(customizer.customizer_choices) > 1)
			for(var/choice_type in customizer.customizer_choices)
				var/datum/customizer_choice/iter_choice = CUSTOMIZER_CHOICE(choice_type)
				if(iter_choice?.name)
					choice_names += iter_choice.name
		entries_out += list(list(
			"customizer_type" = "[customizer_type]",
			"name" = customizer.name,
			"allows_disabling" = customizer.allows_disabling,
			"has_multiple_choices" = (length(customizer.customizer_choices) > 1),
			"choice_options" = choice_names,
		))
	data["entries"] = entries_out
	return data

/// Plain-text + color for a PQ value. Mirrors format_pq_text() but ships structured
/// data to React instead of an HTML <span> the client would render as literal text.
// Lobby roster + countdown. Mirrors /mob/dead/Stat panel display: total players ready,
// per-job groupings, and round-start timer. Wanderer-family jobs (Adventurer, Wretch,
// Court Agent) get collapsed under one "Wanderer" bucket as the classic UI does.
//
// The snapshot is identical across every open menu (no per-user fields), so
// each ui_data poll routes through the shared global cache below — at 150
// concurrent menus this turns O(menus × players) into O(players) per poll.
/datum/preferences_menu/proc/build_lobby_data()
	return get_cached_lobby_snapshot()

GLOBAL_LIST_EMPTY(cached_lobby_snapshot)
GLOBAL_VAR_INIT(cached_lobby_snapshot_at, 0)

/// Returns a shared lobby snapshot, rebuilt at most every 1 second. Every
/// preferences_menu polling for lobby data reads the same cached payload,
/// which avoids re-walking GLOB.player_list once per menu per poll.
/proc/get_cached_lobby_snapshot()
	if(GLOB.cached_lobby_snapshot.len && (world.time - GLOB.cached_lobby_snapshot_at) < 1 SECONDS)
		return GLOB.cached_lobby_snapshot
	GLOB.cached_lobby_snapshot = rebuild_lobby_snapshot()
	GLOB.cached_lobby_snapshot_at = world.time
	return GLOB.cached_lobby_snapshot

/proc/rebuild_lobby_snapshot()
	var/list/data = list()
	var/is_pregame = (SSticker.current_state == GAME_STATE_PREGAME)
	data["is_pregame"] = is_pregame
	data["timeleft_ds"] = is_pregame ? SSticker.GetTimeLeft() : -1
	data["total_ready"] = SSticker.totalPlayersReady
	data["round_in_progress"] = SSticker.IsRoundInProgress()

	var/list/wanderer_jobs = GLOB.prefs_menu_wanderer_titles
	var/list/by_job = list()
	for(var/mob/dead/new_player/player in GLOB.player_list)
		if(player.ready != PLAYER_READY_TO_PLAY)
			continue
		if(player.client?.ckey in GLOB.hiderole)
			continue
		var/list/jp = player.client?.prefs?.job_preferences
		if(!jp)
			continue
		for(var/job_name in jp)
			if(jp[job_name] != JP_HIGH)
				continue
			var/bucket = (job_name in wanderer_jobs) ? "Wanderer" : job_name
			if(!by_job[bucket])
				by_job[bucket] = list()
			by_job[bucket] += player.client.prefs.real_name
			break

	var/list/job_entries = list()
	for(var/job_name in by_job)
		var/list/players = by_job[job_name]
		job_entries += list(list(
			"job" = job_name,
			"players" = players,
			"order" = snapshot_lobby_job_sort_order(job_name, wanderer_jobs),
		))
	sortTim(job_entries, GLOBAL_PROC_REF(cmp_lobby_job_entries))
	data["ready_by_job"] = job_entries
	return data

/// File-scope variant of lobby_job_sort_order — the cache builder runs at
/// global scope so it can't reach the /datum/preferences_menu proc.
/proc/snapshot_lobby_job_sort_order(job_name, list/wanderer_jobs)
	if(job_name == "Wanderer")
		var/min_order = INFINITY
		for(var/wname in wanderer_jobs)
			var/datum/job/wjob = SSjob.GetJob(wname)
			if(wjob && wjob.display_order < min_order)
				min_order = wjob.display_order
		return min_order == INFINITY ? 9999 : min_order
	var/datum/job/job = SSjob.GetJob(job_name)
	return job ? job.display_order : 9999

/proc/cmp_lobby_job_entries(list/a, list/b)
	return a["order"] - b["order"]

/datum/preferences_menu/proc/pq_tier_label(the_pq)
	if(the_pq >= 100)
		return list("text" = "Ascended!", "color" = "#ff2400")
	if(the_pq >= 70)
		return list("text" = "Magnificent!", "color" = "#00ff00")
	if(the_pq >= 50)
		return list("text" = "Exceptional!", "color" = "#00ff00")
	if(the_pq >= 30)
		return list("text" = "Great!", "color" = "#47b899")
	if(the_pq >= 10)
		return list("text" = "Good!", "color" = "#69c975")
	if(the_pq >= 5)
		return list("text" = "Nice", "color" = "#58a762")
	if(the_pq >= -4)
		return list("text" = "Normal", "color" = null)
	if(the_pq >= -30)
		return list("text" = "Poor", "color" = "#be6941")
	if(the_pq >= -70)
		return list("text" = "Terrible", "color" = "#cd4232")
	if(the_pq >= -99)
		return list("text" = "Abysmal", "color" = "#e2221d")
	if(the_pq <= -100)
		return list("text" = "Shitter", "color" = "#ff00ff")
	return list("text" = "Normal", "color" = null)

/// DYNAMIC half of Game Prefs: toggles + per-role state (ban + enabled).
/// Stable across the session except that `enabled` toggles when the user
/// clicks. The static role NAME list lives in build_game_prefs_static.
/datum/preferences_menu/proc/build_game_prefs_dynamic(mob/user)
	var/list/data = list()
	data["stat_simple"] = prefs.stat_simple
	data["tgui_lock"] = prefs.tgui_lock
	data["hotkeys"] = prefs.hotkeys
	data["clientfps"] = prefs.clientfps
	data["ambientocclusion"] = prefs.ambientocclusion
	data["schizo_voice"] = !!(prefs.toggles & SCHIZO_VOICE)

	var/list/roles_out = list()
	var/age_restrict = CONFIG_GET(flag/use_age_restriction_for_jobs)
	for(var/role in GLOB.special_roles_rogue)
		var/list/entry = list("name" = role)
		if(is_banned_from(user.ckey, role))
			entry["state"] = "banned"
		else
			var/days_remaining = null
			if(age_restrict && ispath(GLOB.special_roles_rogue[role]))
				days_remaining = get_remaining_days(user.client)
			if(days_remaining)
				entry["state"] = "days"
				entry["days_remaining"] = days_remaining
			else
				entry["state"] = "ok"
				entry["enabled"] = (role in prefs.be_special)
		roles_out += list(entry)
	data["roles"] = roles_out
	data["banned_from_antag"] = is_banned_from(user.ckey, ROLE_SYNDICATE)
	return data

/// STATIC half of Game Prefs: nothing meaningful to ship — the role name
/// list is rebuilt by the dynamic side anyway (the ban/days_remaining state
/// is per-role and inseparable from the name). Reserved for future use.
/datum/preferences_menu/proc/build_game_prefs_static(mob/user)
	return list()

/datum/preferences_menu/proc/build_ooc_prefs_data(mob/user)
	var/list/data = list()
	data["windowflashing"] = prefs.windowflashing
	data["hear_midis"] = !!(prefs.toggles & SOUND_MIDI)
	data["lobby_music"] = !!(prefs.toggles & SOUND_LOBBY)
	data["pull_requests"] = !!(prefs.chat_toggles & CHAT_PULLR)
	data["unlock_content"] = prefs.unlock_content
	data["byond_publicity"] = !!(prefs.toggles & MEMBER_PUBLIC)
	data["is_admin"] = !!user.client?.holder
	if(user.client?.holder)
		data["admin"] = list(
			"hear_adminhelps" = !!(prefs.toggles & SOUND_ADMINHELP),
			"hear_prayers" = !!(prefs.toggles & SOUND_PRAYERS),
			"announce_login" = !!(prefs.toggles & ANNOUNCE_LOGIN),
			"combohud_lighting" = !!(prefs.toggles & COMBOHUD_LIGHTING),
			// chat_toggles flags are inverted in the classic UI — flag set means
			// "shown". The React side shows the same wording for parity.
			"dead_chat_shown" = !!(prefs.chat_toggles & CHAT_DEAD),
			"radio_chatter_shown" = !!(prefs.chat_toggles & CHAT_RADIO),
			"prayers_shown" = !!(prefs.chat_toggles & CHAT_PRAYER),
			"asaycolor" = prefs.asaycolor || "#ff4500",
			"allow_asaycolor" = CONFIG_GET(flag/allow_admin_asaycolor),
			"deadmin_always" = !!(prefs.toggles & DEADMIN_ALWAYS),
			"deadmin_antag" = !!(prefs.toggles & DEADMIN_ANTAGONIST),
			"deadmin_head" = !!(prefs.toggles & DEADMIN_POSITION_HEAD),
			"auto_deadmin_players" = CONFIG_GET(flag/auto_deadmin_players),
			"auto_deadmin_antagonists" = CONFIG_GET(flag/auto_deadmin_antagonists),
			"auto_deadmin_heads" = CONFIG_GET(flag/auto_deadmin_heads),
		)
	return data

/datum/preferences_menu/proc/build_familiar_dynamic(mob/user)
	var/list/data = list()
	var/datum/familiar_prefs/fp = prefs.familiar_prefs
	if(!fp)
		return data

	data["familiar_name"] = fp.familiar_name
	data["familiar_pronouns"] = fp.familiar_pronouns
	var/static/list/fam_pronoun_options = list(
		"he/him" = HE_HIM,
		"she/her" = SHE_HER,
		"they/them" = THEY_THEM,
		"it/its" = IT_ITS,
	)
	var/pronoun_label = "they/them"
	for(var/k in fam_pronoun_options)
		if(fam_pronoun_options[k] == fp.familiar_pronouns)
			pronoun_label = k
			break
	data["familiar_pronoun_label"] = pronoun_label
	data["familiar_headshot_link"] = fp.familiar_headshot_link
	data["familiar_flavortext_len"] = length(fp.familiar_flavortext)
	data["familiar_ooc_notes_len"] = length(fp.familiar_ooc_notes)
	data["familiar_ooc_extra_set"] = !!fp.familiar_ooc_extra_link

	var/display_name = "None selected"
	for(var/name in GLOB.familiar_types)
		if(GLOB.familiar_types[name] == fp.familiar_specie)
			display_name = name
			break
	data["familiar_specie_name"] = display_name
	data["familiar_lore_blurb"] = fp.familiar_specie ? GLOB.familiar_lore_blurbs[fp.familiar_specie] : null
	data["in_queue"] = (prefs?.parent in GLOB.familiar_queue)
	data["queue_ready"] = (fp.familiar_name && fp.familiar_flavortext_display && fp.familiar_specie)
	return data

/datum/preferences_menu/proc/build_familiar_static(mob/user)
	var/list/data = list()
	var/datum/familiar_prefs/fp = prefs.familiar_prefs
	if(!fp)
		return data
	var/static/list/fam_pronoun_options = list("he/him", "she/her", "they/them", "it/its")
	data["familiar_pronoun_options"] = fam_pronoun_options
	data["familiar_specie_options"] = list_keys(GLOB.familiar_types)
	return data

/datum/preferences_menu/proc/build_gnoll_dynamic(mob/user)
	var/list/data = list()
	var/datum/gnoll_prefs/gp = prefs.gnoll_prefs
	if(!gp)
		return data

	data["gnoll_name"] = gp.gnoll_name
	data["gnoll_pronouns"] = gp.gnoll_pronouns
	data["pronoun_label"] = gp.get_selected_label(gp.get_pronoun_options(), gp.gnoll_pronouns) || gp.gnoll_pronouns
	data["pelt_label"] = gp.get_selected_label(gp.get_pelt_options(), gp.pelt_type) || "Firepelt"
	data["genitals"] = list(
		"penis" = gp.genitals["penis"],
		"vagina" = gp.genitals["vagina"],
		"breasts" = gp.genitals["breasts"],
	)
	data["height_label"] = gp.get_selected_label(gp.get_descriptor_options("height"), gp.descriptor_height) || "Moderate"
	data["body_label"] = gp.get_selected_label(gp.get_descriptor_options("body"), gp.descriptor_body) || "Muscular"
	data["fur_label"] = gp.get_selected_label(gp.get_descriptor_options("fur"), gp.descriptor_fur) || "Coarse"
	data["voice_label"] = gp.get_selected_label(gp.get_descriptor_options("voice"), gp.descriptor_voice) || "Growly"
	data["muzzle_label"] = gp.get_selected_label(gp.get_descriptor_options("muzzle"), gp.descriptor_muzzle) || "Long"
	data["expression_label"] = gp.get_selected_label(gp.get_descriptor_options("expression"), gp.descriptor_expression) || "Alert"
	data["gnoll_flavortext_len"] = length(gp.gnoll_flavortext)
	data["gnoll_ooc_notes_len"] = length(gp.gnoll_ooc_notes)
	return data

/datum/preferences_menu/proc/build_gnoll_static(mob/user)
	var/list/data = list()
	var/datum/gnoll_prefs/gp = prefs.gnoll_prefs
	if(!gp)
		return data
	data["pronoun_options"] = list_keys(gp.get_pronoun_options())
	data["pelt_options"] = list_keys(gp.get_pelt_options())
	var/static/list/descriptor_slots = list("height", "body", "fur", "voice", "muzzle", "expression")
	for(var/slot in descriptor_slots)
		data["[slot]_options"] = list_keys(gp.get_descriptor_options(slot))
	return data

/datum/preferences_menu/proc/list_keys(list/L)
	var/list/out = list()
	for(var/k in L)
		out += k
	return out

/// DYNAMIC half of keybinds: current user bindings (by keybind name → list
/// of keys) + hotkeys mode. Catalog (categories + name + full_name +
/// default_keys for both modes) lives in build_keybinds_static so the
/// ~hundreds of keybinding entries aren't re-walked on every push.
/datum/preferences_menu/proc/build_keybinds_dynamic(mob/user)
	var/list/data = list()
	data["hotkeys_mode"] = prefs.hotkeys
	var/list/user_binds = list()
	for(var/key in prefs.key_bindings)
		for(var/kb_name in prefs.key_bindings[key])
			user_binds[kb_name] += list(key)
	data["user_bindings"] = user_binds
	return data

/datum/preferences_menu/proc/build_keybinds_static(mob/user)
	// GLOB.keybindings_by_name is fixed at SS init — the catalog is round-
	// stable per (hotkeys_mode) combo. Cache both modes; refresh_static_data
	// fires on hotkey-mode toggle so React picks up the matching default_keys.
	var/list/data = list()
	data["max_keys_per_keybind"] = MAX_KEYS_PER_KEYBIND
	var/list/categories_by_name = list()
	for(var/name in GLOB.keybindings_by_name)
		var/datum/keybinding/kb = GLOB.keybindings_by_name[name]
		if(!categories_by_name[kb.category])
			categories_by_name[kb.category] = list()
		categories_by_name[kb.category] += list(list(
			"name" = kb.name,
			"full_name" = kb.full_name,
			"default_keys" = prefs.hotkeys ? (kb.classic_keys || list()) : (kb.hotkey_keys || list()),
		))
	var/list/categories_out = list()
	for(var/cat in categories_by_name)
		categories_out += list(list(
			"name" = cat,
			"keybinds" = categories_by_name[cat],
		))
	data["categories"] = categories_out
	return data

/datum/preferences_menu/proc/build_flavor_data(mob/user)
	var/list/data = list()
	data["agevetted"] = user.check_agevet()
	data["is_legacy"] = prefs.is_legacy
	data["min_flavortext"] = MINIMUM_FLAVOR_TEXT
	data["min_ooc_notes"] = MINIMUM_OOC_NOTES

	data["flavortext_len"] = length(prefs.flavortext)
	data["ooc_notes_len"] = length(prefs.ooc_notes)
	data["rumour_len"] = length(prefs.rumour)
	data["gossip_len"] = length(prefs.gossip)
	data["ooc_extra_set"] = !!prefs.ooc_extra
	data["headshot_link"] = prefs.headshot_link
	data["nsfw_headshot_link"] = prefs.nsfw_headshot_link
	return data

/// DYNAMIC half of the jobs/Class Selection tab. Per-job priority + gating
/// state (which depends on the player's current virtue/charflaw/origin/age,
/// all of which can change mid-session). Plus joblessrole / last_class /
/// class_explain panel state. The static job catalog (titles, categories,
/// colors, tutorial blurbs, slot counts) lives in build_jobs_static.
///
/// Returned as an assoc map keyed by job.title so React can spread it onto
/// each static catalog entry by title without an O(n²) lookup.
/datum/preferences_menu/proc/build_jobs_dynamic(mob/user)
	var/list/data = list()
	if(!SSjob || !SSjob.occupations?.len)
		data["loaded"] = FALSE
		return data
	data["loaded"] = TRUE

	if(prefs.joblessrole != RETURNTOLOBBY && prefs.joblessrole != BERANDOMJOB)
		prefs.joblessrole = RETURNTOLOBBY
	data["joblessrole"] = prefs.joblessrole
	data["last_class"] = prefs.lastclass
	data["job_change_locked"] = SSticker.job_change_locked
	data["triumphs"] = user.get_triumphs()
	data["pq"] = get_playerquality(user.ckey)
	data["class_explain_title"] = active_class_explain_title
	data["class_explain_html"] = active_class_explain_html

	if(!cached_job_gates)
		cached_job_gates = list()

	var/list/job_state = list()
	for(var/datum/job/job as anything in SSjob.occupations)
		if(!job.spawn_positions)
			continue
		job_state[job.title] = build_job_entry_dynamic(user, job)
	data["jobs"] = job_state
	return data

/// STATIC half of jobs: the per-job catalog (title, display_name, tutorial,
/// slots, rcp, required, category, color, order). Cached on the menu datum
/// via static_data_cache; rebuilt only when refresh_static_data() fires —
/// triggered on pronoun changes (display_name uses f_title for she/her).
/datum/preferences_menu/proc/build_jobs_static(mob/user)
	var/list/data = list()
	if(!SSjob || !SSjob.occupations?.len)
		return data
	// Sort cache lives at module scope so every open menu shares the one sort.
	var/static/list/cached_sorted_jobs
	if(!cached_sorted_jobs)
		cached_sorted_jobs = sortList(SSjob.occupations, GLOBAL_PROC_REF(cmp_job_display_asc))
	var/list/jobs_out = list()
	for(var/datum/job/job as anything in cached_sorted_jobs)
		if(!job.spawn_positions)
			continue
		var/used_name = job.title
		if((prefs.pronouns == SHE_HER || prefs.pronouns == THEY_THEM_F) && job.f_title)
			used_name = job.f_title
		var/list/cat = job_category_for(job)
		jobs_out += list(list(
			"title" = job.title,
			"display_name" = used_name,
			"tutorial" = job.tutorial,
			"slots" = job.spawn_positions,
			"rcp" = job.round_contrib_points,
			"required" = job.required,
			"category" = cat["name"],
			"category_color" = cat["color"],
			"category_order" = cat["order"],
		))
	data["jobs"] = jobs_out
	return data

/// Per-job dynamic gating state. Returns just {state, state_text, priority}
/// — the rest of the job's per-entry fields (display_name, category, etc.)
/// come from the static catalog and are merged on the React side.
/datum/preferences_menu/proc/build_job_entry_dynamic(mob/user, datum/job/job)
	var/list/entry = list()
	var/rank = job.title

	// Pull the immutable gates from the per-session cache — ckey/playtime/
	// account-age/PQ are stable for the menu's lifetime, so the four
	// ban/playtime/agedays/PQ lookups are amortized over the session.
	var/list/gate = cached_job_gates[rank]
	if(!gate)
		gate = compute_job_gate(user, job)
		cached_job_gates[rank] = gate

	if(gate["state"])
		entry["state"] = gate["state"]
		entry["state_text"] = gate["state_text"]
		return entry

	// Virtue restrictions (combined: virtue + virtuetwo).
	if(length(job.virtue_restrictions))
		var/disallowed_name
		if(prefs.virtue?.type in job.virtue_restrictions)
			disallowed_name = prefs.virtue.name
		if(prefs.virtuetwo?.type in job.virtue_restrictions)
			disallowed_name = disallowed_name ? "[disallowed_name], [prefs.virtuetwo.name]" : prefs.virtuetwo.name
		if(disallowed_name)
			entry["state"] = "virtue"
			entry["state_text"] = "Disallowed by Virtue: [disallowed_name]"
			return entry

		if(prefs.virtue_origin?.type in job.virtue_restrictions)
			entry["state"] = "origin"
			entry["state_text"] = "Disallowed by Origin: [prefs.virtue_origin.name]"
			return entry

	if(length(job.vice_restrictions) && (prefs.charflaw?.type in job.vice_restrictions))
		entry["state"] = "vice"
		entry["state_text"] = "Disallowed by Vice: [prefs.charflaw.name]"
		return entry

	var/job_unavailable = JOB_AVAILABLE
	if(isnewplayer(prefs.parent?.mob))
		var/mob/dead/new_player/new_player = prefs.parent.mob
		job_unavailable = new_player.IsJobUnavailable(job.title, latejoin = FALSE)
	if(!(job_unavailable in list(JOB_AVAILABLE, JOB_UNAVAILABLE_SLOTFULL)))
		entry["state"] = "unavailable"
		entry["state_text"] = unavailable_reason_text(job_unavailable)
		return entry

	entry["state"] = "available"
	switch(prefs.job_preferences[job.title])
		if(JP_HIGH)
			entry["priority"] = "high"
		if(JP_MEDIUM)
			entry["priority"] = "medium"
		if(JP_LOW)
			entry["priority"] = "low"
		else
			entry["priority"] = "never"
	return entry

/// Resolve a job's category label + color from the same nine GLOB.*_positions
/// lists the late-join picker uses, so Class Selection gets the same colored
/// section headers (Nobles / Courtiers / Garrison / Churchmen / Inquisition /
/// Yeomen / Peasants / Mercenaries / Sidefolk). Jobs outside those lists fall
/// back to "Other". Cached statically since the mapping is round-stable.
/proc/job_category_for(datum/job/job)
	var/static/list/category_cache
	if(!category_cache)
		category_cache = list()
		// Order matches late_join_choices.dm omegalist ordering — that's the
		// order the sections render in.
		// Configured display order on Class Selection:
		//   1 Nobles, 2 Courtiers, 3 Garrison, 4 Churchmen, 5 Inquisition,
		//   6 Yeomen, 7 Peasants, 8 Sidefolk, 9 Mercenaries,
		//   10 Other (any job not in any of these lists),
		//   11 Wanderers (Adventurer/Wretch/Court Agent — separate spawn flow).
		var/list/omegalist = list(
			list("Nobles", GLOB.noble_positions),
			list("Courtiers", GLOB.courtier_positions),
			list("Garrison", GLOB.garrison_positions),
			list("Churchmen", GLOB.church_positions),
			list("Inquisition", GLOB.inquisition_positions),
			list("Yeomen", GLOB.yeoman_positions),
			list("Peasants", GLOB.peasant_positions),
			list("Sidefolk", GLOB.youngfolk_positions),
			list("Mercenaries", GLOB.mercenary_positions),
		)
		var/order = 0
		for(var/list/cat_entry in omegalist)
			order++
			var/cat_name = cat_entry[1]
			var/list/positions = cat_entry[2]
			if(!length(positions))
				continue
			var/datum/job/head = SSjob.name_occupations[positions[1]]
			var/cat_color = head ? head.selection_color : "#dbdce3"
			for(var/title in positions)
				category_cache[title] = list("name" = cat_name, "color" = cat_color, "order" = order)
		// Garrison extras — jobs with department_flag = GARRISON that aren't in
		// GLOB.garrison_positions (which drives late-join). Pinned here so they
		// display under Garrison in Class Selection without affecting other
		// systems that consume the GLOB list.
		var/static/list/garrison_extra_titles = list("Veteran")
		var/datum/job/garrison_head = length(GLOB.garrison_positions) ? SSjob.name_occupations[GLOB.garrison_positions[1]] : null
		var/garrison_color = garrison_head ? garrison_head.selection_color : "#dbdce3"
		for(var/title in garrison_extra_titles)
			category_cache[title] = list("name" = "Garrison", "color" = garrison_color, "order" = 3)

		// Wanderers — pinned to order 11 so "Other" (order 10) renders above it.
		var/list/wanderer_titles = GLOB.prefs_menu_wanderer_titles
		if(length(wanderer_titles))
			var/datum/job/wanderer_head = SSjob.name_occupations[wanderer_titles[1]]
			var/wanderer_color = wanderer_head ? wanderer_head.selection_color : "#dbdce3"
			for(var/title in wanderer_titles)
				category_cache[title] = list("name" = "Wanderers", "color" = wanderer_color, "order" = 11)
	var/list/hit = category_cache[job.title]
	if(hit)
		return hit
	return list("name" = "Other", "color" = "#dbdce3", "order" = 10)

/// Compute the immutable per-session gate for a job (ban / playtime / account
/// age / PQ floor / PQ ceiling). Returns a {state, state_text} list. Empty
/// state means the job has no immutable gate and per-poll dynamic checks
/// (virtue/vice/SLOTFULL) decide whether it's available.
/datum/preferences_menu/proc/compute_job_gate(mob/user, datum/job/job)
	var/list/gate = list("state" = null, "state_text" = null)
	var/rank = job.title

	if(is_banned_from(user.ckey, rank))
		gate["state"] = "banned"
		gate["state_text"] = "BANNED"
		return gate

	var/required_playtime_remaining = job.required_playtime_remaining(user.client)
	if(required_playtime_remaining)
		gate["state"] = "playtime"
		gate["state_text"] = "[get_exp_format(required_playtime_remaining)] as [job.get_exp_req_type()]"
		return gate

	if(!job.player_old_enough(user.client))
		gate["state"] = "agedays"
		gate["state_text"] = "IN [job.available_in_days(user.client)] DAYS"
		return gate

	if(!job.required && !isnull(job.min_pq) && (get_playerquality(user.ckey) < job.min_pq))
		gate["state"] = "min_pq"
		gate["state_text"] = "Min PQ: [job.min_pq]"
		return gate

	if(!job.required && !isnull(job.max_pq) && (get_playerquality(user.ckey) > job.max_pq))
		gate["state"] = "max_pq"
		gate["state_text"] = "Max PQ: [job.max_pq]"
		return gate

	return gate

/// Resolve a JOB_UNAVAILABLE_* code into a short human-readable reason.
/datum/preferences_menu/proc/unavailable_reason_text(reason)
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
	return "Unavailable"

/datum/preferences_menu/proc/build_culinary_dynamic(mob/user)
	prefs.validate_culinary_preferences()
	var/list/data = list()
	data["fav_food_name"] = culinary_food_name(prefs.culinary_preferences[CULINARY_FAVOURITE_FOOD])
	data["fav_drink_name"] = culinary_drink_name(prefs.culinary_preferences[CULINARY_FAVOURITE_DRINK])
	data["hated_food_name"] = culinary_food_name(prefs.culinary_preferences[CULINARY_HATED_FOOD])
	data["hated_drink_name"] = culinary_drink_name(prefs.culinary_preferences[CULINARY_HATED_DRINK])
	data["fav_food_label"] = culinary_food_label(prefs.culinary_preferences[CULINARY_FAVOURITE_FOOD])
	data["hated_food_label"] = culinary_food_label(prefs.culinary_preferences[CULINARY_HATED_FOOD])
	data["fav_drink_label"] = culinary_drink_label(prefs.culinary_preferences[CULINARY_FAVOURITE_DRINK])
	data["hated_drink_label"] = culinary_drink_label(prefs.culinary_preferences[CULINARY_HATED_DRINK])
	return data

/// GLOB.food_with_faretypes / GLOB.drink_with_qualities are populated at SS
/// init and never mutate at runtime, so the labeled dropdown lists are
/// effectively constant. Module-cached so every menu's static payload reuses
/// the same allocation.
/datum/preferences_menu/proc/build_culinary_static(mob/user)
	var/static/list/cached_food_labels
	var/static/list/cached_drink_labels
	if(!cached_food_labels)
		cached_food_labels = list("None")
		for(var/list/food_data in GLOB.food_with_faretypes)
			cached_food_labels += "[capitalize(food_data["name"])] (Quality: [food_data["faretype"]])"
	if(!cached_drink_labels)
		cached_drink_labels = list("None")
		for(var/list/drink_data in GLOB.drink_with_qualities)
			cached_drink_labels += "[capitalize(drink_data["name"])] (Quality: [drink_data["quality"]])"
	var/list/data = list()
	data["food_options"] = cached_food_labels
	data["drink_options"] = cached_drink_labels
	return data

/datum/preferences_menu/proc/culinary_food_label(food_type)
	if(!food_type)
		return "None"
	// GLOB.food_with_faretypes is fixed at SS init, so flip the per-call
	// O(N) walk into a one-time O(N) build + O(1) hashmap lookup. Profile
	// flagged the walk as ~5.7s self CPU across 278K calls; the cache
	// drops it to a single hash hit per call.
	var/static/list/cached_food_labels
	if(!cached_food_labels)
		cached_food_labels = list()
		for(var/list/food_data in GLOB.food_with_faretypes)
			cached_food_labels[food_data["type"]] = "[capitalize(food_data["name"])] (Quality: [food_data["faretype"]])"
	return cached_food_labels[food_type] || culinary_food_name(food_type)

/datum/preferences_menu/proc/culinary_drink_label(drink_type)
	if(!drink_type)
		return "None"
	var/static/list/cached_drink_labels
	if(!cached_drink_labels)
		cached_drink_labels = list()
		for(var/list/drink_data in GLOB.drink_with_qualities)
			cached_drink_labels[drink_data["type"]] = "[capitalize(drink_data["name"])] (Quality: [drink_data["quality"]])"
	return cached_drink_labels[drink_type] || culinary_drink_name(drink_type)

/datum/preferences_menu/proc/culinary_food_name(food_type)
	if(!food_type)
		return "None"
	var/obj/item/food_instance = food_type
	return capitalize(initial(food_instance.name))

/datum/preferences_menu/proc/culinary_drink_name(drink_type)
	if(!drink_type)
		return "None"
	var/datum/reagent/drink_instance = drink_type
	return capitalize(initial(drink_instance.name))

/datum/preferences_menu/proc/build_loadout_dynamic(mob/user)
	var/list/data = list()
	var/list/slot_vars = list("loadout", "loadout2", "loadout3", "loadout4", "loadout5", "loadout6")
	var/list/hex_vars = list("loadout_1_hex", "loadout_2_hex", "loadout_3_hex", "loadout_4_hex", "loadout_5_hex", "loadout_6_hex")
	var/list/slots = list()
	for(var/i in 1 to 6)
		var/datum/loadout_item/item = prefs.vars[slot_vars[i]]
		var/hex = prefs.vars[hex_vars[i]]
		slots += list(list(
			"slot" = i,
			"name" = item?.name || "None",
			"desc" = item?.desc,
			"hex" = hex,
			"color_name" = lookup_loadout_color_name(hex),
		))
	data["slots"] = slots
	return data

/// Item + preset-color picklists. Item list is donator-filtered per user but
/// stable for the menu lifetime once computed → datum-cached. Color preset
/// list is fully static → module-cached.
///
/// Key the cache on the prefs owner's ckey (not whoever is polling) so an
/// admin observer's first poll doesn't pin the donator filter to their own
/// status for the rest of the menu's lifetime.
/datum/preferences_menu/proc/build_loadout_static(mob/user)
	var/list/data = list()
	var/owner_ckey = prefs.parent?.ckey || user.ckey
	if(!cached_loadout_item_options)
		var/list/item_names = list("None")
		for(var/path as anything in GLOB.loadout_items)
			var/datum/loadout_item/item = GLOB.loadout_items[path]
			if(!item?.name)
				continue
			if(item.donoritem && !item.donator_ckey_check(owner_ckey))
				continue
			item_names += item.name
		cached_loadout_item_options = item_names
	data["item_options"] = cached_loadout_item_options
	var/static/list/cached_color_options
	if(!cached_color_options)
		cached_color_options = list("—")
		for(var/k in colorlist)
			cached_color_options += k
	data["color_options"] = cached_color_options
	return data

/datum/preferences_menu/proc/lookup_loadout_color_name(hex)
	if(!hex)
		return "—"
	// Reverse lookup table built once and shared. Was iterating colorlist
	// six times per poll (once per loadout slot) just to compare hex strings.
	var/static/list/cached_hex_to_name
	if(!cached_hex_to_name)
		cached_hex_to_name = list()
		for(var/k in colorlist)
			cached_hex_to_name[colorlist[k]] = k
	return cached_hex_to_name[hex] || "Custom"

/datum/preferences_menu/proc/zone_label(zone)
	switch(zone)
		if(BODY_ZONE_R_ARM)
			return "Right Arm"
		if(BODY_ZONE_L_ARM)
			return "Left Arm"
		if(BODY_ZONE_HEAD)
			return "Head"
		if(BODY_ZONE_CHEST)
			return "Chest"
		if(BODY_ZONE_R_LEG)
			return "Right Leg"
		if(BODY_ZONE_L_LEG)
			return "Left Leg"
		if(BODY_ZONE_PRECISE_R_HAND)
			return "Right Hand"
		if(BODY_ZONE_PRECISE_L_HAND)
			return "Left Hand"
	return zone

/// Force a fresh preview-icon render. Called via Refresh Preview button or after
/// any body-affecting act. Inlines the classic update_preview_icon logic but
/// skips the is_new_player() guard so the dummy renders in the lobby too —
/// the classic preview pipeline only runs post-spawn, which doesn't fit our use case.
/datum/preferences_menu/proc/refresh_preview(mob/user)
	set waitfor = FALSE
	if(!prefs?.parent)
		return

	// Pick the highest-priority job for the dummy's clothes (matches classic behavior).
	var/datum/job/previewJob
	var/highest_pref = 0
	for(var/job in prefs.job_preferences)
		if(prefs.job_preferences[job] > highest_pref)
			previewJob = SSjob.GetJob(job)
			highest_pref = prefs.job_preferences[job]

	var/mob/living/carbon/human/dummy/mannequin = generate_or_wait_for_human_dummy(DUMMY_HUMAN_SLOT_PREFERENCES)
	prefs.copy_to(mannequin, 1, TRUE, TRUE)

	if(previewJob)
		mannequin.job = previewJob.title
		previewJob.equip(mannequin, TRUE, preference_source = prefs.parent)

	mannequin.rebuild_obscured_flags()
	COMPILE_OVERLAYS(mannequin)
	prefs.parent.show_character_previews(new /mutable_appearance(mannequin), "tgui_preview_map")
	unset_busy_human_dummy(DUMMY_HUMAN_SLOT_PREFERENCES)

/datum/preferences_menu/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	if(!prefs)
		return

	var/mob/user = ui.user

	switch(action)
		if("set_tab")
			var/new_tab = params["tab"]
			if(istext(new_tab))
				active_tab = new_tab
				// Autoupdate is disabled, so we must explicitly push so the
				// React side gets the new tab's dynamic data. Without this,
				// the merged `body`/`markings`/etc. object is just the static
				// half and any field that lives only in dynamic comes back
				// undefined — crashes when the renderer reads .length or
				// similar on it.
				SStgui.update_uis(src)
			return TRUE

		if("refresh_preview")
			refresh_preview(user)
			return TRUE

		// --- Identity actions ---

		if("set_name")
			if(check_nameban(user.ckey))
				return TRUE
			var/new_name = tgui_input_text(user, "The name of this vessel?", "IDENTITY", prefs.real_name, encode = FALSE)
			if(new_name)
				new_name = reject_bad_name(new_name)
				if(new_name)
					prefs.real_name = new_name
					on_identity_change()
				else
					to_chat(user, "<font color='red'>Invalid name. Should be 2-[MAX_NAME_LEN] characters, only A-Z, a-z, -, ', . and ,.</font>")
			return TRUE

		if("randomize_name")
			prefs.real_name = prefs.pref_species.random_name(prefs.gender, 1)
			on_identity_change()
			return TRUE

		if("set_nickname")
			var/new_nick = tgui_input_text(user, "Choose your character's nickname (for highlighting):", "NICKNAME", prefs.nickname, encode = FALSE)
			if(new_nick)
				new_nick = reject_bad_name(new_nick)
				if(new_nick)
					prefs.nickname = new_nick
					on_identity_change()
				else
					to_chat(user, "<font color='red'>Invalid nickname. Should be 2-[MAX_NAME_LEN] characters.</font>")
			return TRUE

		if("set_pronouns")
			var/picked = tgui_input_list(user, "Choose your character's pronouns", "PRONOUNS", GLOB.pronouns_list, prefs.pronouns)
			if(picked)
				prefs.pronouns = picked
				prefs.ResetJobs()
				to_chat(user, "<font color='red'>Your character's pronouns are now [prefs.pronouns]. Classes reset.</font>")
				// Pronoun change flips job display_names between title / f_title — static refresh.
				on_identity_change(TRUE)
			return TRUE

		if("set_pronouns_direct")
			var/picked = params["name"]
			if(!picked || !(picked in GLOB.pronouns_list))
				return TRUE
			prefs.pronouns = picked
			prefs.ResetJobs()
			to_chat(user, "<font color='red'>Your character's pronouns are now [prefs.pronouns]. Classes reset.</font>")
			on_identity_change(TRUE)
			return TRUE

		if("set_voice_type")
			var/picked = tgui_input_list(user, "Choose your character's voice type", "VOICE TYPE", GLOB.voice_types_list, prefs.voice_type)
			if(picked)
				prefs.voice_type = picked
				on_identity_change()
			return TRUE

		if("set_voice_type_direct")
			var/picked = params["name"]
			if(!picked || !(picked in GLOB.voice_types_list))
				return TRUE
			prefs.voice_type = picked
			on_identity_change()
			return TRUE

		if("set_voice_pack")
			var/picked = tgui_input_list(user, "Choose your character's emote voice pack", "VOICE PACK", GLOB.voice_packs_list, prefs.voice_pack)
			if(picked)
				prefs.voice_pack = picked
				on_identity_change()
			return TRUE

		if("set_voice_pack_direct")
			var/picked = params["name"]
			if(!picked || !(picked in GLOB.voice_packs_list))
				return TRUE
			prefs.voice_pack = picked
			on_identity_change()
			return TRUE

		if("set_age")
			if(!prefs.pref_species)
				return TRUE
			var/picked = tgui_input_list(user, "Choose your character's age", "YILS LIVED", prefs.pref_species.possible_ages, prefs.age)
			if(picked)
				prefs.age = picked
				// Reset hair color to match new age bracket (mirrors classic Topic behavior).
				var/list/hairs
				if((prefs.age == AGE_OLD) && (OLDGREY in prefs.pref_species.species_traits))
					hairs = prefs.pref_species.get_oldhc_list()
				else
					hairs = prefs.pref_species.get_hairc_list()
				if(hairs)
					prefs.hair_color = hairs[pick(hairs)]
					prefs.facial_hair_color = prefs.hair_color
				prefs.ResetJobs()
				prefs.family = FAMILY_NONE
				to_chat(user, "<font color='red'>Classes reset.</font>")
				// Age unlocks FAMILY_FULL for non-adults — family_options changes.
				on_identity_change(TRUE)
			return TRUE

		if("set_age_direct")
			if(!prefs.pref_species)
				return TRUE
			var/picked = params["name"]
			if(!picked || !(picked in prefs.pref_species.possible_ages))
				return TRUE
			prefs.age = picked
			var/list/hairs
			if((prefs.age == AGE_OLD) && (OLDGREY in prefs.pref_species.species_traits))
				hairs = prefs.pref_species.get_oldhc_list()
			else
				hairs = prefs.pref_species.get_hairc_list()
			if(hairs)
				prefs.hair_color = hairs[pick(hairs)]
				prefs.facial_hair_color = prefs.hair_color
			prefs.ResetJobs()
			prefs.family = FAMILY_NONE
			to_chat(user, "<font color='red'>Classes reset.</font>")
			on_identity_change(TRUE)
			return TRUE

		if("set_statpack")
			var/list/statpacks_available = list()
			for(var/path as anything in GLOB.statpacks)
				var/datum/statpack/sp = GLOB.statpacks[path]
				if(!sp?.name)
					continue
				statpacks_available[sp.name] = sp
			statpacks_available = sort_list(statpacks_available)
			var/picked = tgui_input_list(user, "How shall your strengths manifest?", "STATPACK", statpacks_available, prefs.statpack)
			if(picked)
				var/datum/statpack/sp = statpacks_available[picked]
				// Mirror classic behavior: leaving "Virtuous" wipes virtue/virtuetwo.
				if(prefs.statpack?.name == "Virtuous" && sp.name != "Virtuous")
					if(istype(prefs.virtue, /datum/virtue/size) || istype(prefs.virtuetwo, /datum/virtue/size))
						prefs.features["body_size"] = BODY_SIZE_NORMAL
						to_chat(user, span_purple("Your body size has been reset to [BODY_SIZE_NORMAL*100]%."))
					prefs.virtue = GLOB.virtues[/datum/virtue/none]
					prefs.virtuetwo = GLOB.virtues[/datum/virtue/none]
				prefs.statpack = sp
				to_chat(user, "<font color='purple'>[sp.name]</font>")
				to_chat(user, "<font color='purple'>[sp.description_string()]</font>")
				// Statpack drops the currently-selected statpack from the dropdown list.
				on_identity_change(TRUE)
			return TRUE

		if("set_statpack_direct")
			var/picked = params["name"]
			if(!picked)
				return TRUE
			// Dropdown ships the labeled form ("Trained (+1 STR, ...)") — match
			// either the bare name or the full label so we can resolve it back.
			for(var/path as anything in GLOB.statpacks)
				var/datum/statpack/sp = GLOB.statpacks[path]
				if(!sp?.name)
					continue
				if(sp.name != picked && statpack_dropdown_label(sp) != picked)
					continue
				if(prefs.statpack?.name == "Virtuous" && sp.name != "Virtuous")
					if(istype(prefs.virtue, /datum/virtue/size) || istype(prefs.virtuetwo, /datum/virtue/size))
						prefs.features["body_size"] = BODY_SIZE_NORMAL
						to_chat(user, span_purple("Your body size has been reset to [BODY_SIZE_NORMAL*100]%."))
					prefs.virtue = GLOB.virtues[/datum/virtue/none]
					prefs.virtuetwo = GLOB.virtues[/datum/virtue/none]
				prefs.statpack = sp
				to_chat(user, "<font color='purple'>[sp.name]</font>")
				to_chat(user, "<font color='purple'>[sp.description_string()]</font>")
				on_identity_change(TRUE)
				return TRUE
			return TRUE

		if("set_virtue")
			var/list/virtues_available = build_virtue_picker_list(user, FALSE)
			if(!length(virtues_available))
				to_chat(user, span_warning("No virtues available."))
				return TRUE
			var/picked = tgui_input_list(user, "Choose your virtue", "VIRTUE", virtues_available, prefs.virtue)
			if(picked)
				var/datum/virtue/v = virtues_available[picked]
				var/datum/virtue/old_virtue = prefs.virtue
				prefs.virtue = v
				sync_virtue_body_size(old_virtue, v, user)
				// Job availability depends on virtue restrictions.
				on_identity_change(TRUE)
			return TRUE

		if("set_virtue_direct")
			var/picked = params["name"]
			if(!picked)
				return TRUE
			var/list/virtues_available = build_virtue_picker_list(user, FALSE)
			var/datum/virtue/v = virtues_available[picked]
			if(!v)
				return TRUE
			var/datum/virtue/old_virtue = prefs.virtue
			prefs.virtue = v
			sync_virtue_body_size(old_virtue, v, user)
			on_identity_change(TRUE)
			return TRUE

		if("set_virtuetwo")
			if(prefs.statpack?.name != "Virtuous")
				return TRUE
			var/list/virtues_available = build_virtue_picker_list(user, FALSE)
			if(!length(virtues_available))
				to_chat(user, span_warning("No virtues available."))
				return TRUE
			var/picked = tgui_input_list(user, "Choose your second virtue", "SECOND VIRTUE", virtues_available, prefs.virtuetwo)
			if(picked)
				var/datum/virtue/v = virtues_available[picked]
				var/datum/virtue/old_virtue = prefs.virtuetwo
				prefs.virtuetwo = v
				sync_virtue_body_size(old_virtue, v, user)
				on_identity_change(TRUE)
			return TRUE

		if("set_virtuetwo_direct")
			if(prefs.statpack?.name != "Virtuous")
				return TRUE
			var/picked = params["name"]
			if(!picked)
				return TRUE
			var/list/virtues_available = build_virtue_picker_list(user, FALSE)
			var/datum/virtue/v = virtues_available[picked]
			if(!v)
				return TRUE
			var/datum/virtue/old_virtue = prefs.virtuetwo
			prefs.virtuetwo = v
			sync_virtue_body_size(old_virtue, v, user)
			on_identity_change(TRUE)
			return TRUE

		if("set_charflaw")
			// Use the curated GLOB.character_flaws list (excludes virtues + dev-only flaws) rather than typesof.
			var/list/flaws = GLOB.character_flaws.Copy()
			var/picked = tgui_input_list(user, "What burden will you bear?", "FLAWS", flaws)
			if(picked)
				var/charflaw_path = flaws[picked]
				prefs.charflaw = new charflaw_path()
				if(prefs.charflaw?.desc)
					to_chat(user, "<span class='info'>[prefs.charflaw.desc]</span>")
				// Job availability depends on vice restrictions.
				on_identity_change(TRUE)
			return TRUE

		if("set_charflaw_direct")
			var/picked = params["name"]
			if(!picked)
				return TRUE
			var/list/flaws = GLOB.character_flaws
			if(!flaws[picked])
				return TRUE
			var/charflaw_path = flaws[picked]
			prefs.charflaw = new charflaw_path()
			on_identity_change(TRUE)
			return TRUE

		if("set_species")
			var/list/species = list()
			for(var/A in GLOB.roundstart_races)
				var/datum/species/race = GLOB.species_list[A]
				race = new race()
				if(!user.client)
					continue
				if(race.patreon_req > user.client.patreonlevel())
					continue
				if(race.is_subrace == TRUE)
					continue
				if(race.base_name == prefs.pref_species.base_name)
					continue
				species[race.base_name] += race
			var/picked = tgui_input_list(user, "By what shape are you bound?", "RACE", species)
			if(picked)
				var/datum/species/race_chosen = species[picked]
				prefs.set_new_race(race_chosen, user)
				// Species change invalidates ~every option list — subspecies,
				// race_title, origin, extra_language, tail_type, skin_tone,
				// markings, customizers, descriptors, body section flags.
				on_identity_change(TRUE)
			return TRUE

		// Direct (Dropdown-picked) variants. Re-derive the candidate map so we
		// can resolve the name back to a datum, and validate the pick is still
		// in the eligible set — protects against stale UI ↔ backend races.
		if("set_species_direct")
			var/picked = params["name"]
			if(!picked || !user.client)
				return TRUE
			for(var/A in GLOB.roundstart_races)
				var/datum/species/race = GLOB.species_list[A]
				race = new race()
				if(race.patreon_req > user.client.patreonlevel())
					continue
				if(race.is_subrace)
					continue
				if(race.base_name == prefs.pref_species?.base_name)
					continue
				if(race.base_name != picked)
					continue
				prefs.set_new_race(race, user, silent = TRUE)
				on_identity_change(TRUE)
				return TRUE
			return TRUE

		if("show_species_desc")
			if(!prefs.pref_species)
				return TRUE
			if(prefs.pref_species.desc)
				// Mirror process_virtue_text styling: small (font size 3) +
				// purple, so race lore reads the same as origin lore.
				to_chat(user, "<font size = 3>[span_purple(prefs.pref_species.desc)]</font>")
			else
				to_chat(user, span_info("No description available for this race."))
			return TRUE

		if("show_age_info")
			// Stat effects sourced from /mob/living/proc/apply_race_stat_changes (stats.dm).
			var/blurb
			switch(prefs.age)
				if(AGE_ADULT)
					blurb = "Adult: no stat change."
				if(AGE_MIDDLEAGED)
					blurb = "Middle-Aged: -1 SPE, +1 CON, +1 FOR."
				if(AGE_OLD)
					blurb = "Old: -1 STR, -2 SPE, -1 PER, -2 CON, +2 INT."
				else
					blurb = "[prefs.age]: no recorded stat effects."
			to_chat(user, "<font size = 3>[span_purple(blurb)]</font>")
			return TRUE

		if("set_subspecies")
			var/list/species = list()
			for(var/A in GLOB.roundstart_races)
				var/datum/species/race = GLOB.species_list[A]
				race = new race()
				if(!user.client)
					continue
				if(race.base_name != prefs.pref_species.base_name)
					continue
				if(race.sub_name == prefs.pref_species.sub_name)
					continue
				species[race.sub_name] += race
			var/picked = tgui_input_list(user, "By what shape are you bound?", "SUBRACE", species)
			if(picked)
				var/datum/species/subrace_chosen = species[picked]
				prefs.set_new_race(subrace_chosen, user)
				// Subspecies swap changes body section, customizers, descriptors, markings.
				on_identity_change(TRUE)
			return TRUE

		if("set_subspecies_direct")
			var/picked = params["name"]
			if(!picked || !user.client)
				return TRUE
			for(var/A in GLOB.roundstart_races)
				var/datum/species/race = GLOB.species_list[A]
				race = new race()
				if(race.base_name != prefs.pref_species?.base_name)
					continue
				if(race.sub_name == prefs.pref_species?.sub_name)
					continue
				if(race.sub_name != picked)
					continue
				prefs.set_new_race(race, user, silent = TRUE)
				on_identity_change(TRUE)
				return TRUE
			return TRUE

		if("show_subspecies_desc")
			if(!prefs.pref_species)
				return TRUE
			if(prefs.pref_species.desc)
				to_chat(user, "<font size = 3>[span_purple(prefs.pref_species.desc)]</font>")
			else
				to_chat(user, span_info("No description available for this subrace."))
			return TRUE

		if("show_race_help")
			var/list/dat = list()
			dat += "A <font color='#1cb308'>ᛉ</font> symbol indicates a <b>PSYDONIC</b> race, created by <b>Him</b> before his demise.<br>"
			dat += "These races are eligible for royal nobility.<br>"
			dat += "A <font color='#aa0202'>ᛣ</font> symbol indicates an <b>INHUMEN</b> race, beings of origins other than <b>PSYDON</b>.<br>"
			dat += "These races are not eligible for royal nobility."
			to_chat(user, jointext(dat, ""))
			return TRUE

		if("set_origin")
			var/list/virtue_choices = list()
			for(var/path as anything in GLOB.virtues)
				var/datum/virtue/V = GLOB.virtues[path]
				if(!V?.name)
					continue
				if(prefs.virtue_origin && V.name == prefs.virtue_origin.name)
					continue
				if(!istype(V, /datum/virtue/origin))
					continue
				if(V.restricted && (prefs.pref_species.type in V.races))
					continue
				if(istype(V, /datum/virtue/origin/racial) && !(prefs.pref_species.type in V.races))
					continue
				virtue_choices[V.name] = V
			var/picked = tgui_input_list(user, "From where do you come?", "ORIGINS", virtue_choices)
			if(picked)
				var/datum/virtue/virtue_chosen = virtue_choices[picked]
				prefs.virtue_origin = virtue_chosen
				to_chat(user, prefs.process_virtue_text(virtue_chosen))
				if(virtue_chosen.uniquefaith)
					var/datum/virtue/origin/origin_chosen = virtue_chosen
					prefs.selected_patron = GLOB.patronlist[origin_chosen.uniquefaith[1].godhead]
				else
					prefs.selected_patron = GLOB.patronlist[/datum/patron/divine/astrata]
				// Origin swap invalidates faith options (uniquefaith), extra_language options,
				// patron options (selected_patron may flip), and job availability (virtue_restrictions).
				on_identity_change(TRUE)
			return TRUE

		if("set_origin_direct")
			var/picked = params["name"]
			if(!picked)
				return TRUE
			for(var/path as anything in GLOB.virtues)
				var/datum/virtue/V = GLOB.virtues[path]
				if(!V?.name || V.name != picked)
					continue
				if(!istype(V, /datum/virtue/origin))
					continue
				if(V.restricted && (prefs.pref_species?.type in V.races))
					continue
				if(istype(V, /datum/virtue/origin/racial) && !(prefs.pref_species?.type in V.races))
					continue
				prefs.virtue_origin = V
				// Auto-print is suppressed — the (i) tooltip button next to the
				// Origin Dropdown invokes show_origin_help on demand instead.
				if(V.uniquefaith)
					var/datum/virtue/origin/origin_chosen = V
					prefs.selected_patron = GLOB.patronlist[origin_chosen.uniquefaith[1].godhead]
				else
					prefs.selected_patron = GLOB.patronlist[/datum/patron/divine/astrata]
				on_identity_change(TRUE)
				return TRUE
			return TRUE

		if("show_origin_help")
			if(!prefs.virtue_origin)
				to_chat(user, span_info("No origin selected."))
				return TRUE
			to_chat(user, prefs.process_virtue_text(prefs.virtue_origin))
			return TRUE

		if("show_virtue_desc")
			if(!prefs.virtue)
				to_chat(user, span_info("No virtue selected."))
				return TRUE
			to_chat(user, prefs.process_virtue_text(prefs.virtue))
			return TRUE

		if("show_virtuetwo_desc")
			if(!prefs.virtuetwo)
				to_chat(user, span_info("No second virtue selected."))
				return TRUE
			to_chat(user, prefs.process_virtue_text(prefs.virtuetwo))
			return TRUE

		if("show_charflaw_desc")
			if(!prefs.charflaw)
				to_chat(user, span_info("No vice selected."))
				return TRUE
			if(prefs.charflaw.desc)
				to_chat(user, "<font size = 3>[span_purple(prefs.charflaw.desc)]</font>")
			else
				to_chat(user, span_info("No description available for this vice."))
			return TRUE

		if("show_patron_desc")
			if(!prefs.selected_patron)
				to_chat(user, span_info("No patron selected."))
				return TRUE
			var/datum/patron/p = prefs.selected_patron
			to_chat(user, "<font color='yellow'>Patron: [p.name]</font>")
			if(p.domain)
				to_chat(user, "Domain: [p.domain]")
			if(p.desc)
				to_chat(user, "<font size = 3>[span_purple(p.desc)]</font>")
			if(p.worshippers)
				to_chat(user, "<font color='red'>Likely Worshippers: [p.worshippers]</font>")
			return TRUE

		// --- Body actions ---

		if("toggle_update_mutant_colors")
			prefs.update_mutant_colors = !prefs.update_mutant_colors
			on_identity_change()
			return TRUE

		if("set_skin_tone")
			if(!prefs.pref_species?.use_skintones)
				return TRUE
			var/list/listy = prefs.pref_species.get_skin_list()
			var/picked = tgui_input_list(user, "Choose your character's skin tone:", "SKINTONE", listy)
			if(picked)
				prefs.skin_tone = listy[picked]
				prefs.try_update_mutant_colors()
				on_identity_change()
			return TRUE

		if("set_skin_tone_direct")
			if(!prefs.pref_species?.use_skintones)
				return TRUE
			var/picked = params["name"]
			if(!picked)
				return TRUE
			var/list/listy = prefs.pref_species.get_skin_list()
			if(!(picked in listy))
				return TRUE
			prefs.skin_tone = listy[picked]
			// "Update Colors With Change" off: persist the ancestry pick so the
			// dropdown remembers it, but skip refresh_preview() so the body
			// color the user already has stays put. Caveat: any other action
			// that triggers on_identity_change (species swap, slot reload)
			// will snap the body to the new ancestry's color.
			if(!prefs.update_mutant_colors)
				SStgui.update_uis(src)
				return TRUE
			prefs.try_update_mutant_colors()
			on_identity_change()
			return TRUE

		if("show_skin_color_ref")
			var/list/dat = list()
			dat += "Skin color codes reference list<br><br>"
			for(var/tone in prefs.pref_species?.get_skin_list_tooltip())
				dat += "[tone]<br>"
			to_chat(user, jointext(dat, ""))
			return TRUE

		if("set_mutant_color")
			var/index = text2num(params["index"])
			if(!(index in list(1, 2, 3)))
				return TRUE
			var/key = (index == 1) ? "mcolor" : "mcolor[index]"
			var/picked = color_pick_sanitized(user, "Choose your character's mutant #[index] color:", "Character Preference", "#" + (prefs.features?[key] || "ffffff"))
			if(picked)
				prefs.features[key] = sanitize_hexcolor(picked)
				prefs.try_update_mutant_colors()
				on_identity_change()
			return TRUE

		if("set_skin_choice_pick")
			// LAMIAN_TAIL variant: prompt custom vs predefined.
			if(!(LAMIAN_TAIL in prefs.pref_species?.species_traits))
				return TRUE
			var/prompt = tgui_alert(user, "Choose skin/scales color", "Skin / Scales", list("Custom", "Predefined"))
			if(prompt == "Custom")
				var/picked = color_pick_sanitized(user, "Choose your character's skin/scale color:", "Character Preference", "#" + (prefs.features?["mcolor"] || "ffffff"))
				if(picked)
					prefs.features["mcolor"] = sanitize_hexcolor(picked)
					prefs.try_update_mutant_colors()
					on_identity_change()
			else if(prompt == "Predefined")
				var/list/listy = prefs.pref_species.get_skin_list()
				var/picked = tgui_input_list(user, "Choose your character's skin tone:", "Sun", listy)
				if(picked)
					prefs.features["mcolor"] = listy[picked]
					prefs.try_update_mutant_colors()
					on_identity_change()
			return TRUE

		if("set_skin_feathers_pick")
			// HARPY variant.
			if(!(HARPY in prefs.pref_species?.species_traits))
				return TRUE
			var/prompt = tgui_alert(user, "Choose skin/feathers color", "Skin / Feathers", list("Custom", "Predefined"))
			if(prompt == "Custom")
				var/picked = color_pick_sanitized(user, "Choose your character's skin/feathers color:", "Character Preference", "#" + (prefs.features?["mcolor"] || "ffffff"))
				if(picked)
					prefs.features["mcolor"] = sanitize_hexcolor(picked)
					prefs.try_update_mutant_colors()
					on_identity_change()
			else if(prompt == "Predefined")
				var/list/listy = prefs.pref_species.get_skin_list()
				var/picked = tgui_input_list(user, "Choose your character's skin tone:", "Sun", listy)
				if(picked)
					prefs.features["mcolor"] = listy[picked]
					prefs.try_update_mutant_colors()
					on_identity_change()
			return TRUE

		if("set_voice_color")
			// Use the TGUI-native color picker (ColorPickerModal) instead of
			// BYOND's OS-native color dialog — keeps the picker in-game and
			// gives the user HSV/RGB inputs + presets.
			var/picked = tgui_color_picker(user, "Choose your character's voice color:", "Voice Color", prefs.voice_color)
			if(picked)
				if(color_hex2num(picked) < 230)
					to_chat(user, "<font color='red'>This voice color is too dark for mortals.</font>")
					return TRUE
				prefs.voice_color = sanitize_hexcolor(picked)
				on_identity_change()
			return TRUE

		if("set_highlight_color")
			var/picked = tgui_color_picker(user, "Choose your character's nickname highlight color:", "Nickname Highlight Color", prefs.highlight_color)
			if(picked)
				prefs.highlight_color = sanitize_hexcolor(picked)
				on_identity_change()
			return TRUE

		if("set_voice_pitch")
			var/picked = tgui_input_number(user, "Choose voice pitch ([MIN_VOICE_PITCH] to [MAX_VOICE_PITCH], lower is deeper):", "Voice Pitch", prefs.voice_pitch, MAX_VOICE_PITCH, MIN_VOICE_PITCH)
			if(picked)
				prefs.voice_pitch = picked
				on_identity_change()
			return TRUE

		if("set_voice_pitch_direct")
			var/raw = params["value"]
			if(isnull(raw))
				return TRUE
			var/picked = text2num("[raw]")
			if(isnull(picked))
				return TRUE
			picked = clamp(picked, MIN_VOICE_PITCH, MAX_VOICE_PITCH)
			prefs.voice_pitch = picked
			on_identity_change()
			return TRUE

		if("set_char_accent")
			var/picked = tgui_input_list(user, "Choose your character's accent:", "Character Preference", GLOB.character_accents, prefs.char_accent)
			if(picked)
				prefs.char_accent = picked
				on_identity_change()
			return TRUE

		if("set_char_accent_direct")
			var/picked = params["name"]
			if(!picked || !(picked in GLOB.character_accents))
				return TRUE
			prefs.char_accent = picked
			on_identity_change()
			return TRUE

		// --- Markings actions ---

		if("markings_use_preset")
			var/confirm = tgui_alert(user, "Use a preset? This will clear your existing markings.", "Markings Preset", list("Yes", "No"))
			if(confirm != "Yes")
				return TRUE
			var/list/candidates = marking_sets_for_species(prefs.pref_species)
			if(!length(candidates))
				return TRUE
			var/picked = tgui_input_list(user, "Choose your new body markings:", "Markings Preset", candidates)
			if(picked)
				var/datum/body_marking_set/BMS = GLOB.body_marking_sets[picked]
				prefs.body_markings = assemble_body_markings_from_set(BMS, prefs.features, prefs.pref_species)
				on_identity_change()
			return TRUE

		if("markings_clear_all")
			var/confirm = tgui_alert(user, "Clear ALL body markings from every zone? This cannot be undone.", "Clear Markings", list("Yes", "No"))
			if(confirm != "Yes")
				return TRUE
			prefs.body_markings = list()
			on_identity_change()
			return TRUE

		if("marking_add")
			var/zone = params["zone"]
			if(!GLOB.body_markings_per_limb[zone])
				return TRUE
			var/list/possible = marking_list_of_zone_for_species(zone, prefs.pref_species)
			if(prefs.body_markings?[zone])
				if(length(prefs.body_markings[zone]) >= MAXIMUM_MARKINGS_PER_LIMB)
					return TRUE
				for(var/keyed_name in prefs.body_markings[zone])
					possible -= keyed_name
			if(!length(possible))
				to_chat(user, span_warning("No markings available for this zone."))
				return TRUE
			var/picked = tgui_input_list(user, "Choose your new marking to add:", "Add Marking", possible)
			if(picked)
				var/datum/body_marking/BD = GLOB.body_markings[picked]
				if(!prefs.body_markings[zone])
					prefs.body_markings[zone] = list()
				prefs.body_markings[zone][BD.name] = BD.get_default_color(prefs.features, prefs.pref_species)
				on_identity_change()
			return TRUE

		// Inline-dropdown variants of marking_add / marking_change. The React UI
		// hands us the picked name directly, sparing the user a tgui_input_list
		// popup. Backend still validates the name against the candidate pool.
		if("marking_add_direct")
			var/zone = params["zone"]
			var/picked = params["name"]
			if(!zone || !picked || !GLOB.body_markings_per_limb[zone])
				return TRUE
			var/list/possible = marking_list_of_zone_for_species(zone, prefs.pref_species)
			if(prefs.body_markings?[zone])
				if(length(prefs.body_markings[zone]) >= MAXIMUM_MARKINGS_PER_LIMB)
					return TRUE
				for(var/keyed_name in prefs.body_markings[zone])
					possible -= keyed_name
			if(!(picked in possible))
				return TRUE
			var/datum/body_marking/BD = GLOB.body_markings[picked]
			if(!BD)
				return TRUE
			if(!prefs.body_markings[zone])
				prefs.body_markings[zone] = list()
			prefs.body_markings[zone][BD.name] = BD.get_default_color(prefs.features, prefs.pref_species)
			on_identity_change()
			return TRUE

		if("marking_change_direct")
			var/zone = params["zone"]
			var/changing_name = params["from"]
			var/picked = params["to"]
			if(!zone || !changing_name || !picked)
				return TRUE
			var/list/possible = marking_list_of_zone_for_species(zone, prefs.pref_species)
			if(prefs.body_markings?[zone])
				for(var/keyed_name in prefs.body_markings[zone])
					if(keyed_name == changing_name)
						continue
					possible -= keyed_name
			if(!(picked in possible))
				return TRUE
			if(!prefs.body_markings[zone] || !prefs.body_markings[zone][changing_name])
				return TRUE
			var/held_index = LAZYFIND(prefs.body_markings[zone], changing_name)
			var/datum/body_marking/BD = GLOB.body_markings[picked]
			if(!BD)
				return TRUE
			var/marking_content = BD.get_default_color(prefs.features, prefs.pref_species)
			prefs.body_markings[zone] -= changing_name
			prefs.body_markings[zone].Insert(held_index, picked)
			prefs.body_markings[zone][picked] = marking_content
			on_identity_change()
			return TRUE

		if("marking_remove")
			var/zone = params["zone"]
			var/name = params["name"]
			if(!prefs.body_markings?[zone] || !prefs.body_markings[zone][name])
				return TRUE
			prefs.body_markings[zone] -= name
			if(!length(prefs.body_markings[zone]))
				prefs.body_markings -= zone
			on_identity_change()
			return TRUE

		if("marking_change")
			var/zone = params["zone"]
			var/changing_name = params["name"]
			var/list/possible = marking_list_of_zone_for_species(zone, prefs.pref_species)
			if(prefs.body_markings?[zone])
				for(var/keyed_name in prefs.body_markings[zone])
					possible -= keyed_name
			if(!length(possible))
				return TRUE
			var/picked = tgui_input_list(user, "Choose a marking to change the current one to:", "Change Marking", possible)
			if(!picked)
				return TRUE
			if(!prefs.body_markings[zone] || !prefs.body_markings[zone][changing_name])
				return TRUE
			var/held_index = LAZYFIND(prefs.body_markings[zone], changing_name)
			var/datum/body_marking/BD = GLOB.body_markings[picked]
			var/marking_content = BD.get_default_color(prefs.features, prefs.pref_species)
			prefs.body_markings[zone] -= changing_name
			prefs.body_markings[zone].Insert(held_index, picked)
			prefs.body_markings[zone][picked] = marking_content
			on_identity_change()
			return TRUE

		if("marking_color")
			var/zone = params["zone"]
			var/name = params["name"]
			if(!prefs.body_markings?[zone] || !prefs.body_markings[zone][name])
				return TRUE
			var/color = prefs.body_markings[zone][name]
			var/picked = color_pick_sanitized(user, "Choose your markings color:", "Marking Color", "#[color]")
			if(picked)
				if(!prefs.body_markings[zone] || !prefs.body_markings[zone][name])
					return TRUE
				prefs.body_markings[zone][name] = sanitize_hexcolor(picked, 6)
				on_identity_change()
			return TRUE

		if("marking_reset_color")
			var/zone = params["zone"]
			var/name = params["name"]
			if(!prefs.body_markings?[zone] || !prefs.body_markings[zone][name])
				return TRUE
			var/datum/body_marking/BM = GLOB.body_markings[name]
			prefs.body_markings[zone][name] = BM.get_default_color(prefs.features, prefs.pref_species)
			on_identity_change()
			return TRUE

		if("marking_move_up")
			var/zone = params["zone"]
			var/name = params["name"]
			var/list/marking_list = LAZYACCESS(prefs.body_markings, zone)
			var/current_index = LAZYFIND(marking_list, name)
			if(!current_index || --current_index < 1)
				return TRUE
			var/marking_content = marking_list[name]
			marking_list -= name
			marking_list.Insert(current_index, name)
			marking_list[name] = marking_content
			on_identity_change()
			return TRUE

		// --- Customizers actions ---

		if("customizer_toggle")
			var/customizer_type = text2path(params["customizer_type"])
			var/datum/customizer/customizer = CUSTOMIZER(customizer_type)
			if(!customizer?.allows_disabling)
				return TRUE
			var/datum/customizer_entry/entry = prefs.get_customizer_entry_for_customizer_type(customizer_type)
			if(!entry)
				return TRUE
			entry.disabled = !entry.disabled
			on_identity_change()
			return TRUE

		if("customizer_change_choice")
			var/customizer_type = text2path(params["customizer_type"])
			var/datum/customizer/customizer = CUSTOMIZER(customizer_type)
			if(!customizer)
				return TRUE
			var/datum/customizer_entry/entry = prefs.get_customizer_entry_for_customizer_type(customizer_type)
			if(!entry)
				return TRUE
			var/datum/customizer_choice/current_choice = CUSTOMIZER_CHOICE(entry.customizer_choice_type)
			var/list/choice_list = list()
			for(var/choice_type in customizer.customizer_choices)
				var/datum/customizer_choice/iter_choice = CUSTOMIZER_CHOICE(choice_type)
				choice_list[iter_choice.name] = choice_type
			var/picked = tgui_input_list(user, "Choose your [lowertext(customizer.name)]:", "Character Preference", choice_list, current_choice?.name)
			if(!picked)
				return TRUE
			var/chosen_choice_type = choice_list[picked]
			if(chosen_choice_type == entry.customizer_choice_type)
				return TRUE
			prefs.customizer_entries -= entry
			prefs.customizer_entries += customizer.create_customizer_entry(prefs, chosen_choice_type)
			on_identity_change()
			return TRUE

		if("customizer_change_choice_direct")
			var/customizer_type = text2path(params["customizer_type"])
			var/datum/customizer/customizer = CUSTOMIZER(customizer_type)
			if(!customizer)
				return TRUE
			var/datum/customizer_entry/entry = prefs.get_customizer_entry_for_customizer_type(customizer_type)
			if(!entry)
				return TRUE
			var/picked = params["name"]
			if(!picked)
				return TRUE
			for(var/choice_type in customizer.customizer_choices)
				var/datum/customizer_choice/iter_choice = CUSTOMIZER_CHOICE(choice_type)
				if(iter_choice?.name != picked)
					continue
				if(choice_type == entry.customizer_choice_type)
					return TRUE
				prefs.customizer_entries -= entry
				prefs.customizer_entries += customizer.create_customizer_entry(prefs, choice_type)
				on_identity_change()
				return TRUE
			return TRUE

		if("customizer_open_classic")
			// Escape hatch: open the classic Customizers browser popup. Kept around
			// in case the structured pickers fail or someone wants the wide HTML view.
			prefs.ShowCustomizers(user)
			return TRUE

		if("customizer_action")
			// Generic router: re-uses classic handle_customizer_topic by reconstructing
			// the href_list with customizer_type / customizer_task / any extra params.
			var/customizer_type_str = params["customizer_type"]
			var/customizer_task = params["customizer_task"]
			if(!customizer_type_str || !customizer_task)
				return TRUE
			var/list/href_list = list(
				"task" = "change_customizer",
				"customizer" = customizer_type_str,
				"customizer_task" = customizer_task,
			)
			// rotate direction (prev/next)
			if(params["rotate"])
				href_list["rotate"] = params["rotate"]
			// color index for acc_color
			if(params["color_index"])
				href_list["color_index"] = params["color_index"]
			// Pre-picked value from an inline Dropdown — handle_topic cases that
			// support direct picks honor this in lieu of opening their popup.
			if(params["picked_name"])
				href_list["picked_name"] = params["picked_name"]
			prefs.handle_customizer_topic(user, href_list)
			on_identity_change()
			return TRUE

		if("customizers_reset_all_colors")
			prefs.reset_all_customizer_accessory_colors()
			on_identity_change()
			return TRUE

		if("customizers_randomize_all")
			// "Randomize All" covers every appearance section below the
			// Customizers heading on the Features tab: Customizers (accessory
			// entries), Body (skin tone + mutant colors), and Markings.
			// Voice/pitch/accent/sprite-scale aren't randomized — those are
			// personal preferences, not appearance characteristics.
			prefs.randomize_all_customizer_accessories()
			// Cosmetics that default to disabled stay invisible after the
			// underlying entry randomizes unless we also flip them on.
			// Force-enable these four so the user actually sees the result.
			var/static/list/force_enable_on_randomize = list("Accessory", "Face Detail", "Legwear", "Underwear")
			for(var/datum/customizer_entry/entry as anything in prefs.customizer_entries)
				var/datum/customizer_choice/choice = CUSTOMIZER_CHOICE(entry.customizer_choice_type)
				if(choice?.name in force_enable_on_randomize)
					entry.disabled = FALSE
			if(prefs.pref_species)
				if(prefs.pref_species.use_skintones)
					var/list/skins = prefs.pref_species.get_skin_list()
					if(length(skins))
						prefs.skin_tone = skins[pick(skins)]
				prefs.features = prefs.pref_species.get_random_features()
				prefs.body_markings = prefs.pref_species.get_random_body_markings(prefs.features)
			on_identity_change()
			return TRUE

		// --- Game / OOC prefs toggles ---

		if("toggle_stat_simple")
			prefs.stat_simple = !prefs.stat_simple
			on_identity_change()
			return TRUE

		if("toggle_tgui_lock")
			prefs.tgui_lock = !prefs.tgui_lock
			on_identity_change()
			return TRUE

		if("toggle_hotkeys")
			prefs.hotkeys = !prefs.hotkeys
			user.client?.set_macros()
			// Hotkey mode flips default_keys for every keybind in the catalog.
			on_identity_change(TRUE)
			return TRUE

		if("set_clientfps")
			var/desiredfps = tgui_input_number(user, "Choose your desired fps. (0 = synced with server tick rate, currently:[world.fps])", "Client FPS", prefs.clientfps, 240, 0)
			if(isnull(desiredfps))
				return TRUE
			prefs.clientfps = desiredfps
			prefs.parent?.fps = desiredfps
			on_identity_change()
			return TRUE

		if("toggle_ambientocclusion")
			prefs.ambientocclusion = !prefs.ambientocclusion
			on_identity_change()
			return TRUE

		if("toggle_schizo_voice")
			prefs.toggles ^= SCHIZO_VOICE
			on_identity_change()
			return TRUE

		if("toggle_special_role")
			var/role = params["role"]
			if(!role)
				return TRUE
			if(is_banned_from(user.ckey, role))
				return TRUE
			if(role in prefs.be_special)
				prefs.be_special -= role
			else
				prefs.be_special += role
			on_identity_change()
			return TRUE

		if("toggle_winflash")
			prefs.windowflashing = !prefs.windowflashing
			on_identity_change()
			return TRUE

		if("toggle_hear_midis")
			prefs.toggles ^= SOUND_MIDI
			on_identity_change()
			return TRUE

		if("toggle_lobby_music")
			prefs.toggles ^= SOUND_LOBBY
			if((prefs.toggles & SOUND_LOBBY) && user.client && isnewplayer(user))
				user.client.playtitlemusic()
			else
				user.stop_sound_channel(CHANNEL_LOBBYMUSIC)
			on_identity_change()
			return TRUE

		if("toggle_pull_requests")
			prefs.chat_toggles ^= CHAT_PULLR
			on_identity_change()
			return TRUE

		if("toggle_byond_publicity")
			if(prefs.unlock_content)
				prefs.toggles ^= MEMBER_PUBLIC
				on_identity_change()
			return TRUE

		if("toggle_tgui_pref")
			// Escape hatch: flips tgui_pref off + closes the TGUI window so the
			// classic browser UI takes over on the next prefs interaction. Lets
			// users recover when the TGUI bundle won't render correctly.
			prefs.tgui_pref = FALSE
			SStgui.close_uis(src)
			prefs.ShowChoices(user)
			return TRUE

		if("cycle_tgui_theme")
			// Cycle to the next theme in /datum/preferences/proc/setTguiStyle
			// and push a UI update so the new palette propagates immediately.
			// setTguiStyle calls save_preferences() on its own so the theme
			// pick persists immediately — it's a one-click choice rather than
			// part of the character editor's Save-button flow.
			prefs.setTguiStyle(user)
			SStgui.update_uis(src)
			return TRUE

		// --- Admin OOC toggles. Each handler gates on user.client.holder so
		// non-admins can't fire them by hand-crafting ui_act calls. ---

		if("admin_toggle_adminhelps")
			if(!user.client?.holder)
				return TRUE
			user.client.toggleadminhelpsound()
			on_identity_change()
			return TRUE

		if("admin_toggle_hear_prayers")
			if(!user.client?.holder)
				return TRUE
			user.client.toggle_prayer_sound()
			on_identity_change()
			return TRUE

		if("admin_toggle_announce_login")
			if(!user.client?.holder)
				return TRUE
			user.client.toggleannouncelogin()
			on_identity_change()
			return TRUE

		if("admin_toggle_combohud")
			if(!user.client?.holder)
				return TRUE
			prefs.toggles ^= COMBOHUD_LIGHTING
			on_identity_change()
			return TRUE

		if("admin_toggle_dead_chat")
			if(!user.client?.holder)
				return TRUE
			user.client.deadchat()
			on_identity_change()
			return TRUE

		if("admin_toggle_radio_chatter")
			if(!user.client?.holder)
				return TRUE
			user.client.toggle_hear_radio()
			on_identity_change()
			return TRUE

		if("admin_toggle_prayers")
			if(!user.client?.holder)
				return TRUE
			user.client.toggleprayers()
			on_identity_change()
			return TRUE

		if("admin_set_asaycolor")
			if(!user.client?.holder)
				return TRUE
			if(!CONFIG_GET(flag/allow_admin_asaycolor))
				return TRUE
			var/picked = color_pick_sanitized(user, "Choose your ASAY color:", "Game Preference", prefs.asaycolor)
			if(picked)
				prefs.asaycolor = picked
				on_identity_change()
			return TRUE

		if("admin_toggle_deadmin_always")
			if(!user.client?.holder)
				return TRUE
			if(CONFIG_GET(flag/auto_deadmin_players))
				return TRUE
			prefs.toggles ^= DEADMIN_ALWAYS
			on_identity_change()
			return TRUE

		if("admin_toggle_deadmin_antag")
			if(!user.client?.holder)
				return TRUE
			if(CONFIG_GET(flag/auto_deadmin_antagonists))
				return TRUE
			prefs.toggles ^= DEADMIN_ANTAGONIST
			on_identity_change()
			return TRUE

		if("admin_toggle_deadmin_head")
			if(!user.client?.holder)
				return TRUE
			if(CONFIG_GET(flag/auto_deadmin_heads))
				return TRUE
			prefs.toggles ^= DEADMIN_POSITION_HEAD
			on_identity_change()
			return TRUE

		if("open_keybinds_editor")
			// Legacy escape hatch — opens the classic key-capture popup.
			prefs.SetKeybinds(user)
			return TRUE

		if("open_familiar_prefs")
			// Switch to the in-window Familiar tab.
			active_tab = "familiar"
			SStgui.update_uis(src)
			return TRUE

		if("open_gnoll_prefs")
			// Switch to the in-window Gnoll tab.
			active_tab = "gnoll"
			SStgui.update_uis(src)
			return TRUE

		// --- Familiar prefs actions: defer to fam_process_link by reconstructing href_list ---

		if("familiar_action")
			var/datum/familiar_prefs/fp = prefs.familiar_prefs
			if(!fp)
				return TRUE
			var/list/href_list = list("task" = params["task"] || "input", "preference" = params["preference"])
			// Pre-picked Dropdown value — fam_process_link's familiar_specie and
			// familiar_pronouns cases honor this in lieu of opening a popup.
			if(params["picked_name"])
				href_list["picked_name"] = params["picked_name"]
			fp.fam_process_link(user, href_list, from_tgui = TRUE)
			on_identity_change()
			return TRUE

		// --- Gnoll prefs actions: defer to gnoll_process_link ---

		if("gnoll_action")
			var/datum/gnoll_prefs/gp = prefs.gnoll_prefs
			if(!gp)
				return TRUE
			var/list/href_list = list("action" = params["gaction"])
			if(params["slot"])
				href_list["slot"] = params["slot"]
			if(params["genital"])
				href_list["genital"] = params["genital"]
			if(params["toggle"])
				href_list["toggle"] = params["toggle"]
			// Pre-picked Dropdown value — handled by choose_pronouns / choose_pelt
			// / choose_descriptor inside gnoll_process_link in lieu of a popup.
			if(params["picked_name"])
				href_list["picked_name"] = params["picked_name"]
			gp.gnoll_process_link(user, href_list, from_tgui = TRUE)
			on_identity_change()
			return TRUE

		if("open_pq_menu")
			check_pq_menu(user.ckey)
			return TRUE

		if("open_triumphs_list")
			user.show_triumphs_list()
			return TRUE

		if("open_triumph_buy_menu")
			SStriumphs.startup_triumphs_menu(user.client)
			return TRUE

		if("agevet_info")
			if(!user.check_agevet())
				to_chat(user, span_warning("You are not Age Verified. Open a ticket in Discord with valid ID to get verified."))
			else
				to_chat(user, span_nicegreen("You are already Age Verified."))
			return TRUE

		// --- Lobby / round-state actions ---

		if("toggle_ready")
			var/mob/dead/new_player/np = user
			if(!istype(np))
				return TRUE
			if(SSticker.current_state > GAME_STATE_PREGAME)
				return TRUE
			// Mirror new_player.Topic ready=X validation.
			if(np.ready == PLAYER_READY_TO_PLAY)
				if(SSticker.job_change_locked)
					return TRUE
				np.ready = PLAYER_NOT_READY
			else
				// Single source of truth shared with the header's
				// ready_block_reason field (which disables the React button
				// + shows the reason in the tooltip). Server-side gate kept
				// as a defense in case the client bypasses the disabled flag.
				var/block_reason = compute_ready_block_reason()
				if(block_reason)
					to_chat(user, span_boldwarning(block_reason))
					return TRUE
				np.ready = PLAYER_READY_TO_PLAY
				log_game("([user || "NO KEY"]) readied as ([prefs.real_name])")
			// Push the roster change to every open menu (covers THIS user's
			// own header.player_ready flip AND the by-job bucket update that
			// other players need to see).
			notify_preference_menus_lobby_changed()
			return TRUE

		if("late_join")
			var/mob/dead/new_player/np = user
			if(!istype(np))
				return TRUE
			// Pre-flight: run the same eligibility checks the classic Topic handler
			// would, since AttemptLateSpawn doesn't (those gates live in Topic
			// itself). Refusal cases print to chat and return without opening the
			// picker, matching classic UX.
			if(!SSticker?.IsRoundInProgress())
				to_chat(user, span_boldwarning("The game is starting. You cannot join yet."))
				return TRUE
			if(prefs.is_active_migrant())
				to_chat(user, span_boldwarning("You are in the migrant queue."))
				return TRUE
			var/timetojoin = 5 MINUTES
#ifdef ALLOWPLAY
			timetojoin = 1 SECONDS
#endif
#ifdef TESTSERVER
			timetojoin = 0
#endif
			if(SSticker.round_start_time && world.time < SSticker.round_start_time + timetojoin)
				var/ttime = round((SSticker.round_start_time + timetojoin - world.time) / 10)
				to_chat(user, span_warning("Late-joining is not yet possible. ([ttime])"))
				return TRUE
			np.open_late_join_choices()
			return TRUE

		if("save_character")
			if(!prefs.path)
				to_chat(user, span_warning("Save failed — your savefile is not available (guests cannot save)."))
				return TRUE
			// Only path that writes character data to disk. Mutations are
			// in-memory only until the user clicks here — matches the classic
			// browser UI's behavior.
			var/prefs_ok = prefs.save_preferences()
			var/char_ok = prefs.save_character()
			if(prefs_ok && char_ok)
				to_chat(user, span_notice("Saved to slot [prefs.default_slot]: [prefs.real_name]."))
				// Refresh the cached slot name so the dropdown picks up the
				// new label on the next poll. No disk re-read — just write
				// what we know we just saved. Drop the assembled options
				// list too so the next poll re-builds it from the fresh name.
				if(!cached_slot_names)
					cached_slot_names = list()
				cached_slot_names["[prefs.default_slot]"] = prefs.real_name || "Slot [prefs.default_slot]"
				cached_slot_options = null
			else
				to_chat(user, span_warning("Save failed — check savefile permissions."))
			SStgui.update_uis(src)
			return TRUE

		if("load_character")
			if(!prefs.path)
				to_chat(user, span_warning("Undo failed — no savefile available (guests can't save or load)."))
				return TRUE
			prefs.load_preferences()
			if(!prefs.load_character())
				to_chat(user, span_warning("Undo failed — no saved data for slot [prefs.default_slot]."))
				return TRUE
			to_chat(user, span_notice("Reverted slot [prefs.default_slot] to last saved: [prefs.real_name]."))
			// Refresh preview + UI WITHOUT calling on_identity_change — that would
			// immediately save_character() back, undoing the undo for any in-memory
			// state that didn't survive the disk round-trip. Load may swap species/
			// origin/etc, so push a full static refresh so dependent option lists
			// re-derive against the freshly loaded prefs.
			refresh_preview(prefs.parent?.mob)
			refresh_static_data()
			return TRUE

		if("change_slot")
			var/new_slot = text2num(params["slot"])
			if(!new_slot)
				return TRUE
			new_slot = clamp(round(new_slot), 1, prefs.max_save_slots)
			if(new_slot == prefs.default_slot)
				return TRUE
			// load_character bails early when the savefile doesn't exist yet — that
			// path leaves default_slot stale, so update it unconditionally here so the
			// dropdown reflects the user's pick even on a fresh/empty savefile.
			prefs.default_slot = new_slot
			if(prefs.load_character(new_slot))
				to_chat(user, span_notice("Loaded character slot [new_slot]: [prefs.real_name]."))
			else
				// Empty slot — give the user a fresh randomized starting point to edit, but
				// do NOT auto-save. The slot stays nameless in the dropdown until the user
				// clicks Save themselves.
				prefs.random_character()
				to_chat(user, span_notice("Switched to empty slot [new_slot]. Edit and click Save to commit."))
			// Refresh preview + UI directly, bypassing on_identity_change() — that proc
			// calls save_character() which would persist the randomized data and lock
			// the slot's name in the dropdown before the user gets a chance to edit.
			// New slot means new species/origin/etc — push a full static refresh.
			refresh_preview(prefs.parent?.mob)
			refresh_static_data()
			return TRUE

		if("open_migration")
			prefs.migrant?.show_ui()
			return TRUE

		if("open_manifest")
			prefs.parent?.view_actors_manifest()
			return TRUE

		if("become_observer")
			var/mob/dead/new_player/np = user
			if(istype(np))
				np.make_me_an_observer()
			return TRUE

		if("set_keybind")
			// Mirrors classic keybindings_set: clears old binding (if any) and applies new full_key.
			var/kb_name = params["keybinding"]
			if(!kb_name)
				return TRUE
			var/clear_key = text2num("[params["clear_key"]]")
			var/old_key = params["old_key"]
			if(clear_key)
				if(prefs.key_bindings[old_key])
					prefs.key_bindings[old_key] -= kb_name
					if(!length(prefs.key_bindings[old_key]))
						prefs.key_bindings -= old_key
				user.client?.update_movement_keys()
				on_identity_change()
				return TRUE

			var/new_key = uppertext("[params["key"]]")
			var/AltMod = text2num("[params["alt"]]") ? "Alt" : ""
			var/CtrlMod = text2num("[params["ctrl"]]") ? "Ctrl" : ""
			var/ShiftMod = text2num("[params["shift"]]") ? "Shift" : ""
			var/numpad = text2num("[params["numpad"]]") ? "Numpad" : ""

			if(GLOB._kbMap[new_key])
				new_key = GLOB._kbMap[new_key]

			var/full_key
			switch(new_key)
				if("Alt")
					full_key = "[new_key][CtrlMod][ShiftMod]"
				if("Ctrl")
					full_key = "[AltMod][new_key][ShiftMod]"
				if("Shift")
					full_key = "[AltMod][CtrlMod][new_key]"
				else
					full_key = "[AltMod][CtrlMod][ShiftMod][numpad][new_key]"

			if(old_key && prefs.key_bindings[old_key])
				prefs.key_bindings[old_key] -= kb_name
				if(!length(prefs.key_bindings[old_key]))
					prefs.key_bindings -= old_key
			prefs.key_bindings[full_key] += list(kb_name)
			prefs.key_bindings[full_key] = sortList(prefs.key_bindings[full_key])
			user.client?.update_movement_keys()
			on_identity_change()
			return TRUE

		if("reset_keybinds")
			var/choice = tgui_alert(user, "Reset all keybindings to default? Pick the layout you want.", "Reset Keybindings", list("Hotkeys", "Classic", "Cancel"))
			if(choice == "Cancel" || !choice)
				return TRUE
			prefs.hotkeys = (choice == "Hotkeys")
			prefs.key_bindings = prefs.hotkeys ? deepCopyList(GLOB.hotkey_keybinding_list_by_key) : deepCopyList(GLOB.classic_keybinding_list_by_key)
			user.client?.update_movement_keys()
			on_identity_change()
			return TRUE

		// --- Flavor actions ---

		if("edit_flavortext")
			to_chat(user, "<span class='notice'><span class='bold'>Flavortext should not include nonphysical nonsensory attributes such as backstory or the character's internal thoughts.</span></span>")
			var/new_text = tgui_input_text(user, "Input your character description:", "Flavortext", prefs.flavortext, multiline = TRUE, encode = FALSE, bigmodal = TRUE)
			if(isnull(new_text))
				return TRUE
			if(new_text == "")
				prefs.flavortext = null
				prefs.flavortext_display = null
				prefs.is_legacy = FALSE
			else
				prefs.flavortext = new_text
				var/ft = html_encode(new_text)
				ft = replacetext(parsemarkdown_basic(ft), "\n", "<BR>")
				prefs.flavortext_display = ft
				prefs.is_legacy = FALSE
				to_chat(user, span_notice("Successfully updated flavortext"))
				log_game("[user] has set their flavortext.")
			on_identity_change()
			return TRUE

		if("edit_ooc_notes")
			to_chat(user, "<span class='notice'><span class='bold'>If you put 'anything goes' or 'no limits' here, do not be surprised if people take you up on it.</span></span>")
			var/new_text = tgui_input_text(user, "Input your OOC preferences:", "OOC notes", prefs.ooc_notes, multiline = TRUE, encode = FALSE, bigmodal = TRUE)
			if(isnull(new_text))
				return TRUE
			if(new_text == "")
				prefs.ooc_notes = null
				prefs.ooc_notes_display = null
				prefs.is_legacy = FALSE
			else
				prefs.ooc_notes = new_text
				var/ooc = html_encode(new_text)
				ooc = replacetext(parsemarkdown_basic(ooc), "\n", "<BR>")
				prefs.ooc_notes_display = ooc
				prefs.is_legacy = FALSE
				to_chat(user, span_notice("Successfully updated OOC notes."))
				log_game("[user] has set their OOC notes.")
			on_identity_change()
			return TRUE

		if("edit_rumour")
			to_chat(user, "<span class='notice'><span class='bold'>Rumours are things others might know, or think they know about you. They give players hints about how to interact with your character.</span></span>")
			var/new_text = tgui_input_text(user, "Input rumours about your character (400 character limit):", "Rumours", prefs.rumour, multiline = TRUE, encode = FALSE, bigmodal = TRUE)
			if(isnull(new_text))
				return TRUE
			if(new_text == "")
				prefs.rumour = null
				prefs.rumour_display = null
				prefs.is_legacy = FALSE
			else
				if(length(new_text) > 400)
					to_chat(user, span_warning("Rumours cannot exceed 400 characters."))
					return TRUE
				prefs.rumour = new_text
				var/r = html_encode(new_text)
				r = replacetext(parsemarkdown_basic(r), "\n", "<BR>")
				prefs.rumour_display = r
				prefs.is_legacy = FALSE
				to_chat(user, span_notice("Successfully updated Rumours"))
				log_game("[user] has set their rumour.")
			on_identity_change()
			return TRUE

		if("edit_gossip")
			to_chat(user, "<span class='notice'><span class='bold'>Gossip is rumours spread around Noble circles. Only other well-born individuals are aware of it.</span></span>")
			var/new_text = tgui_input_text(user, "Input noble gossip about your character (400 character limit):", "Noble Gossip", prefs.gossip, multiline = TRUE, encode = FALSE, bigmodal = TRUE)
			if(isnull(new_text))
				return TRUE
			if(new_text == "")
				prefs.gossip = null
				prefs.gossip_display = null
				prefs.is_legacy = FALSE
			else
				if(length(new_text) > 400)
					to_chat(user, span_warning("Noble gossip cannot exceed 400 characters."))
					return TRUE
				prefs.gossip = new_text
				var/g = html_encode(new_text)
				g = replacetext(parsemarkdown_basic(g), "\n", "<BR>")
				prefs.gossip_display = g
				prefs.is_legacy = FALSE
				to_chat(user, span_notice("Successfully updated Noble Gossip"))
				log_game("[user] has set their noble gossip.")
			on_identity_change()
			return TRUE

		if("edit_headshot")
			if(!user.check_agevet())
				to_chat(user, span_warning("You must be age-vetted to set a headshot."))
				return TRUE
			to_chat(user, span_notice("Please use a relatively SFW image of the head and shoulder area to maintain immersion. Do not use a real life photo or any image that is less than serious."))
			to_chat(user, span_notice("If the photo doesn't show up properly in-game, ensure that it's a direct image link that opens properly in a browser."))
			to_chat(user, span_notice("The photo will be downsized to 325x325 pixels — square images render best."))
			var/new_link = tgui_input_text(user, "Input the headshot link (https, hosts: gyazo, discord, lensdump, imgbox, catbox):", "Headshot", prefs.headshot_link, encode = FALSE)
			if(isnull(new_link))
				return TRUE
			if(new_link == "")
				prefs.headshot_link = null
				on_identity_change()
				return TRUE
			if(!valid_headshot_link(user, new_link))
				prefs.headshot_link = null
				on_identity_change()
				return TRUE
			prefs.headshot_link = new_link
			to_chat(user, span_notice("Successfully updated headshot picture"))
			log_game("[user] has set their Headshot image to '[new_link]'.")
			on_identity_change()
			return TRUE

		if("edit_nsfw_headshot")
			if(!user.check_agevet())
				to_chat(user, span_warning("You must be age-vetted to set an NSFW bodyshot."))
				return TRUE
			to_chat(user, span_notice("Finally a place to show it all."))
			var/new_link = tgui_input_text(user, "Input the NSFW bodyshot link (https, hosts: gyazo, lensdump, imgbox, catbox):", "NSFW Bodyshot", prefs.nsfw_headshot_link, encode = FALSE)
			if(isnull(new_link))
				return TRUE
			if(new_link == "")
				prefs.nsfw_headshot_link = null
				on_identity_change()
				return TRUE
			if(!valid_nsfw_headshot_link(user, new_link))
				prefs.nsfw_headshot_link = null
				on_identity_change()
				return TRUE
			prefs.nsfw_headshot_link = new_link
			to_chat(user, span_notice("Successfully updated NSFW Bodyshot picture"))
			log_game("[user] has set their NSFW Bodyshot image to '[new_link]'.")
			on_identity_change()
			return TRUE

		if("edit_ooc_extra")
			// Embeds an image/video/audio link at the bottom of the OOC notes. Logic mirrors the
			// legacy preferences.dm "ooc_extra" topic (which the new TGUI Flavor tab had dropped).
			if(!user.check_agevet())
				to_chat(user, span_warning("You must be age-vetted to set an OOC Extra."))
				return TRUE
			to_chat(user, span_notice("Add a link from a suitable host (catbox, etc) to an mp3, mp4, or jpg / png file to have it embed at the bottom of your OOC notes."))
			to_chat(user, span_notice("If the link doesn't show up properly in-game, ensure that it's a direct link that opens properly in a browser."))
			to_chat(user, span_notice("Videos will be shrunk to a ~300x300 square. Keep this in mind."))
			to_chat(user, "<font color = '#d6d6d6'>Leave a single space to delete it from your OOC notes.</font>")
			to_chat(user, "<font color ='red'>Abuse of this will get you banned.</font>")
			var/new_extra_link = tgui_input_text(user, "Input the accessory link (https, hosts: gyazo, discord, lensdump, imgbox, catbox):", "OOC Extra", prefs.ooc_extra_link, encode = FALSE)
			if(new_extra_link == null)
				return TRUE
			if(new_extra_link == "")
				return TRUE
			if(new_extra_link == " ") //Single space to delete
				prefs.ooc_extra_link = null
				prefs.ooc_extra = null
				to_chat(user, span_notice("Successfully deleted OOC Extra."))
				on_identity_change()
				return TRUE
			var/static/list/valid_extensions = list("jpg", "png", "jpeg", "gif", "mp4", "mp3")
			if(!valid_headshot_link(user, new_extra_link, FALSE, valid_extensions))
				return TRUE
			var/list/value_split = splittext(new_extra_link, ".")
			// extension will always be the last entry
			var/extension = value_split[length(value_split)]
			var/info
			if(extension in valid_extensions)
				prefs.ooc_extra_link = new_extra_link
				prefs.ooc_extra = "<div align ='center'><center>"
				if(extension == "jpg" || extension == "png" || extension == "jpeg" || extension == "gif")
					prefs.ooc_extra += "<br>"
					prefs.ooc_extra += "<img src='[prefs.ooc_extra_link]'/>"
					info = "an embedded image."
				else
					switch(extension)
						if("mp4")
							prefs.ooc_extra = "<br>"
							prefs.ooc_extra += "<video width=["288"] height=["288"] controls=["true"]>"
							prefs.ooc_extra += "<source src='[prefs.ooc_extra_link]' type=["video/mp4"]>"
							prefs.ooc_extra += "</video>"
							info = "a video."
						if("mp3")
							prefs.ooc_extra = "<br>"
							prefs.ooc_extra += "<audio controls>"
							prefs.ooc_extra += "<source src='[prefs.ooc_extra_link]' type=["audio/mp3"]>"
							prefs.ooc_extra += "Your browser does not support the audio element."
							prefs.ooc_extra += "</audio>"
							info = "embedded audio."
				prefs.ooc_extra += "</center></div>"
				to_chat(user, span_notice("Successfully updated OOC Extra with [info]"))
				log_game("[user] has set their OOC Extra to '[prefs.ooc_extra_link]'.")
				on_identity_change()
			return TRUE

		if("preview_examine")
			// Re-uses the classic browser preview popup verbatim.
			var/list/href_list = list("preference" = "ooc_preview", "task" = "input")
			prefs.process_link(user, href_list)
			return TRUE

		// --- Jobs actions ---

		if("set_job_level")
			if(SSticker.job_change_locked)
				to_chat(user, span_warning("Job preferences are locked for this round."))
				return TRUE
			var/role = params["role"]
			var/desired_level = params["level"]   // "high" | "medium" | "low" | "never"
			var/datum/job/job = SSjob.GetJob(role)
			if(!job)
				return TRUE
			var/jpval
			switch(desired_level)
				if("high")
					jpval = JP_HIGH
				if("medium")
					jpval = JP_MEDIUM
				if("low")
					jpval = JP_LOW
				else
					jpval = null
			// Low-PQ players may only set a required job to OFF or LOW — block medium/high. Crucially,
			// OFF (null) must be allowed too, so they can lower/disable the pref (the old check forced
			// null back up to LOW, trapping them at the role they can't actually lower).
			if(job.required && !isnull(job.min_pq) && (get_playerquality(user.ckey) < job.min_pq))
				if(jpval != JP_LOW && !isnull(jpval))
					var/used_name = job.title
					if((prefs.pronouns == SHE_HER || prefs.pronouns == THEY_THEM_F) && job.f_title)
						used_name = job.f_title
					to_chat(user, "<font color='red'>Your PQ is too low for [used_name] (Min PQ: [job.min_pq]); only LOW is allowed.</font>")
					jpval = JP_LOW
			prefs.SetJobPreferenceLevel(job, jpval)
			on_identity_change()
			return TRUE

		if("toggle_joblessrole")
			switch(prefs.joblessrole)
				if(RETURNTOLOBBY)
					prefs.joblessrole = BERANDOMJOB
				if(BERANDOMJOB)
					prefs.joblessrole = RETURNTOLOBBY
				else
					prefs.joblessrole = RETURNTOLOBBY
			on_identity_change()
			return TRUE

		if("reset_jobs")
			prefs.ResetJobs()
			on_identity_change()
			return TRUE

		if("show_job_tutorial")
			var/role = params["role"]
			var/datum/job/job = SSjob.GetJob(role)
			if(!job)
				return TRUE
			to_chat(user, span_info("* ----------------------- *"))
			to_chat(user, "<b>[job.title]</b>")
			to_chat(user, job.tutorial)
			if(job.spawn_positions)
				to_chat(user, "Slots: [job.spawn_positions][job.round_contrib_points ? " | RCP: +[job.round_contrib_points]" : ""]")
			to_chat(user, span_info("* ----------------------- *"))
			return TRUE

		if("show_class_explain")
			// Build the same HTML the classic /datum/job/Topic(explainjob)
			// classhelp popup uses — subclass list with their stats / traits
			// / skills / languages / spellpoints, class-level stats, stat
			// ceilings, class traits — and stash it on the menu datum so
			// JobsTab.tsx can render it inline via dangerouslySetInnerHTML
			// directly below the tutorial blurb.
			var/role = params["role"]
			var/datum/job/job = SSjob.GetJob(role)
			if(!job)
				return TRUE
			active_class_explain_title = job.title
			active_class_explain_html = job.build_class_explain_html()
			SStgui.update_uis(src)
			return TRUE

		if("clear_class_explain")
			// User backed out of the tutorial view — drop the cached payload.
			active_class_explain_title = null
			active_class_explain_html = null
			SStgui.update_uis(src)
			return TRUE

		if("check_job_ban")
			var/role = params["role"]
			// Classic relays via href bancheck=[rank] — we just echo the ban info into chat for now.
			if(is_banned_from(user.ckey, role))
				to_chat(user, span_warning("You are banned from <b>[role]</b>. Contact an admin for details."))
			return TRUE

		if("play_lastclass_again")
			prefs.ResetLastClass(user)
			on_identity_change()
			return TRUE

		// --- Culinary actions ---

		if("set_culinary_food")
			var/preference_type = params["preference_type"]
			if(preference_type != CULINARY_FAVOURITE_FOOD && preference_type != CULINARY_HATED_FOOD)
				return TRUE
			var/list/food_list = list()
			for(var/list/food_data in GLOB.food_with_faretypes)
				var/food_type = food_data["type"]
				var/display = "[capitalize(food_data["name"])] (Quality: [food_data["faretype"]])"
				food_list[display] = food_type
			var/picked = tgui_input_list(user, "Choose [lowertext(preference_type)]:", preference_type, food_list)
			if(!picked)
				return TRUE
			var/food_type = food_list[picked]
			var/opposite = (preference_type == CULINARY_FAVOURITE_FOOD) ? CULINARY_HATED_FOOD : CULINARY_FAVOURITE_FOOD
			if(prefs.culinary_preferences[opposite] == food_type)
				to_chat(user, span_warning("You can't set the same item as both favorite and hated!"))
				return TRUE
			prefs.culinary_preferences[preference_type] = food_type
			on_identity_change()
			return TRUE

		if("set_culinary_food_direct")
			var/preference_type = params["preference_type"]
			if(preference_type != CULINARY_FAVOURITE_FOOD && preference_type != CULINARY_HATED_FOOD)
				return TRUE
			var/picked = params["name"]
			if(!picked)
				return TRUE
			if(picked == "None")
				prefs.culinary_preferences[preference_type] = null
				on_identity_change()
				return TRUE
			for(var/list/food_data in GLOB.food_with_faretypes)
				var/display = "[capitalize(food_data["name"])] (Quality: [food_data["faretype"]])"
				if(display != picked)
					continue
				var/food_type = food_data["type"]
				var/opposite = (preference_type == CULINARY_FAVOURITE_FOOD) ? CULINARY_HATED_FOOD : CULINARY_FAVOURITE_FOOD
				if(prefs.culinary_preferences[opposite] == food_type)
					to_chat(user, span_warning("You can't set the same item as both favorite and hated!"))
					return TRUE
				prefs.culinary_preferences[preference_type] = food_type
				on_identity_change()
				return TRUE
			return TRUE

		if("set_culinary_drink")
			var/preference_type = params["preference_type"]
			if(preference_type != CULINARY_FAVOURITE_DRINK && preference_type != CULINARY_HATED_DRINK)
				return TRUE
			var/list/drink_list = list()
			for(var/list/drink_data in GLOB.drink_with_qualities)
				var/drink_type = drink_data["type"]
				var/display = "[capitalize(drink_data["name"])] (Quality: [drink_data["quality"]])"
				drink_list[display] = drink_type
			var/picked = tgui_input_list(user, "Choose [lowertext(preference_type)]:", preference_type, drink_list)
			if(!picked)
				return TRUE
			var/drink_type = drink_list[picked]
			var/opposite = (preference_type == CULINARY_FAVOURITE_DRINK) ? CULINARY_HATED_DRINK : CULINARY_FAVOURITE_DRINK
			if(prefs.culinary_preferences[opposite] == drink_type)
				to_chat(user, span_warning("You can't set the same drink as both favorite and hated!"))
				return TRUE
			prefs.culinary_preferences[preference_type] = drink_type
			on_identity_change()
			return TRUE

		if("set_culinary_drink_direct")
			var/preference_type = params["preference_type"]
			if(preference_type != CULINARY_FAVOURITE_DRINK && preference_type != CULINARY_HATED_DRINK)
				return TRUE
			var/picked = params["name"]
			if(!picked)
				return TRUE
			if(picked == "None")
				prefs.culinary_preferences[preference_type] = null
				on_identity_change()
				return TRUE
			for(var/list/drink_data in GLOB.drink_with_qualities)
				var/display = "[capitalize(drink_data["name"])] (Quality: [drink_data["quality"]])"
				if(display != picked)
					continue
				var/drink_type = drink_data["type"]
				var/opposite = (preference_type == CULINARY_FAVOURITE_DRINK) ? CULINARY_HATED_DRINK : CULINARY_FAVOURITE_DRINK
				if(prefs.culinary_preferences[opposite] == drink_type)
					to_chat(user, span_warning("You can't set the same drink as both favorite and hated!"))
					return TRUE
				prefs.culinary_preferences[preference_type] = drink_type
				on_identity_change()
				return TRUE
			return TRUE

		// --- Loadout actions ---

		if("set_loadout_slot")
			var/slot = text2num(params["slot"])
			if(!(slot in list(1, 2, 3, 4, 5, 6)))
				return TRUE
			var/list/loadouts_available = list("None")
			for(var/path as anything in GLOB.loadout_items)
				var/datum/loadout_item/item = GLOB.loadout_items[path]
				if(item.donoritem && !item.donator_ckey_check(user.ckey))
					continue
				if(!item.name)
					continue
				loadouts_available[item.name] = item
			var/picked = tgui_input_list(user, "Choose your loadout item. RMB a tree, statue or clock to collect.", "LOADOUT ITEM", loadouts_available)
			if(!picked)
				return TRUE
			var/slot_var = (slot == 1) ? "loadout" : "loadout[slot]"
			if(picked == "None")
				prefs.vars[slot_var] = null
				to_chat(user, "Who needs stuff anyway?")
			else
				var/datum/loadout_item/picked_item = loadouts_available[picked]
				prefs.vars[slot_var] = picked_item
				to_chat(user, "<font color='yellow'><b>[picked_item.name]</b></font>")
				if(picked_item.desc)
					to_chat(user, "[picked_item.desc]")
			on_identity_change()
			return TRUE

		if("set_loadout_slot_direct")
			var/slot = text2num(params["slot"])
			if(!(slot in list(1, 2, 3, 4, 5, 6)))
				return TRUE
			var/picked = params["name"]
			if(!picked)
				return TRUE
			var/slot_var = (slot == 1) ? "loadout" : "loadout[slot]"
			if(picked == "None")
				prefs.vars[slot_var] = null
				on_identity_change()
				return TRUE
			for(var/path as anything in GLOB.loadout_items)
				var/datum/loadout_item/item = GLOB.loadout_items[path]
				if(!item?.name || item.name != picked)
					continue
				if(item.donoritem && !item.donator_ckey_check(user.ckey))
					return TRUE
				prefs.vars[slot_var] = item
				if(item.desc)
					to_chat(user, "[item.desc]")
				on_identity_change()
				return TRUE
			return TRUE

		if("set_loadout_hex")
			var/slot = text2num(params["slot"])
			if(!(slot in list(1, 2, 3, 4, 5, 6)))
				return TRUE
			var/hex_var = "loadout_[slot]_hex"
			var/picked = tgui_input_list(user, "Choose a color.", "Loadout Item Color", colorlist)
			var/slot_label_words = list("first", "second", "third", "fourth", "fifth", "sixth")
			if(picked && colorlist[picked])
				prefs.vars[hex_var] = colorlist[picked]
				to_chat(user, "The colour for your <b>[slot_label_words[slot]]</b> loadout item has been set to <b>[picked]</b>.")
			else
				prefs.vars[hex_var] = null
				to_chat(user, "The colour for your <b>[slot_label_words[slot]]</b> loadout item has been cleared.")
			on_identity_change()
			return TRUE

		if("set_loadout_hex_direct")
			var/slot = text2num(params["slot"])
			if(!(slot in list(1, 2, 3, 4, 5, 6)))
				return TRUE
			var/hex_var = "loadout_[slot]_hex"
			var/picked = params["name"]
			if(!picked || picked == "—")
				prefs.vars[hex_var] = null
				on_identity_change()
				return TRUE
			if(colorlist[picked])
				prefs.vars[hex_var] = colorlist[picked]
			on_identity_change()
			return TRUE

		// --- Descriptors actions ---

		if("set_descriptor")
			var/choice_type = text2path(params["choice_type"])
			if(!(choice_type in prefs.pref_species?.descriptor_choices))
				return TRUE
			var/datum/descriptor_choice/choice = DESCRIPTOR_CHOICE(choice_type)
			if(!choice)
				return TRUE
			var/list/picklist = list()
			for(var/desc_type in choice.descriptors)
				var/datum/mob_descriptor/descriptor = MOB_DESCRIPTOR(desc_type)
				picklist[descriptor.name] = desc_type
			var/picked = tgui_input_list(user, "Describe my [lowertext(choice.name)]", "Describe myself", picklist)
			if(!picked)
				return TRUE
			var/picked_type = picklist[picked]
			var/datum/descriptor_entry/entry = prefs.get_descriptor_entry_for_choice(choice_type)
			if(entry)
				entry.descriptor_type = picked_type
				on_identity_change()
			return TRUE

		if("set_descriptor_direct")
			var/choice_type = text2path(params["choice_type"])
			if(!(choice_type in prefs.pref_species?.descriptor_choices))
				return TRUE
			var/datum/descriptor_choice/choice = DESCRIPTOR_CHOICE(choice_type)
			if(!choice)
				return TRUE
			var/picked = params["name"]
			if(!picked)
				return TRUE
			for(var/desc_type in choice.descriptors)
				var/datum/mob_descriptor/descriptor = MOB_DESCRIPTOR(desc_type)
				if(descriptor?.name != picked)
					continue
				var/datum/descriptor_entry/entry = prefs.get_descriptor_entry_for_choice(choice_type)
				if(entry)
					entry.descriptor_type = desc_type
					on_identity_change()
				return TRUE
			return TRUE

		if("set_custom_descriptor_prefix")
			var/static/list/input_list = CUSTOM_PREFIX_INPUT_LIST
			var/static/list/translation = CUSTOM_PREFIX_TRANSLATION_LIST
			var/index = text2num(params["index"])
			if(!index || index < 1 || index > length(prefs.custom_descriptors))
				return TRUE
			var/datum/custom_descriptor_entry/custom_entry = prefs.custom_descriptors[index]
			var/current_text = translation["[custom_entry.prefix_type]"]
			var/picked = tgui_input_list(user, "Choose the prefix", "Describe myself", input_list, current_text)
			if(!picked)
				return TRUE
			custom_entry.prefix_type = input_list[picked]
			on_identity_change()
			return TRUE

		if("set_custom_descriptor_content")
			var/index = text2num(params["index"])
			if(!index || index < 1 || index > length(prefs.custom_descriptors))
				return TRUE
			var/datum/custom_descriptor_entry/custom_entry = prefs.custom_descriptors[index]
			var/new_content = tgui_input_text(user, "Describe the feature", "Describe myself", custom_entry.content_text, max_length = CUSTOM_DESCRIPTOR_TEXT_LENGTH, encode = FALSE)
			if(isnull(new_content))
				return TRUE
			custom_entry.content_text = STRIP_HTML_SIMPLE(lowertext(new_content), CUSTOM_DESCRIPTOR_TEXT_LENGTH)
			on_identity_change()
			return TRUE

		if("marking_move_down")
			var/zone = params["zone"]
			var/name = params["name"]
			var/list/marking_list = LAZYACCESS(prefs.body_markings, zone)
			var/current_index = LAZYFIND(marking_list, name)
			if(!current_index || ++current_index > length(marking_list))
				return TRUE
			var/marking_content = marking_list[name]
			marking_list -= name
			marking_list.Insert(current_index, name)
			marking_list[name] = marking_content
			on_identity_change()
			return TRUE

		if("set_body_size")
			if((prefs.statpack?.name == "Virtuous" && istype(prefs.virtuetwo, /datum/virtue/size)) || istype(prefs.virtue, /datum/virtue/size))
				to_chat(user, span_purple("Unable to change sprite size due to virtue."))
				return TRUE
			var/current_pct = round((prefs.features?["body_size"] || BODY_SIZE_NORMAL) * 100)
			var/picked = tgui_input_number(user, "Choose desired sprite size ([BODY_SIZE_MIN*100]%-[BODY_SIZE_MAX*100]%). May make your character look distorted.", "Sprite Scale", current_pct, BODY_SIZE_MAX*100, BODY_SIZE_MIN*100)
			if(picked)
				prefs.features["body_size"] = clamp(picked * 0.01, BODY_SIZE_MIN, BODY_SIZE_MAX)
				on_identity_change()
			return TRUE

		if("set_body_size_direct")
			if((prefs.statpack?.name == "Virtuous" && istype(prefs.virtuetwo, /datum/virtue/size)) || istype(prefs.virtue, /datum/virtue/size))
				to_chat(user, span_purple("Unable to change sprite size due to virtue."))
				return TRUE
			var/raw = params["value"]
			if(isnull(raw))
				return TRUE
			var/picked = text2num("[raw]")
			if(isnull(picked))
				return TRUE
			prefs.features["body_size"] = clamp(picked * 0.01, BODY_SIZE_MIN, BODY_SIZE_MAX)
			on_identity_change()
			return TRUE

		if("set_extra_language")
			if(!prefs.virtue_origin?.extra_language)
				to_chat(user, span_warning("Your current Origin does not grant a free language."))
				return TRUE
			var/static/list/selectable_languages = list(
				/datum/language/grenzelhoftian,
				/datum/language/etruscan,
				/datum/language/gronnic,
				/datum/language/kazengunese,
				/datum/language/aavnic,
				/datum/language/celestial,
				/datum/language/otavan,
			)
			var/list/choices = list("None" = "None")
			for(var/language in selectable_languages)
				if(language in prefs.pref_species.languages)
					continue
				var/datum/language/a_language = new language()
				choices[a_language.name] = language
			var/picked = tgui_input_list(user, "Choose your character's extra language:", "EXTRA LANGUAGE", choices)
			if(picked)
				to_chat(user, span_notice("Language will not be applied unless selected Origin or Role provides a free language."))
				if(picked == "None")
					prefs.extra_language = "None"
				else
					prefs.extra_language = choices[picked]
				on_identity_change()
			return TRUE

		if("set_extra_language_direct")
			if(!prefs.virtue_origin?.extra_language)
				to_chat(user, span_warning("Your current Origin does not grant a free language."))
				return TRUE
			var/picked = params["name"]
			if(!picked)
				return TRUE
			if(picked == "None")
				prefs.extra_language = "None"
				on_identity_change()
				return TRUE
			var/static/list/selectable_languages = list(
				/datum/language/grenzelhoftian,
				/datum/language/etruscan,
				/datum/language/gronnic,
				/datum/language/kazengunese,
				/datum/language/aavnic,
				/datum/language/celestial,
				/datum/language/otavan,
			)
			for(var/language in selectable_languages)
				if(language in prefs.pref_species?.languages)
					continue
				var/datum/language/a_language = new language()
				if(a_language.name != picked)
					continue
				prefs.extra_language = language
				to_chat(user, span_notice("Language will not be applied unless selected Origin or Role provides a free language."))
				on_identity_change()
				return TRUE
			return TRUE

		if("set_race_title")
			if(!prefs.pref_species?.use_titles)
				return TRUE
			var/list/choices = list("None")
			for(var/title in prefs.pref_species.race_titles)
				choices += title
			var/picked = tgui_input_list(user, "What do they call your kind?", "RACE TITLE", choices)
			if(picked)
				prefs.selected_title = (picked == "None") ? "None" : picked
				on_identity_change()
			return TRUE

		if("set_race_title_direct")
			if(!prefs.pref_species?.use_titles)
				return TRUE
			var/picked = params["name"]
			if(!picked)
				return TRUE
			if(picked != "None" && !(picked in prefs.pref_species.race_titles))
				return TRUE
			prefs.selected_title = picked
			on_identity_change()
			return TRUE

		if("set_faith")
			var/list/faiths_named = list()
			if(prefs.virtue_origin?.uniquefaith)
				for(var/path as anything in prefs.virtue_origin.uniquefaith)
					var/datum/faith/faith = GLOB.faithlist[path]
					if(!faith?.name)
						continue
					faiths_named[faith.name] = faith
			else
				for(var/path as anything in GLOB.preference_faiths)
					var/datum/faith/faith = GLOB.faithlist[path]
					if(!faith?.name)
						continue
					faiths_named[faith.name] = faith
			var/picked = tgui_input_list(user, "The world rots. Which truth you bear?", "FAITH", faiths_named)
			if(picked)
				var/datum/faith/faith = faiths_named[picked]
				to_chat(user, "<font color='yellow'>Faith: [faith.name]</font>")
				to_chat(user, "Background: [faith.desc]")
				to_chat(user, "<font color='red'>Likely Worshippers: [faith.worshippers]</font>")
				prefs.selected_patron = GLOB.patronlist[faith.godhead] || GLOB.patronlist[pick(GLOB.patrons_by_faith[picked])]
				// Faith change re-keys patron_options (associated_faith on selected_patron flips).
				on_identity_change(TRUE)
			return TRUE

		if("set_patron")
			var/list/patrons_named = list()
			var/faith_key = prefs.selected_patron?.associated_faith || initial(prefs.default_patron.associated_faith)
			for(var/path as anything in GLOB.patrons_by_faith[faith_key])
				var/datum/patron/patron = GLOB.patronlist[path]
				if(!patron?.name)
					continue
				patrons_named[patron.name] = patron
			var/picked = tgui_input_list(user, "The first amongst many.", "PATRON", patrons_named)
			if(picked)
				prefs.selected_patron = patrons_named[picked]
				to_chat(user, "<font color='yellow'>Patron: [prefs.selected_patron]</font>")
				// Inhumen patron flips virtue_options to include heretic virtues.
				on_identity_change(TRUE)
			return TRUE

		if("set_combat_music")
			var/picked = tgui_input_list(user, "To you, the Signal sounds like:", "COMBAT MUSIC", GLOB.cmode_tracks_by_name, prefs.combat_music?.name)
			if(picked)
				prefs.combat_music = GLOB.cmode_tracks_by_name[picked]
				to_chat(user, span_notice("Selected track: <b>[picked]</b>."))
				on_identity_change()
			return TRUE

		if("set_combat_music_direct")
			var/picked = params["name"]
			if(!picked || !GLOB.cmode_tracks_by_name[picked])
				return TRUE
			prefs.combat_music = GLOB.cmode_tracks_by_name[picked]
			on_identity_change()
			return TRUE

		if("set_faith_direct")
			var/picked = params["name"]
			if(!picked)
				return TRUE
			var/list/faiths_named = list()
			if(prefs.virtue_origin?.uniquefaith)
				for(var/path as anything in prefs.virtue_origin.uniquefaith)
					var/datum/faith/faith = GLOB.faithlist[path]
					if(!faith?.name)
						continue
					faiths_named[faith.name] = faith
			else
				for(var/path as anything in GLOB.preference_faiths)
					var/datum/faith/faith = GLOB.faithlist[path]
					if(!faith?.name)
						continue
					faiths_named[faith.name] = faith
			var/datum/faith/faith = faiths_named[picked]
			if(!faith)
				return TRUE
			prefs.selected_patron = GLOB.patronlist[faith.godhead] || GLOB.patronlist[pick(GLOB.patrons_by_faith[picked])]
			on_identity_change(TRUE)
			return TRUE

		if("set_patron_direct")
			var/picked = params["name"]
			if(!picked)
				return TRUE
			var/faith_key = prefs.selected_patron?.associated_faith || initial(prefs.default_patron.associated_faith)
			for(var/path as anything in GLOB.patrons_by_faith[faith_key])
				var/datum/patron/patron = GLOB.patronlist[path]
				if(!patron?.name || patron.name != picked)
					continue
				prefs.selected_patron = patron
				on_identity_change(TRUE)
				return TRUE
			return TRUE

		if("toggle_domhand")
			prefs.domhand = (prefs.domhand == 1) ? 2 : 1
			on_identity_change()
			return TRUE

		if("toggle_dnr")
			prefs.dnr_pref = !prefs.dnr_pref
			on_identity_change()
			return TRUE

		if("set_family")
			if(!user.check_agevet())
				return TRUE
			var/list/famtree_options_list = list(FAMILY_NONE, FAMILY_PARTIAL, FAMILY_NEWLYWED)
			if(prefs.age != AGE_ADULT)
				famtree_options_list = list(FAMILY_NONE, FAMILY_PARTIAL, FAMILY_NEWLYWED, FAMILY_FULL)
			var/picked = tgui_input_list(user, "Select your hero's bond", "FAMILY", famtree_options_list, prefs.family)
			if(picked)
				prefs.family = picked
				prefs.setspouse = null
				prefs.gender_choice = ANY_GENDER
				prefs.xenophobe_pref = 1
				on_identity_change()
			return TRUE

		if("set_family_direct")
			if(!user.check_agevet())
				return TRUE
			var/picked = params["name"]
			var/list/famtree_options_list = list(FAMILY_NONE, FAMILY_PARTIAL, FAMILY_NEWLYWED)
			if(prefs.age != AGE_ADULT)
				famtree_options_list += FAMILY_FULL
			if(!(picked in famtree_options_list))
				return TRUE
			prefs.family = picked
			prefs.setspouse = null
			prefs.gender_choice = ANY_GENDER
			prefs.xenophobe_pref = 1
			on_identity_change()
			return TRUE

		if("set_setspouse")
			if(!user.check_agevet() || prefs.family == FAMILY_NONE)
				return TRUE
			var/newspouse = tgui_input_text(user, "Input the identity of another hero", "TIL DEATH DO US PART", prefs.setspouse)
			prefs.setspouse = newspouse || null
			on_identity_change()
			return TRUE

		if("cycle_xenophobe")
			if(!user.check_agevet() || (prefs.family != FAMILY_NEWLYWED && prefs.family != FAMILY_FULL))
				return TRUE
			prefs.xenophobe_pref += 1
			if(prefs.xenophobe_pref > 2)
				prefs.xenophobe_pref = (prefs.family == FAMILY_FULL) ? 1 : 0
			on_identity_change()
			return TRUE

		if("set_xenophobe_direct")
			if(!user.check_agevet() || (prefs.family != FAMILY_NEWLYWED && prefs.family != FAMILY_FULL))
				return TRUE
			var/picked = params["name"]
			var/new_pref
			switch(picked)
				if("Unrestricted")
					new_pref = 0
				if("Race only")
					new_pref = 1
				if("Subrace only")
					new_pref = 2
				else
					return TRUE
			// FAMILY_FULL has no "Unrestricted" — coerce 0 → 1 (matches the
			// classic cycle behavior, which skips 0 for FAMILY_FULL).
			if(prefs.family == FAMILY_FULL && new_pref == 0)
				new_pref = 1
			prefs.xenophobe_pref = new_pref
			on_identity_change()
			return TRUE

		if("set_gender_choice")
			if(!user.check_agevet() || (prefs.family != FAMILY_NEWLYWED && prefs.family != FAMILY_FULL))
				return TRUE
			if(prefs.pronouns == THEY_THEM || prefs.pronouns == IT_ITS)
				to_chat(user, span_warning("With neutral pronouns, you may only choose [ANY_GENDER]."))
				prefs.gender_choice = ANY_GENDER
				on_identity_change()
				return TRUE
			var/list/options = list(ANY_GENDER, SAME_GENDER, DIFFERENT_GENDER)
			var/picked = tgui_input_list(user, "Spouse gender preference", "TO LOVE AND TO CHERISH", options, prefs.gender_choice)
			if(picked)
				prefs.gender_choice = picked
				on_identity_change()
			return TRUE

		if("set_gender_choice_direct")
			if(!user.check_agevet() || (prefs.family != FAMILY_NEWLYWED && prefs.family != FAMILY_FULL))
				return TRUE
			if(prefs.pronouns == THEY_THEM || prefs.pronouns == IT_ITS)
				to_chat(user, span_warning("With neutral pronouns, you may only choose [ANY_GENDER]."))
				prefs.gender_choice = ANY_GENDER
				on_identity_change()
				return TRUE
			var/picked = params["name"]
			if(!(picked in list(ANY_GENDER, SAME_GENDER, DIFFERENT_GENDER)))
				return TRUE
			prefs.gender_choice = picked
			on_identity_change()
			return TRUE

		if("toggle_gender")
			if(AGENDER in prefs.pref_species?.species_traits)
				return TRUE
			prefs.gender = (prefs.gender == MALE) ? FEMALE : MALE
			to_chat(user, "<font color='red'>Your character will now use a [prefs.gender == MALE ? "masculine" : "feminine"] sprite.</font>")
			prefs.genderize_customizer_entries()
			on_identity_change()
			return TRUE

		if("set_tail_type")
			if(!(LAMIAN_TAIL in prefs.pref_species?.species_traits))
				return TRUE
			var/list/species_tail_list = prefs.pref_species.get_tail_list()
			if(!LAZYLEN(species_tail_list))
				prefs.tail_type = /obj/item/bodypart/lamian_tail/lamian_tail
				to_chat(user, span_bad("There are no available tail types for this species."))
				on_identity_change()
				return TRUE
			var/list/tail_selection = list()
			for(var/obj/item/bodypart/lamian_tail/tt as anything in species_tail_list)
				tail_selection[tt::name] = tt
			var/picked = tgui_input_list(user, "Choose your character's tail type", "Tail Type", tail_selection)
			if(picked)
				prefs.tail_type = tail_selection[picked]
				on_identity_change()
			return TRUE

		if("set_tail_type_direct")
			if(!(LAMIAN_TAIL in prefs.pref_species?.species_traits))
				return TRUE
			var/picked = params["name"]
			if(!picked)
				return TRUE
			var/list/species_tail_list = prefs.pref_species.get_tail_list()
			for(var/obj/item/bodypart/lamian_tail/tt as anything in species_tail_list)
				if(tt::name != picked)
					continue
				prefs.tail_type = tt
				on_identity_change()
				return TRUE
			return TRUE

		if("set_tail_color")
			if(!(LAMIAN_TAIL in prefs.pref_species?.species_traits))
				return TRUE
			var/picked = input(user, "Choose tail color:", "Tail Color", "#[prefs.tail_color]") as color|null
			if(picked)
				prefs.tail_color = sanitize_hexcolor(picked)
				on_identity_change()
			return TRUE

		if("set_tail_markings_color")
			if(!(LAMIAN_TAIL in prefs.pref_species?.species_traits))
				return TRUE
			var/picked = input(user, "Choose tail markings color:", "Marking Color", "#[prefs.tail_markings_color]") as color|null
			if(picked)
				prefs.tail_markings_color = sanitize_hexcolor(picked)
				on_identity_change()
			return TRUE

/// Count how many other roundstart races share the current species' base_name (excluding the current sub_name).
/// 0 means there are no subspecies to switch to — the picker would be empty.
///
/// GLOB.roundstart_races and GLOB.species_list are fixed at SS init, so the
/// answer is purely a function of (base_name, sub_name). Memoize by the
/// species datum ref — the profile flagged the GLOB walk as ~2.1s self CPU
/// across 139K calls.
/datum/preferences_menu/proc/count_other_subspecies(datum/species/current)
	if(!current)
		return 0
	var/static/list/cached_counts
	if(!cached_counts)
		cached_counts = list()
	var/cached = cached_counts[current]
	if(!isnull(cached))
		return cached
	var/count = 0
	for(var/A in GLOB.roundstart_races)
		var/datum/species/race = GLOB.species_list[A]
		if(!race)
			continue
		if(race.base_name != current.base_name)
			continue
		if(race.sub_name == current.sub_name)
			continue
		count++
	cached_counts[current] = count
	return count

/// Reverse-lookup the human-readable name for a stored skin_tone hex value.
/// pref_species.get_skin_list() returns name→hex; we find the matching name.
/datum/preferences_menu/proc/lookup_skin_tone_name(stored_value)
	if(!prefs?.pref_species)
		return stored_value
	var/list/skin_list = prefs.pref_species.get_skin_list()
	for(var/k in skin_list)
		if(skin_list[k] == stored_value)
			return k
	return stored_value

/// Refresh hooks shared by every identity write. Saves prefs, repaints the preview, and pushes a UI update.
///
/// If `refresh_static` is TRUE, also rebuild the cached ui_static_data and
/// ship a send_full_update — used when the mutation invalidates one or more
/// option lists (species/origin/faith/patron/statpack/virtue/charflaw/age/
/// pronouns/hotkeys/markings_preset/random/load/change_slot). Otherwise the
/// regular partial push covers the per-tab dynamic changes.
///
/// Mutations only update in-memory prefs — the explicit Save button is the
/// sole disk-write path for character data, matching the classic browser UI.
/// Closing the window without clicking Save discards any pending edits.
/datum/preferences_menu/proc/on_identity_change(refresh_static = FALSE)
	if(!prefs)
		return
	queue_preview_refresh()
	if(refresh_static)
		refresh_static_data()
	else
		SStgui.update_uis(src)

/// Mark the preview dirty and schedule a flush. A burst of body-affecting acts
/// (e.g. rapid customizer rotations) now composes one dummy mob instead of one
/// per act. 0.5s gives the player near-immediate feedback while collapsing
/// machine-gun clicks.
/datum/preferences_menu/proc/queue_preview_refresh()
	preview_dirty = TRUE
	addtimer(CALLBACK(src, PROC_REF(flush_preview)), 0.5 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)

/datum/preferences_menu/proc/flush_preview()
	if(!preview_dirty || !prefs)
		return
	// Use our lobby-safe refresh instead of update_preview_icon() — the classic proc
	// short-circuits when parent.is_new_player() is TRUE (i.e. exactly when we need it).
	refresh_preview(prefs.parent?.mob)
	preview_dirty = FALSE

/// Keeps body_size in sync with size virtues (e.g. Giant). Picking a size virtue locks
/// body_size to its scale; switching the last size virtue off restores normal size. The
/// legacy prefs.dm virtue picker did this inline; the TGUI rewrite dropped it.
/datum/preferences_menu/proc/sync_virtue_body_size(datum/virtue/old_virtue, datum/virtue/new_virtue, mob/user)
	if(istype(new_virtue, /datum/virtue/size))
		var/datum/virtue/size/S = new_virtue
		prefs.features["body_size"] = S.scale
		to_chat(user, span_purple("Your body size has been set to [S.scale * 100]%."))
		return
	if(!istype(old_virtue, /datum/virtue/size))
		return
	// Switched this slot off a size virtue — reset unless the other slot still grants size.
	if(istype(prefs.virtue, /datum/virtue/size))
		return
	if(prefs.statpack?.name == "Virtuous" && istype(prefs.virtuetwo, /datum/virtue/size))
		return
	prefs.features["body_size"] = BODY_SIZE_NORMAL
	to_chat(user, span_purple("Your body size has been reset to [BODY_SIZE_NORMAL * 100]%."))

/// Build the virtue picker list, filtering the same way the classic prefs.dm:2320 picker does
/// (skip origin/pack/racial/heretic virtues — they're handled by separate prefs).
/datum/preferences_menu/proc/build_virtue_picker_list(mob/user, show_message = FALSE)
	var/list/out = list()
	if(!prefs)
		return out
	var/species_type = prefs.pref_species?.type
	var/heretic = istype(prefs.selected_patron, /datum/patron/inhumen)
	for(var/path as anything in GLOB.virtues)
		var/datum/virtue/v = GLOB.virtues[path]
		if(!v?.name)
			continue
		if(istype(v, /datum/virtue/origin))
			continue
		if(istype(v, /datum/virtue/heretic) && !heretic)
			continue
		if(v.restricted && species_type && (species_type in v.races))
			continue
		if(istype(v, /datum/virtue/racial) && species_type && !(species_type in v.races))
			continue
		out[v.name] = v
	return sort_list(out)

/// Lazy-creates the datum and opens the TGUI window. Called from /datum/preferences/Topic.
/datum/preferences/proc/open_preferences_menu(mob/user)
	if(!user)
		return
	if(!preferences_menu)
		preferences_menu = new(src)
	preferences_menu.ui_interact(user)
