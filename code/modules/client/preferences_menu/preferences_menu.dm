// TGUI character-creation menu. Backed by /datum/preferences; mutates the same prefs
// vars as the classic /datum/preferences/Topic handlers. Savefile schema stays untouched.
// Reference pattern: /obj/structure/roguemachine/bathvend (Brassface).

/datum/preferences_menu
	var/datum/preferences/prefs
	var/active_tab = "identity"
	/// Set TRUE while the lobby auto-refresh loop is running, so we don't double-start it.
	var/lobby_refresh_active = FALSE

/datum/preferences_menu/New(datum/preferences/owning_prefs)
	. = ..()
	prefs = owning_prefs

/datum/preferences_menu/Destroy()
	prefs = null
	return ..()

/datum/preferences_menu/ui_state(mob/user)
	return GLOB.always_state

/datum/preferences_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PreferencesMenu", "Character Setup")
		ui.open()
	start_lobby_refresh()

// Periodic push of lobby state (ready roster + countdown) while the window is open
// and the round hasn't started. Polls every 2s — enough to feel responsive without
// flooding the UI subsystem. Self-exits when no listener is left or the round begins.
/datum/preferences_menu/proc/start_lobby_refresh()
	if(lobby_refresh_active)
		return
	lobby_refresh_active = TRUE
	addtimer(CALLBACK(src, PROC_REF(tick_lobby_refresh)), 2 SECONDS)

/datum/preferences_menu/proc/tick_lobby_refresh()
	lobby_refresh_active = FALSE
	if(!prefs)
		return
	// Only keep ticking while at least one client has the window open.
	var/datum/tgui/open_ui = SStgui.get_open_ui(prefs.parent?.mob, src)
	if(!open_ui)
		return
	SStgui.update_uis(src)
	// Once the round starts, stop the loop — the lobby panel becomes static.
	if(SSticker.current_state == GAME_STATE_PREGAME)
		start_lobby_refresh()

/datum/preferences_menu/proc/build_slot_options()
	var/list/slots = list()
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
		slots += list(list("id" = i, "name" = slot_name))
	return slots

/datum/preferences_menu/ui_static_data(mob/user)
	var/list/data = list()
	data["pronoun_options"] = GLOB.pronouns_list?.Copy() || list()
	data["voice_type_options"] = GLOB.voice_types_list?.Copy() || list()
	data["slots"] = build_slot_options()

	// Voice packs — assoc list (name → datum) in GLOB.
	var/list/voice_packs = list()
	for(var/vp_name in GLOB.voice_packs_list)
		voice_packs += vp_name
	data["voice_pack_options"] = voice_packs

	// Statpacks: ship name + description per pack for in-tab preview.
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

	return data

/datum/preferences_menu/ui_data(mob/user)
	var/list/data = list()
	data["active_tab"] = active_tab
	if(!prefs)
		return data

	// Header stats — visible from every tab so the player doesn't have to switch tabs to check.
	var/pq_num = get_playerquality(user.ckey)
	var/list/pq_label = pq_tier_label(pq_num)
	var/mob/dead/new_player/np = user
	var/is_np = istype(np)
	data["header"] = list(
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
	)

	data["lobby"] = build_lobby_data()

	data["identity"] = build_identity_data(user)
	data["body"] = build_body_data(user)
	data["markings"] = build_markings_data(user)
	data["descriptors"] = build_descriptors_data(user)
	data["customizers"] = build_customizers_data(user)
	data["loadout"] = build_loadout_data(user)
	data["culinary"] = build_culinary_data(user)
	data["jobs"] = build_jobs_data(user)
	data["flavor"] = build_flavor_data(user)
	data["game_prefs"] = build_game_prefs_data(user)
	data["ooc_prefs"] = build_ooc_prefs_data(user)
	data["keybinds"] = build_keybinds_data(user)
	data["familiar"] = build_familiar_data(user)
	data["gnoll"] = build_gnoll_data(user)
	return data

/datum/preferences_menu/proc/build_identity_data(mob/user)
	var/list/id = list()
	id["real_name"] = prefs.real_name
	id["name_is_banned"] = check_nameban(user.ckey)
	id["appearance_banned"] = is_banned_from(user.ckey, "Appearance")
	id["nickname"] = prefs.nickname
	id["pronouns"] = prefs.pronouns
	id["voice_type"] = prefs.voice_type
	id["voice_pack"] = prefs.voice_pack || "Default"
	id["age"] = prefs.age
	id["age_options"] = prefs.pref_species ? prefs.pref_species.possible_ages?.Copy() : list()

	id["species_name"] = prefs.pref_species?.base_name
	id["subspecies_name"] = prefs.pref_species?.sub_name
	id["species_psydonic"] = prefs.pref_species?.psydonic
	id["species_use_titles"] = prefs.pref_species?.use_titles
	id["selected_title"] = prefs.selected_title || "None"
	id["has_subspecies_options"] = count_other_subspecies(prefs.pref_species) > 0

	id["origin_name"] = prefs.virtue_origin ? "[prefs.virtue_origin]" : "None"
	id["origin_gives_language"] = prefs.virtue_origin?.extra_language

	id["statpack_name"] = prefs.statpack?.name
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

/datum/preferences_menu/proc/build_body_data(mob/user)
	var/list/body = list()
	var/list/traits = prefs.pref_species?.species_traits

	// Conditional flags driving which controls render.
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
	body["body_size_pct"] = round((prefs.features?["body_size"] || BODY_SIZE_NORMAL) * 100)

	return body

/datum/preferences_menu/proc/build_markings_data(mob/user)
	var/list/data = list()
	data["max_per_limb"] = MAXIMUM_MARKINGS_PER_LIMB
	data["has_presets"] = length(marking_sets_for_species(prefs.pref_species)) > 0

	var/list/zones_out = list()
	for(var/zone in GLOB.marking_zones)
		// Compute the candidate pool for this zone first — if the species has no markings
		// that target this zone, we hide the zone entirely (matches the silent-no-op the
		// classic prefs gives for species-without-markings like dwarves).
		var/list/all_candidates = marking_list_of_zone_for_species(zone, prefs.pref_species)
		var/list/marking_list = prefs.body_markings?[zone]
		var/has_current = (islist(marking_list) && length(marking_list) > 0)
		if(!length(all_candidates) && !has_current)
			continue

		var/list/zone_entry = list()
		zone_entry["key"] = zone
		zone_entry["label"] = zone_label(zone)
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
		zone_entry["markings"] = markings_out
		// "can_add" requires both: under the per-limb count cap AND at least one unused candidate.
		var/list/remaining = all_candidates.Copy()
		for(var/keyed_name in marking_list)
			remaining -= keyed_name
		zone_entry["can_add"] = (length(markings_out) < MAXIMUM_MARKINGS_PER_LIMB) && length(remaining) > 0
		zones_out += list(zone_entry)
	data["zones"] = zones_out
	data["species_has_no_markings"] = !length(zones_out)
	return data

/datum/preferences_menu/proc/build_descriptors_data(mob/user)
	var/list/data = list()
	prefs.validate_descriptors() // make sure entries exist for current species before reading

	var/list/entries_out = list()
	for(var/choice_type in prefs.pref_species?.descriptor_choices)
		var/datum/descriptor_choice/choice = DESCRIPTOR_CHOICE(choice_type)
		var/datum/descriptor_entry/entry = prefs.get_descriptor_entry_for_choice(choice_type)
		var/datum/mob_descriptor/descriptor = MOB_DESCRIPTOR(entry?.descriptor_type)
		entries_out += list(list(
			"choice_type" = "[choice_type]",
			"choice_name" = choice?.name,
			"current_name" = descriptor?.name,
		))
	data["entries"] = entries_out

	var/static/list/prefix_translation = CUSTOM_PREFIX_TRANSLATION_LIST
	var/list/custom_out = list()
	for(var/i in 1 to CUSTOM_DESCRIPTOR_AMOUNT)
		// Mirror classic: only unlock custom slot N if the matching
		// /datum/mob_descriptor/prominent/custom/<one|two> is present in entries.
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
	data["max_content_length"] = CUSTOM_DESCRIPTOR_TEXT_LENGTH

	return data

/datum/preferences_menu/proc/build_customizers_data(mob/user)
	var/list/data = list()
	prefs.validate_customizer_entries() // make sure entries match the current species
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
			"name" = customizer.name,
			"allows_disabling" = customizer.allows_disabling,
			"disabled" = entry.disabled,
			"choice_name" = choice?.name,
			"has_multiple_choices" = (length(customizer.customizer_choices) > 1),
			"pref_data" = pref_data,
		))
	data["entries"] = entries_out
	return data

/// Plain-text + color for a PQ value. Mirrors format_pq_text() but ships structured
/// data to React instead of an HTML <span> the client would render as literal text.
// Lobby roster + countdown. Mirrors /mob/dead/Stat panel display: total players ready,
// per-job groupings, and round-start timer. Wanderer-family jobs (Adventurer, Wretch,
// Court Agent) get collapsed under one "Wanderer" bucket as the classic UI does.
/datum/preferences_menu/proc/build_lobby_data()
	var/list/data = list()
	var/is_pregame = (SSticker.current_state == GAME_STATE_PREGAME)
	data["is_pregame"] = is_pregame
	data["timeleft_ds"] = is_pregame ? SSticker.GetTimeLeft() : -1
	data["total_ready"] = SSticker.totalPlayersReady
	data["round_in_progress"] = SSticker.IsRoundInProgress()

	var/static/list/wanderer_jobs = list("Adventurer", "Wretch", "Court Agent")
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
		job_entries += list(list("job" = job_name, "players" = players))
	sortTim(job_entries, GLOBAL_PROC_REF(cmp_lobby_job_entries))
	data["ready_by_job"] = job_entries
	return data

/proc/cmp_lobby_job_entries(list/a, list/b)
	return sorttext(b["job"], a["job"])

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

/datum/preferences_menu/proc/build_game_prefs_data(mob/user)
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

/datum/preferences_menu/proc/build_ooc_prefs_data(mob/user)
	var/list/data = list()
	data["windowflashing"] = prefs.windowflashing
	data["hear_midis"] = !!(prefs.toggles & SOUND_MIDI)
	data["lobby_music"] = !!(prefs.toggles & SOUND_LOBBY)
	data["pull_requests"] = !!(prefs.chat_toggles & CHAT_PULLR)
	data["unlock_content"] = prefs.unlock_content
	data["byond_publicity"] = !!(prefs.toggles & MEMBER_PUBLIC)
	data["is_admin"] = !!user.client?.holder
	return data

/datum/preferences_menu/proc/build_familiar_data(mob/user)
	var/list/data = list()
	var/datum/familiar_prefs/fp = prefs.familiar_prefs
	if(!fp)
		return data

	data["familiar_name"] = fp.familiar_name
	data["familiar_pronouns"] = fp.familiar_pronouns
	data["familiar_headshot_link"] = fp.familiar_headshot_link
	data["familiar_flavortext_len"] = length(fp.familiar_flavortext)
	data["familiar_ooc_notes_len"] = length(fp.familiar_ooc_notes)
	data["familiar_ooc_extra_set"] = !!fp.familiar_ooc_extra_link

	// Species: resolve current type to a human-readable name via GLOB.familiar_types.
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

/datum/preferences_menu/proc/build_gnoll_data(mob/user)
	var/list/data = list()
	var/datum/gnoll_prefs/gp = prefs.gnoll_prefs
	if(!gp)
		return data

	data["gnoll_name"] = gp.gnoll_name
	data["gnoll_pronouns"] = gp.gnoll_pronouns
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

/datum/preferences_menu/proc/build_keybinds_data(mob/user)
	var/list/data = list()
	data["max_keys_per_keybind"] = MAX_KEYS_PER_KEYBIND
	data["hotkeys_mode"] = prefs.hotkeys

	// Inverted: keybind_name -> list of currently-bound keys.
	var/list/user_binds = list()
	for(var/key in prefs.key_bindings)
		for(var/kb_name in prefs.key_bindings[key])
			user_binds[kb_name] += list(key)

	// Group keybinds by category.
	var/list/categories_out = list()
	var/list/categories_by_name = list()
	for(var/name in GLOB.keybindings_by_name)
		var/datum/keybinding/kb = GLOB.keybindings_by_name[name]
		if(!categories_by_name[kb.category])
			categories_by_name[kb.category] = list()
		categories_by_name[kb.category] += list(list(
			"name" = kb.name,
			"full_name" = kb.full_name,
			"bindings" = user_binds[kb.name] || list(),
			"default_keys" = prefs.hotkeys ? (kb.classic_keys || list()) : (kb.hotkey_keys || list()),
		))
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

/datum/preferences_menu/proc/build_jobs_data(mob/user)
	var/list/data = list()
	if(!SSjob || !SSjob.occupations?.len)
		data["loaded"] = FALSE
		return data
	data["loaded"] = TRUE

	// Normalize joblessrole — fallback to RETURNTOLOBBY if anything stale is stored.
	if(prefs.joblessrole != RETURNTOLOBBY && prefs.joblessrole != BERANDOMJOB)
		prefs.joblessrole = RETURNTOLOBBY
	data["joblessrole"] = prefs.joblessrole
	data["last_class"] = prefs.lastclass
	data["job_change_locked"] = SSticker.job_change_locked
	data["triumphs"] = user.get_triumphs()
	data["pq"] = get_playerquality(user.ckey)

	var/list/jobs_out = list()
	for(var/datum/job/job in sortList(SSjob.occupations, GLOBAL_PROC_REF(cmp_job_display_asc)))
		if(!job.spawn_positions)
			continue
		var/list/entry = build_job_entry(user, job)
		jobs_out += list(entry)
	data["jobs"] = jobs_out
	return data

/datum/preferences_menu/proc/build_job_entry(mob/user, datum/job/job)
	var/rank = job.title
	var/used_name = job.title
	if((prefs.pronouns == SHE_HER || prefs.pronouns == THEY_THEM_F) && job.f_title)
		used_name = job.f_title

	var/list/entry = list(
		"title" = rank,
		"display_name" = used_name,
		"tutorial" = job.tutorial,
		"slots" = job.spawn_positions,
		"rcp" = job.round_contrib_points,
		"required" = job.required,
	)

	// Banned ckey — never shows priority button, click opens ban check.
	if(is_banned_from(user.ckey, rank))
		entry["state"] = "banned"
		entry["state_text"] = "BANNED"
		return entry

	// Required playtime gate.
	var/required_playtime_remaining = job.required_playtime_remaining(user.client)
	if(required_playtime_remaining)
		entry["state"] = "playtime"
		entry["state_text"] = "[get_exp_format(required_playtime_remaining)] as [job.get_exp_req_type()]"
		return entry

	// Account-age gate.
	if(!job.player_old_enough(user.client))
		entry["state"] = "agedays"
		entry["state_text"] = "IN [job.available_in_days(user.client)] DAYS"
		return entry

	// Min PQ.
	if(!job.required && !isnull(job.min_pq) && (get_playerquality(user.ckey) < job.min_pq))
		entry["state"] = "min_pq"
		entry["state_text"] = "Min PQ: [job.min_pq]"
		return entry

	// Max PQ.
	if(!job.required && !isnull(job.max_pq) && (get_playerquality(user.ckey) > job.max_pq))
		entry["state"] = "max_pq"
		entry["state_text"] = "Max PQ: [job.max_pq]"
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

		// Origin restrictions also use virtue_restrictions (same field).
		if(prefs.virtue_origin?.type in job.virtue_restrictions)
			entry["state"] = "origin"
			entry["state_text"] = "Disallowed by Origin: [prefs.virtue_origin.name]"
			return entry

	// Vice restrictions.
	if(length(job.vice_restrictions) && (prefs.charflaw?.type in job.vice_restrictions))
		entry["state"] = "vice"
		entry["state_text"] = "Disallowed by Vice: [prefs.charflaw.name]"
		return entry

	// JOB_UNAVAILABLE_* check (when in lobby) — accept JOB_AVAILABLE and SLOTFULL.
	var/job_unavailable = JOB_AVAILABLE
	if(isnewplayer(prefs.parent?.mob))
		var/mob/dead/new_player/new_player = prefs.parent.mob
		job_unavailable = new_player.IsJobUnavailable(job.title, latejoin = FALSE)
	if(!(job_unavailable in list(JOB_AVAILABLE, JOB_UNAVAILABLE_SLOTFULL)))
		entry["state"] = "unavailable"
		entry["state_text"] = unavailable_reason_text(job_unavailable)
		return entry

	// Available — show priority button.
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

/datum/preferences_menu/proc/build_culinary_data(mob/user)
	prefs.validate_culinary_preferences()
	var/list/data = list()
	data["fav_food_name"] = culinary_food_name(prefs.culinary_preferences[CULINARY_FAVOURITE_FOOD])
	data["fav_drink_name"] = culinary_drink_name(prefs.culinary_preferences[CULINARY_FAVOURITE_DRINK])
	data["hated_food_name"] = culinary_food_name(prefs.culinary_preferences[CULINARY_HATED_FOOD])
	data["hated_drink_name"] = culinary_drink_name(prefs.culinary_preferences[CULINARY_HATED_DRINK])
	return data

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

/datum/preferences_menu/proc/build_loadout_data(mob/user)
	var/list/data = list()
	var/list/slot_vars = list("loadout", "loadout2", "loadout3", "loadout4", "loadout5", "loadout6")
	var/list/hex_vars = list("loadout_1_hex", "loadout_2_hex", "loadout_3_hex", "loadout_4_hex", "loadout_5_hex", "loadout_6_hex")
	var/list/slots = list()
	for(var/i in 1 to 6)
		var/datum/loadout_item/item = prefs.vars[slot_vars[i]]
		slots += list(list(
			"slot" = i,
			"name" = item?.name || "None",
			"desc" = item?.desc,
			"hex" = prefs.vars[hex_vars[i]],
		))
	data["slots"] = slots
	return data

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
				on_identity_change()
			return TRUE

		if("set_voice_type")
			var/picked = tgui_input_list(user, "Choose your character's voice type", "VOICE TYPE", GLOB.voice_types_list, prefs.voice_type)
			if(picked)
				prefs.voice_type = picked
				on_identity_change()
			return TRUE

		if("set_voice_pack")
			var/picked = tgui_input_list(user, "Choose your character's emote voice pack", "VOICE PACK", GLOB.voice_packs_list, prefs.voice_pack)
			if(picked)
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
				on_identity_change()
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
					prefs.virtue = GLOB.virtues[/datum/virtue/none]
					if(istype(prefs.virtuetwo, /datum/virtue/size))
						prefs.features["body_size"] = BODY_SIZE_NORMAL
						to_chat(user, span_purple("Your body size has been reset to [BODY_SIZE_NORMAL*100]%."))
					prefs.virtuetwo = GLOB.virtues[/datum/virtue/none]
				prefs.statpack = sp
				to_chat(user, "<font color='purple'>[sp.name]</font>")
				to_chat(user, "<font color='purple'>[sp.description_string()]</font>")
				on_identity_change()
			return TRUE

		if("set_virtue")
			var/list/virtues_available = build_virtue_picker_list(user, FALSE)
			if(!length(virtues_available))
				to_chat(user, span_warning("No virtues available."))
				return TRUE
			var/picked = tgui_input_list(user, "Choose your virtue", "VIRTUE", virtues_available, prefs.virtue)
			if(picked)
				var/datum/virtue/v = virtues_available[picked]
				prefs.virtue = v
				on_identity_change()
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
				prefs.virtuetwo = v
				on_identity_change()
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
				on_identity_change()
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
				on_identity_change()
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
				on_identity_change()
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
				on_identity_change()
			return TRUE

		if("show_origin_help")
			if(!prefs.virtue_origin?.origin_desc)
				to_chat(user, "<span class='info'>No origin description available.</span>")
				return TRUE
			to_chat(user, "<b>Origin Description:</b><br>[prefs.virtue_origin.origin_desc]")
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
			var/picked = color_pick_sanitized(user, "Choose your character's voice color:", "Character Preference", prefs.voice_color)
			if(picked)
				if(color_hex2num(picked) < 230)
					to_chat(user, "<font color='red'>This voice color is too dark for mortals.</font>")
					return TRUE
				prefs.voice_color = sanitize_hexcolor(picked)
				on_identity_change()
			return TRUE

		if("set_highlight_color")
			var/picked = color_pick_sanitized(user, "Choose your character's nickname highlight color:", "Character Preference", prefs.highlight_color)
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

		if("set_char_accent")
			var/picked = tgui_input_list(user, "Choose your character's accent:", "Character Preference", GLOB.character_accents, prefs.char_accent)
			if(picked)
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
			prefs.handle_customizer_topic(user, href_list)
			on_identity_change()
			return TRUE

		if("customizers_reset_all_colors")
			prefs.reset_all_customizer_accessory_colors()
			on_identity_change()
			return TRUE

		if("customizers_randomize_all")
			prefs.randomize_all_customizer_accessories()
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
			on_identity_change()
			return TRUE

		if("set_clientfps")
			var/desiredfps = tgui_input_number(user, "Choose your desired fps. (0 = synced with server tick rate, currently:[world.fps])", "Client FPS", prefs.clientfps, 240, 0)
			if(isnull(desiredfps))
				return TRUE
			prefs.clientfps = desiredfps
			prefs.parent.fps = desiredfps
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
				if(length(prefs.flavortext) < MINIMUM_FLAVOR_TEXT)
					to_chat(user, span_boldwarning("You need a minimum of [MINIMUM_FLAVOR_TEXT] characters in your flavor text in order to play."))
					return TRUE
				if(length(prefs.ooc_notes) < MINIMUM_OOC_NOTES)
					to_chat(user, span_boldwarning("You need at least a few words in your OOC notes in order to play."))
					return TRUE
				np.ready = PLAYER_READY_TO_PLAY
				log_game("([user || "NO KEY"]) readied as ([prefs.real_name])")
			SStgui.update_uis(src)
			return TRUE

		if("late_join")
			var/mob/dead/new_player/np = user
			if(!istype(np))
				return TRUE
			var/list/href_list = list("late_join" = "1")
			np.Topic(null, href_list)
			return TRUE

		if("save_character")
			if(!prefs.path)
				to_chat(user, span_warning("Save failed — your savefile is not available (guests cannot save)."))
				return TRUE
			var/prefs_ok = prefs.save_preferences()
			var/char_ok = prefs.save_character()
			if(prefs_ok && char_ok)
				to_chat(user, span_notice("Saved to slot [prefs.default_slot]: [prefs.real_name]."))
			else
				to_chat(user, span_warning("Save failed — check savefile permissions."))
			update_static_data_for_all_viewers()
			return TRUE

		if("load_character")
			prefs.load_preferences()
			prefs.load_character()
			to_chat(user, span_notice("Character reloaded from disk."))
			on_identity_change()
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
			refresh_preview(prefs.parent?.mob)
			SStgui.update_uis(src)
			update_static_data_for_all_viewers()
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
			// Re-apply the classic PQ guard so required jobs with bad PQ can only go to LOW.
			if(job.required && !isnull(job.min_pq) && (get_playerquality(user.ckey) < job.min_pq))
				if(jpval == JP_LOW)
					// already low — allow null toggle
				else
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
				on_identity_change()
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
				on_identity_change()
			return TRUE

		if("set_combat_music")
			var/picked = tgui_input_list(user, "To you, the Signal sounds like:", "COMBAT MUSIC", GLOB.cmode_tracks_by_name, prefs.combat_music?.name)
			if(picked)
				prefs.combat_music = GLOB.cmode_tracks_by_name[picked]
				to_chat(user, span_notice("Selected track: <b>[picked]</b>."))
				on_identity_change()
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
/datum/preferences_menu/proc/count_other_subspecies(datum/species/current)
	if(!current)
		return 0
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
/datum/preferences_menu/proc/on_identity_change()
	if(!prefs)
		return
	prefs.save_preferences()
	prefs.save_character()
	// Use our lobby-safe refresh instead of update_preview_icon() — the classic proc
	// short-circuits when parent.is_new_player() is TRUE (i.e. exactly when we need it).
	refresh_preview(prefs.parent?.mob)
	SStgui.update_uis(src)

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
