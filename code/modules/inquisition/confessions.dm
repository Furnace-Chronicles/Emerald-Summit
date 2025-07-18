/obj/item/paper/confession
	name = "confession"
	icon_state = "confession"
	var/base_icon_state = "confession"
	var/target = null //The guilty person's name in question
	var/signed = null
	textper = 108
	maxlen = 2000
	var/confession_type = "antag" //for voluntary confessions


/obj/item/paper/confession/examine(mob/user)
	. = ..()
	. += span_info("One signature is all that bars you from Eternity's Gate")

/obj/item/paper/confession/attackby(atom/A, mob/living/user, params)
	if(signed)
		return
	if(istype(A, /obj/item/natural/feather))
		attempt_confession(user)
		return TRUE
	return ..()

/obj/item/paper/confession/update_icon_state()
	. = ..()
	if(mailer)
		icon_state = "paper_prep"
		throw_range = 7
		return
	throw_range = initial(throw_range)
	icon_state = "[base_icon_state][signed ? "signed" : ""]"
	return

/obj/item/paper/confession/proc/attempt_confession(mob/living/carbon/human/M, mob/user)
	if(!ishuman(M))
		return
	if(M.real_name != target)
		to_chat(M, span_notice("This confession is not for me to make!"))
		return
	var/input = alert(M, "Sign the confession of guilt?", "CONFESSION OF GUILT", "Yes", "No")
	if(M.stat >= UNCONSCIOUS)
		return
	if(!M.CanReach(src))
		return
	if(signed)
		return
	if(input == "Yes")
		playsound(src, 'sound/items/write.ogg', 50, FALSE, ignore_walls = FALSE)
		M.visible_message(span_info("[M] signs the confession."), span_info("I seal my fate."), vision_distance = COMBAT_MESSAGE_RANGE)
		signed = TRUE
		update_icon_state()
	else
		M.visible_message(span_boldwarning("[M] refused to sign the confession!"), span_boldwarning("I refused to sign the confession!"), vision_distance = COMBAT_MESSAGE_RANGE)
	return

/obj/item/paper/confession/read(mob/user)
	if(!user.client || !user.hud_used)
		return
	if(!user.hud_used.reads)
		return
	if(!user.can_read(src))
		if(info)
			user.adjust_skillrank(/datum/skill/misc/reading, 2, FALSE)
		return
	/*font-size: 125%;*/
	if(in_range(user, src) || isobserver(user))
		user.hud_used.reads.icon_state = "scroll"
		user.hud_used.reads.show()
		var/dat = {"<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">
					<html><head><style type=\"text/css\">
					body { background-image:url('book.png');background-repeat: repeat; }</style>
					</head><body scroll=yes>"}
		dat += "[info]<br>"
		dat += "<a href='byond://?src=[REF(src)];close=1' style='position:absolute;right:50px'>Close</a>"
		dat += "</body></html>"
		user << browse(dat, "window=reading;size=460x300;can_close=0;can_minimize=0;can_maximize=0;can_resize=0;titlebar=0")
		onclose(user, "reading", src)
	else
		return "<span class='warning'>I'm too far away to read it.</span>"

/obj/item/paper/confession/rmb_self(mob/user)
	return TRUE

/obj/item/paper/confession/attack_right(mob/user)
	return TRUE

/obj/structure/roguemachine/nkvd_confession
	name = "JUSTICAR"
	desc = "Its proclamations will wipe the pink off your wet lips."
	icon = 'icons/roguetown/misc/machines.dmi'
	icon_state = "confession"
	max_integrity = 0
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	density = TRUE

/obj/structure/roguemachine/nkvd_confession/attack_hand(mob/user)
	var/list/sins = list("theft", "murder", "heresy", "lechery", "unsanctioned magic", "defilement of the dead",
	 "impersonation of a clergyman", "unauthorized preaching", "blahsphemy", "freekishness","conspiracy against the crown", "dishonour")
	playsound(src,'sound/misc/machinery_chirp.ogg',60, FALSE)
	var/victim_name = input("Who's the Fucker?") as text|null
	if(!victim_name)
		return

	var/crime = input("What are we charging them with?") as null | anything in sins
	if(!crime)
		return

	var/confession_info = "I, <b>[victim_name]</b> ADMIT TO <b>[crime]</b>. I WILL REPENT AND SUBMIT TO ANY PUNISHMENT THE CLERGY DEEMS APPROPRIATE FOR MY MISDEEDS AGAINST THE HOLY TEN. LET MY VOLUNTARY CONFESSION OF SIN WEIGH ON THE ANGEL GABRIEL'S JUDGEMENT AT THE MANY-SPIKED GATES OF HEAVEN."
	var/obj/item/paper/confession/confession_paper = new /obj/item/paper/confession(src.loc)
	confession_paper.info = confession_info
	confession_paper.target = victim_name
	playsound(src,'sound/misc/confession_print.ogg',60, FALSE)
	return
