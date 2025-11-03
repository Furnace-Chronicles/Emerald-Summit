
/obj/effect/proc_holder/spell/targeted/shapeshift/bat
	name = "Bat Form"
	desc = ""
	invocation = ""
	recharge_time = 50
	cooldown_min = 50
	die_with_shapeshifted_form =  FALSE
	shapeshift_type = /mob/living/simple_animal/hostile/retaliate/bat
	shifted_speed_increase = 1.25
	show_true_name = FALSE
	convert_damage = FALSE
	do_gibs = FALSE

/obj/effect/proc_holder/spell/targeted/shapeshift/gaseousform
	name = "Mist Form"
	desc = ""
	invocation = ""
	recharge_time = 50
	cooldown_min = 50
	die_with_shapeshifted_form =  FALSE
	shapeshift_type = /mob/living/simple_animal/hostile/retaliate/gaseousform
	convert_damage = FALSE
	do_gibs = FALSE

/obj/effect/proc_holder/spell/targeted/shapeshift/crow
	name = "Zad Form"
	overlay_state = "zad"
	desc = ""
	invocation = ""
	gesture_required = TRUE
	chargetime = 5 SECONDS
	recharge_time = 50
	cooldown_min = 50
	die_with_shapeshifted_form =  FALSE
	shapeshift_type = /mob/living/simple_animal/hostile/retaliate/bat/crow
	sound = 'sound/vo/mobs/bird/birdfly.ogg'
	shifted_speed_increase = 1.25
	show_true_name = FALSE
	convert_damage = FALSE
	do_gibs = FALSE

//This is pretty much a proc override for the base shape shift to remove the gib
/obj/effect/proc_holder/spell/targeted/shapeshift/crow/Shapeshift(mob/living/caster)
	var/obj/shapeshift_holder/H = locate() in caster
	if(H)
		to_chat(caster, span_warning("You're already shapeshifted!"))
		return

	var/mob/living/shape = new shapeshift_type(caster.loc)
	H = new(shape,src,caster)
	shape.name = "[shape] ([caster.real_name])"

	clothes_req = FALSE
	human_req = FALSE
	shape.see_in_dark = 8
	shape.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE


/obj/effect/proc_holder/spell/targeted/shapeshift/bat/Shapeshift(mob/living/caster)
	var/obj/shapeshift_holder/H = locate() in caster
	if(H)
		to_chat(caster, span_warning("You're already shapeshifted!"))
		return

	var/mob/living/shape = new shapeshift_type(caster.loc)
	H = new(shape,src,caster)
	shape.name = "[shape] ([caster.real_name])"

	clothes_req = FALSE
	human_req = FALSE
	shape.see_in_dark = 8
	shape.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE

/obj/effect/proc_holder/spell/self/regenerate
	name = "Regenerate"
	desc = ""
	invocation = ""
	recharge_time = 20 SECONDS
	overlay_icon = 'icons/mob/actions/genericmiracles.dmi'
	overlay_state = "woundheal"
	action_icon_state = "woundheal"
	action_icon = 'icons/mob/actions/genericmiracles.dmi'

/obj/effect/proc_holder/spell/self/regenerate/cast(list/targets, mob/living/carbon/human/user)
	. = ..()
	if(!ishuman(user))
		return
	if(user.has_status_effect(/datum/status_effect/fire_handler/fire_stacks/sunder) || user.has_status_effect(/datum/status_effect/fire_handler/fire_stacks/sunder/blessed))
		if(prob(50))
			to_chat(user, span_warning("I cannot regenerate while engulfed in holy fire!"))
		else
			to_chat(user, span_warning("Holy fire smothers my attempt to mend these wounds!"))
		return
	var/datum/antagonist/vampirelord/VD = user.mind.has_antag_datum(/datum/antagonist/vampirelord)
	if(VD)
		if(VD.disguised)
			to_chat(user, span_warning("My curse is hidden."))
			revert_cast()
			return
		if(VD.vitae < 600)
			to_chat(user, span_warning("Not enough vitae."))
			revert_cast()
			return
		to_chat(user, span_greentext("! REGENERATE !"))
		user.playsound_local(get_turf(user), 'sound/misc/vampirespell.ogg', 100, FALSE, pressure_affected = FALSE)
		VD.handle_vitae(-600)
		user.fully_heal()
		if(!VD.isstray)
			user.regenerate_limbs()
		else
			recharge_time = 5 MINUTES
		return


/obj/effect/proc_holder/spell/self/disguise
	name = "Disguise"
	desc = ""
	invocation = ""
	recharge_time = 30 SECONDS

/obj/effect/proc_holder/spell/self/disguise/cast(list/targets, mob/living/carbon/human/user)
	. = ..()
	if(!ishuman(user))
		return
	var/datum/antagonist/vampirelord/VD = user.mind.has_antag_datum(/datum/antagonist/vampirelord)
	if(!VD)
		return
	if(VD.disguised)
		VD.last_transform = world.time
		user.vampire_undisguise(VD)
	else
		if(VD.vitae < 100)
			to_chat(src, span_warning("I don't have enough Vitae!"))
			return
		VD.last_transform = world.time
		user.vampire_disguise(VD)
