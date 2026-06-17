//Make a component to do things like gravity/flying checks
///Manages the loop caused by being on a conveyor belt
///Prevents movement while you're floating, etc
///Takes the direction to move, delay between steps, and time before starting to move as arguments
/datum/component/convey
	var/living_parent = FALSE
	var/speed

/datum/component/convey/Initialize(direction, speed, start_delay)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	living_parent = isliving(parent)
	src.speed = speed
	if(!start_delay)
		start_delay = speed
	var/atom/movable/moving_parent = parent
	var/datum/move_loop/loop = SSmove_manager.move(moving_parent, direction, delay = start_delay, subsystem = SSconveyors, flags=MOVEMENT_LOOP_IGNORE_PRIORITY)
	RegisterSignal(loop, COMSIG_MOVELOOP_PREPROCESS_CHECK, PROC_REF(should_move))
	RegisterSignal(loop, COMSIG_PARENT_QDELETING, PROC_REF(loop_ended))

/datum/component/convey/proc/should_move(datum/move_loop/source)
	SIGNAL_HANDLER
	source.delay = speed //We use the default delay
	if(living_parent)
		var/mob/living/moving_mob = parent
		if((moving_mob.movement_type & FLYING) && !moving_mob.stat)
			return MOVELOOP_SKIP_STEP
	var/atom/movable/moving_parent = parent
	if(moving_parent.anchored)
		return MOVELOOP_SKIP_STEP

/datum/component/convey/proc/loop_ended(datum/source)
	SIGNAL_HANDLER
	if(QDELETED(src))
		return
	qdel(src)

/obj/structure/roller
	name = "roller"
	desc = "A rotating roller that moves items in one direction. Can be powered by rotation from the sides."
	icon = 'icons/obj/roller.dmi'
	icon_state = "roller"
	density = FALSE
	anchored = TRUE
	layer = BELOW_OPEN_DOOR_LAYER
	rotation_structure = TRUE
	stress_use = 0
	initialize_dirs = CONN_DIR_LEFT | CONN_DIR_RIGHT | CONN_DIR_FORWARD | CONN_DIR_FLIP

	var/operating = FALSE
	var/movedir

/obj/structure/roller/Initialize(mapload)
	. = ..()
	movedir = dir

	return INITIALIZE_HINT_LATELOAD

/obj/structure/roller/LateInitialize()
	. = ..()
	set_connection_dir()
	find_rotation_network()
	// A freshly placed roller joins through try_connect, whose pass_rotation_data only propagates
	// on an rpm difference and doesn't reliably push the network's current speed onto the new node
	// (only try_network_merge and later placements call rebuild_group). That left the just-placed
	// roller at RPM 0 until the NEXT roller was placed — re-propagate from the network's generators
	// now so it spins up immediately.
	rotation_network?.rebuild_group()

/obj/structure/roller/Destroy()
	return ..()

/obj/structure/roller/examine(mob/user)
	. = ..()
	. += span_notice("It moves items [dir2text(movedir)].")
	. += span_notice("Rotation can be connected from the [get_rotation_sides_text()] sides.")
	if(rotation_network)
		. += span_notice("RPM: [rotations_per_minute]")
		. += span_notice("Rollers don't consume stress from the network.")
	. += span_notice("Use a <b>wrench</b> to rotate it.")

/obj/structure/roller/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Powered rollers move loose items and mobs in their facing direction.")
	. += span_info("They take rotation from a cog, shaft, or gearbox on one of their sides, and pass it only down an aligned line of rollers.")
	. += span_info("They can be re-aimed to change which way they move items.")

/obj/structure/roller/proc/get_rotation_sides_text()
	var/list/sides = list()
	switch(dir)
		if(NORTH, SOUTH)
			sides = list("east", "west")
		if(EAST, WEST)
			sides = list("north", "south")
	return english_list(sides)

/obj/structure/roller/can_connect(obj/structure/connector)
	var/connect_dir = get_dir(src, connector)
	var/on_src_axis = (connect_dir == movedir || connect_dir == REVERSE_DIR(movedir))

	// Non-rollers (shafts/cogs/gearboxes): keep the base direction-conflict check (generator-gated),
	// and only let them drive us from a SIDE — a rotation source on our front/back doesn't turn us.
	if(!istype(connector, /obj/structure/roller))
		. = ..()
		if(!.)
			return FALSE
		if(on_src_axis)
			return FALSE
		return TRUE

	// Roller-to-roller: link ONLY along an aligned conveyor chain — same/opposite facing AND adjacent
	// along that shared movement axis (front/back). Side-by-side, perpendicular, and corner adjacencies
	// do NOT link, so two roller runs that merely touch stay separate networks (user design call). This
	// is symmetric (on_src_axis == on_other_axis when aligned), so it no longer depends on which roller
	// initiates. Power reaches a chain from a cog/shaft/gearbox on a roller's side, not from neighbours.
	var/obj/structure/roller/other = connector
	var/aligned = (movedir == other.movedir || movedir == REVERSE_DIR(other.movedir))
	if(!aligned || !on_src_axis)
		return FALSE

	return TRUE

// Traversal (power propagation + network splitting) decides connectivity from dpdir, which spans all
// our sides so a cog/shaft/gearbox can drive us from any side. But roller-to-roller it must obey the
// same chain-only rule as can_connect, or a perpendicular neighbour gets treated as wired even though
// it never formed a connection — power leaks across it and reassess won't split there.
/obj/structure/roller/can_rotation_link(obj/structure/structure, direction)
	. = ..()
	if(!.)
		return FALSE
	if(istype(structure, /obj/structure/roller))
		return can_connect(structure)
	return TRUE

/obj/structure/roller/setDir(newdir)
	// movedir must be updated BEFORE ..() — the base setDir runs find_rotation_network()
	// during ..(), and can_connect() keys off movedir. Setting it afterwards made the network
	// connection decision lag one rotation behind the visible facing, so a perpendicular roller
	// would only (wrongly) power up after being rotated through an aligned orientation.
	movedir = newdir
	. = ..()
	vand_update_appearance()

/obj/structure/roller/take_damage(damage_amount, damage_type = BRUTE, damage_flag = "", sound_effect = TRUE, attack_dir, armor_penetration = 0)
	. = ..()
	// take_damage plays a pixel_x "shake" via animate() when hit, which replaces our looping spin
	// animation and leaves the sprite frozen while the roller is still operating. Restart the spin
	// once the shake (3 x 0.5ds) settles so it keeps visibly turning.
	if(!QDELETED(src) && operating && rotations_per_minute)
		addtimer(CALLBACK(src, PROC_REF(update_animation_effect)), 2, TIMER_OVERRIDE | TIMER_UNIQUE)

/obj/structure/roller/rotation_break()
	set_rotations_per_minute(0)

/obj/structure/roller/set_stress_use(new_stress, check_network)
	return TRUE

/obj/structure/roller/set_rotations_per_minute(rpm)
	if(rotations_per_minute == rpm)
		return FALSE

	rotations_per_minute = rpm

	if(rpm > 0)
		operating = TRUE
	else
		operating = FALSE
		for(var/atom/movable/movable in loc)
			stop_conveying(movable)

	vand_update_appearance()
	return TRUE

/obj/structure/roller/proc/get_move_delay()
	// Higher RPM = faster movement (shorter delay)
	// At 16 RPM: 1 second, at 32 RPM: 0.5 seconds, at 64 RPM: 0.25 seconds
	var/clamprpm = clamp(rotations_per_minute,0,32) //limiting RPM down
	return max(1, (10 / (clamprpm / 16))) // Returns deciseconds

// ES adaptation: our codebase lacks the connect_loc element, so we use Crossed/Uncrossed instead
/obj/structure/roller/Crossed(atom/movable/entering_atom)
	. = ..()

	if(!operating || !rotations_per_minute)
		return

	if(!ismovable(entering_atom))
		return

	var/static/list/unconveyables = typecacheof(list(/obj/effect, /mob/dead))
	if(is_type_in_typecache(entering_atom, unconveyables))
		return

	if(entering_atom.anchored || entering_atom == src)
		return

	start_conveying(entering_atom)

/obj/structure/roller/proc/start_conveying(atom/movable/moving)
	if(QDELETED(moving))
		return

	var/datum/move_loop/move/existing_loop = SSmove_manager.processing_on(moving, SSconveyors)
	if(existing_loop)
		existing_loop.direction = movedir
		existing_loop.delay = get_move_delay()
		return

	moving.AddComponent(/datum/component/convey, movedir, get_move_delay())

/obj/structure/roller/proc/stop_conveying(atom/movable/thing)
	if(!ismovable(thing))
		return
	SSmove_manager.stop_looping(thing, SSconveyors)

/obj/structure/roller/Uncrossed(atom/movable/exiting_atom)
	. = ..()

	if(!ismovable(exiting_atom))
		return

	var/obj/structure/roller/next_roller = locate(/obj/structure/roller) in get_turf(exiting_atom)

	// Stop conveying if no operating roller in exit direction
	if(!next_roller || !next_roller.operating)
		stop_conveying(exiting_atom)

/obj/structure/roller/wrench_act(mob/living/user, obj/item/tool)
	tool.play_tool_sound(src, 50)
	rotate_roller(user)
	return TRUE

/obj/structure/roller/proc/rotate_roller(mob/user)
	setDir(turn(dir, 90))
	to_chat(user, span_notice("You rotate [src]."))

/obj/structure/roller/vand_update_appearance()
	. = ..()
	// Always refresh the animation — update_animation_effect() handles both the spinning and
	// the stopped state (it resets to the static frame when rpm is 0). Gating on operating
	// meant a roller losing power never got told to stop, so it kept visually spinning even
	// though conveying and the readouts had already halted.
	update_animation_effect()

/obj/structure/roller/update_animation_effect()
	if(!rotation_network || rotation_network.overstressed || !rotations_per_minute)
		animate(src, icon_state = "roller", time = 1)
		return
	var/clamprpm = clamp(rotations_per_minute,0,32) //limiting RPM down
	// match the autosmither cadence so the spin reads cleanly: 2ds/frame at 16 RPM, 1ds/frame
	// at 32 RPM (a full 4-frame cycle in 0.8s / 0.4s). The old formula ran ~10x faster and
	// flickered at 32 RPM.
	var/frame_time = 32 / max(1, clamprpm)

	animate(src, icon_state = "roller1", time = frame_time, loop = -1)
	animate(icon_state = "roller2", time = frame_time)
	animate(icon_state = "roller3", time = frame_time)
	animate(icon_state = "roller4", time = frame_time)

/obj/structure/roller/attack_right(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	var/obj/item/held_item = user.get_active_held_item()
	if(held_item?.type != /obj/item/contraption/linker)
		return
	rotate_roller(user)
	return TRUE
