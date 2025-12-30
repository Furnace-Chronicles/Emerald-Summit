/obj/item/signal_horn
	name = "signal horn"
	desc = "Used to sound the alarm."
	icon = 'modular_hearthstone/icons/obj/items/signalhorn.dmi'
	icon_state = "signalhorn"
	slot_flags = ITEM_SLOT_HIP|ITEM_SLOT_NECK
	w_class = WEIGHT_CLASS_NORMAL
	grid_height = 32
	grid_width = 64
	var/last_toot

/obj/item/signal_horn/attack_self(mob/living/user)
	. = ..()
	if(world.time < last_toot + 15 SECONDS)
		to_chat(user, span_notice("Not yet!"))
	user.visible_message(span_warning("[user] is about to sound the [src]!"))
	if(do_after(user, 15))
		sound_horn(user)

/obj/item/signal_horn/proc/sound_horn(mob/living/user)
	user.visible_message(span_warning("[user] sounds the alarm!"))
	switch(user.job)
		if("Warden")
			playsound(src, 'modular_hearthstone/sound/items/bogguardhorn.ogg', 100, TRUE)
		if("Town Sheriff", "Watchman", "Sergeant", "Man at Arms")
			playsound(src, 'modular_hearthstone/sound/items/watchhorn.ogg', 100, TRUE)
		if("Royal Guard")
			playsound(src, 'modular_hearthstone/sound/items/rghorn.ogg', 100, TRUE)
		else
			playsound(src, 'modular_hearthstone/sound/items/signalhorn.ogg', 100, TRUE)

	var/turf/origin_turf = get_turf(src)

	for(var/mob/living/player in GLOB.player_list)
		if(player.stat == DEAD)
			continue
		if(isbrain(player))
			continue

		var/distance = get_dist(player, origin_turf)
		if(distance <= 7)
			continue
		var/dirtext = " to the "
		var/direction = angle2dir(Get_Angle(player, origin_turf))
		switch(direction)
			if(NORTH)
				dirtext += "north"
			if(SOUTH)
				dirtext += "south"
			if(EAST)
				dirtext += "east"
			if(WEST)
				dirtext += "west"
			if(NORTHWEST)
				dirtext += "northwest"
			if(NORTHEAST)
				dirtext += "northeast"
			if(SOUTHWEST)
				dirtext += "southwest"
			if(SOUTHEAST)
				dirtext += "southeast"
			else //Where ARE you.
				dirtext = "although I cannot make out an exact direction"

		var/disttext
		switch(distance)
			if(0 to 20)
				disttext = " within 20 paces"
			if(20 to 40)
				disttext = " 20 to 40 paces away"
			if(40 to 80)
				disttext = " 40 to 80 paces away"
			if(80 to 160)
				disttext = " far"
			else
				disttext = " very far"

		var/placetext
		var/area/localarea = get_area_name(src)
		switch(localarea)
			if("mountains")
				placetext = " In the Mountains!"
			if("mt decapitation")
				placetext = " from Mt Decapitation!"
			if("black basin")
				placetext = " in the The Black Basin!"
			if("wilderness")
				placetext = " in the The Scarlet Grove!"
			if("bog", "dense bog")
				placetext = " in the The Terrorbog!"
			if("coast", "coastforest")
				placetext = " on the Scarlet Coast!"
			if("indoors", "Shop", "Physician", "outdoors", "roofs")
				placetext = " somewhere in town!"
			if("Manor", "Wizard's Tower")
				placetext = " from the Keep!"
			if("Garrison", "dungeon cell")
				placetext = " from the Garrison!"
			if("Baths", "tavern")
				placetext = " from the Inn!"
			if("church")
				placetext = " from the Church!"
			else
				placetext = " I cannot discern where it came from exactly!"

		//sound played for other players
		switch(user.job)
			if("Warden")
				player.playsound_local(get_turf(player), 'modular_hearthstone/sound/items/bogguardhorn.ogg', 35, FALSE, pressure_affected = FALSE)
				to_chat(player, span_warning("I hear the horn of the Wardens somewhere[disttext],[dirtext],[placetext]"))
			if("Marshall", "Watchman", "Sergeant", "Man at Arms")
				player.playsound_local(get_turf(player), 'modular_hearthstone/sound/items/watchhorn.ogg', 35, FALSE, pressure_affected = FALSE)
				to_chat(player, span_warning("I hear the horn of the Garrison somewhere[disttext],[dirtext],[placetext]"))
			if("Knight")
				player.playsound_local(get_turf(player), 'modular_hearthstone/sound/items/rghorn.ogg', 35, FALSE, pressure_affected = FALSE)
				to_chat(player, span_warning("I hear the horn of the Royal Guard somewhere[disttext],[dirtext],[placetext]"))
			else
				player.playsound_local(get_turf(player), 'modular_hearthstone/sound/items/signalhorn.ogg', 35, FALSE, pressure_affected = FALSE)
				to_chat(player, span_warning("I hear the signal horn somewhere[disttext], [dirtext],[placetext]"))

				


//used for the unique warden horn, port from Azure Peak
//This needs to be made into a subtype of the main horn, I was just too lazy to get it working for now. 
#define WARDEN_AMBUSH_MIN 2
#define WARDEN_AMBUSH_MAX 9

/obj/item/warden_horn
	name = "warden horn"
	icon = 'modular_hearthstone/icons/obj/items/signalhorn.dmi' // need to make a unique icon for this
	icon_state = "signalhorn"
	slot_flags = ITEM_SLOT_HIP|ITEM_SLOT_NECK
	w_class = WEIGHT_CLASS_NORMAL
	grid_height = 32
	grid_width = 64

/obj/item/warden_horn/examine()
	. = ..()
	. += span_notice("Using the horn will make you stand still and induce several ambushes to happen at once, enabling you to clear out an area. It cannot be used in rapid succession.")
	. += span_notice("Using it will leave you exhausted for a moment. Bring friends!")
	
/obj/item/warden_horn/attack_self(mob/living/user)
	. = ..()
	var/area/AR = get_area(user)
	var/datum/threat_region/TR = SSregionthreat.get_region(AR.threat_region)
	if(!TR || !TR.latent_ambush || TR.fixed_ambush)
		to_chat(user, span_warning("There's no point in sounding the horn here."))
		return
	if(user.get_will_block_ambush())
		to_chat(user, span_warning("This place is too well-lit for enemies to come."))
		return
	if(!user.get_possible_ambush_spawn(min_dist = WARDEN_AMBUSH_MIN, max_dist = WARDEN_AMBUSH_MAX))
		to_chat(user, span_warning("This place is too lightly vegetated for enemies to hide."))
		return
	if(TR && TR.last_induced_ambush_time && (world.time < TR.last_induced_ambush_time + 5 MINUTES))
		to_chat(user, span_warning("Foes have been cleared out here recently, perhaps you should wait a moment before sounding the horn again."))
		return
	user.visible_message(span_userdanger("[user] is about to sound [src]!"))
	user.apply_status_effect(/datum/status_effect/debuff/clickcd, 5 SECONDS) // We don't want them to spam the message.
	if(do_after(user, 30 SECONDS)) // Enough time for any antag to kick or interrupt third party, me think
		TR.last_induced_ambush_time = world.time
		user.Immobilize(30) // A very crude solution to kill any solo gamer
		warden_sound_horn(user)

/obj/item/warden_horn/proc/warden_sound_horn(mob/living/user)
	user.visible_message(span_userdanger("[user] blows the horn!"))
	switch(user.job)
		if("Warden")
			playsound(src, 'modular_hearthstone/sound/items/bogguardhorn.ogg', 100, TRUE)
		if("Town Sheriff", "Watchman", "Sergeant", "Man at Arms")
			playsound(src, 'modular_hearthstone/sound/items/watchhorn.ogg', 100, TRUE)
		if("Knight Captain", "Royal Guard")
			playsound(src, 'modular_hearthstone/sound/items/rghorn.ogg', 100, TRUE)
		else
			playsound(src, 'modular_hearthstone/sound/items/signalhorn.ogg', 100, TRUE)
	for(var/mob/living/player in GLOB.player_list)
		if(player.stat == DEAD)
			continue
		if(isbrain(player))
			continue
		var/turf/origin_turf = get_turf(src)
		var/distance = get_dist(player, origin_turf)
		if(distance <= 7 || distance > 21) // two screens away
			continue
		var/dirtext = " to the "
		var/direction = get_dir(player, origin_turf)
		switch(direction)
			if(NORTH)
				dirtext += "north"
			if(SOUTH)
				dirtext += "south"
			if(EAST)
				dirtext += "east"
			if(WEST)
				dirtext += "west"
			if(NORTHWEST)
				dirtext += "northwest"
			if(NORTHEAST)
				dirtext += "northeast"
			if(SOUTHWEST)
				dirtext += "southwest"
			if(SOUTHEAST)
				dirtext += "southeast"
			else //Where ARE you.
				dirtext = "although I cannot make out an exact direction"
		switch(user.job)
			if("Warden")
				player.playsound_local(get_turf(player), 'modular_hearthstone/sound/items/bogguardhorn.ogg', 35, FALSE, pressure_affected = FALSE)
			if("Marshall", "Watchman", "Sergeant", "Man at Arms")
				player.playsound_local(get_turf(player), 'modular_hearthstone/sound/items/watchhorn.ogg', 35, FALSE, pressure_affected = FALSE)
			if("Knight Captain", "Knight")
				player.playsound_local(get_turf(player), 'modular_hearthstone/sound/items/rghorn.ogg', 35, FALSE, pressure_affected = FALSE)
			else
				player.playsound_local(get_turf(player), 'modular_hearthstone/sound/items/signalhorn.ogg', 35, FALSE, pressure_affected = FALSE)
		to_chat(player, span_warning("I hear the horn of the Wardens somewhere [dirtext]"))

	var/random_ambushes = 4 + rand(0,2) // 4 - 6 ambushes
	var/did_ambush = FALSE
	for(var/i = 0, i < random_ambushes, i++)
		var/silent = (i != 0)
		var/success = user.consider_ambush(TRUE, TRUE, min_dist = WARDEN_AMBUSH_MIN, max_dist = WARDEN_AMBUSH_MAX, silent = silent)
		if(success)
			did_ambush = TRUE
	return did_ambush
