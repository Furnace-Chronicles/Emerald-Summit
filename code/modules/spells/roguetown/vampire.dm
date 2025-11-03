
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
