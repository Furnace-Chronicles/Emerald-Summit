#define ALLOW_TRENCH_ON(T) ( \
	istype(T, /turf/open/floor/rogue/grass)     || \
	istype(T, /turf/open/floor/rogue/dirt/road) || \
	istype(T, /turf/open/floor/rogue/cobblerock) )

#define TRENCH_ICON 'icons/roguetown/items/siege.dmi'
#define DIRMASK_NORTH 1
#define DIRMASK_EAST  2
#define DIRMASK_SOUTH 4
#define DIRMASK_WEST  8

proc/_trench_states_all()
	return list(
		"lefttoptrench","topmiddletrench","toprighttrench",
		"leftmiddletrench","middlemiddletrench","rightmiddletrench",
		"leftbottomtrench","bottommiddletrench","rightbottomtrench"
	)

proc/_trench_state_display_names()
	return list(
		"lefttoptrench"      = "Left Top Corner",
		"toprighttrench"     = "Right Top Corner",
		"leftbottomtrench"   = "Left Bottom Corner",
		"rightbottomtrench"  = "Right Bottom Corner",
		"topmiddletrench"    = "Top Edge",
		"bottommiddletrench" = "Bottom Edge",
		"leftmiddletrench"   = "Left Edge",
		"rightmiddletrench"  = "Right Edge",
		"middlemiddletrench" = "Center Trench"
	)

proc/_icon_state_exists(iconfile, state)
	if (!state || !length(state)) return FALSE
	var/list/st = icon_states(iconfile)
	return (state in st)

proc/_first_available_trench_state(iconfile)
	for (var/s in _trench_states_all())
		if (_icon_state_exists(iconfile, s))
			return s
	return null

proc/_choose_trench_state_any_menu(mob/user)
	var/iconfile = TRENCH_ICON
	var/list/all_states = _trench_states_all()
	var/list/names = _trench_state_display_names()
	var/list/choices = list()
	for (var/s in all_states)
		if (_icon_state_exists(iconfile, s))
			choices[names[s]] = s
	var/choice = input(user, "Choose trench shape", "Trench") as null|anything in choices
	if (!choice) return null
	return choices[choice]

/turf/open/floor/rogue/trench
	name = "trench"
	icon = TRENCH_ICON
	icon_state = "middlemiddletrench"
	var/original_floor_type

/turf/open/floor/rogue/trench/turf_destruction()
	ChangeTurf(/turf/open/floor/rogue/dirt/road)
	return

/turf/open/floor/rogue/trench/proc/_wood_block_mask()
	switch(icon_state)
		if("middlemiddletrench") return 0
		if("topmiddletrench") return DIRMASK_NORTH
		if("bottommiddletrench") return DIRMASK_SOUTH
		if("leftmiddletrench") return DIRMASK_WEST
		if("rightmiddletrench") return DIRMASK_EAST
		if("lefttoptrench") return (DIRMASK_NORTH | DIRMASK_WEST)
		if("toprighttrench") return (DIRMASK_NORTH | DIRMASK_EAST)
		if("leftbottomtrench") return (DIRMASK_SOUTH | DIRMASK_WEST)
		if("rightbottomtrench") return (DIRMASK_SOUTH | DIRMASK_EAST)
		else return 0

/turf/open/floor/rogue/trench/proc/_blocks_dir(d)
	var/m = _wood_block_mask()
	if (!m) return FALSE
	switch(d)
		if(NORTH) return !!(m & DIRMASK_NORTH)
		if(EAST)  return !!(m & DIRMASK_EAST)
		if(SOUTH) return !!(m & DIRMASK_SOUTH)
		if(WEST)  return !!(m & DIRMASK_WEST)
	return FALSE

/turf/open/floor/rogue/trench/CanPass(atom/movable/m, turf/target)
	if(istype(m, /obj/projectile)) return 1
	if (target != src) return ..()
	if (icon_state == "middlemiddletrench") return ..()
	if (isturf(m.loc))
		var/d = get_dir(m.loc, src)
		var/opp
		switch(d)
			if(NORTH) opp = SOUTH
			if(EAST)  opp = WEST
			if(SOUTH) opp = NORTH
			if(WEST)  opp = EAST
		if (_blocks_dir(opp)) return 0
	return ..()

/turf/open/floor/rogue/trench/CheckExit(atom/movable/O, turf/target)
	if(istype(O, /obj/projectile)) return 1
	if (O.loc != src) return ..()
	if (icon_state == "middlemiddletrench") return ..()
	var/d = get_dir(src, target)
	if (_blocks_dir(d)) return 0
	return ..()

/obj/item/rogueweapon/shovel/attackby(obj/item/W, mob/user, params)
	if (!istype(W, /obj/item/rogueweapon/pick)) return ..()
	var/turf/U = get_turf(user)
	if (!U) return TRUE

	if (istype(U, /turf/open/floor/rogue/trench))
		var/turf/open/floor/rogue/trench/T = U
		var/s = _choose_trench_state_any_menu(user)
		if (!s) return TRUE
		if (_icon_state_exists(T.icon, s)) T.icon_state = s
		return TRUE

	if (ALLOW_TRENCH_ON(U))
		var/old = U.type
		U.ChangeTurf(/turf/open/floor/rogue/trench)
		var/turf/open/floor/rogue/trench/NT = U
		NT.original_floor_type = old
		if (_icon_state_exists(NT.icon, "middlemiddletrench"))
			NT.icon_state = "middlemiddletrench"
		else
			var/f = _first_available_trench_state(NT.icon)
			if (f) NT.icon_state = f
		return TRUE

	return TRUE
