SUBSYSTEM_DEF(lobbymenu)
	name = "Lobbyrefresh"
	// 5s cadence (was 2s). Each fire calls browse() to replace the HTML of
	// every classic-UI player's lobby_window, and BYOND drops the custom
	// cursor for a frame during that replacement — visible as a 2s-cadence
	// cursor flicker. Slowing it 2.5× trades countdown smoothness for far
	// less flicker; the ready-roster doesn't usually change that fast anyway.
	// TGUI users no longer trigger any browse work here at all (see
	// /mob/dead/new_player/proc/lobby_refresh's winexists() guard).
	wait = 50
	priority = 100
	flags = SS_NO_INIT
//	runlevels = RUNLEVEL_SETUP | RUNLEVEL_LOBBY | RUNLEVEL_GAME
	runlevels = RUNLEVEL_SETUP | RUNLEVEL_LOBBY
	var/list/currentrun = list()

/datum/controller/subsystem/lobbymenu/fire(resumed = 0)
	if(!resumed)
		currentrun = GLOB.new_player_list.Copy()

	while(currentrun.len)
		var/mob/dead/new_player/player = currentrun[currentrun.len]
		currentrun.len--
		if(player.client)
			player.lobby_refresh()
		if (MC_TICK_CHECK)
			return