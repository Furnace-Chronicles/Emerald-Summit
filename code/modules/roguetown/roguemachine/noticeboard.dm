/obj/structure/roguemachine/noticeboard
	name = "Notice Board"
	desc = "A large wooden notice board, carrying postings from all across Scarlet Reach. A ZAD perch sits atop it."
	icon = 'icons/roguetown/misc/64x64.dmi'
	icon_state = "noticeboard0"
	density = TRUE
	anchored = TRUE
	max_integrity = 0
	blade_dulling = DULLING_BASH
	layer = ABOVE_MOB_LAYER
	plane = GAME_PLANE_UPPER
	var/current_category = NOTICEBOARD_CAT_POSTINGS
	var/list/categories = NOTICEBOARD_ALL_CATEGORIES

/obj/structure/roguemachine/boardbarrier //Blocks sprite locations
	name = ""
	desc = "A large wooden notice board, carrying postings from all across Scarlet Reach. A ZAD perch sits atop it."
	icon = 'icons/roguetown/underworld/underworld.dmi'
	icon_state = "spiritpart"
	density = TRUE
	anchored = TRUE

/obj/structure/roguemachine/noticeboard/Initialize()
	. = ..()
	SSroguemachine.noticeboards += src
	RegisterSignal(SSdcs, COMSIG_NOTICEBOARD_POST_ADDED, PROC_REF(post_added))
	RegisterSignal(SSdcs, COMSIG_NOTICEBOARD_POST_REMOVED, PROC_REF(post_removed))

/obj/structure/roguemachine/noticeboard/Destroy()
	. = ..()
	SSroguemachine.noticeboards -= src
	UnregisterSignal(SSdcs, list(COMSIG_NOTICEBOARD_POST_ADDED,	COMSIG_NOTICEBOARD_POST_REMOVED))

/datum/noticeboardpost
	var/title
	var/truepostername
	var/posterstitle
	var/poster
	var/message
	/// Composed HTML banner for quick display
	var/banner
	/// Weakref to the poster's mob
	var/datum/weakref/posterweakref

/datum/noticeboardpost/Destroy(force, ...)
	posterweakref = null
	return ..()

/obj/structure/roguemachine/noticeboard/examine(mob/living/carbon/human/user)
	. = ..()
	if(!ishuman(user))
		return
	if(user in GLOB.board_viewers)
		return
	else
		GLOB.board_viewers += user
		to_chat(user, span_smallred("A new posting has been made since I last checked!"))

/obj/structure/roguemachine/noticeboard/update_icon()
	. = ..()
	var/total_length = length(GLOB.noticeboard_posts) + length(GLOB.premium_noticeboardposts) + length(GLOB.sellsword_noticeboardposts)
	switch(total_length)
		if(0)
			icon_state = "noticeboard0"
		if(1 to 3)
			icon_state = "noticeboard1"
		if(4 to 6)
			icon_state = "noticeboard2"
		else
			icon_state = "noticeboard3"

/obj/structure/roguemachine/noticeboard/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/roguecoin))
		var/obj/item/roguecoin/coin = I
		switch(coin.get_real_price())
			if(5) // One silver coin
				merc_message(user, coin)
			if(10) // One gold coin
				merc_broadcast(user, coin)	
	return ..()

/obj/structure/roguemachine/noticeboard/proc/merc_message(mob/living/carbon/human/user, obj/item/roguecoin/coin)
	if(user.has_status_effect(/datum/status_effect/debuff/mercdmcooldown))
		to_chat(user, span_warning("I must wait a time until contacting another sellsword..."))
		return

	var/list/available_mercs = list()
	for(var/datum/noticeboardpost/saved_post in GLOB.sellsword_noticeboardposts)
		if(saved_post.poster != MERC_STATUS_AVAILABLE)
			continue

		var/mob/living/L = saved_post.posterweakref?.resolve()
		if(QDELETED(L) || L.stat == DEAD)
			continue
		
		available_mercs[L.real_name] = L

	if(!available_mercs.len)
		to_chat(user, span_warning("No sellswords are willing to earn mammons todae."))
		return

	var/choice = tgui_input_list(user, "Select a mercenary to contact", "Mercenary Contact", available_mercs)
	if(!choice || !Adjacent(user))
		return

	var/message = tgui_input_text(
		user, 
		"Enter your message to [choice]. Remember, they will be able to answer only yae or nae.", 
		"Mercenary Contact", 
		max_length = 300, 
		bigmodal = TRUE
	)
	if(!message || !Adjacent(user))
		return

	var/mob/living/carbon/chosen_merc = available_mercs[choice]
	if(!istype(chosen_merc))
		return

	qdel(coin)
	LAZYADD(GLOB.merc_dm_enquiries, "\ref[user]_\ref[chosen_merc]")
	playsound(src, 'sound/ambience/noises/birds (7).ogg', 30, FALSE, -1)
	to_chat(user, span_notice("My message has been sent to [chosen_merc.real_name]."))
	to_chat(
		chosen_merc, 
		span_boldnotice(
			"A potential employer contacts me: <i>[message]</i> - [user.real_name]<br>\
			<a href='?src=[REF(src)];direct_response=yae;enquierer_ref=\ref[user];eol=[world.time + MERC_DM_RESPONSE_LIFESPAN]'>\[YAE\]</a> | \
			<a href='?src=[REF(src)];direct_response=nae;enquierer_ref=\ref[user];eol=[world.time + MERC_DM_RESPONSE_LIFESPAN]'>\[NAE\]</a>"\
		)
	)
	chosen_merc.playsound_local(chosen_merc, 'sound/misc/notice (2).ogg', 100)
	user.apply_status_effect(/datum/status_effect/debuff/mercdmcooldown)

/obj/structure/roguemachine/noticeboard/proc/merc_broadcast(mob/living/carbon/human/user, obj/item/roguecoin/coin)
	if(user.has_status_effect(/datum/status_effect/debuff/mercbroadcastcooldown))
		to_chat(user, span_warning("I must wait a time until broadcasting to sellswords again..."))
		return

	var/list/available_mercs = list()
	for(var/datum/noticeboardpost/saved_post in GLOB.sellsword_noticeboardposts)
		if(saved_post.poster == MERC_STATUS_DND)
			continue

		var/mob/living/L = saved_post.posterweakref?.resolve()
		if(QDELETED(L) || L.stat == DEAD)
			continue
			
		available_mercs += L

	if(!available_mercs.len)
		to_chat(user, span_warning("No sellswords are willing to earn mammons todae."))
		return

	var/message = tgui_input_text(user, "Enter your message to broadcast to all sellswords in the Reach.", "Mercenary Contact", max_length = 300, bigmodal = TRUE)
	if(!message || !Adjacent(user))
		return

	qdel(coin)
	playsound(src, 'sound/ambience/noises/birds (7).ogg', 30, FALSE, -1)
	var/list/merc_ckeys = list()
	for(var/mob/living/L in available_mercs)
		merc_ckeys += key_name(L)
		playsound(L.loc, 'sound/misc/notice (2).ogg', 100, FALSE, -1)
		to_chat(user, span_boldannounce("The mercenary statue calls out: <i>[message]</i> - [user.real_name]<br>"))

	to_chat(user, span_notice("My message has been broadcast to [LAZYLEN(available_mercs)] mercenary[LAZYLEN(available_mercs) == 1 ? "" : "s"]."))
	user.log_talk(message, LOG_SAY, tag="noticeboard merc broadcast (to [merc_ckeys.Join(", ")])")
	user.apply_status_effect(/datum/status_effect/debuff/mercbroadcastcooldown)

/obj/structure/roguemachine/noticeboard/Topic(href, href_list)
	. = ..()
	if(href_list["direct_response"])// Merc DM response, handled before CanUseTopic
		var/mob/living/carbon/human/responder = usr
		if(!istype(responder) || responder.mind?.assigned_role != "Mercenary")
			return
		/**
		 * TextRefs can be replaced - when an object is deleted another can take its place in memory
		 * But the chances of a human mob being raplced in 2 minutes by another huaman mob are very slim
		 * At least according to my guesstimations. In all other replacement cases istype() will fail.
		 * Beat me with a stick if a mercenary responds to the wrong person because of this. ~ Halford
		 */
		var/mob/living/carbon/human/enquierer = locate(href_list["enquierer_ref"])
		if(!istype(enquierer) || !enquierer.mind || !enquierer.client)
			to_chat(responder, span_warning("There is no one to respond to."))
			return

		if(!("\ref[enquierer]_\ref[responder]" in GLOB.merc_dm_enquiries))
			to_chat(responder, span_warning("It seems I have already responded to this message."))
			return

		if(world.time >= text2num(href_list["eol"]))
			to_chat(responder, span_warning("It must be too late."))
			return

		var/response_type = href_list["direct_response"]
		// Send response to sender
		if(response_type == "yae")
			to_chat(enquierer, span_notice("[responder.real_name] responded in affirmation to my message."))
			to_chat(responder, span_notice("I responded in affirmation to [enquierer.real_name]."))
		else // nae
			to_chat(enquierer, span_notice("[responder.real_name] responded negatively to my message."))
			to_chat(responder, span_notice("I responded negatively to [enquierer.real_name]."))
		playsound(enquierer.loc, 'sound/misc/notice (2).ogg', 100, FALSE, -1)
		playsound(responder.loc, 'sound/misc/beep.ogg', 100, FALSE, -1)
		LAZYREMOVE(GLOB.merc_dm_enquiries, "\ref[enquierer]_\ref[responder]")
		responder.log_talk("direct response: [response_type]", LOG_SAY, tag="mercenary noticeboard response (to [key_name(enquierer)])")
		return

	if(!usr.canUseTopic(src, BE_CLOSE))
		return
	if(href_list["changecategory"])
		current_category = href_list["changecategory"]
	if(href_list["makepost"])
		make_post(usr)
		return attack_hand(usr)
	if(href_list["premiumpost"])
		premium_post(usr)
		return attack_hand(usr)
	if(href_list["removepost"])
		remove_post(usr)
		return attack_hand(usr)
	if(href_list["authorityremovepost"])
		authority_removepost(usr)
		return attack_hand(usr)
	if(href_list["changemercstatus"])
		change_merc_status(usr)
		return attack_hand(usr)
	if(href_list["editmercpost"])
		edit_merc_post(usr)
		return attack_hand(usr)
	return attack_hand(usr)

/obj/structure/roguemachine/noticeboard/attack_hand(mob/living/carbon/human/user)
	if(!ishuman(user)) 
		return
	var/can_remove = FALSE
	var/can_premium = FALSE
	if(user.job in list("Man at Arms","Inquisitor", "Knight", "Sergeant", "Orthodoxist", "Absolver","Marshal", "Hand"))
		can_remove = TRUE
	if(user.job in list("Bathmaster","Merchant", "Innkeeper", "Steward", "Court Magician", "Town Crier", "Keeper"))
		can_premium = TRUE
	var/contents
	contents += "<center>NOTICEBOARD<BR>"
	contents += "--------------<BR>"
	var/selection = "Categories: "
	for(var/i = 1, i <= length(categories), i++)
		var/category = categories[i]
		if(category == current_category)
			selection += "<b>[current_category]</b> | "
		else if(i != length(categories))
			selection += "<a href='?src=[REF(src)];changecategory=[category]'>[category]</a> | "
		else
			selection += "<a href='?src=[REF(src)];changecategory=[category]'>[category]</a> "
	contents += selection + "<BR>"
	if(current_category in list(NOTICEBOARD_CAT_POSTINGS, NOTICEBOARD_CAT_PREMIUM))
		contents += "<a href='?src=[REF(src)];makepost=1'>Make a Posting</a>"
		if(can_premium)
			contents += " | <a href='?src=[REF(src)];premiumpost=1'>Make a Premium Posting</a><br>"
		else
			contents += "<br>"
		contents += "<a href='?src=[REF(src)];removepost=1'>Remove my Posting</a><br>"
		if(can_remove)
			contents += "<a href='?src=[REF(src)];authorityremovepost=1'>Authority: Remove a Posting</a>"
	var/board_empty = TRUE
	switch(current_category)
		if(NOTICEBOARD_CAT_POSTINGS)
			for(var/datum/noticeboardpost/saved_post in GLOB.noticeboard_posts)
				contents += saved_post.banner
				board_empty = FALSE
		if(NOTICEBOARD_CAT_PREMIUM)
			for(var/datum/noticeboardpost/saved_post in GLOB.premium_noticeboardposts)
				contents += saved_post.banner
				board_empty = FALSE
		if(NOTICEBOARD_CAT_SCOUT)
			var/list/regional_threats = SSregionthreat.get_threat_regions_for_display()
			contents += "<h2>Scout Report</h2>"
			contents += "<hr></center>"
			for(var/T in regional_threats)
				var/datum/threat_region_display/TRS = T
				contents += ("<div>[TRS?.region_name]: <font color=[TRS?.danger_color]>[TRS?.danger_level]</font></div>")
			contents += "<hr>"
			contents += "Scouts rate how dangerous a region is from Safe -> Low -> Moderate -> Dangerous -> Bleak <br>"
			contents += "A safe region is safe and travelers are unlikely to be ambushed by common creechurs and brigands <br>"
			contents += "A low threat region is unlikely to manifest any great threat and brigands and creechurs are often found alone.<br>"
			contents += "Only the Black Basin, Scarlet Grove and the Terrorbog can be rendered safe entirely. <br>" 
			contents += "Regions not listed are beyond the charge of the wardens. Danger will be constant in these regions.<br>"
			contents += "Danger is reduced by luring villains and creechurs and killing them when they ambush you. The signal horns wardens have been issued can help with this. Take care with using it."
		if(NOTICEBOARD_CAT_SELLSWORDS)
			if(LAZYLEN(GLOB.sellsword_noticeboardposts))
				board_empty = FALSE
				var/merc_count = 0
				var/available_count = 0
				var/contracted_count = 0
				var/dnd_count = 0
				var/list/available_mercs = list()
				var/list/contracted_mercs = list()
				var/list/dnd_mercs = list()
				var/user_status = null
				for(var/datum/noticeboardpost/saved_post in GLOB.sellsword_noticeboardposts)
					merc_count++
					switch(saved_post.poster)
						if(MERC_STATUS_AVAILABLE)
							available_count++
							available_mercs += saved_post
						if(MERC_STATUS_CONTRACTED)
							contracted_count++
							contracted_mercs += saved_post
						if(MERC_STATUS_DND)
							dnd_count++
							dnd_mercs += saved_post
					if(saved_post.posterweakref.resolve() == user)
						user_status = saved_post.poster

				if(!isnull(user_status))
					contents += "<br><center><a href='?src=[REF(src)];changemercstatus=1'>Current status: [user_status]</a><br>"
					contents += "<center><a href='?src=[REF(src)];editmercpost=1'>Edit my post</a></center><br>"

				contents += "<center><i>Insert a silver coin to message one, gold to message them all.</i></center>"
				contents += "<center><b>Registered Mercenaries:</b><br>"
				contents += "Total: <b>[merc_count]</b> | "
				contents += "<span style='color:green;'>Available: [available_count]</span> | "
				contents += "<span style='color:orange;'>Contracted: [contracted_count]</span> | "
				contents += "<span style='color:red;'>DND: [dnd_count]</span>"
				contents += "</center><br><hr>"

				if(LAZYLEN(available_mercs))
					contents += "<b><span style='color:green;'>Available for Contract:</span></b><br>"
					for(var/datum/noticeboardpost/mercpost in available_mercs)
						contents += mercpost.banner
					contents += "<br>"

				if(LAZYLEN(contracted_mercs))
					contents += "<b><span style='color:orange;'>Currently Contracted:</span></b><br>"
					for(var/datum/noticeboardpost/mercpost in contracted_mercs)
						contents += mercpost.banner
					contents += "<br>"

				if(LAZYLEN(dnd_mercs))
					contents += "<b><span style='color:red;'>Do Not Disturb:</span></b><br>"
					for(var/datum/noticeboardpost/mercpost in dnd_mercs)
						contents += mercpost.banner
	if(board_empty)
		contents += "<br><span class='notice'>No postings have been made yet!</span>"
	var/datum/browser/popup = new(user, "NOTICEBOARD", "", 800, 650)
	popup.set_content(contents)
	popup.open()


/obj/structure/roguemachine/noticeboard/proc/premium_post(mob/living/carbon/human/guy)
	if(guy.has_status_effect(/datum/status_effect/debuff/postcooldown))
		to_chat(guy, span_warning("I must wait a time until my next posting..."))
		return
	var/inputtitle = input(guy, "What shall the title of my posting be?", "NOTICEBOARD", null)
	if(!inputtitle)
		return
	var/inputmessage = stripped_multiline_input(guy, "What shall I write for this posting?", "NOTICEBOARD", no_trim=TRUE)
	if(inputmessage)
		if(length(inputmessage) > 2000)
			to_chat(guy, span_warning("Too long! You shall surely overburden the with this novel!"))
			return
	else
		return
	var/inputname = input(guy, "What name shall I use on the posting?", "NOTICEBOARD", null)
	if(!inputname)
		return
	var/inputrole = input(guy, "What personal title shall I use on the posting?", "NOTICEBOARD", null)
	add_post(inputmessage, inputtitle, inputname, inputrole, guy.real_name, NOTICEBOARD_CAT_PREMIUM, guy)
	guy.apply_status_effect(/datum/status_effect/debuff/postcooldown)
	message_admins("[ADMIN_LOOKUPFLW(guy)] has made a notice board post. The message was: [inputmessage]")

/obj/structure/roguemachine/noticeboard/proc/post_added(ssdcs, source)
	SIGNAL_HANDLER
	if(src == source) // This board is the one from which new posts originated, ignore it
		return

	playsound(src, 'sound/ambience/noises/birds (7).ogg', 50, FALSE, -1)
	visible_message(span_smallred("A ZAD lands, delivering a new posting!"))
	update_icon()

/obj/structure/roguemachine/noticeboard/proc/post_removed(ssdcs, source)
	SIGNAL_HANDLER
	if(src == source) // This board is the one from which new posts originated, ignore it
		return

	playsound(src, 'sound/ambience/noises/birds (7).ogg', 50, FALSE, -1)
	visible_message(span_smallred("A ZAD lands, removing an old posting!"))
	update_icon()

/obj/structure/roguemachine/noticeboard/proc/make_post(mob/living/carbon/human/guy)
	if(guy.has_status_effect(/datum/status_effect/debuff/postcooldown))
		to_chat(guy, span_warning("I must wait a time until my next posting..."))
		return
	var/inputtitle = stripped_input(guy, "What shall the title of my posting be?", "NOTICEBOARD", null)
	if(!inputtitle)
		return
	if(length(inputtitle) > 50)
		to_chat(guy, span_warning("Too long! You shall surely overburden the zad with this novel!"))
		return
	var/inputmessage = stripped_multiline_input(guy, "What shall I write for this posting?", "NOTICEBOARD", no_trim=TRUE)
	if(inputmessage)
		if(length(inputmessage) > 2000)
			to_chat(guy, span_warning("Too long! You shall surely overburden the zad with this novel!"))
			return
	else
		return
	var/inputname = stripped_input(guy, "What name shall I use on the posting?", "NOTICEBOARD", null)
	if(!inputname)
		return
	if(length(inputname) > 50)
		to_chat(guy, span_warning("Too long! You shall surely overburden the zad with this novel!"))
		return
	var/inputrole = stripped_input(guy, "What personal title shall I use on the posting?", "NOTICEBOARD", null)
	if(length(inputrole) > 50)
		to_chat(guy, span_warning("Too long! You shall surely overburden the zad with this novel!"))
		return
	add_post(inputmessage, inputtitle, inputname, inputrole, guy.real_name, NOTICEBOARD_CAT_POSTINGS, guy)
	guy.apply_status_effect(/datum/status_effect/debuff/postcooldown)
	message_admins("[ADMIN_LOOKUPFLW(guy)] has made a notice board post. The message was: [inputmessage]")
	SEND_GLOBAL_SIGNAL(COMSIG_NOTICEBOARD_POST_ADDED, src)
	update_icon()

/obj/structure/roguemachine/noticeboard/proc/remove_post(mob/living/carbon/human/guy)
	var/list/myposts_list = list()
	for(var/datum/noticeboardpost/removable_posts in GLOB.noticeboard_posts)
		if(removable_posts.truepostername == guy.real_name)
			myposts_list += removable_posts.title
	for(var/datum/noticeboardpost/removable_postspremium in GLOB.premium_noticeboardposts)
		if(removable_postspremium.truepostername == guy.real_name)
			myposts_list += removable_postspremium.title
	if(!myposts_list.len)
		to_chat(guy, span_warning("There are no posts I can take down."))
		return
	var/post2remove = input(guy, "Which post shall I take down?", src) as null|anything in myposts_list
	if(!post2remove)
		return
	playsound(loc, 'sound/foley/dropsound/paper_drop.ogg', 50, FALSE, -1)
	loc.visible_message(span_smallred("[guy] tears down a posting!"))
	for(var/datum/noticeboardpost/removing_post in GLOB.noticeboard_posts)
		if(post2remove == removing_post.title && removing_post.truepostername == guy.real_name)
			GLOB.noticeboard_posts -= removing_post
			message_admins("[ADMIN_LOOKUPFLW(guy)] has removed their post, the message was [removing_post.message]")
	for(var/datum/noticeboardpost/removing_post in GLOB.premium_noticeboardposts)
		if(post2remove == removing_post.title && removing_post.truepostername == guy.real_name)
			GLOB.premium_noticeboardposts -= removing_post
			message_admins("[ADMIN_LOOKUPFLW(guy)] has removed their post, the message was [removing_post.message]")
	SEND_GLOBAL_SIGNAL(COMSIG_NOTICEBOARD_POST_REMOVED, src)
	update_icon()

/obj/structure/roguemachine/noticeboard/proc/authority_removepost(mob/living/carbon/human/guy)
	var/list/posts_list = list()
	for(var/datum/noticeboardpost/removable_posts in GLOB.noticeboard_posts)
		posts_list += removable_posts.title
	if(!posts_list.len)
		to_chat(guy, span_warning("There are no posts I can take down."))
		return
	var/post2remove = input(guy, "Which post shall I take down?", src) as null|anything in posts_list
	if(!post2remove)
		return
	playsound(loc, 'sound/foley/dropsound/paper_drop.ogg', 50, FALSE, -1)
	loc.visible_message(span_smallred("[guy] tears down a posting!"))
	for(var/datum/noticeboardpost/removing_post in GLOB.noticeboard_posts)
		if(post2remove == removing_post.title)
			GLOB.noticeboard_posts -= removing_post
			message_admins("[ADMIN_LOOKUPFLW(guy)] has authoritavely removed a post, the message was [removing_post.message]")

/obj/structure/roguemachine/noticeboard/proc/change_merc_status(mob/living/carbon/human/guy)
	for(var/datum/noticeboardpost/saved_post in GLOB.sellsword_noticeboardposts)
		if(saved_post.posterweakref.resolve() != guy)
			continue

		switch(saved_post.poster)
			if(MERC_STATUS_AVAILABLE)
				saved_post.poster = MERC_STATUS_CONTRACTED
			if(MERC_STATUS_CONTRACTED)
				saved_post.poster = MERC_STATUS_DND
			if(MERC_STATUS_DND)
				saved_post.poster = MERC_STATUS_AVAILABLE

/obj/structure/roguemachine/noticeboard/proc/edit_merc_post(mob/living/carbon/human/guy)
	for(var/datum/noticeboardpost/saved_post in GLOB.sellsword_noticeboardposts)
		if(saved_post.posterweakref.resolve() != guy)
			continue

		var/inputmessage = stripped_multiline_input(guy, "What shall I write my mercenary posting?", "MERCENARY", no_trim=TRUE)
		if(!inputmessage)
			return

		message_admins("[ADMIN_LOOKUPFLW(guy)] has edited a sellsword board post. The message was: [inputmessage]")
		saved_post.message = inputmessage
		saved_post.banner = null
		compose_post(saved_post)

/proc/add_post(message, chosentitle, chosenname, chosenrole, truename, category, mob/author)
	var/datum/noticeboardpost/new_post = new /datum/noticeboardpost
	new_post.poster = chosenname
	new_post.title = chosentitle
	new_post.message = message
	new_post.posterstitle = chosenrole
	new_post.truepostername = truename
	new_post.posterweakref = WEAKREF(author)
	compose_post(new_post)
	GLOB.board_viewers = list()
	switch(category)
		if(NOTICEBOARD_CAT_PREMIUM)
			GLOB.premium_noticeboardposts += new_post
		if(NOTICEBOARD_CAT_SELLSWORDS)
			GLOB.sellsword_noticeboardposts += new_post
		if(NOTICEBOARD_CAT_POSTINGS)
			GLOB.noticeboard_posts += new_post

/proc/compose_post(datum/noticeboardpost/new_post)
	new_post.banner += "<center><b>[new_post.title]</b><BR>"
	new_post.banner += "[new_post.message]<BR>"
	new_post.banner += "- [new_post.poster]"
	if(new_post.posterstitle)
		new_post.banner += ", [new_post.posterstitle]"
	new_post.banner += "<BR>"
	new_post.banner += "--------------<BR>"

/datum/status_effect/debuff/postcooldown
	id = "postcooldown"
	duration = 5 MINUTES
	alert_type = /atom/movable/screen/alert/status_effect/debuff/postcooldown

/atom/movable/screen/alert/status_effect/debuff/postcooldown
	name = "Recent messenger"
	desc = "I'll have to wait a bit before making another posting!"

/datum/status_effect/debuff/mercdmcooldown
	id = "mercdmcooldown"
	duration = 30 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/debuff/mercdmcooldown

/atom/movable/screen/alert/status_effect/debuff/mercdmcooldown
	name = "Mercenary Contacted"
	desc = "I'll have to wait a bit before contacting another mercenary!"

/datum/status_effect/debuff/mercbroadcastcooldown
	id = "mercbroadcastcooldown"
	duration = 10 MINUTES
	alert_type = null // It hangs for a long time, no need show a screen alert for so long
