/datum/intent/bite
	name = "bite"
	candodge = TRUE
	canparry = TRUE
	chargedrain = 0
	chargetime = 0
	swingdelay = 0
	unarmed = TRUE
	noaa = FALSE
	animname = "bite"
	attack_verb = list("bites")

/datum/intent/bite/on_mmb(atom/target, mob/living/user, params)
	if(!target.Adjacent(user))
		return
	if(target == user)
		return
	if(user.incapacitated())
		return
	if(!get_location_accessible(user, BODY_ZONE_PRECISE_MOUTH, grabs="other"))
		to_chat(user, span_warning("My mouth is blocked."))
		return
	if(HAS_TRAIT(user, TRAIT_NO_BITE))
		to_chat(user, span_warning("I can't bite."))
		return
	user.changeNext_move(clickcd)
	user.face_atom(target)
	target.onbite(user)
	. = ..()
	return

/atom/proc/onbite(mob/user)
	return

/mob/living/onbite(mob/living/carbon/human/user)
	return

// Initial bite on target
// src is target
/mob/living/carbon/onbite(mob/living/carbon/human/user)
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, span_warning("I don't want to harm [src]!"))
		return FALSE
	
	if(!user.can_bite())
		to_chat(user, span_warning("My mouth has something in it."))
		return FALSE

	var/datum/intent/bite/bitten = new()
	if(checkdefense(bitten, user))
		return FALSE

	if(user.pulling != src)
		if(!lying_attack_check(user))
			return FALSE

	var/def_zone = check_zone(user.zone_selected)
	var/obj/item/bodypart/affecting = get_bodypart(def_zone)
	if(!affecting)
		to_chat(user, span_warning("Nothing to bite."))
		return

	next_attack_msg.Cut()

	user.do_attack_animation(src, "bite")
	playsound(user, 'sound/gore/flesh_eat_01.ogg', 100)
	var/nodmg = FALSE
	var/dam2do = 10*(user.STASTR/20)
	if(HAS_TRAIT(user, TRAIT_STRONGBITE))
		dam2do *= 2
	if(!HAS_TRAIT(user, TRAIT_STRONGBITE))
		if(!affecting.has_wound(/datum/wound/bite))
			nodmg = TRUE
	if(!nodmg)
		var/armor_block = run_armor_check(user.zone_selected, "stab",blade_dulling=BCLASS_BITE)
		if(!apply_damage(dam2do, BRUTE, def_zone, armor_block, user))
			nodmg = TRUE
			next_attack_msg += span_warning("Armor stops the damage.")

	var/datum/wound/caused_wound
	if(!nodmg)
		caused_wound = affecting.bodypart_attacked_by(BCLASS_BITE, dam2do, user, user.zone_selected, crit_message = TRUE)
	visible_message(span_danger("[user] bites [src]'s [parse_zone(user.zone_selected)]![next_attack_msg.Join()]"), \
					span_userdanger("[user] bites my [parse_zone(user.zone_selected)]![next_attack_msg.Join()]"))

	next_attack_msg.Cut()
	/*
		nodmg if they don't have an open wound
		nodmg if we don't have strongbite
		nodmg if our teeth can't break through their armour
	*/
	if(!nodmg)
		playsound(src, "smallslash", 100, TRUE, -1)
		if(ishuman(src) && user.mind)
			var/mob/living/carbon/human/bite_victim = src
			/*
				WEREWOLF INFECTION VIA BITE
			*/
			if(istype(user.dna.species, /datum/species/werewolf))
				if(HAS_TRAIT(src, TRAIT_SILVER_BLESSED))
					to_chat(user, span_warning("BLEH! [bite_victim] tastes of SILVER! My gift cannot take hold."))
				else
					caused_wound?.werewolf_infect_attempt()
					if(prob(30))
						user.werewolf_feed(bite_victim, 10)
			
			/*
				ZOMBIE INFECTION VIA BITE
			*/
			var/datum/antagonist/zombie/zombie_antag = user.mind.has_antag_datum(/datum/antagonist/zombie)
			if(zombie_antag && zombie_antag.has_turned)
				zombie_antag.last_bite = world.time
				if(bite_victim.zombie_infect_attempt())   // infect_attempt on bite
					to_chat(user, span_danger("You feel your gift trickling from your mouth into [bite_victim]'s wound..."))
				
	var/obj/item/grabbing/bite/B = new()
	user.equip_to_slot_or_del(B, SLOT_MOUTH)
	if(user.mouth == B)
		var/used_limb = src.find_used_grab_limb(user)
		B.name = "[src]'s [parse_zone(used_limb)]"
		var/obj/item/bodypart/BP = get_bodypart(check_zone(used_limb))
		BP.grabbedby += B
		B.grabbed = src
		B.grabbee = user
		B.limb_grabbed = BP
		B.sublimb_grabbed = used_limb

		lastattacker = user.real_name
		lastattackerckey = user.ckey
		if(mind)
			mind.attackedme[user.real_name] = world.time
		log_combat(user, src, "bit")
	return TRUE

// Checking if the unit can bite
/mob/living/carbon/human/proc/can_bite()
	// if(mouth?.muteinmouth && mouth?.type != /obj/item/grabbing/bite) // This one allows continued first biting rather than having to chew
	if(mouth?.muteinmouth)
		return FALSE
	for(var/obj/item/grabbing/grab in grabbedby) // Grabbed by the mouth
		if(grab.sublimb_grabbed == BODY_ZONE_PRECISE_MOUTH)
			return FALSE

	return TRUE
