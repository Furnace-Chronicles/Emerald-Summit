/datum/intent/jump
	name = "jump"
	candodge = FALSE
	canparry = FALSE
	chargedrain = 0
	chargetime = 0
	noaa = TRUE
	pointer = 'icons/effects/mousemice/human_jump.dmi'

/datum/intent/jump/on_mmb(atom/target, mob/living/user, params)
	user.jump_action(target)
