///////////OFFHAND///////////////
/obj/item/grabbing
	name = "pulling"
	icon_state = "grabbing"
	icon = 'icons/mob/roguehudgrabs.dmi'
	w_class = WEIGHT_CLASS_HUGE
	possible_item_intents = list(/datum/intent/grab/upgrade)
	item_flags = ABSTRACT
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	grab_state = 0 //this is an atom/movable var i guess
	no_effect = TRUE
	force = 0
	experimental_inhand = FALSE
	var/grabbed				//ref to what atom we are grabbing
	var/obj/item/bodypart/limb_grabbed		//ref to actual bodypart being grabbed if we're grabbing a carbo
	var/sublimb_grabbed		//ref to what precise (sublimb) we are grabbing (if any) (text)
	var/mob/living/carbon/grabbee
	var/list/dependents = list()
	var/handaction
	var/bleed_suppressing = 0.25 //multiplier for how much we suppress bleeding, can accumulate so two grabs means 50% less bleeding; each grab being 25% basically.
	var/chokehold = FALSE

/obj/item/grabbing/Initialize(mapload/*= FALSE*/, mob/living/carbon/user, atom/movable/target)// i hope mapload is false
	if(mapload)
		CRASH("A grab item was spawned during mapload.")
	target.grabbedby += src
	grabbed = target
	grabbee = user
	name = null
	if(!iscarbon(target) && isliving(target))    
		var/mob/living/living_target = target
		sublimb_grabbed = living_target.simple_limb_hit(user.zone_selected)
		user.visible_message(
			span_danger("[user] grabs [living_target]!"),
			span_danger("I grab [target]!"),
			ignored_mobs = list(living_target), runechat_message = "grabs [target]!")
		to_chat(target, span_userdanger("[user] grabs me!"))
	else if(iscarbon(target))
		var/mob/living/carbon/carbon_target = target
		var/zone_name = parse_zone(user.zone_selected)
		var/obj/item/bodypart/part_grabbed = carbon_target.get_bodypart(user.zone_selected)
		name = "[carbon_target]'s [zone_name]"
		sublimb_grabbed = user.zone_selected
		limb_grabbed = part_grabbed
		part_grabbed.grabbedby += src
		if(target == user)
			user.visible_message(
				span_bignotice("[user] grabs [user.p_their()] own [zone_name]."),
				span_notice("I grab my [zone_name]."))
		else
			user.visible_message(
				span_danger("[user] grabs [carbon_target]'s [zone_name]!"),
				span_danger("I grab [carbon_target]'s [zone_name]!"),
				ignored_mobs = list(carbon_target))
			to_chat(target, span_userdanger("[user] grabs my [zone_name]!"))
	else
		user.visible_message(span_notice("[user] grabs hold of [target]."))
	name = name ? name : "[target.name]"
	user.put_in_hands(src)
	update_hands(user)
	START_PROCESSING(SSfastprocess, src)
	. = ..()

/obj/item/grabbing/process()
	valid_check()

/obj/item/grabbing/proc/valid_check()
	// We require adjacency to count the grab as valid
	if(grabbee.Adjacent(grabbed))
		return TRUE
	grabbee.stop_pulling(FALSE)
	qdel(src)
	return FALSE

/obj/item/grabbing/Click(location, control, params)
	var/list/modifiers = params2list(params)
	if(iscarbon(usr))
		var/mob/living/carbon/C = usr
		if(C != grabbee)
			qdel(src)
			return 1
		if(modifiers["right"])
			qdel(src)
			return 1
	return ..()

/obj/item/grabbing/proc/update_hands(mob/living/carbon/user)
	if(!user)
		return
	for(var/i in 1 to length(user.held_items))
		var/obj/item/held = user.get_item_for_held_index(i)
		if(held != src)
			continue
		if(i == 1)
			user.r_grab = src
		else
			user.l_grab = src

/datum/proc/grabdropped(obj/item/grabbing/G)
	if(G)
		for(var/datum/D in G.dependents)
			if(D == src)
				G.dependents -= D

/obj/item/grabbing/proc/relay_cancel_action()
	if(handaction)
		for(var/datum/D in dependents) //stop fapping
			if(handaction == D)
				D.grabdropped(src)
		handaction = null

/obj/item/grabbing/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	if(isobj(grabbed))
		var/obj/I = grabbed
		I.grabbedby -= src
	if(ismob(grabbed))
		var/mob/M = grabbed
		M.grabbedby -= src
		if(iscarbon(M) && sublimb_grabbed)
			var/mob/living/carbon/carbonmob = M
			var/obj/item/bodypart/part = carbonmob.get_bodypart(sublimb_grabbed)

			// Edge case: if a weapon becomes embedded in a mob, our "grab" will be destroyed...
			// In this case, grabbed will be the mob, and sublimb_grabbed will be the weapon, rather than a bodypart
			// This means we should skip any further processing for the bodypart
			if(part)
				part.grabbedby -= src
				part = null
				sublimb_grabbed = null
	if(isturf(grabbed))
		var/turf/T = grabbed
		T.grabbedby -= src
	if(grabbee)
		if(grabbee.r_grab == src)
			grabbee.r_grab = null
		if(grabbee.l_grab == src)
			grabbee.l_grab = null
		if(grabbee.mouth == src)
			grabbee.mouth = null
	for(var/datum/D in dependents)
		D.grabdropped(src)
	return ..()

/obj/item/grabbing/dropped(mob/living/user, show_message = TRUE)
	SHOULD_CALL_PARENT(FALSE)
	// Dont stop the pull if another hand grabs the person
	if(user.r_grab == src)
		if(user.l_grab && user.l_grab.grabbed == user.r_grab.grabbed)
			qdel(src)
			return
	if(user.l_grab == src)
		if(user.r_grab && user.r_grab.grabbed == user.l_grab.grabbed)
			qdel(src)
			return
	if(grabbed == user.pulling)
		user.stop_pulling(FALSE)
	if(!user.pulling)
		user.stop_pulling(FALSE)
	for(var/mob/M in user.buckled_mobs)
		if(M == grabbed)
			user.unbuckle_mob(M, force = TRUE)
	if(QDELETED(src))
		return
	qdel(src)

/mob/living/carbon/human
	var/mob/living/carbon/human/hostagetaker //Stores the person that took us hostage in a var, allows us to force them to attack the mob and such
	var/mob/living/carbon/human/hostage //What hostage we have

/mob/living/carbon/human/proc/attackhostage()
	if(!istype(hostagetaker.get_active_held_item(), /obj/item/rogueweapon))
		return
	var/obj/item/rogueweapon/WP = hostagetaker.get_active_held_item()
	WP.attack(src, hostagetaker)
	hostagetaker.visible_message("<span class='danger'>\The [hostagetaker] attacks \the [src] reflexively!</span>")
	hostagetaker.hostage = null
	hostagetaker = null

/obj/item/grabbing/attack(mob/living/M, mob/living/user)
	if(M != grabbed)
		if(!istype(limb_grabbed, /obj/item/bodypart/head))
			return FALSE
		if(M != user)
			return FALSE
		if(!user.cmode)
			return FALSE
		user.changeNext_move(CLICK_CD_RESIST)
		headbutt(user)
		return
	if(!valid_check())
		return FALSE
	user.changeNext_move(CLICK_CD_MELEE * 2 - user.STASPD) // 24 - the user's speed

	var/skill_diff = 0
	var/combat_modifier = 1
	if(user.mind)
		skill_diff += (user.get_skill_level(/datum/skill/combat/wrestling))
	if(M.mind)
		skill_diff -= (M.get_skill_level(/datum/skill/combat/wrestling))
	if(HAS_TRAIT(M, TRAIT_GRABIMMUNE))
		if(M.cmode)
			to_chat(user, span_warning("Can't get a grip on this one!"))
			return

	if(M.compliance || M.surrendering)
		combat_modifier = 2

	if(M.restrained())
		combat_modifier += 0.25

	if(!(M.mobility_flags & MOBILITY_STAND) && user.mobility_flags & MOBILITY_STAND)
		combat_modifier += 0.05

	if(user.cmode && !M.cmode)
		combat_modifier += 0.3
	
	else if(!user.cmode && M.cmode)
		combat_modifier -= 0.3

	if(sublimb_grabbed == BODY_ZONE_PRECISE_NECK && grab_state > 0) //grabbing aggresively the neck
		if(user && (M.dir == turn(get_dir(M,user), 180))) //is behind the grabbed
			chokehold = TRUE

	if(chokehold)
		combat_modifier += 0.15

	switch(user.used_intent.type)
		if(/datum/intent/grab/upgrade)
			if(!(M.status_flags & CANPUSH) || HAS_TRAIT(M, TRAIT_PUSHIMMUNE))
				to_chat(user, span_warning("Can't get a grip!"))
				return FALSE
			user.stamina_add(rand(7,15))
			if(M.grippedby(user))			//Aggro grip
				bleed_suppressing = 0.5		//Better bleed suppression
		if(/datum/intent/grab/choke)
			if(user.buckled)
				to_chat(user, span_warning("I can't do this while buckled!"))
				return FALSE
			if(limb_grabbed && grab_state > 0) //this implies a carbon victim
				if(iscarbon(M) && M != user)
					user.stamina_add(rand(1,3))
					var/mob/living/carbon/C = M
					if(get_location_accessible(C, BODY_ZONE_PRECISE_NECK))
						if(prob(25))
							C.emote("choke")
						var/choke_damage
						if(user.STASTR > STRENGTH_SOFTCAP)
							choke_damage = STRENGTH_SOFTCAP
						else
							choke_damage = user.STASTR * 0.75
						if(chokehold)
							choke_damage *= 1.2		//Slight bonus
						if(C.pulling == user && C.grab_state >= GRAB_AGGRESSIVE)
							choke_damage *= 0.95	//Slight malice
						C.adjustOxyLoss(choke_damage)
						C.visible_message(span_danger("[user] [pick("chokes", "strangles")] [C][chokehold ? " with a chokehold" : ""]!"), \
								span_userdanger("[user] [pick("chokes", "strangles")] me[chokehold ? " with a chokehold" : ""]!"), span_hear("I hear a sickening sound of pugilism!"), COMBAT_MESSAGE_RANGE, user)
						to_chat(user, span_danger("I [pick("choke", "strangle")] [C][chokehold ? " with a chokehold" : ""]!"))
					else
						to_chat(user, span_warning("I can't reach [C]'s throat!"))
					user.changeNext_move(CLICK_CD_GRABBING)	//Stops spam for choking.
		if(/datum/intent/grab/hostage)
			if(user.buckled)
				to_chat(user, span_warning("I can't do this while buckled!"))
				return FALSE
			if(limb_grabbed && grab_state > GRAB_PASSIVE) //this implies a carbon victim
				if(ishuman(M) && M != user)
					var/mob/living/carbon/human/H = M
					var/mob/living/carbon/human/U = user
					if(U.cmode)
						if(H.cmode)
							to_chat(U, "<span class='warning'>[H] is too prepared for combat to be taken hostage.</span>")
							return
						to_chat(U, "<span class='warning'>I take [H] hostage.</span>")
						to_chat(H, "<span class='danger'>[U] takes us hostage!</span>")

						U.swap_hand() // Swaps hand to weapon so you can attack instantly if hostage decides to resist

						U.hostage = H
						H.hostagetaker = U
		if(/datum/intent/grab/twist)
			if(user.buckled)
				to_chat(user, span_warning("I can't do this while buckled!"))
				return FALSE
			if(limb_grabbed && grab_state > 0) //this implies a carbon victim
				if(iscarbon(M))
					user.stamina_add(rand(3,8))
					twistlimb(user)
		if(/datum/intent/grab/twistitem)
			if(user.buckled)
				to_chat(user, span_warning("I can't do this while buckled!"))
				return FALSE
			if(limb_grabbed && grab_state > 0) //this implies a carbon victim
				if(ismob(M))
					user.stamina_add(rand(3,8))
					twistitemlimb(user)
		if(/datum/intent/grab/remove)
			if(user.buckled)
				to_chat(user, span_warning("I can't do this while buckled!"))
				return FALSE
			user.stamina_add(rand(3,13))
			if(isitem(sublimb_grabbed))
				removeembeddeditem(user)
			else
				user.stop_pulling()
		if(/datum/intent/grab/shove)
			if(user.buckled)
				to_chat(user, span_warning("I can't do this while buckled!"))
				return FALSE
			if(!(user.mobility_flags & MOBILITY_STAND))
				to_chat(user, span_warning("I must stand.."))
				return
			if(!(M.mobility_flags & MOBILITY_STAND))
				if(user.loc != M.loc)
					to_chat(user, span_warning("I must be above them."))
					return
				var/stun_dur = max(((65 + (skill_diff * 10) + (user.STASTR * 5) - (M.STASTR * 5)) * combat_modifier), 20)
				var/pincount = 0
				user.stamina_add(rand(1,3))
				while(M == grabbed && !(M.mobility_flags & MOBILITY_STAND) && (src in M.grabbedby))
					if(M.IsStun())
						if(!do_after(user, stun_dur + 1, needhand = 0, target = M))
							pincount = 0
							qdel(src)
							break
						if(!(src in M.grabbedby))
							pincount = 0
							qdel(src)
							break
						M.Stun(stun_dur - pincount * 2)	
						M.Immobilize(stun_dur)	//Made immobile for the whole do_after duration, though
						user.stamina_add(rand(1,3) + abs(skill_diff) + stun_dur / 1.5)
						M.visible_message(span_danger("[user] keeps [M] pinned to the ground!"))
						pincount += 2
					else if(src in M.grabbedby)
						M.Stun(stun_dur - 10)
						M.Immobilize(stun_dur)
						user.stamina_add(rand(1,3) + abs(skill_diff) + stun_dur / 1.5)
						pincount += 2
						M.visible_message(span_danger("[user] pins [M] to the ground!"), \
							span_userdanger("[user] pins me to the ground!"), span_hear("I hear a sickening sound of pugilism!"), COMBAT_MESSAGE_RANGE)
			else
				user.stamina_add(rand(5,15))
				if(M.compliance || prob(clamp((((4 + (((user.STASTR - M.STASTR)/2) + skill_diff)) * 10 + rand(-5, 5)) * combat_modifier), 5, 95)))
					M.visible_message(span_danger("[user] shoves [M] to the ground!"), \
									span_userdanger("[user] shoves me to the ground!"), span_hear("I hear a sickening sound of pugilism!"), COMBAT_MESSAGE_RANGE)
					M.Knockdown(max(10 + (skill_diff * 2), 1))
				else
					M.visible_message(span_warning("[user] tries to shove [M]!"), \
									span_danger("[user] tries to shove me!"), span_hear("I hear a sickening sound of pugilism!"), COMBAT_MESSAGE_RANGE)

/obj/item/grabbing/proc/twistlimb(mob/living/user) //implies limb_grabbed and sublimb are things
	var/mob/living/carbon/C = grabbed
	var/armor_block = C.run_armor_check(limb_grabbed, "slash")
	var/damage = user.get_punch_dmg()
	playsound(C.loc, "genblunt", 100, FALSE, -1)
	C.next_attack_msg.Cut()
	if(isdoll(C)) {
		armor_block = C.getarmor(sublimb_grabbed, "blunt")
		if(armor_block < 1)
			
		else
		
			C.apply_damage(damage, BRUTE, limb_grabbed, armor_block)
	}
	else {
	
		armor_block = C.run_armor_check(limb_grabbed, "slash")
		C.apply_damage(damage, BRUTE, limb_grabbed, armor_block)
	}	
		
	limb_grabbed.bodypart_attacked_by(BCLASS_TWIST, damage, user, sublimb_grabbed, crit_message = TRUE)
	C.visible_message(span_danger("[user] twists [C]'s [parse_zone(sublimb_grabbed)]![C.next_attack_msg.Join()]"), \
					span_userdanger("[user] twists my [parse_zone(sublimb_grabbed)]![C.next_attack_msg.Join()]"), span_hear("I hear a sickening sound of pugilism!"), COMBAT_MESSAGE_RANGE, user)
	to_chat(user, span_warning("I twist [C]'s [parse_zone(sublimb_grabbed)].[C.next_attack_msg.Join()]"))
	C.next_attack_msg.Cut()
	log_combat(user, C, "limbtwisted [sublimb_grabbed] ")
	if(limb_grabbed.status == BODYPART_ROBOTIC && armor_block == 0) //Twisting off prosthetics.
		C.visible_message(span_danger("[C]'s prosthetic [parse_zone(sublimb_grabbed)] twists off![C.next_attack_msg.Join()]"), \
					span_userdanger("My prosthetic [parse_zone(sublimb_grabbed)] was twisted off of me![C.next_attack_msg.Join()]"), span_hear("I hear a sickening sound of pugilism!"), COMBAT_MESSAGE_RANGE, user)
		to_chat(user, span_warning("I twisted [C]'s prosthetic [parse_zone(sublimb_grabbed)] off.[C.next_attack_msg.Join()]"))
		limb_grabbed.drop_limb(TRUE)

	if(limb_grabbed.body_zone == sublimb_grabbed && isdoll(C))
		var/mob/living/carbon/human/target = C
		armor_block = target.getarmor(sublimb_grabbed, "slash")
		
		if(armor_block >= 1)
			target.visible_message(span_danger("[target]'s [parse_zone(sublimb_grabbed)] fails to be twisted off!"), \
				span_danger("[user] Tries to twist my [parse_zone(sublimb_grabbed)] out of it's socket but the armor keeps it in place!"))
			to_chat(user, span_warning("[target]'s [parse_zone(sublimb_grabbed)] stays in it's socket because of [target]'s armor!"))
			return

		target.visible_message(span_danger("[target]'s [parse_zone(sublimb_grabbed)] is being forcefully popped out of socket!"), \
			span_danger("My [parse_zone(sublimb_grabbed)] is being forcefully popped out of socket!"))
		to_chat(user, span_warning("I begin popping [target]'s [parse_zone(sublimb_grabbed)] out of socket."))

		var/delay = (sublimb_grabbed == BODY_ZONE_HEAD) ? 100 : 6
		
		if(do_after(user, delay, target = target))
			target.visible_message(span_danger("[target]'s [parse_zone(sublimb_grabbed)] has been popped out of socket!"), \
				span_userdanger("My [parse_zone(sublimb_grabbed)] has been popped out of socket!"))
			to_chat(user, span_warning("I pop [target]'s [parse_zone(sublimb_grabbed)] out of socket."))

			limb_grabbed.drop_limb(FALSE)

			if(QDELETED(limb_grabbed))
				return

			qdel(src)
			user.put_in_active_hand(limb_grabbed)
      
  // Dealing damage to the head beforehand is intentional.
	if(limb_grabbed.body_zone == BODY_ZONE_HEAD && isdullahan(C))
		var/mob/living/carbon/human/target = C
		var/datum/species/dullahan/target_species = target.dna.species
		var/obj/item/equipped_nodrop = target_species.get_nodrop_head()
		if(equipped_nodrop)
			target.visible_message(span_danger("[target]'s head fails to be twisted off!"), \
				span_danger("[user] Tries to twist my head off but the [equipped_nodrop.name] keeps it bound to my neck!"))
			to_chat(user, span_warning("[target]'s head stays bound to their neck because of the [equipped_nodrop.name]!"))
			return

		target.visible_message(span_danger("[target]'s head is being forcefully twisted off!"), \
			span_danger("My head is being forcefully twisted off!"))
		to_chat(user, span_warning("I begin twisting [target]'s head off."))

		if(do_after(user, 6, target = target))
			target.visible_message(span_danger("[target]'s head has been twisted off!"), \
				span_userdanger("My head was twisted off!"))
			to_chat(user, span_warning("I twist [target]'s head off."))

			limb_grabbed.drop_limb(FALSE)

			if(QDELETED(limb_grabbed))
				return

			qdel(src)
			user.put_in_active_hand(limb_grabbed)
      
/obj/item/grabbing/proc/headbutt(mob/living/carbon/human/H)
	var/mob/living/carbon/C = grabbed
	var/obj/item/bodypart/Chead = C.get_bodypart(BODY_ZONE_HEAD)
	var/obj/item/bodypart/Hhead = H.get_bodypart(BODY_ZONE_HEAD)
	var/armor_block = C.run_armor_check(Chead, "blunt")
	var/armor_block_user = H.run_armor_check(Hhead, "blunt")
	var/damage = H.get_punch_dmg()
	C.next_attack_msg.Cut()
	playsound(C.loc, "genblunt", 100, FALSE, -1)
	C.apply_damage(damage*1.5, , Chead, armor_block)
	Chead.bodypart_attacked_by(BCLASS_SMASH, damage*1.5, H, crit_message=TRUE)
	H.apply_damage(damage, BRUTE, Hhead, armor_block_user)
	Hhead.bodypart_attacked_by(BCLASS_SMASH, damage/1.2, H, crit_message=TRUE)
	C.stop_pulling(TRUE)
	C.Immobilize(10)
	C.OffBalance(10)
	H.Immobilize(5)
	C.visible_message("<span class='danger'>[H] headbutts [C]'s [parse_zone(sublimb_grabbed)]![C.next_attack_msg.Join()]</span>", \
					"<span class='userdanger'>[H] headbutts my [parse_zone(sublimb_grabbed)]![C.next_attack_msg.Join()]</span>", "<span class='hear'>I hear a sickening sound of pugilism!</span>", COMBAT_MESSAGE_RANGE, H)
	to_chat(H, "<span class='warning'>I headbutt [C]'s [parse_zone(sublimb_grabbed)].[C.next_attack_msg.Join()]</span>")
	C.next_attack_msg.Cut()
	log_combat(H, C, "headbutted ")

/obj/item/grabbing/proc/twistitemlimb(mob/living/user) //implies limb_grabbed and sublimb are things
	var/mob/living/M = grabbed
	var/damage = rand(5,10)
	var/obj/item/I = sublimb_grabbed
	playsound(M.loc, "genblunt", 100, FALSE, -1)
	M.apply_damage(damage, BRUTE, limb_grabbed)
	M.visible_message(span_danger("[user] twists [I] in [M]'s wound!"), \
					span_userdanger("[user] twists [I] in my wound!"), span_hear("I hear a sickening sound of pugilism!"), COMBAT_MESSAGE_RANGE)
	log_combat(user, M, "itemtwisted [sublimb_grabbed] ")

/obj/item/grabbing/proc/removeembeddeditem(mob/living/user) //implies limb_grabbed and sublimb are things
	var/mob/living/M = grabbed
	var/obj/item/bodypart/L = limb_grabbed
	playsound(M.loc, "genblunt", 100, FALSE, -1)
	log_combat(user, M, "itemremovedgrab [sublimb_grabbed] ")
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		var/obj/item/I = locate(sublimb_grabbed) in L.embedded_objects
		if(QDELETED(I) || QDELETED(L) || !L.remove_embedded_object(I))
			return FALSE
		L.receive_damage(I.embedding.embedded_unsafe_removal_pain_multiplier*I.w_class) //It hurts to rip it out, get surgery you dingus.
		user.dropItemToGround(src) // this will unset vars like limb_grabbed
		user.put_in_hands(I)
		C.emote("paincrit", TRUE)
		playsound(C, 'sound/foley/flesh_rem.ogg', 100, TRUE, -2)
		if(usr == src)
			user.visible_message(span_notice("[user] rips [I] out of [user.p_their()] [L.name]!"), span_notice("I rip [I] from my [L.name]."))
		else
			user.visible_message(span_notice("[user] rips [I] out of [C]'s [L.name]!"), span_notice("I rip [I] from [C]'s [L.name]."))
	else if(HAS_TRAIT(M, TRAIT_SIMPLE_WOUNDS))
		var/obj/item/I = locate(sublimb_grabbed) in M.simple_embedded_objects
		if(QDELETED(I) || !M.simple_remove_embedded_object(I))
			return FALSE
		M.apply_damage(I.embedding.embedded_unsafe_removal_pain_multiplier*I.w_class, BRUTE) //It hurts to rip it out, get surgery you dingus.
		user.dropItemToGround(src) // this will unset vars like limb_grabbed
		user.put_in_hands(I)
		M.emote("paincrit", TRUE)
		playsound(M, 'sound/foley/flesh_rem.ogg', 100, TRUE, -2)
		if(user == M)
			user.visible_message(span_notice("[user] rips [I] out of [user.p_them()]self!"), span_notice("I remove [I] from myself."))
		else
			user.visible_message(span_notice("[user] rips [I] out of [M]!"), span_notice("I rip [I] from [src]."))
	user.update_grab_intents(grabbed)
	return TRUE

/obj/item/grabbing/attack_turf(turf/T, mob/living/user)
	if(!valid_check())
		return
	user.changeNext_move(CLICK_CD_GRABBING)
	switch(user.used_intent.type)
		if(/datum/intent/grab/move)
			if(isturf(T))
				user.Move_Pulled(T)
		if(/datum/intent/grab/smash)
			if(!(user.mobility_flags & MOBILITY_STAND))
				to_chat(user, span_warning("I must stand.."))
				return
			if(limb_grabbed && grab_state > 0) //this implies a carbon victim
				if(isopenturf(T))
					if(iscarbon(grabbed))
						var/mob/living/carbon/C = grabbed
						if(!C.Adjacent(T))
							return FALSE
						if(C.mobility_flags & MOBILITY_STAND)
							return
						playsound(C.loc, T.attacked_sound, 100, FALSE, -1)
						smashlimb(T, user)
				else if(isclosedturf(T))
					if(iscarbon(grabbed))
						var/mob/living/carbon/C = grabbed
						if(!C.Adjacent(T))
							return FALSE
						if(!(C.mobility_flags & MOBILITY_STAND))
							return
						playsound(C.loc, T.attacked_sound, 100, FALSE, -1)
						smashlimb(T, user)

/obj/item/grabbing/attack_obj(obj/O, mob/living/user)
	if(!valid_check())
		return
	user.changeNext_move(CLICK_CD_GRABBING)
	if(user.used_intent.type == /datum/intent/grab/smash)
		if(isstructure(O) && O.blade_dulling != DULLING_CUT)
			if(!(user.mobility_flags & MOBILITY_STAND))
				to_chat(user, span_warning("I must stand.."))
				return
			if(limb_grabbed && grab_state > 0) //this implies a carbon victim
				if(iscarbon(grabbed))
					var/mob/living/carbon/C = grabbed
					if(!C.Adjacent(O))
						return FALSE
					playsound(C.loc, O.attacked_sound, 100, FALSE, -1)
					smashlimb(O, user)


/obj/item/grabbing/proc/smashlimb(atom/A, mob/living/user) //implies limb_grabbed and sublimb are things
	var/mob/living/carbon/C = grabbed
	var/armor_block = C.run_armor_check(limb_grabbed, d_type, armor_penetration = BLUNT_DEFAULT_PENFACTOR)
	var/damage = user.get_punch_dmg()
	var/unarmed_skill = user.get_skill_level(/datum/skill/combat/unarmed)
	damage *= (1 + (unarmed_skill / 10))	//1.X multiplier where X is the unarmed skill.
	C.next_attack_msg.Cut()
	if(C.apply_damage(damage, BRUTE, limb_grabbed, armor_block))
		limb_grabbed.bodypart_attacked_by(BCLASS_BLUNT, damage, user, sublimb_grabbed, crit_message = TRUE)
		playsound(C.loc, "smashlimb", 100, FALSE, -1)
	else
		C.next_attack_msg += " <span class='warning'>Armor stops the damage.</span>"
	C.visible_message(span_danger("[user] smashes [C]'s [limb_grabbed] into [A]![C.next_attack_msg.Join()]"), \
					span_userdanger("[user] smashes my [limb_grabbed] into [A]![C.next_attack_msg.Join()]"), span_hear("I hear a sickening sound of pugilism!"), COMBAT_MESSAGE_RANGE, user)
	to_chat(user, span_warning("I smash [C]'s [limb_grabbed] against [A].[C.next_attack_msg.Join()]"))
	C.next_attack_msg.Cut()
	log_combat(user, C, "limbsmashed [limb_grabbed] ")

/datum/intent/grab
	unarmed = TRUE
	chargetime = 0
	noaa = TRUE
	candodge = FALSE
	canparry = FALSE
	no_attack = TRUE
	misscost = 2
	releasedrain = 2

/datum/intent/grab/move
	name = "grab move"
	desc = ""
	icon_state = "inmove"

/datum/intent/grab/upgrade
	name = "upgrade grab"
	desc = ""
	icon_state = "ingrab"

/datum/intent/grab/smash
	name = "smash"
	desc = ""
	icon_state = "insmash"

/datum/intent/grab/twist
	name = "twist"
	desc = ""
	icon_state = "intwist"

/datum/intent/grab/choke
	name = "choke"
	desc = ""
	icon_state = "inchoke"

/datum/intent/grab/hostage
	name = "hostage"
	desc = ""
	icon_state = "inhostage"

/datum/intent/grab/shove
	name = "shove"
	desc = ""
	icon_state = "intackle"

/datum/intent/grab/twistitem
	name = "twist in wound"
	desc = ""
	icon_state = "intwist"

/datum/intent/grab/remove
	name = "remove"
	desc = ""
	icon_state = "intake"

/mob/living/proc/grabbedby(mob/living/carbon/user, supress_message = FALSE, item_override)
	if(!user || !src || anchored || !isturf(user.loc))
		return FALSE

	if(!user.pulling || user.pulling == src)
		user.start_pulling(src, supress_message = supress_message)
		return

/mob/living/start_pulling(atom/movable/AM, state, force = pull_force, supress_message = FALSE)
	if(!AM || !src)
		return FALSE
	if(!(AM.can_be_pulled(src, state, force)))
		return FALSE
	if(throwing || !(mobility_flags & MOBILITY_PULL))
		return FALSE

	AM.add_fingerprint(src)

	// If we're pulling something then drop what we're currently pulling and pull this instead.
	if(pulling && AM != pulling)
		stop_pulling()

	changeNext_move(CLICK_CD_GRABBING)

	if(AM != src)
		pulling = AM
		AM.pulledby = src
	update_pull_hud_icon()

	wiggle(AM)
	if(isliving(AM))
		. = grab_living(AM)
		set_pull_offsets(AM, state)
	else if (isobj(AM))
		. = grab_obj(AM)
		if(.)
			update_grab_intents()
	if(!.)
		return
	if(!supress_message)
		var/sound_to_play = 'sound/combat/shove.ogg'
		playsound(src.loc, sound_to_play, 50, TRUE, -1)
	if(.)
		update_pull_movespeed()

/mob/living/proc/grab_obj(obj/target, suppress_message = FALSE)
	new /obj/item/grabbing(src, src, target)
	return TRUE

/mob/living/proc/grab_living(mob/living/target, suppress_message = FALSE)
	log_combat(src, target, "grab attempt")

	target.update_damage_hud()

	if(HAS_TRAIT(target, TRAIT_GRABIMMUNE) && target.stat == CONSCIOUS) // Grab immunity check
		if(target.cmode)
			target.visible_message(span_warning("[target] breaks from [src]'s grip effortlessly!"), \
					span_warning("I breaks from [src]'s grab effortlesly!"))
			log_combat(src, target, "grab failed", addition="[target] has TRAIT_GRABIMMUNE")
			stop_pulling()
			return FALSE

	playsound(src.loc, 'sound/combat/shove.ogg', 50, TRUE, -1)
	new /obj/item/grabbing(src, src, target)
	return TRUE

//proc to upgrade a simple pull into a more aggressive grab.
/mob/living/proc/grippedby(mob/living/carbon/user, instant = FALSE)
	user.changeNext_move(CLICK_CD_GRABBING * 2 - user.STASPD)
	var/skill_diff = 0
	var/combat_modifier = 1
	if(user.mind)
		skill_diff += (user.get_skill_level(/datum/skill/combat/wrestling)) //NPCs don't use this
	if(mind)
		skill_diff -= (get_skill_level(/datum/skill/combat/wrestling))

	if(user == src)
		instant = TRUE

	if(surrendering)
		combat_modifier = 2

	if(restrained())
		combat_modifier += 0.25

	if(!(mobility_flags & MOBILITY_STAND) && user.mobility_flags & MOBILITY_STAND)
		combat_modifier += 0.05

	if(user.cmode && !cmode)
		combat_modifier += 0.3
	else if(!user.cmode && cmode)
		combat_modifier -= 0.3

	var/probby
	if(!compliance)
		probby = clamp((((4 + (((user.STASTR - STASTR)/2) + skill_diff)) * 10 + rand(-5, 5)) * combat_modifier), 5, 95)
	else
		probby = 100

	if(!prob(probby) && !instant && !stat)
		visible_message(span_warning("[user] struggles with [src]!"),
						span_warning("[user] struggles to restrain me!"), span_hear("I hear aggressive shuffling!"), null, user)
		if(src.client?.prefs.showrolls)
			to_chat(user, span_warning("I struggle with [src]! [probby]%"))
		else
			to_chat(user, span_warning("I struggle with [src]!"))
		playsound(src.loc, 'sound/foley/struggle.ogg', 100, FALSE, -1)
		user.Immobilize(2 SECONDS)
		user.changeNext_move(2 SECONDS)
		src.Immobilize(1 SECONDS)
		src.changeNext_move(1 SECONDS)
		return

	if(!instant)
		var/sound_to_play = 'sound/foley/grab.ogg'
		playsound(src.loc, sound_to_play, 100, FALSE, -1)

	user.setGrabState(GRAB_AGGRESSIVE)
	if(user.active_hand_index == 1)
		if(user.r_grab)
			user.r_grab.grab_state = GRAB_AGGRESSIVE
	if(user.active_hand_index == 2)
		if(user.l_grab)
			user.l_grab.grab_state = GRAB_AGGRESSIVE

	user.update_grab_intents()

	var/add_log = ""
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		add_log = " (pacifist)"
	send_grabbed_message(user)
	if(user != src)
		if(pulling != user) // If the person we're pulling aggro grabs us don't break the grab
			stop_pulling()
		user.set_pull_offsets(src, user.grab_state)
	log_combat(user, src, "grabbed", addition="aggressive grab[add_log]")
	return 1

/mob/living/proc/update_grab_intents(mob/living/target)
	return

/mob/living/carbon/update_grab_intents()
	var/obj/item/grabbing/G = get_active_held_item()
	if(!istype(G))
		return
	if(ismob(G.grabbed))
		if(isitem(G.sublimb_grabbed))
			var/obj/item/I = G.sublimb_grabbed
			G.possible_item_intents = I.grabbedintents(src, G.sublimb_grabbed)
		else
			if(iscarbon(G.grabbed) && G.limb_grabbed)
				var/obj/item/I = G.limb_grabbed
				G.possible_item_intents = I.grabbedintents(src, G.sublimb_grabbed)
			else
				var/mob/M = G.grabbed
				G.possible_item_intents = M.grabbedintents(src, G.sublimb_grabbed)
	if(isobj(G.grabbed))
		var/obj/I = G.grabbed
		G.possible_item_intents = I.grabbedintents(src, G.sublimb_grabbed)
	if(isturf(G.grabbed))
		var/turf/T = G.grabbed
		G.possible_item_intents = T.grabbedintents(src)
	update_a_intents()

/turf/proc/grabbedintents(mob/living/user)
	//RTD up and down
	return list(/datum/intent/grab/move)

/obj/proc/grabbedintents(mob/living/user, precise)
	return list(/datum/intent/grab/move)

/obj/item/grabbedintents(mob/living/user, precise)
	return list(/datum/intent/grab/remove, /datum/intent/grab/twistitem)

/mob/proc/grabbedintents(mob/living/user, precise)
	return list(/datum/intent/grab/move)

/mob/living/proc/send_grabbed_message(mob/living/carbon/user)
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		visible_message(span_danger("[user] firmly grips [src]!"),
						span_danger("[user] firmly grips me!"), span_hear("I hear aggressive shuffling!"), null, user)
		to_chat(user, span_danger("I firmly grip [src]!"))
	else
		visible_message(span_danger("[user] tightens [user.p_their()] grip on [src]!"), \
						span_danger("[user] tightens [user.p_their()] grip on me!"), span_hear("I hear aggressive shuffling!"), null, user)
		to_chat(user, span_danger("I tighten my grip on [src]!"))

