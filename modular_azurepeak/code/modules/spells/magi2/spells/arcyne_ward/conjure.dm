// Conjure Arcyne Ward — universal Magi 2 mage armor.
// Simplified port of Azure-Peak conjure_arcyne_ward.dm:
//  - Single base ward (no dragonhide/crystalhide variants — those are minor-aspect upgrades).
//  - No paired Regenerate Arcyne Ward action (would need its own paired-spell wiring).
//  - Coverage is calculated ONCE at conjure time. Equipment changes after conjure don't
//    auto-update the ward because Emerald Summit lacks the COMSIG_MOB_EQUIPPED_ITEM/DROPITEM
//    signals upstream uses. Player removing armor mid-fight WILL leave gaps; player adding
//    armor mid-fight gets double-coverage on those slots.

#define ARCYNE_WARD_FILTER "arcyne_ward_glow"
#define BASE_ARCYNE_INTEGRITY 225

/datum/action/cooldown/spell/conjure_arcyne_ward_magi2
	name = "Conjure Arcyne Ward"
	desc = "Conjure an invisible arcyne ward that covers your entire body. Cast again to dismiss it. \
		The ward withdraws from areas where you wear real armor at the moment of casting. \
		225 integrity, does not regenerate. Dismissing refunds cooldown proportionally to \
		remaining integrity — full health is no cooldown, broken is full cooldown."
	button_icon = 'icons/mob/actions/roguespells.dmi'
	button_icon_state = "conjure_armor"
	sound = 'sound/magic/whiteflame.ogg'
	spell_color = GLOW_COLOR_ARCANE
	glow_intensity = GLOW_INTENSITY_MEDIUM

	click_to_activate = FALSE // self-cast — no target click needed

	primary_resource_type = SPELL_COST_ENERGY
	primary_resource_cost = 130
	var/upfront_stamina_cost = 70

	invocations = list("Aegis Congrego!")
	invocation_type = INVOCATION_SHOUT

	charge_required = TRUE
	charge_time = 6 SECONDS
	charge_slowdown = 3
	charge_sound = 'sound/magic/charging.ogg'
	cooldown_time = 2 MINUTES

	associated_skill = /datum/skill/magic/arcane
	point_cost = 2
	spell_tier = 2
	spell_impact_intensity = SPELL_IMPACT_NONE
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_SAME_Z

	var/obj/item/clothing/suit/roguetown/armor/arcyne_ward_magi2/conjured_ward
	var/ward_type = /obj/item/clothing/suit/roguetown/armor/arcyne_ward_magi2
	var/dismiss_invocation = "Aegis Dissipo!"

/datum/action/cooldown/spell/conjure_arcyne_ward_magi2/before_cast(atom/cast_on)
	var/dismissing = conjured_ward && !QDELETED(conjured_ward)
	// Dismiss is instant — temporarily zero out the charge so the spell skips do_after
	// and the up-front stamina hit.
	var/saved_charge_time
	var/saved_upfront
	if(dismissing)
		saved_charge_time = charge_time
		charge_time = 0
		saved_upfront = upfront_stamina_cost
		upfront_stamina_cost = 0
	. = ..()
	if(dismissing)
		charge_time = saved_charge_time
		upfront_stamina_cost = saved_upfront
	// We handle the cooldown manually in cast() (proportional refund on dismiss, no
	// cooldown at all on initial conjure because the button stays usable for dismiss).
	. |= SPELL_NO_IMMEDIATE_COOLDOWN
	if(dismissing)
		. |= SPELL_NO_IMMEDIATE_COST | SPELL_NO_FEEDBACK

/datum/action/cooldown/spell/conjure_arcyne_ward_magi2/on_start_charge()
	. = ..()
	// Up-front stamina drain at charge start — taken even if the cast is interrupted.
	if(upfront_stamina_cost > 0 && isliving(owner))
		var/mob/living/L = owner
		var/adjusted = get_adjusted_cost(upfront_stamina_cost)
		if(adjusted > 0)
			L.stamina_add(adjusted)

/datum/action/cooldown/spell/conjure_arcyne_ward_magi2/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE

	// Dismiss path — proportional cooldown refund based on remaining integrity.
	if(conjured_ward && !QDELETED(conjured_ward))
		var/integrity_ratio = conjured_ward.obj_integrity / conjured_ward.max_integrity
		H.say(dismiss_invocation, forced = "spell", language = /datum/language/common)
		to_chat(owner, span_notice("I dismiss my arcyne ward."))
		conjured_ward.dismissed = TRUE
		qdel(conjured_ward)
		var/adjusted_cooldown = get_adjusted_cooldown() * (1 - integrity_ratio)
		StartCooldown(adjusted_cooldown)
		return TRUE

	// The ward lives in its own slot (arcyne_ward_armor), NOT skin_armor — so natural racial armor
	// (harpy/lamia/drider scales) stays in skin_armor and layers underneath. get_best_worn_armor picks
	// the strongest item per zone, so the scales keep their zones and the ward covers everything else.
	// Only block on a lower-tier ward trying to downgrade a stronger existing one.
	if(H.arcyne_ward_armor && !QDELETED(H.arcyne_ward_armor))
		var/obj/item/clothing/suit/roguetown/armor/arcyne_ward_magi2/existing = H.arcyne_ward_armor
		if(existing.arcyne_armor_tier > initial(ward_type:arcyne_armor_tier))
			to_chat(owner, span_warning("A stronger ward already protects me!"))
			return FALSE
		// Replacing the existing ward — dismiss it so cleanup runs.
		existing.dismissed = TRUE
		qdel(existing)

	// Conjure path — wear ward, calculate coverage once.
	owner.visible_message(span_notice("An arcyne ward shimmers into existence around [owner]!"))
	conjured_ward = new ward_type(H)
	H.arcyne_ward_armor = conjured_ward
	conjured_ward.setup_ward(H)
	conjured_ward.linked_spell = src
	// Conjure starts no cooldown — the button stays available so the player can dismiss
	// at will. The ward breaking or being dismissed runs the cooldown logic.
	reset_spell_cooldown()
	return TRUE

/datum/action/cooldown/spell/conjure_arcyne_ward_magi2/Destroy()
	if(conjured_ward && !QDELETED(conjured_ward))
		conjured_ward.visible_message(span_warning("The arcyne ward flickers and fades!"))
		qdel(conjured_ward)
	return ..()

// ---- The ward item ----
// Inherits from /obj/item/clothing/suit/roguetown/armor (skipping Azure-Peak's /manual
// subtype which doesn't exist in ES). The ward is invisible (icon_state = null), sits
// in the H.arcyne_ward_armor slot (separate from skin_armor so racial scales layer under it), and
// dynamically gap-fills around the player's other armor.

/obj/item/clothing/suit/roguetown/armor/arcyne_ward_magi2
	name = "arcyne ward"
	desc = "An invisible barrier of arcyne energy protecting the wearer."
	icon_state = null
	slot_flags = ITEM_SLOT_SHIRT|ITEM_SLOT_ARMOR
	break_sound = 'sound/magic/magic_nulled.ogg'

	body_parts_covered = COVERAGE_FULL_BODY_ACTUAL
	body_parts_inherent = COVERAGE_FULL_BODY_ACTUAL
	armor_class = ARMOR_CLASS_LIGHT
	armor = ARMOR_LEATHER
	max_integrity = BASE_ARCYNE_INTEGRITY

	blocksound = SOFTHIT

	var/datum/action/cooldown/spell/conjure_arcyne_ward_magi2/linked_spell
	var/mob/living/carbon/human/ward_owner
	var/dismissed = FALSE
	/// Used by the conjure spell's cast() to gate downgrades. Base ward = BASE; the
	/// Autowardry upgrades override to GREATER.
	var/arcyne_armor_tier = ARCYNE_WARD_TIER_BASE
	/// Examine phrase shown on the wearer (see /mob/living/carbon/human/examine in bestow_ward.dm).
	/// Upgrade wards override this to describe their distinct appearance.
	var/ward_examine_phrase = "wrapped in a shimmering arcyne ward"

/obj/item/clothing/suit/roguetown/armor/arcyne_ward_magi2/Initialize(mapload)
	. = ..()
	// Make the ward un-droppable while it's the player's skin armor.
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT)

/obj/item/clothing/suit/roguetown/armor/arcyne_ward_magi2/proc/setup_ward(mob/living/carbon/human/H)
	ward_owner = H
	recalculate_coverage()

/// One-shot coverage calc: the ward covers every body slot the player isn't already
/// wearing armor in. Upstream re-runs this on each equip/drop signal; we run it once
/// at conjure time only (signal hookup not present in Emerald Summit).
/obj/item/clothing/suit/roguetown/armor/arcyne_ward_magi2/proc/recalculate_coverage()
	if(QDELETED(src) || !ward_owner)
		return
	var/new_coverage = COVERAGE_FULL_BODY_ACTUAL
	var/mob/living/carbon/human/H = ward_owner

	if(has_real_armor(H.head))
		new_coverage &= ~(HEAD | HAIR | EARS)
	if(has_real_armor(H.wear_mask))
		new_coverage &= ~(NOSE | MOUTH)
	if(has_real_armor(H.wear_shirt) && has_real_armor(H.wear_armor))
		new_coverage &= ~(CHEST | GROIN | VITALS)
	if(has_real_armor(H.wear_armor, ARM_LEFT | ARM_RIGHT) || has_real_armor(H.wear_shirt, ARM_LEFT | ARM_RIGHT))
		new_coverage &= ~(ARM_LEFT | ARM_RIGHT)
	if(has_real_armor(H.gloves))
		new_coverage &= ~(HAND_LEFT | HAND_RIGHT)
	if(has_real_armor(H.wear_pants))
		new_coverage &= ~(LEG_LEFT | LEG_RIGHT)
	if(has_real_armor(H.shoes))
		new_coverage &= ~(FOOT_LEFT | FOOT_RIGHT)

	body_parts_covered_dynamic = new_coverage

/obj/item/clothing/suit/roguetown/armor/arcyne_ward_magi2/proc/has_real_armor(obj/item/clothing/C, coverage_check)
	if(!C || !istype(C))
		return FALSE
	if(C.armor_class <= ARMOR_CLASS_NONE)
		return FALSE
	if(coverage_check)
		return (C.body_parts_covered_dynamic & coverage_check)
	return TRUE

/obj/item/clothing/suit/roguetown/armor/arcyne_ward_magi2/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armor_penetration)
	if(ward_owner && damage_amount > 0)
		var/turf/T = get_turf(ward_owner)
		new /obj/effect/temp_visual/spell_impact(T, GLOW_COLOR_ARCANE, SPELL_IMPACT_LOW)
		playsound(T, 'sound/magic/clang.ogg', 50, TRUE)
		flash_ward()
		if(prob(50))
			do_sparks(2, FALSE, T)
	. = ..()

/obj/item/clothing/suit/roguetown/armor/arcyne_ward_magi2/proc/flash_ward()
	if(!ward_owner)
		return
	ward_owner.remove_filter(ARCYNE_WARD_FILTER)
	ward_owner.add_filter(ARCYNE_WARD_FILTER, 2, list("type" = "outline", "color" = GLOW_COLOR_ARCANE, "alpha" = 80, "size" = 1))
	addtimer(CALLBACK(src, PROC_REF(clear_flash)), 3)

/obj/item/clothing/suit/roguetown/armor/arcyne_ward_magi2/proc/clear_flash()
	if(ward_owner)
		ward_owner.remove_filter(ARCYNE_WARD_FILTER)

/obj/item/clothing/suit/roguetown/armor/arcyne_ward_magi2/dropped(mob/user, silent)
	..()
	cleanup_ward()

/obj/item/clothing/suit/roguetown/armor/arcyne_ward_magi2/Destroy()
	cleanup_ward()
	return ..()

/obj/item/clothing/suit/roguetown/armor/arcyne_ward_magi2/proc/cleanup_ward()
	if(ward_owner)
		ward_owner.remove_filter(ARCYNE_WARD_FILTER)
		if(ward_owner.arcyne_ward_armor == src)
			ward_owner.arcyne_ward_armor = null
		ward_owner = null
	if(linked_spell)
		// Break (not dismiss) = full cooldown; dismiss handles its own proportional refund.
		if(!QDELETED(linked_spell) && !dismissed)
			linked_spell.StartCooldown(linked_spell.get_adjusted_cooldown())
		linked_spell.conjured_ward = null
		linked_spell = null

#undef ARCYNE_WARD_FILTER
#undef BASE_ARCYNE_INTEGRITY
