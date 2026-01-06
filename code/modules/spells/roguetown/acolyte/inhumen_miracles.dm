//im putting this here just for my mental sake
//Miracles T1
/obj/effect/proc_holder/spell/invoked/lesser_heal/zizo
	name = "ZIZO's Miracle"
	desc = "Call upon ZIZO to either damage or heal your target, possibly at a cost..."
	overlay_state = "zizo_lesser"
	releasedrain = 15
	chargedrain = 0
	chargetime = 0
	movement_interrupt = FALSE
	sound = 'sound/magic/zizo_heal.ogg'
	antimagic_allowed = TRUE
	recharge_time = 10 SECONDS
	miracle = TRUE
	devotion_cost = 5
	range = 7

/mob/living/proc/clear_sunder_fire()    //to stop sunder in my lesser healing
	remove_status_effect(/datum/status_effect/fire_handler/fire_stacks/sunder)

/obj/effect/proc_holder/spell/invoked/lesser_heal/zizo/can_heal(mob/living/carbon/human/user, mob/living/target)
	if (target == user)
		to_chat(user, span_warning("I can not direct this miracle upon myself!"))
		revert_cast()
		return FALSE
	if (user.devotion?.level == CLERIC_T4)
		if (get_dist(user, target) > range)
			to_chat(user, span_warning("I need to get closer!"))
			revert_cast()
			return FALSE
	else
		if (!user.Adjacent(target))
			to_chat(user, span_warning("I must be beside them to channel."))
			revert_cast()
			return FALSE
	if(target.patron?.type == /datum/patron/inhumen/zizo)
		target.clear_sunder_fire()
		return TRUE
	var/faction_tag = "[user.mind.current.real_name]_faction"
	if(target.mob_biotypes & MOB_UNDEAD || (target.mind?.current && faction_tag in target.mind.current.faction))	//gravemarked people can now get healed
		user.adjustBruteLoss(4)
		return TRUE

	//shitty ass psydonites need special code in here, im adding extra damage to psydonites just because they made me write this block
	if(HAS_TRAIT(target, TRAIT_PSYDONITE))
		user.visible_message(span_danger("[target] is seared by necrotic power!"))
		playsound(user, 'sound/magic/zizo_heal.ogg', 100, TRUE)
		target.adjustFireLoss(15)		//making sure psydonites get attacked too
		target.adjustBruteLoss(4)		//damage here
		return FALSE

	// EVERYONE ELSE
	user.visible_message(span_danger("[target] is seared by necrotic power!"))
	playsound(user, 'sound/magic/zizo_heal.ogg', 100, TRUE)
	target.adjustFireLoss(14)		//damage is here
	user.adjustBruteLoss(4)
	return FALSE

//Blood Heal T1
/obj/effect/proc_holder/spell/invoked/blood_heal/zizo
	name = "Lyfe Drain"
	desc = "ZIZO demands lyfe energy, steal the lyfe force of others so I may continue. Killing the unambitious with it gives a boon."
	overlay_icon = 'icons/mob/actions/genericmiracles.dmi'
	overlay_state = "bloodheal"
	action_icon_state = "bloodheal"
	action_icon = 'icons/mob/actions/genericmiracles.dmi'
	releasedrain = 5
	chargedrain = 0
	chargetime = 0
	ignore_los = FALSE
	movement_interrupt = TRUE
	sound = 'sound/magic/bloodheal.ogg'
	associated_skill = /datum/skill/magic/holy
	antimagic_allowed = FALSE
	recharge_time = 20 SECONDS
	miracle = TRUE
	devotion_cost = 30
	range = 5

/obj/effect/proc_holder/spell/invoked/blood_heal/zizo/cast(list/targets, mob/living/carbon/human/user)
	var/mob/living/target = targets[1]
	if(!isliving(target) || target.stat == DEAD)
		to_chat(user, span_warning("Cannot drain from the dead!"))
		revert_cast()
		return FALSE

	var/allowed_range = 1   //range code
	if(user.devotion?.level == CLERIC_T4)  //only T4 clerics can cast at distance
		allowed_range = range
	if(get_dist(user, target) > allowed_range)
		to_chat(user, span_warning("I must be closer to channel dark power!"))
		revert_cast()
		return FALSE
	if(user.z != target.z)
		to_chat(user, span_warning("This miracle can not be directed upwards or downwards!"))
		revert_cast()
		return FALSE

	if((target.mob_biotypes & MOB_UNDEAD) || istype(target.patron?.type, /datum/patron/inhumen/zizo))
		return ..()

	playsound(user, 'sound/magic/bloodheal_start.ogg', 100, TRUE)
	var/user_skill = user.get_skill_level(associated_skill)
	var/max_loops = 4 + user_skill        //max is 10 at legendary, expert is 8 loops, cleric missionary can get 9 with devotee
	var/channel_time = 1.2 SECONDS - (user_skill * 0.08 SECONDS)  //at 5 skill master you have a 0.40 second reduction, legendary is -0.48 seconds
	var/beam_time = (max_loops * channel_time) + 2 SECONDS //padding to make sure the beam lasts the duration

	//damage beam loop here
	var/datum/beam/bloodbeam = user.Beam(target, icon_state="blood", time=(beam_time))
	var/buff_given = FALSE
	for(var/i = 1 to max_loops)
		if(!do_after(user, channel_time) || get_dist(user, target) > allowed_range)
			break
		var/was_alive = (target.stat != DEAD)
		target.adjustBruteLoss(15)  //15 damage every second, or based on their skill level
		target.blood_volume = max(target.blood_volume - 5, 0)
		user.adjustBruteLoss(-12)
		user.adjustFireLoss(-8)
		user.blood_volume = min(user.blood_volume + 5, BLOOD_VOLUME_NORMAL)

		if(was_alive && target.stat == DEAD && !buff_given)    //buff for killing someone while channeling
			buff_given = TRUE
			user.apply_status_effect(/datum/status_effect/buff/zizo_con)
			break
	bloodbeam.End()
	return TRUE

//Wound heal T3
/obj/effect/proc_holder/spell/invoked/wound_heal/zizo
	name = "Vile Wound Heal"
	desc = "Seals flesh through sacrafice, restoring even what was lost."
	overlay_icon = 'icons/mob/actions/genericmiracles.dmi'
	overlay_state = "zizo_wound_heal"
	action_icon = 'icons/mob/actions/genericmiracles.dmi'
	releasedrain = 15
	chargedrain = 0
	chargetime = 30
	range = 1
	ignore_los = FALSE
	warnie = "sydwarning"
	movement_interrupt = FALSE
	chargedloop = /datum/looping_sound/invokeascendant
	sound = 'sound/magic/zizo_woundheal.ogg'
	antimagic_allowed = FALSE
	recharge_time = 90 SECONDS
	miracle = TRUE
	is_cdr_exempt = TRUE
	devotion_cost = 60

/obj/effect/proc_holder/spell/invoked/wound_heal/zizo/proc/stop_divine_destruction(mob/living/target)
	if(!target)
		return
	if(target in GLOB.divine_destruction_mobs)  // divine destruction stopping code
		//cancels all timers
		for(var/timer_id in GLOB.divine_destruction_mobs[target])
			deltimer(timer_id)
		GLOB.divine_destruction_mobs -= target

		//removes visual effects
		target.remove_filter("divine_glow")  // no more glowing
		for(var/obj/effect/dummy/lighting_obj/moblight/L in target)
			qdel(L)

		//removes godmode and stun
		target.status_flags &= ~GODMODE

		target.remove_status_effect(/datum/status_effect/incapacitating/stun)		//removing all stuns to make sure
		target.remove_status_effect(/datum/status_effect/incapacitating/knockdown)
		target.remove_status_effect(/datum/status_effect/incapacitating/paralyzed)

		UnregisterSignal(target, COMSIG_LIVING_CALCIFICATION_OVERRIDE)
		to_chat(target, span_notice("THE WHORE ASTRATA IS STOPPED, SHE IS WEAK!"))

/obj/effect/proc_holder/spell/invoked/wound_heal/zizo/cast(list/targets, mob/living/carbon/human/user)
	// validate target
	if(!targets || targets.len < 1)
		revert_cast()
		return FALSE

	var/mob/living/carbon/human/target = targets[1]

	if(!ishuman(target))
		revert_cast()
		return FALSE

	//RANGE CODE
	if(get_dist(user, target) > 1)
		to_chat(user, span_warning("I must be beside them to channel this miracle."))
		revert_cast()
		return FALSE

	// stop divine destruction
	if(target in GLOB.divine_destruction_mobs)
		stop_divine_destruction(target)

	// undead or Zizo only
	if(!(target.mob_biotypes & MOB_UNDEAD) && target.patron?.type != /datum/patron/inhumen/zizo)
		target.visible_message(span_info("[target] recoils as the profane miracle refuses them."))
		revert_cast()
		return FALSE

	var/zone = check_zone(user.zone_selected)
	if(!zone)
		revert_cast()
		return FALSE

	var/obj/item/bodypart/affecting = target.get_bodypart(zone)

	playsound(target, 'sound/magic/zizo_woundheal.ogg', 100, TRUE)

	// LIMB MISSING REGENERATE AS SKELETONIZED
	if(!affecting)
		to_chat(user, span_info("Bone answers your call. Flesh is for the unambitious."))

		// spawn correct limb type
		var/list/missing = list(zone)
		target.regenerate_limbs(missing)

		var/obj/item/bodypart/new_limb = target.get_bodypart(zone)
		if(!new_limb)
			revert_cast()
			return FALSE

		new_limb.rotted = FALSE
		new_limb.skeletonized = TRUE
		new_limb.update_limb()
		target.update_body()

		return TRUE   // parent NOT called

	// LIMB EXISTS SO USE PARENT LOGIC
	return ..()
