/obj/effect/proc_holder/spell/self/howl
	name = "Howl"
	desc = "Howl to the moon to communicate with my fellow wolves. Do beware, those versed in beasttongue may be listening."
	overlay_state = "howl"
	antimagic_allowed = TRUE
	recharge_time = 600 //1 minute
	ignore_cockblock = TRUE
	var/use_language = FALSE
	var/list/howl_sounds = list('sound/vo/mobs/wwolf/howl (1).ogg','sound/vo/mobs/wwolf/howl (2).ogg')
	var/list/howl_sounds_far = list('sound/vo/mobs/wwolf/howldist (1).ogg','sound/vo/mobs/wwolf/howldist (2).ogg')
	var/howl_antag_type = /datum/antagonist/werewolf
	// Who can hear this howl. Use HOWL_CHANNEL_* constants. Default: werewolves and druids.
	var/list/howl_channels = list(HOWL_CHANNEL_WEREWOLF, HOWL_CHANNEL_DRUID)
	var/howl_distance_limit = 50
	var/howl_distance_volume = 50
	var/howl_prompt_text = "Howl at the hidden moon..."
	var/howl_prompt_title = "MOONCURSED"
	var/howl_announcement_target = "hidden moon"

/obj/effect/proc_holder/spell/self/howl/proc/is_druid_howl_listener(mob/player)
	if(!player?.mind)
		return FALSE

	if(player.mind.assigned_role == "Druid" || player.mind.assigned_role == "Druidess")
		return TRUE

	var/mob/living/carbon/human/human_player = player
	if(istype(human_player) && human_player.patron?.type == /datum/patron/divine/dendor && player.mind.assigned_role == "Acolyte")
		return TRUE

	return FALSE

/obj/effect/proc_holder/spell/self/howl/cast(mob/user = usr)
	..()
	var/message = input(howl_prompt_text, howl_prompt_title) as text|null
	if(!message) return

	var/datum/antagonist/antag_data = user.mind.has_antag_datum(howl_antag_type)

	// sound played for owner
	playsound(user, pick(howl_sounds), 75, TRUE)

	for(var/mob/player in GLOB.player_list)

		if(!player.mind) continue
		if(isbrain(player)) continue
		var/speaker_name = (antag_data && hasvar(antag_data, "wolfname")) ? antag_data:wolfname : user.real_name

		// Admin ghost visibility
		if(IsAdminGhost(player))
			to_chat(player, span_notice("[speaker_name] howls to the [howl_announcement_target]: [message]"))
			continue

		// Check each named channel to see if this player qualifies to hear the howl
		var/can_hear = FALSE
		if(HOWL_CHANNEL_WEREWOLF in howl_channels)
			can_hear = can_hear || player.mind.has_antag_datum(/datum/antagonist/werewolf)
		if(HOWL_CHANNEL_DRUID in howl_channels)
			can_hear = can_hear || is_druid_howl_listener(player)
		if(HOWL_CHANNEL_GNOLL in howl_channels)
			can_hear = can_hear || player.mind.has_antag_datum(/datum/antagonist/gnoll)
		if(can_hear)
			to_chat(player, span_boldannounce("[speaker_name] howls to the [howl_announcement_target]: [message]"))

		//sound played for other players
		if(player == user) continue
		var/player_distance = get_dist(player, user)
		if(player_distance > 7 && player_distance <= howl_distance_limit)
			player.playsound_local(get_turf(player), pick(howl_sounds_far), howl_distance_volume, FALSE, pressure_affected = FALSE)

	user.log_message("howls: [message] ([howl_antag_type])", LOG_GAME)

/obj/effect/proc_holder/spell/self/claws
	name = "Lupine Claws"
	desc = "Unsheathe your claws"
	overlay_state = "claws"
	antimagic_allowed = TRUE
	recharge_time = 20 //2 seconds
	ignore_cockblock = TRUE
	var/extended = FALSE
	var/claw_type = /obj/item/rogueweapon/werewolf_claw

/obj/effect/proc_holder/spell/self/claws/cast(mob/user = usr)
	..()
	var/left_claw_path = text2path("[claw_type]/left")
	var/right_claw_path = text2path("[claw_type]/right")
	var/obj/item/rogueweapon/werewolf_claw/l
	var/obj/item/rogueweapon/werewolf_claw/r

	l = user.get_active_held_item()
	r = user.get_inactive_held_item()
	if(extended)
		// Check each hand independently — without this guard, retracting claws when one
		// hand has been replaced by a weapon/item qdels the non-claw item.
		if(istype(l, claw_type))
			user.dropItemToGround(l, TRUE)
			qdel(l)
		if(istype(r, claw_type))
			user.dropItemToGround(r, TRUE)
			qdel(r)
		extended = FALSE
	else
		l = new left_claw_path(user, 1)
		r = new right_claw_path(user, 2)
		user.put_in_hands(l, TRUE, FALSE, TRUE)
		user.put_in_hands(r, TRUE, FALSE, TRUE)
		extended = TRUE
