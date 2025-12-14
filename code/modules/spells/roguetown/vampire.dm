/obj/effect/proc_holder/spell/targeted/shapeshift/vampire
	do_gibs = FALSE
	show_true_name = FALSE
	invocation_type = "shout"
	recharge_time = 30 SECONDS
	cooldown_min = 30 SECONDS
	die_with_shapeshifted_form = FALSE
	knockout_on_death = 0
	escape_grabs = TRUE  // Vampires can escape grabs when transforming

/obj/effect/proc_holder/spell/targeted/shapeshift/vampire/bat
	name = "Bat Form"
	desc = ""
	shapeshift_type = /mob/living/simple_animal/hostile/retaliate/bat

/obj/effect/proc_holder/spell/targeted/shapeshift/vampire/gaseousform
	name = "Mist Form"
	desc = ""
	gesture_required = FALSE // can transform while chained because mist bro
	shapeshift_type = /mob/living/simple_animal/hostile/retaliate/gaseousform

/obj/effect/proc_holder/spell/targeted/shapeshift/vampire/crow
	name = "Zad Form"
	overlay_state = "zad"
	desc = ""
	gesture_required = TRUE
	shapeshift_type = /mob/living/simple_animal/hostile/retaliate/bat/crow
	sound = 'sound/vo/mobs/bird/birdfly.ogg'

/obj/effect/proc_holder/spell/targeted/shapeshift/vampire/rat
	name = "Rat Form"
	desc = ""
	shapeshift_type = /mob/living/simple_animal/hostile/retaliate/smallrat

/obj/effect/proc_holder/spell/targeted/shapeshift/vampire/cabbit
	name = "Cabbit Form"
	desc = ""
	shapeshift_type = /mob/living/simple_animal/hostile/retaliate/rogue/mudcrab/cabbit
