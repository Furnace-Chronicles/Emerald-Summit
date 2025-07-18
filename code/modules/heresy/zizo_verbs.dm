//Call to the Overlord! Speak the profane words! 
//You can't stop Progress.
/atom/movable/screen/alert/status_effect/overlord
	name = "ZIZO"
	desc = "ZIZO HEARS ME!"
	icon_state = "stressvg"

/mob/living/carbon/human/proc/praise_zizo()
	set name = "Call to Overlord!"
	set category = "ZIZO"
	if(!src.can_speak_vocal() || src.has_status_effect(/datum/status_effect/overlord))
		return //You can only do this if you can actually speak
	audible_message(span_danger("[src] praises <span class='bold'>Zizo</span>!"))
	src.add_stress(/datum/stressevent/overlord_heard)
	src.apply_status_effect(/datum/status_effect/overlord)
	var/list/shouts = list(
		'sound/vo/cult/cultist1.ogg',
		'sound/vo/cult/cultist2.ogg',
		'sound/vo/cult/cultist3.ogg',
		'sound/vo/cult/cultist4.ogg',
		'sound/vo/cult/cultist5.ogg',
	)
	playsound(src.loc, pick(shouts), 100)
	if(src.has_flaw(/datum/charflaw/addiction/godfearing)) //Why yes, Zizoids enjoy shouting their praises to the Overlord
		src.sate_addiction()

/datum/status_effect/overlord //There are benefits to crying out to Zizo!
	id = "overlord"
	alert_type = /atom/movable/screen/alert/status_effect/overlord
	status_type = STATUS_EFFECT_UNIQUE
	effectedstats = list("strength" = 1)
	duration = 10 SECONDS

/datum/status_effect/overlord/on_apply()
	. = ..()
	owner.add_stress(/datum/stressevent/overlord_heard)
	if(owner.IsStun())
		owner.remove_status_effect(STATUS_EFFECT_STUN)

/datum/status_effect/overlord/on_remove()
	. = ..()
	owner.remove_stress(/datum/stressevent/overlord_heard)

/datum/stressevent/overlord_heard
	stressadd = -5
	desc = span_boldgreen("Zizo hears me!")
	timer = 10 SECONDS

/mob/living/carbon/human/proc/remember_associates()//It's a cult!
	set name = "Remember Fellow Qabalists"
	set category = "ZIZO"

	to_chat(src, span_boldwarning("Cultistes ov ZIZO"))
	to_chat(src, "\n")
	for(var/mob/living/carbon/human/C in GLOB.player_list)
		if(HAS_TRAIT(C, TRAIT_CABAL) || C.patron == /datum/patron/inhumen/zizo)
			var/name = C.real_name
			var/job = C.mind.assigned_role
			to_chat(src, span_italics("[name] - [job]"))


