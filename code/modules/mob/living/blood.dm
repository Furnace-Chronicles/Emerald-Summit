/****************************************************
				BLOOD SYSTEM
****************************************************/

/mob/living/proc/suppress_bloodloss(amount)
	if(bleedsuppress)
		return
	else
		bleedsuppress = TRUE
		addtimer(CALLBACK(src, PROC_REF(resume_bleeding)), amount)

/mob/living/proc/resume_bleeding()
	bleedsuppress = 0
	if(stat != DEAD && bleed_rate)
		to_chat(src, span_warning("The blood soaks through my bandage."))

/mob/living/carbon/monkey/handle_blood()
	if((bodytemperature <= TCRYO) || HAS_TRAIT(src, TRAIT_HUSK)) //cryosleep or husked people do not pump the blood.
		return
	//Blood regeneration if there is some space
	if(blood_volume < BLOOD_VOLUME_NORMAL)
		blood_volume += 0.1 // regenerate blood VERY slowly
		if((blood_volume < BLOOD_VOLUME_OKAY) && !HAS_TRAIT(src, TRAIT_BLOODLOSS_IMMUNE))
			adjustOxyLoss(round((BLOOD_VOLUME_NORMAL - blood_volume) * 0.02, 1))

/mob/living/proc/handle_blood()
	if((bodytemperature <= TCRYO) || HAS_TRAIT(src, TRAIT_HUSK)) //cryosleep or husked people do not pump the blood.
		return

	blood_volume = min(blood_volume, BLOOD_VOLUME_MAXIMUM)
	//Effects of bloodloss - only run if we're not actually dead.
	if (stat != DEAD)
		if(!HAS_TRAIT(src, TRAIT_BLOODLOSS_IMMUNE))
			switch(blood_volume)
				if(BLOOD_VOLUME_OKAY to BLOOD_VOLUME_SAFE)
					if(prob(3))
						to_chat(src, span_warning("I feel dizzy."))
					remove_status_effect(/datum/status_effect/debuff/bleedingworse)
					remove_status_effect(/datum/status_effect/debuff/bleedingworst)
					apply_status_effect(/datum/status_effect/debuff/bleeding)
				if(BLOOD_VOLUME_BAD to BLOOD_VOLUME_OKAY)
					if(prob(3))
						blur_eyes(6)
						to_chat(src, span_warning("I feel faint."))
					remove_status_effect(/datum/status_effect/debuff/bleeding)
					remove_status_effect(/datum/status_effect/debuff/bleedingworst)
					apply_status_effect(/datum/status_effect/debuff/bleedingworse)
				if(0 to BLOOD_VOLUME_BAD)
					if(prob(3))
						blur_eyes(6)
						to_chat(src, span_warning("I feel faint."))
					if(prob(3) && !IsUnconscious())
						Unconscious(rand(5 SECONDS,10 SECONDS))
						to_chat(src, span_warning("I feel drained."))
					remove_status_effect(/datum/status_effect/debuff/bleedingworse)
					remove_status_effect(/datum/status_effect/debuff/bleeding)
					apply_status_effect(/datum/status_effect/debuff/bleedingworst)
			if(blood_volume <= BLOOD_VOLUME_BAD)
				adjustOxyLoss(1)
				if(blood_volume <= BLOOD_VOLUME_SURVIVE)
					adjustOxyLoss(2)
		else
			remove_status_effect(/datum/status_effect/debuff/bleeding)
			remove_status_effect(/datum/status_effect/debuff/bleedingworse)
			remove_status_effect(/datum/status_effect/debuff/bleedingworst)

	bleed_rate = get_bleed_rate()
	if(HAS_TRAIT(src, TRAIT_ADRENALINE_RUSH))
		bleed_rate = FALSE
	if(bleed_rate)
		bleed(bleed_rate)
	else if(blood_volume < BLOOD_VOLUME_NORMAL)
		blood_volume = min(blood_volume + 1, BLOOD_VOLUME_NORMAL)

	// Non-vampiric bloodpool regen.
	// We assume that in non-vampires bloodpool represents "usable" blood that is regenerated slower than blood_volume
	if(!clan && blood_volume > BLOOD_VOLUME_SAFE)
		adjust_bloodpool(BLOODPOL_REGEN, FALSE)

// Takes care blood loss and regeneration
/mob/living/carbon/handle_blood()
	if((bodytemperature <= TCRYO) || HAS_TRAIT(src, TRAIT_HUSK)) //cryosleep or husked people do not pump the blood.
		return

	blood_volume = min(blood_volume, BLOOD_VOLUME_MAXIMUM)
	if(dna?.species)
		if(NOBLOOD in dna.species.species_traits)
			blood_volume = BLOOD_VOLUME_NORMAL
			return

	// if we're dead and have no blood left, then there's nothing to do here: we can't regen it ourselves (in this proc), so...
	// we'll continue to bleed out for as long as we have blood, but that's it
	if (!blood_volume)
		if (stat == DEAD)
			bleed_rate = 0 // just to be sure for anything else that cares about it, since we're ostensibly out of blood now
			return
		else
			// handle just the oxyloss, and then abort. nothing else in here is relevant to us
			adjustOxyLoss(blood_volume <= BLOOD_VOLUME_SURVIVE ? 3 : 1)
			return

	//Blood regeneration if there is some space
	if(blood_volume < BLOOD_VOLUME_NORMAL && blood_volume)
		var/nutrition_ratio = 1
//			switch(nutrition)
//				if(0 to NUTRITION_LEVEL_STARVING)
//					nutrition_ratio = 0.2
//				if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_HUNGRY)
//					nutrition_ratio = 0.4
//				if(NUTRITION_LEVEL_HUNGRY to NUTRITION_LEVEL_FED)
//					nutrition_ratio = 0.6
//				if(NUTRITION_LEVEL_FED to NUTRITION_LEVEL_WELL_FED)
//					nutrition_ratio = 0.8
//				else
//					nutrition_ratio = 1
//			if(satiety > 80)
//				nutrition_ratio *= 1.25
//			adjust_hydration(-nutrition_ratio * HUNGER_FACTOR) //get thirsty twice as fast when regenning blood
		blood_volume = min(BLOOD_VOLUME_NORMAL, blood_volume + 0.5 * nutrition_ratio)

	//Effects of bloodloss - only if we're actually alive, though
	if (stat != DEAD)
		if(!HAS_TRAIT(src, TRAIT_BLOODLOSS_IMMUNE))
			var/current_bleeding_tier
			switch(blood_volume)
				if(BLOOD_VOLUME_SAFE to INFINITY)
					current_bleeding_tier = 0
				if(BLOOD_VOLUME_OKAY to BLOOD_VOLUME_SAFE)
					current_bleeding_tier = 1
					if(prob(3))
						to_chat(src, span_warning("I feel dizzy."))
				if(BLOOD_VOLUME_BAD to BLOOD_VOLUME_OKAY)
					current_bleeding_tier = 2
					if(prob(3))
						blur_eyes(6)
						to_chat(src, span_warning("I feel faint."))
				if(0 to BLOOD_VOLUME_BAD)
					current_bleeding_tier = 3
					if(prob(3))
						blur_eyes(6)
						to_chat(src, span_warning("I feel faint."))
					if(prob(3))
						Unconscious(rand(5 SECONDS,10 SECONDS))
						to_chat(src, span_warning("I feel drained."))
				else
					current_bleeding_tier = bleeding_tier

			// only apply status effects if we've actually shifted a tier of bleeding instead of performing
			// 3+ STATUS EFFECT CHECKS ON EVERY SINGLE LIFE TICK. HOLY SMOKES!!!
			if (current_bleeding_tier != bleeding_tier)
				bleeding_tier = current_bleeding_tier
				switch (bleeding_tier)
					if (0)
						remove_status_effect(/datum/status_effect/debuff/bleeding)
						remove_status_effect(/datum/status_effect/debuff/bleedingworse)
						remove_status_effect(/datum/status_effect/debuff/bleedingworst)
					if (1)
						apply_status_effect(/datum/status_effect/debuff/bleeding)
						remove_status_effect(/datum/status_effect/debuff/bleedingworse)
						remove_status_effect(/datum/status_effect/debuff/bleedingworst)
					if (2)
						apply_status_effect(/datum/status_effect/debuff/bleedingworse)
						remove_status_effect(/datum/status_effect/debuff/bleeding)
						remove_status_effect(/datum/status_effect/debuff/bleedingworst)
					if (3)
						apply_status_effect(/datum/status_effect/debuff/bleedingworst)
						remove_status_effect(/datum/status_effect/debuff/bleeding)
						remove_status_effect(/datum/status_effect/debuff/bleedingworse)

			// Automatic unconsciousness at BAD threshold
			if(blood_volume <= BLOOD_VOLUME_BAD && !IsUnconscious())
				Unconscious(10 SECONDS)
				to_chat(src, span_userdanger("The world fades to black..."))

			// CON-based soft crit threshold: higher CON = survive at lower blood levels
			// Base is 122 at 10 CON, -10 blood per CON point above 10
			// This means high CON characters enter soft crit later (at lower blood volume)
			var/soft_crit_threshold = BLOOD_VOLUME_SURVIVE - ((STACON - 10) * 10)
			soft_crit_threshold = clamp(soft_crit_threshold, 40, 200)

			// Progressive oxygen damage based on blood loss severity
			// Much lower rates for extended bleedout time (120-160 seconds)
			var/oxy_adjustment = 0
			if(blood_volume <= 40) // Death threshold - ~7% blood
				oxy_adjustment = 2 // Rapid death
			else if(blood_volume <= soft_crit_threshold)
				oxy_adjustment = 0.4 // Soft crit - very slow
			else if(blood_volume <= BLOOD_VOLUME_BAD)
				oxy_adjustment = 0.2 // Below BAD threshold - minimal
			else if((blood_volume > soft_crit_threshold) || HAS_TRAIT(src, TRAIT_BLOODLOSS_IMMUNE))
				if(getOxyLoss())
					oxy_adjustment = -1.6
			if(oxy_adjustment)
				adjustOxyLoss(oxy_adjustment)

	//Bleeding out
	bleed_rate = get_bleed_rate() // expensive proc, but we zero it on bled-out mobs
	if(HAS_TRAIT(src, TRAIT_ADRENALINE_RUSH))
		bleed_rate = FALSE
	if(bleed_rate)
		bleed(bleed_rate) // bandage handling moved to bodypart.get_bleed_rate()

/mob/living/proc/get_bleed_rate()
	if (!blood_volume)
		return FALSE //the blood bag is empty, brother.
	var/bleed_rate = 0
	/*for(var/datum/wound/wound as anything in get_wounds())
		bleed_rate += wound.bleed_rate*/
	bleed_rate += simple_bleeding
	for(var/obj/item/embedded as anything in simple_embedded_objects)
		bleed_rate += embedded.embedding?.embedded_bloodloss
	return bleed_rate

/mob/living/carbon/get_bleed_rate()
	if (!blood_volume)
		return 0
	if(NOBLOOD in dna?.species?.species_traits)
		return 0

	var/normal_bleed = 0
	var/critical_bleed = 0

	var/grab_suppression = 1.0
	for(var/obj/item/bodypart/BP as anything in bodyparts)
		if(length(BP.grabbedby))
			for(var/obj/item/grabbing/G in BP.grabbedby)
				grab_suppression *= G.bleed_suppressing

	for(var/obj/item/bodypart/BP as anything in bodyparts)
		var/bp_bleed = BP.bleeding
		var/bp_critical = 0
		var/bp_max_bleed = 0

		for(var/datum/wound/W as anything in BP.wounds)
			if(!W)
				continue

			if(W.bleed_rate)
				if(W.bleed_rate > bp_max_bleed)
					bp_max_bleed = W.bleed_rate

				if(W.severity >= WOUND_SEVERITY_CRITICAL)
					bp_critical += W.bleed_rate
					bp_bleed -= W.bleed_rate

		for(var/obj/item/I as anything in BP.embedded_objects)
			if(I.embedding?.embedded_bloodloss)
				var/embed_bleed = I.embedding.embedded_bloodloss
				if(embed_bleed > bp_max_bleed)
					bp_max_bleed = embed_bleed

		if(BP.bandage && !HAS_BLOOD_DNA(BP.bandage))
			var/bandage_effectiveness = 0.5
			if(istype(BP.bandage, /obj/item/natural/cloth))
				var/obj/item/natural/cloth/cloth = BP.bandage
				bandage_effectiveness = cloth.bandage_effectiveness
			if(bandage_effectiveness < bp_max_bleed)
				BP.bandage_expire()

		normal_bleed += bp_bleed
		critical_bleed += bp_critical

	if(grab_suppression != 1.0)
		normal_bleed *= grab_suppression
		critical_bleed *= grab_suppression * 0.5

	if(normal_bleed > 0 && blood_volume < BLOOD_VOLUME_NORMAL)
		var/blood_pressure = blood_volume / BLOOD_VOLUME_NORMAL
		normal_bleed *= (blood_pressure ** 2)
		critical_bleed *= min(blood_pressure * 1.5, 1)

	return normal_bleed + critical_bleed

//Makes a blood drop, leaking amt units of blood from the mob
/mob/living/proc/bleed(amt)
	if(!blood_volume)
		return FALSE
	if(!iscarbon(src) && !HAS_TRAIT(src, TRAIT_SIMPLE_WOUNDS))
		return FALSE

	//For each CON above 10, we bleed slower.
	//Consequently, for each CON under 10 we bleed faster.
	var/conbonus = 1
	if(STACON >= CONSTITUTION_BLEEDRATE_CAP)
		conbonus = CONSTITUTION_BLEEDRATE_CAP - 10
	else if(STACON != 10)
		conbonus = STACON - 10
	if(mind)
		amt -= amt * (conbonus * CONSTITUTION_BLEEDRATE_MOD)
	var/old_volume = blood_volume
	blood_volume = max(blood_volume - amt, 0)
	if (old_volume > 0 && !blood_volume) // it looks like we've just bled out. bummer.
		to_chat(src, span_userdanger("The last of your lyfeblood ebbs from your ravaged body and soaks the cold earth below..."))
		death()

	GLOB.scarlet_round_stats[STATS_BLOOD_SPILT] += amt
	if(isturf(src.loc)) //Blood loss still happens in locker, floor stays clean
		add_drip_floor(src.loc, amt)
	var/vol2use
	if(amt > 1)
		vol2use = 'sound/misc/bleed (1).ogg'
	if(amt > 2)
		vol2use = 'sound/misc/bleed (2).ogg'
	if(amt > 3)
		vol2use = 'sound/misc/bleed (3).ogg'
	if(!(mobility_flags & MOBILITY_STAND))
		vol2use = null
	if(vol2use)
		playsound(get_turf(src), vol2use, 100, FALSE)

	return TRUE

/mob/living/carbon/human/bleed(amt)
	amt *= physiology.bleed_mod
	if(!(NOBLOOD in dna.species.species_traits))
		return ..()
	return FALSE

/mob/living/proc/restore_blood()
	blood_volume = initial(blood_volume)
	bleed_rate = 0

/mob/living/carbon/human/restore_blood()
	blood_volume = BLOOD_VOLUME_NORMAL
	bleed_rate = 0

/****************************************************
				BLOOD TRANSFERS
****************************************************/

//Gets blood from mob to a container or other mob, preserving all data in it.
/mob/living/proc/transfer_blood_to(atom/movable/AM, amount, forced)
	if(!blood_volume || !AM.reagents)
		return 0
	if(blood_volume < BLOOD_VOLUME_BAD && !forced)
		return 0

	if(blood_volume < amount)
		amount = blood_volume

	var/blood_id = get_blood_id()
	if(!blood_id)
		return 0

	blood_volume -= amount

	var/list/blood_data = get_blood_data(blood_id)

	if(iscarbon(AM))
		var/mob/living/carbon/C = AM
		if(blood_id == C.get_blood_id())//both mobs have the same blood substance
			if(blood_id == /datum/reagent/blood) //normal blood
				if(!(blood_data["blood_type"] in get_safe_blood(C.dna.blood_type)))
					C.reagents.add_reagent(/datum/reagent/toxin, amount * 0.5)
					return 1

			C.blood_volume = min(C.blood_volume + round(amount, 0.1), BLOOD_VOLUME_MAXIMUM)
			return 1

	AM.reagents.add_reagent(blood_id, amount, blood_data, bodytemperature)
	return 1


/mob/living/proc/get_blood_data(blood_id)
	return

/mob/living/carbon/get_blood_data(blood_id)
	if(blood_id == /datum/reagent/blood) //actual blood reagent
		var/blood_data = list()
		//set the blood data
		blood_data["donor"] = src

		blood_data["blood_DNA"] = copytext(dna.unique_enzymes,1,0)
		var/list/temp_chem = list()
		for(var/datum/reagent/R in reagents.reagent_list)
			temp_chem[R.type] = R.volume
		blood_data["trace_chem"] = list2params(temp_chem)
		if(mind)
			blood_data["mind"] = mind
		else if(last_mind)
			blood_data["mind"] = last_mind
		if(ckey)
			blood_data["ckey"] = ckey
		else if(last_mind)
			blood_data["ckey"] = ckey(last_mind.key)

		if(!suiciding)
			blood_data["cloneable"] = 1
		blood_data["blood_type"] = copytext(dna.blood_type,1,0)
		blood_data["gender"] = gender
		blood_data["real_name"] = real_name
		blood_data["features"] = dna.features
		blood_data["factions"] = faction
		return blood_data

//get the id of the substance this mob use as blood.
/mob/proc/get_blood_id()
	return

/mob/living/simple_animal/get_blood_id()
	if(blood_volume)
		return /datum/reagent/blood

/mob/living/carbon/monkey/get_blood_id()
	if(!(HAS_TRAIT(src, TRAIT_HUSK)))
		return /datum/reagent/blood

/mob/living/carbon/human/get_blood_id()
	if(HAS_TRAIT(src, TRAIT_HUSK))
		return
	if(dna?.species)
		if(dna.species.exotic_blood)
			return dna.species.exotic_blood
		if((NOBLOOD in dna.species.species_traits))
			return
	return /datum/reagent/blood

// This is has more potential uses, and is probably faster than the old proc.
/proc/get_safe_blood(bloodtype)
	. = list()
	if(!bloodtype)
		return

	var/static/list/bloodtypes_safe = list(
		"A-" = list("A-", "O-"),
		"A+" = list("A-", "A+", "O-", "O+"),
		"B-" = list("B-", "O-"),
		"B+" = list("B-", "B+", "O-", "O+"),
		"AB-" = list("A-", "B-", "O-", "AB-"),
		"AB+" = list("A-", "A+", "B-", "B+", "O-", "O+", "AB-", "AB+"),
		"O-" = list("O-"),
		"O+" = list("O-", "O+"),
		"L" = list("L"),
		"U" = list("A-", "A+", "B-", "B+", "O-", "O+", "AB-", "AB+", "L", "U")
	)

	var/safe = bloodtypes_safe[bloodtype]
	if(safe)
		. = safe

//to add a splatter of blood or other mob liquid.
/mob/living/proc/add_splatter_floor(turf/T)
	if(!iscarbon(src))
		if(!HAS_TRAIT(src, TRAIT_SIMPLE_WOUNDS))
			return
	if(!get_blood_id())
		return
	if(!T)
		T = get_turf(src)

	if(istype(T, /turf/open/water))
		var/turf/open/water/W = T
		W.water_reagent = /datum/reagent/blood // this is dumb, but it works for now
		W.mapped = FALSE // no infinite vitae glitch
		W.water_maximum = 10
		W.water_volume = 10
		W.update_icon()
		return
	new /obj/effect/decal/cleanable/blood/splatter(T)
	T?.pollute_turf(/datum/pollutant/metallic_scent, 30)

/mob/living/proc/add_drip_floor(turf/T, amt)
	if(!iscarbon(src))
		if(!HAS_TRAIT(src, TRAIT_SIMPLE_WOUNDS))
			return
	if(!get_blood_id())
		return
	if(!T)
		T = get_turf(src)

	if(amt > 3)
		if(istype(T, /turf/open/water))
			var/turf/open/water/W = T
			W.water_reagent = /datum/reagent/blood // this is dumb, but it works for now
			W.mapped = FALSE // no infinite vitae glitch
			W.water_maximum = 10
			W.water_volume = 10
			W.update_icon()
			return
	var/obj/effect/decal/cleanable/blood/puddle/P = locate() in T
	if(P)
		P.blood_vol += amt
		P.update_icon()
	else
		var/obj/effect/decal/cleanable/blood/drip/D = locate() in T
		if(D)
			D.blood_vol += amt
			D.drips++
			D.update_icon()
		else
			new /obj/effect/decal/cleanable/blood/drip(T)

/mob/living/carbon/human/add_splatter_floor(turf/T, small_drip)
	if(!(NOBLOOD in dna.species.species_traits))
		..()
