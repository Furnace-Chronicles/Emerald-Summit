/datum/looping_sound/waterwheel_loop
	mid_sounds = 'sound/items/wheelwater.ogg'
	mid_length = 6 SECONDS
	volume = 40
	extra_range = -1

/obj/structure/waterwheel
	name = "waterwheel"

	icon = 'icons/roguetown/misc/waterwheel.dmi'
	icon_state = "1"

	layer = 5
	stress_generator = TRUE
	rotation_structure = TRUE
	initialize_dirs = CONN_DIR_FORWARD | CONN_DIR_FLIP

	var/datum/looping_sound/waterwheel_loop/soundloop

/obj/structure/waterwheel/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Place it in flowing river water with the wheel facing across the current, not along it.")
	. += span_info("When the flow is strong enough, it generates rotational power for connected shafts and machinery.")
	. += span_info("Right-click it while holding an engineering wrench to turn it if it sits the wrong way.")

/obj/structure/waterwheel/Initialize()
	soundloop = new(src, FALSE)
	. = ..()
	AddComponent(/datum/component/simple_rotation, ROTATION_REQUIRE_WRENCH|ROTATION_IGNORE_ANCHORED)

/obj/structure/waterwheel/Destroy()
	QDEL_NULL(soundloop)
	return ..()

// The orientation check in setup_rotation() runs during init, but placement (and the wrench)
// apply the final facing through setDir() afterwards — so re-validate whenever we turn.
// A wheel turned parallel to the flow stops generating; turned back across it, it restarts.
/obj/structure/waterwheel/setDir(newdir)
	. = ..()
	if(!rotation_network)
		return
	set_connection_dir()
	reevaluate_rotation()

/obj/structure/waterwheel/proc/reevaluate_rotation()
	var/turf/open/water/river/water = get_turf(src)
	if(istype(water) && (water.dir & ALL_CARDINALS) && water.water_volume >= 10 && dir != water.dir && dir != REVERSE_DIR(water.dir))
		setup_rotation(water)
		return
	if(!last_stress_generation && !rotations_per_minute)
		return // already idle
	set_stress_generation(0, FALSE)
	set_rotational_direction_and_speed(rotation_direction || EAST, 0)

/obj/structure/waterwheel/proc/has_active_rotation()
	return rotation_network && !rotation_network?.overstressed && rotations_per_minute && rotation_network?.total_stress && last_stress_generation

/obj/structure/waterwheel/proc/update_soundloop()
	if(!soundloop)
		return
	if(has_active_rotation())
		if(soundloop.stopped)
			soundloop.start()
		return
	if(!soundloop.stopped)
		soundloop.stop()

/obj/structure/waterwheel/find_rotation_network()
	. = ..()
	setup_rotation(get_turf(src))

/obj/structure/waterwheel/proc/setup_rotation(turf/open/water/river/water)
	if(!water)
		water = get_turf(src)
	if(!istype(water))
		return
	if(water.water_volume < 10)
		return
	var/wheel_rotation_dir = water.dir
	if(!(wheel_rotation_dir & ALL_CARDINALS))
		return
	if(dir == wheel_rotation_dir || dir == REVERSE_DIR(wheel_rotation_dir)) //incorrect orientation
		return

	if(EWCOMPONENT(wheel_rotation_dir))
		wheel_rotation_dir = EWDIRFLIP(wheel_rotation_dir)
	else // northern water is EAST rotation, southern water is WEST rotation
		wheel_rotation_dir = turn(wheel_rotation_dir, -90)
	last_stress_generation = 0
	set_stress_generation(1024)
	set_rotational_direction_and_speed(wheel_rotation_dir, 8)
	return TRUE

/obj/structure/waterwheel/update_animation_effect()
	update_soundloop()
	if(!has_active_rotation())
		animate(src, icon_state = "1", time = 1)
		return
	var/frame_stage = 1 / ((rotations_per_minute / 60) * 4)
	if(rotation_direction == WEST)
		// start on a frame that differs from the resting state — BYOND discards animations whose
		// first step doesn't change the appearance, which froze every CCW sprite
		animate(src, icon_state = "2", time = frame_stage, loop=-1)
		animate(icon_state = "3", time = frame_stage)
		animate(icon_state = "4", time = frame_stage)
		animate(icon_state = "1", time = frame_stage)
	else
		animate(src, icon_state = "4", time = frame_stage, loop=-1)
		animate(icon_state = "3", time = frame_stage)
		animate(icon_state = "2", time = frame_stage)
		animate(icon_state = "1", time = frame_stage)
