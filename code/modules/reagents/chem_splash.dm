// Replaces chemgrenade stuff, allowing reagent explosions to be called from anywhere.
// It should be called using a location, the range, and a list of reagents involved.

// Threatscale is a multiplier for the 'threat' of the grenade. If you're increasing the affected range drastically, you might want to improve this.
// Extra heat affects the temperature of the mixture, and may cause it to react in different ways.


/proc/chem_splash_can_pass(turf/from_turf, turf/to_turf)
	if(!from_turf || !to_turf)
		return FALSE
	if(from_turf.blocks_air || to_turf.blocks_air)
		return FALSE
	if(!CANATMOSPASS(from_turf, to_turf) || !CANATMOSPASS(to_turf, from_turf))
		return FALSE
	return TRUE

/proc/chem_splash_cardinal_dir(dir)
	if(!(dir & (NORTH|SOUTH|EAST|WEST)))
		return 0
	var/cardinal = dir & (NORTH|SOUTH|EAST|WEST)
	if(cardinal == (NORTH|EAST))
		return prob(50) ? NORTH : EAST
	if(cardinal == (NORTH|WEST))
		return prob(50) ? NORTH : WEST
	if(cardinal == (SOUTH|EAST))
		return prob(50) ? SOUTH : EAST
	if(cardinal == (SOUTH|WEST))
		return prob(50) ? SOUTH : WEST
	return cardinal

/proc/chem_splash(turf/epicenter, affected_range = 3, list/datum/reagents/reactants = list(), extra_heat = 0, threatscale = 1, adminlog = 1, bias_dir = 0, nondirectional_chance = 15, t_chance = 10, l_chance = 10)
	if(!isturf(epicenter) || !reactants.len || threatscale <= 0)
		return
	var/has_reagents
	var/total_reagents
	for(var/datum/reagents/R in reactants)
		if(R.total_volume)
			has_reagents = 1
			total_reagents += R.total_volume

	if(!has_reagents)
		return

	//water turf eats reagents
	if(istype(epicenter, /turf/open/water))
		for(var/datum/reagents/R in reactants)
			R.clear_reagents()
		return

	//splash down, not on open spaces.
	while(istype(epicenter, /turf/open/transparent/openspace))
		var/turf/downcheck = GET_TURF_BELOW(epicenter)
		if(downcheck)
			epicenter = downcheck
		else
			break

	var/datum/reagents/splash_holder = new/datum/reagents(total_reagents*threatscale)
	splash_holder.my_atom = epicenter // For some reason this is setting my_atom to null, and causing runtime errors.
	var/total_temp = 0

	for(var/datum/reagents/R in reactants)
		R.trans_to(splash_holder, R.total_volume, threatscale, 1, 1)
		total_temp += R.chem_temp
	splash_holder.chem_temp = (total_temp/reactants.len) + extra_heat // Average temperature of reagents + extra heat.
	splash_holder.handle_reactions() // React them now.

	var/use_directional = FALSE
	var/bias_dx = 0
	var/bias_dy = 0
	if(bias_dir)
		var/cardinal_dir = chem_splash_cardinal_dir(bias_dir)
		if(cardinal_dir && !prob(nondirectional_chance))
			use_directional = TRUE
			if(cardinal_dir & EAST)
				bias_dx = 1
			else if(cardinal_dir & WEST)
				bias_dx = -1
			if(cardinal_dir & NORTH)
				bias_dy = 1
			else if(cardinal_dir & SOUTH)
				bias_dy = -1

	var/list/liquid_targets
	var/list/allowed_sides
	if(use_directional)
		liquid_targets = list()
		liquid_targets += epicenter
		var/turf/line_turf = epicenter
		for(var/i=1; i<=affected_range; i++)
			line_turf = get_step(line_turf, bias_dir)
			if(!isturf(line_turf) || isclosedturf(line_turf))
				break
			liquid_targets += line_turf
		allowed_sides = list()
		var/roll = rand(1, 100)
		var/left_dir = turn(bias_dir, 90)
		var/right_dir = turn(bias_dir, -90)
		if(roll <= t_chance)
			allowed_sides += left_dir
			allowed_sides += right_dir
		else if(roll <= (t_chance + l_chance))
			allowed_sides += prob(50) ? left_dir : right_dir
		if(length(allowed_sides))
			for(var/side_dir in allowed_sides)
				var/turf/side_turf = get_step(epicenter, side_dir)
				if(isturf(side_turf) && !isclosedturf(side_turf))
					liquid_targets += side_turf


	if(splash_holder.total_volume && affected_range >= 0)	//The possible reactions didnt use up all reagents, so we spread it around.
		var/datum/effect_system/steam_spread/steam = new /datum/effect_system/steam_spread()
		steam.set_up(10, 0, epicenter)
		steam.attach(epicenter)
		steam.start()

		var/list/viewable = view(affected_range, epicenter)

		var/list/accessible = list(epicenter)
		for(var/i=1; i<=affected_range; i++)
			var/list/turflist = list()
			for(var/turf/T in (orange(i, epicenter) - orange(i-1, epicenter)))
				turflist |= T
			for(var/turf/T in turflist)
				if(!(get_dir(T,epicenter) in GLOB.cardinals) && (abs(T.x - epicenter.x) == abs(T.y - epicenter.y) ))
					turflist.Remove(T)
					turflist.Add(T) // we move the purely diagonal turfs to the end of the list.
			for(var/turf/T in turflist)
				if(accessible[T])
					continue
				for(var/dir in GLOB.cardinals)
					var/turf/NT = get_step(T, dir)
					if(!(NT in accessible))
						continue
					if(!chem_splash_can_pass(T, NT))
						continue
					accessible[T] = 1
					break
		var/list/reactable = accessible
		for(var/turf/T in accessible)
			for(var/atom/A in T.GetAllContents())
				if(!(A in viewable))
					continue
				reactable |= A
			if(extra_heat >= 300)
				T.hotspot_expose(extra_heat*2, 5)
		if(!reactable.len) //Nothing to react with. Probably means we're in nullspace.
			return
		for(var/thing in reactable)
			var/atom/A = thing
			var/distance = max(1,get_dist(A, epicenter))
			var/fraction = 0.5/(2 ** distance) //50/25/12/6... for a 200u splash, 25/12/6/3... for a 100u, 12/6/3/1 for a 50u
			if(use_directional)
				var/turf/T = isturf(A) ? A : get_turf(A)
				if(T)
					var/dx = T.x - epicenter.x
					var/dy = T.y - epicenter.y
					if(dx && dy)
						continue // no diagonals when directional
					if(!dx && !dy)
						fraction *= 1.0
					else
						var/dot = (dx * bias_dx) + (dy * bias_dy)
						if(dot > 0)
							fraction *= 2.25
						else if(dot == 0)
							var/side_dir
							if(dx > 0)
								side_dir = EAST
							else if(dx < 0)
								side_dir = WEST
							else if(dy > 0)
								side_dir = NORTH
							else if(dy < 0)
								side_dir = SOUTH
							if(!allowed_sides || !(side_dir in allowed_sides))
								continue
							fraction *= 0.3
						else
							fraction *= 0.05
			if(fraction <= 0)
				continue
			splash_holder.reaction(A, TOUCH, fraction)

	if(liquid_targets && length(liquid_targets))
		var/total_targets = length(liquid_targets)
		var/total_weight = total_targets + 1 // bias toward epicenter
		for(var/turf/T in liquid_targets)
			var/weight = (T == epicenter) ? 2 : 1
			var/amount = (splash_holder.total_volume * (weight / total_weight))
			T.add_liquid_from_reagents(splash_holder, amount = amount)
	else
		epicenter.add_liquid_from_reagents(splash_holder)
	qdel(splash_holder)
	return 1


