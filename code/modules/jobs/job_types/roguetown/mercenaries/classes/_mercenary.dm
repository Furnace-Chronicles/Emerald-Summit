/// Buff applied to a merc while hired. Class-specific.
/datum/advclass/mercenary/var/hiredbuff = null

/datum/advclass/mercenary/post_equip(mob/living/carbon/human/H)
	. = ..()
	// Input sleeps. I do not want any equip to do that.
	INVOKE_ASYNC(H, GLOBAL_PROC_REF(merc_edit_posting), H)
	H.verbs += /mob/living/carbon/human/proc/hireme

/// Cooldown for calling hereme proc. Otherwise coal players will spam HIREMEE!!!
/mob/living/COOLDOWN_DECLARE(hireme_cooldown)
#define HIREME_COOLDOWN_DELAY (20 SECONDS)

/proc/merc_edit_posting(mob/living/carbon/human/H)
	var/inputmessage = stripped_multiline_input(H, "What shall I write my mercenary posting?", "MERCENARY", no_trim=TRUE)
	if(!inputmessage)
		return
	message_admins("[ADMIN_LOOKUPFLW(H)] has made a notice board post. The message was: [inputmessage]")
	add_post(
		message = inputmessage,
		chosentitle = "[H.real_name], [H.advjob]",
		chosenname = MERC_STATUS_AVAILABLE,
		chosenrole = MERC_STATUS_AVAILABLE,
		truename = H.real_name,
		category = NOTICEBOARD_CAT_SELLSWORDS,
		author = H
	)
	/// GLOBAL SIGNAL THIS, DUMB FUCK!!!
	SEND_GLOBAL_SIGNAL(COMSIG_NOTICEBOARD_POST_ADDED, null)

/mob/living/carbon/human/proc/hireme()
	set name = "~Mercenary. Hire Me!"
	set category = "IC"

	if(stat || !mind)
		return

	if(!COOLDOWN_FINISHED(src, hireme_cooldown))
		return FALSE

	var/list/folksnearby = list()
	for(var/mob/living/carbon/human/potential_employer in view(1))
		if(potential_employer == src || !potential_employer?.mind)
			continue

		folksnearby += potential_employer

	var/mob/living/carbon/human/employer = tgui_input_list(src, "Choose a potential employer", "MERCENARY", folksnearby)
	if(!employer?.mind)
		return

	COOLDOWN_START(src, hireme_cooldown, HIREME_COOLDOWN_DELAY)

	say("I am at your command, [employer]. For the right price.")
	var/prompt = tgui_alert(employer, "Do wish hire [src]?", "MERCENARY", list("MAKE IT SO", "I RESCIND"))
	if(prompt != "MAKE IT SO")
		return

	employer.say("You are hired, [src]!")
	say("I serve you, [employer]!")
	visible_message(span_warning("[src] shakes hands with the [employer]."))
	if(!do_after(employer, 5 SECONDS) || !employer?.mind?.add_mercenary(mind))
		to_chat(src, span_warning("I need to stand still to shake hands with my employer..."))
		to_chat(employer, span_warning("I need to stand still to shake hands with my mercenary..."))
		return

	employer.verbs += /mob/living/carbon/human/proc/listmercs
	employer.verbs += /mob/living/carbon/human/proc/firethem

	verbs -= /mob/living/carbon/human/proc/hireme
	verbs += /mob/living/carbon/human/proc/fireme
	verbs += /mob/living/carbon/human/proc/merccontract

/mob/living/carbon/human/proc/fireme()
	set name = "~Mercenary. Fire Me!"
	set category = "IC"

	if(stat)
		return

	var/datum/mind/employer = mind?.employer?.resolve()
	if(!employer || !employer?.current)
		to_chat(src, span_notice("I am not serving anyone right now."))

	var/prompt = tgui_alert(src, "Do you wish to void your contract with [employer.current.real_name]?", "MERCENARY", list("MAKE IT SO", "I RESCIND"))
	if(prompt != "MAKE IT SO")
		return

	employer?.remove_mercenary(mind)
	to_chat(employer, span_userdanger("Your mercenary, [real_name], has unilaterally broken their contract! Curses upon those sellswords!"))
	to_chat(src, span_userdanger("I'm no longer employed by [employer.current?.real_name]"))

/mob/living/carbon/human/proc/merccontract()
	set name = "~Mercenary. Contract info."
	set category = "IC"

	if(stat)
		return

	var/datum/mind/employer = mind?.employer?.resolve()
	if(!employer || !employer?.current)
		to_chat(src, span_notice("I am not serving anyone right now."))

	to_chat(src, span_notice("My current employer is [employer.current.real_name]."))

/mob/living/carbon/human/proc/firethem()
	set name = "~Mercenary. Fire a mercenary!"
	set category = "IC"

	if(stat)
		return

	if(!mind?.has_mercs_employed())
		to_chat(src, span_warning("I have no mercenaries under my employ!"))
		return

	var/list/mob/living/carbon/human/mercs = list()
	for(var/datum/mind/merc_mind in mind.get_mercenary_list())
		var/mob/living/carbon/human/merc = merc_mind.current
		if(get_dist(src, merc) > world.view)
			continue

		mercs += merc

	if(!mercs.len)
		to_chat(src, span_warning("No mercenaries are close enough to fire! I need to see them to tell them off..."))
		return

	var/mob/living/carbon/human/merc = tgui_input_list(src, "Choose a mercenary to fire", "MERCENARY", mercs)
	if(!merc)
		return

	say("You are dismissed, [merc].")
	mind.remove_mercenary(merc.mind)
	to_chat(merc, span_userdanger("My employer, [src], has voided our contract."))

/mob/living/carbon/human/proc/listmercs()
	set name = "~Mercenary. List mercenaries."
	set category = "IC"

	if(stat)
		return

	if(!mind?.has_mercs_employed())
		to_chat(src, span_warning("I have no mercenaries under my employ!"))
		return

	var/printf = "<b>The following sellswords are currently under my employ:</b>"
	for(var/datum/mind/merc_mind in mind.get_mercenary_list())
		var/mob/living/carbon/human/merc = merc_mind.current
		if(get_dist(src, merc) > world.view)
			continue

		printf += "<br>[merc.real_name]"

	to_chat(src, span_notice(printf))

#undef HIREME_COOLDOWN_DELAY
