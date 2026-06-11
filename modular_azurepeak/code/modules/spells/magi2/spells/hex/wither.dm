// Wither — Hex minor aspect spell, port of Azure-Peak wither.dm.
// MVP config: click_to_activate FALSE — line goes from caster toward facing direction.
// (Upstream click_to_activate TRUE — same deferred click-intercept story as Pyromancy.)
// Reuses existing /datum/status_effect/buff/witherd from Emerald Summit's spells_status_effects.dm.
// Suffix _magi2 on spell type and visuals to avoid collision with the existing proc_holder Wither
// (/obj/effect/proc_holder/spell/invoked/projectile/wither and /obj/effect/temp_visual/trap/wither).

/datum/action/cooldown/spell/wither_magi2
	name = "Wither"
	desc = "Lash out a delayed line of dark magic, sapping the physical prowess of all in its path. \
		The line telegraphs for a moment before striking every tile at once."
	button_icon = 'icons/mob/actions/mage_hex.dmi'
	button_icon_state = "wither"
	sound = 'sound/magic/shadowstep_destination.ogg'
	spell_color = GLOW_COLOR_HEX
	glow_intensity = GLOW_INTENSITY_MEDIUM

	click_to_activate = TRUE
	cast_range = SPELL_RANGE_GROUND

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_MAJOR_AOE

	invocations = list("Arescentem!")
	invocation_type = INVOCATION_SHOUT

	charge_required = TRUE
	weapon_cast_penalized = TRUE
	charge_time = CHARGETIME_MAJOR
	charge_drain = 1
	charge_slowdown = CHARGING_SLOWDOWN_MEDIUM
	charge_sound = 'sound/magic/charging.ogg'
	cooldown_time = 20 SECONDS

	associated_skill = /datum/skill/magic/arcane
	spell_tier = 2
	spell_impact_intensity = SPELL_IMPACT_MEDIUM
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_SAME_Z

	/// Ticks of telegraph before the line strikes.
	var/strike_delay = TELEGRAPH_SKILLSHOT

/datum/action/cooldown/spell/wither_magi2/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE

	var/turf/target_turf
	if(click_to_activate)
		target_turf = get_turf(cast_on)
	else
		target_turf = get_ranged_target_turf(H, H.dir, cast_range)
	if(!target_turf)
		return FALSE

	var/turf/source_turf = get_turf(H)
	if(!(target_turf in get_hear(cast_range, source_turf)))
		to_chat(H, span_warning("I can't cast where I can't see!"))
		return FALSE

	var/list/affected_turfs = list()
	for(var/turf/line_turf in getline(source_turf, target_turf))
		if(line_turf == source_turf)
			continue
		if(!(line_turf in get_hear(cast_range, source_turf)))
			continue
		affected_turfs += line_turf
		new /obj/effect/temp_visual/trap/wither_line_magi2(line_turf, strike_delay)

	if(!length(affected_turfs))
		return FALSE

	addtimer(CALLBACK(src, PROC_REF(strike_line), affected_turfs), strike_delay)
	return TRUE

/datum/action/cooldown/spell/wither_magi2/proc/strike_line(list/turfs)
	for(var/turf/damage_turf as anything in turfs)
		new /obj/effect/temp_visual/wither_strike_magi2(damage_turf)
		playsound(damage_turf, 'sound/magic/shadowstep_destination.ogg', 50)
		for(var/mob/living/L in damage_turf.contents)
			if(L.anti_magic_check())
				L.visible_message(span_warning("The dark magic fades away around [L]!"))
				playsound(damage_turf, 'sound/magic/magic_nulled.ogg', 100)
				continue
			L.apply_status_effect(/datum/status_effect/buff/witherd)

/obj/effect/temp_visual/trap/wither_line_magi2
	icon = 'icons/effects/effects.dmi'
	icon_state = "curse"
	color = GLOW_COLOR_HEX
	light_outer_range = 0
	duration = 1 SECONDS
	layer = MASSIVE_OBJ_LAYER
	alpha = 70

/obj/effect/temp_visual/trap/wither_line_magi2/Initialize(mapload, duration_override)
	if(duration_override)
		duration = duration_override
	. = ..()

/obj/effect/temp_visual/wither_strike_magi2
	icon = 'icons/effects/effects.dmi'
	icon_state = "curseblob"
	light_outer_range = 2
	light_color = GLOW_COLOR_HEX
	duration = 1 SECONDS
	layer = MASSIVE_OBJ_LAYER
