//im putting this here just for my mental sake
//Miracles T1
/obj/effect/proc_holder/spell/invoked/lesser_heal/zizo
	name = "Miracle"
	desc = "Call upon ZIZO to heal your target, possibly at a cost..."
	overlay_state = "zizo_lesser"
	movement_interrupt = FALSE
	sound = 'sound/magic/zizo_heal.ogg'
	invocation_type = "none"
	antimagic_allowed = TRUE
	devotion_cost = 5
	range = 7
	
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
		return TRUE
	if(target.mob_biotypes & MOB_UNDEAD)
		user.adjustBruteLoss(4)             //non worshipers do not share your ambition, pay the price to heal them
		return TRUE
		
	//shitty ass psydonites need special code in here
	if(HAS_TRAIT(target, TRAIT_PSYDONITE))
		user.visible_message(span_danger("[target] is seared by necrotic power!"))
		target.adjustFireLoss(12)             //making sure psydonites get attacked too
		user.adjustBruteLoss(4)             //damage here
		return FALSE
		
	// EVERYONE ELSE	
	user.visible_message(span_danger("[target] is seared by necrotic power!"))
	target.adjustFireLoss(12)     //damage is here
	user.adjustBruteLoss(4)
	return FALSE
