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
	if(SSticker.current_state >= GAME_STATE_PLAYING)
		for(var/obj/structure/roguemachine/noticeboard/board in SSroguemachine.noticeboards)
			board.update_icon()
			playsound(board, 'sound/ambience/noises/birds (7).ogg', 50, FALSE, -1)
			board.visible_message(span_smallred("A ZAD lands, delivering a new posting!"))
