// Lesser miracle
/obj/effect/proc_holder/spell/invoked/lesser_heal
	name = "Miracle"
	desc = "Call upon your patron to heal your target."
	overlay_state = "lesserheal"
	releasedrain = 30
	chargedrain = 0
	chargetime = 0
	range = 7
	warnie = "sydwarning"
	movement_interrupt = FALSE
	sound = 'sound/magic/heal.ogg'
	invocation_type = "none"
	associated_skill = /datum/skill/magic/holy
	antimagic_allowed = TRUE
	recharge_time = 10 SECONDS
	miracle = TRUE
	devotion_cost = 10
	var/base_healing = 2.5 // how much we heal per tick

/obj/effect/proc_holder/spell/invoked/lesser_heal/free //using this for a simplemob spell
	releasedrain = 0
	devotion_cost = 0

/obj/effect/proc_holder/spell/invoked/lesser_heal/proc/get_most_damaged_limb(mob/living/carbon/C)
	var/obj/item/bodypart/most_damaged_limb = null
	var/highest_damage = 0
	var/obj/item/bodypart/bleeding_limb = null
	var/highest_bleed_rate = 0

	// First check for bleeding limbs
	for(var/obj/item/bodypart/BP in C.bodyparts)
		var/bleed_rate = BP.get_bleed_rate()
		if(bleed_rate > highest_bleed_rate)
			highest_bleed_rate = bleed_rate
			bleeding_limb = BP

	// If we found a bleeding limb, return it
	if(bleeding_limb)
		return bleeding_limb

	// If no bleeding limbs, find the most damaged limb
	for(var/obj/item/bodypart/BP in C.bodyparts)
		var/total_damage = BP.get_damage()
		if(total_damage > highest_damage)
			highest_damage = total_damage
			most_damaged_limb = BP

	return most_damaged_limb

/obj/effect/proc_holder/spell/invoked/lesser_heal/proc/range_check(mob/living/carbon/human/user, mob/living/target)
	// we can only miracle someone if we're adjacent to them, unless we're a t4 cleric
	if (target == user) // we can always lay hands on ourself
		return TRUE

	if (user.devotion?.level == CLERIC_T4)
		if (get_dist(user, target) >= range)
			to_chat(user, span_warning("I need to be closer to them to call forth a healing miracle!"))
			return FALSE
		return TRUE
	
	if (!user.Adjacent(target))
		to_chat(user, span_warning("I need to be beside them to perform miraculous healing!"))
		return FALSE
	
	return TRUE	

/obj/effect/proc_holder/spell/invoked/lesser_heal/proc/can_heal(mob/living/user, mob/living/target)
	if (!range_check(user, target))
		revert_cast()
		return FALSE

	if(HAS_TRAIT(target, TRAIT_PSYDONITE))
		target.visible_message(span_info("[target] stirs for a moment, the miracle dissipates."), span_notice("A dull warmth swells in your heart, only to fade as quickly as it arrived."))
		user.playsound_local(user, 'sound/magic/PSY.ogg', 100, FALSE, -1)
		playsound(target, 'sound/magic/PSY.ogg', 100, FALSE, -1)
		return FALSE

	if(user.patron?.undead_hater && (target.mob_biotypes & MOB_UNDEAD)) //positive energy harms the undead
		target.visible_message(span_danger("[target] is burned by holy light!"), span_userdanger("I'm burned by holy light!"))
		target.adjustFireLoss(10)
		target.fire_act(1,10)
		return FALSE

	if(target.has_status_effect(/datum/status_effect/buff/healing))
		to_chat(user, span_warning("They are already under the effects of a healing aura!"))
		revert_cast()
		return FALSE

	var/is_divine = ispath(user.patron?.type, /datum/patron/divine)
	if(is_divine && (target.real_name in GLOB.excommunicated_players))
		to_chat(user, span_danger("The gods recoil from [target]! Divine fire scorches your hands as your plea is rejected!"))
		target.visible_message(span_danger("[target] is seared by divine wrath! The gods hate them!"), span_userdanger("I am seared by divine wrath! The gods hate me!"))
		revert_cast()
		return FALSE

	return TRUE

/obj/effect/proc_holder/spell/invoked/lesser_heal/proc/check_embeds(mob/living/target, mob/living/user)
	var/no_embeds = TRUE
	var/list/embeds = target.get_embedded_objects()
	if(length(embeds))
		for(var/object in embeds)
			if(!istype(object, /obj/item/natural/worms/leech))	//Leeches and surgical cheeles are made an exception.
				no_embeds = FALSE
	else
		no_embeds = TRUE

	return no_embeds

/obj/effect/proc_holder/spell/invoked/lesser_heal/proc/apply_healing(mob/living/target, mob/living/user, amount)
	if (ishuman(target))
		var/no_embeds = check_embeds(target, user)
		if(no_embeds)
			// Always apply the status effect for visual effects
			target.apply_status_effect(/datum/status_effect/buff/healing, amount)

			// Find and heal the most damaged limb
			var/obj/item/bodypart/most_damaged_limb = get_most_damaged_limb(target)
			if(most_damaged_limb && most_damaged_limb.get_damage() > 0)
				most_damaged_limb.heal_damage(amount * 2, amount * 2, amount * 2)
				target.update_damage_overlays()
				to_chat(target, span_notice("The miracle mends my [most_damaged_limb.name]!"))
		else
			target.visible_message(span_warning("The wounds tear and rip around the embedded objects!"), span_warning("Agonising pain shoots through your body as magycks try to sew around the embedded objects!"))
			target.adjustBruteLoss(20)
			playsound(target, 'sound/combat/dismemberment/dismem (2).ogg', 100)
			target.emote("agony")
	else
		target.apply_status_effect(/datum/status_effect/buff/healing, amount)

	charge_counter = 0
	if(action)
		action.UpdateButtonIcon()

	var/the_line = pick(user.patron.miracle_healing_lines)
	the_line = replacetext(the_line, "%TARGET", "[target]")
	target.visible_message(span_info(the_line))

/obj/effect/proc_holder/spell/invoked/lesser_heal/proc/get_situational_bonus(mob/living/user, mob/living/target)
	var/situational_info = user.patron.situational_bonus(user, target)
	var/conditional_buff = situational_info[1] ? TRUE : FALSE
	var/situational_bonus = situational_info[2] ? situational_info[2] : 0

	var/healing = base_healing
	if (conditional_buff)
		to_chat(user, span_info("Channeling my patron's power is easier in these conditions!"))
		healing += situational_bonus
	
	return healing

/obj/effect/proc_holder/spell/invoked/lesser_heal/cast(list/targets, mob/living/user)
	. = ..()
	if(isliving(targets[1]))
		var/mob/living/target = targets[1]
		var/mob/living/carbon/human/H = user

		if (!user.patron || !H)
			return FALSE
		
		// perform all of our pre-heal checks inside can_heal, including revert_casts, if needed
		if (!can_heal(user, target))
			return FALSE
		
		if (target != user)
			if (H.devotion?.level == CLERIC_T4)
				user.visible_message(span_notice("[user] gestures towards [target] with a whispered prayer!"))
			else
				user.visible_message(span_notice("[user] lays their hands upon [target], willing flesh and bone to mend..."))

			var/datum/beam/healing_beam = user.Beam(target, icon_state="medbeam", time=5 MINUTES)
			apply_healing(target, user, get_situational_bonus(user, target))
			playsound(target, 'sound/magic/heal.ogg', 100)
			while (do_after(user, 10.5 SECONDS, target = target))
				if (H.devotion?.check_devotion(src))
					if (can_heal(user, target))
						playsound(target, 'sound/magic/heal.ogg', 100)
						apply_healing(target, user, get_situational_bonus(user, target))
						H.devotion?.update_devotion(-devotion_cost)
						to_chat(user, "<font color='purple'>I lose [devotion_cost] devotion!</font>")
					else
						healing_beam.End()
						return TRUE
				else
					to_chat(user, span_warning("My devotion runs dry - I can call upon [user.patron.name] no further for the moment!"))
					healing_beam.End()
					return TRUE

			healing_beam.End()
			return TRUE
		else
			user.visible_message(span_info("[user] quickly lays their hands upon themselves!"))
			apply_healing(target, user, get_situational_bonus(user, target))
			return TRUE
	
	revert_cast()
	return FALSE

// Miracle
/obj/effect/proc_holder/spell/invoked/heal
	name = "Fortify"
	desc = "Increases the amount of healing your target recieves for a time."
	overlay_state = "astrata"
	releasedrain = 30
	chargedrain = 0
	chargetime = 0
	range = 4
	warnie = "sydwarning"
	movement_interrupt = FALSE
//	chargedloop = /datum/looping_sound/invokeholy
	chargedloop = null
	req_items = list(/obj/item/clothing/neck/roguetown/psicross)
	sound = 'sound/magic/heal.ogg'
	invocation_type = "none"
	associated_skill = /datum/skill/magic/holy
	antimagic_allowed = TRUE
	recharge_time = 20 SECONDS
	miracle = TRUE
	devotion_cost = 20

/obj/effect/proc_holder/spell/invoked/heal/cast(list/targets, mob/living/user)
	. = ..()
	if(isliving(targets[1]))
		var/mob/living/target = targets[1]
		if(HAS_TRAIT(target, TRAIT_PSYDONITE))
			target.visible_message(span_info("[target] stirs for a moment, the miracle dissipates."), span_notice("A dull warmth swells in your heart, only to fade as quickly as it arrived."))
			user.playsound_local(user, 'sound/magic/PSY.ogg', 100, FALSE, -1)
			playsound(target, 'sound/magic/PSY.ogg', 100, FALSE, -1)
			return FALSE
		if(user.patron?.undead_hater && (target.mob_biotypes & MOB_UNDEAD)) //positive energy harms the undead
			target.visible_message(span_danger("[target] is burned by holy light!"), span_userdanger("I'm burned by holy light!"))
			target.adjustFireLoss(25)
			target.fire_act(1,10)
			return TRUE
		// Block if excommunicated and caster is divine pantheon
		var/is_divine = ispath(user.patron?.type, /datum/patron/divine)
		if(is_divine && (target.real_name in GLOB.excommunicated_players))
			to_chat(user, span_danger("The gods recoil from [target]! Divine fire scorches your hands as your plea is rejected!"))
			target.visible_message(span_danger("[target] is seared by divine wrath! The gods hate them!"), span_userdanger("I am seared by divine wrath! The gods hate me!"))
			revert_cast()
			return FALSE
		target.visible_message(span_info("A wreath of gentle light passes over [target]!"), span_notice("I'm bathed in holy light!"))
		if(iscarbon(target))
			var/mob/living/carbon/C = target
			C.apply_status_effect(/datum/status_effect/buff/fortify)
		else
			target.adjustBruteLoss(-50)
			target.adjustFireLoss(-50)
		return TRUE
	revert_cast()
	return FALSE

/obj/effect/proc_holder/spell/invoked/regression
	name = "Regression"
	overlay_state = "regression"
	releasedrain = 30
	chargedrain = 0
	chargetime = 0
	range = 4
	warnie = "sydwarning"
	movement_interrupt = FALSE
	sound = list('sound/magic/regression1.ogg','sound/magic/regression2.ogg','sound/magic/regression3.ogg','sound/magic/regression4.ogg')
	invocation_type = "none"
	associated_skill = /datum/skill/magic/holy
	antimagic_allowed = TRUE
	recharge_time = 10 SECONDS
	miracle = TRUE
	devotion_cost = 10
	req_items = list(/obj/item/clothing/mask/rogue)

/obj/effect/proc_holder/spell/invoked/regression/proc/get_most_damaged_limb(mob/living/carbon/C)
	var/obj/item/bodypart/most_damaged_limb = null
	var/highest_damage = 0
	var/obj/item/bodypart/bleeding_limb = null
	var/highest_bleed_rate = 0

	// First check for bleeding limbs
	for(var/obj/item/bodypart/BP in C.bodyparts)
		var/bleed_rate = BP.get_bleed_rate()
		if(bleed_rate > highest_bleed_rate)
			highest_bleed_rate = bleed_rate
			bleeding_limb = BP

	// If we found a bleeding limb, return it
	if(bleeding_limb)
		return bleeding_limb

	// If no bleeding limbs, find the most damaged limb
	for(var/obj/item/bodypart/BP in C.bodyparts)
		var/total_damage = BP.get_damage()
		if(total_damage > highest_damage)
			highest_damage = total_damage
			most_damaged_limb = BP

	return most_damaged_limb

/obj/effect/proc_holder/spell/invoked/regression/cast(list/targets, mob/living/user)
	. = ..()
	if(isliving(targets[1]))
		var/mob/living/target = targets[1]
		target.visible_message(span_info("Order filled magic rewind [target]'s wounds!"), span_notice("My wounds, undone!"))
		var/healing = 2.5
		if(target.has_status_effect(/datum/status_effect/buff/stasis))
			healing += 2.5
		target.apply_status_effect(/datum/status_effect/buff/healing, healing)
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			var/obj/item/bodypart/target_limb = get_most_damaged_limb(H)
			if(target_limb)
				// Heal the most damaged/bleeding limb
				target_limb.heal_damage(healing * 10, healing * 10) // Convert healing to damage values
				H.update_damage_overlays()
		return TRUE
	revert_cast()
	return FALSE

/obj/effect/proc_holder/spell/invoked/convergence
	name = "Convergence"
	overlay_state = "convergence"
	releasedrain = 30
	chargedrain = 0
	chargetime = 0
	range = 4
	warnie = "sydwarning"
	movement_interrupt = FALSE
//	chargedloop = /datum/looping_sound/invokeholy
	chargedloop = null
	req_items = list(/obj/item/clothing/neck/roguetown/psicross, /obj/item/clothing/mask/rogue)
	sound = list('sound/magic/convergence1.ogg','sound/magic/convergence2.ogg','sound/magic/convergence3.ogg','sound/magic/convergence4.ogg')
	invocation_type = "none"
	associated_skill = /datum/skill/magic/holy
	antimagic_allowed = TRUE
	recharge_time = 20 SECONDS
	miracle = TRUE
	devotion_cost = 20

/obj/effect/proc_holder/spell/invoked/convergence/cast(list/targets, mob/living/user)
	. = ..()
	if(isliving(targets[1]))
		var/mob/living/target = targets[1]
		target.visible_message(span_info("A convergence of fates surrounds [target]!"), span_notice("My past and present converge as one!"))
		if(iscarbon(target))
			var/mob/living/carbon/C = target
			C.apply_status_effect(/datum/status_effect/buff/convergence)
			C.apply_status_effect(/datum/status_effect/buff/fortify)
		else
			target.adjustBruteLoss(-50)
			target.adjustFireLoss(-50)
		return TRUE
	revert_cast()
	return FALSE


/obj/effect/proc_holder/spell/invoked/stasis
	name = "Stasis"
	desc = "You capture your target's current state in time, reverting them to such a state several seconds later."
	releasedrain = 35
	chargedrain = 1
	chargetime = 30
	recharge_time = 60 SECONDS
	warnie = "spellwarning"
	no_early_release = TRUE
	movement_interrupt = FALSE
	charging_slowdown = 3
	sound = 'sound/magic/timeforward.ogg'
	chargedloop = /datum/looping_sound/invokegen
	associated_skill = /datum/skill/magic/holy
	overlay_state = "sands_of_time"
	var/brute = 0
	var/burn = 0
	var/oxy = 0
	var/toxin = 0
	var/turf/origin
	var/firestacks = 0
	var/divinefirestacks = 0
	var/sunderfirestacks = 0
	var/blood = 0
	miracle = TRUE
	devotion_cost = 30
	req_items = list(/obj/item/clothing/mask/rogue)

/obj/effect/proc_holder/spell/invoked/stasis/cast(list/targets, mob/user = usr)
	if(isliving(targets[1]))
		var/mob/living/carbon/target = targets[1]
		var/mob/living/carbon/C = target
		C.apply_status_effect(/datum/status_effect/buff/stasis)
		brute = target.getBruteLoss()
		burn = target.getFireLoss()
		oxy = target.getOxyLoss()
		toxin = target.getToxLoss()
		origin = get_turf(target)
		blood = target.blood_volume
		var/datum/status_effect/fire_handler/fire_stacks/fire_status = target.has_status_effect(/datum/status_effect/fire_handler/fire_stacks)
		firestacks = fire_status?.stacks
		var/datum/status_effect/fire_handler/fire_stacks/sunder/sunder_status = target.has_status_effect(/datum/status_effect/fire_handler/fire_stacks/sunder)
		sunderfirestacks = sunder_status?.stacks
		var/datum/status_effect/fire_handler/fire_stacks/divine/divine_status = target.has_status_effect(/datum/status_effect/fire_handler/fire_stacks/divine)
		divinefirestacks = divine_status?.stacks
		to_chat(target, span_warning("I feel a part of me was left behind..."))
		play_indicator(target,'icons/mob/overhead_effects.dmi', "timestop", 100, OBJ_LAYER)
		addtimer(CALLBACK(src, PROC_REF(remove_buff), target), wait = 10 SECONDS)
		return TRUE


/obj/effect/proc_holder/spell/invoked/stasis/proc/remove_buff(mob/living/carbon/target)
	do_teleport(target, origin, no_effects=TRUE)
	var/brutenew = target.getBruteLoss()
	var/burnnew = target.getFireLoss()
	var/oxynew = target.getOxyLoss()
	var/toxinnew = target.getToxLoss()
	target.adjust_fire_stacks(firestacks)
	target.adjust_fire_stacks(sunderfirestacks, /datum/status_effect/fire_handler/fire_stacks/sunder)
	target.adjust_fire_stacks(divinefirestacks, /datum/status_effect/fire_handler/fire_stacks/divine)
	if(target.has_status_effect(/datum/status_effect/buff/convergence))
		if(brutenew>brute)
			target.adjustBruteLoss(brutenew*-1 + brute)
		if(burnnew>burn)
			target.adjustFireLoss(burnnew*-1 + burn)
		if(oxynew>oxy)
			target.adjustOxyLoss(oxynew*-1 + oxy)
		if(toxinnew>toxin)
			target.adjustToxLoss(target.getToxLoss()*-1 + toxin)
		if(target.blood_volume<blood)
			target.blood_volume = blood
	else
		target.adjustBruteLoss(brutenew*-1 + brute)
		target.adjustFireLoss(burnnew*-1 + burn)
		target.adjustOxyLoss(oxynew*-1 + oxy)
		target.adjustToxLoss(target.getToxLoss()*-1 + toxin)
		target.blood_volume = blood
	playsound(target.loc, 'sound/magic/timereverse.ogg', 100, FALSE)

/obj/effect/proc_holder/spell/invoked/stasis/proc/play_indicator(mob/living/carbon/target, icon_path, overlay_name, clear_time, overlay_layer)
	if(!ishuman(target))
		return
	if(target.stat != DEAD)
		var/mob/living/carbon/humie = target
		var/datum/species/species =	humie.dna.species
		var/list/offset_list
		if(humie.gender == FEMALE)
			offset_list = species.offset_features[OFFSET_HEAD_F]
		else
			offset_list = species.offset_features[OFFSET_HEAD]
			var/mutable_appearance/appearance = mutable_appearance(icon_path, overlay_name, overlay_layer)
			if(offset_list)
				appearance.pixel_x += (offset_list[1])
				appearance.pixel_y += (offset_list[2]+12)
			appearance.appearance_flags = RESET_COLOR
			target.overlays_standing[OBJ_LAYER] = appearance
			target.apply_overlay(OBJ_LAYER)
			update_icon()
			addtimer(CALLBACK(humie, PROC_REF(clear_overhead_indicator), appearance, target), clear_time)

/obj/effect/proc_holder/spell/invoked/stasis/proc/clear_overhead_indicator(appearance,mob/living/carbon/target)
	target.remove_overlay(OBJ_LAYER)
	cut_overlay(appearance, TRUE)
	qdel(appearance)
	update_icon()
	return


//Universal miracle T3 miracle.
//Instantly heals all wounds & damage on a selected limb.
//Long CD (so a Medical class would still outpace this if there's more than one patient to heal)
/obj/effect/proc_holder/spell/invoked/wound_heal
	name = "Wound Miracle"
	desc = "Heals all wounds on a targeted limb."
	overlay_icon = 'icons/mob/actions/genericmiracles.dmi'
	overlay_state = "woundheal"
	action_icon_state = "woundheal"
	action_icon = 'icons/mob/actions/genericmiracles.dmi'
	releasedrain = 15
	chargedrain = 0
	chargetime = 3
	range = 1
	ignore_los = FALSE
	warnie = "sydwarning"
	movement_interrupt = TRUE
	chargedloop = /datum/looping_sound/invokeholy
	sound = 'sound/magic/woundheal.ogg'
	invocation_type = "none"
	associated_skill = /datum/skill/magic/holy
	antimagic_allowed = FALSE
	recharge_time = 2 MINUTES
	miracle = TRUE
	is_cdr_exempt = TRUE
	var/delay = 4.5 SECONDS	//Reduced to 1.5 seconds with Legendary
	devotion_cost = 100

/obj/effect/proc_holder/spell/invoked/wound_heal/cast(list/targets, mob/user = usr)
	if(ishuman(targets[1]))

		var/mob/living/carbon/human/target = targets[1]
		var/mob/living/carbon/human/HU = user
		var/def_zone = check_zone(user.zone_selected)
		var/obj/item/bodypart/affecting = target.get_bodypart(def_zone)

		if(HAS_TRAIT(target, TRAIT_PSYDONITE))
			target.visible_message(span_info("[target] stirs for a moment, then the miracle dissipates."), span_notice("A dull warmth swells in your heart, only to fade as quickly as it arrived."))
			user.playsound_local(user, 'sound/magic/PSY.ogg', 100, FALSE, -1)
			playsound(target, 'sound/magic/PSY.ogg', 100, FALSE, -1)
			return FALSE

		if(!affecting)
			revert_cast()
			return FALSE
		if(length(affecting.embedded_objects))
			var/no_embeds = TRUE
			for(var/object in affecting.embedded_objects)
				if(!istype(object, /obj/item/natural/worms/leech))	//Leeches and surgical cheeles are made an exception.
					no_embeds = FALSE
			if(!no_embeds)
				to_chat(user, span_warning("We cannot seal wounds with objects inside this limb!"))
				revert_cast()
				return FALSE
		if(!do_after(user, (delay - (0.5 SECONDS * HU.get_skill_level(associated_skill)))))
			revert_cast()
			to_chat(user, span_warning("We were interrupted!"))
			return FALSE
		var/foundwound = FALSE
		if(length(affecting.wounds))
			for(var/datum/wound/wound in affecting.wounds)
				if(!isnull(wound) && wound.healable_by_miracles)
					wound.heal_wound(wound.whp)
					foundwound = TRUE
					user.visible_message(("<font color = '#488f33'>The [wound.name] oozes a clear fluid and closes shut, forming into a sore bruise!</font>"))
					affecting.add_wound(/datum/wound/bruise/woundheal)
			if(foundwound)
				playsound(target, 'sound/magic/woundheal_crunch.ogg', 100, TRUE)
			affecting.change_bodypart_status(BODYPART_ORGANIC, heal_limb = TRUE)
			affecting.update_disabled()
			target.update_damage_hud()
			return TRUE
		else
			to_chat(user, span_warning("The limb is free of wounds."))
			revert_cast()
			return FALSE
	revert_cast()
	return FALSE


/obj/effect/proc_holder/spell/invoked/blood_heal
	name = "Bloodbond"
	desc = "Transfers some of my lyfeblood to a target in need."
	overlay_icon = 'icons/mob/actions/genericmiracles.dmi'
	overlay_state = "bloodheal"
	action_icon_state = "bloodheal"
	action_icon = 'icons/mob/actions/genericmiracles.dmi'
	releasedrain = 30
	chargedrain = 0
	chargetime = 0
	range = 7
	ignore_los = FALSE
	warnie = "sydwarning"
	movement_interrupt = TRUE
	sound = 'sound/magic/bloodheal.ogg'
	invocation_type = "none"
	associated_skill = /datum/skill/magic/holy
	antimagic_allowed = FALSE
	recharge_time = 15 SECONDS
	miracle = TRUE
	devotion_cost = 50
	var/blood_price_coefficient = 1.25
	var/blood_vol_restore = 7.5 // base value
	var/vol_per_skill = 3.75 // double at apprentice, triple at expert, quadruple at legendary
	var/delay = 1.5 SECONDS

/obj/effect/proc_holder/spell/invoked/blood_heal/proc/bond_check(mob/living/carbon/human/user, mob/living/target, revert = TRUE)
	if (!istype(user, /mob/living/carbon/human) || !istype(target, /mob/living/carbon/human))
		to_chat(user, span_warning("I can only forge a bloodbond with other humanoids!"))
		if (revert)
			revert_cast()
		return FALSE
	if (target == user)
		to_chat(user, span_warning("I can't start a bloodbond on myself! It has to be on someone else!"))
		if (revert)
			revert_cast()
		return
	if (!user.Adjacent(target))
		to_chat(user, span_warning("I need to be next to my target to maintain a bloodbond with them!"))
		if (revert)
			revert_cast()
		return FALSE
	if(NOBLOOD in user.dna?.species?.species_traits)
		to_chat(user, span_warning("I have no blood to provide."))
		if (revert)
			revert_cast()
		return FALSE
	if(target.blood_volume >= BLOOD_VOLUME_NORMAL)
		to_chat(user, span_warning("Their lyfeblood is at capacity. There is no need."))
		if (revert)
			revert_cast()
		return FALSE
	if(HAS_TRAIT(target, TRAIT_PSYDONITE))
		target.visible_message(span_info("[target] stirs for a moment, then the miracle dissipates."), span_notice("A dull warmth swells in your heart, only to fade as quickly as it arrived."))
		user.playsound_local(user, 'sound/magic/PSY.ogg', 100, FALSE, -1)
		playsound(target, 'sound/magic/PSY.ogg', 100, FALSE, -1)
		return FALSE

	return TRUE

/obj/effect/proc_holder/spell/invoked/blood_heal/cast(list/targets, mob/user = usr)
	if(ishuman(targets[1]))
		var/mob/living/carbon/human/target = targets[1]
		// Check if user is human before accessing dna
		if(!ishuman(user))
			to_chat(user, span_warning("I cannot transfer blood in this form!"))
			revert_cast()
			return FALSE
		var/mob/living/carbon/human/UH = user

		if (!bond_check(UH, target, revert = TRUE))
			return FALSE

		UH.visible_message(span_warning("Tiny strands of red link between [UH] and [target], and droplets of blood flow through it!"))
		playsound(UH, 'sound/magic/bloodheal_start.ogg', 100, TRUE)
		var/user_skill = UH.get_skill_level(associated_skill)
		
		// higher miracle skills let us transfer more of our blood at once, but don't really affect the efficiency all that much.
		var/actual_blood_vol_restore = blood_vol_restore
		actual_blood_vol_restore += (vol_per_skill * user_skill)

		// a cheele restores 300% of the original blood volume over a LONG period of time
		// we want bloodbond to be about 125% since it doesn't require an external item, is much faster, and uses two renewable resources (blood & devotion)
		var/actual_blood_price = actual_blood_vol_restore / blood_price_coefficient

		var/max_loops = max(round(UH.blood_volume / actual_blood_price, 1), 1)
		var/datum/beam/bloodbeam = user.Beam(target,icon_state="blood",time=(max_loops * 5))

		for(var/i in 1 to max_loops)
			if(UH.blood_volume > (BLOOD_VOLUME_SURVIVE / 2))
				if(do_after(UH, delay) && bond_check(UH, target, revert = FALSE) && UH.devotion?.check_devotion(src))
					target.blood_volume = min((target.blood_volume + actual_blood_vol_restore), BLOOD_VOLUME_NORMAL)
					UH.blood_volume = max((UH.blood_volume - actual_blood_price), 0)
					var/devo_cost = round(0 - (devotion_cost / max_loops), 1)
					UH.devotion?.update_devotion(devo_cost)
				else
					UH.visible_message(span_warning("The bloodbond between [UH] and [target] breaks!"))
					bloodbeam.End()
					return TRUE
			else
				UH.visible_message(span_warning("The bloodbond between [UH] and [target] breaks!"))
				bloodbeam.End()
				return TRUE
		bloodbeam.End()
		return TRUE
	revert_cast()
	return FALSE
