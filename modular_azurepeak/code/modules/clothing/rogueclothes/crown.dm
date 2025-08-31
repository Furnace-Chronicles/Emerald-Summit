#define GARRISON_CROWN_COLOR "#C2A245"

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
