/atom/movable/screen/alert/status_effect/psylove
	name = "PSYDON"
	desc = "PRAISE PSYDON!"
	icon_state = "stressvg"

/mob/living/carbon/human/proc/praise_psy()
	set name = "Praise Psydon!"
	set category = "PSYDON"
	if(!src.can_speak_vocal() || src.has_status_effect(/datum/status_effect/psylove))
		return //You can only do this if you can actually speak
	audible_message(span_orator("[src] praises <span class='bold'>Psydon</span>!"))
	src.add_stress(/datum/stressevent/overlord_heard)
	src.apply_status_effect(/datum/status_effect/psylove)
	var/list/shouts = list()

	if(should_wear_masc_clothes(src))
		shouts = list(
			'sound/vo/male/evil/psydon1.ogg',
			'sound/vo/male/evil/psydon2.ogg',
			'sound/vo/male/evil/psydon3.ogg')
	else if(should_wear_femme_clothes(src))
		shouts = list(
			'sound/vo/female/evil/psydon1.ogg',
			'sound/vo/female/evil/psydon2.ogg')
	else
		shouts = list(
			'sound/vo/male/evil/psydon1.ogg'
			)
	playsound(src.loc, pick(shouts), 100)
	if(src.has_flaw(/datum/charflaw/addiction/godfearing)) //PRAISE PSYDON!!!!
		src.sate_addiction()

/datum/status_effect/psylove // PRAISE PSYDON!!!!
	id = "psylove"
	alert_type = /atom/movable/screen/alert/status_effect/psylove
	status_type = STATUS_EFFECT_UNIQUE
	effectedstats = list("strength" = 1)
	duration = 10 SECONDS
