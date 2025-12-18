/// Subsystem for batch processing job knowledge population at roundstart
/// Prevents O(n²) knowledge operations from blocking equipment phase
SUBSYSTEM_DEF(job_knowledge_processor)
	name = "Job Knowledge Processor"
	wait = 0.5 SECONDS
	flags = SS_NO_INIT
	runlevels = RUNLEVEL_LOBBY | RUNLEVEL_SETUP | RUNLEVEL_GAME
	
	var/list/pending_queue = list()
	var/batch_size = 5  // Process 5 players per tick
	var/processing = FALSE

/datum/controller/subsystem/job_knowledge_processor/stat_entry(msg)
	msg = "Pending: [length(pending_queue)]"
	return ..()

/datum/controller/subsystem/job_knowledge_processor/fire(resumed)
	if(!length(pending_queue))
		processing = FALSE
		return
	
	processing = TRUE
	var/processed = 0
	
	while(length(pending_queue) && processed < batch_size)
		var/datum/callback/CB = pending_queue[1]
		pending_queue.Cut(1, 2)
		
		if(CB)
			CB.Invoke()
		
		processed++
	
	if(!length(pending_queue))
		processing = FALSE
		log_game("KNOWLEDGE: Batch processing complete")

/// Queue a knowledge population callback for batch processing
/datum/controller/subsystem/job_knowledge_processor/proc/queue_knowledge(datum/callback/CB)
	if(!CB)
		return
	pending_queue += CB
	
	if(!processing)
		log_game("KNOWLEDGE: Starting batch processor with [length(pending_queue)] players queued")
