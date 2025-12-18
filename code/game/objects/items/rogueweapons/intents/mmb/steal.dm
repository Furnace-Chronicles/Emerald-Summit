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
		var/initialstealroll = roll("1d12") + (thiefskill * 2) + (user.STASPD / 3)
		var/advantageroll = 0
		var/targetperception = (target_human.STAPER)

		if(target_human.cmode)
			targetperception += 6 // Target is alert, gain +6 extra effective perception
			to_chat(user, span_notice("[target_human] is tense and is more likely to detect me."))

		if(HAS_TRAIT(user, TRAIT_CULTIC_THIEF)) // Matthios blesses his devout with rolling advantage on thieving checks.
			advantageroll = roll("1d12") + (thiefskill * 2) + (user.STASPD / 3)
		
		// Used for showing fail chance.
		var/chance2steal = max(round(((12 + (thiefskill * 2) + (user.STASPD / 3) - (targetperception)) / 12 ) * 100, 1), 0)

		//Mathematically:
		// SPD stat is to give an initial baseline to lower skilled thieves and reward speedy thieves slightly.
		// Journeyman thief will struggle to steal someone with combat mode on at 10 spd vs 10 perception. Otherwise will steal most of the time.
		// Very high skilled thieves will be able to manage it quite handily, as long as they're out of sight.
		// Matthios thieves get a substantial advantage to pickpocketing.

		var/stealroll = max(initialstealroll, advantageroll)

		var/list/stealablezones = list("chest", "neck", "groin", "r_hand", "l_hand")
		var/list/stealpos = list()
		var/list/mobsbehind = list()

		var/exp_to_gain = user_human.STAINT

		to_chat(user, span_notice("I try to steal from [target_human]..."))

		if(do_after(user, 5, target = target_human, progress = 0))

			if(target_human.IsUnconscious() || target_human.stat != CONSCIOUS) //They're out of it bro.
				targetperception = 0

			if(stealroll > targetperception)
				//TODO add exp here

				if(HAS_TRAIT(user, TRAIT_CULTIC_THIEF) && initialstealroll < targetperception)
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
							if (target_human.get_item_by_slot(SLOT_BACK_L))
								stealpos.Add(target_human.get_item_by_slot(SLOT_BACK_L))
							if (target_human.get_item_by_slot(SLOT_BACK_R))
								stealpos.Add(target_human.get_item_by_slot(SLOT_BACK_R))
						if("neck")
							if (target_human.get_item_by_slot(SLOT_NECK))
								stealpos.Add(target_human.get_item_by_slot(SLOT_NECK))
						if("groin")
							if (target_human.get_item_by_slot(SLOT_BELT_R))
								stealpos.Add(target_human.get_item_by_slot(SLOT_BELT_R))
							if (target_human.get_item_by_slot(SLOT_BELT_L))
								stealpos.Add(target_human.get_item_by_slot(SLOT_BELT_L))
						if("r_hand", "l_hand")
							if (target_human.get_item_by_slot(SLOT_RING))
								stealpos.Add(target_human.get_item_by_slot(SLOT_RING))

					if (length(stealpos) > 0)
						var/obj/item/picked = pick(stealpos)
						target_human.dropItemToGround(picked)
						user.put_in_active_hand(picked)
						to_chat(user, span_green("I stole [picked]!"))
						target_human.log_message("has had \the [picked] stolen by [key_name(user_human)]", LOG_ATTACK, color="white")
						user_human.log_message("has stolen \the [picked] from [key_name(target_human)]", LOG_ATTACK, color="white")
						if(target_human.client && target_human.stat != DEAD)
							SEND_SIGNAL(user_human, COMSIG_ITEM_STOLEN, target_human)
							record_featured_stat(FEATURED_STATS_THIEVES, user_human)
							record_featured_stat(FEATURED_STATS_CRIMINALS, user_human)
							record_round_statistic(STATS_ITEMS_PICKPOCKETED)
						if (stealroll < 2 * targetperception && target_human.STAINT > 8)
							to_chat(target_human, span_warning("Huh? My [picked] is gone!"))
							to_chat(user, span_warning("The target noticed the missing item."))
					else
						exp_to_gain /= 2
						to_chat(user, span_warning("I didn't find anything there. Perhaps I should look elsewhere."))
				else
					to_chat(user, "<span class='warning'>They can see me!")
			if(stealroll < targetperception)
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
