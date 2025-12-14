#define EQUALIZED_GLOW "equalizer glow"

// T0: Determine the net mammon value of target

/obj/effect/proc_holder/spell/invoked/appraise
	name = "Appraise"
	overlay_state = "appraise"
	releasedrain = 10
	chargedrain = 0
	chargetime = 0
	range = 2
	warnie = "sydwarning"
	movement_interrupt = FALSE
	invocation_type = "none"
	associated_skill = /datum/skill/magic/holy
	antimagic_allowed = TRUE
	recharge_time = 5 SECONDS 
	miracle = TRUE
	devotion_cost = 0 

/obj/effect/proc_holder/spell/invoked/appraise/secular
	name = "Secular Appraise"
	overlay_state = "appraise"
	range = 2
	associated_skill = /datum/skill/misc/reading // idk reading is like Accounting right
	miracle = FALSE
	devotion_cost = 0 //Merchants are not clerics


/obj/effect/proc_holder/spell/invoked/appraise/cast(list/targets, mob/living/user)
	if(ishuman(targets[1]))
		var/mob/living/carbon/human/target = targets[1]
		var/mammonsonperson = get_mammons_in_atom(target)
		var/mammonsinbank = SStreasury.bank_accounts[target] ? SStreasury.bank_accounts[target] : 0
		var/totalvalue = mammonsinbank + mammonsonperson
		to_chat(user, ("<font color='yellow'>[target] has [mammonsonperson] mammons on them, [mammonsinbank] in their meister, for a total of [totalvalue] mammons.</font>"))

/obj/effect/proc_holder/spell/invoked/appraise/secular/pileappraisal
	name = "Pile Appraise"
	range = 1

/obj/effect/proc_holder/spell/invoked/appraise/secular/pileappraisal/cast(list/targets, mob/living/user)
	var/turf/T = get_turf(targets[1])
	var/totalvalue = 0
	for(var/obj/O in T.contents)
		if(O.sellprice)
			totalvalue += O.get_real_price()
	to_chat(user, ("<font color='yellow'>That pile of items costs around [totalvalue] mammons.</font>"))

// T1 - Take value of item in hand, apply that as healing. Destroys item.

/obj/effect/proc_holder/spell/invoked/transact
	name = "Transact"
	overlay_state = "transact"
	releasedrain = 30
	chargedrain = 0
	chargetime = 0
	range = 4
	warnie = "sydwarning"
	movement_interrupt = FALSE
	invocation_type = "none"
	associated_skill = /datum/skill/magic/holy
	antimagic_allowed = TRUE
	recharge_time = 20 SECONDS
	miracle = TRUE
	devotion_cost = 20

/obj/effect/proc_holder/spell/invoked/transact/proc/get_most_damaged_limb(mob/living/carbon/C)
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

/obj/effect/proc_holder/spell/invoked/transact/cast(list/targets, mob/living/user)
	. = ..()
	var/obj/item/held_item = user.get_active_held_item()
	if(!held_item)
		to_chat(user, span_info("I need something of value to make a transaction..."))
		return
	var/helditemvalue = held_item.get_real_price()
	if(!helditemvalue)
		to_chat(user, span_info("This has no value, It will be of no use In such a transaction."))
		return
	if(helditemvalue<10)
		to_chat(user, span_info("This has little value, It will be of no use In such a transaction."))
		return
	if(isliving(targets[1]))
		var/mob/living/target = targets[1]
		if(HAS_TRAIT(target, TRAIT_PSYDONITE))
			user.playsound_local(user, 'sound/magic/PSY.ogg', 100, FALSE, -1)
			target.visible_message(span_info("[target] stirs for a moment, the miracle dissipates."), span_notice("A dull warmth swells in your heart, only to fade as quickly as it arrived."))
			playsound(target, 'sound/magic/PSY.ogg', 100, FALSE, -1)
			return FALSE
		user.visible_message(span_notice("The transaction Is made, [target] Is bathed In empowerment!"))
		to_chat(user, "<font color='yellow'>[held_item] burns into the air suddenly, my Transaction is accepted.</font>")
		if(iscarbon(target))
			var/mob/living/carbon/C = target
			var/obj/item/bodypart/most_damaged_limb = get_most_damaged_limb(C)

			// Always apply the status effect for visual effects
			C.apply_status_effect(/datum/status_effect/buff/healing, helditemvalue/2)

			if(most_damaged_limb && most_damaged_limb.get_damage() > 0)
				// Apply healing to the most damaged limb
				most_damaged_limb.heal_damage(helditemvalue, helditemvalue, helditemvalue)
				C.update_damage_overlays()
				to_chat(C, span_notice("The miracle mends my [most_damaged_limb.name]!"))
			playsound(user, 'sound/combat/hits/burn (2).ogg', 100, TRUE)
			qdel(held_item)
		else
			target.adjustBruteLoss(-helditemvalue/2)
			target.adjustFireLoss(-helditemvalue/2)
			playsound(user, 'sound/combat/hits/burn (2).ogg', 100, TRUE)
			qdel(held_item)
		return TRUE
	revert_cast()
	return FALSE

// T2 We're going to debuff a targets stats = to the difference between us and them in total stats. 

/obj/effect/proc_holder/spell/invoked/equalize
	name = "Equalize"
	desc = "Create equality, with a thumb on the scales, with your target. Siphon strength, speed, and constitution from them."
	overlay_state = "equalize"
	clothes_req = FALSE
	overlay_state = "equalize"
	associated_skill = /datum/skill/magic/holy
	chargedloop = /datum/looping_sound/invokeascendant
	sound = 'sound/magic/swap.ogg'
	chargedrain = 0
	chargetime = 50
	releasedrain = 60
	no_early_release = TRUE
	antimagic_allowed = TRUE
	movement_interrupt = FALSE
	recharge_time = 2 MINUTES
	range = 4


/obj/effect/proc_holder/spell/invoked/equalize/cast(list/targets, mob/living/user)
	if(ishuman(targets[1]))
		var/mob/living/target = targets[1]
		target.apply_status_effect(/datum/status_effect/debuff/equalizedebuff)
		user.apply_status_effect(/datum/status_effect/buff/equalizebuff)
		return TRUE
	revert_cast()
	return FALSE


 // buff
/datum/status_effect/buff/equalizebuff
	id = "equalize"
	alert_type = /atom/movable/screen/alert/status_effect/buff/equalized
	effectedstats = list("strength" = 2, "constitution" = 2, "speed" = 2)
	duration = 1 MINUTES
	var/outline_colour = "#FFD700"


/atom/movable/screen/alert/status_effect/buff/equalized
	name = "Equalized"
	desc = "Equalized, with a gentle thumb on the scale, tactfully."

/datum/status_effect/buff/equalizebuff/on_apply()
	. = ..()
	owner.add_filter(EQUALIZED_GLOW, 2, list("type" = "outline", "color" = outline_colour, "alpha" = 200, "size" = 1))

/datum/status_effect/buff/equalizebuff/on_remove()
	. = ..()
	owner.remove_filter(EQUALIZED_GLOW)
	to_chat(owner, "<font color='yellow'>My link wears off, their stolen fire returns to them</font>")


 // debuff
/datum/status_effect/debuff/equalizedebuff
	id = "equalize"
	alert_type = /atom/movable/screen/alert/status_effect/buff/equalized
	effectedstats = list("strength" = -2, "constitution" = -2, "speed" = -2)
	duration = 1 MINUTES
	var/outline_colour = "#FFD700"

/atom/movable/screen/alert/status_effect/debuff/equalized
	name = "Equalized"
	desc = "My fire is stolen from me!"

/datum/status_effect/debuff/equalizedebuff/on_apply()
	. = ..()
	owner.add_filter(EQUALIZED_GLOW, 2, list("type" = "outline", "color" = outline_colour, "alpha" = 200, "size" = 1))

/datum/status_effect/debuff/equalizedebuff/on_remove()
	. = ..()
	owner.remove_filter(EQUALIZED_GLOW)
	to_chat(owner, "<font color='yellow'>My fire returns to me!</font>")

//T3 COUNT WEALTH, HURT TARGET/APPLY EFFECTS BASED ON AMOUNT OF WEALTH. AT 500+, OLD STYLE CHURNS THE TARGET.

/obj/effect/proc_holder/spell/invoked/churnwealthy
	name = "Churn Wealthy"
	desc = "Empowering the weak often involves destroying the strong."
	clothes_req = FALSE
	overlay_state = "churnwealthy"
	associated_skill = /datum/skill/magic/holy
	chargedloop = /datum/looping_sound/invokeascendant
	chargedrain = 0
	chargetime = 50
	releasedrain = 90
	no_early_release = TRUE
	antimagic_allowed = TRUE
	movement_interrupt = FALSE
	recharge_time = 2 MINUTES
	range = 4

/obj/effect/proc_holder/spell/invoked/churnwealthy/cast(list/targets, mob/living/user)
	if(ishuman(targets[1]))
		var/mob/living/carbon/human/target = targets[1]

		if(user.z != target.z) //Stopping no-interaction snipes
			to_chat(user, "<font color='yellow'>The Free-God compels me to face [target] on level ground before I transact.</font>")
			revert_cast()
			return
		var/mammonsonperson = get_mammons_in_atom(target)
		var/mammonsinbank = SStreasury.bank_accounts[target]
		var/totalvalue = mammonsinbank + mammonsonperson

		if(HAS_TRAIT(target, TRAIT_NOBLE))
			totalvalue += 101 // We're ALWAYS going to do a medium level smite minimum to nobles.

		var/fire_dmg = 0
		var/oxy_dmg = 0
		var/stun_to_apply = 0
		var/thing_to_say = "Wealth becomes woe!"
		var/fire_stacks = 0

		switch (totalvalue)
			if (0 to 10)
				to_chat(user, "<font color='yellow'>[target] one has no wealth to hold against them.</font>")
				revert_cast()
				return
			if (11 to 30)
				fire_dmg = 30
			if (31 to 60)
				fire_dmg = 60
			if (61 to 100)
				thing_to_say = "The Free-God rebukes!"
				fire_dmg = 80
				stun_to_apply = 20
			if (101 to 200)
				fire_dmg = 100
				stun_to_apply = 20
				fire_stacks = 7
			if (201 to 500)
				fire_dmg = 120
				fire_stacks = 9
				stun_to_apply = 40
			if (501 to INFINITY)
				thing_to_say = "YOUR FINAL TRANSACTION! THE FREE-GOD REBUKES!!"
				stun_to_apply = 60
				fire_stacks = 10
				fire_dmg = 150
				oxy_dmg = 50
				explosion(get_turf(target), light_impact_range = 1, flame_range = 1, smoke = FALSE)

		if (thing_to_say)
			user.say(thing_to_say)

		if (fire_dmg)
			target.adjustFireLoss(fire_dmg)
		
		if (oxy_dmg)
			target.adjustOxyLoss(oxy_dmg)

		var/combined_dmg = fire_dmg + oxy_dmg

		if (combined_dmg >= 150)
			target.emote("agony")

		if (stun_to_apply)
			target.Stun(stun_to_apply)
		
		if (fire_stacks)
			target.adjust_fire_stacks(fire_stacks, /datum/status_effect/fire_handler/fire_stacks/divine)
			target.ignite_mob()
		
		target.visible_message(span_danger("[target] is burned by holy light!"), span_userdanger("I feel the weight of my wealth burning at my soul!"))
		playsound(user, 'sound/magic/churn.ogg', 100, TRUE)
