/mob/living
	/// An overlay image that displays the mob's intent, doesn't apply to NPCs.
	var/static/mutable_appearance/combat_indicator

/mob/living/proc/toggle_combat_indicator(mob/living/user)
	if(!cmode)
		cut_overlay(combat_indicator)
		update_vision_cone()
	else
		update_combat_indicator()
		update_vision_cone()
		switch(cmbintent)
			if(CMB_INTENT_SPAR)	
				visible_message(span_warningbig("[usr] moves with sparring intent!"))
			if(CMB_INTENT_ARREST)
				visible_message(span_warningbig("[usr] moves with subduing intent!"))
			if(CMB_INTENT_FRAG)
				visible_message(span_warningbig("[usr] moves with killing intent!"))
	return cmode


/mob/living/proc/update_combat_indicator()	
	if(combat_indicator)
		cut_overlay(combat_indicator)
		update_vision_cone()

	switch(cmbintent)
		if(CMB_INTENT_SPAR)
			combat_indicator = mutable_appearance('icons/mob/roguehud.dmi', "cmb0", FLY_LAYER)
			add_overlay(combat_indicator)
			update_vision_cone()
		if(CMB_INTENT_ARREST)
			combat_indicator = mutable_appearance('icons/mob/roguehud.dmi', "cmb1", FLY_LAYER)
			add_overlay(combat_indicator)
			update_vision_cone()
		if(CMB_INTENT_FRAG)
			combat_indicator = mutable_appearance('icons/mob/roguehud.dmi', "cmb2", FLY_LAYER)
			add_overlay(combat_indicator)
			update_vision_cone()

	if(cmode)
		var/intent
		switch(cmbintent)
			if(CMB_INTENT_SPAR)
				intent = "spar"
				playsound(usr, 'sound/combat/nonlethal.ogg', 75)
			if(CMB_INTENT_ARREST)
				intent = "arrest"
				playsound(usr, 'sound/combat/arrest.ogg', 75)
			if(CMB_INTENT_FRAG)
				intent = "frag"
				playsound(usr, 'sound/combat/lethal.ogg', 75)		
		log_message("[src] has changed combat intent to [intent] intent.", LOG_ATTACK)	

	return combat_indicator


/mob/living/toggle_cmode()
	..()
	var/intent
	if(cmbintent)
		switch(cmbintent)
			if(CMB_INTENT_SPAR)
				intent = "spar"
			if(CMB_INTENT_ARREST)
				intent = "arrest"
			if(CMB_INTENT_FRAG)
				intent = "frag"
	log_message("[src] has " + (cmode ? "enabled" : "disabled") + " combat mode with [intent] intent.", LOG_ATTACK)
	toggle_combat_indicator()
