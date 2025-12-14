/obj/effect/proc_holder/spell/targeted/shapeshift
	name = "Shapechange"
	desc = ""
	clothes_req = FALSE
	human_req = FALSE
	recharge_time = 200
	cooldown_min = 50
	range = -1
	include_user = TRUE
	invocation = "RAC'WA NO!"
	invocation_type = "shout"
	action_icon_state = "shapeshift"
	
	var/do_gibs = TRUE
	var/show_true_name = TRUE
	var/escape_grabs = FALSE  // Whether transformation can break free from grabs

	var/shifted_speed_increase = 1 // Applied as NEGATIVE multiplicative_slowdown, so 1.25 = 25% speed increase

	var/revert_on_death = TRUE
	var/knockout_on_death = 0 // we will apply this value (as deciseconds) to our host mob as a knockout effect when punted out of the form
	var/die_with_shapeshifted_form = TRUE
	var/convert_damage = TRUE // Convert caster's health to shift, and vice versa
	var/convert_damage_type = BRUTE // Simplemobs don't have advanced damagetypes

	var/shapeshift_type // Path to the mob type to transform into

/obj/effect/proc_holder/spell/targeted/shapeshift/cast(list/targets, mob/user = usr)
	. = ..()
	var/datum/antagonist/vampire/VD = usr?.mind?.has_antag_datum(/datum/antagonist/vampire)
	if(VD && SEND_SIGNAL(user, COMSIG_DISGUISE_STATUS))
		to_chat(usr, span_warning("My curse is hidden."))
		return
	if(usr.restrained(ignore_grab = FALSE))
		// Check if this transformation can escape grabs
		if(escape_grabs)
			// Free from all grabs before transforming
			for(var/obj/item/grabbing/G in usr.grabbedby)
				if(G.grabbee)
					G.grabbee.visible_message(span_warning("[usr] escapes out of [G.grabbee]'s grasp by transforming!"))
					G.grabbee.stop_pulling(FALSE)
				qdel(G)
		else
			to_chat(usr, span_warn("I am restrained, I can't shapeshift!"))
			revert_cast(usr)  // Refund cooldown since we didn't actually cast
			return
	if(src in user.mob_spell_list)
		user.mob_spell_list.Remove(src)
		user.mind.AddSpell(src)
	if(user.buckled)
		user.buckled.unbuckle_mob(src, force = TRUE)
	
	for(var/mob/living/M in targets)
		var/obj/shapeshift_holder/S = locate() in M
		if(S)
			Restore(M)
		else if(shapeshift_type)
			if(shapeshift_type == /mob/living/simple_animal/hostile/retaliate/gaseousform)
				spawn(100)
					Restore(M)
			Shapeshift(M)
			return TRUE
	return

/obj/effect/proc_holder/spell/targeted/shapeshift/proc/Shapeshift(mob/living/caster)
	var/obj/shapeshift_holder/H = locate() in caster
	if(H)
		to_chat(caster, span_warning("You're already shapeshifted!"))
		return
		
	// leave a track to indicate something's happened here
	var/obj/effect/track/the_evidence = new(caster.loc)
	the_evidence.handle_creation(caster)
	the_evidence.track_type = "mixture of shifted animal and humanoid tracks"
	the_evidence.ambiguous_track_type = "curious footprints"
	the_evidence.base_diff = 6 // very noticable

	var/mob/living/shape = new shapeshift_type(caster.loc)
	if(shifted_speed_increase && shifted_speed_increase != 1)
		shape.add_movespeed_modifier(type, update = TRUE, priority = 100, multiplicative_slowdown = -shifted_speed_increase)

	H = new(shape, src, caster)
	if(show_true_name)
		shape.name = "[shape] ([caster.real_name])"

	clothes_req = FALSE
	human_req = FALSE

	if(do_gibs)
		playsound(caster.loc, pick('sound/combat/gib (1).ogg','sound/combat/gib (2).ogg'), 200, FALSE, 3)
		caster.spawn_gibs(FALSE)

/obj/effect/proc_holder/spell/targeted/shapeshift/proc/Restore(mob/living/shape)
	var/obj/shapeshift_holder/H = locate() in shape
	if(!H)
		return

	H.restore()

	clothes_req = initial(clothes_req)
	human_req = initial(human_req)
