/obj/structure
	var/rotation_structure = FALSE
	var/rotations_per_minute
	var/stress_use
	var/last_stress_added = 0
	var/rotation_direction
	var/cog_size = COG_SMALL
	var/stress_generator = FALSE
	var/last_stress_generation
	var/accepts_water_input = FALSE
	/// Bitmask of actual directions structure can connect to
	var/dpdir
	/// Bitflags of relative directional SHAFT connections. See \code\_DEFINES\rotation_defines.dm
	var/initialize_dirs

/* //we're not include waterpumps right now
	var/obj/structure/water_pipe/input
	var/obj/structure/water_pipe/output
*/
	var/datum/rotation_network/rotation_network

/obj/structure/Initialize(mapload, ndir)
	// placement passes the final facing through new() so LateInitialize computes dpdir and
	// joins networks with the correct sides — setDir afterwards would transiently connect
	// on the default-facing sides, which can wrongly merge (or break) neighboring networks.
	// rotation_structure guard: other structures get unrelated extra new() args (wild_plant)
	if(ndir && rotation_structure)
		dir = ndir
	. = ..()
	if(rotation_structure || accepts_water_input)
		return INITIALIZE_HINT_LATELOAD

/obj/structure/LateInitialize()
	. = ..()
	if(redstone_id)
		for(var/obj/structure/S in GLOB.redstone_objs)
			if(S.redstone_id == redstone_id)
				redstone_attached |= S
				S.redstone_attached |= src

	if(rotation_structure && !QDELETED(src))
		set_connection_dir()
		find_rotation_network()
/*//we're not include waterpumps right now
	if(accepts_water_input)
		setup_water()
*/

/obj/structure/Destroy()
	if(rotation_network)
		var/datum/rotation_network/old_network = rotation_network
		rotation_network.remove_connection(src)
		old_network.reassess_group(src)
	rotation_network = null
/*//we're not include waterpumps right now
	input = null
	output = null
*/
	return ..()

/obj/structure/MiddleClick(mob/user, params)
	. = ..()
	if(!user.Adjacent(src))
		return
	if(!rotation_structure) //&& !istype(src, /obj/structure/water_pipe)) //we're not include waterpumps right now
		return
	var/obj/item/contraption/linker/linker = user.get_active_held_item()
	if(!istype(linker))
		return

	for(var/obj/item/rotation_contraption/item as anything in subtypesof(/obj/item/rotation_contraption))
		if(type == initial(item.placed_type))
			start_deconstruct(user, item)
			return

// From CC PR 407: right-click a rotation structure with the engineering wrench to rotate it.
/obj/structure/attack_right(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!rotation_structure || !user?.Adjacent(src))
		return
	var/obj/item/contraption/linker/linker = user.get_active_held_item()
	if(!istype(linker))
		return
	var/datum/component/simple_rotation/rotcomp = GetComponent(/datum/component/simple_rotation)
	if(!rotcomp)
		return
	rotcomp.HandRot(rotcomp, user, ROTATION_CLOCKWISE)
	return TRUE

/obj/structure/proc/start_deconstruct(mob/living/user, obj/item/rotation_contraption/type)
	user.visible_message(span_notice("[user] starts to disassemble [src]."), span_notice("You start to disassemble [src]."))
	if(!do_after(user, 2.5 SECONDS  - (user?.get_skill_level(/datum/skill/craft/engineering)  * 2), src))
		return
	new type(get_turf(src))
	qdel(src)

// You can path over a dense structure if it's climbable.
/obj/structure/CanAStarPass(ID, to_dir, requester)
	. = climbable || ..()

/obj/structure/return_rotation_chat(atom/movable/screen/movable/mouseover/mouseover)
	if(!rotation_network)
		return
	mouseover.maptext_height = 112
	// Only show the stress line once the network is actually powered (total_stress > 0). An
	// unpowered standalone part has total_stress 0 and would otherwise display its bare demand
	// as "Stress: 12", which misreads as active consumption. Appended to the RPM line (rather
	// than left as an empty middle line) so hiding it doesn't leave a blank gap.
	var/stress_text = ""
	if(rotation_network.total_stress)
		stress_text = "\n\t\t\t[rotation_network.overstressed ? "OVER:" : "STRESS:"][round(((rotation_network.used_stress / max(1, rotation_network.total_stress)) * 100), 1)]%"
	return {"<span style='font-size:8pt;font-family:"Pterra";color:#e6b120;text-shadow:0 0 1px #fff, 0 0 2px #fff, 0 0 30px #e60073, 0 0 40px #e60073, 0 0 50px #e60073, 0 0 60px #e60073, 0 0 70px #e60073;' class='center maptext '>
			RPM:[rotations_per_minute ? rotations_per_minute : "0"][stress_text]
			DIR:[rotation_direction == 4 ? "CW" : rotation_direction == 8 ? "CCW" : ""]</span>"}

/obj/structure/setDir(newdir)
	if(rotation_network)
		if(!dpdir)
			set_connection_dir()
		var/datum/rotation_network/old_network = rotation_network
		rotation_network.remove_connection(src)
		old_network.reassess_group(src)
		. = ..()
		set_connection_dir()
		find_rotation_network()
	else
		. = ..()

/obj/structure/proc/set_connection_dir()
	if(QDELETED(src) || !rotation_structure || !initialize_dirs)
		return

	var/newdpdir = NONE
	if(!(initialize_dirs & CONN_DIR_NONE))
		if(initialize_dirs & CONN_DIR_FORWARD)
			newdpdir |= dir
		if(initialize_dirs & CONN_DIR_LEFT)
			newdpdir |= turn(dir, 90)
		if(initialize_dirs & CONN_DIR_RIGHT)
			newdpdir |= turn(dir, -90)
		if(initialize_dirs & CONN_DIR_FLIP)
			newdpdir |= turn(dir, 180)
		if(initialize_dirs & CONN_DIR_Z_UP)
			newdpdir |= UP
		if(initialize_dirs & CONN_DIR_Z_DOWN)
			newdpdir |= DOWN
	dpdir = newdpdir

// Whether `structure` in `direction` is a valid rotation link for power propagation / network
// splitting. Default: the dpdir adjacency test. Subtypes can tighten this so traversal stays
// consistent with how connections actually form (see roller — its dpdir spans all sides for
// side-fed power, but it only chains to other rollers along its movement axis).
/obj/structure/proc/can_rotation_link(obj/structure/structure, direction)
	return (REVERSE_DIR(direction) & structure.dpdir)


/obj/structure/proc/setup_water()
	return
/*
	for(var/direction in GLOB.cardinals)
		var/turf/cardinal_turf = get_step(src, direction)
		for(var/obj/structure/water_pipe/structure in cardinal_turf)
			if(!valid_water_connection(REVERSE_DIR(direction), structure))
				continue
			structure.set_connection(get_dir(structure, src))
*/

/obj/structure/proc/update_animation_effect()
	return

/* //we're not include waterpumps right now
///reminder this is the direction coming from the pipe to src.
/obj/structure/proc/valid_water_connection(direction, obj/structure/water_pipe/pipe)
	return TRUE
*/
/obj/structure/proc/use_water_pressure(pressure)
	return


/obj/structure/proc/find_rotation_network()
	for(var/direction in GLOB.cardinals_multiz)
		if(!(direction & dpdir))
			continue
		var/turf/step_forward = get_step_multiz(src, direction)
		for(var/obj/structure/structure in step_forward?.contents)
			if(!structure.rotation_network || !structure.dpdir)
				continue
			if(!(REVERSE_DIR(direction) & structure.dpdir))
				continue
			if(rotation_network)
				// Already in the same network as this neighbor — we're closing a loop, not failing
				// to merge. try_network_merge would return FALSE here ("src already in connected"),
				// which find_rotation_network would wrongly treat as a conflict and rotation_break.
				if(structure.rotation_network == rotation_network)
					continue
				// A refused merge just means these two don't wire together (e.g. perpendicular
				// rollers) — leave the networks separate. Don't rotation_break: a real opposing-source
				// conflict is still caught during propagation (propagate_rotation_change).
				structure.try_network_merge(src)
			else
				structure.try_connect(src)

	if(!rotation_network)
		rotation_network = new
		rotation_network.add_connection(src)
		last_stress_added = 0
		set_stress_use(stress_use)

/obj/structure/proc/set_rotational_direction_and_speed(direction, speed)
	set_rotations_per_minute(speed)
	rotation_direction = direction
	find_and_propagate(first = TRUE)
	rotation_network.check_stress()
	rotation_network.update_animation_effect()

/obj/structure/proc/set_rotational_speed(speed)
	set_rotations_per_minute(speed)
	find_and_propagate(first = TRUE)
	rotation_network.check_stress()
	rotation_network.update_animation_effect()

// DOES NOT UPDATE NETWORK ANIMATION
/obj/structure/proc/set_stress_generation(amount, check_network = TRUE)
	rotation_network.total_stress -= last_stress_generation
	rotation_network.total_stress += amount
	last_stress_generation = amount
	if(check_network)
		rotation_network.check_stress()

// DOES NOT UPDATE NETWORK ANIMATION
/obj/structure/proc/set_stress_use(amount, check_network = TRUE)
	rotation_network?.used_stress -= last_stress_added
	rotation_network?.used_stress += amount
	last_stress_added = amount
	stress_use = amount
	if(check_network)
		rotation_network?.check_stress()

/obj/structure/proc/try_connect(obj/structure/connector)
	if(can_connect(connector))
		rotation_network.add_connection(connector)
		pass_rotation_data(connector)
		if(connector.stress_use)
			connector.set_stress_use(connector.stress_use)
		if(connector.stress_generator && connector.last_stress_generation)
			// joining generator brings its output along — otherwise its later set_stress_generation
			// subtracts a contribution this network never received
			rotation_network.total_stress += connector.last_stress_generation
		return TRUE
	return FALSE

/obj/structure/proc/can_connect(obj/structure/connector)
	if(connector.rotation_direction && rotation_direction && (connector.rotation_direction != rotation_direction))
		if(connector.rotations_per_minute && rotations_per_minute)
			// Only a genuine power source spinning against the network is a real conflict. Passive
			// parts (shafts/gearboxes) reached by two paths in a closed loop carry traversal-assigned
			// direction LABELS that can differ without representing opposing spin — rejecting that
			// tears apart a perfectly consistent loop. Let propagation reconcile passive-to-passive
			// connections; a genuinely flipped loop still tears apart at the generator boundary
			// (propagate_rotation_change, gated on stress_generator).
			if(stress_generator || connector.stress_generator)
				return FALSE
	return TRUE

/obj/structure/proc/try_network_merge(obj/structure/connector)
	if(!can_connect(connector))
		return FALSE
	if(!rotation_network)
		return FALSE
	if(src in connector.rotation_network.connected)
		return FALSE
	var/connector_stress = connector.rotation_network.total_stress
	for(var/obj/structure/child in connector.rotation_network.connected)
		if(src == child)
			return FALSE
		connector.rotation_network.remove_connection(child)
		rotation_network.add_connection(child)
		if(child.stress_use) // remove_connection resets last_stress_added
			child.set_stress_use(child.stress_use, check_network = FALSE)
		if(child.stress_generator)
			rotation_network.total_stress += child.last_stress_generation // this is undone in set_stress_generation
			child.set_stress_generation(child.last_stress_generation, check_network = FALSE)
	if(!connector_stress)
		propagate_rotation_change(connector)
	rotation_network.rebuild_group() // <=-- this is dumb as hell but for some reason if you perform a fucking dark ritual or someshit you can trick the game into lobotomizing itself.
	return TRUE

/obj/structure/proc/propagate_rotation_change(obj/structure/connector, list/checked, first = FALSE)
	if(!length(checked))
		checked = list()
	checked |= src

	if(connector.last_stress_generation && connector.rotation_direction && rotation_direction && (connector.rotation_direction != rotation_direction))
		rotation_break()
		return
	connector.rotation_direction = rotation_direction
	if(!connector.stress_generator)
		connector.set_rotations_per_minute(rotations_per_minute)

	connector.find_and_propagate(checked, FALSE)
	if(first)
		connector.update_animation_effect()

/obj/structure/proc/find_and_propagate(list/checked, first = FALSE)
	if(!length(checked))
		checked = list()
	checked |= src

	for(var/direction in GLOB.cardinals_multiz)
		if(!(direction & dpdir))
			continue
		var/turf/step_forward = get_step_multiz(src, direction)
		if(step_forward)
			for(var/obj/structure/structure in step_forward.contents)
				if(structure in checked)
					continue
				if(!structure.rotation_network || !structure.dpdir)
					continue
				if(!(structure in rotation_network.connected))
					continue
				if(!can_rotation_link(structure, direction))
					continue
				propagate_rotation_change(structure, checked, FALSE)
				// propagate_rotation_change can trigger rotation_break, which qdels us mid-pass
				// and re-enters the rebuild; stop rather than keep propagating from a now
				// deleted/disconnected structure and re-powering what the rebuild just reset.
				if(QDELETED(src) || !rotation_network)
					return

	if(first)
		rotation_network?.update_animation_effect()

/obj/structure/proc/pass_rotation_data(obj/structure/connector, list/checked)
	if(!length(checked))
		checked = list()
	checked |= src

	if(connector.rotations_per_minute == rotations_per_minute)
		return

	if(connector.rotations_per_minute > rotations_per_minute)
		connector.propagate_rotation_change(src, first = TRUE)
	else
		propagate_rotation_change(connector, checked, TRUE)

/obj/structure/proc/rotation_break()
	visible_message(span_warning("[src] breaks apart from the opposing directions!"))
	playsound(src, 'sound/foley/cartdump.ogg', 75)
	for(var/obj/item/rotation_contraption/item as anything in subtypesof(/obj/item/rotation_contraption))
		if(type == initial(item.placed_type))
			new item(get_turf(src))
			qdel(src)
			return

/obj/structure/proc/set_rotations_per_minute(speed)
	if(speed > 256)
		rotation_break()
		return FALSE
	rotations_per_minute = speed
	return TRUE

/obj/structure/proc/return_surrounding_rotation(datum/rotation_network/network)
	var/list/surrounding = list()

	for(var/direction in GLOB.cardinals_multiz)
		if(!(direction & dpdir))
			continue
		var/turf/step_forward = get_step_multiz(src, direction)
		if(step_forward)
			for(var/obj/structure/structure in step_forward.contents)
				if(!(structure in network.connected))
					continue
				if(!can_rotation_link(structure, direction)) // structure should be connected by shaft
					continue
				surrounding |= structure

	return surrounding

/obj/structure/proc/return_connected(obj/structure/deleted, list/passed, datum/rotation_network/network)
	var/list/surroundings = return_surrounding_rotation(network)
	var/list/connected = list()
	if(!length(passed))
		passed = list()
	passed |= src
	if(deleted in surroundings)
		surroundings -= deleted

	connected |= surroundings
	for(var/obj/structure/surrounding in surroundings)
		if(surrounding == src)
			continue
		if(surrounding in passed)
			continue
		connected |= surrounding.return_connected(deleted, passed, network)
	return connected
