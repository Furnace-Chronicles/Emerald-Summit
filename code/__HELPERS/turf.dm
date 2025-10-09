/**
 * Get ranged target turf, but with direct targets as opposed to directions
 *
 * Starts at atom starting_atom and gets the exact angle between starting_atom and target
 * Moves from starting_atom with that angle, Range amount of times, until it stops, bound to map size
 * Arguments:
 * * starting_atom - Initial Firer / Position
 * * target - Target to aim towards
 * * range - Distance of returned target turf from starting_atom
 * * offset - Angle offset, 180 input would make the returned target turf be in the opposite direction
 */
/proc/get_ranged_target_turf_direct(atom/starting_atom, atom/target, range, offset)
	var/angle = ATAN2(target.x - starting_atom.x, target.y - starting_atom.y)
	if(offset)
		angle += offset
	var/turf/starting_turf = get_turf(starting_atom)
	for(var/i in 1 to range)
		var/turf/check = locate(starting_atom.x + cos(angle) * i, starting_atom.y + sin(angle) * i, starting_atom.z)
		if(!check)
			break
		starting_turf = check

	return starting_turf



/*
	Given a starting atom, this returns a list of all turfs in the same "room" as that atom
	It does this by flood filling out from the start position, until it reaches a given range
*/
/proc/get_room_turfs(atom/starting_atom, match_area = FALSE, max_range = 10)

	var/list/turf/possible = list()
	var/list/turf/processed = list()
	var/list/turf/accepted = list()

	var/turf/origin = get_turf(starting_atom)
	var/area/origin_area = get_area(origin)

	accepted.Add(origin)
	processed.Add(origin)	//Tracks every turf we've looked at to avoid infinite loops
	possible.Add(get_adjacent_turfs(origin))

	while (possible.len)
		var/turf/T = pop(possible)	//Pop gets and removes an element from the list
		processed.Add(T)

		//If this turf isnt clear, then its a dead end
		if (!T.is_clear(TRUE))
			continue

		//Too far, we don't wanna get stuck measuring colossal cave systems and outdoor fields or forests
		if (get_dist(origin, T) > max_range)
			continue

		//Area Lock
		if (match_area && (origin_area != get_area(T)))
			continue

		//Okay this turf is good,
		accepted += T

		//now we continue the search from there
		var/list/turf/candidates = get_adjacent_turfs(T)

		//Filter out any we already looked at
		candidates -= processed

		//Check if theres still any
		if (!candidates.len)
			continue

		//Things to look at next loop
		possible += candidates

	return accepted

/*
	A "clear" turf is one that is probably walkable to most mobs most of the time. this is generally false for walls and true for floors that don't contain blocking objects

	the always flag additionally checks for objects that are designed to switch density, generally this means doors and gates. If it is set, turfs with such density switching objects will be treated as not clear, regardless of whether the door is open
*/
/turf/proc/is_clear(var/always = FALSE)
	if (density)
		return FALSE

	for (var/obj/A in src.contents)
		var/density_flag
		if (always)
			density_flag = A.get_possible_density()
		else
			density_flag = A.density

		if (density_flag)
			return FALSE

	return TRUE

/turf/wall/is_clear()
	return FALSE


//This should be overridden to always return true, for any object that can become dense even if it is not always in that state
/obj/proc/get_possible_density()
	return density

/obj/structure/mineral_door/get_possible_density()
	return TRUE

