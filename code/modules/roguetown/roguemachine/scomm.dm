#define DEFAULT_GARRISON_COLOR "#FF4242"
#define GARRISON_CROWN_COLOR "#C2A245"

#define SCOM_TARGET_COMMONS 0
#define SCOM_TARGET_GARRISON 1
#define SCOM_TARGET_MATTHIOS 2
#define SCOM_TARGET_INQUISITOR 3
#define SCOM_TARGET_LOUDMOUTH 4
#define SCOM_TARGET_JABBERLINE 5
#define SCOM_TARGET_LOUDMOUTH_STRONG 6

// Vrell - This shit needed modularized ages ago. I'm fixing that.
/datum/scommodule
	var/obj/parent_object = null
	var/listening = TRUE
	var/speaking = TRUE
	var/active_listening = TRUE
	var/active_speaking = TRUE

	var/scom_number = null
	var/scom_tag = null

	var/datum/scommodule/calling = null
	var/datum/scommodule/called_by = null
	var/is_dynamic = FALSE
	var/garrisoncolor = DEFAULT_GARRISON_COLOR // NOTE: THIS IS THE SENDER'S COLOR, NOT THE RECEIVER'S
	var/is_broken = FALSE
	var/message_received_sound = 'sound/misc/scom.ogg'
	var/message_received_volume = 50 //THIS SHIT GETS LOUD WHEN THE MAPPERS AIN'T THINKING
	var/target = SCOM_TARGET_COMMONS
	var/mute_commons = FALSE
	var/mute_garrison = FALSE
	var/mute_loudmouth = FALSE
	var/common_talk_allowed = TRUE

	var/receive_commons = TRUE

	var/is_setup = FALSE

/datum/scommodule/proc/setup(obj/set_parent_object, set_common_talk_allowed = TRUE, set_listening = TRUE, set_speaking = TRUE, set_can_call = FALSE, set_garrisoncolor = DEFAULT_GARRISON_COLOR, set_message_received_sound = 'sound/misc/scom.ogg', set_message_received_volume = 100, set_starting_target = SCOM_TARGET_COMMONS, set_receive_commons = TRUE, set_receive_garrison = FALSE, set_receive_matthios = FALSE, set_receive_inquisitor = FALSE, set_scom_tag = null)
	parent_object = set_parent_object

	listening = set_listening
	speaking = set_speaking
	garrisoncolor = set_garrisoncolor
	message_received_sound = set_message_received_sound
	target = set_starting_target
	message_received_volume = set_message_received_volume
	common_talk_allowed = set_common_talk_allowed
	receive_commons = set_receive_commons
	scom_tag = set_scom_tag

	SSroguemachine.scomm_machines += src
	if(set_receive_commons)
		SSroguemachine.scomm_commons += src
	if(set_receive_garrison)
		SSroguemachine.scomm_garrison += src
	if(set_receive_matthios)
		SSroguemachine.scomm_matthios += src
	if(set_receive_inquisitor)
		SSroguemachine.scomm_inquisitor += src
	if(set_can_call)
		SSroguemachine.scomm_jabberlines += src
		scom_number = SSroguemachine.scomm_jabberlines.len

	is_setup = TRUE

	return

/datum/scommodule/proc/mute(mob/living/user)
	if(!is_setup)
		throw EXCEPTION("YOU MUST CALL 'setup()' ON A SCOMMODULE BEFORE USING IT!!!")
	if(receive_commons && !mute_loudmouth)
		to_chat(user, span_info("I quell the Loudmouth's prattling on the [parent_object.name]. It may be muted entirely still."))
		mute_loudmouth = TRUE
	else
		active_listening  = !active_listening
		active_speaking = !active_speaking
		to_chat(user, span_info("I [active_listening ? "unmute" : "mute"] the [parent_object.name]."))
		if(receive_commons && active_listening)
			to_chat(user, span_info("I enable the Loudmouth's prattling once more."))
			mute_loudmouth = FALSE

/datum/scommodule/proc/start_jabberline(mob/living/user)
	if(!is_setup)
		throw EXCEPTION("YOU MUST CALL 'setup()' ON A SCOMMODULE BEFORE USING IT!!!")

	if(calling)
		disconnect_jabberline()
		to_chat(user, span_info("I cut the jabberline."))
	else
		parent_object.say("Input SCOM designation.", spans = list("info"))
		var/nightcall = input(user, "Input the number you have been provided with.", "INTERFACING") as null|num
		if(!nightcall)
			return
		if(nightcall == scom_number)
			to_chat(user, span_warning("Nothing but rats squeaking back at you."))
			playsound(parent_object, 'sound/vo/mobs/rat/rat_life.ogg', 100, TRUE, -1)
			return
		if(SSroguemachine.scomm_jabberlines.len < nightcall)
			parent_object.say("There are no rats running this jabberline.", spans = list("info"))
			return
		var/datum/scommodule/S = SSroguemachine.scomm_jabberlines[nightcall]
		if(!S)
			to_chat(user, span_warning("There are no rats running this jabberline."))
			return
		if(S.calling || S.called_by)
			parent_object.say("This jabberline's rats are occupied.", spans = list("info"))
			return
		if(!S.speaking || !S.active_speaking)
			parent_object.say("This jabberline's rats have been gagged.", spans = list("info"))
			return
		calling = S
		S.called_by = src
		parent_object.update_icon()
		calling.parent_object.say("Jabberline coupling call from SCOM #[nightcall]!", spans = list("info"))

		for(var/i in 1 to 10)
			if(!calling)
				parent_object.update_icon()
				return
			if(calling.calling == src)
				return
			calling.ring_ring()
			ring_ring()
			sleep(30)
		parent_object.say("This jabberline's rats gave up.", spans = list("info"))
		calling.called_by = null
		calling = null
		parent_object.update_icon()

/datum/scommodule/proc/answer_jabberline(mob/living/user)
	if(!is_setup)
		throw EXCEPTION("YOU MUST CALL 'setup()' ON A SCOMMODULE BEFORE USING IT!!!")

	if(called_by && !calling)
		calling = called_by
		calling.parent_object.say("Jabberline fused.", spans = list("info"))
		parent_object.say("Jabberline fused.", spans = list("info"))
		parent_object.update_icon()
		return TRUE
	if(calling) //Vrell -  WHY THE FUCK IS THIS A MECHANIC? WHO DOES THIS?
		active_listening = !active_listening
		to_chat(user, span_info("I [active_listening ? "unmute" : "mute"] the input on the SCOM."))
		return TRUE
	return FALSE

/datum/scommodule/proc/reject_jabberline(mob/living/user)
	if(!is_setup)
		throw EXCEPTION("YOU MUST CALL 'setup()' ON A SCOMMODULE BEFORE USING IT!!!")

	if(called_by && !calling)
		called_by.parent_object.say("Jabberline refused.", spans = list("info"))
		parent_object.say("Jabberline refused.", spans = list("info"))
		called_by.calling = null
		called_by = null
		return TRUE
	if(calling) //Vrell - this is such niche behaviour. Who wrote this????
		active_speaking = !active_speaking
		to_chat(user, span_info("I [active_speaking ? "unmute" : "mute"] the output on the SCOM."))
		return TRUE
	return FALSE

/datum/scommodule/proc/disconnect_jabberline(coverother = TRUE)
	if(coverother)
		calling?.disconnect_jabberline(FALSE)
	if(!is_broken)
		parent_object.say("Jabberline severed.", spans = list("info"))
	called_by = null
	calling = null
	active_speaking = active_listening
	parent_object.update_icon()

/datum/scommodule/proc/ring_ring()
	playsound(parent_object, 'sound/vo/mobs/rat/rat_life.ogg', 100, TRUE, 3)
	var/oldx = parent_object.pixel_x
	animate(parent_object, pixel_x = oldx+1, time = 0.5)
	animate(pixel_x = oldx-1, time = 0.5)
	animate(pixel_x = oldx, time = 0.5)

/datum/scommodule/proc/examine(mob/user)
	if(!is_setup)
		throw EXCEPTION("YOU MUST CALL 'setup()' ON A SCOMMODULE BEFORE USING IT!!!")
	if(scom_number)
		. += "Its designation is #[scom_number][scom_tag ? ", labeled as [scom_tag]" : ""].\n"
		//Shows the directory on all scoms that can do jabberlines.
		. += "<a href='?src=[REF(src)];directory=1'>Directory</a>"

/datum/scommodule/Topic(href, href_list)
	..()

	if(!usr)
		return

	if(href_list["directory"])
		view_directory(usr)

/datum/scommodule/proc/view_directory(mob/user)
	var/dat
	for(var/datum/scommodule/X in SSroguemachine.scomm_jabberlines)
		if(X.scom_tag)
			dat += "#[X.scom_number] [X.scom_tag]<br>"

	var/datum/browser/popup = new(user, "scom_directory", "<center>RAT REGISTER</center>", 387, 420)
	popup.set_content(dat)
	popup.open(FALSE)

/datum/scommodule/proc/break_scom()
	if(!is_setup)
		throw EXCEPTION("YOU MUST CALL 'setup()' ON A SCOMMODULE BEFORE USING IT!!!")
	is_broken = TRUE
	disconnect_jabberline()
	speaking = FALSE
	listening = FALSE

	// OPTIMIZATIONS!
	cleanup()

/datum/scommodule/proc/cleanup()
	SSroguemachine.scomm_machines -= src
	SSroguemachine.scomm_jabberlines -= src
	SSroguemachine.scomm_commons -= src
	SSroguemachine.scomm_garrison -= src
	SSroguemachine.scomm_matthios -= src

/datum/scommodule/proc/scom_hear(atom/movable/speaker, message_language, raw_message, crown = FALSE, list/tspans = list())
	if(!is_setup)
		throw EXCEPTION("YOU MUST CALL 'setup()' ON A SCOMMODULE BEFORE USING IT!!!")
	if(!ishuman(speaker))
		return
	if(!listening || !active_listening)
		return
	if(!raw_message) // WHY THE FUCK WASN'T THIS UP HERE TO BEGIN WITH?!?!?!?!?!
		return
	var/mob/living/carbon/human/H = speaker
	var/usedcolor = H.voice_color
	if(H.voicecolor_override)
		usedcolor = H.voicecolor_override
	if(length(raw_message) > 100) //When these people talk too much, put that shit in slow motion, yeah
		/*if(length(raw_message) > 200)
			if(!spawned_rat)
				visible_message(span_warning("An angered rous emerges from the SCOMlines!"))
				new /mob/living/simple_animal/hostile/retaliate/rogue/bigrat(get_turf(src))
				spawned_rat = TRUE
			return*/
		raw_message = "<small>[raw_message]</small>"
	var/colored_message = raw_message
	if(H.client.patreon_colored_say_allowed && H.client.prefs.patreon_say_color_enabled)
		colored_message = "<span style='color:#[H.client.prefs.patreon_say_color]'>[raw_message]</span>"
	if(calling)
		if(calling.calling == src)
			calling.repeat_message(colored_message, src, usedcolor, message_language, tspans, SCOM_TARGET_JABBERLINE)
		return
	switch(target)
		if(SCOM_TARGET_GARRISON)
			colored_message = "<span style='color:[garrisoncolor]'>[raw_message]</span>" //Prettying up for Garrison line
			if(crown)
				colored_message = "<big>[colored_message]</big>"
			for(var/datum/scommodule/S in SSroguemachine.scomm_garrison)
				S.repeat_message(colored_message, src, usedcolor, message_language, tspans, target)
		if(SCOM_TARGET_MATTHIOS)
			for(var/datum/scommodule/S in SSroguemachine.scomm_matthios)
				S.repeat_message(colored_message, src, usedcolor, message_language, tspans, target)
		if(SCOM_TARGET_INQUISITOR)
			for(var/datum/scommodule/S in SSroguemachine.scomm_inquisitor)
				S.repeat_message(colored_message, src, usedcolor, message_language, tspans, target)
		if(SCOM_TARGET_LOUDMOUTH)
			for(var/datum/scommodule/S in SSroguemachine.scomm_commons)
				S.repeat_message(colored_message, src, usedcolor, message_language, tspans, target)
		else
			if(common_talk_allowed)
				for(var/datum/scommodule/S in SSroguemachine.scomm_commons)
					S.repeat_message(colored_message, src, usedcolor, message_language, tspans, target)

/datum/scommodule/proc/repeat_message(message, datum/scommodule/A, tcolor, message_language = null, list/tspans = list(), target = SCOM_TARGET_COMMONS)
	if(!is_setup || !parent_object)
		throw EXCEPTION("YOU MUST CALL 'setup()' ON A SCOMMODULE BEFORE USING IT!!! Object:[parent_object]")
	if(A == src)
		return
	//Vrell - moved these checks to the repeat side to make the code look less ass and make it a bit more dynamic.
	if(target == SCOM_TARGET_COMMONS && mute_commons)
		return
	if(target == SCOM_TARGET_GARRISON && mute_garrison)
		return
	if(target == SCOM_TARGET_LOUDMOUTH && mute_loudmouth)
		return
	if(calling && target != SCOM_TARGET_JABBERLINE) // MAKES IT SO JABBERLINES DON'T OUTPUT OTHER STUFF!!!!
		return
	if(tcolor)
		parent_object.voicecolor_override = tcolor
	if(active_speaking && speaking && message)
		playsound(parent_object, message_received_sound, message_received_volume, TRUE, -1)
		parent_object.say(message, spans = tspans, language = message_language)
	parent_object.voicecolor_override = null

/obj/structure/roguemachine/scomm
	name = "SCOM"
	desc = "The Supernatural Communication Optical Machine is a wonder of magic and technology. There's a button in the MIDDLE for making private jabberline connections."
	icon = 'icons/roguetown/misc/machines.dmi'
	icon_state = "scomm1"
	density = FALSE
	blade_dulling = DULLING_BASH
	max_integrity = 0
	pixel_y = 32
	flags_1 = HEAR_1
	anchored = TRUE
	verb_say = "squeaks"
	var/scom_tag //Vrell - USED FOR SETTING TAG IN MAP CREATION!!!!

	var/next_decree = 0
	var/datum/scommodule/scom = new/datum/scommodule()

/obj/structure/roguemachine/scomm/OnCrafted(dirin, mob/user)
	. = ..()
	loc = user.loc
	pixel_y = 0
	switch(dirin)
		if(NORTH)
			pixel_y = 32
		if(SOUTH)
			pixel_y = -32
		if(EAST)
			pixel_x = 32
		if(WEST)
			pixel_x = -32

/obj/structure/roguemachine/scomm/r
	pixel_y = 0
	pixel_x = 32

/obj/structure/roguemachine/scomm/l
	pixel_y = 0
	pixel_x = -32

/obj/structure/roguemachine/scomm/examine(mob/user)
	. = ..()
	. += scom.examine(user)
	if(user.loc == loc)
		. += "<b>THE LAWS OF THE LAND:</b>"
		if(!length(GLOB.laws_of_the_land))
			. += span_danger("The land has no laws! <b>We are doomed!</b>")
			return
		if(!user.is_literate())
			. += span_warning("Uhhh... I can't read them...")
			return
		for(var/i in 1 to length(GLOB.laws_of_the_land))
			. += span_small("[i]. [GLOB.laws_of_the_land[i]]")

/obj/structure/roguemachine/scomm/process()
	if(world.time <= next_decree)
		return
	next_decree = world.time + rand(3 MINUTES, 8 MINUTES)
	if(!GLOB.lord_decrees.len)
		return
	if(!scom.speaking)
		return
	say("The [SSticker.rulertype] Decrees: [pick(GLOB.lord_decrees)]", spans = list("info"))

/obj/structure/roguemachine/scomm/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	user.changeNext_move(CLICK_CD_INTENTCAP)
	playsound(loc, 'sound/misc/beep.ogg', 100, FALSE, -1)
	if(scom.answer_jabberline(user))
		return
	scom.mute(user)
	update_icon()

/obj/structure/roguemachine/scomm/attack_right(mob/user)
	if(.)
		return
	user.changeNext_move(CLICK_CD_INTENTCAP)
	playsound(loc, 'sound/misc/beep.ogg', 100, FALSE, -1)
	if(scom.reject_jabberline(user))
		return
	var/canread = user.can_read(src, TRUE)
	var/contents
	if(SSticker.rulertype == "Grand Duke")
		contents += "<center>GRAND DUKE'S DECREES<BR>"
	else
		contents += "<center>GRAND DUTCHESS' DECREES<BR>"
	contents += "-----------<BR><BR></center>"
	for(var/i = GLOB.lord_decrees.len to 1 step -1)
		contents += "[i]. <span class='info'>[GLOB.lord_decrees[i]]</span><BR>"
	if(!canread)
		contents = stars(contents)
	var/datum/browser/popup = new(user, "VENDORTHING", "", 370, 220)
	popup.set_content(contents)
	popup.open()

/obj/structure/roguemachine/scomm/MiddleClick(mob/living/carbon/human/user)
	if(.)
		return
	if((HAS_TRAIT(user, TRAIT_GUARDSMAN) || HAS_TRAIT(user, TRAIT_GUARDSMAN_NOBLE) || (user.job == "Warden") || (user.job == "Hand") || (user.job == "Watchman") || (user.job == "Squire") || (user.job == "Marshal") || (user.job == "Grand Duke") || (user.job == "Knight Captain") || (user.job == "Knight") || (user.job == "Consort")))
		if(alert("Would you like to swap lines or connect to a jabberline?",, "swap", "jabberline") != "jabberline")
			if(scom.target != SCOM_TARGET_GARRISON)
				scom.target = SCOM_TARGET_GARRISON
			else
				scom.target = SCOM_TARGET_COMMONS
			scom.mute_commons = !scom.mute_commons
			scom.mute_garrison = !scom.mute_commons // Yes this is intentional.
			to_chat(user, span_info("I [scom.target == SCOM_TARGET_GARRISON ? "connect to the garrison SCOMline" : "connect to the general SCOMLINE"]"))
			playsound(loc, 'sound/misc/garrisonscom.ogg', 100, FALSE, -1)
			update_icon()
			return
	user.changeNext_move(CLICK_CD_INTENTCAP)
	playsound(loc, 'sound/misc/beep.ogg', 100, FALSE, -1)
	scom.start_jabberline(user)

/obj/structure/roguemachine/scomm/obj_break(damage_flag)
	..()
	scom.break_scom()
	icon_state = "[icon_state]-br"
	update_icon() // WHY WAS THE ORDER ON THIS WRONG?!?!?!?

/obj/structure/roguemachine/scomm/Initialize()
	. = ..()
//	icon_state = "scomm[rand(1,2)]"
	scom.setup(src, FALSE, TRUE, TRUE, TRUE, DEFAULT_GARRISON_COLOR, 'sound/vo/mobs/rat/rat_life.ogg', 100, SCOM_TARGET_COMMONS, TRUE, TRUE, FALSE, FALSE, scom_tag)
	scom.mute_garrison = TRUE

	START_PROCESSING(SSroguemachine, src)
	become_hearing_sensitive()
	update_icon()

/obj/structure/roguemachine/scomm/update_icon()
	if(obj_broken)
		set_light(0)
		return
	if(scom.target == SCOM_TARGET_GARRISON)
		icon_state = "scomm2"
		return
	if(scom.calling)
		icon_state = "scomm2"
	else if(scom.active_listening)
		icon_state = "scomm1"
	else
		icon_state = "scomm0"

/obj/structure/roguemachine/scomm/Destroy()
	scom.cleanup()
	qdel(scom)
	STOP_PROCESSING(SSroguemachine, src)
	lose_hearing_sensitivity()
	set_light(0)
	return ..()

/obj/structure/roguemachine/scomm/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, message_mode, original_message)
	if(!scom.calling && loc != speaker.loc)
		return
	scom.scom_hear(speaker, message_language, raw_message, FALSE)

/* Vrell - This is unused in the current scom code. removing it.
/obj/structure/roguemachine/scomm/proc/dictate_laws()
	if(dictating)
		return
	dictating = TRUE
	repeat_message("THE LAWS OF THE LAND ARE...", tcolor = COLOR_RED)
	INVOKE_ASYNC(src, PROC_REF(dictation))

/obj/structure/roguemachine/scomm/proc/dictation()
	if(!length(GLOB.laws_of_the_land))
		sleep(2)
		repeat_message("THE LAND HAS NO LAWS!", tcolor = COLOR_RED)
		dictating = FALSE
		return
	for(var/i in 1 to length(GLOB.laws_of_the_land))
		sleep(2)
		repeat_message("[i]. [GLOB.laws_of_the_land[i]]", tcolor = COLOR_RED)
	dictating = FALSE
*/

/proc/scom_announce(message)
	for(var/datum/scommodule/S in SSroguemachine.scomm_commons) //Why wasn't this applied to all common SCOM types in the first place?
		if(S.speaking)
			S.parent_object.say(message, spans = list("info"))

//SCOMSTONE                 SCOMSTONE

/obj/item/scomstone
	name = "scomstone"
	icon_state = "ring_scom"
	desc = "A heavy ring made of metal. There is a gem embedded in the center - dim, but alive."
	gripped_intents = null
	dropshrink = 0.75
	possible_item_intents = list(INTENT_GENERIC)
	force = 10
	throwforce = 10
	slot_flags = ITEM_SLOT_MOUTH|ITEM_SLOT_HIP|ITEM_SLOT_NECK|ITEM_SLOT_RING
	obj_flags = null
	icon = 'icons/roguetown/items/misc.dmi'
	w_class = WEIGHT_CLASS_SMALL
	experimental_inhand = FALSE
	flags_1 = HEAR_1
	muteinmouth = TRUE
	var/hearrange = 1 // change to 0 if you want your special scomstone to be only hearable by wearer
	drop_sound = 'sound/foley/coinphy (1).ogg'
	sellprice = 100
	grid_width = 32
	grid_height = 32
	var/datum/scommodule/scom = new/datum/scommodule()

//wip
/obj/item/scomstone/attack_right(mob/living/carbon/human/user)
	user.changeNext_move(CLICK_CD_INTENTCAP)
	var/input_text = input(user, "Enter your message:", "Message")
	if(!input_text)
		return
	user.whisper(input_text)
	scom.scom_hear(user, null, input_text, FALSE)

/obj/item/scomstone/MiddleClick(mob/user)
	if(.)
		return
	user.changeNext_move(CLICK_CD_INTENTCAP)
	playsound(loc, 'sound/misc/beep.ogg', 100, FALSE, -1)
	scom.mute(user)
	update_icon()

/obj/item/scomstone/Destroy()
	scom.cleanup()
	qdel(scom)
	return ..()

/obj/item/scomstone/Initialize()
	. = ..()
	scominit()
	update_icon()

/obj/item/scomstone/proc/scominit()
	scom.setup(src, TRUE, TRUE, TRUE, FALSE, DEFAULT_GARRISON_COLOR, 'sound/misc/scom.ogg', 100, SCOM_TARGET_COMMONS, TRUE, FALSE, FALSE)

/obj/item/scomstone/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	if(!can_speak())
		return
	if(message == "" || !message)
		return
	spans |= speech_span
	if(!language)
		language = get_default_language()
	if(istype(loc, /obj/item))
		var/obj/item/I = loc
		I.send_speech(message, hearrange, I, , spans, message_language=language)
	else
		send_speech(message, hearrange, src, , spans, message_language=language)

/obj/item/scomstone/bad
	name = "serfstone"
	desc = "A rusty shoddily-made metal ring. The gem embedded within is barely holding on."
	icon_state = "ring_serfscom"
	sellprice = 20

/obj/item/scomstone/bad/scominit()
	scom.setup(src, FALSE, FALSE, TRUE, FALSE, DEFAULT_GARRISON_COLOR, 'sound/misc/scom.ogg', 100, SCOM_TARGET_COMMONS, TRUE, FALSE, FALSE)

/obj/item/scomstone/bad/attack_right(mob/user)
	return

//LISTENSTONE		LISTENSTONE
/obj/item/scomstone/listenstone //Vrell - WHY WASN'T THIS DERIVED FROM THE SCOMSTONE IN THE FIRST PLACE?
	name = "gemerald choker"
	icon_state = "listenstone"
	desc = "An iron and gold choker with a gemerald gem."
	gripped_intents = null
	dropshrink = 0
	possible_item_intents = list(INTENT_GENERIC)
	force = 0
	throwforce = 0
	slot_flags = ITEM_SLOT_MOUTH|ITEM_SLOT_HIP|ITEM_SLOT_NECK|ITEM_SLOT_WRISTS
	obj_flags = null
	icon = 'icons/roguetown/clothing/neck.dmi'
	w_class = WEIGHT_CLASS_SMALL
	experimental_inhand = FALSE
	flags_1 = HEAR_1
	muteinmouth = TRUE
	sellprice = 200
	grid_width = 32
	grid_height = 32

/obj/item/scomstone/listenstone/scominit()
	scom.setup(src, TRUE, TRUE, TRUE, FALSE, DEFAULT_GARRISON_COLOR, 'sound/vo/mobs/rat/rat_life.ogg', 100, SCOM_TARGET_COMMONS, TRUE, FALSE, FALSE)

/obj/item/scomstone/listenstone/MiddleClick(mob/user)
	if(.)
		return
	user.changeNext_move(CLICK_CD_INTENTCAP)
	playsound(loc, 'sound/misc/beep.ogg', 100, FALSE, -1)
	scom.mute(user)
	if(scom.active_listening)
		icon_state = "listenstone"
	else
		icon_state = "listenstone_act"
	update_icon()

// MATTHIAN SCOMCOIN

/obj/item/scomstone/mattcoin
	name = "rontz ring"
	icon_state = "mattcoin"
	desc = "A faded coin with a rontz laid into its center."
	gripped_intents = null
	dropshrink = 0.75
	possible_item_intents = list(INTENT_GENERIC)
	force = 10
	throwforce = 10
	slot_flags = ITEM_SLOT_MOUTH|ITEM_SLOT_HIP|ITEM_SLOT_NECK|ITEM_SLOT_RING
	obj_flags = null
	icon = 'icons/roguetown/items/misc.dmi'
	w_class = WEIGHT_CLASS_SMALL
	experimental_inhand = FALSE
	flags_1 = HEAR_1
	muteinmouth = TRUE
	sellprice = 0
	grid_width = 32
	grid_height = 32

/obj/item/scomstone/mattcoin/scominit()
	scom.setup(src, TRUE, TRUE, TRUE, FALSE, DEFAULT_GARRISON_COLOR, 'sound/foley/coins1.ogg', 20, SCOM_TARGET_MATTHIOS, FALSE, FALSE, TRUE)

/obj/item/scomstone/mattcoin/New(loc, ...)
	. = ..()
	name = pick("rontz ring", "gold ring", "fate weaver", "gemerald ring", "toper ring", "blortz ring", "saffira ring","signet ring","silver signet ring", "dorpel ring")

/obj/item/scomstone/mattcoin/pickup(mob/living/user)
	if(!HAS_TRAIT(user, TRAIT_COMMIE))
		to_chat(user, "The coin turns to ash in my hands!")
		playsound(loc, 'sound/items/firesnuff.ogg', 100, FALSE, -1)
		qdel(src)
	..()

/obj/item/scomstone/mattcoin/doStrip(mob/stripper, mob/owner)
	if(!(stripper?.mind.has_antag_datum(/datum/antagonist/bandit))) //You're not a bandit, you can't strip the bandit coin
		to_chat(stripper, "[src] turns to ash in my hands!")
		playsound(stripper.loc, 'sound/items/firesnuff.ogg', 100, FALSE, -1)
		qdel(src)
		return FALSE
	. = ..()

/obj/item/scomstone/mattcoin/MiddleClick(mob/user)
	user.changeNext_move(CLICK_CD_INTENTCAP)
	playsound(loc, 'sound/misc/coindispense.ogg', 100, FALSE, -1)
	scom.mute(user)
	update_icon()

// INQUISITORIAL LISTENERS AND RECEIVER

/obj/item/scomstone/speakerinq
	name = "secret whisperer"
	desc = "Sweet secrets whispered so freely."
	sellprice = 20
	icon = 'icons/roguetown/items/misc.dmi'
	icon_state = "scomite_active"
	gripped_intents = null
	dropshrink = 0.75
	possible_item_intents = list(INTENT_GENERIC)
	force = 10
	throwforce = 10
	w_class = WEIGHT_CLASS_SMALL
	experimental_inhand = FALSE
	slot_flags = ITEM_SLOT_MOUTH|ITEM_SLOT_HIP|ITEM_SLOT_NECK|ITEM_SLOT_RING
	possible_item_intents = list(INTENT_GENERIC)
	grid_width = 32
	grid_height = 32
	hearrange = 0

/obj/item/scomstone/speakerinq/scominit()
	scom.setup(src, FALSE, FALSE, TRUE, FALSE, DEFAULT_GARRISON_COLOR, 'sound/vo/mobs/rat/rat_life.ogg', 20, SCOM_TARGET_INQUISITOR, FALSE, FALSE, FALSE, TRUE)

/obj/item/scomstone/speakerinq/MiddleClick(mob/user)
	user.changeNext_move(CLICK_CD_INTENTCAP)
	playsound(loc, 'sound/misc/beep.ogg', 100, FALSE, -1)
	scom.mute(user)
	update_icon()

/obj/item/scomstone/speakerinq/attack_right(mob/user)
	return

/obj/item/listeningdevice
	name = "listener"
	desc = "An ever-attentive ear"
	icon = 'icons/roguetown/items/misc.dmi'
	icon_state = "listenstone"
	dropshrink = 0.75
	gripped_intents = null
	possible_item_intents = list(INTENT_GENERIC)
	force = 10
	throwforce = 10
	w_class = WEIGHT_CLASS_SMALL
	experimental_inhand = FALSE
	grid_width = 32
	grid_height = 32

/obj/item/listeningdevice/attack_self(mob/living/user)
	var/turf/step_turf = get_step(get_turf(user), user.dir)
	to_chat(user, span_tinynotice("I begin planting the listen-stone..."))
	if(!do_after(user, 30, src))
		return
	new /obj/structure/listeningdeviceactive(step_turf)
	message_admins("[usr.key] has planted a listening device")
	qdel(src)


/obj/structure/listeningdeviceactive
	name = "listener"
	desc = "An ever attentive ear. A red light blinks upon it..."
	icon_state = "listenstone_active"
	icon = 'icons/roguetown/items/misc.dmi'
	density = FALSE
	anchored = TRUE
	flags_1 = HEAR_1
	alpha = 0
	layer = PROJECTILE_HIT_THRESHHOLD_LAYER
	var/datum/scommodule/scom = new/datum/scommodule()

/obj/structure/listeningdeviceactive/Initialize()
	. = ..()
	scom.setup(src, TRUE, TRUE, FALSE, FALSE, DEFAULT_GARRISON_COLOR, 'sound/vo/mobs/rat/rat_life.ogg', 100, SCOM_TARGET_INQUISITOR, FALSE, FALSE, FALSE, FALSE)
	become_hearing_sensitive()

/obj/structure/listeningdeviceactive/attack_right(mob/user)
	to_chat(user, span_info("I begin dismounting the listen-stone..."))
	if(!do_after(user, 30, src))
		return
	new /obj/item/listeningdevice(loc)
	qdel(src)

/obj/structure/listeningdeviceactive/Destroy()
	scom.cleanup()
	qdel(scom)
	lose_hearing_sensitivity()
	return ..()

/obj/structure/listeningdeviceactive/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, message_mode, original_message)
	scom.scom_hear(speaker, message_language, raw_message, FALSE)

/obj/structure/broadcast_horn
	name = "\improper Streetpipe"
	desc = "Also known as the People's Mouth, so long as the people can afford the ratfeed to pay for it."
	icon_state = "broadcaster_crass"
	icon = 'icons/roguetown/misc/machines.dmi'
	blade_dulling = DULLING_BASH
	max_integrity = 0
	density = TRUE
	anchored = TRUE
	flags_1 = HEAR_1
	speech_span = SPAN_ORATOR
	var/datum/scommodule/scom = new/datum/scommodule()

/obj/structure/broadcast_horn/Initialize()
	. = ..()
	scominit()
	become_hearing_sensitive()


/obj/structure/broadcast_horn/Destroy()
	lose_hearing_sensitivity()
	return ..()

/obj/structure/broadcast_horn/proc/scominit()
	scom.setup(src, TRUE, TRUE, FALSE, FALSE, DEFAULT_GARRISON_COLOR, 'sound/vo/mobs/rat/rat_life.ogg', 100, SCOM_TARGET_LOUDMOUTH_STRONG, FALSE, FALSE, FALSE, FALSE)
	scom.active_listening = TRUE
	scom.active_speaking = FALSE

/obj/structure/broadcast_horn/examine(mob/user)
	. = ..()
	if(scom.active_listening)
		. += "There's a faint skittering coming out of it."
	else
		. += "The rats within are quiet."

/obj/structure/broadcast_horn/redstone_triggered()
	toggle_horn()

/obj/structure/broadcast_horn/proc/toggle_horn()
	playsound(loc, 'sound/misc/beep.ogg', 100, FALSE, -1)
	if(scom.active_listening)
		visible_message(span_notice("[src]'s whine stills."))
		scom.active_listening = FALSE
	else
		scom.active_listening = TRUE
		visible_message(span_notice("[src] squeaks alive."))

/obj/structure/broadcast_horn/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, message_mode, original_message)
	var/turf/step_turf = get_step(get_turf(src), src.dir) //Vrell - OH BOY DO I LOVE NOT FOLLOWING THE CONVENTIONS SET BY THE CODE THAT CAME BEFORE ME!!!! (not actually that bad but weh)
	if(get_turf(speaker) != step_turf)
		return
	var/list/tspans = list()
	tspans |= speech_span
	scom.scom_hear(speaker, message_language, raw_message, FALSE, tspans)

/obj/structure/broadcast_horn/loudmouth
	name = "\improper Golden Mouth"
	desc = "The Loudmouth's own gleaming horn, its surface engraved with the ducal crest."
	icon_state = "broadcaster"
	var/speech_color = COLOR_ASSEMBLY_GOLD

/obj/structure/broadcast_horn/loudmouth/scominit()
	scom.setup(src, TRUE, TRUE, FALSE, FALSE, DEFAULT_GARRISON_COLOR, 'sound/vo/mobs/rat/rat_life.ogg', 100, SCOM_TARGET_LOUDMOUTH, FALSE, FALSE, FALSE, FALSE)
	scom.active_listening = FALSE
	scom.active_speaking = FALSE

/obj/structure/broadcast_horn/loudmouth/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, message_mode, original_message)
	var/turf/step_turf = get_step(get_turf(src), src.dir) //Vrell - OH BOY DO I LOVE NOT FOLLOWING THE CONVENTIONS SET BY THE CODE THAT CAME BEFORE ME!!!! (not actually that bad but weh)
	if(get_turf(speaker) != step_turf)
		return
	var/list/tspans = list()
	tspans |= speech_span
	raw_message = "<span style='color: [speech_color]'>[raw_message]</span>"
	scom.scom_hear(speaker, message_language, raw_message, FALSE, tspans)

/obj/structure/broadcast_horn/loudmouth/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	user.changeNext_move(CLICK_CD_INTENTCAP)
	toggle_horn()

/obj/structure/broadcast_horn/loudmouth/guest
	name = "\improper Silver Tongue"
	desc = "A guest's horn. Not as gaudy as the Loudmouth's own, but still a fine piece of craftsmanship. "
	icon_state = "broadcaster_crass"
	speech_color = COLOR_ASSEMBLY_GURKHA

// garrison scoms/listenstones

/obj/item/scomstone/garrison
	name = "crownstone"
	icon_state = "ring_crownscom"
	desc = "A lavish golden ring with the mark of the Crown. Heavy and garish. The gem embedded flickering in excitement."
	sellprice = 100
	hearrange = 0

/obj/item/scomstone/garrison/scominit()
	scom.setup(src, TRUE, TRUE, TRUE, FALSE, DEFAULT_GARRISON_COLOR, 'sound/misc/garrisonscom.ogg', 100, SCOM_TARGET_COMMONS, TRUE, TRUE, FALSE, FALSE)

/obj/item/scomstone/garrison/attack_self(mob/living/user)
	if(.)
		return
	user.changeNext_move(CLICK_CD_INTENTCAP)
	playsound(loc, 'sound/misc/beep.ogg', 100, FALSE, -1)
	if(scom.target == SCOM_TARGET_COMMONS)
		scom.target = SCOM_TARGET_GARRISON
	else
		scom.target = SCOM_TARGET_COMMONS
	to_chat(user, span_info("I [scom.target == SCOM_TARGET_GARRISON ? "connect to the garrison SCOMline" : "connect to the general SCOMline"]"))
	update_icon()

/obj/item/scomstone/garrison/update_icon()
	icon_state = "[initial(icon_state)][scom.target == SCOM_TARGET_GARRISON ? "_on" : ""]"

/obj/item/scomstone/bad/garrison
	name = "houndstone"
	desc = "A basic metal ring. It has a well-cut, dismal gem embedded - bearing the mark of the Crown."
	icon_state = "ring_houndscom"
	sellprice = 20
	hearrange = 0

/obj/item/scomstone/bad/garrison/scominit()
	scom.setup(src, FALSE, FALSE, TRUE, FALSE, DEFAULT_GARRISON_COLOR, 'sound/misc/garrisonscom.ogg', 100, SCOM_TARGET_COMMONS, TRUE, TRUE, FALSE, FALSE)

/obj/item/clothing/head/roguetown/crown/serpcrown
	name = "Crown of Scarlet Reach"
	article = "the"
	desc = "Heavy is the head that wears this."
	icon_state = "serpcrown"
	dynamic_hair_suffix = null
	sellprice = 200
	resistance_flags = FIRE_PROOF | ACID_PROOF
	anvilrepair = /datum/skill/craft/armorsmithing
	visual_replacement = /obj/item/clothing/head/roguetown/crown/fakecrown
	var/datum/scommodule/scom = new/datum/scommodule()
	var/hearrange = 0 // Only hearable by wearer
	is_important = TRUE

/obj/item/clothing/head/roguetown/crown/serpcrown/Initialize()
	. = ..()
	if(SSroguemachine.crown)
		qdel(src)
	else
		SSroguemachine.crown = src
	scom.setup(src, TRUE, TRUE, TRUE, FALSE, GARRISON_CROWN_COLOR, 'sound/misc/scom.ogg', 100, SCOM_TARGET_COMMONS, TRUE, TRUE, FALSE, FALSE)
	become_hearing_sensitive()

/obj/item/clothing/head/roguetown/crown/serpcrown/proc/anti_stall()
	src.visible_message(span_warning("The Crown of Scarlet Reach crumbles to dust, the ashes spiriting away in the direction of the Keep."))
	SSroguemachine.crown = null //Do not harddel.
	qdel(src) //Anti-stall

/obj/item/clothing/head/roguetown/crown/serpcrown/attack_right(mob/living/carbon/human/user)
	user.changeNext_move(CLICK_CD_MELEE)
	var/input_text = input(user, "Enter your ducal message:", "Crown SCOM")
	if(!input_text)
		return
	user.whisper(input_text)
	scom.scom_hear(user, null, input_text, TRUE)

/obj/item/clothing/head/roguetown/crown/serpcrown/attack_self(mob/living/user)
	if(.)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	playsound(loc, 'sound/misc/beep.ogg', 100, FALSE, -1)
	if(scom.target == SCOM_TARGET_COMMONS)
		scom.target = SCOM_TARGET_GARRISON
	else
		scom.target = SCOM_TARGET_COMMONS
	to_chat(user, span_info("I [scom.target == SCOM_TARGET_GARRISON ? "connect the crown to the garrison SCOMline" : "connect the crown to the general SCOMline"]"))

/obj/item/clothing/head/roguetown/crown/serpcrown/MiddleClick(mob/user)
	if(.)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	playsound(loc, 'sound/misc/beep.ogg', 100, FALSE, -1)
	scom.mute(user)
	update_icon()

/obj/item/clothing/head/roguetown/crown/serpcrown/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	if(!can_speak())
		return
	if(message == "" || !message)
		return
	spans |= speech_span
	if(!language)
		language = get_default_language()
	if(istype(loc, /obj/item))
		var/obj/item/I = loc
		I.send_speech(message, hearrange, I, , spans, message_language=language)
	else
		send_speech(message, hearrange, src, , spans, message_language=language)

/obj/item/clothing/head/roguetown/crown/serpcrown/Destroy()
	lose_hearing_sensitivity()
	scom.cleanup()
	qdel(scom)
	return ..()
