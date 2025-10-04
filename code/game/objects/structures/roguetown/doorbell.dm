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

/obj/structure/doorbell/Initialize()
	if(!bell_area) // if not overridden in map, use spawn location
		bell_area = get_area(get_turf(src))
	. = ..()

/obj/structure/doorbell/attack_hand(mob/user)
	if(world.time < last_ring + 15 SECONDS)
		return
	to_chat(user, span_notice("I ring the [bell_name]."))
	playsound(src, 'sound/misc/doorbell.ogg', 100, extrarange = 5)
	last_ring = world.time
	for(var/i = GLOB.player_list.len; i > 0; i--)
		var/mob/M = GLOB.player_list[i]
		if(!istype(M) || M == user)
			continue
		if(istype(get_area(M), bell_area))
			to_chat(M, span_notice("You hear the [bell_name] ring."))
