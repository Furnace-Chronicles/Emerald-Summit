/datum/intent/steal
	name = "steal"
	candodge = FALSE
	canparry = FALSE
	chargedrain = 0
	chargetime = 0
	noaa = TRUE

/datum/intent/steal/on_mmb(atom/target, mob/living/user, params)
	if(!target.Adjacent(user))
		return

	if(ishuman(target))
		var/mob/living/carbon/human/user_human = user
		var/mob/living/carbon/human/target_human = target

		var/thiefskill = user.get_skill_level(/datum/skill/misc/stealing) + (has_world_trait(/datum/world_trait/matthios_fingers) ? 1 : 0)
		var/spd_bonus = round(user.STASPD / 6) // SPD now provides half of what it used to towards pickpocketing. It was used as a substitute for skill.
		var/targetperception = (target_human.STAPER)

		if(target_human.cmode)
			targetperception += 6 // Target is alert, gain +6 extra effective perception
			to_chat(user, span_notice("[target_human] is tense and is more likely to detect me."))

		// Pickpocketing Difficulty System Redone with Salt:
		// Roll: 1d12 + (skill × 2) + (SPD / 6) vs Target Perception + Slot Difficulty
		// Slot Difficulties: Belt +4, Back +6, Necklace +14, Ring +10
		// SPD provides minor bonus - skill is the primary factor
		// SPD also now influences the speed of your pickpocket attempt, 10s at SPD 10, down to 1s at SPD 20
		// Novice thieves can attempt belts with ~17% chance at average stats (PER 10, no combat mode)
		// Journeyman thieves have ~50% on belts, can start attempting back slots
		// Expert thieves have reliable success on belts/backs, can attempt rings
		// Master thieves can attempt neck, and have high success on all other slots
		// Combat mode adds +6 to effective perception, making all attempts much harder
		// Matthios worshippers roll with advantage, taking the higher of two rolls
		// Slot difficulty modifiers (added to effective perception)
		var/slot_difficulty = 0
		switch(user.zone_selected)
			if("chest") // Back slots - moderate difficulty
				slot_difficulty = 6
			if("neck") // Necklaces - extremely difficult
				slot_difficulty = 14
			if("groin") // Belt slots - somewhat difficult
				slot_difficulty = 4
			if("r_hand", "l_hand") // Rings - very difficult
				slot_difficulty = 10

		var/effective_perception = targetperception + slot_difficulty
		var/initialstealroll = roll("1d12") + (thiefskill * 2) + spd_bonus
		var/advantageroll = 0

		if(HAS_TRAIT(user, TRAIT_CULTIC_THIEF))	// Matthios blesses his devout with rolling advantage on thieving checks.
			advantageroll = roll("1d12") + (thiefskill * 2) + spd_bonus
		
		var/stealroll = max(initialstealroll, advantageroll)
		var/chance2steal = max(round(((12 + (thiefskill * 2) + spd_bonus - effective_perception) / 12) * 100, 1), 0) 



		var/list/stealablezones = list("chest", "neck", "groin", "r_hand", "l_hand")
		var/list/stealpos = list()
		var/list/mobsbehind = list()

		var/exp_to_gain = user_human.STAINT

		to_chat(user, span_notice("I try to steal from [target_human]..."))

		// Pickpocketing delay scales with SPD: 5s at SPD 10, 0.5s at SPD 19+ (deciseconds)
		var/delay = clamp(round(50 - 5 * (user.STASPD - 10)), 5, 50) // 5 seconds at SPD 10, 4.5 seconds at SPD 11, ..., 0.5 seconds at SPD 19+
		if(do_after(user, delay, target = target_human, progress = 0))

			if(target_human.IsUnconscious() || target_human.stat != CONSCIOUS) //They're out of it bro.
				effective_perception = 0

			if(stealroll > effective_perception)
				//TODO add exp here

				if(HAS_TRAIT(user, TRAIT_CULTIC_THIEF) && initialstealroll < effective_perception)
					to_chat(user, span_green("Matthios tips fate in my favor..."))

				if(user_human.get_active_held_item())
					to_chat(user, span_warning("I can't pickpocket while my hand is full!"))
					return

				if(!(user.zone_selected in stealablezones))
					to_chat(user, span_warning("What am I going to steal from there?"))
					return

				mobsbehind |= cone(target_human, list(turn(target_human.dir, 180)), list(user))

				if(mobsbehind.Find(user) || target_human.IsUnconscious() || target_human.eyesclosed || target_human.eye_blind || target_human.eye_blurry || !(target_human.mobility_flags & MOBILITY_STAND))
					switch(user_human.zone_selected)
						if("chest")
							if(target_human.get_item_by_slot(SLOT_BACK_L))
								stealpos.Add(target_human.get_item_by_slot(SLOT_BACK_L))
							if(target_human.get_item_by_slot(SLOT_BACK_R))
								stealpos.Add(target_human.get_item_by_slot(SLOT_BACK_R))
						if("neck")
							if(target_human.get_item_by_slot(SLOT_NECK))
								stealpos.Add(target_human.get_item_by_slot(SLOT_NECK))
						if("groin")
							if(target_human.get_item_by_slot(SLOT_BELT_R))
								stealpos.Add(target_human.get_item_by_slot(SLOT_BELT_R))
							if(target_human.get_item_by_slot(SLOT_BELT_L))
								stealpos.Add(target_human.get_item_by_slot(SLOT_BELT_L))
						if("r_hand", "l_hand")
							if(target_human.get_item_by_slot(SLOT_RING))
								stealpos.Add(target_human.get_item_by_slot(SLOT_RING))

					if (length(stealpos) > 0)
						var/obj/item/picked = pick(stealpos)
						target_human.dropItemToGround(picked)
						user.put_in_active_hand(picked)
						if(HAS_TRAIT(user, TRAIT_CULTIC_THIEF))
							to_chat(user, span_green("I stole [picked]! [round(1 - ((1 - (chance2steal / 100)) * (1 - (chance2steal / 100))), 0.01) * 100]%"))
						else
							to_chat(user, span_green("I stole [picked]! [chance2steal]%"))
						target_human.log_message("has had \the [picked] stolen by [key_name(user_human)]", LOG_ATTACK, color="white")
						user_human.log_message("has stolen \the [picked] from [key_name(target_human)]", LOG_ATTACK, color="white")
						if(target_human.client && target_human.stat != DEAD)
							SEND_SIGNAL(user_human, COMSIG_ITEM_STOLEN, target_human)
							record_featured_stat(FEATURED_STATS_THIEVES, user_human)
							record_featured_stat(FEATURED_STATS_CRIMINALS, user_human)
							record_round_statistic(STATS_ITEMS_PICKPOCKETED)
						if (stealroll < 2 * effective_perception && target_human.STAINT > 8)
							to_chat(target_human, span_warning("Huh? My [picked] is gone!"))
							to_chat(user, span_warning("The target noticed the missing item."))
					else
						exp_to_gain /= 2
						to_chat(user, span_warning("I didn't find anything there. Perhaps I should look elsewhere."))
				else
					to_chat(user, "<span class='warning'>They can see me!")
			if(stealroll < effective_perception)
				if(stealroll <= 8)
					target_human.log_message("has had an attempted pickpocket by [key_name(user_human)]", LOG_ATTACK, color="white")
					user_human.log_message("has attempted to pickpocket [key_name(target_human)]", LOG_ATTACK, color="white")
					user_human.visible_message(span_danger("[user_human] failed to pickpocket [target_human]!"))
					to_chat(target_human, span_danger("[user_human] tried pickpocketing me!"))
				else
					target_human.log_message("has had an attempted pickpocket by [key_name(user_human)]", LOG_ATTACK, color="white")
					user_human.log_message("has attempted to pickpocket [key_name(target_human)]", LOG_ATTACK, color="white")
					if(HAS_TRAIT(user, TRAIT_CULTIC_THIEF))
						to_chat(user, span_danger("I failed to pick the pocket! [1 - ((1 - chance2steal) * (1 - chance2steal))]%!"))
					else
						to_chat(user, span_danger("I failed to pick the pocket! [chance2steal]%!"))
					to_chat(target_human, span_danger("Someone tried pickpocketing me!"))
				exp_to_gain /= 5 // these can be removed or changed on reviewer's discretion
			// If we're pickpocketing someone else, and that person is conscious, grant XP
			if(user != target_human && target_human.stat == CONSCIOUS)
				user.mind.add_sleep_experience(/datum/skill/misc/stealing, exp_to_gain, FALSE)
			user.changeNext_move(clickcd)
		else
			to_chat(user, span_warning("I lost contact with them!"))

	. = ..()
