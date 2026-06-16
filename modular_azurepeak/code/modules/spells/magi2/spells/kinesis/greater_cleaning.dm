// Greater Cleaning — Kinesis utility cantrip. AOE scrubs grime and decals in a 3x3 zone.

/datum/action/cooldown/spell/greater_cleaning_magi2
	name = "Greater Cleaning"
	desc = "Unleash a wave of kinetic force that scours a nearby area clean of grime and debris."
	button_icon = 'icons/mob/actions/mage_kinesis.dmi'
	button_icon_state = "greater_cleaning"
	sound = 'sound/magic/whiteflame.ogg'
	spell_color = GLOW_COLOR_KINESIS
	glow_intensity = GLOW_INTENSITY_LOW

	click_to_activate = TRUE
	cast_range = 7

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_CANTRIP

	invocations = list("Purga Omnia.")
	invocation_type = INVOCATION_SHOUT

	charge_required = TRUE
	weapon_cast_penalized = FALSE
	charge_time = CHARGETIME_POKE
	cooldown_time = 10 SECONDS

	associated_skill = /datum/skill/magic/arcane
	spell_tier = 1
	spell_impact_intensity = SPELL_IMPACT_NONE
	point_cost = 1
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_SAME_Z

/datum/action/cooldown/spell/greater_cleaning_magi2/cast(atom/cast_on)
	. = ..()
	var/turf/target_turf = get_turf(cast_on)
	if(!target_turf)
		return FALSE

	owner.visible_message(
		span_notice("[owner] gestures forcefully. A wave of arcyne force ripples outward, scouring the area clean."),
		span_notice("I unleash a wave of kinetic force, purging the area of filth."),
	)

	var/washed = 0
	var/max_washes = 75
	for(var/turf/T in range(1, target_turf))
		if(washed >= max_washes)
			break
		new /obj/effect/temp_visual/cleaning_pulse_magi2(T)
		wash_atom(T, CLEAN_MEDIUM)
		washed++
		for(var/atom/A in T)
			if(washed >= max_washes)
				break
			if(istype(A, /obj/effect/decal/cleanable) || ismob(A) || (isobj(A) && !istype(A, /obj/effect)))
				wash_atom(A, CLEAN_MEDIUM)
				washed++
	return TRUE

/obj/effect/temp_visual/cleaning_pulse_magi2
	name = "cleaning pulse"
	icon = 'icons/effects/wizard_spell_effects.dmi'
	icon_state = "cleaning_pulse"
	duration = 8
	randomdir = FALSE
