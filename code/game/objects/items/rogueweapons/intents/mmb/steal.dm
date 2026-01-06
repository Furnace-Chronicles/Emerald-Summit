/datum/intent/steal
	name = "steal"
	candodge = FALSE
	canparry = FALSE
	chargedrain = 0
	chargetime = 0
	noaa = TRUE

/// Determines what ends up in the end list of things pickpocket can attempt to steal.
/datum/intent/steal/proc/can_steal(obj/item/thing, mob/living/carbon/human/target)
	if (!thing)
		return FALSE

	// can't steal armored items from someone in combat mode
	if (isclothing(thing))
		var/obj/item/clothing/thing_clothing = thing
		if (target.cmode && thing_clothing.armor)
			if (target.IsUnconscious() || !(target.mobility_flags & MOBILITY_STAND))
				return TRUE
			else
				return FALSE

	// can't steal long items (like longswords, spears, etc) unless they're floored or KO'd
	if (thing.wlength > WLENGTH_NORMAL)
		if (target.IsUnconscious() || !(target.mobility_flags & MOBILITY_STAND))
			return TRUE
		else
			return FALSE

	// can't steal especially heavy items unless they're floored or KO'd
	if (thing.w_class > WEIGHT_CLASS_NORMAL)
		if (target.IsUnconscious() || !(target.mobility_flags & MOBILITY_STAND))
			return TRUE
		else
			return FALSE
		
		return FALSE

	return TRUE

/datum/intent/steal/on_mmb(atom/target, mob/living/user, params)
	if(!target.Adjacent(user))
		return

	if(ishuman(target))
		var/mob/living/carbon/human/user_human = user
		var/mob/living/carbon/human/target_human = target

		if(user_human.get_active_held_item())
			to_chat(user, span_warning("I can't pickpocket while my hand is full!"))
			return

		// the last changes made to pickpocket made it horrendously fucking overpowered, so here's what we're doing
		// most pickpocketing classes are keyed to expert - expert is 4d6, which averages out to about 14
		var/thiefskill = user.get_skill_level(/datum/skill/misc/stealing) + (has_world_trait(/datum/world_trait/matthios_fingers) ? 2 : 0)
		var/initialstealroll = roll("[thiefskill]d6")
		var/advantageroll = 0
		var/targetperception = (target_human.STAPER) + ((target_human.STALUC - 10)) // perception, and their luck above or below 10
		
		var/do_time = 5 // how long we take to actually pickpocket in deciseconds - being risked up will quadruple this, in essence
		// if we're lucky, it's worse for them. if we're unlucky, it's better for them
		if (user.STALUC > 10)
			targetperception -= (user.STALUC - 10)
		else if (user.STALUC < 10)
			targetperception += (user.STALUC - 10)

		// if they're alert, they get a big ass bonus. cmode is also checked in can_steal for things like armor
		if(target_human.cmode)
			targetperception += 7 // d6 average is 3.5, so this on average, accomodates for roughly 2 ranks of thieving skill
			to_chat(user, span_notice("[target_human] is tense and is more likely to detect me."))

		// if we're rumbled, they're harder to steal from
		if(user.has_status_effect(/datum/status_effect/debuff/risk_low))
			targetperception += 2
			do_time += 5
		
		// if we're BUSTED they're MUCH harder to steal from
		if(user.has_status_effect(/datum/status_effect/debuff/risk_high))
			targetperception += 4
			do_time += 10

		if(HAS_TRAIT(user, TRAIT_CULTIC_THIEF) || user.goodluck(20)) // advantage if matthios patron and 20% chance per fortune above 10
			advantageroll = roll("[thiefskill]d6") // mathematically, advantage on a d6 works out to about +1~ ish overall
		
		// Used for showing fail chance.
		//___TraitAddvar/chance2steal = max(round(((12 + (thiefskill * 2) + (user.STASPD / 3) - (targetperception)) / 12 ) * 100, 1), 0)

		var/stealroll = max(initialstealroll, advantageroll)

		var/list/stealablezones = list("chest", "neck", "groin", "r_hand", "l_hand")
		var/list/stealpos = list()
		var/list/mobsbehind = list()

		var/exp_to_gain = user_human.STAINT

		to_chat(user, span_notice("I try to steal from [target_human]..."))

		if(do_after(user, do_time, target = target_human, progress = 0))

			if(target_human.IsUnconscious() || target_human.stat != CONSCIOUS) //They're out of it bro.
				targetperception = 0

			if(stealroll > targetperception)
				//TODO add exp here

				if(HAS_TRAIT(user, TRAIT_CULTIC_THIEF) && initialstealroll < targetperception)
					to_chat(user, span_green("Matthios tips fate in my favor..."))

				if(!(user.zone_selected in stealablezones))
					to_chat(user, span_warning("What am I going to steal from there?"))
					return

				mobsbehind |= cone(target_human, list(turn(target_human.dir, 180)), list(user))

				if(mobsbehind.Find(user) || target_human.IsUnconscious() || target_human.eyesclosed || target_human.eye_blind || target_human.eye_blurry || !(target_human.mobility_flags & MOBILITY_STAND))
					switch(user_human.zone_selected)
						if("chest")
							if (can_steal(target_human.get_item_by_slot(SLOT_BACK_L), target))
								stealpos.Add(target_human.get_item_by_slot(SLOT_BACK_L))
							if (can_steal(target_human.get_item_by_slot(SLOT_BACK_R), target))
								stealpos.Add(target_human.get_item_by_slot(SLOT_BACK_R))
						if("neck")
							if (can_steal(target_human.get_item_by_slot(SLOT_NECK), target))
								stealpos.Add(target_human.get_item_by_slot(SLOT_NECK))
						if("groin")
							if (can_steal(target_human.get_item_by_slot(SLOT_BELT_R), target))
								stealpos.Add(target_human.get_item_by_slot(SLOT_BELT_R))
							if (can_steal(target_human.get_item_by_slot(SLOT_BELT_L), target))
								stealpos.Add(target_human.get_item_by_slot(SLOT_BELT_L))
						if("r_hand", "l_hand")
							if (can_steal(target_human.get_item_by_slot(SLOT_RING), target))
								stealpos.Add(target_human.get_item_by_slot(SLOT_RING))

					var/do_steal = TRUE
					var/obj/item/picked 
					if (length(stealpos) > 0)
						picked = pick(stealpos)

					if (!picked)
						to_chat(user, span_notice("...can't find anything worth trying to take."))
						return
					
					// if we're yoinking a storage container, we should reassess the rolls again based on how full it is.
					// for simplicity's sake, let's just say every item in a container adds 0.5 onto the required roll to succeed.
					// this makes satchels pretty hard to steal and full pouches (4 slots = +2 difficulty) also a bit harder than normal.
					// those pouches are gonna jingle

					var/list/picked_item_contents = get_all_item_contents(picked)
					if (!target_human.IsUnconscious() && picked_item_contents && picked_item_contents.len > 0)
						var/penalty_per_stored_item = picked_item_contents.len * 0.5
						stealroll -= penalty_per_stored_item
						to_chat(user, span_notice("My fingers find [picked], heavy with the promise of loot..."))
						if (stealroll < targetperception)
							do_steal = FALSE
							if (stealroll < (targetperception * 0.66) || user.has_status_effect(/datum/status_effect/debuff/risk_low) || user.has_status_effect(/datum/status_effect/debuff/risk_high)) // you royally fucked up. probably because you stole a satchel or a backpack. fool. suffer. perish.
								to_chat(user, span_boldwarning("...oh, taff. They heard that. THEY HEARD THAT!!!"))
								to_chat(target_human, span_boldwarning("[picked] rustles loudly as something behind you fiddles with it!"))
								playsound(target_human, 'sound/foley/pickpocketing-storage-fail.ogg', 100)
								user.apply_status_effect(/datum/status_effect/debuff/risk_high)
							else
								to_chat(user, span_warning("...gotta back off, they'll hear it rustle."))
								user.apply_status_effect(/datum/status_effect/debuff/risk_low)
							return

					if (do_steal && picked)
						target_human.dropItemToGround(picked)
						user.put_in_active_hand(picked)
						to_chat(user, span_green("I stole [picked]!"))
						target_human.log_message("has had \the [picked] stolen by [key_name(user_human)]", LOG_ATTACK, color="white")
						user_human.log_message("has stolen \the [picked] from [key_name(target_human)]", LOG_ATTACK, color="white")
						
						// if we haul something big, clear our risk debuffs and give us a little fortune boost
						var/mammons_in_haul = get_mammons_in_atom(picked)
						var/haul_value = mammons_in_haul ? mammons_in_haul : get_sellprice_in_atom(picked)
						if (haul_value >= 100)
							user.apply_status_effect(/datum/status_effect/buff/risk_jackpot)
							user.remove_status_effect(/datum/status_effect/debuff/risk_low)
							user.remove_status_effect(/datum/status_effect/debuff/risk_high)
							to_chat(user, span_green("SCORE!! This must be worth an arsing ton of mammons!"))

						if(target_human.client && target_human.stat != DEAD && !target_human.IsUnconscious())
							SEND_SIGNAL(user_human, COMSIG_ITEM_STOLEN, target_human)
							record_featured_stat(FEATURED_STATS_THIEVES, user_human)
							record_featured_stat(FEATURED_STATS_CRIMINALS, user_human)
							record_round_statistic(STATS_ITEMS_PICKPOCKETED)
						
						// if our success is only narrowly above their perception, we incur risk, and if we're already at risk, we get rumbled.
						if (stealroll < (1.2 * targetperception) && target_human.STAINT > 8)
							to_chat(target_human, span_boldwarning("Huh? My [picked] is gone! <I>THIEF!!</I>"))
							to_chat(user, span_boldwarning("[target_human] pats themselves down - they've noticed something's wrong!"))
							if (user.has_status_effect(/datum/status_effect/debuff/risk_low))
								user.apply_status_effect(/datum/status_effect/debuff/risk_high)
							else
								user.apply_status_effect(/datum/status_effect/debuff/risk_low)
				else
					to_chat(user, "<span class='warning'>They can see me!")
			if(stealroll < targetperception)
				if(stealroll <= 8)
					target_human.log_message("has had an attempted pickpocket by [key_name(user_human)]", LOG_ATTACK, color="white")
					user_human.log_message("has attempted to pickpocket [key_name(target_human)]", LOG_ATTACK, color="white")
					user_human.visible_message(span_danger("[user_human] failed to pickpocket [target_human]!"))
					to_chat(target_human, span_danger("[user_human] tried pickpocketing me!"))

					if (user.has_status_effect(/datum/status_effect/debuff/risk_low))
						user.apply_status_effect(/datum/status_effect/debuff/risk_high)
					else
						user.apply_status_effect(/datum/status_effect/debuff/risk_low)
				else
					target_human.log_message("has had an attempted pickpocket by [key_name(user_human)]", LOG_ATTACK, color="white")
					user_human.log_message("has attempted to pickpocket [key_name(target_human)]", LOG_ATTACK, color="white")
					to_chat(user, span_danger("I failed to pick their pocket!"))
					to_chat(target_human, span_danger("Someone tried pickpocketing me!"))

					if (user.has_status_effect(/datum/status_effect/debuff/risk_low))
						user.apply_status_effect(/datum/status_effect/debuff/risk_high)
					else
						user.apply_status_effect(/datum/status_effect/debuff/risk_low)

				exp_to_gain /= 5 // these can be removed or changed on reviewer's discretion
			// If we're pickpocketing someone else, and that person is conscious, grant XP
			if(user != target_human && target_human.stat == CONSCIOUS)
				user.mind.add_sleep_experience(/datum/skill/misc/stealing, exp_to_gain, FALSE)
			user.changeNext_move(clickcd)
		else
			to_chat(user, span_warning("I lost contact with them!"))

	. = ..()

/datum/status_effect/debuff/risk_low
	id = "risk_low"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/theft_risk_low
	duration = 1 MINUTES
	effectedstats = list("fortune" = -1)

/datum/status_effect/debuff/risk_high
	id = "risk_high"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/theft_risk_high
	duration = 5 MINUTES
	effectedstats = list("fortune" = -3)

/atom/movable/screen/alert/status_effect/debuff/theft_risk_low
	name = "Rumbled"
	desc = "Shaking hands, trembling fingers. Almost blew it. Almost. Better be more careful..."

/atom/movable/screen/alert/status_effect/debuff/theft_risk_high
	name = "BUSTED!"
	desc = "OH, FRICK!!! THEY SAW ME!!!"

/datum/status_effect/buff/risk_jackpot
	id = "risk_jackpot"
	alert_type = /atom/movable/screen/alert/status_effect/buff/risk_jackpot
	duration = 5 MINUTES
	effectedstats = list("fortune" = 2)

/atom/movable/screen/alert/status_effect/buff/risk_jackpot
	name = "SCORE!!"
	desc = "I filched something valuable off a hapless rube. Ehehe."
