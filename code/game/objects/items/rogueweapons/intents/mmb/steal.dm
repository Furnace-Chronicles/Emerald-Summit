/datum/intent/steal
	name = "steal"
	candodge = FALSE
	canparry = FALSE
	chargedrain = 0
	chargetime = 0
	noaa = TRUE

/datum/intent/steal/on_mmb(atom/target, mob/living/user, params)
	var/list/_mods = list("chance_add" = 0, "range_add" = 0)
	SEND_SIGNAL(user, "steal_mods_query", _mods)

	var/extra_range = max(0, _mods["range_add"] || 0)
	var/allowed_range = 1 + extra_range
	if(get_dist(user, target) > allowed_range)
		return

	if(ishuman(target))
		var/mob/living/carbon/human/user_human = user
		var/mob/living/carbon/human/target_human = target

		var/thiefskill = user.get_skill_level(/datum/skill/misc/stealing) + (has_world_trait(/datum/world_trait/matthios_fingers) ? 1 : 0)
		var/stealroll = roll("[thiefskill]d6")
		var/targetperception = (target_human.STAPER)

		var/list/stealablezones = list("chest", "neck", "groin", "r_hand", "l_hand")
		var/list/stealpos = list()
		var/list/mobsbehind = list()

		var/exp_to_gain = user_human.STAINT

		to_chat(user, span_notice("I try to steal from [target_human]..."))

		if(do_after(user, 5, target = target_human, progress = 0))
			var/base_success = (stealroll > targetperception)
			var/bonus_success = (!base_success && (_mods["chance_add"] > 0) && prob(_mods["chance_add"]))
			var/final_success = base_success || bonus_success

			if(final_success)
				// RATWOOD MODULAR START
				if(target_human.cmode)
					to_chat(user, "<span class='warning'>[target_human] is alert. I can't pickpocket them like this.</span>")
					return
				// RATWOOD MODULAR END

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
					else
						exp_to_gain /= 2
						to_chat(user, span_warning("I didn't find anything there. Perhaps I should look elsewhere."))
				else
					to_chat(user, "<span class='warning'>They can see me!")
			else
				if(stealroll <= 5)
					target_human.log_message("has had an attempted pickpocket by [key_name(user_human)]", LOG_ATTACK, color="white")
					user_human.log_message("has attempted to pickpocket [key_name(target_human)]", LOG_ATTACK, color="white")
					user_human.visible_message(span_danger("[user_human] failed to pickpocket [target_human]!"))
					to_chat(target_human, span_danger("[user_human] tried pickpocketing me!"))

				if(stealroll < targetperception)
					target_human.log_message("has had an attempted pickpocket by [key_name(user_human)]", LOG_ATTACK, color="white")
					user_human.log_message("has attempted to pickpocket [key_name(target_human)]", LOG_ATTACK, color="white")
					to_chat(user, span_danger("I failed to pick the pocket!"))
					to_chat(target_human, span_danger("Someone tried pickpocketing me!"))
					exp_to_gain /= 5
			if(user != target_human && target_human.stat == CONSCIOUS)
				var/xp_gain = exp_to_gain
				var/list/xpmods = list("xp_mult" = 1)
				SEND_SIGNAL(user, "steal_xp_query", xpmods, /datum/skill/misc/stealing)
				var/xpm = isnum(xpmods["xp_mult"]) ? xpmods["xp_mult"] : 1
				xp_gain *= xpm
				if(user?.mind)
					user.mind.add_sleep_experience(/datum/skill/misc/stealing, xp_gain, FALSE)
			user.changeNext_move(clickcd)

	. = ..()
