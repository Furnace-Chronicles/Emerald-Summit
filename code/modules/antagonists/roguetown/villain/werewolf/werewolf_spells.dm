/obj/effect/proc_holder/spell/self/howl
	name = "Howl"
	desc = "Howl to the moon to communicate with my fellow wolves. Do beware, those versed in beasttongue may be listening.	"
	overlay_state = "howl"
	antimagic_allowed = TRUE
	recharge_time = 600 //1 minute
	ignore_cockblock = TRUE
	var/use_language = FALSE
	var/list/howl_sounds = list('sound/vo/mobs/wwolf/howl (1).ogg','sound/vo/mobs/wwolf/howl (2).ogg')
	var/list/howl_sounds_far = list('sound/vo/mobs/wwolf/howldist (1).ogg','sound/vo/mobs/wwolf/howldist (2).ogg')
	var/wolf_antag_type = /datum/antagonist/werewolf

/obj/effect/proc_holder/spell/self/howl/cast(mob/user = usr)
	..()
	var/message = input("Howl at the hidden moon...", "MOONCURSED") as text|null
	if(!message) return

	var/datum/antagonist/antag_data = user.mind.has_antag_datum(wolf_antag_type)

	// sound played for owner
	playsound(src, pick(howl_sounds), 75, TRUE)

	for(var/mob/player in GLOB.player_list)

		if(!player.mind) continue
		if(player.stat == DEAD) continue
		if(isbrain(player)) continue

		// Announcement to other werewolves (and anyone else who has beast language somehow)
		if(player.mind.has_antag_datum(wolf_antag_type) || (player.has_language(/datum/language/beast)))
			var/speaker_name = (antag_data && hasvar(antag_data, "wolfname")) ? antag_data:wolfname : user.real_name
			to_chat(player, span_boldannounce("[speaker_name] howls to the hidden moon: [message]"))

		//sound played for other players
		if(player == src) continue
		if(get_dist(player, src) > 7)
			player.playsound_local(get_turf(player), pick(howl_sounds_far), 50, FALSE, pressure_affected = FALSE)

	user.log_message("howls: [message] ([wolf_antag_type])", LOG_GAME)

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
	var/obj/item/rogueweapon/werewolf_claw/left/l
	var/obj/item/rogueweapon/werewolf_claw/right/r

	l = user.get_active_held_item()
	r = user.get_inactive_held_item()
	if(extended)
		if(istype(user.get_active_held_item(), /obj/item/rogueweapon/werewolf_claw))
			user.dropItemToGround(l, TRUE)
			user.dropItemToGround(r, TRUE)
			qdel(l)
			qdel(r)
			//user.visible_message("Your claws retract.", "You feel your claws retracting.", "You hear a sound of claws retracting.")
			extended = FALSE
	else
		l = new(user,1)
		r = new(user,2)
		user.put_in_hands(l, TRUE, FALSE, TRUE)
		user.put_in_hands(r, TRUE, FALSE, TRUE)
		//user.visible_message("Your claws extend.", "You feel your claws extending.", "You hear a sound of claws extending.")
		extended = TRUE
