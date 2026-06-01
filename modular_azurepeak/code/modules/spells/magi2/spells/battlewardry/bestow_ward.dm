// Bestow Ward — Battlewardry buff. Wraps an ally in an arcyne ward equivalent to the
// caster's Conjure Arcyne Ward but at a lower tier and with a fixed duration. Will not
// overwrite a stronger existing ward or any non-arcyne skin armor.

/datum/action/cooldown/spell/bestow_ward_magi2
	name = "Bestow Ward"
	desc = "Channel arcyne energy to wrap an ally in a protective ward. The ward covers their entire \
		body with light armor, yielding coverage to any real armor they wear. Lasts 2.5 minutes or until destroyed."
	button_icon = 'icons/mob/actions/mage_battlewardry.dmi'
	button_icon_state = "bestow_ward"
	sound = 'sound/magic/whiteflame.ogg'
	spell_color = GLOW_COLOR_WARD
	glow_intensity = GLOW_INTENSITY_MEDIUM
	attunement_school = ASPECT_NAME_BATTLEWARDRY

	click_to_activate = TRUE
	cast_range = 3
	self_cast_possible = FALSE

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_UTILITY_BUFF

	invocations = list("Aegis Impono!")
	invocation_type = INVOCATION_SHOUT

	charge_required = TRUE
	charge_time = CHARGETIME_HEAVY
	charge_drain = 1
	charge_slowdown = CHARGING_SLOWDOWN_MEDIUM
	charge_sound = 'sound/magic/charging.ogg'
	cooldown_time = 1.5 MINUTES

	associated_skill = /datum/skill/magic/arcane
	spell_tier = 2
	spell_impact_intensity = SPELL_IMPACT_NONE
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_SAME_Z

	var/ward_type = /obj/item/clothing/suit/roguetown/armor/arcyne_ward_magi2/bestowed
	var/ward_duration = 2.5 MINUTES

/datum/action/cooldown/spell/bestow_ward_magi2/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/caster = owner
	if(!istype(caster))
		return FALSE
	if(!ishuman(cast_on))
		to_chat(caster, span_warning("I can only bestow a ward upon a person."))
		return FALSE

	var/mob/living/carbon/human/target = cast_on
	if(target == caster)
		to_chat(caster, span_warning("I cannot bestow a ward upon myself."))
		return FALSE

	var/refreshing = FALSE
	if(target.skin_armor)
		if(!istype(target.skin_armor, /obj/item/clothing/suit/roguetown/armor/arcyne_ward_magi2))
			to_chat(caster, span_warning("[target] is already protected by something beyond my power to overcome."))
			return FALSE
		var/obj/item/clothing/suit/roguetown/armor/arcyne_ward_magi2/existing = target.skin_armor
		if(existing.arcyne_armor_tier > ARCYNE_WARD_TIER_OTHER)
			to_chat(caster, span_warning("[target] already bears a ward of greater strength."))
			return FALSE
		refreshing = TRUE
		qdel(existing)

	var/obj/item/clothing/suit/roguetown/armor/arcyne_ward_magi2/bestowed/ward = new ward_type(target)
	target.skin_armor = ward
	ward.setup_ward(target)
	ward.set_duration(ward_duration)

	if(refreshing)
		target.visible_message(span_notice("[target]'s arcyne ward shimmers brightly as it is renewed!"))
		to_chat(caster, span_notice("I refresh [target]'s ward."))
	else
		target.visible_message(span_notice("An arcyne ward shimmers into existence around [target]!"))
		to_chat(caster, span_notice("I bestow an arcyne ward upon [target]."))
	return TRUE

/obj/item/clothing/suit/roguetown/armor/arcyne_ward_magi2/bestowed
	name = "bestowed ward"
	desc = "An arcyne ward placed by another mage. It cannot be dismissed — it must be weathered or destroyed."
	max_integrity = 200
	arcyne_armor_tier = ARCYNE_WARD_TIER_OTHER

	var/duration_timer

/obj/item/clothing/suit/roguetown/armor/arcyne_ward_magi2/bestowed/proc/set_duration(duration)
	if(duration_timer)
		deltimer(duration_timer)
	duration_timer = QDEL_IN(src, duration)

/obj/item/clothing/suit/roguetown/armor/arcyne_ward_magi2/bestowed/Destroy()
	if(duration_timer)
		deltimer(duration_timer)
		duration_timer = null
	return ..()

/obj/item/clothing/suit/roguetown/armor/arcyne_ward_magi2/bestowed/obj_destruction(damage_flag)
	if(ward_owner)
		ward_owner.visible_message(span_warning("[ward_owner]'s arcyne ward shatters!"))
		playsound(get_turf(ward_owner), break_sound, 80, TRUE)
	qdel(src)

/obj/item/clothing/suit/roguetown/armor/arcyne_ward_magi2/bestowed/setup_ward(mob/living/carbon/human/H)
	. = ..()
	H.add_filter("bestowed_ward_glow_magi2", 2, list("type" = "outline", "color" = GLOW_COLOR_WARD, "alpha" = 150, "size" = 2))
	H.apply_status_effect(/datum/status_effect/buff/bestowed_ward_magi2)

/obj/item/clothing/suit/roguetown/armor/arcyne_ward_magi2/bestowed/cleanup_ward()
	if(ward_owner)
		ward_owner.remove_filter("bestowed_ward_glow_magi2")
		ward_owner.remove_status_effect(/datum/status_effect/buff/bestowed_ward_magi2)
	return ..()

// Append a ward readout to the wearer's examine output. Applies to every Magi 2
// arcyne ward variant (self-conjured base / Dragonhide / Crystalhide / Bestowed).
// Action-button integrity is only visible to the caster; this examine line is how
// other players (and the wearer on self-examine) see the damage state. Damage tier
// reuses the standard /obj/item/clothing/integrity_check() flavor strings.
/mob/living/carbon/human/examine(mob/user)
	. = ..()
	var/obj/item/clothing/suit/roguetown/armor/arcyne_ward_magi2/ward = skin_armor
	if(istype(ward))
		. += span_info("[user == src ? "I am" : "[p_they(TRUE)] [p_are()]"] [ward.ward_examine_phrase].")
		var/intcheck = ward.integrity_check()
		if(intcheck)
			. += intcheck

// ============================================================================
// Status effect — gives the recipient a visible buff icon for the ward's lifetime.
// ============================================================================

/datum/status_effect/buff/bestowed_ward_magi2
	id = "bestowed_ward_magi2"
	alert_type = /atom/movable/screen/alert/status_effect/buff/bestowed_ward_magi2
	// Indefinite — removed by the ward's cleanup_ward() when the ward expires or shatters.
	duration = -1

/atom/movable/screen/alert/status_effect/buff/bestowed_ward_magi2
	name = "Bestowed Ward"
	desc = "An arcyne ward shimmers around me, absorbing harm."
	icon = 'icons/mob/actions/mage_battlewardry.dmi'
	icon_state = "bestow_ward"
