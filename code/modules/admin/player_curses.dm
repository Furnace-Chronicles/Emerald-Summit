
#define CURSE_MASTER_LIST list("brokedick")

/proc/curse2trait(curse)
	if(!curse)
		return
	switch(curse)
		if("brokedick")
			return TRAIT_LIMPDICK

/proc/has_player_curse(key,curse)
	if(!key)
		return
	if(!curse)
		return
	var/list/json = get_player_curses(key)
	if(!json)
		return
	for(var/X in json)
		if(X == curse)
			return TRUE

/proc/get_player_curses(key)
	if(!key)
		return
	var/json_file = "data/player_saves/[copytext(key,1,2)]/[key]/curses.json"
	if(!rustg_file_exists(json_file))
		rustg_file_write("{}", json_file)
		return list()
	
	// Retry file read
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
		log_game("CURSE ERROR: File for [key] corrupt after [read_attempts] attempts, recreating")
		rustg_file_write("{}", json_file)
		return list()
	
	// FILE I/O CAN FAIL YOU DIMWIT
	var/list/json
	try
		json = json_decode(file_content)
	catch
		log_game("CURSE ERROR: JSON decode failed for [key], recreating")
		rustg_file_write("{}", json_file)
		return list()
	
	if(json)
		return json
	
	log_game("CURSE ERROR: JSON returned null for [key], recreating")
	rustg_file_write("{}", json_file)
	return list()

/proc/apply_player_curse(key, curse)
	if(!key)
		return
	if(!curse)
		return
	var/json_file = "data/player_saves/[copytext(key,1,2)]/[key]/curses.json"
	if(!rustg_file_exists(json_file))
		rustg_file_write("{}", json_file)
	
	var/file_content = rustg_file_read(json_file)
	var/list/json
	try
		json = json_decode(file_content)
	catch
		json = list()
	if(!json)
		json = list()

	if(json[curse])
		return
	json[curse] = 1
	rustg_file_write(json_encode(json), json_file)
	return TRUE

/proc/remove_player_curse(key, curse)
	if(!key)
		return
	if(!curse)
		return
	var/json_file = "data/player_saves/[copytext(key,1,2)]/[key]/curses.json"
	if(!rustg_file_exists(json_file))
		rustg_file_write("{}", json_file)
	
	var/file_content = rustg_file_read(json_file)
	var/list/json
	try
		json = json_decode(file_content)
	catch
		json = list()
	if(!json)
		json = list()

	if(!json[curse])
		return
	json[curse] = null
	rustg_file_write(json_encode(json), json_file)
	return TRUE
