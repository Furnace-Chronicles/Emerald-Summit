GLOBAL_LIST_EMPTY(outlawed_players)
GLOBAL_LIST_EMPTY(lord_decrees)
GLOBAL_LIST_EMPTY(court_agents)
GLOBAL_LIST_INIT(laws_of_the_land, initialize_laws_of_the_land())

#define THROAT_MODE_DEFAULT 1 // Idle
#define THROAT_MODE_ANNOUNCEMENT 2 // Announcements
#define THROAT_MODE_DECREE 3 // Decrees
#define THROAT_MODE_OUTLAW 4 // Outlaws
#define THROAT_MODE_LAW 5 // Make laws

/proc/initialize_laws_of_the_land()
	var/list/laws = strings("laws_of_the_land.json", "lawsets")
	var/list/lawsets_weighted = list()
	for(var/lawset_name as anything in laws)
		var/list/lawset = laws[lawset_name]
		lawsets_weighted[lawset_name] = lawset["weight"]
	var/chosen_lawset = pickweight(lawsets_weighted)
	return laws[chosen_lawset]["laws"]

/obj/structure/roguemachine/titan
	name = "throat"
	desc = "He who wears the crown holds the key to this strange thing. If all else fails, demand the \"secrets of the throat!\""
	icon = 'icons/roguetown/misc/machines.dmi'
	icon_state = ""
	density = FALSE
	blade_dulling = DULLING_BASH
	integrity_failure = 0.5
	max_integrity = 0
	anchored = TRUE
	/// Status of the throat, 1 - 5 [Idle, Announcement, Decree, Outlaw, Make Law]
	var/mode = THROAT_MODE_DEFAULT
	/// Key value pair for mode - examine text
	var/list/throat_modes_kv = list(
		THROAT_MODE_DEFAULT = "The throat is in an idle state, ready to listen to demands.",
		THROAT_MODE_ANNOUNCEMENT = "The throat is ready to announce your will.",
		THROAT_MODE_DECREE = "The throat is eagerly listening to state your decree.",
		THROAT_MODE_OUTLAW = "The throat is awaiting the name of the criminal in mind.",
		THROAT_MODE_LAW = "The throat is prepared to enact your new law.",
	)

/obj/structure/roguemachine/titan/examine(mob/user)
	. = ..()
	var/key = mode // Don't... just don't ask.
	. += span_info("<font color = '#46bacf'>[throat_modes_kv[key]]</font>")


/obj/structure/roguemachine/titan/obj_break(damage_flag)
	..()
	cut_overlays()
//	icon_state = "[icon_state]-br"
	set_light(0)
	return

/obj/structure/roguemachine/titan/Destroy()
	lose_hearing_sensitivity()
	set_light(0)
	return ..()

/obj/structure/roguemachine/titan/Initialize()
	. = ..()
	icon_state = null
	become_hearing_sensitive()
//	var/mutable_appearance/eye_lights = mutable_appearance(icon, "titan-eyes")
//	eye_lights.plane = ABOVE_LIGHTING_PLANE //glowy eyes
//	eye_lights.layer = ABOVE_LIGHTING_LAYER
//	add_overlay(eye_lights)
	set_light(5)

/obj/structure/roguemachine/titan/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, message_mode, message)
//	. = ..()
	if(speaker == src)
		return
	if(speaker.loc != loc)
		return
	if(obj_broken)
		return
	if(!ishuman(speaker))
		return
	var/mob/living/carbon/human/H = speaker
	var/nocrown
	if(!istype(H.head, /obj/item/clothing/head/roguetown/crown/serpcrown))
		nocrown = TRUE
	var/notlord = TRUE
	if(SSticker.rulermob == H || SSticker.regentmob == H)
		notlord = FALSE

	if(mode)
		if(findtext(message, "nevermind"))
			mode = THROAT_MODE_DEFAULT
			return
	if(findtext(message, "summon crown")) //This must never fail, thus place it before all other modestuffs.
		if(!SSroguemachine.crown)
			new /obj/item/clothing/head/roguetown/crown/serpcrown(src.loc)
			say("The crown is summoned!")
			playsound(src, 'sound/misc/machinetalk.ogg', 100, FALSE, -1)
			playsound(src, 'sound/misc/hiss.ogg', 100, FALSE, -1)
		if(SSroguemachine.crown)
			var/obj/item/clothing/head/roguetown/crown/serpcrown/I = SSroguemachine.crown
			if(!I)
				I = new /obj/item/clothing/head/roguetown/crown/serpcrown(src.loc)
			if(I && !ismob(I.loc))//You MUST MUST MUST keep the Crown on a person to prevent it from being summoned (magical interference)
				var/area/crown_area = get_area(I)
				if(crown_area && istype(crown_area, /area/rogue/indoors/town/vault) && notlord) //Anti throat snipe from vault
					say("The crown is within the vault.")
					playsound(src, 'sound/misc/machinetalk.ogg', 100, FALSE, -1)
					return
				I.anti_stall()
				I = new /obj/item/clothing/head/roguetown/crown/serpcrown(src.loc)
				say("The crown is summoned!")
				playsound(src, 'sound/misc/machinetalk.ogg', 100, FALSE, -1)
				playsound(src, 'sound/misc/hiss.ogg', 100, FALSE, -1)
				return
			if(ishuman(I.loc))
				var/mob/living/carbon/human/HC = I.loc
				if(HC.stat != DEAD)
					if(I in HC.held_items)
						say("[HC.real_name] holds the crown!")
						playsound(src, 'sound/misc/machinetalk.ogg', 100, FALSE, -1)
						return
					if(HC.head == I)
						say("[HC.real_name] wears the crown!")
						playsound(src, 'sound/misc/machinetalk.ogg', 100, FALSE, -1)
						return
				else
					HC.dropItemToGround(I, TRUE) //If you're dead, forcedrop it, then move it.
			I.forceMove(src.loc)
			say("The crown is summoned!")
			playsound(src, 'sound/misc/machinetalk.ogg', 100, FALSE, -1)
			playsound(src, 'sound/misc/hiss.ogg', 100, FALSE, -1)
	if(findtext(message, "summon key"))
		if(nocrown)
			say("You need the crown.")
			playsound(src, 'sound/misc/machineno.ogg', 100, FALSE, -1)
			return
		if(!SSroguemachine.key)
			new /obj/item/roguekey/lord(src.loc)
			say("The key is summoned!")
			playsound(src, 'sound/misc/machinetalk.ogg', 100, FALSE, -1)
			playsound(src, 'sound/misc/hiss.ogg', 100, FALSE, -1)
		if(SSroguemachine.key)
			var/obj/item/roguekey/lord/I = SSroguemachine.key
			if(!I)
				I = new /obj/item/roguekey/lord(src.loc)
			if(I && !ismob(I.loc))
				I.anti_stall()
				I = new /obj/item/roguekey/lord(src.loc)
				say("The key is summoned!")
				playsound(src, 'sound/misc/machinetalk.ogg', 100, FALSE, -1)
				playsound(src, 'sound/misc/hiss.ogg', 100, FALSE, -1)
				return
			if(ishuman(I.loc))
				var/mob/living/carbon/human/HC = I.loc
				if(HC.stat != DEAD)
					say("[HC.real_name] holds the key!")
					playsound(src, 'sound/misc/machinetalk.ogg', 100, FALSE, -1)
					return
				else
					HC.dropItemToGround(I, TRUE) //If you're dead, forcedrop it, then move it.
			I.forceMove(src.loc)
			say("The key is summoned!")
			playsound(src, 'sound/misc/machinetalk.ogg', 100, FALSE, -1)
			playsound(src, 'sound/misc/hiss.ogg', 100, FALSE, -1)
	switch(mode)
		if(THROAT_MODE_DEFAULT)
			if(findtext(message, "secrets of the throat"))
				say("My commands are: Make Decree, Make Announcement, Set Taxes, Declare Outlaw, Summon Crown, Summon Key, Make Law, Remove Law, Purge Laws, Purge Decrees, Become Regent, Nevermind")
				playsound(src, 'sound/misc/machinelong.ogg', 100, FALSE, -1)
			if(findtext(message, "make announcement"))
				if(nocrown)
					say("You need the crown.")
					playsound(src, 'sound/misc/machineno.ogg', 100, FALSE, -1)
					return
				if(!SScommunications.can_announce(H))
					say("I must gather my strength!")
					return
				say("Speak and they will listen.")
				playsound(src, 'sound/misc/machineyes.ogg', 100, FALSE, -1)
				mode = THROAT_MODE_ANNOUNCEMENT
				return
			if(findtext(message, "make decree"))
				if(!SScommunications.can_announce(H))
					say("I must gather my strength!")
					playsound(src, 'sound/misc/machineno.ogg', 100, FALSE, -1)
					return
				if(notlord || nocrown)
					say("You are not my master!")
					playsound(src, 'sound/misc/machineno.ogg', 100, FALSE, -1)
					return
				say("Speak and they will obey.")
				playsound(src, 'sound/misc/machineyes.ogg', 100, FALSE, -1)
				mode = THROAT_MODE_DECREE
				return
			if(findtext(message, "purge decrees"))
				if(notlord || nocrown)
					say("You are not my master!")
					playsound(src, 'sound/misc/machineno.ogg', 100, FALSE, -1)
					return
				say("All decrees shall be purged!")
				playsound(src, 'sound/misc/machineyes.ogg', 100, FALSE, -1)
				purge_decrees()
				return
			if(findtext(message, "make law"))
				if(notlord || nocrown)
					say("You are not my master!")
					playsound(src, 'sound/misc/machineno.ogg', 100, FALSE, -1)
					return
				say("Speak and they will obey.")
				playsound(src, 'sound/misc/machineyes.ogg', 100, FALSE, -1)
				mode = THROAT_MODE_LAW
				return
			if(findtext(message, "remove law"))
				if(notlord || nocrown)
					say("You are not my master!")
					playsound(src, 'sound/misc/machineno.ogg', 100, FALSE, -1)
					return
				var/message_clean = replacetext(message, "remove law", "")
				var/law_index = text2num(message_clean) || 0
				if(!law_index || !GLOB.laws_of_the_land[law_index])
					say("That law doesn't exist!")
					return
				say("That law shall be gone!")
				playsound(src, 'sound/misc/machineyes.ogg', 100, FALSE, -1)
				remove_law(law_index)
				return
			if(findtext(message, "purge laws"))
				if(notlord || nocrown)
					say("You are not my master!")
					playsound(src, 'sound/misc/machineno.ogg', 100, FALSE, -1)
					return
				say("All laws shall be purged!")
				playsound(src, 'sound/misc/machineyes.ogg', 100, FALSE, -1)
				purge_laws()
				return
			if(findtext(message, "declare outlaw"))
				if(notlord || nocrown)
					say("You are not my master!")
					playsound(src, 'sound/misc/machineno.ogg', 100, FALSE, -1)
					return
				say("Who should be outlawed?")
				playsound(src, 'sound/misc/machinequestion.ogg', 100, FALSE, -1)
				mode = THROAT_MODE_OUTLAW
				return
			if(findtext(message, "set taxes"))
				if(notlord || nocrown)
					say("You are not my master!")
					playsound(src, 'sound/misc/machineno.ogg', 100, FALSE, -1)
					return
				say("The new tax percent shall be...")
				playsound(src, 'sound/misc/machinetalk.ogg', 100, FALSE, -1)
				give_tax_popup(H)
				return
			if(findtext(message, "become regent"))
				if(nocrown)
					say("You need the crown.")
					playsound(src, 'sound/misc/machineno.ogg', 100, FALSE, -1)
					return
				if(SSticker.rulermob && SSticker.rulermob == H) //failsafe for edge cases
					say("No others share the throne with you, master.")
					playsound(src, 'sound/misc/machinetalk.ogg', 100, FALSE, -1)
					SSticker.regentmob = null
					return
				if(SSticker.rulermob != null)
					say("The true lord is already present in the realm.")
					playsound(src, 'sound/misc/machineno.ogg', 100, FALSE, -1)
					return
				if(!(HAS_TRAIT(H, TRAIT_NOBLE)))
					say("You have not the noble blood to be regent.")
					playsound(src, 'sound/misc/machineno.ogg', 100, FALSE, -1)
					return
				if(HAS_TRAIT(H, TRAIT_OUTLANDER))
					say("You are too estranged from this realm to be regent.")
					playsound(src, 'sound/misc/machineno.ogg', 100, FALSE, -1)
					return
				if(SSticker.regentday == GLOB.dayspassed)
					say("A regent has already been declared this dae!")
					playsound(src, 'sound/misc/machineno.ogg', 100, FALSE, -1)
					return
				if(SSticker.regentmob == H)
					say("You are already the regent!")
					playsound(src, 'sound/misc/machineno.ogg', 100, FALSE, -1)
					return
				become_regent(H)
				return

		if(THROAT_MODE_ANNOUNCEMENT)
			make_announcement(H, raw_message)
			mode = THROAT_MODE_DEFAULT
		if(THROAT_MODE_DECREE)
			make_decree(H, raw_message)
			mode = THROAT_MODE_DEFAULT
		if(THROAT_MODE_OUTLAW)
			declare_outlaw(H, message)
			mode = THROAT_MODE_DEFAULT
		if(THROAT_MODE_LAW)
			if(!SScommunications.can_announce(speaker))
				return
			make_law(raw_message)
			mode = THROAT_MODE_DEFAULT

/obj/structure/roguemachine/titan/proc/give_tax_popup(mob/living/carbon/human/user)
	if(!Adjacent(user))
		return
	var/newtax = input(user, "Set a new tax percentage (1-99)", src, SStreasury.tax_value*100) as null|num
	if(newtax)
		if(!Adjacent(user))
			return
		if(findtext(num2text(newtax), "."))
			return
		newtax = CLAMP(newtax, 1, 99)
		SStreasury.tax_value = newtax / 100
		priority_announce("The new tax in Scarlet Reach shall be [newtax] percent.", "The Generous Lord Decrees", pick('sound/misc/royal_decree.ogg', 'sound/misc/royal_decree2.ogg'), "Captain")


/obj/structure/roguemachine/titan/proc/make_announcement(mob/living/user, raw_message)
	if(!SScommunications.can_announce(user))
		return
	try_make_rebel_decree(user)

	SScommunications.make_announcement(user, FALSE, raw_message)

/obj/structure/roguemachine/titan/proc/try_make_rebel_decree(mob/living/user)
	if(!SScommunications.can_announce(user))
		return
	var/datum/antagonist/prebel/P = user.mind?.has_antag_datum(/datum/antagonist/prebel)
	if(P)
		if(P.rev_team)
			if(P.rev_team.members.len < 3)
				to_chat(user, "<span class='warning'>I need more folk on my side to declare victory.</span>")
			else
				for(var/datum/objective/prebel/obj in user.mind.get_all_objectives())
					obj.completed = TRUE
				if(!SSmapping.retainer.head_rebel_decree)
					user.mind.adjust_triumphs(1)
				SSmapping.retainer.head_rebel_decree = TRUE

/obj/structure/roguemachine/titan/proc/make_decree(mob/living/user, raw_message)
	var/datum/antagonist/prebel/rebel_datum = user.mind?.has_antag_datum(/datum/antagonist/prebel)
	if(rebel_datum)
		if(rebel_datum.rev_team?.members.len < 3)
			to_chat(user, "<span class='warning'>I need more folk on my side to declare victory.</span>")
		else
			for(var/datum/objective/prebel/obj in user.mind.get_all_objectives())
				obj.completed = TRUE
			if(!SSmapping.retainer.head_rebel_decree)
				user.mind.adjust_triumphs(1)
			SSmapping.retainer.head_rebel_decree = TRUE
	record_round_statistic(STATS_LAWS_AND_DECREES_MADE)
	SScommunications.make_announcement(user, TRUE, raw_message)

/obj/structure/roguemachine/titan/proc/declare_outlaw(mob/living/user, raw_message)
	if(!SScommunications.can_announce(user))
		return
	return make_outlaw(raw_message, user)

/proc/make_outlaw(raw_message, mob/living/user, silent = FALSE)
	var/mob/living/carbon/human/outlaw
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(lowertext(H.real_name) == lowertext(raw_message))
			outlaw = H
	if(!outlaw)
		return FALSE
	if(outlaw.real_name in GLOB.outlawed_players)
		if(!silent)
			var/prompt = alert(user, "[outlaw.real_name] is already an outlaw, would you wish to declare them no longer an outlaw?", "DECLARE OUTLAW", "Yes", "No")
			if(prompt == "Yes")
				GLOB.outlawed_players -= outlaw.real_name
				priority_announce("[outlaw.real_name] is no longer an outlaw in the Scarlet Reach.", "The [SSticker.rulertype] Decrees", 'sound/misc/royal_decree.ogg', "Captain")
		else
			GLOB.outlawed_players -= outlaw.real_name
		return FALSE
	if(!silent)
		var/prompt = alert(user, "[outlaw.real_name] is not an outlaw, would you wish to declare them an outlaw?", "DECLARE OUTLAW", "Yes", "No")
		if(prompt == "Yes")
			GLOB.outlawed_players += outlaw.real_name
			priority_announce("[outlaw.real_name] has been declared an outlaw and must be captured or slain.", "The [SSticker.rulertype] Decrees", 'sound/misc/royal_decree2.ogg', "Captain")
		else
			return FALSE
	else
		GLOB.outlawed_players += outlaw.real_name
	return TRUE

/proc/make_law(raw_message)
	GLOB.laws_of_the_land += raw_message
	priority_announce("[length(GLOB.laws_of_the_land)]. [raw_message]", "A LAW IS DECLARED", pick('sound/misc/new_law.ogg', 'sound/misc/new_law2.ogg'), "Captain")
	record_round_statistic(STATS_LAWS_AND_DECREES_MADE)

/proc/remove_law(law_index)
	if(!GLOB.laws_of_the_land[law_index])
		return
	var/law_text = GLOB.laws_of_the_land[law_index]
	GLOB.laws_of_the_land -= law_text
	priority_announce("[law_index]. [law_text]", "A LAW IS ABOLISHED", pick('sound/misc/new_law.ogg', 'sound/misc/new_law2.ogg'), "Captain")
	record_round_statistic(STATS_LAWS_AND_DECREES_MADE, -1)

/proc/purge_laws()
	GLOB.laws_of_the_land = list()
	priority_announce("All laws of the land have been purged!", "LAWS PURGED", 'sound/misc/lawspurged.ogg', "Captain")

/proc/purge_decrees()
	GLOB.lord_decrees = list()
	priority_announce("All of the land's prior decrees have been purged!", "DECREES PURGED", pick('sound/misc/royal_decree.ogg', 'sound/misc/royal_decree2.ogg'), "Captain")

/proc/become_regent(mob/living/carbon/human/H)
	priority_announce("[H.name], the [H.get_role_title()], sits as the regent of the realm.", "A New Regent Resides", pick('sound/misc/royal_decree.ogg', 'sound/misc/royal_decree2.ogg'), "Captain")
	SSticker.regentmob = H
	SSticker.regentday = GLOB.dayspassed
