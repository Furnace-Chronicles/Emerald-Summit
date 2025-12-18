// PQ cache to avoid file spam during roundstart job assignment
GLOBAL_LIST_EMPTY(pq_cache) // ckey => pq_value

// Queue a ckey for batched PQ loading (called on client login)
/proc/queue_pq_load(ckey_to_load)
	SSplayer_data_loader?.queue_player(ckey_to_load)

/proc/get_playerquality(key, text)
	if(!key)
		return
	
	var/ckey_normalized = ckey(key)
	

	// Check cache first (populated on client login)
	// Use 'in' operator to detect 0 values (0 is falsy but valid)
	if(ckey_normalized in GLOB.pq_cache)
		var/the_pq = GLOB.pq_cache[ckey_normalized]
		if(!text)
			return the_pq
		else
			return format_pq_text(the_pq)
	
	// Cache miss - read from file
	var/the_pq = 0
	var/json_file = "data/player_saves/[copytext(key,1,2)]/[key]/pq_num.json"
	if(!rustg_file_exists(json_file))
		rustg_file_write("{}", json_file)
		// Cache the default value for new files
		GLOB.pq_cache[ckey_normalized] = 0
		return 0 // New file, return default
	
	// Retry file read up to 3 times with delays in case Windows is blocking I/O
	var/file_content
	var/read_attempts = 0
	while(read_attempts < 3)
		file_content = rustg_file_read(json_file)
		if(file_content && length(file_content) >= 2)
			break // Success
		read_attempts++
		if(read_attempts < 3)
			sleep(1) // 0.1 second delay before retry
	
	if(!file_content || length(file_content) < 2)
		// File is TRULY corrupted after multiple attempts - recreate it
		var/accessor = usr ? key_name(usr) : "SYSTEM"
		log_game("PQ WARNING: File for [key] still empty after [read_attempts] attempts, recreating (accessed by [accessor])")
		message_admins(span_boldwarning("PQ ERROR: File for [key] corrupt after [read_attempts] read attempts, recreating. Accessed by [accessor]."))
		rustg_file_write("{}", json_file)
		GLOB.pq_cache[ckey_normalized] = 0
		return 0
	
	var/list/json
	try
		json = json_decode(file_content)
	catch
		// JSON decode failed - recreate file
		var/accessor = usr ? key_name(usr) : "SYSTEM"
		log_game("PQ ERROR: Failed to decode JSON for [key], recreating (accessed by [accessor])")
		message_admins(span_boldwarning("PQ ERROR: JSON decode failed for [key], recreating. Accessed by [accessor]."))
		rustg_file_write("{}", json_file)
		GLOB.pq_cache[ckey_normalized] = 0
		return 0
	
	if(!json) // Null check in case decode returns null without throwing
		var/accessor = usr ? key_name(usr) : "SYSTEM"
		log_game("PQ ERROR: JSON decode returned null for [key], recreating (accessed by [accessor])")
		message_admins(span_boldwarning("PQ ERROR: JSON decode returned null for [key], recreating. Accessed by [accessor]."))
		rustg_file_write("{}", json_file)
		GLOB.pq_cache[ckey_normalized] = 0
		return 0

	if(json[ckey(key)])
		the_pq = json[ckey(key)]
	if(!the_pq)
		the_pq = 0
	
	// Cache the value
	GLOB.pq_cache[ckey_normalized] = the_pq
	
	if(!text)
		return the_pq
	else
		return format_pq_text(the_pq)

/proc/format_pq_text(the_pq)
	if(the_pq >= 100)
		return "<span style='color: #ff2400;'>Ascended!</span>"
	if(the_pq >= 70)
		return "<span style='color: #00ff00;'>Magnificent!</span>"
	if(the_pq >= 50)
		return "<span style='color: #00ff00;'>Exceptional!</span>"
	if(the_pq >= 30)
		return "<span style='color: #47b899;'>Great!</span>"
	if(the_pq >= 10)
		return "<span style='color: #69c975;'>Good!</span>"
	if(the_pq >= 5)
		return "<span style='color: #58a762;'>Nice</span>"
	if(the_pq >= -4)
		return "Normal"
	if(the_pq >= -30)
		return "<span style='color: #be6941;'>Poor</span>"
	if(the_pq >= -70)
		return "<span style='color: #cd4232;'>Terrible</span>"
	if(the_pq >= -99)
		return "<span style='color: #e2221d;'>Abysmal</span>"
	if(the_pq <= -100)
		return "<span style='color: #ff00ff;'>Shitter</span>"
	return "Normal"

/proc/adjust_playerquality(amt, key, admin, reason)
	var/curpq = 0
	var/json_file = "data/player_saves/[copytext(key,1,2)]/[key]/pq_num.json"
	if(!rustg_file_exists(json_file))
		rustg_file_write("{}", json_file)
	
	// Retry file read up to 3 times with delays
	var/file_content
	var/read_attempts = 0
	while(read_attempts < 3)
		file_content = rustg_file_read(json_file)
		if(file_content && length(file_content) >= 2)
			break
		read_attempts++
		if(read_attempts < 3)
			sleep(1)
	
	if(!file_content || length(file_content) < 2)
		// Truly corrupted after retries - recreate it
		var/admin_name = admin ? "[admin]" : "SYSTEM"
		log_game("PQ ERROR: File for [key] still empty after [read_attempts] attempts, recreating (requested by [admin_name])")
		message_admins(span_boldwarning("PQ ERROR: File for [key] corrupt after [read_attempts] read attempts, recreating. Requested by [admin_name]."))
		rustg_file_write("{}", json_file)
		file_content = "{}"
	
	// FILE I/O CAN FAIL YOU DIMWIT
	var/list/json
	try
		json = json_decode(file_content)
	catch
		// Failed decode - recreate file
		var/admin_name = admin ? "[admin]" : "SYSTEM"
		log_game("PQ ERROR: Cannot decode JSON for [key], recreating (requested by [admin_name])")
		message_admins(span_boldwarning("PQ ERROR: Cannot decode JSON for [key], recreating. Requested by [admin_name]."))
		rustg_file_write("{}", json_file)
		json = list()
	
	if(!json)
		var/admin_name = admin ? "[admin]" : "SYSTEM"
		log_game("PQ ERROR: JSON decode returned null for [key], recreating (requested by [admin_name])")
		message_admins(span_boldwarning("PQ ERROR: JSON decode returned null for [key], recreating. Requested by [admin_name]."))
		json = list()
	
	if(json[key])
		curpq = json[key]
	curpq += amt
	curpq = CLAMP(curpq, -100, 100)
	json[key] = curpq
	
	// Invalidate cache so next read gets fresh value
	GLOB.pq_cache -= ckey(key)
	
	rustg_file_write(json_encode(json), json_file)

	if(reason || admin)
		var/thing = ""
		if(amt > 0)
			thing += "+[amt]"
		if(amt < 0)
			thing += "[amt]"
		if(admin)
			thing += " by [admin]"
		if(reason)
			thing += " for reason: [reason]"
		if(amt == 0)
			if(!reason && !admin)
				return
			if(admin)
				thing = "NOTE from [admin]: [reason]"
			else
				thing = "NOTE: [reason]"
		thing += " ([GLOB.rogue_round_id])"
		thing += "\n"
		text2file(thing,"data/player_saves/[copytext(key,1,2)]/[key]/playerquality.txt")

		var/msg
		if(!amt)
			msg = "[key] triggered event [msg]"
		else
			if(amt > 0)
				msg = "[key] ([amt])"
			else
				msg = "[key] ([amt])"
		if(admin)
			msg += " - GM: [admin]"
		if(reason)
			msg += " - RSN: [reason]"
		message_admins("[admin] adjusted [key]'s PQ by [amt] for reason: [reason]")
		log_admin("[admin] adjusted [key]'s PQ by [amt] for reason: [reason]")

/client/proc/check_pq()
	set category = "-Special Verbs-"
	set name = "PQ - Check"
	if(!holder)
		return
	var/selection = alert(src, "Check VIA...", "Check PQ", "Character List", "Player List", "Player Name")
	if(!selection)
		return
	var/list/selections = list()
	var/theykey
	if(selection == "Character List")
		for(var/mob/living/H in GLOB.player_list)
			selections[H.real_name] = H.ckey
		if(!selections.len)
			to_chat(src, span_boldwarning("No characters found."))
			return
		selection = input("Which Character?") as null|anything in sortList(selections)
		if(!selection)
			return
		theykey = selections[selection]
	if(selection == "Player List")
		for(var/client/C in GLOB.clients)
			var/usedkey = C.ckey
			selections[usedkey] = C.ckey
		selection = input("Which Player?") as null|anything in sortList(selections)
		if(!selection)
			return
		theykey = selections[selection]
	if(selection == "Player Name")
		selection = input("Which Player?", "CKEY", "") as text|null
		if(!selection)
			return
		theykey = selection
	check_pq_menu(theykey)

/proc/check_pq_menu(ckey)
	if(!fexists("data/player_saves/[copytext(ckey,1,2)]/[ckey]/preferences.sav"))
		to_chat(usr, span_boldwarning("User does not exist."))
		return
	var/popup_window_data = "<center>[ckey]</center>"
	popup_window_data += "<center>PQ: [get_playerquality(ckey, TRUE, TRUE)] ([get_playerquality(ckey, FALSE, TRUE)])</center>"

//	dat += "<table width=100%><tr><td width=33%><div style='text-align:left'><a href='?_src_=prefs;preference=playerquality;task=menu'><b>PQ:</b></a> [get_playerquality(user.ckey, text = TRUE)]</div></td><td width=34%><center><a href='?_src_=prefs;preference=triumphs;task=menu'><b>TRIUMPHS:</b></a> [user.get_triumphs() ? "\Roman [user.get_triumphs()]" : "None"]</center></td><td width=33%></td></tr></table>"
	popup_window_data += "<center><a href='?_src_=holder;[HrefToken()];cursemenu=[ckey]'>CURSES</a></center>"
	popup_window_data += "<table width=100%><tr><td width=33%><div style='text-align:left'>"
	popup_window_data += "Commends: <a href='?_src_=holder;[HrefToken()];readcommends=[ckey]'>[get_commends(ckey)]</a></div></td>"
	popup_window_data += "<td width=34%><center>Round Contributor Points: [get_roundpoints(ckey)]</center></td>"
	popup_window_data += "<td width=33%><div style='text-align:right'>Rounds Survived: [get_roundsplayed(ckey)]</div></td></tr></table>"
	var/list/listy = world.file2list("data/player_saves/[copytext(ckey,1,2)]/[ckey]/playerquality.txt")
	if(!listy.len)
		popup_window_data += span_info("No data on record. Create some.")
	else
		for(var/i = listy.len to 1 step -1)
			var/ya = listy[i]
			if(ya)
				popup_window_data += "<span class='info'>[listy[i]]</span><br>"
	var/datum/browser/noclose/popup = new(usr, "playerquality", "", 390, 320)
	popup.set_content(popup_window_data)
	popup.open()

/client/proc/adjust_pq()
	set category = "-Special Verbs-"
	set name = "PQ - Adjust"
	if(!holder)
		return
	var/selection = alert(src, "Adjust VIA...", "MODIFY PQ", "Character List", "Player List", "Player Name")
	var/list/selections = list()
	var/theykey
	if(selection == "Character List")
		for(var/mob/living/H in GLOB.player_list)
			selections[H.real_name] = H.ckey
		if(!selections.len)
			to_chat(src, span_boldwarning("No characters found."))
			return
		selection = input("Which Character?") as null|anything in sortList(selections)
		if(!selection)
			return
		theykey = selections[selection]
	if(selection == "Player List")
		for(var/client/C in GLOB.clients)
			var/usedkey = C.ckey
//			if(!check_rights(R_ADMIN,0))
//				if(C.ckey in GLOB.anonymize)
//					usedkey = get_fake_key(C.ckey)
			selections[usedkey] = C.ckey
		selection = input("Which Player?") as null|anything in sortList(selections)
		if(!selection)
			return
		theykey = selections[selection]
	if(selection == "Player Name")
		selection = input("Which Player?", "CKEY", "") as text|null
		if(!selection)
			return
		theykey = selection
	if(!fexists("data/player_saves/[copytext(theykey,1,2)]/[theykey]/preferences.sav"))
		to_chat(src, span_boldwarning("User does not exist."))
		return
	var/amt2change = input("How much to modify the PQ by? (20 to -20, or 0 to just add a note)") as null|num
	if(!check_rights(R_ADMIN,0))
		amt2change = CLAMP(amt2change, -20, 20)
	var/raisin = stripped_input("State a short reason for this change", "Game Master", "", null)
	if(!amt2change && !raisin)
		return
	adjust_playerquality(amt2change, theykey, src.ckey, raisin)
	for(var/client/C in GLOB.clients) // I hate this, but I'm not refactoring the cancer above this point.
		if(lowertext(C.key) == lowertext(theykey))
			to_chat(C, "<span class=\"admin\"><span class=\"prefix\">ADMIN LOG:</span> <span class=\"message linkify\">Your PQ has been adjusted by [amt2change] by [key] for reason: [raisin]</span></span>")
			return

/proc/add_commend(key, giver)
	if(!giver || !key)
		return
	var/curcomm = 0
	var/json_file = "data/player_saves/[copytext(key,1,2)]/[key]/commends.json"
	if(!rustg_file_exists(json_file))
		rustg_file_write("{}", json_file)
	
	var/list/json
	try
		json = json_decode(rustg_file_read(json_file))
	catch
		json = list()
	if(!json)
		json = list()
	
	if(json[giver])
		curcomm = json[giver]
	curcomm++
	json[giver] = curcomm
	rustg_file_write(json_encode(json), json_file)

	//add the pq, only on the first commend
	if(curcomm == 1)
//	if(get_playerquality(key) < 29)
		adjust_playerquality(1, ckey(key))

/proc/get_commends(key)
	if(!key)
		return
	var/curcomm = 0
	var/json_file = "data/player_saves/[copytext(key,1,2)]/[key]/commends.json"
	if(!rustg_file_exists(json_file))
		rustg_file_write("{}", json_file)
	
	var/list/json
	try
		json = json_decode(rustg_file_read(json_file))
	catch
		return 0
	if(!json)
		return 0

	for(var/X in json)
		curcomm += json[X]
	if(!curcomm)
		curcomm = 0
	return curcomm

/proc/add_roundpoints(amt, key) //Each round contributor point counts as 0.1 of a PQ.
	if(!key)
		return
	var/curcomm = 0
	var/json_file = "data/player_saves/[copytext(key,1,2)]/[key]/rcp.json"
	if(!rustg_file_exists(json_file))
		rustg_file_write("{}", json_file)
	
	var/list/json
	try
		json = json_decode(rustg_file_read(json_file))
	catch
		json = list()
	if(!json)
		json = list()
	
	if(json["RCP"])
		curcomm = json["RCP"]

	curcomm += amt
	json["RCP"] = curcomm
	rustg_file_write(json_encode(json), json_file)

	if(curcomm < 100 || get_playerquality(key) < 10)
		adjust_playerquality(round(amt/10,0.1), ckey(key))

/proc/get_roundpoints(key)
	if(!key)
		return
	var/curcomm = 0
	var/json_file = "data/player_saves/[copytext(key,1,2)]/[key]/rcp.json"
	if(!rustg_file_exists(json_file))
		rustg_file_write("{}", json_file)
	
	var/list/json
	try
		json = json_decode(rustg_file_read(json_file))
	catch
		return 0
	if(!json)
		return 0

	if(json["RCP"])
		curcomm = json["RCP"]
	if(!curcomm)
		curcomm = 0
	return curcomm

