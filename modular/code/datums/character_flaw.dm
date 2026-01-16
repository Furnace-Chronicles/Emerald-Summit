/datum/charflaw/addiction/lovefiend
	name = "Nymphomaniac"
	desc = "I must make love!"
	time = 90 MINUTES
	needsate_text = "I'm feeling randy."

/datum/charflaw/addiction/baothancurse
	name = "Baothan Curse"
	desc = "I bear an indecent curse."
	time = 60 MINUTES
	needsate_text = "It comes again, the unbearable need..."

/datum/charflaw/addiction/baothancurse/on_mob_creation(mob/user)
	ADD_TRAIT(user, TRAIT_BAOTHA_FERTILITY_BOON, TRAIT_GENERIC)
	var/mob/living/carbon/human/H = user
	var/mutable_appearance/ma = mutable_appearance('icons/roguetown/misc/baotha_marking.dmi', "marking_m", -BODY_LAYER)
	user.overlays += ma
	user.update_body(H)
