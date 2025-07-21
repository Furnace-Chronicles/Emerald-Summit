//Returns MINDS of the assigned antags of given type/subtypes
/proc/get_antag_minds(antag_type,specific = FALSE)
	. = list()
	for(var/datum/antagonist/A in GLOB.antagonists)
		if(!A.owner)
			continue
		if(!antag_type || !specific && istype(A,antag_type) || specific && A.type == antag_type)
			. += A.owner

//Get all teams [of type team_type]
/proc/get_all_teams(team_type)
	. = list()
	for(var/V in GLOB.antagonists)
		var/datum/antagonist/A = V
		if(!A.owner)
			continue
		var/datum/team/T = A.get_team()
		if(!team_type || istype(T,team_type))
			. |= T

// Helper to select and assign Thieves' Guild antagonists at roundstart
/proc/assign_thieves_guild_antags(list/possible_minds, num=1)
	if(!possible_minds || !possible_minds.len)
		return
	// Only include players who have the role enabled in their preferences
	var/list/eligible = list()
	for(var/datum/mind/M in possible_minds)
		if(M.current && M.current.client && (ROLE_THIEVESGUILD in M.current.client.prefs.be_special))
			eligible += M
	if(!eligible.len)
		return
	// Limit to a maximum of 5
	num = min(num, 5, eligible.len)
	var/list/chosen = pick_n_shuffle(eligible, num)
	for(var/datum/mind/M in chosen)
		M.add_antag_datum(/datum/antagonist/thievesguild)

// Utility: pick n random elements from a list
/proc/pick_n_shuffle(list/L, n)
	if(!islist(L) || !L.len || n <= 0)
		return list()
	var/list/copy = L.Copy()
	copy = ::shuffle(copy) // explicitly call global proc
	return copy.Copy(1, min(n, copy.len) + 1)
