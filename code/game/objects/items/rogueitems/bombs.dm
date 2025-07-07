
/obj/item/bomb
	name = "bottle bomb"
	desc = "A fiery explosion waiting to be coaxed from its glass prison."
	icon_state = "bbomb"
	icon = 'icons/roguetown/items/misc.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	//dropshrink = 0
	throwforce = 0
	slot_flags = ITEM_SLOT_HIP
	throw_speed = 0.5
	var/fuze = 50
	var/lit = FALSE
	var/prob2fail = 23
	var/blewup = FALSE
	grid_width = 32
	grid_height = 64


/obj/item/bomb/spark_act()
	light()

/obj/item/bomb/fire_act()
	light()

/obj/item/bomb/ex_act()
	if(!QDELETED(src))
		lit = TRUE
		explode(TRUE)

/obj/item/bomb/proc/light()
	if(!lit)
		START_PROCESSING(SSfastprocess, src)
		icon_state = "bbomb-lit"
		lit = TRUE
		playsound(src.loc, 'sound/items/firelight.ogg', 100)
		if(ismob(loc))
			var/mob/M = loc
			M.update_inv_hands()

/obj/item/bomb/extinguish()
	snuff()

/obj/item/bomb/proc/snuff()
	if(lit)
		lit = FALSE
		STOP_PROCESSING(SSfastprocess, src)
		playsound(src.loc, 'sound/items/firesnuff.ogg', 100)
		icon_state = "bbomb"
		if(ismob(loc))
			var/mob/M = loc
			M.update_inv_hands()

/obj/item/bomb/proc/explode(skipprob)
	STOP_PROCESSING(SSfastprocess, src)
	var/turf/T = get_turf(src)
	if(T)
		if(lit)
			if(!skipprob && prob(prob2fail))
				snuff()
				new /obj/item/natural/glass/shard (T)
			else
				explosion(T, light_impact_range = 2, flame_range = 2, smoke = TRUE, soundin = pick('sound/misc/explode/bottlebomb (1).ogg','sound/misc/explode/bottlebomb (2).ogg'))
				blewup = TRUE
		else
			if(prob(prob2fail))
				snuff()
				new /obj/item/natural/glass/shard (T)
			else
				playsound(T, 'sound/items/firesnuff.ogg', 100)
				new /obj/item/natural/glass/shard (T)
	qdel(src)

/obj/item/bomb/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	..()
	var/mob/living/L = hit_atom
	if(isliving(hit_atom))
		L.adjust_fire_stacks(12.5) //6 pats when standing or rolling on the floor 3 times, in case the bomb doesn't explode, you are still covered in accelerant...
	explode()
	if(blewup == TRUE) //in case the bomb DOES explode
		L.IgniteMob()

/obj/item/bomb/process()
	fuze--
	if(fuze <= 0)
		explode(TRUE)

/obj/item/smokebomb
	name = "smoke bomb"
	desc = "A soft sphere with an alchemical mixture and a dispersion mechanism hidden inside. Any pressure will detonate it."
	icon_state = "smokebomb"
	icon = 'icons/roguetown/items/misc.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	//dropshrink = 0
	throwforce = 0
	slot_flags = ITEM_SLOT_HIP
	throw_speed = 0.5
	grid_width = 32
	grid_height = 64

/obj/item/smokebomb/attack_self(mob/user)
    ..()
    explode()

/obj/item/smokebomb/ex_act()
	if(!QDELETED(src))
		..()
	explode()

/obj/item/smokebomb/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	..()
	explode()

/obj/item/smokebomb/proc/explode()
    STOP_PROCESSING(SSfastprocess, src)
    var/turf/T = get_turf(src)
    if (!T) return
    playsound(src.loc, 'sound/items/smokebomb.ogg', 50)
    var/radius = 3
    var/datum/effect_system/smoke_spread/S = new /datum/effect_system/smoke_spread
    S.set_up(radius, T)
    S.start()
    new /obj/item/ash(T)
    qdel(src)
