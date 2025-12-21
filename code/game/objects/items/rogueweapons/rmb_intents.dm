/datum/rmb_intent
	var/name = "intent"
	var/desc = ""
	var/icon_state = ""
	var/adjacency = TRUE
	/// Whether the rclick will try to get turfs as target.
	var/prioritize_turfs = FALSE

/mob/living/carbon/human
	var/bait_stacks

/mob/living/carbon/human/on_cmode()
	if(!cmode)	//We just toggled it off.
		addtimer(CALLBACK(src, PROC_REF(purge_bait)), 30 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)
		addtimer(CALLBACK(src, PROC_REF(expire_peel)), 60 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)
	if(!HAS_TRAIT(src, TRAIT_DECEIVING_MEEKNESS))
		filtered_balloon_alert(TRAIT_COMBAT_AWARE, (cmode ? ("<i><font color = '#831414'>Tense</font></i>") : ("<i><font color = '#c7c6c6'>Relaxed</font></i>")), y_offset = 32)

/mob/living/carbon/human/RightClickOn(atom/A, params)
	if(rmb_intent && !rmb_intent.adjacency && !istype(A, /obj/item/clothing) && cmode && !istype(src, /mob/living/carbon/human/species/skeleton) && !istype(A, /obj/item/quiver) && !istype(A, /obj/item/storage))
		var/held = get_active_held_item()
		if(held && istype(held, /obj/item))
			var/obj/item/I = held
			if(I.associated_skill)
				rmb_intent.special_attack(src, ismob(A) ? A : rmb_intent.prioritize_turfs ? get_turf(A) : get_foe_from_turf(get_turf(A)))
	else
		. = ..()

/// Used for "directional" style rmb attacks on a turf, prioritizing standing targets
/mob/living/proc/get_foe_from_turf(turf/T)
	if(!istype(T))
		return

	var/list/mob/living/foes = list()
	for(var/mob/living/foe_in_turf in T)
		if(foe_in_turf == src)
			continue

		var/foe_prio = rand(4, 8)
		if(foe_in_turf.mobility_flags & MOBILITY_STAND)
			foe_prio += 10
		else if(foe_in_turf.stat != CONSCIOUS)
			foe_prio = 2
		else if(foe_in_turf.surrendering)
			foe_prio = -5

		foes[foe_in_turf] = foe_prio

	if(!foes.len)
		return null

	if(foes.len > 1)
		sortTim(foes, cmp = /proc/cmp_numeric_dsc, associative = TRUE)
	return foes[1]

/datum/rmb_intent/proc/special_attack(mob/living/user, atom/target)
	return

/datum/rmb_intent/aimed
	name = "aimed"
	desc = "Your attacks are more precise but have a longer recovery time. Higher critrate with precise attacks.\n(RMB WHILE COMBAT MODE IS ACTIVE) Bait out your targeted limb to the enemy. If it matches where they're aiming, they will be thrown off balance."
	icon_state = "rmbaimed"

/mob/living/proc/attempt_bait(mob/living/user, atom/target)
	if(istype(src, /mob/living/carbon/human/species/skeleton))
		return
	if(!user)
		return
	if(user.incapacitated())
		return
	if(!ishuman(user))
		return
	if(!ishuman(target))
		return
	if(user == target)
		return
	
	var/mob/living/carbon/human/HT = target
	var/mob/living/carbon/human/HU = user
	var/target_zone = HT.zone_selected
	var/user_zone = HU.zone_selected

	if(HT.has_status_effect(/datum/status_effect/debuff/baited) || user.has_status_effect(/datum/status_effect/debuff/baitcd))
		return	//We don't do anything if either of us is affected by bait statuses

	if(user.STAINT < 8) //We don't want this happening if their intelligence is 7 or below.
		to_chat(HU, span_danger("Argh! This is too complicated, I've made a fool of myself!"))
		HU.stamina_add(HU.max_stamina * 0.2)
		HU.emote("huh")
		return

	HU.visible_message(span_danger("[HU] baits an attack from [HT]!"))
	HU.apply_status_effect(/datum/status_effect/debuff/baitcd)
	HU.stamina_add(HU.max_stamina * 0.2)

	if((target_zone != user_zone) || ((target_zone == BODY_ZONE_CHEST) || (user_zone == BODY_ZONE_CHEST))) //Our zones match and it's not the chest | Our zones do not match, or we were targeting chest
		to_chat(HU, span_danger("It didn't work! [HT.p_their(TRUE)] footing returned!"))
		to_chat(HT, span_notice("I fooled [HU.p_them()]! I've regained my footing!"))
		HU.emote("groan")
		HT.bait_stacks = 0
		return

	var/fatiguemod	//The heavier the target's armor, the more fatigue (green bar) we drain.
	var/targetac = HT.highest_ac_worn()
	switch(targetac)
		if(ARMOR_CLASS_NONE)
			fatiguemod = 5
		if(ARMOR_CLASS_LIGHT, ARMOR_CLASS_MEDIUM)
			fatiguemod = 4
		if(ARMOR_CLASS_HEAVY)
			fatiguemod = 3

	HT.apply_status_effect(/datum/status_effect/debuff/baited)
	HT.apply_status_effect(/datum/status_effect/debuff/exposed)
	HT.apply_status_effect(/datum/status_effect/debuff/clickcd, 5 SECONDS)
	HT.bait_stacks++
	if(HT.bait_stacks <= 1)
		HT.Immobilize(0.5 SECONDS)
		HT.stamina_add(HT.max_stamina / fatiguemod)
		HT.Slowdown(3)
		HT.emote("huh")
		HU.purge_peel(BAIT_PEEL_REDUCTION)
		HU.changeNext_move(0.1 SECONDS, override = TRUE)
		to_chat(HU, span_notice("[HT.p_they(TRUE)] fell for my bait <b>perfectly</b>! One more!"))
		to_chat(HT, span_danger("I fall for [HU.p_their()]'s bait <b>perfectly</b>! I'm losing my footing! <b>I can't let this happen again!</b>"))
	
	if(HU.has_duelist_ring() && HT.has_duelist_ring() || HT.bait_stacks >= 2)	//We're explicitly (hopefully non-lethally) dueling. Flavor.
		HT.emote("gasp")
		HT.OffBalance(2 SECONDS)
		HT.Immobilize(2 SECONDS)
		to_chat(HU, span_notice("[HT.p_they(TRUE)] fell for it again and is off-balanced! NOW!"))
		to_chat(HT, span_danger("I fall for [HU.p_their()] bait <b>perfectly</b>! My balance is GONE!</b>"))
		HT.bait_stacks = 0


	if(!HT.pulling)
		return

	HT.stop_pulling()
	to_chat(HU, span_notice("[HT.p_they(TRUE)] fell for my dirty trick! I am loose!"))
	to_chat(HT, span_danger("I fall for [HU.p_their()] dirty trick! My hold is broken!"))
	HU.OffBalance(2 SECONDS)
	HT.OffBalance(2 SECONDS)
	playsound(user, 'sound/combat/riposte.ogg', 100, TRUE)

/datum/rmb_intent/aimed/special_attack(mob/living/user, atom/target)
	user.attempt_bait(user, target)

/datum/rmb_intent/strong
	name = "strong"
	desc = "Your attacks have +1 strength but use more stamina. Higher critrate with brutal attacks. Intentionally fails surgery steps."
	icon_state = "rmbstrong"
	adjacency = FALSE
	prioritize_turfs = TRUE

/datum/rmb_intent/strong/special_attack(mob/living/user, atom/target)
	if(!user)
		return
	if(user.incapacitated())
		return
	if(!user.mind)
		return
	if(user.has_status_effect(/datum/status_effect/debuff/specialcd))
		return

	var/obj/item/rogueweapon/W = user.get_active_held_item()
	if(istype(W, /obj/item/rogueweapon) && W.special)
		var/skillreq = W.associated_skill
		if(W.special.custom_skill)
			skillreq = W.special.custom_skill
		if(user.get_skill_level(skillreq) < SKILL_LEVEL_JOURNEYMAN)
			to_chat(user, span_info("I'm not knowledgeable enough in the arts of this weapon to use this."))
			return
		W.special.deploy(user, W, target)

/datum/rmb_intent/swift
	name = "swift"
	desc = "Your attacks have less recovery time but are less accurate."
	icon_state = "rmbswift"

/datum/rmb_intent/special
	name = "special"
	desc = "(RMB WHILE DEFENSE IS ACTIVE) A special attack that depends on the type of weapon you are using."
	icon_state = "rmbspecial"

/datum/rmb_intent/feint
	name = "feint"
	desc = "(RMB WHILE IN COMBAT MODE) A deceptive half-attack with no follow-through, meant to force your opponent to open their guard. Will fail on targets that are relaxed and less alert."
	icon_state = "rmbfeint"
	var/feintdur = 7.5 SECONDS

/mob/living/proc/attempt_feint(mob/living/user, atom/target)
	if(istype(src, /mob/living/carbon/human/species/skeleton))
		return
	if(!isliving(target))
		return
	if(!user)
		return
	if(user.incapacitated())
		return
	if(!user.mind)
		return
	if(user.has_status_effect(/datum/status_effect/debuff/feintcd))
		return
	var/mob/living/L = target
	if (L.client && !L.cmode)
		playsound(user, 'sound/combat/feint.ogg', 100, TRUE)
		user.visible_message(span_danger("[user] attempts to feint an attack at [L], but only makes a fool of themselves!"))
		user.OffBalance(3 SECONDS)
		user.apply_status_effect(/datum/status_effect/debuff/feintcd)
		for(var/mob/living/carbon/human/H in view(7, user))
			if(H == user || !H.client)
				continue
			if(HAS_TRAIT(H, TRAIT_XYLIX) && !H.has_status_effect(/datum/status_effect/buff/xylix_joy))
				H.apply_status_effect(/datum/status_effect/buff/xylix_joy)
				to_chat(H, span_info("Such a curt display of hubris amuses the Laughing God!"))
		return
	else
		user.visible_message(span_danger("[user] feints an attack at [target]!"))
	var/perc = 50
	var/obj/item/I = user.get_active_held_item()
	var/ourskill = 0
	var/theirskill = 0
	var/skill_factor = 0
	if(I)
		if(I.associated_skill)
			ourskill = user.get_skill_level(I.associated_skill)
			if(I.item_flags & PEASANT_WEAPON && HAS_TRAIT(user, TRAIT_PEASANTMILITIA))
				ourskill += 1
		if(L.mind)
			I = L.get_active_held_item()
			if(I?.associated_skill)
				theirskill = L.get_skill_level(I.associated_skill)
				if(I.item_flags & PEASANT_WEAPON && HAS_TRAIT(L, TRAIT_PEASANTMILITIA))
					theirskill += 1
	perc += (ourskill - theirskill)*15 	//skill is of the essence
	perc += (user.STAINT - L.STAINT)*10	//but it's also mostly a mindgame
	skill_factor = (ourskill - theirskill)/2

	var/special_msg

	if(L.has_status_effect(/datum/status_effect/debuff/exposed))
		perc = 0

	if(L.has_status_effect(/datum/status_effect/debuff/feinted))
		perc = 0
		special_msg = span_warning("Too soon! They were expecting it!")

	if(!L.can_see_cone(user) && L.mind)
		perc = 0
		special_msg = span_warning("They need to see me for me to feint them!")

	perc = CLAMP(perc, 0, 90)

	if(!prob(perc)) //feint intent increases the immobilize duration significantly
		playsound(user, 'sound/combat/feint.ogg', 100, TRUE)
		if(user.client?.prefs.showrolls)
			to_chat(user, span_warning("[L.p_they(TRUE)] did not fall for my feint... [perc]%"))
		user.apply_status_effect(/datum/status_effect/debuff/feintcd)
		if(special_msg)
			to_chat(user, special_msg)
		return

	if(L.has_status_effect(/datum/status_effect/buff/clash))
		L.remove_status_effect(/datum/status_effect/buff/clash)
		to_chat(user, span_notice("[L.p_their(TRUE)] Guard disrupted!"))
	L.apply_status_effect(/datum/status_effect/debuff/exposed, feintdur)
	L.apply_status_effect(/datum/status_effect/debuff/clickcd, max(1.5 SECONDS + skill_factor, 2.5 SECONDS))
	L.apply_status_effect(/datum/status_effect/debuff/feinted, 30 SECONDS + feintdur)
	L.Immobilize(0.5 SECONDS)
	L.stamina_add(L.stamina * 0.1)
	L.Slowdown(2)
	user.apply_status_effect(/datum/status_effect/debuff/feintcd, 30 SECONDS + feintdur)
	to_chat(user, span_notice("[L.p_they(TRUE)] fell for my feint attack!"))
	to_chat(L, span_danger("I fall for [user.p_their()] feint attack!"))
	playsound(user, 'sound/combat/riposte.ogg', 100, TRUE)

/datum/rmb_intent/feint/special_attack(mob/living/user, atom/target)
	user.attempt_feint(user, target)

/datum/rmb_intent/riposte
	name = "defend"
	desc = "No delay between dodge and parry rolls.\n(RMB WHILE NOT GRABBING ANYTHING AND HOLDING A WEAPON)\nEnter a defensive stance, guaranteeing the next hit is defended against.\nTwo people who hit each other with the Guard up will have their weapons Clash, potentially disarming them.\nLetting it expire or hitting someone with it who has no Guard up is tiresome."
	icon_state = "rmbdef"
	adjacency = FALSE

/mob/living/proc/attempt_riposte(mob/living/user, atom/target)
	if(!user.has_status_effect(/datum/status_effect/buff/clash) && !user.has_status_effect(/datum/status_effect/debuff/clashcd))
		if(!user.get_active_held_item()) //Nothing in our hand to Guard with.
			return 
		if(user.r_grab || user.l_grab || length(user.grabbedby)) //Not usable while grabs are in play.
			return
		if(user.IsImmobilized() || user.IsOffBalanced()) //Not usable while we're offbalanced or immobilized
			return
		if(user.m_intent == MOVE_INTENT_RUN)
			to_chat(user, span_warning("I can't focus on this while running."))
			return
		if(user.magearmor == FALSE && HAS_TRAIT(user, TRAIT_MAGEARMOR))	//The magearmor is ACTIVE, so we can't Guard. (Yes, it's active while FALSE / 0.)
			to_chat(user, span_warning("I'm already focusing on my mage armor!"))
			return
		user.apply_status_effect(/datum/status_effect/buff/clash)

/datum/rmb_intent/riposte/special_attack(mob/living/user, atom/target)	//Wish we could breakline these somehow.
	user.attempt_riposte(user, target)

/datum/rmb_intent/guard
	name = "guarde"
	desc = "(RMB WHILE DEFENSE IS ACTIVE) Raise your weapon, ready to attack any creature who moves onto the space you are guarding."
	icon_state = "rmbguard"

/datum/rmb_intent/weak
	name = "weak"
	desc = "Your attacks have -1 strength and will never critically-hit. Useful for longer punishments, play-fighting, and bloodletting."
	icon_state = "rmbweak"

/datum/rmb_intent/omni
	name = "omni"
	desc = "Intelligently attempts to apply other RMB & MMB intent actives based on the situation. (RMB on yourself or the ground triggers DEFEND, RMB on an opponent attempts to bait (if possible), kick them if they're grappling you, kick them if they're off balance and feint (in this order) otherwise.)"
	icon_state = "rmbguard" // needs a new icon_state or something

/datum/rmb_intent/omni/special_attack(mob/living/user, atom/target)
	var/mob/living/carbon/human/HU = user
	if (isturf(target) || user == target)
		// RMB on turf or self: DEFEND.
		if (!HU.has_status_effect(/datum/status_effect/debuff/clashcd))
			HU.attempt_riposte(user, target)
			HU.changeNext_move(0.5 SECONDS)
			return
	
	var/mob/living/carbon/human/HT
	if (ismob(target) && user != target)
		if (ishuman(target))
			HT = target

		// RMB on mob (priority 0): check to see if a bait has any chance to succeed (match targeting zones between us and the target), if so, attempt it (ONLY check for matching zones, nothing else).
		if (HT)
			var/target_zone = HT.zone_selected
			var/user_zone = HU.zone_selected
			if (!user.has_status_effect(/datum/status_effect/debuff/baitcd) && !user.has_status_effect(/datum/status_effect/debuff/baited) && target_zone && user_zone && (target_zone != BODY_ZONE_CHEST && user_zone != BODY_ZONE_CHEST) && target_zone == user_zone)
				HU.attempt_bait(user, target)
				HU.changeNext_move(0.5 SECONDS)
				return
		
		// RMB on mob (priority 1): has something grappled us (passively), and can we kick? if so, attempt a kick.
		if (!HU.IsOffBalanced())
			var/mob/kick_target
			for(var/obj/item/grabbing/G in HU.grabbedby)
				if(G.grabbee && G.grab_state == GRAB_PASSIVE)
					kick_target = G.grabbee
					break
			if (kick_target)
				HU.try_kick(kick_target)
				HU.changeNext_move(0.5 SECONDS)
				return

		// RMB on mob (priority 2): is the target off-balance and not knocked over? if so, kick them over.
		if (HT && HT.IsOffBalanced() && (HT.mobility_flags & MOBILITY_STAND))
			HU.try_kick(target)
			HU.changeNext_move(0.5 SECONDS)
			return

		// RMB on mob (priority 3): attempt a feint if possible and off cooldown.
		if (!HU.has_status_effect(/datum/status_effect/debuff/feintcd))
			HU.attempt_feint(user, target)
			HU.changeNext_move(0.5 SECONDS)
			return
