// Regenerating armour — ported from Ratwood-2.0 PR #1133.
//
// Upstream uses recursive addtimer() callbacks; this port uses SSobj processing to match
// the local trollslayer/slayer-skin pattern. Same end behavior: take damage, wait
// `repair_time` without taking more damage, then tick integrity back up by `repair_amount`
// every `repair_time` until full.

/obj/item/clothing/suit/roguetown/armor/regenerating
	name = "regenerating armour"
	desc = "Abstract parent. Contact developer if you see this."
	icon_state = null
	slot_flags = ITEM_SLOT_SHIRT|ITEM_SLOT_ARMOR

	var/repairmsg_begin = "My armour begins to slowly mend its abuse.."
	var/repairmsg_continue = "My armour mends some of its abuse.."
	var/repairmsg_stop = "My armour stops mending from the onslaught!"
	var/repairmsg_end = "My armour has become taut with newfound vigor!"

	/// Seconds of no damage required before regen ticks resume.
	var/repair_time = 14 SECONDS
	/// Integrity restored per regen tick. If null at Initialize, auto-calculated as 20% of max_integrity.
	var/repair_amount = null
	/// world.time of the most recent damage applied.
	var/last_damage_time = 0
	/// TRUE between "begin" and "end" messages — gates which message fires each tick.
	var/is_regenerating = FALSE
	/// Post-armor damage below this threshold is ignored for the regen timer
	/// (integrity still ticks down, but `last_damage_time` is not bumped and
	/// any in-flight mend is not interrupted). 0 = preserve original behavior.
	var/min_damage_to_reset = 0

/obj/item/clothing/suit/roguetown/armor/regenerating/Initialize(mapload)
	. = ..()
	if(isnull(repair_amount))
		repair_amount = round(max_integrity * 0.2)

/obj/item/clothing/suit/roguetown/armor/regenerating/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armor_penetration)
	. = ..()
	if(!damage_amount)
		return
	if(obj_integrity < max_integrity)
		START_PROCESSING(SSobj, src)
	// Sub-threshold damage (thorns, scrapes) still ticks integrity down but
	// does NOT reset the regen timer or interrupt an in-flight mend. `.` is
	// the post-armor damage from the parent; when armor is broken our
	// obj_break zeroes the datum so `.` equals raw input, matching the
	// "no armor → use raw incoming" intent.
	if(min_damage_to_reset > 0 && . < min_damage_to_reset)
		return
	last_damage_time = world.time
	if(is_regenerating && ismob(loc))
		to_chat(loc, span_notice(repairmsg_stop))
	is_regenerating = FALSE

/obj/item/clothing/suit/roguetown/armor/regenerating/get_inspect_durability_extra()
	if(obj_integrity >= max_integrity)
		return null
	var/time_left = (last_damage_time + repair_time) - world.time
	if(time_left <= 0)
		return "\n<b>REGENERATING</b>"
	return "\n<b>REGENERATES IN:</b> [round(time_left / 10)]s"

/obj/item/clothing/suit/roguetown/armor/regenerating/process()
	if(obj_integrity >= max_integrity)
		if(is_regenerating && ismob(loc))
			to_chat(loc, span_notice(repairmsg_end))
		is_regenerating = FALSE
		STOP_PROCESSING(SSobj, src)
		return
	if(world.time < last_damage_time + repair_time)
		return
	if(!is_regenerating)
		is_regenerating = TRUE
		if(ismob(loc))
			to_chat(loc, span_notice(repairmsg_begin))
	else if(ismob(loc))
		to_chat(loc, span_notice(repairmsg_continue))
	obj_integrity = min(obj_integrity + repair_amount, max_integrity)
	if(obj_broken)
		obj_fix()

// Skin variant — force-bound to wearer, qdel on drop.

/obj/item/clothing/suit/roguetown/armor/regenerating/skin
	name = "regenerating skin"
	break_sound = 'sound/foley/cloth_rip.ogg'
	drop_sound = 'sound/foley/dropsound/cloth_drop.ogg'
	resistance_flags = FIRE_PROOF
	body_parts_covered = COVERAGE_FULL
	body_parts_inherent = COVERAGE_FULL
	repairmsg_begin = "My skin begins to slowly mend its abuse.."
	repairmsg_continue = "My skin mends some of its abuse.."
	repairmsg_stop = "My skin stops mending from the onslaught!"
	repairmsg_end = "My skin has become taut with newfound vigor!"

/obj/item/clothing/suit/roguetown/armor/regenerating/skin/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT)

/obj/item/clothing/suit/roguetown/armor/regenerating/skin/dropped(mob/living/carbon/human/user)
	. = ..()
	if(QDELETED(src))
		return
	qdel(src)
