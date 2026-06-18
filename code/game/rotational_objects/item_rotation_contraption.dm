//pulled in from vanderlin
/obj/item/rotation_contraption
	name = ""
	desc = ""

	w_class =  WEIGHT_CLASS_SMALL
	grid_height = 32
	grid_width = 32

	var/obj/structure/placed_type
	var/in_stack = 1
	var/can_stack = TRUE
	var/place_behavior
	var/resize_factor = 0.95
	/// Optional item-side appearance overrides, so the held/dropped item can differ from the
	/// structure it places. When unset, the item mirrors the placed structure (icon + "[name] item").
	var/item_icon
	var/item_icon_state
	var/item_name
	/// Whether to apply the shared "diamond" look (half scale + 45° turn) to the held/dropped item.
	/// Reskinned items turn this off to show their own sprite normally (upright, full size).
	var/contraption_transform = TRUE

/obj/item/rotation_contraption/Initialize()
	. = ..()
	if(placed_type)
		set_type(placed_type)
	if(can_stack)
		for(var/obj/item/rotation_contraption/contraption in loc)
			if(QDELETED(contraption))
				continue
			if(contraption == src)
				continue
			if(!istype(contraption, src.type))
				continue
			if(placed_type != contraption.placed_type)
				continue

			in_stack += contraption.in_stack
			qdel(contraption)
	//update_appearance(UPDATE_NAME)
	vand_update_appearance(UPDATE_NAME)

// ES adaptation: afterpickup/afterdrop are never invoked in our inventory code, and the base
// update_transform() nulls the matrix on every drop/throw — reapply our look there instead.
/obj/item/rotation_contraption/update_transform()
	. = ..()
	if(!contraption_transform)
		return
	var/matrix/resize = matrix()
	resize.Scale(0.5, 0.5)
	resize.Turn(45)
	transform = resize
	if(resize_factor)
		transform = transform.Scale(resize_factor, resize_factor)

/obj/item/rotation_contraption/proc/set_type(obj/structure/parent_type)
	icon = item_icon || initial(parent_type.icon)
	icon_state = item_icon_state || initial(parent_type.icon_state)
	if(contraption_transform)
		var/matrix/resize = matrix()
		resize.Scale(0.5, 0.5)
		resize.Turn(45)
		transform = resize
		if(resize_factor)
			transform = transform.Scale(resize_factor, resize_factor)
	name = item_name || (initial(parent_type.name) + " item")
	desc = initial(parent_type.desc)
	placed_type = parent_type

/obj/item/rotation_contraption/attack_turf(turf/T, mob/living/user)
	. = ..()
	if(!istype(T))
		return
	// if(is_blocked_turf(T))
	// 	return
	for(var/obj/structure/structure in T.contents)

		if(structure.rotation_structure)// && !ispath(placed_type, /obj/structure/water_pipe))//commenting out water pipes for now 
			return

		if(structure.accepts_water_input && !ispath(placed_type, /obj/structure/rotation_piece))
			return

		if(istype(structure, placed_type))
			return

	// Compute the facing up front: it gates can_place(), and it's passed through new() — the
	// structure hooks up to rotation networks during creation (LateInitialize), so applying dir
	// only afterwards lets it transiently connect on its default-facing sides (see
	// /obj/structure/Initialize). The setDir() below is then redundant on the happy path, but
	// it's the proven wrench-rotation reconnect cycle, kept as a fallback.
	var/wanted_dir
	if(place_behavior == PLACE_TOWARDS_USER)
		if(get_turf(user) == T)
			wanted_dir = REVERSE_DIR(user.dir)
		else
			wanted_dir = get_cardinal_dir(T, user)
	else
		if(get_turf(user) == T)
			wanted_dir = user.dir
		else
			wanted_dir = get_cardinal_dir(user, T)
	if(!can_place(T, user, wanted_dir))
		return
	visible_message("[user] starts placing down [src].", "You start to place [src].")
	if(!do_after(user, 1.2 SECONDS - user?.get_skill_level(/datum/skill/craft/engineering), T))
		return
	var/obj/structure/structure = new placed_type(T, wanted_dir)
	structure.setDir(wanted_dir)
	// setDir() is an appearance change, which discards any animation started during Initialize,
	// and animate() calls on an atom's creation tick don't reliably take — restart the animation
	// a tick later so freshly placed wheels/cogs don't sit frozen until the network next updates.
	addtimer(CALLBACK(structure, TYPE_PROC_REF(/obj/structure, update_animation_effect)), 1)

	in_stack--
	if(in_stack <= 0)
		qdel(src)
	else
		//update_appearance(UPDATE_NAME)
		vand_update_appearance(UPDATE_NAME)

/// Last-gate placement check, called with the facing the structure will be placed with.
/// Return FALSE (and tell the user why) to refuse placement.
/obj/item/rotation_contraption/proc/can_place(turf/T, mob/living/user, wanted_dir)
	return TRUE

/obj/item/rotation_contraption/vand_update_name()
	. = ..()
	if(in_stack > 1)
		var/base = item_name || initial(placed_type.name)
		var/suffix = "s"
		if(copytext(base, length(base)) in list("s", "x", "z")) // "gearboxes", not "gearboxs"
			suffix = "es"
		name = "pile of [base][suffix] x [in_stack]"
	else
		name = item_name || (initial(placed_type.name) + " item")

// Right-click a pile (held or on the ground) to take a single piece off it into your hand.
/obj/item/rotation_contraption/attack_right(mob/user)
	if(in_stack <= 1)
		return ..()
	if(loc != user && !user.Adjacent(src))
		return ..()
	var/obj/item/rotation_contraption/single = new type(null) // null loc so Initialize doesn't merge it straight back into us
	if(!user.put_in_hands(single))
		qdel(single)
		to_chat(user, span_warning("I need a free hand to take one."))
		return TRUE
	in_stack--
	vand_update_appearance(UPDATE_NAME)
	to_chat(user, span_notice("I take \a [single.name] from [src]."))
	return TRUE

/obj/item/rotation_contraption/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	if(!can_stack)
		return
	if(!istype(I, src.type))
		return
	if(placed_type != I:placed_type)
		return

	I:in_stack += in_stack
	visible_message("[user] collects [src].")
	qdel(src)
	//I.update_appearance(UPDATE_NAME)
	I.vand_update_appearance(UPDATE_NAME)

/obj/item/rotation_contraption/cog
	placed_type = /obj/structure/rotation_piece/cog

/obj/item/rotation_contraption/shaft
	placed_type = /obj/structure/rotation_piece
	// reskin to the wood-shaft sprite and a distinct name (it still places a rotation_piece)
	item_icon = 'icons/roguetown/misc/shafts.dmi'
	item_icon_state = "woodshaft"
	item_name = "engineering shaft"
	contraption_transform = FALSE // show the wood-shaft sprite upright, not the diamond look

/obj/item/rotation_contraption/large_cog
	placed_type = /obj/structure/rotation_piece/cog/large

/obj/item/rotation_contraption/horizontal
	placed_type = /obj/structure/gearbox

/obj/item/rotation_contraption/vertical
	placed_type = /obj/structure/vertical_gearbox

/obj/item/rotation_contraption/waterwheel
	placed_type = /obj/structure/waterwheel

	grid_height = 96
	grid_width = 96

// A wheel set along the current (facing with or against the flow) can't catch it — refuse
// the placement outright instead of leaving the player a wheel that silently never spins.
// Mirrors the orientation check in /obj/structure/waterwheel/reevaluate_rotation().
/obj/item/rotation_contraption/waterwheel/can_place(turf/T, mob/living/user, wanted_dir)
	var/turf/open/water/river/water = T
	if(!istype(water) || !(water.dir & ALL_CARDINALS))
		return TRUE // not on a flowing river — nothing to align against
	if(wanted_dir != water.dir && wanted_dir != REVERSE_DIR(water.dir))
		return TRUE
	to_chat(user, span_warning("The current here flows [dir2text(water.dir)] — the wheel must stand across it to catch the flow. I should place it facing [dir2text(turn(water.dir, 90))] or [dir2text(turn(water.dir, -90))]."))
	return FALSE

/obj/item/rotation_contraption/minecart_rail
	placed_type = /obj/structure/minecart_rail

	grid_height = 64
	grid_width = 32

/obj/item/rotation_contraption/minecart_rail/railbreak
	placed_type = /obj/structure/minecart_rail/railbreak

	grid_height = 64
	grid_width = 32

/obj/item/rotation_contraption/roller
	placed_type = /obj/structure/roller

	grid_height = 32
	grid_width = 32

/* commenting out water pipes for now 
/obj/item/rotation_contraption/water_pipe
	placed_type = /obj/structure/water_pipe
/obj/item/rotation_contraption/pump
	placed_type = /obj/structure/water_pump
	can_stack = FALSE
	grid_height = 96
	grid_width = 96
	place_behavior = PLACE_TOWARDS_USER
/obj/item/rotation_contraption/boiler
	placed_type = /obj/structure/boiler
	can_stack = FALSE
	grid_height = 96
	grid_width = 96
	place_behavior = PLACE_TOWARDS_USER
/obj/item/rotation_contraption/steam_recharger
	placed_type = /obj/structure/steam_recharger
	can_stack = FALSE
	grid_height = 96
	grid_width = 96
	place_behavior = PLACE_TOWARDS_USER
/obj/item/rotation_contraption/water_vent
	placed_type = /obj/structure/water_vent
	grid_height = 64
	grid_width = 64
	place_behavior = PLACE_TOWARDS_USER
*/
