//============================================
// TIER 0 MIRACLES
//============================================

//T0. Removes cone vision for a dynamic duration.
/obj/effect/proc_holder/spell/self/astrata_gaze
	name = "Astratan Gaze"
	desc = "Call upon your patron to improve your sight to 360-degrees."
	overlay_state = "astrata_gaze"
	releasedrain = 10
	chargedrain = 0
	chargetime = 0
	chargedloop = /datum/looping_sound/invokeholy
	sound = 'sound/magic/astrata_choir.ogg'
	associated_skill = /datum/skill/magic/holy
	antimagic_allowed = FALSE
	invocation = "Astrata show me true."
	invocation_type = "shout"
	recharge_time = 120 SECONDS
	devotion_cost = 30
	miracle = TRUE

//T0. Ignites torches, ovens, undead, and candles.
/obj/effect/proc_holder/spell/invoked/ignition
	name = "Ignition"
	desc = "Ignite a flammable object at range."
	overlay_state = "sacredflame"
	releasedrain = 30
	chargedrain = 0
	chargetime = 0
	range = 15
	warnie = "sydwarning"
	movement_interrupt = FALSE
	chargedloop = null
	sound = 'sound/magic/heal.ogg'
	invocation = null
	invocation_type = null
	associated_skill = /datum/skill/magic/holy
	antimagic_allowed = TRUE
	recharge_time = 5 SECONDS
	miracle = TRUE
	devotion_cost = 10

//============================================
// TIER 1 MIRACLES
//============================================

// Sacred Flame - Ranged holy fire beam that deals extra damage to undead
/obj/effect/proc_holder/spell/invoked/projectile/lightningbolt/sacred_flame_rogue
	name = "Sacred Flame"
	desc = "Launch a laser of holy fire at your target, setting them aflame. Deals increased damage to undead."
	overlay_state = "sacredflame"
	sound = 'sound/magic/bless.ogg'
	req_items = list(/obj/item/clothing/neck/roguetown/psicross)
	invocation = null
	invocation_type = "shout"
	associated_skill = /datum/skill/magic/holy
	antimagic_allowed = TRUE
	recharge_time = 20 SECONDS
	miracle = TRUE
	devotion_cost = 50
	projectile_type = /obj/projectile/magic/astratablast

//============================================
// TIER 2 MIRACLES
//============================================

// Tyrant's Strike - T2 weapon enhancement that adds pain and stress
/obj/effect/proc_holder/spell/self/tyrants_strike
	name = "Tyrant's Strike"
	desc = "Enhance your weapon with divine wrath. Your next strike will inflict great pain and terror upon your foe."
	overlay = "createlight"
	recharge_time = 1 MINUTES
	movement_interrupt = FALSE
	chargedrain = 0
	chargetime = 1 SECONDS
	charging_slowdown = 2
	chargedloop = null
	associated_skill = /datum/skill/magic/holy
	req_items = list(/obj/item/clothing/neck/roguetown/psicross)
	sound = 'sound/magic/timestop.ogg'
	invocation = "Feel Astrata's wrath!"
	invocation_type = "shout"
	antimagic_allowed = TRUE
	miracle = TRUE
	devotion_cost = 50

//============================================
// TIER 3 MIRACLES  
//============================================

// Sun's Shield - Fire resistance ability granted by ritual
/obj/effect/proc_holder/spell/self/suns_shield
	name = "Sun's Shield"
	desc = "Call upon Astrata's blessing to shield yourself and nearby divine followers from flame."
	overlay_state = "burning"
	recharge_time = 4 MINUTES
	invocation = "By Her light, we are shielded!"
	invocation_type = "shout"
	sound = 'sound/magic/holyshield.ogg'

// Anastasis - Revive a dead target or obliterate undead
/obj/effect/proc_holder/spell/invoked/revive
	name = "Anastasis"
	desc = "Call upon Her greatness to return lyfe to a dead target. Obliterates the undead."
	overlay_state = "revive"
	releasedrain = 90
	chargedrain = 0
	chargetime = 50
	range = 1
	warnie = "sydwarning"
	no_early_release = TRUE
	movement_interrupt = TRUE
	chargedloop = /datum/looping_sound/invokeholy
	req_items = list(/obj/item/clothing/neck/roguetown/psicross)
	sound = 'sound/magic/revive.ogg'
	associated_skill = /datum/skill/magic/holy
	antimagic_allowed = TRUE
	recharge_time = 2 MINUTES
	miracle = TRUE
	devotion_cost = 80
	/// Amount of PQ gained for reviving people
	var/revive_pq = PQ_GAIN_REVIVE

//============================================
// TIER 4 MIRACLES
//============================================

// Tyrant's Decree - T4 pain/stress check that forces kneeling
/obj/effect/proc_holder/spell/invoked/tyrants_decree
	name = "Tyrant's Decree"
	desc = "Command the weak to kneel before Astrata's authority. Those wracked with pain and terror will be forced to submit."
	overlay = "createlight"
	releasedrain = 50
	chargedrain = 0
	chargetime = 2 SECONDS
	range = 7
	warnie = "sydwarning"
	movement_interrupt = FALSE
	chargedloop = /datum/looping_sound/invokeholy
	req_items = list(/obj/item/clothing/neck/roguetown/psicross)
	sound = 'sound/magic/churn.ogg'
	invocation = "KNEEL BEFORE HER LIGHT!!"
	invocation_type = "shout"
	associated_skill = /datum/skill/magic/holy
	antimagic_allowed = TRUE
	recharge_time = 5 MINUTES
	miracle = TRUE
	devotion_cost = 100

//============================================
// STATUS EFFECTS & SUPPORTING CODE
//============================================

//T0. Astratan Gaze Support Code
/obj/effect/proc_holder/spell/self/astrata_gaze/cast(list/targets, mob/user)
	if(!ishuman(user))
		revert_cast()
		return FALSE
	var/mob/living/carbon/human/H = user
	var/skill_level = H.get_skill_level(associated_skill)
	H.apply_status_effect(/datum/status_effect/buff/astrata_gaze, skill_level)
	return TRUE

/atom/movable/screen/alert/status_effect/buff/astrata_gaze
	name = "Astratan's Gaze"
	desc = "She shines through me, illuminating all injustice."
	icon_state = "astrata_gaze"

/datum/status_effect/buff/astrata_gaze
	id = "astratagaze"
	alert_type = /atom/movable/screen/alert/status_effect/buff/astrata_gaze
	duration = 20 SECONDS
	var/skill_level = 0
	status_type = STATUS_EFFECT_REPLACE

/datum/status_effect/buff/astrata_gaze/on_creation(mob/living/new_owner, slevel)
    // Only store skill level here
    skill_level = slevel
    .=..()

/datum/status_effect/buff/astrata_gaze/on_apply()
	// Reset base values because the miracle can 
	// now actually be recast at high enough skill and during day time
	// This is a safeguard because buff code makes my head hurt
    var/per_bonus = 0
    duration = 20 SECONDS

    if(skill_level > SKILL_LEVEL_NOVICE)
        per_bonus++

    if(GLOB.tod == "day" || GLOB.tod == "dawn")
        per_bonus++
        duration *= 2

    duration *= skill_level

    if(per_bonus)
        effectedstats = list(STATKEY_PER = per_bonus)

    if(ishuman(owner))
        var/mob/living/carbon/human/H = owner
        H.viewcone_override = TRUE
        H.hide_cone()
        H.update_cone_show()

    to_chat(owner, span_astrata("She shines through me! I can perceive all clear as dae!"))

    return ..()

/datum/status_effect/buff/astrata_gaze/on_remove()
	. = ..()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.viewcone_override = FALSE
		H.hide_cone()
		H.update_cone_show()

//T0 Ignition Support Code
/obj/effect/proc_holder/spell/invoked/ignition/cast(list/targets, mob/user = usr)
	. = ..()
	// Spell interaction with ignitable objects (burn wooden things, light torches up)
	if(isobj(targets[1]))
		var/obj/O = targets[1]
		if(O.fire_act())
			user.visible_message(span_astrata("[user] points at [O], igniting it with sacred flames!"))
			return TRUE
		else
			to_chat(user, span_warning("You point at [O], but it fails to catch fire."))
			return FALSE
	// Check if target is an undead mob
	if(ismob(targets[1]))
		var/mob/living/M = targets[1]
		if(M.mob_biotypes & MOB_UNDEAD)
			M.adjust_fire_stacks(1, /datum/status_effect/fire_handler/fire_stacks/sunder)
			M.ignite_mob()
			user.visible_message(span_astratabig("[user] points at [M], igniting them with searing holy flames!"))
			return TRUE
	revert_cast()
	return FALSE


//T1. Sacred Flame Support Code
/obj/projectile/magic/astratablast
	damage = 25
	name = "ray of holy fire"
	nodamage = FALSE
	damage_type = BURN
	speed = 0.3
	muzzle_type = null
	impact_type = null
	hitscan = TRUE
	flag = "magic"
	light_color = "#a98107"
	light_outer_range = 7
	tracer_type = /obj/effect/projectile/tracer/solar_beam
	var/fuck_that_guy_multiplier = 2
	var/biotype_we_look_for = MOB_UNDEAD

/obj/projectile/magic/astratablast/on_hit(target)
	. = ..()
	if(ismob(target))
		var/mob/living/M = target
		if(M.anti_magic_check())
			visible_message(span_warning("[src] fizzles on contact with [target]!"))
			playsound(get_turf(target), 'sound/magic/magic_nulled.ogg', 100)
			qdel(src)
			return BULLET_ACT_BLOCK
		if(M.mob_biotypes & biotype_we_look_for || istype(M, /mob/living/simple_animal/hostile/rogue/skeleton))
			damage *= fuck_that_guy_multiplier
			// Apply sunder firestacks to undead instead of regular fire
			M.adjust_fire_stacks(5, /datum/status_effect/fire_handler/fire_stacks/sunder)
			visible_message(span_warning("[target] erupts in searing holy flame upon being struck by [src]!"))
			M.ignite_mob()
		else
			M.adjust_fire_stacks(4) //2 pats to put it out
			visible_message(span_warning("[src] ignites [target]!"))
			M.ignite_mob()
	return FALSE


//T2. Tyrant's Strike Support Code
/obj/effect/proc_holder/spell/self/tyrants_strike/cast(mob/living/user)
	if(!isliving(user))
		return FALSE
	user.apply_status_effect(/datum/status_effect/tyrants_strike, user.get_active_held_item())
	return TRUE

/datum/status_effect/tyrants_strike
	id = "tyrants_strike"
	status_type = STATUS_EFFECT_UNIQUE
	duration = 15 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/buff/tyrants_strike
	on_remove_on_mob_delete = TRUE
	var/datum/weakref/buffed_item

/datum/status_effect/tyrants_strike/on_creation(mob/living/new_owner, obj/item/I)
	. = ..()
	if(!.)
		return
	if(istype(I) && !(I.item_flags & ABSTRACT))
		buffed_item = WEAKREF(I)
		if(!I.light_outer_range && I.light_system == STATIC_LIGHT)
			I.set_light(1)
		RegisterSignal(I, COMSIG_ITEM_AFTERATTACK, PROC_REF(item_afterattack))
	else
		RegisterSignal(owner, COMSIG_MOB_ATTACK_HAND, PROC_REF(hand_attack))

/datum/status_effect/tyrants_strike/on_remove()
	. = ..()
	UnregisterSignal(owner, COMSIG_MOB_ATTACK_HAND)
	if(buffed_item)
		var/obj/item/I = buffed_item.resolve()
		if(istype(I))
			I.set_light(0)
		UnregisterSignal(I, COMSIG_ITEM_AFTERATTACK)

/datum/status_effect/tyrants_strike/proc/item_afterattack(obj/item/source, atom/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag)
		return
	if(!isliving(target))
		return
	var/mob/living/living_target = target
	
	// Get the bodypart that was hit
	var/obj/item/bodypart/affecting = living_target.get_bodypart(ran_zone(user.zone_selected))
	if(!affecting)
		affecting = living_target.get_bodypart(BODY_ZONE_CHEST)
	
	// Apply the Tyrant's Strike wound - this only adds pain, no bleeding
	var/datum/wound/tyrants_strike/W = new()
	affecting.add_wound(W)
	
	// Estimate damage from the weapon for wound upgrade (pain calculation only)
	var/estimated_damage = 20  // Default
	if(istype(source, /obj/item/rogueweapon))
		var/obj/item/rogueweapon/weapon = source
		estimated_damage = weapon.force
	
	W.upgrade(estimated_damage, 0)  // 0 armor for full pain effect
	
	// Add stress event
	living_target.add_stress(/datum/stressevent/tyrants_strike)
	
	living_target.visible_message(span_warning("Divine light erupts from [user]'s strike against [living_target]!"), \
		span_userdanger("Searing pain floods through me from [user]'s strike!"))
	
	qdel(src)

/datum/status_effect/tyrants_strike/proc/hand_attack(datum/source, mob/living/carbon/human/M, mob/living/carbon/human/H, datum/martial_art/attacker_style)
	if(!istype(M))
		return
	if(!istype(H))
		return
	if(!istype(M.used_intent, INTENT_HARM))
		return
	
	// Get the bodypart that was hit
	var/obj/item/bodypart/affecting = H.get_bodypart(ran_zone(M.zone_selected))
	if(!affecting)
		affecting = H.get_bodypart(BODY_ZONE_CHEST)
	
	// Apply the wound (pain only)
	var/datum/wound/tyrants_strike/W = new()
	affecting.add_wound(W)
	W.upgrade(10, 0)  // Unarmed strike - less damage, less pain
	
	// Add stress event
	H.add_stress(/datum/stressevent/tyrants_strike)
	
	H.visible_message(span_warning("Divine light erupts from [M]'s strike against [H]!"), \
		span_userdanger("Searing pain floods through me from [M]'s strike!"))
	
	qdel(src)

/atom/movable/screen/alert/status_effect/buff/tyrants_strike
	name = "Tyrant's Strike"
	desc = "My weapon glows with divine wrath. My next strike will bring pain and terror."
	icon_state = "strike"


//T3. Sun's shield Support Code
/obj/effect/proc_holder/spell/self/suns_shield/cast(list/targets, mob/living/user = usr)
	var/is_day = (GLOB.tod == "day")
	var/user_duration = is_day ? 2 MINUTES : 1 MINUTES
	var/ally_duration = user_duration / 2
	
	// Clear user's firestacks and extinguish them
	if(isliving(user))
		var/mob/living/L = user
		L.adjust_fire_stacks(-L.fire_stacks)
		var/datum/status_effect/fire_handler/fire_stacks/FS = L.has_status_effect(/datum/status_effect/fire_handler/fire_stacks)
		if(FS)
			FS.extinguish()
	
	// Apply to user
	user.apply_status_effect(/datum/status_effect/buff/suns_shield, user_duration)
	to_chat(user, span_astratabig("Astrata's radiance flows through you, shielding you from flame!"))
	
	// Apply to nearby divine pantheon followers
	for(var/mob/living/carbon/target in view(3, get_turf(user)))
		if(target == user)
			continue
		if(!istype(target.patron, /datum/patron/divine))
			continue
		if(!user.faction_check_mob(target))
			continue
		if(target.mob_biotypes & MOB_UNDEAD)
			continue
		
		target.apply_status_effect(/datum/status_effect/buff/suns_shield, ally_duration)
		to_chat(target, span_astrata("Astrata's blessing shields you from flame!"))
	
	return TRUE

/datum/status_effect/buff/suns_shield
	id = "suns_shield"
	alert_type = /atom/movable/screen/alert/status_effect/buff/suns_shield
	effectedstats = null
	
/datum/status_effect/buff/suns_shield/on_apply()
	. = ..()
	ADD_TRAIT(owner, TRAIT_NOFIRE, "[type]")
	to_chat(owner, span_astrata("I am shielded from flame by Astrata's light!"))

/datum/status_effect/buff/suns_shield/on_remove()
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_NOFIRE, "[type]")
	to_chat(owner, span_warning("Astrata's flame shield fades."))

/atom/movable/screen/alert/status_effect/buff/suns_shield
	name = "Sun's Shield"
	desc = "Astrata's blessing shields me from flame."
	icon_state = "immolation"


//T3. Anastasis Support Code
/obj/effect/proc_holder/spell/invoked/revive/cast(list/targets, mob/living/user)
	. = ..()
	if(isliving(targets[1]))
		testing("revived1")
		var/mob/living/target = targets[1]
		// Check for undead FIRST - obliterate them with holy light
		if((target.mob_biotypes & MOB_UNDEAD) && !HAS_TRAIT(target, TRAIT_HOLLOW_LIFE))
			if(GLOB.tod == "night")
				to_chat(user, span_astratabig("Let there be light."))
			for(var/obj/structure/fluff/psycross/S in oview(5, user))
				S.AOE_flash(user, range = 8)
			target.visible_message(span_danger("[target] is unmade by holy light!"), span_userdanger("I'm unmade by holy light!"))
			target.gib()
			return TRUE
		// Block if excommunicated and caster is divine pantheon
		if(istype(user, /mob/living)) {
			var/mob/living/LU = user
			var/excomm_found = FALSE
			for(var/excomm_name in GLOB.excommunicated_players)
				var/clean_excomm = lowertext(trim(excomm_name))
				var/clean_target = lowertext(trim(target.real_name))
				if(clean_excomm == clean_target)
					excomm_found = TRUE
					break
			if(ispath(LU.patron?.type, /datum/patron/divine) && excomm_found) {
				to_chat(user, span_danger("The gods recoil from [target]! Divine fire scorches your hands as your plea is rejected!"))
				target.visible_message(span_danger("[target] is seared by divine wrath! The gods hate them!"), span_userdanger("I am seared by divine wrath! The gods hate me!"))
				revert_cast()
				return FALSE
			}
		}
		var/mob/dead/observer/spirit = target.get_spirit()
		//GET OVER HERE!
		if(spirit)
			var/mob/dead/observer/ghost = spirit.ghostize()
			qdel(spirit)
			ghost.mind.transfer_to(target, TRUE)
		target.grab_ghost(force = FALSE)
		if(!target.check_revive(user))
			revert_cast()
			return FALSE
		if(GLOB.tod == "night")
			to_chat(user, span_astratabig("Let there be light."))
		for(var/obj/structure/fluff/psycross/S in oview(5, user))
			S.AOE_flash(user, range = 8)
		target.adjustOxyLoss(-target.getOxyLoss()) //Ye Olde CPR
		if(!target.revive(full_heal = FALSE))
			to_chat(user, span_warning("Nothing happens."))
			revert_cast()
			return FALSE
		testing("revived2")
		target.emote("breathgasp")
		target.Jitter(100)
		record_round_statistic(STATS_ASTRATA_REVIVALS)
		target.update_body()
		target.visible_message(span_astratabig("[target] is revived by holy light!"), span_green("I awake from the void."))
		if(revive_pq && !HAS_TRAIT(target, TRAIT_IWASREVIVED) && user?.ckey)
			adjust_playerquality(revive_pq, user.ckey)
			ADD_TRAIT(target, TRAIT_IWASREVIVED, "[type]")
		target.mind.remove_antag_datum(/datum/antagonist/zombie)
		target.remove_status_effect(/datum/status_effect/debuff/rotted_zombie)	//Removes the rotted-zombie debuff if they have it - Failsafe for it.
		target.apply_status_effect(/datum/status_effect/debuff/revived)	//Temp debuff on revive, your stats get hit temporarily. Doubly so if having rotted.
		return TRUE
	revert_cast()
	return FALSE

/obj/effect/proc_holder/spell/invoked/revive/cast_check(skipcharge = 0,mob/user = usr)
	if(!..())
		return FALSE
	var/found = null
	for(var/obj/structure/fluff/psycross/S in oview(5, user))
		found = S
	if(!found)
		to_chat(user, span_warning("I need a holy cross."))
		return FALSE
	return TRUE


//T4. Tyrant's Decree Support Code
/obj/effect/proc_holder/spell/invoked/tyrants_decree/cast(list/targets, mob/user = usr)
	if(!isliving(targets[1]))
		return FALSE
	
	var/mob/living/carbon/target = targets[1]
	
	// Get target's stress and pain
	var/target_stress = target.get_stress_amount()
	var/target_pain = 0
	
	if(iscarbon(target))
		// Get pain and convert to stress equivalent (100 pain = 1 stress)
		target_pain = target.get_complex_pain() / 100
	
	var/total_suffering = target_stress + target_pain
	
	// Visual effect
	target.remove_overlay(MUTATIONS_LAYER)
	var/mutable_appearance/divine_overlay = mutable_appearance('icons/effects/clan.dmi', "presence", -MUTATIONS_LAYER)
	divine_overlay.pixel_z = 1
	target.overlays_standing[MUTATIONS_LAYER] = divine_overlay
	target.apply_overlay(MUTATIONS_LAYER)
	
	// Determine effect based on suffering threshold
	if(total_suffering < 4)
		// Not enough suffering - minor effect
		to_chat(target, span_userdanger("The divine command washes over me, but I stand firm!"))
		target.visible_message(span_warning("[target] resists [user]'s command!"))
		target.Immobilize(1 SECONDS)
	else if(total_suffering < 11)
		// Stage 1 - Hesitation and brief immobilization
		to_chat(target, span_astrata("The weight of divine authority bears down on me!"))
		target.visible_message(span_warning("[user]'s command staggers [target]!"))
		target.Immobilize(3 SECONDS)
		target.add_stress(/datum/stressevent/tyrants_strike)  // Add more stress from being dominated
	else if(total_suffering < 19)
		// Stage 2 - Forced to kneel
		to_chat(target, span_astratabig("I cannot resist! My legs give out beneath me!"))
		target.visible_message(span_astrata("[target] is forced to their knees by [user]'s divine command!"))
		target.Immobilize(5 SECONDS)
		target.set_resting(TRUE, TRUE)
		target.add_stress(/datum/stressevent/tyrants_strike)
	else
		// Stage 3 - Severe kneeling with extended duration
		to_chat(target, span_astrataextreme("ASTRATA'S AUTHORITY IS ABSOLUTE! I MUST KNEEL!"))
		target.visible_message(span_astratabig("[target] collapses before [user], overwhelmed by divine wrath!"))
		target.Immobilize(8 SECONDS)
		target.set_resting(TRUE, TRUE)
		target.AdjustKnockdown(20)  // Extra knockdown time
		target.add_stress(/datum/stressevent/tyrants_strike)
	
	// Remove overlay after a delay
	addtimer(CALLBACK(target, TYPE_PROC_REF(/mob, remove_overlay), MUTATIONS_LAYER), 3 SECONDS)
	
	return TRUE
