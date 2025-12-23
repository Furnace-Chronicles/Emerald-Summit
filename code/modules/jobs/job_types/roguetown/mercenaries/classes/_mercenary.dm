/datum/advclass/mercenary/post_equip(mob/living/carbon/human/H)
	. = ..()
	// Input sleeps. I do not want any equip to do that.
	INVOKE_ASYNC(H, GLOBAL_PROC_REF(merc_edit_posting), H)

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
