// Magi 2 compatibility stubs
// Provides type declarations and proc stubs for Azure-Peak-specific machinery that
// spell_cooldown.dm references but Emerald Summit does not (yet) have a port of.
//
// These are intentionally MINIMAL — they exist only so the spell base compiles.
// Future ports of the upstream Arcyne combat / implement / featured-stats systems
// will REPLACE these stubs with real implementations.

// ---- Missing status effect types ----
// Referenced by spell_cooldown.dm but not present in Emerald Summit's roguebuff.dm.
// Empty subtype of the buff base so type paths resolve. Application is a no-op
// in the adapter layer; nothing applies these yet.

/// Residual Focus — granted by the Magi 2 implement system. Carries a `pool` of energy
/// drained from the cast that gets returned to the holder evenly over 20 seconds.
/// Applied via `target.apply_status_effect(/datum/status_effect/buff/residual_focus, pool)`
/// from /datum/action/cooldown/spell.apply_residual_focus().
/datum/status_effect/buff/residual_focus
	id = "residual_focus"
	duration = 20 SECONDS
	tick_interval = 1 SECONDS
	/// Total energy to return over the duration (positive number). Set on apply.
	var/pool = 0
	/// Per-tick energy refund — pool / 20.
	var/per_tick = 0

/datum/status_effect/buff/residual_focus/on_creation(mob/living/new_owner, new_pool = 0)
	pool = max(0, new_pool)
	per_tick = pool / 20
	return ..()

/datum/status_effect/buff/residual_focus/tick()
	if(QDELETED(owner) || per_tick <= 0)
		return
	owner.energy_add(per_tick)

/datum/status_effect/buff/parry_buffer
	id = "parry_buffer"
	duration = 5 SECONDS

/datum/status_effect/buff/arcyne_momentum
	id = "arcyne_momentum"
	duration = 30 SECONDS
	var/stacks = 0

/datum/status_effect/buff/arcyne_momentum/proc/consume_all_stacks()
	stacks = 0
	qdel(src)

/datum/status_effect/recent_weapon
	id = "recent_weapon"
	duration = 5 SECONDS

// ---- Missing helpers referenced by spell_cooldown.dm ----

/// Returns the implement weapon held by the user, if any. Stub: always null.
/// Real implementation will check rogueweapon.implement_refund once that var is ported.
/proc/arcyne_get_weapon(mob/user)
	return null

/// Simplified port of Azure-Peak's arcyne_strike — applies spell damage with armor block
/// and wound roll, returns damage dealt after armor. AP's full version handles parry/clash
/// integration, attack animations, hit verbs, and integrity messaging via VISMSG_*; we
/// strip those for the pilot since they require porting Arcyne combat helpers we don't have.
/proc/arcyne_strike(mob/living/carbon/human/user, mob/living/target, obj/item/weapon, damage, def_zone, blade_class_override, armor_penetration = 0, spell_name = "Arcyne Strike", skip_animation = FALSE, skip_message = FALSE, allow_shield_check = FALSE, damage_type = BRUTE, npc_simple_damage_mult = 1, intdamage_factor)
	if(!user || !target || QDELETED(user) || QDELETED(target))
		return 0

	var/blade_class = blade_class_override || BCLASS_CUT
	var/attack_flag = "slash"
	switch(blade_class)
		if(BCLASS_BLUNT, BCLASS_SMASH)
			blade_class = BCLASS_BLUNT
			attack_flag = "blunt"
		if(BCLASS_STAB, BCLASS_PICK)
			blade_class = BCLASS_STAB
			attack_flag = "stab"
		if(BCLASS_BURN)
			attack_flag = "fire"
		else
			blade_class = BCLASS_CUT
			attack_flag = "slash"

	if(!def_zone)
		def_zone = user.zone_selected || BODY_ZONE_CHEST

	if(iscarbon(target))
		var/mob/living/carbon/C = target
		var/obj/item/bodypart/targeting = C.get_bodypart(check_zone(def_zone))
		if(!targeting)
			def_zone = BODY_ZONE_CHEST

	// Optional shield check — defer to existing check_shields if the target is human.
	if(allow_shield_check && ishuman(target) && user != target)
		var/mob/living/carbon/human/H = target
		if(H.check_shields(weapon, damage, spell_name, MELEE_ATTACK, armor_penetration))
			for(var/obj/item/I in H.held_items)
				if(I.block_chance > 0)
					I.take_damage(floor(damage / 4))
					break
			return 0

	if(npc_simple_damage_mult != 1 && istype(target, /mob/living/simple_animal))
		damage = round(damage * npc_simple_damage_mult)

	if(isnull(intdamage_factor))
		intdamage_factor = 1
	var/armor_block = target.run_armor_check(def_zone, attack_flag, blade_dulling = blade_class, armor_penetration = armor_penetration, damage = damage, intdamfactor = intdamage_factor)
	var/damage_dealt = target.apply_damage(damage, damage_type, def_zone, armor_block)
	SEND_SIGNAL(target, COMSIG_ATOM_WAS_ATTACKED, user, damage)

	if(damage_dealt)
		var/wound_damage = max(0, damage - armor_block)
		if(wound_damage > 0)
			if(iscarbon(target))
				var/mob/living/carbon/C = target
				var/obj/item/bodypart/affecting = C.get_bodypart(check_zone(def_zone))
				if(affecting)
					affecting.bodypart_attacked_by(blade_class, wound_damage, user, def_zone, crit_message = TRUE, weapon = weapon)
			else
				target.simple_woundcritroll(blade_class, wound_damage, user, def_zone, crit_message = TRUE)

	if(!skip_message)
		var/verb_text = (blade_class == BCLASS_BURN) ? "scorches" : "strikes"
		target.visible_message(
			span_danger("[user] [verb_text] [target] with [lowertext(spell_name)]!"),
			span_danger("[user] [verb_text] me with [lowertext(spell_name)]!")
		)

	log_combat(user, target, "spell-struck ([spell_name])")
	return max(0, damage - armor_block)

// `isarcyne`, `record_featured_object_stat`, and `mouse_angle_from_client` already exist in
// Emerald Summit (code/datums/magic_items/mages_mechanics.dm/mageritualrunes.dm,
// code/__HELPERS/round_statistics.dm, code/__HELPERS/mouse_control.dm respectively).
// We use the existing implementations.

// ---- Defines for residual_focus / parry_buffer / arcyne_momentum integration ----
// Used by spell_cooldown.dm spell_guard_check. Picked to match Azure-Peak values.
#define RIPOSTE_SHARPNESS_FACTOR 0.05
#define RIPOSTE_INTEG_DIVISOR 20
#define INTEG_PARRY_DECAY_NOSHARP 2

// ---- /obj/item/rogueweapon stub var ----
// Implement refund pool. Magi 2 weapons set this to fractional values (0.20 / 0.275 / 0.35).
// Existing Emerald Summit weapons leave this as 0, so spell_guard_check / implement refund
// pathways naturally become no-ops until weapons are flagged.
/obj/item/rogueweapon
	var/implement_refund = 0
