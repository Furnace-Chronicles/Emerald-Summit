// Unified player data batch loader to prevent file handle exhaustion
// Loads PQ, Triumphs, Curses, and RoundsPlayed in controlled batches

SUBSYSTEM_DEF(player_data_loader)
	name = "Player Data Loader"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_PLAYER_DATA
	
	var/list/load_queue = list() // ckeys waiting to load
	var/processing = FALSE
	var/batch_size = 10 // Files per batch (conservative to avoid Windows file handle issues)
	var/batch_delay = 5 // Deciseconds between batches (0.5 seconds - gives Windows time to release handles)

/datum/controller/subsystem/player_data_loader/proc/queue_player(ckey_to_load)
	if(!ckey_to_load)
		return
	var/ckey_normalized = ckey(ckey_to_load)
	
	// Don't queue if already queued
	if(ckey_normalized in load_queue)
		return
	
	load_queue += ckey_normalized
	
	// Start processor if not running
	if(!processing)
		processing = TRUE
		addtimer(CALLBACK(src, PROC_REF(process_batch)), batch_delay, TIMER_STOPPABLE)

/datum/controller/subsystem/player_data_loader/proc/process_batch()
	var/processed = 0
	
	while(processed < batch_size && load_queue.len)
		var/ckey_to_load = load_queue[1]
		load_queue -= ckey_to_load
		
		// Load all player data files
		load_player_data(ckey_to_load)
		processed++
	
	// Schedule next batch if more items
	if(load_queue.len > 0)
		addtimer(CALLBACK(src, PROC_REF(process_batch)), batch_delay, TIMER_STOPPABLE)
	else
		processing = FALSE

/datum/controller/subsystem/player_data_loader/proc/load_player_data(ckey_to_load)
	// Load PQ
	get_playerquality(ckey_to_load)
	
	// Load Triumphs  
	SStriumphs?.get_triumphs(ckey_to_load)
	
	// Load Curses
	get_player_curses(ckey_to_load)
	
	// Load Rounds Played (global proc, not subsystem)
	get_nightsurvive(ckey_to_load)
