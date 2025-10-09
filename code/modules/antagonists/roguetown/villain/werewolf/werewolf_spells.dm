/obj/effect/proc_holder/spell/self/howl
	name = "Howl"
	desc = "!"
	overlay_state = "howl"
	antimagic_allowed = TRUE
	recharge_time = 600 //1 minute
	ignore_cockblock = TRUE
	var/use_language = FALSE

/obj/effect/proc_holder/spell/self/howl/cast(mob/user = usr)
	..()
	var/message = input("Howl at the hidden moon...", "MOONCURSED") as text|null
	if(!message) return

	var/datum/antagonist/werewolf/werewolf_player = user.mind.has_antag_datum(/datum/antagonist/werewolf)

	// sound played for owner
	playsound(src, pick('sound/vo/mobs/wwolf/howl (1).ogg','sound/vo/mobs/wwolf/howl (2).ogg'), 75, TRUE)

	for(var/mob/player in GLOB.player_list)

		if(!player.mind) continue
		if(player.stat == DEAD) continue
		if(isbrain(player)) continue

		// Announcement to other werewolves (and anyone else who has beast language somehow)
		if(player.mind.has_antag_datum(/datum/antagonist/werewolf) || (use_language && player.has_language(/datum/language/beast)))
			to_chat(player, span_boldannounce("[werewolf_player ? werewolf_player.wolfname : user.real_name] howls to the hidden moon: [message]"))

		//sound played for other players
		if(player == src) continue
		if(get_dist(player, src) > 7)
			player.playsound_local(get_turf(player), pick('sound/vo/mobs/wwolf/howldist (1).ogg','sound/vo/mobs/wwolf/howldist (2).ogg'), 50, FALSE, pressure_affected = FALSE)

	var/log_type = werewolf_player ? "(WEREWOLF))" : "(BEAST LANGUAGE)"

	user.log_message("howls: [message] ([log_type])", LOG_GAME)

/obj/effect/proc_holder/spell/self/claws
	name = "Lupine Claws"
	desc = "!"
	overlay_state = "claws"
	antimagic_allowed = TRUE
	recharge_time = 20 //2 seconds
	ignore_cockblock = TRUE
	var/extended = FALSE

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



/*
	This proc checks the local area for suitability as a wolf den, giving the user feedback
*/
/obj/effect/proc_holder/spell/self/den_sense
	name = "Den Sense"
	desc = "Evaluates the current area for suitability as a wolf den"
	overlay_state = "wolfeye"
	antimagic_allowed = TRUE
	recharge_time = 50 //2 seconds
	ignore_cockblock = TRUE

/obj/effect/proc_holder/spell/self/den_sense/cast (mob/user = usr)
	..()

	var/mob/living/carbon/human/H = usr

	var/turf/current_turf = get_turf(H)
	var/area/A = get_area(current_turf)


	var/list/actions = list("[H] sniffs the air", "[H] perks up their ears", "[H] looks around warily")

	user.visible_message(pick(actions))

	//Gotta be in an underground marked area
	if (A.underground != TRUE)
		to_chat(H, span_userdanger("This place is too exposed to protect from the sunlight, we must go underground."))
		return

	if (current_turf.can_see_sky())
		to_chat(H, span_userdanger("This place is underground, but the surface overhead provides no shelter, sunlight can penetrate here easily."))
		return

	to_chat(H, span_userdanger("This turf cannot see the sky [current_turf], [current_turf.x], [current_turf.y] "))


	var/list/turfs = get_room_turfs(usr, TRUE, 5)

	var/exposed_turfs = 0
	to_chat(H, span_userdanger("Number of turfs [turfs.len]"))
	to_chat(H, span_userdanger("Seesky flags [turfs.len]"))
	to_chat(H, span_userdanger("Yes: [SEE_SKY_YES]"))
	to_chat(H, span_userdanger("No: [SEE_SKY_NO]"))


	for (var/turf/T in turfs)
		if (T.can_see_sky())
			to_chat(H, span_userdanger("This turf can see the sky [T], [T.x], [T.y] (Sky:[T.can_see_sky])"))
			exposed_turfs++

	to_chat(H, span_userdanger("Number of exposed turfs [exposed_turfs.len]"))

	if (exposed_turfs == 0)
		to_chat(H, span_nicegreen("This place is dark and sunproof, perfect shelter for our new home!"))
		return
	else if (exposed_turfs >= turfs.len*0.25)
		to_chat(H, span_warning("The roof is full of holes, this place will provide shelter if we huddle and remain still, but it is no place to call home"))
		return
	else //A nonzero quantity of exposed turfs
		to_chat(H, span_warning("This place is adequate shelter, but it is not completely intact, we must tread carefully lest sunbeams sneak in through cracks"))
		return

