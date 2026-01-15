GLOBAL_LIST_INIT(brain_penetration_zones, list(BODY_ZONE_PRECISE_SKULL, BODY_ZONE_HEAD, BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_PRECISE_NOSE, BODY_ZONE_PRECISE_L_EYE, BODY_ZONE_PRECISE_R_EYE))

	/// Calculates the base crit chance based on damage and limb state
	/// Returns the probability value (0-100+) for use in prob() calls
/obj/item/bodypart/proc/calculate_crit_chance(damage_dividend, dam, resistance, base_multiplier = 10, dam_divisor = 7, resistance_penalty = 10, bonus = 0, armor_resistance = 0)
	var/damage_contribution = sqrt(dam) * (dam_divisor / 7)

	var/base_chance = round(damage_dividend * base_multiplier + damage_contribution - resistance_penalty * resistance + bonus, 1)
	if(armor_resistance > 0)
		var/armor_multiplier =  1 - (armor_resistance / 100) * 0.7
		base_chance *= armor_multiplier
	return round(base_chance, 1)

	/// Checks if the damage meets the threshold for a crit to occur
	/// Evaluates EITHER the damage_dividend threshold OR the overkill threshold
/obj/item/bodypart/proc/check_crit_threshold(damage_dividend, dam, resistance, divisor, overkill_difficulty)
	if(damage_dividend >= divisor)
		return TRUE
	if(!overkill_difficulty)
		return FALSE
	return get_overkill_threshold(overkill_difficulty, damage_dividend, dam, resistance)

	/// Checks if a wound should be added based on threshold and probability
/obj/item/bodypart/proc/try_add_crit_wound(wound_type, damage_dividend, dam, resistance, crit_chance, divisor, overkill_difficulty, silent = FALSE, crit_message = FALSE)
	var/threshold_pass = check_crit_threshold(damage_dividend, dam, resistance, divisor, overkill_difficulty)
	if(!threshold_pass)
		return FALSE
	if(!prob(crit_chance))
		return FALSE
	return wound_type

/obj/item/bodypart
	/// List of /datum/wound instances affecting this bodypart
	var/list/datum/wound/wounds
	/// List of items embedded in this bodypart
	var/list/obj/item/embedded_objects = list()
	/// Bandage, if this ever hard dels thats fucking silly lol
	var/obj/item/bandage
	/// Cached bitflag of our last get_surgery_flags call. Used pretty much exclusively to swiftly check bleed rate calls.
	var/cached_surgery_flags = 0

/// Checks if we have any embedded objects whatsoever
/obj/item/bodypart/proc/has_embedded_objects()
	return length(embedded_objects)

/// Checks if we have an embedded object of a specific type
/obj/item/bodypart/proc/has_embedded_object(path, specific = FALSE)
	if(!path)
		return
	for(var/obj/item/embedder as anything in embedded_objects)
		if((specific && embedder.type != path) || !istype(embedder, path))
			continue
		return embedder

/// Checks if an object is embedded in us
/obj/item/bodypart/proc/is_object_embedded(obj/item/embedder)
	if(!embedder)
		return FALSE
	return (embedder in embedded_objects)

/// Returns all wounds on this limb that can be sewn
/obj/item/bodypart/proc/get_sewable_wounds()
	var/list/woundies = list()
	for(var/datum/wound/wound as anything in wounds)
		if(wound == null)
			listclearnulls(wounds) //Putting this somewhere useful but low intensity
			continue
		if(!wound.can_sew)
			continue
		woundies += wound
	return woundies

/// Returns the first wound of the specified type on this bodypart
/obj/item/bodypart/proc/has_wound(path, specific = FALSE)
	if(!path)
		return
	for(var/datum/wound/wound as anything in wounds)
		if((specific && wound.type != path) || !istype(wound, path))
			continue
		return wound

/// Heals wounds on this bodypart by the specified amount
/obj/item/bodypart/proc/heal_wounds(heal_amount)
	if(!length(wounds))
		return FALSE
	if(HAS_TRAIT(owner, TRAIT_SILVER_WEAK) && owner.has_status_effect(/datum/status_effect/fire_handler/fire_stacks/sunder) || owner.has_status_effect(/datum/status_effect/fire_handler/fire_stacks/sunder/blessed))
		return
	var/healed_any = FALSE
	for(var/datum/wound/wound as anything in wounds)
		if(heal_amount <= 0)
			continue
		var/amount_healed = wound.heal_wound(heal_amount)
		heal_amount -= amount_healed
		healed_any = TRUE
	return healed_any

/// Adds a wound to this bodypart, applying any necessary effects
/obj/item/bodypart/proc/add_wound(datum/wound/wound, silent = FALSE, crit_message = FALSE)
	if(!wound || !owner || (owner.status_flags & GODMODE))
		return
	if(ispath(wound, /datum/wound))
		var/datum/wound/primordial_wound = GLOB.primordial_wounds[wound]
		if(!primordial_wound.can_apply_to_bodypart(src))
			return
		wound = new wound()
	else if(!istype(wound))
		return
	else if(!wound.can_apply_to_bodypart(src))
		qdel(wound)
		return
	if(!wound.apply_to_bodypart(src, silent, crit_message))
		qdel(wound)
		return
	return wound

/// Removes a wound from this bodypart, removing any associated effects
/obj/item/bodypart/proc/remove_wound(datum/wound/wound)
	if(ispath(wound))
		wound = has_wound(wound)
	if(!istype(wound))
		return FALSE
	. = wound.remove_from_bodypart()
	if(.)
		qdel(wound)

/// Check to see if we can apply a bleeding wound on this bodypart
/obj/item/bodypart/proc/can_bloody_wound()
	if(skeletonized)
		return FALSE
	if(!is_organic_limb())
		return FALSE
	if(NOBLOOD in owner?.dna?.species?.species_traits)
		return FALSE
	return TRUE

/// Returns the total bleed rate on this bodypart (simple version for backwards compatibility)
/obj/item/bodypart/proc/get_bleed_rate()
	var/bleed_rate = bleeding
	if(bandage && !HAS_BLOOD_DNA(bandage))
		try_bandage_expire()
		return 0
	for(var/obj/item/embedded as anything in embedded_objects)
		if(!embedded.embedding.embedded_bloodloss)
			continue
		bleed_rate += embedded.embedding.embedded_bloodloss
	for(var/obj/item/grabbing/grab in grabbedby)
		bleed_rate *= grab.bleed_suppressing
	bleed_rate = max(round(bleed_rate, 0.1), 0)

	if(cached_surgery_flags & SURGERY_CLAMPED)
		return min(bleed_rate, 0.5)

	return bleed_rate

/// Returns TRUE if this bodypart has an effective bandage (not blood-soaked)
/obj/item/bodypart/proc/is_bandaged()
	return bandage && !HAS_BLOOD_DNA(bandage)

/obj/item/bodypart/proc/calculate_lethal_death_chance(raw_damage, armor_block, mob/living/user)
	if(!owner || !raw_damage)
		return 0

	var/death_chance = min(raw_damage, 100)
	var/damage_ratio = (get_damage() / max_damage) * 100
	death_chance += damage_ratio * 0.5

	if(armor_block > 0)
		var/absorption_ratio = armor_block / (raw_damage + armor_block)
		death_chance *= (1 - absorption_ratio)

	var/con_modifier = (owner.STACON - 10) * 5
	death_chance -= con_modifier

	if(user && user.goodluck(3))
		death_chance += user.STALUC * 2

	death_chance = clamp(death_chance, 1, 40)

	return death_chance

/// Called after a bodypart is attacked so that wounds and critical effects can be applied
/obj/item/bodypart/proc/bodypart_attacked_by(bclass = BCLASS_BLUNT, dam, mob/living/user, zone_precise = src.body_zone, silent = FALSE, crit_message = FALSE, armor, was_blunted = FALSE, raw_damage = 0, armor_block = 0, obj/item/weapon)
	if(!bclass || !dam || !owner || (owner.status_flags & GODMODE))
		return FALSE
	var/do_crit = TRUE
	var/crit_resistance = 0
	var/acheck_dflag
	switch(bclass)
		if(BCLASS_BLUNT, BCLASS_SMASH, BCLASS_TWIST, BCLASS_PUNCH)
			acheck_dflag = "blunt"
		if(BCLASS_CHOP, BCLASS_CUT, BCLASS_LASHING, BCLASS_PUNISH)
			acheck_dflag = "slash"
		if(BCLASS_PICK, BCLASS_STAB)
			acheck_dflag = "stab"
	armor = owner.run_armor_check(zone_precise, acheck_dflag, damage = 0)
	if(ishuman(owner))
		// Attacks blunted by armor never result in a critical hit
		if(was_blunted)
			do_crit = FALSE
		else
			var/mob/living/carbon/human/human_owner = owner
			var/probbonus = 0
			crit_resistance = human_owner.checkcritarmor(zone_precise, bclass)  // Returns 0-100 based on armor durability percentage
			if(user)
				if(user.goodluck(2))
					probbonus = user.STALUC*2

			if(probbonus)
				crit_resistance -= probbonus
			//if(owner.mind && (get_damage() <= (max_damage * 0.9))) //No crits unless the damage is maxed out.
			//	do_crit = FALSE // We used to check if they are buckled or lying down but being grounded is a big enough advantage.
	testing("bodypart_attacked_by() dam [dam]")

	var/datum/wound/dynwound = manage_dynamic_wound(bclass, dam, armor)

	if(do_crit)
		var/datum/component/silverbless/psyblessed = weapon?.GetComponent(/datum/component/silverbless)
		var/sundering = HAS_TRAIT(owner, TRAIT_SILVER_WEAK) && istype(weapon) && weapon?.is_silver && psyblessed?.is_blessed
		var/crit_attempt = try_crit(sundering ? BCLASS_SUNDER : bclass, dam, user, zone_precise, silent, crit_message, raw_damage, armor_block, crit_resistance, was_blunted)
		if(crit_attempt)
			return crit_attempt
	return dynwound

/obj/item/bodypart/proc/manage_dynamic_wound(bclass, dam, armor)
	var/woundtype
	switch(bclass)
		if(BCLASS_BLUNT, BCLASS_SMASH, BCLASS_PUNCH, BCLASS_TWIST)
			woundtype = /datum/wound/dynamic/bruise
		if(BCLASS_BITE)
			woundtype = /datum/wound/dynamic/bite
		if(BCLASS_CHOP, BCLASS_CUT)
			woundtype = /datum/wound/dynamic/slash
		if(BCLASS_STAB)
			woundtype = /datum/wound/dynamic/puncture
		if(BCLASS_PICK, BCLASS_PIERCE)
			woundtype = /datum/wound/dynamic/gouge
		if(BCLASS_LASHING)
			woundtype = /datum/wound/dynamic/lashing
		if(BCLASS_PUNISH)
			woundtype = /datum/wound/dynamic/punish
		else	//Wrong bclass type for wounds, skip adding this.
			return
	var/datum/wound/dynwound = has_wound(woundtype)
	if(!isnull(dynwound))
		dynwound.upgrade(dam, armor)
	else
		if(ispath(woundtype) && woundtype)
			if(!isnull(woundtype))
				var/datum/wound/newwound = add_wound(woundtype)
				dynwound = newwound
				if(newwound && !isnull(newwound))	//don't even ask - Free
					newwound.upgrade(dam, armor)
	return dynwound

/// Behemoth of a proc used to apply a wound after a bodypart is damaged in an attack
/obj/item/bodypart/proc/try_crit(bclass = BCLASS_BLUNT, dam, mob/living/user, zone_precise = src.body_zone, silent = FALSE, crit_message = FALSE, raw_damage = 0, armor_block = 0, armor_resistance = 0, was_blunted = FALSE)
	if(!bclass || !dam || (owner.status_flags & GODMODE))
		return FALSE
	var/list/attempted_wounds = list()
	var/total_dam = get_damage()
	var/damage_dividend = (total_dam / max_damage)
	var/resistance = HAS_TRAIT(owner, TRAIT_CRITICAL_RESISTANCE)
	if(user && dam)
		if(user.goodluck(2))
			dam += 10
	if((bclass == BCLASS_PUNCH) && (user && dam))
		if(user && HAS_TRAIT(user, TRAIT_CIVILIZEDBARBARIAN))
			dam += 15

	var/con_threshold = owner.STACON * (1 - (damage_dividend * 0.5))
	if(dam < con_threshold)
		return FALSE

	var/strong_bonus = (user && istype(user.rmb_intent, /datum/rmb_intent/strong)) ? 10 : 0
	var/aimed_bonus = (user && istype(user.rmb_intent, /datum/rmb_intent/aimed)) ? 10 : 0
	var/brittle_bonus = HAS_TRAIT(src, TRAIT_BRITTLE) ? 10 : 0

	if(bclass in GLOB.dislocation_bclasses)
		var/disloc_chance = calculate_crit_chance(damage_dividend, dam, resistance, armor_resistance = armor_resistance, bonus = strong_bonus)
		var/wound_applied = try_add_crit_wound(
			resistance ? /datum/wound/fracture : /datum/wound/dislocation,
			damage_dividend, dam, resistance,
			disloc_chance, CRIT_LIMB_DISLOCATION_DIVISOR, CRIT_LIMB_DISLOCATION_THRESHOLD,
			silent, crit_message
		)
		if(wound_applied)
			attempted_wounds += wound_applied

	if(bclass in GLOB.fracture_bclasses)
		var/frac_chance = calculate_crit_chance(damage_dividend, dam, resistance, armor_resistance = armor_resistance, bonus = strong_bonus + brittle_bonus)
		var/wound_type = (damage_dividend >= CRIT_LIMB_FRACTURE_DIVISOR) ? /datum/wound/fracture : /datum/wound/dislocation
		var/wound_applied = try_add_crit_wound(
			wound_type,
			damage_dividend, dam, resistance,
			frac_chance, CRIT_LIMB_DISLOCATION_DIVISOR, CRIT_LIMB_DISLOCATION_THRESHOLD,
			silent, crit_message
		)
		if(wound_applied)
			attempted_wounds += wound_applied

	if(bclass in GLOB.artery_bclasses)
		var/artery_bonus = ((bclass in GLOB.artery_strong_bclasses) && strong_bonus) ? strong_bonus : aimed_bonus
		var/artery_chance = calculate_crit_chance(damage_dividend, dam, resistance, armor_resistance = armor_resistance, bonus = artery_bonus)
		var/wound_applied = try_add_crit_wound(
			/datum/wound/artery,
			damage_dividend, dam, resistance,
			artery_chance, CRIT_ARTERY_DIVISOR, CRIT_ARTERY_THRESHOLD,
			silent, crit_message
		)
		if(wound_applied)
			attempted_wounds += wound_applied

	if(bclass in GLOB.whipping_bclasses)
		if(user && istype(user.rmb_intent, /datum/rmb_intent/strong))
			dam += 10
		if(HAS_TRAIT(src, TRAIT_CRITICAL_WEAKNESS))
			attempted_wounds += /datum/wound/artery  // Sword-tier wounds
		var/scar_chance = calculate_crit_chance(damage_dividend, dam, resistance, armor_resistance = armor_resistance)
		var/wound_applied = try_add_crit_wound(
			/datum/wound/scarring,
			damage_dividend, dam, resistance,
			scar_chance, CRIT_SCARRING_DIVISOR, CRIT_SCARRING_THRESHOLD,
			silent, crit_message
		)
		if(wound_applied)
			attempted_wounds += wound_applied

	if((bclass in GLOB.sunder_bclasses) && !was_blunted)
		if(HAS_TRAIT(owner, TRAIT_SILVER_WEAK) && !owner.has_status_effect(STATUS_EFFECT_ANTIMAGIC))
			var/sunder_chance = calculate_crit_chance(damage_dividend, dam, resistance, armor_resistance = armor_resistance, dam_divisor = 2)
			if(prob(sunder_chance))
				attempted_wounds += /datum/wound/sunder/head

	for(var/wound_type in shuffle(attempted_wounds))
		var/datum/wound/applied = add_wound(wound_type, silent, crit_message)
		if(applied)
			if(user?.client)
				record_round_statistic(STATS_CRITS_MADE)
			return applied
	return FALSE

/obj/item/bodypart/chest/try_crit(bclass, dam, mob/living/user, zone_precise, silent = FALSE, crit_message = FALSE, raw_damage = 0, armor_block = 0, armor_resistance = 0, was_blunted = FALSE)
	if(!bclass || !dam || (owner.status_flags & GODMODE))
		return FALSE
	var/list/attempted_wounds = list()
	var/total_dam = get_damage()
	var/damage_dividend = (total_dam / max_damage)
	var/resistance = HAS_TRAIT(owner, TRAIT_CRITICAL_RESISTANCE)

	if(user && dam)
		if(user.goodluck(2))
			dam += 10

	var/con_threshold = owner.STACON * (1 - (damage_dividend * 0.5))
	if(dam < con_threshold)
		return FALSE

	var/strong_bonus = (user && istype(user.rmb_intent, /datum/rmb_intent/strong)) ? 10 : 0
	var/aimed_bonus = (user && istype(user.rmb_intent, /datum/rmb_intent/aimed)) ? 10 : 0
	var/brittle_bonus = HAS_TRAIT(src, TRAIT_BRITTLE) ? 10 : 0

	if((bclass in GLOB.cbt_classes) && (zone_precise == BODY_ZONE_PRECISE_GROIN))
		var/cbt_multiplier = 1
		if(user && HAS_TRAIT(user, TRAIT_NUTCRACKER))
			cbt_multiplier = 2
		var/cbt_chance = round(dam/5) * cbt_multiplier
		if(!resistance)
			var/wound_applied = try_add_crit_wound(
				/datum/wound/cbt,
				damage_dividend, dam, resistance,
				cbt_chance, CRIT_CBT_DIVISOR, CRIT_CBT_THRESHOLD,
				silent, crit_message
			)
			if(wound_applied)
				attempted_wounds += wound_applied
		if(prob(dam * cbt_multiplier))
			owner.emote("groin", TRUE)
			owner.Stun(10)

	if((bclass in GLOB.fracture_bclasses) && (zone_precise != BODY_ZONE_PRECISE_STOMACH))
		var/frac_chance = calculate_crit_chance(damage_dividend, dam, resistance, armor_resistance = armor_resistance, bonus = strong_bonus + brittle_bonus)
		var/fracture_type = /datum/wound/fracture/chest
		var/frac_divisor = CRIT_CHEST_FRACTURE_DIVISOR
		var/frac_threshold = CRIT_CHEST_FRACTURE_THRESHOLD
		if(zone_precise == BODY_ZONE_PRECISE_GROIN)
			if(damage_dividend >= CRIT_GROIN_FRACTURE_DIVISOR)
				fracture_type = /datum/wound/fracture/groin
			frac_divisor = CRIT_GROIN_FRACTURE_DIVISOR
			frac_threshold = CRIT_GROIN_FRACTURE_THRESHOLD
		var/wound_applied = try_add_crit_wound(
			fracture_type,
			damage_dividend, dam, resistance,
			frac_chance, frac_divisor, frac_threshold,
			silent, crit_message
		)
		if(wound_applied)
			attempted_wounds += wound_applied

	if(bclass in GLOB.artery_bclasses)
		var/artery_bonus = ((bclass in GLOB.artery_strong_bclasses) && strong_bonus) ? strong_bonus : aimed_bonus
		var/artery_chance = calculate_crit_chance(damage_dividend, dam, resistance, armor_resistance = armor_resistance, dam_divisor = 10, bonus = artery_bonus)
		if((zone_precise == BODY_ZONE_PRECISE_STOMACH) && !resistance && (bclass in GLOB.disembowel_bclasses))
			var/wound_applied = try_add_crit_wound(
				/datum/wound/slash/disembowel,
				damage_dividend, dam, resistance,
				artery_chance, CRIT_DISEMBOWEL_DIVISOR, CRIT_DISEMBOWEL_THRESHOLD,
				silent, crit_message
			)
			if(wound_applied)
				attempted_wounds += wound_applied

		var/artery_type = /datum/wound/artery
		var/artery_divisor = CRIT_ARTERY_DIVISOR
		var/artery_threshold = CRIT_ARTERY_THRESHOLD
		if(owner.has_wound(/datum/wound/fracture/chest) || (bclass in GLOB.artery_heart_bclasses) || HAS_TRAIT(owner, TRAIT_CRITICAL_WEAKNESS))
			artery_type = /datum/wound/artery/chest
			artery_divisor = CRIT_ARTERY_CHEST_DIVISOR
			artery_threshold = CRIT_ARTERY_CHEST_THRESHOLD
		var/wound_applied = try_add_crit_wound(
			artery_type,
			damage_dividend, dam, resistance,
			artery_chance, artery_divisor, artery_threshold,
			silent, crit_message
		)
		if(wound_applied)
			attempted_wounds += wound_applied

	if(bclass in GLOB.whipping_bclasses)
		if(user && istype(user.rmb_intent, /datum/rmb_intent/strong))
			dam += 10
		var/scar_chance = calculate_crit_chance(damage_dividend, dam, resistance, armor_resistance = armor_resistance, dam_divisor = 10)
		if(HAS_TRAIT(owner, TRAIT_CRITICAL_WEAKNESS))
			attempted_wounds += /datum/wound/artery/chest
		else
			var/wound_applied = try_add_crit_wound(
				/datum/wound/scarring,
				damage_dividend, dam, resistance,
				scar_chance, CRIT_SCARRING_DIVISOR, CRIT_SCARRING_THRESHOLD,
				silent, crit_message
			)
			if(wound_applied)
				attempted_wounds += wound_applied

	if(bclass in GLOB.stab_bclasses)
		var/stab_chance = calculate_crit_chance(damage_dividend, dam, resistance, armor_resistance = armor_resistance, dam_divisor = 2, resistance_penalty = 12, bonus = aimed_bonus ? 12 : 0)
		if(check_crit_threshold(damage_dividend, dam, resistance, CRIT_CHEST_ORGAN_STAB_DIVISOR, CRIT_CHEST_ORGAN_STAB_THRESHOLD) && prob(stab_chance))
			var/is_construct = isgolemp(owner) || isdoll(owner)
			if(zone_precise == BODY_ZONE_CHEST)
				if(prob(20) && owner.getorganslot(ORGAN_SLOT_HEART))
					attempted_wounds += /datum/wound/lethal/heart_penetration
				else if(!is_construct && owner.getorganslot(ORGAN_SLOT_LUNGS))
					attempted_wounds += /datum/wound/lethal/lung_penetration
			else if(zone_precise == BODY_ZONE_PRECISE_STOMACH)
				if(!is_construct && prob(50) && owner.getorganslot(ORGAN_SLOT_LIVER))
					attempted_wounds += /datum/wound/lethal/liver_penetration
				else if(!is_construct && owner.getorganslot(ORGAN_SLOT_STOMACH))
					attempted_wounds += /datum/wound/lethal/stomach_penetration

	if(bclass in GLOB.artery_bclasses)
		var/slash_chance = calculate_crit_chance(damage_dividend, dam, resistance, armor_resistance = armor_resistance, base_multiplier = 15, resistance_penalty = 15, bonus = strong_bonus)
		if(check_crit_threshold(damage_dividend, dam, resistance, CRIT_CHEST_ORGAN_SLASH_DIVISOR, CRIT_CHEST_ORGAN_SLASH_THRESHOLD) && prob(slash_chance))
			var/is_construct = isgolemp(owner) || isdoll(owner)
			if(zone_precise == BODY_ZONE_CHEST)
				if(prob(10) && owner.getorganslot(ORGAN_SLOT_HEART))
					attempted_wounds += /datum/wound/lethal/heart_penetration
				else if(!is_construct && owner.getorganslot(ORGAN_SLOT_LUNGS))
					attempted_wounds += /datum/wound/lethal/lung_penetration
			else if(zone_precise == BODY_ZONE_PRECISE_STOMACH)
				if(!is_construct && prob(50) && owner.getorganslot(ORGAN_SLOT_LIVER))
					attempted_wounds += /datum/wound/lethal/liver_penetration
				else if(!is_construct && owner.getorganslot(ORGAN_SLOT_STOMACH))
					attempted_wounds += /datum/wound/lethal/stomach_penetration

	if((bclass in GLOB.fracture_bclasses) && owner.has_wound(/datum/wound/fracture/chest) && (zone_precise == BODY_ZONE_CHEST))
		var/blunt_chance = calculate_crit_chance(damage_dividend, dam, resistance, armor_resistance = armor_resistance, base_multiplier = 18, resistance_penalty = 12, bonus = strong_bonus)
		if(check_crit_threshold(damage_dividend, dam, resistance, CRIT_CHEST_ORGAN_BLUNT_DIVISOR, CRIT_CHEST_ORGAN_BLUNT_THRESHOLD) && prob(blunt_chance))
			var/is_construct = isgolemp(owner) || isdoll(owner)
			if(prob(20) && owner.getorganslot(ORGAN_SLOT_HEART))
				var/datum/wound/lethal/heart_penetration/bone_frag_wound = new /datum/wound/lethal/heart_penetration(dam)
				bone_frag_wound.from_fracture = TRUE
				attempted_wounds += bone_frag_wound
			else if(!is_construct && owner.getorganslot(ORGAN_SLOT_LUNGS))
				var/datum/wound/lethal/lung_penetration/bone_frag_wound = new /datum/wound/lethal/lung_penetration(dam)
				bone_frag_wound.from_fracture = TRUE
				attempted_wounds += bone_frag_wound

	for(var/wound_type in shuffle(attempted_wounds))
		var/datum/wound/applied = add_wound(wound_type, silent, crit_message)
		if(applied)
			if(user?.client)
				record_round_statistic(STATS_CRITS_MADE)
			return applied
	return FALSE

/obj/item/bodypart/head/try_crit(bclass, dam, mob/living/user, zone_precise, silent = FALSE, crit_message = FALSE, raw_damage = 0, armor_block = 0, armor_resistance = 0, was_blunted = FALSE)
	var/static/list/eyestab_zones = list(BODY_ZONE_PRECISE_R_EYE, BODY_ZONE_PRECISE_L_EYE)
	var/static/list/tonguestab_zones = list(BODY_ZONE_PRECISE_MOUTH)
	var/static/list/nosestab_zones = list(BODY_ZONE_PRECISE_NOSE)
	var/static/list/earstab_zones = list(BODY_ZONE_PRECISE_EARS)
	var/static/list/knockout_zones = list(BODY_ZONE_HEAD, BODY_ZONE_PRECISE_SKULL)
	var/list/attempted_wounds = list()
	var/total_dam = get_damage()
	var/damage_dividend = (total_dam / max_damage)
	var/resistance = HAS_TRAIT(owner, TRAIT_CRITICAL_RESISTANCE)

	if(user && dam)
		if(user.goodluck(2))
			dam += 10

	var/con_threshold = owner.STACON * (1 - (damage_dividend * 0.5))
	if(dam < con_threshold)
		return FALSE

	var/from_behind = FALSE
	if(user && (owner.dir == turn(get_dir(owner,user), 180)))
		from_behind = TRUE

	var/strong_bonus = (user && istype(user.rmb_intent, /datum/rmb_intent/strong)) ? 10 : 0
	var/aimed_bonus = (user && istype(user.rmb_intent, /datum/rmb_intent/aimed)) ? 10 : 0
	var/brittle_bonus = HAS_TRAIT(src, TRAIT_BRITTLE) ? 20 : 0
	var/sneak_bonus = (user && user.m_intent == MOVE_INTENT_SNEAK) ? 10 : 0

	if((bclass in GLOB.dislocation_bclasses) && (total_dam >= max_damage))
		var/neck_disloc_chance = calculate_crit_chance(damage_dividend, dam, resistance, armor_resistance = armor_resistance)
		if(prob(neck_disloc_chance))
			if(HAS_TRAIT(src, TRAIT_BRITTLE))
				attempted_wounds += /datum/wound/fracture/neck
			else if (!resistance)
				attempted_wounds += /datum/wound/dislocation/neck


	if(bclass in GLOB.fracture_bclasses)
		var/frac_bonus = brittle_bonus + strong_bonus + sneak_bonus
		var/frac_chance = calculate_crit_chance(damage_dividend, dam, resistance, armor_resistance = armor_resistance, bonus = frac_bonus)

		if(!owner.stat && !resistance && (zone_precise in knockout_zones) && (bclass != BCLASS_CHOP && bclass != BCLASS_PIERCE) && prob(frac_chance))
			owner.next_attack_msg += " <span class='crit'><b>Critical hit!</b> [owner] is knocked out[from_behind ? " FROM BEHIND" : ""]!</span>"
			owner.flash_fullscreen("whiteflash3")
			owner.Unconscious(5 SECONDS + (from_behind * 10 SECONDS))
			if(owner.client)
				winset(owner.client, "outputwindow.output", "max-lines=1")
				winset(owner.client, "outputwindow.output", "max-lines=100")

		var/dislocation_type
		var/fracture_type = /datum/wound/fracture/head
		var/frac_divisor = CRIT_HEAD_FRACTURE_DIVISOR
		var/frac_threshold = CRIT_HEAD_FRACTURE_THRESHOLD
		var/is_lethal_fracture = FALSE

		if(resistance)
			fracture_type = /datum/wound/fracture
		else
			switch(zone_precise)
				if(BODY_ZONE_PRECISE_SKULL)
					fracture_type = /datum/wound/fracture/head/brain
					frac_divisor = CRIT_SKULL_FRACTURE_DIVISOR
					frac_threshold = CRIT_SKULL_FRACTURE_THRESHOLD
					is_lethal_fracture = TRUE
				if(BODY_ZONE_PRECISE_EARS)
					fracture_type = /datum/wound/fracture/head/ears
					frac_divisor = CRIT_FACE_FRACTURE_DIVISOR
					frac_threshold = CRIT_FACE_FRACTURE_THRESHOLD
				if(BODY_ZONE_PRECISE_NOSE)
					fracture_type = /datum/wound/fracture/head/nose
					frac_divisor = CRIT_FACE_FRACTURE_DIVISOR
					frac_threshold = CRIT_FACE_FRACTURE_THRESHOLD
					is_lethal_fracture = TRUE
				if(BODY_ZONE_PRECISE_MOUTH)
					fracture_type = /datum/wound/fracture/mouth
					frac_divisor = CRIT_MOUTH_FRACTURE_DIVISOR
					frac_threshold = CRIT_MOUTH_FRACTURE_THRESHOLD
				if(BODY_ZONE_PRECISE_NECK)
					fracture_type = /datum/wound/fracture/neck
					dislocation_type = /datum/wound/dislocation/neck
					frac_divisor = CRIT_NECK_FRACTURE_DIVISOR
					frac_threshold = CRIT_NECK_FRACTURE_THRESHOLD
					is_lethal_fracture = TRUE

		if(check_crit_threshold(damage_dividend, dam, resistance, frac_divisor, frac_threshold) && prob(frac_chance))
			if(dislocation_type)
				attempted_wounds += dislocation_type
			if(is_lethal_fracture)
				var/death_prob = calculate_lethal_death_chance(raw_damage, armor_block, user)
				var/datum/wound/fracture/lethal_fracture = new fracture_type()
				lethal_fracture.death_probability = death_prob
				attempted_wounds += lethal_fracture
			else
				attempted_wounds += fracture_type

	if(bclass in GLOB.artery_bclasses)
		var/artery_bonus = (bclass == BCLASS_CHOP) ? strong_bonus : aimed_bonus
		var/artery_chance = calculate_crit_chance(damage_dividend, dam, resistance, armor_resistance = armor_resistance, bonus = artery_bonus)

		var/artery_type = /datum/wound/artery
		var/artery_divisor = CRIT_ARTERY_DIVISOR
		var/artery_threshold = CRIT_ARTERY_THRESHOLD
		if(zone_precise == BODY_ZONE_PRECISE_NECK)
			artery_type = /datum/wound/artery/neck
			artery_divisor = CRIT_ARTERY_NECK_DIVISOR
			artery_threshold = CRIT_ARTERY_NECK_THRESHOLD

		var/wound_applied = try_add_crit_wound(
			artery_type,
			damage_dividend, dam, resistance,
			artery_chance, artery_divisor, artery_threshold,
			silent, crit_message
		)
		if(wound_applied)
			attempted_wounds += wound_applied

		if((bclass in GLOB.stab_bclasses) && !resistance && prob(artery_chance))
			if(check_crit_threshold(damage_dividend, dam, resistance, CRIT_FACIAL_STAB_DIVISOR, CRIT_FACIAL_STAB_THRESHOLD))
				if(zone_precise in earstab_zones)
					var/obj/item/organ/ears/my_ears = owner.getorganslot(ORGAN_SLOT_EARS)
					if(!my_ears || has_wound(/datum/wound/facial/ears))
						attempted_wounds += /datum/wound/fracture/head/ears
					else
						attempted_wounds += /datum/wound/facial/ears
				else if(zone_precise in eyestab_zones)
					var/obj/item/organ/my_eyes = owner.getorganslot(ORGAN_SLOT_EYES)
					if(!my_eyes || (has_wound(/datum/wound/facial/eyes/left) && has_wound(/datum/wound/facial/eyes/right)))
						attempted_wounds += /datum/wound/fracture/head/eyes
					else if(my_eyes)
						if(zone_precise == BODY_ZONE_PRECISE_R_EYE)
							attempted_wounds += /datum/wound/facial/eyes/right
						else if(zone_precise == BODY_ZONE_PRECISE_L_EYE)
							attempted_wounds += /datum/wound/facial/eyes/left
				else if(zone_precise in tonguestab_zones)
					var/obj/item/organ/tongue/tongue_up_my_asshole = owner.getorganslot(ORGAN_SLOT_TONGUE)
					if(!tongue_up_my_asshole || has_wound(/datum/wound/facial/tongue))
						attempted_wounds += /datum/wound/fracture/mouth
					else
						attempted_wounds += /datum/wound/facial/tongue
				else if(zone_precise in nosestab_zones)
					if(has_wound(/datum/wound/facial/disfigurement/nose))
						attempted_wounds +=/datum/wound/fracture/head/nose
					else
						attempted_wounds += /datum/wound/facial/disfigurement/nose

	if((bclass in GLOB.sunder_bclasses) && !was_blunted)
		if(HAS_TRAIT(owner, TRAIT_SILVER_WEAK) && !owner.has_status_effect(STATUS_EFFECT_ANTIMAGIC))
			var/sunder_chance = calculate_crit_chance(damage_dividend, dam, resistance, armor_resistance = armor_resistance, dam_divisor = 2)
			if(prob(sunder_chance))
				attempted_wounds += /datum/wound/sunder

	var/is_construct = isgolemp(owner) || isdoll(owner)
	if(!is_construct && (bclass in GLOB.stab_bclasses) && (zone_precise in GLOB.brain_penetration_zones))
		var/brain_stab_chance = calculate_crit_chance(damage_dividend, dam, resistance, armor_resistance = armor_resistance, base_multiplier = 25, dam_divisor = 2, resistance_penalty = 15, bonus = strong_bonus ? 15 : 0)
		if(check_crit_threshold(damage_dividend, dam, resistance, CRIT_BRAIN_PENETRATION_DIVISOR, CRIT_BRAIN_PENETRATION_THRESHOLD) && prob(brain_stab_chance) && owner.getorganslot(ORGAN_SLOT_BRAIN))
			attempted_wounds += /datum/wound/lethal/brain_penetration

	if(!is_construct && (bclass in GLOB.fracture_bclasses) && owner.has_wound(/datum/wound/fracture/head))
		var/brain_blunt_chance = calculate_crit_chance(damage_dividend, dam, resistance, armor_resistance = armor_resistance, resistance_penalty = 12, bonus = strong_bonus ? 12 : 0)
		if(check_crit_threshold(damage_dividend, dam, resistance, CRIT_BRAIN_BLUNT_DIVISOR, CRIT_BRAIN_BLUNT_THRESHOLD) && prob(brain_blunt_chance) && owner.getorganslot(ORGAN_SLOT_BRAIN))
			var/datum/wound/lethal/brain_penetration/bone_frag_wound = new /datum/wound/lethal/brain_penetration(dam)
			bone_frag_wound.from_fracture = TRUE
			attempted_wounds += bone_frag_wound

	for(var/wound_type in shuffle(attempted_wounds))
		var/datum/wound/applied = add_wound(wound_type, silent, crit_message)
		if(applied)
			if(user?.client)
				record_round_statistic(STATS_CRITS_MADE)
			return applied
	return FALSE

/// Returns the overkill critical hit threshold for a body part
/obj/item/bodypart/proc/get_overkill_threshold(difficulty, damage_dividend, damage, resistance)
	var/overkill_threshold = (damage >= (difficulty + owner.STACON))
	return overkill_threshold

/// Embeds an object in this bodypart
/obj/item/bodypart/proc/add_embedded_object(obj/item/embedder, silent = FALSE, crit_message = FALSE)
	if(!embedder || !can_embed(embedder))
		return FALSE
	if(owner && ((owner.status_flags & GODMODE) || HAS_TRAIT(owner, TRAIT_PIERCEIMMUNE)))
		return FALSE
	if(istype(embedder, /obj/item/natural/worms/leech))
		record_round_statistic(STATS_LEECHES_EMBEDDED)
	LAZYADD(embedded_objects, embedder)
	embedder.is_embedded = TRUE
	embedder.forceMove(src)
	if(owner)
		// Invalidate mob bleed cache since we added an embedded object
		if(iscarbon(owner))
			var/mob/living/carbon/C = owner
			C.invalidate_bleed_cache()
		embedder.add_mob_blood(owner)
		if (!silent)
			playsound(owner, 'sound/combat/newstuck.ogg', 100, vary = TRUE)
			if (owner.has_status_effect(/datum/status_effect/buff/ozium))
				owner.emote ("exhales")
			if (owner.has_status_effect(/datum/status_effect/buff/drunk) && !owner.has_status_effect(/datum/status_effect/buff/ozium))
				owner.emote("pain")
			if (!owner.has_status_effect(/datum/status_effect/buff/drunk) && !owner.has_status_effect(/datum/status_effect/buff/ozium))
				owner.emote("embed")
		if(crit_message)
			owner.next_attack_msg += " <span class='userdanger'>[embedder] runs through [owner]'s [src]!</span>"
		update_disabled()
		if(embedder.is_silver && HAS_TRAIT(owner, TRAIT_SILVER_WEAK) && !owner.has_status_effect(STATUS_EFFECT_ANTIMAGIC))
			var/datum/component/silverbless/psyblessed = embedder.GetComponent(/datum/component/silverbless)
			owner.adjust_fire_stacks(1, psyblessed?.is_blessed ? /datum/status_effect/fire_handler/fire_stacks/sunder/blessed : /datum/status_effect/fire_handler/fire_stacks/sunder)
			to_chat(owner, span_danger("the [embedder] in your body painfully jostles!"))
	return TRUE

/// Removes an embedded object from this bodypart
/obj/item/bodypart/proc/remove_embedded_object(obj/item/embedder)
	if(!embedder)
		return FALSE
	if(ispath(embedder))
		embedder = has_embedded_object(embedder)
	if(!istype(embedder) || !is_object_embedded(embedder))
		return FALSE
	LAZYREMOVE(embedded_objects, embedder)
	embedder.is_embedded = FALSE
	var/drop_location = owner?.drop_location() || drop_location()
	if(drop_location)
		embedder.forceMove(drop_location)
	else
		qdel(embedder)
	if(owner)
		// Invalidate mob bleed cache since we removed an embedded object
		if(iscarbon(owner))
			var/mob/living/carbon/C = owner
			C.invalidate_bleed_cache()
		if(!owner.has_embedded_objects())
			owner.clear_alert("embeddedobject")
			SEND_SIGNAL(owner, COMSIG_CLEAR_MOOD_EVENT, "embedded")
		update_disabled()
	if (embedder.embedding?.clamp_limbs)
		get_surgery_flags() // hacky workaround that ensures cached clamp flag status updates properly
	return TRUE

/obj/item/bodypart/proc/try_bandage(obj/item/new_bandage)
	if(!new_bandage)
		return FALSE
	bandage = new_bandage
	new_bandage.forceMove(src)
	// Invalidate bleed cache since bandage affects bleeding
	if(owner && iscarbon(owner))
		var/mob/living/carbon/C = owner
		C.invalidate_bleed_cache()
	return TRUE

/obj/item/bodypart/proc/try_bandage_expire()
	if(!bandage)
		return FALSE
	var/bandage_effectiveness = 0.5
	if(istype(bandage, /obj/item/natural/cloth))
		var/obj/item/natural/cloth/cloth = bandage
		bandage_effectiveness = cloth.bandage_effectiveness
	var/highest_bleed_rate = 0
	for(var/datum/wound/wound as anything in wounds)
		if(wound.bleed_rate < highest_bleed_rate)
			continue
		highest_bleed_rate = wound.bleed_rate
	for(var/obj/item/embedded as anything in embedded_objects)
		if(!embedded.embedding.embedded_bloodloss)
			continue
		if(embedded.embedding.embedded_bloodloss < highest_bleed_rate)
			continue
		highest_bleed_rate = embedded.embedding.embedded_bloodloss
	highest_bleed_rate = round(highest_bleed_rate, 0.1)
	if(bandage_effectiveness < highest_bleed_rate)
		return bandage_expire()
	return FALSE

/obj/item/bodypart/proc/bandage_expire()
	testing("expire bandage")
	if(!owner)
		return FALSE
	if(!bandage)
		return FALSE
	// Invalidate bleed cache since bandage is expiring
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		C.invalidate_bleed_cache()
	if(owner.stat != DEAD)
		to_chat(owner, span_warning("Blood soaks through the bandage on my [name]."))
	return bandage.add_mob_blood(owner)

/obj/item/bodypart/proc/remove_bandage()
	if(!bandage)
		return FALSE
	var/drop_location = owner?.drop_location() || drop_location()
	if(drop_location)
		bandage.forceMove(drop_location)
	else
		qdel(bandage)
	bandage = null
	// Invalidate bleed cache since bandage was removed
	if(owner && iscarbon(owner))
		var/mob/living/carbon/C = owner
		C.invalidate_bleed_cache()
	owner?.update_damage_overlays()
	return TRUE

/// Applies a temporary paralysis effect to this bodypart
/obj/item/bodypart/proc/temporary_crit_paralysis(duration = 60 SECONDS, brittle = TRUE)
	if(HAS_TRAIT(src, TRAIT_BRITTLE))
		return FALSE
	ADD_TRAIT(src, TRAIT_PARALYSIS, CRIT_TRAIT)
	if(brittle)
		ADD_TRAIT(src, TRAIT_BRITTLE, CRIT_TRAIT)
	addtimer(CALLBACK(src, PROC_REF(remove_crit_paralysis)), duration)
	if(owner)
		update_disabled()
	return TRUE

/// Removes the temporary paralysis effect from this bodypart
/obj/item/bodypart/proc/remove_crit_paralysis()
	REMOVE_TRAIT(src, TRAIT_PARALYSIS, CRIT_TRAIT)
	REMOVE_TRAIT(src, TRAIT_BRITTLE, CRIT_TRAIT)
	if(owner)
		update_disabled()
	return TRUE

/// Returns surgery flags applicable to this bodypart
/obj/item/bodypart/proc/get_surgery_flags()
	// oh sweet mother of christ what the FUCK is this. this is called EVERY TIME BLEED RATE IS CHECKED.
	// why do we BUILD THIS every time instead of applying the appropriate flags??? i'm SO CONFUSED.
	var/returned_flags = NONE
	if(can_bloody_wound())
		returned_flags |= SURGERY_BLOODY
	for(var/datum/wound/slash/incision/incision in wounds)
		if(incision.is_sewn())
			continue
		returned_flags |= SURGERY_INCISED
		break
	if(owner?.construct) // Construct snowflake check.
		for(var/datum/wound/slash/incision/construct/incision in wounds)
			if(incision.is_sewn())
				continue
			returned_flags |= SURGERY_INCISED
			break
		returned_flags |= SURGERY_CONSTRUCT
	var/static/list/retracting_behaviors = list(
		TOOL_RETRACTOR,
		TOOL_CROWBAR,
		TOOL_IMPROVISED_RETRACTOR,
	)
	var/static/list/clamping_behaviors = list(
		TOOL_HEMOSTAT,
		TOOL_WIRECUTTER,
		TOOL_IMPROVISED_HEMOSTAT,
	)
	for(var/obj/item/embedded as anything in embedded_objects)
		if((embedded.tool_behaviour in retracting_behaviors) || embedded.embedding?.retract_limbs)
			returned_flags |= SURGERY_RETRACTED
		if((embedded.tool_behaviour in clamping_behaviors) || embedded.embedding?.clamp_limbs)
			returned_flags |= SURGERY_CLAMPED
	if(has_wound(/datum/wound/dislocation))
		returned_flags |= SURGERY_DISLOCATED
	if(has_wound(/datum/wound/fracture))
		returned_flags |= SURGERY_BROKEN
	if(has_wound(/datum/wound/slash/vein))
		returned_flags |= SURGERY_CUTVEIN
	for(var/datum/wound/puncture/drilling/drilling in wounds)
		if(drilling.is_sewn())
			continue
		returned_flags |= SURGERY_DRILLED
	if(skeletonized)
		returned_flags |= SURGERY_INCISED | SURGERY_RETRACTED | SURGERY_DRILLED //ehh... we have access to whatever organ is there
	
	cached_surgery_flags = returned_flags
	return returned_flags
