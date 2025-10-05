/obj/structure/doorbell
	name = "bell"
	desc = "This bell looks big enough to be heard inside the building."
	icon = 'icons/roguetown/misc/structure.dmi'
	icon_state = "bell"
	density = FALSE
	max_integrity = 0
	anchored = TRUE
	var/bell_name = "doorbell"
	var/area/bell_area = null
	var/last_ring
	var/list/player_ignoring = null

/obj/structure/doorbell/Initialize()
	if(!bell_area) // if not overridden in map, use spawn location
		bell_area = get_area(get_turf(src))
	last_ring = world.time
	player_ignoring = list()
	. = ..()

/obj/structure/doorbell/Topic(href, href_list)
	. = ..()
	// defensive checks
	if(!usr)
		return
	var/mob/M = usr
	if(!istype(M))
		return
	switch(href_list["action"])
		if("ignore")
			player_ignoring |= M
			to_chat(M, span_info("You are ignoring the [bell_name]."))
		if("hear_bell")
			player_ignoring -= M
			to_chat(M, span_info("You are no longer ignoring the [bell_name]."))

/obj/structure/doorbell/examine(mob/user)
	. = ..()
	if(!obj_broken)
		if(user in player_ignoring)
			. += span_notice("You are <a href='?src=[REF(src)];action=hear_bell'>ignoring the [bell_name]</a>.")

/obj/structure/doorbell/attack_hand(mob/user)
	if(world.time < last_ring + 15 SECONDS)
		return
	var/is_spammed = world.time < last_ring + 5 MINUTES
	to_chat(user, span_notice("I ring the [bell_name]."))
	if(user in player_ignoring) // if we ring the doorbell, remove from ignore list
		player_ignoring -= user
	playsound(src, 'sound/misc/doorbell.ogg', 100, extrarange = 5)
	last_ring = world.time
	for(var/i = GLOB.player_list.len; i > 0; i--)
		var/mob/M = GLOB.player_list[i]
		if(!istype(M) || M == user)
			continue
		if(!istype(get_area(M), bell_area))
			continue
		if(HAS_TRAIT(M, TRAIT_DEAF) || !M.getorganslot(ORGAN_SLOT_EARS))
			continue
		if(M in player_ignoring)
			continue
		if(is_spammed)
			to_chat(M, span_notice("You hear the [bell_name] ring, again..."))
			to_chat(M, span_info("You feel you can <a href='?src=[REF(src)];action=ignore'>ignore the [bell_name]</a>."))
		else
			to_chat(M, span_notice("You hear the [bell_name] ring."))
		M.playsound_local(M, 'sound/misc/doorbell.ogg', 25)
