
/proc/add_roundplayed(key)
	var/json_file = file("data/roundsplayed.json")
	if(!fexists(json_file))
		WRITE_FILE(json_file, "{}")
	var/list/json = json_decode(file2text(json_file))

	if(islist(key))
		var/list/L = key
		for(var/K in L)
			var/curtriumphs = 0
			if(json[K])
				curtriumphs = json[K]
			curtriumphs += 1
			json[K] = curtriumphs
	else
		var/curtriumphs = 0
		if(json[key])
			curtriumphs = json[key]
		curtriumphs += 1
		json[key] = curtriumphs

	fdel(json_file)
	WRITE_FILE(json_file, json_encode(json))

/proc/get_roundsplayed(key)
	var/json_file = file("data/roundsplayed.json")
	if(!fexists(json_file))
		return 0
	var/list/json = json_decode(file2text(json_file))

	if(json[key])
		return json[key]
	return 0

/proc/add_nightsurvive(key)
	var/json_file = "data/player_saves/[copytext(key,1,2)]/[key]/nightsurvive.json"
	if(!rustg_file_exists(json_file))
		rustg_file_write("{}", json_file)
	
	var/file_content = rustg_file_read(json_file)
	// FILE I/O CAN FAIL YOU DIMWIT
	var/list/json
	try
		json = json_decode(file_content)
	catch
		json = list()
	if(!json)
		json = list()

	if(islist(key))
		var/list/L = key
		for(var/K in L)
			var/curtriumphs = 0
			if(json[K])
				curtriumphs = json[K]
			curtriumphs += 1
			json[K] = curtriumphs
	else
		var/curtriumphs = 0
		if(json[key])
			curtriumphs = json[key]
		curtriumphs += 1
		json[key] = curtriumphs

	rustg_file_write(json_encode(json), json_file)

/proc/get_nightsurvive(key)
	var/json_file = "data/player_saves/[copytext(key,1,2)]/[key]/nightsurvive.json"
	if(!rustg_file_exists(json_file))
		return 0
	
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
		log_game("ROUNDS ERROR: File for [key] corrupt after [read_attempts] attempts")
		return 0
	
	// FILE I/O CAN FAIL YOU DIMWIT
	var/list/json
	try
		json = json_decode(file_content)
	catch
		log_game("ROUNDS ERROR: JSON decode failed for [key]")
		return 0
	
	if(!json)
		return 0

	if(json[key])
		return json[key]
	return 0
