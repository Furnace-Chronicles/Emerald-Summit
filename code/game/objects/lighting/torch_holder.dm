/obj/machinery/light/rogue/torchholder
	name = "sconce"
	desc = "A wall-mounted fixture that allows a torch to illuminate the area while freeing the hands for other tasks."
	icon_state = "torchwall1"
	var/torch_off_state = "torchwall0"
	base_state = "torchwall"
	density = FALSE
	brightness = 0
	light_outer_range = 0 //THIS REALLY SHOULDN'T BE A CHILD OF LIGHT.
	light_color = ""
	light_power = 0
	light_on = 0
	var/obj/item/flashlight/flare/torch/torchy
	fueluse = FALSE //we use the torch's fuel
	no_refuel = TRUE
	soundloop = null
	crossfire = FALSE
	plane = GAME_PLANE_UPPER
	cookonme = FALSE
	never_on = TRUE //neVER EVER EVER WORK ON PAPRIKA CODE
	var/can_remove = TRUE //anti copy-paste, holy fuck.

/obj/machinery/light/rogue/torchholder/c
	pixel_y = 32

/obj/machinery/light/rogue/torchholder/r
	dir = WEST

/obj/machinery/light/rogue/torchholder/l
	dir = EAST

/obj/machinery/light/rogue/torchholder/fire_act(added, maxstacks)
	if(torchy)
		if(!on)
			if(torchy.fuel > 0)
				torchy.spark_act()
				playsound(src.loc, 'sound/items/firelight.ogg', 100)
				on = TRUE
				update()
				update_icon()
				if(soundloop)
					soundloop.start()
				addtimer(CALLBACK(src, PROC_REF(trigger_weather)), rand(5,20))
				return TRUE

/obj/machinery/light/rogue/torchholder/Initialize()
	torchy = new /obj/item/flashlight/flare/torch(src)
	torchy.spark_act()
	torchy.weather_resistant = TRUE
	copytorchy()
	. = ..()

/obj/machinery/light/rogue/torchholder/OnCrafted(dirin, user)
	dirin = turn(dirin, 180)
	QDEL_NULL(torchy)
	on = FALSE
	copytorchy()
	update_icon()

	..(dirin, user)

/obj/machinery/light/rogue/torchholder/process()
	if(on)
		if(torchy)
			if(torchy.fuel <= 0)
				extinguish()
			if(!torchy.on)
				extinguish()
		else
			return PROCESS_KILL

/obj/machinery/light/rogue/torchholder/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(torchy && can_remove)
		if(!istype(user) || !Adjacent(user) || !user.put_in_active_hand(torchy))
			torchy.weather_resistant = FALSE
			torchy.forceMove(loc)
		torchy.set_light(l_on=torchy.on)
		torchy = null
		on = FALSE
		extinguish(TRUE)
		copytorchy()
		update_icon()
		playsound(src.loc, 'sound/foley/torchfixturetake.ogg', 70)

/obj/machinery/light/rogue/torchholder/update_icon()
	if(torchy)
		if(on)
			icon_state = "[base_state]1"
		else
			icon_state = "[torch_off_state]"
	else
		icon_state = "[base_state]"
	copytorchy()

/obj/machinery/light/rogue/torchholder/burn_out()
	if(torchy && torchy.on)
		torchy.turn_off()
	update_icon()
	..()

/obj/machinery/light/rogue/torchholder/attackby(obj/item/W, mob/living/user, params)
	if(istype(W, /obj/item/flashlight/flare/torch))
		var/obj/item/flashlight/flare/torch/LR = W
		if(torchy)
			if(LR.on && !on)
				if(torchy.fuel <= 0)
					to_chat(user, "<span class='warning'>The mounted torch is burned out.</span>")
					return
				else
					torchy.spark_act()
					user.visible_message("<span class='info'>[user] lights [src].</span>")
					playsound(src.loc, 'sound/items/firelight.ogg', 100)
					on = TRUE
					update()
					update_icon()
					addtimer(CALLBACK(src, PROC_REF(trigger_weather)), rand(5,20))
					copytorchy()
					return
			if(!LR.on && on)
				if(LR.fuel > 0)
					LR.spark_act()
					user.visible_message("<span class='info'>[user] lights [LR] in [src].</span>")
					user.update_inv_hands()
		else
			if(LR.on)
				if(!user.transferItemToLoc(LR, src))
					return
				torchy = LR
				torchy.weather_resistant = TRUE
				on = TRUE
				update()
				update_icon()
				addtimer(CALLBACK(src, PROC_REF(trigger_weather)), rand(5,20))
			else
				if(!user.transferItemToLoc(LR, src))
					return
				torchy = LR
				torchy.weather_resistant = TRUE
				update_icon()
				copytorchy()
			playsound(src.loc, 'sound/foley/torchfixtureput.ogg', 70)
		return
	. = ..()

//Call this whenever a torch is added.
/obj/machinery/light/rogue/torchholder/proc/copytorchy()
	if(!torchy)
		set_light(l_on = FALSE)
	else 
		set_light(l_outer_range = torchy.light_outer_range, l_color= torchy.light_color, l_power = torchy.light_power, l_on = torchy.on)
		torchy.set_light(l_on = FALSE)


/obj/machinery/light/rogue/torchholder/lanternpost
	name = "lantern post"
	desc = "A small lamptern dangles from a wooden post. The metal frame around the inner flame casts shadows on its surroundings."
	icon = 'icons/roguetown/misc/tallstructure.dmi'
	icon_state = "streetlantern1"
	base_state = "streetlantern"
	brightness = 5
	density = FALSE
	fueluse = 0 //we use the torch's fuel
	no_refuel = TRUE
	soundloop = null
	crossfire = FALSE
	plane = GAME_PLANE_UPPER
	cookonme = FALSE
	can_remove = FALSE
