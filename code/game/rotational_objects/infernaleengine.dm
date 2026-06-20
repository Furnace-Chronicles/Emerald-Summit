/obj/structure/infernalengine
	icon = 'icons/roguetown/misc/forge.dmi'
	name = "infernal engine"
	desc = "This engine uses cycling magma from an internal core to rotate large machinery."
	icon_state = "infernal0"
	var/base_state = "infernal"
	var/on = FALSE
	//these is built and anchored, artificers need to be careful where they place them, one of the drawbacks
	anchored = TRUE
	density = TRUE
	layer = ABOVE_MOB_LAYER + 0.01 // draw over adjacent cogs/shafts, which sit at ABOVE_MOB_LAYER
	stress_generator = TRUE
	rotation_structure = TRUE
	initialize_dirs = CONN_DIR_FORWARD | CONN_DIR_FLIP
	debris = list(/obj/item/magic/infernal/core = 1)

/obj/structure/infernalengine/examine(mob/user)
	. = ..()
	. += span_info("This engine generates rotational power continuously for connected machinery while it remains active.")
	. += span_info("Keep it out of wet terrain. Water can extinguish it and stop the engine.")
	if(!on)
		. += span_info("Its core lies dormant. Strike it with sparks to reignite it.")

/obj/structure/infernalengine/find_rotation_network()
	. = ..()
	setup_rotation(get_turf(src))

// ES adaptation: RW's version called extinguish() on wet turfs but powered the network anyway,
// and never actually stopped the engine — the water interaction is implemented properly here.
/obj/structure/infernalengine/proc/setup_rotation(turf/open/water/river/water)
	if(isopenturf(loc))
		var/turf/open/O = loc
		if(IS_WET_OPEN_TURF(O))
			extinguish()
			return FALSE
	on = TRUE
	icon_state = "infernal1"
	update_icon()
	var/engine_rotation_dir = EAST

	last_stress_generation = 0
	set_stress_generation(1024)
	set_rotational_direction_and_speed(engine_rotation_dir, 32) //high RPM to make up for the difficulty to make this
	return TRUE

/obj/structure/infernalengine/extinguish()
	if(!on)
		return ..()
	on = FALSE // set before touching the network so its update can't re-enter us
	icon_state = "infernal0"
	update_icon()
	visible_message(span_warning("[src] sputters and goes cold!"))
	if(rotation_network)
		set_stress_generation(0, FALSE)
		set_rotational_direction_and_speed(EAST, 0)
	return ..()

/obj/structure/infernalengine/spark_act()
	. = ..()
	if(on)
		return
	if(isopenturf(loc))
		var/turf/open/O = loc
		if(IS_WET_OPEN_TURF(O))
			visible_message(span_warning("[src] hisses. Its core refuses to ignite in the wet."))
			return
	visible_message(span_notice("[src] roars back to life!"))
	playsound(src, 'sound/items/firelight.ogg', 100)
	setup_rotation(get_turf(src))

/obj/structure/infernalengine/fire_act(added, maxstacks)
	spark_act()

/obj/structure/infernalengine/update_animation_effect()
	if(!rotation_network || rotation_network?.overstressed || !rotations_per_minute || !rotation_network?.total_stress) //if the loop is over stressed we turn things off
		extinguish()
		return

	//if its working and turned on...
	on = TRUE
	icon_state = "infernal1"
	update_icon()
