/*
Firstly, the coordinates device. Eventually, I'll add free aim. But for now...
*/
/obj/item/rogueweapon/palantir
	name = "\improper palantir"
	desc = "An arcyne compass, runed and imbued with energy. \
	That is, of course, to say that this is able to detect leyline intersection points. Or LIPs, for short. \
	An incredibly expensive device, likely pried from one of the Queen's own magicians."
	icon = 'icons/roguetown/weapons/stationary/bombard.dmi'
	icon_state = "compass"
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	force = 5
	possible_item_intents = list(INTENT_GENERIC)
	var/last_x = "UNKNOWN"
	var/last_y = "UNKNOWN"
	var/last_z = "UNKNOWN"

/obj/item/rogueweapon/palantir/examine(mob/user)
	. = ..()
	if(HAS_TRAIT(user, TRAIT_FUSILIER))
		. += "<small>Last 'X-LIP' recorded: <span class='warning'>[last_x]</span> <br>\
			Last 'Y-LIP' recorded: <span class='warning'>[last_y]</span> <br>\
			Last 'Z-LIP' recorded: <span class='warning'>[last_z]</span></small>"
	else
		. += "<small>As expected, you've no understanding of the smaller details. Someone trained with smokepowder might know...</small>"

/obj/item/rogueweapon/palantir/afterattack(atom/A, mob/living/user, adjacent, params) //handles coord obtaining
	if(!HAS_TRAIT(user, TRAIT_FUSILIER))
		to_chat(user, "<span class='warning'>This device is beyond your understanding...</span>")
		return
	to_chat(user, "Calculating leyline intersection point. Stand still.")
	loud_message("A palantir's loud whine can be heard", hearing_distance = 24)//"ZEZUZ PYST FROM WHERE?!!"
	if(do_after(user, 12 SECONDS, src))
		A = get_turf(A)
		last_x = obfuscate_x(A.x)
		last_y = obfuscate_y(A.y)
		last_z = A.z
		to_chat(user, "INTERSECTION POINT OF TARGET <br>\
		<small>X-LIP: <span class='warning'>[last_x]</span> <br>\
		Y-LIP: <span class='warning'>[last_y]</span> <br>\
		Z-LIP: <span class='warning'>[last_z]</span></small>")
	else
		to_chat(user, "<span class='warning'>You must remain still!</span>")

//Right-click a bombard while holding the palantir to feed it the coordinates we last recorded -
//the proper way to aim, instead of reading the LIPs off the device and typing them in by hand.
/obj/item/rogueweapon/palantir/proc/load_bombard(obj/structure/bombard/B, mob/living/user)
	if(!HAS_TRAIT(user, TRAIT_FUSILIER))
		to_chat(user, "<span class='warning'>This device is beyond your understanding...</span>")
		return
	if(B.busy)
		to_chat(user, "<span class='warning'>Someone else is currently using [B].</span>")
		return
	if(B.firing)
		to_chat(user, "<span class='warning'>[B]'s barrel is still too hot to handle.</span>")
		return
	if(last_x == "UNKNOWN" || last_y == "UNKNOWN" || last_z == "UNKNOWN")
		to_chat(user, "<span class='warning'>[src] hasn't recorded a leyline intersection point yet.</span>")
		return
	var/area/AR = get_area(B)
	if(!AR.outdoors)
		to_chat(user, "<span class='warning'>You refrain from aiming [B] while indoors.</span>")
		return
	//Deobfuscate our stored LIPs back into the real coordinates the bombard fires by.
	var/targ_x = deobfuscate_x(last_x)
	var/targ_y = deobfuscate_y(last_y)
	var/targ_z = last_z
	if(targ_z > 5 || targ_z < 2)
		to_chat(user, "<span class='warning'>That intersection point sits at an elevation [B] cannot fire at.</span>")
		return
	if(targ_x > world.maxx || targ_x < 1 || targ_y > world.maxy || targ_y < 1)
		to_chat(user, "<span class='warning'>That intersection point is outside [B]'s reach.</span>")
		return
	var/turf/T = locate(targ_x, targ_y, targ_z)
	if(!T)
		to_chat(user, "<span class='warning'>That intersection point cannot be targeted.</span>")
		return
	if(get_dist(B.loc, T) < 10)
		to_chat(user, "<span class='warning'>That target is too close to [B].</span>")
		return
	if(get_dist(B.loc, T) > 124 && !B.heavy)
		to_chat(user, "<span class='warning'>That target is too far away for a light bombard!</span>")
		return
	if(!T.can_see_sky())
		to_chat(user, "<span class='warning'>That location has a ceiling - you cannot aim directly at it!</span>")
		return
	//All clear - run the loading action, same timing/feel as filling or ramming.
	user.visible_message("<span class='notice'>[user] begins feeding [B] the coordinates stored in [src].</span>",
	"<span class='notice'>You begin loading [B] with the coordinates stored in [src].</span>")
	B.busy = 1
	if(!do_after(user, 30, B))
		B.busy = 0
		return
	B.busy = 0
	B.xinput = targ_x
	B.yinput = targ_y
	B.zdial = targ_z
	var/offset_x_max = round(abs((B.xinput + B.xdial) - B.x) / B.offset_per_turfs)
	var/offset_y_max = round(abs((B.yinput + B.ydial) - B.y) / B.offset_per_turfs)
	B.xoffset = rand(-offset_x_max, offset_x_max)
	B.yoffset = rand(-offset_y_max, offset_y_max)
	B.update_facing()//Turn the barrel to face the coordinates we just fed in.
	playsound(B.loc, 'sound/combat/shieldraise.ogg', 25, TRUE)
	user.visible_message("<span class='notice'>[user] locks in [B]'s firing solution.</span>",
	"<span class='notice'>You lock in [B]'s firing solution from [src].</span>")

//This is a weapon because it makes me chuckle. Sorry.
/obj/item/rogueweapon/woodstaff/quarterstaff/bombard_sponge
	name = "powder ram"
	desc = "A bulky, heavy rod with a sponge at one end, and a fool at the other. Wholly unsuited for combat."
	icon = 'icons/roguetown/weapons/stationary/bombard64.dmi'
	icon_state = "ramrod"
	item_state = "ramrod"
	w_class = WEIGHT_CLASS_BULKY
	force = 5
	force_wielded = 10
	max_integrity = 25
	wdefense = 2
	wdefense_wbonus = 2
	possible_item_intents = list(INTENT_GENERIC)

//The portable bombard's frame, lacking a barrel.
/obj/item/bombard_frame
	name = "\improper light bombard frame"
	desc = "A light bombard's frame. If you'd the barrel, you could set up a light bombard... <br>\
	<small>To do so, you must have both pieces and 'craft' it.</small>"
	icon = 'icons/roguetown/weapons/stationary/bombard.dmi'
	icon_state = "kit_frame"
	w_class = WEIGHT_CLASS_BULKY
	force = 5
	possible_item_intents = list(INTENT_GENERIC)

//And the barrel it lacks.
/obj/item/bombard_barrel
	name = "\improper light bombard barrel"
	desc = "A light bombard's barrel. If you'd the frame, you could set up a light bombard... <br>\
	<small>To do so, you must have both pieces and 'craft' it.</small>"
	icon = 'icons/roguetown/weapons/stationary/bombard.dmi'
	icon_state = "kit_barrel"
	w_class = WEIGHT_CLASS_BULKY
	force = 5
	possible_item_intents = list(INTENT_GENERIC)

//And the recipe in which we hold it hostage. It shouldn't be survival, but, whatever.
/datum/crafting_recipe/roguetown/survival/bombard
	name = "Portable Bombard (Barrel and Frame)"
	result = /obj/structure/bombard
	category = "Ranged"
	reqs = list(
		/obj/item/bombard_frame = 1,
		/obj/item/bombard_barrel = 1
		)
	skillcraft = /datum/skill/combat/firearms
	craftdiff = 1
	time = 60
