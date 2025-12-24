/mob/living/Login()
	login_fade()
	. = ..()
	if(!. || !client)
		return FALSE
		
	//Mind updates
	sync_mind()
	mind.show_memory(src, 0)
	
	// TODO: TEMPORARY WORKAROUND - Remove once roundstart hang issue is fixed
	// Handle deferred equipment if player reconnected after timeout during roundstart
	if(ishuman(src) && mind?.pending_equipment_job)
		var/deferred_job = mind.pending_equipment_job
		var/deferred_latejoin = mind.pending_equipment_latejoin
		mind.pending_equipment_job = null
		mind.pending_equipment_latejoin = FALSE
		
		log_game("EQUIP RESUMED: [key_name(src)] reconnected, completing [deferred_job] equipment")
		
		// Complete equipment that was deferred
		var/datum/job/job = SSjob.GetJob(deferred_job)
		if(job && client)
			var/mob/living/carbon/human/H = src
			// Run the equipment and after_spawn that was skipped
			var/new_mob = job.equip(H, null, null, deferred_latejoin, null, client)
			H = new_mob || H
			
			if(client) // Still connected after equip
				job.after_spawn(H, src, deferred_latejoin)
				
				// Also run advclass selection if this job has subclasses
				if(job.job_subclasses && length(job.job_subclasses))
					SSrole_class_handler.setup_class_handler(H)
				else
					// No advclass - send equipment complete signal immediately
					SEND_SIGNAL(H, COMSIG_JOB_EQUIPPED, deferred_latejoin)

	update_a_intents()
	update_damage_hud()
	update_health_hud()
//	update_tod_hud()
	update_spd()

	update_sight()
//	if (client && (stat == DEAD))
//		client.ghostize()

	var/turf/T = get_turf(src)
	if (isturf(T))
		update_z(T.z)

	//Vents
//	if(ventcrawler)
//		to_chat(src, span_notice("I can ventcrawl! Use alt+click on vents to quickly travel about the station."))

	if(ranged_ability)
		ranged_ability.deactivate()

	set_ssd_indicator(FALSE)
	
	return TRUE

/mob/living/proc/login_fade()
	set waitfor = FALSE
	if(!client)
		return
	var/atom/movable/screen/F = new /atom/movable/screen/fullscreen/fade()
	client.screen += F
	sleep(40)
	if(!client)
		return
	client.screen -= F
	do_time_change()
