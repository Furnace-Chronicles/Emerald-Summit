// Gravity — Kinesis single-target knockdown. STR-resisted, 15s adaptation immunity per target.
// Reuses existing ES /obj/effect/temp_visual/gravity and /gravity_trap.

/datum/action/cooldown/spell/gravity_magi2
	name = "Gravity"
	desc = "Weighten space around someone, crushing them and knocking them to the floor. \
		Stronger opponents will resist and be off-balanced. \
		Targets adapt for 15 seconds after being struck — consecutive hits within that window do damage but no CC."
	button_icon = 'icons/mob/actions/mage_kinesis.dmi'
	button_icon_state = "gravity"
	sound = 'sound/magic/gravity.ogg'
	spell_color = GLOW_COLOR_KINESIS
	glow_intensity = GLOW_INTENSITY_MEDIUM
	attunement_school = ASPECT_NAME_KINESIS

	click_to_activate = TRUE
	cast_range = SPELL_RANGE_GROUND

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_SINGLE_CC

	invocations = list("Pondus!")
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
	displayed_damage = 60
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_SAME_Z

	var/telegraph_delay = TELEGRAPH_SKILLSHOT
	var/crush_damage = 60
	var/resisted_damage = 15
	var/knockdown_time = 5
	var/offbalance_time = 10
	var/str_threshold = 15
	var/npc_damage_mult = 2

/datum/action/cooldown/spell/gravity_magi2/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE
	var/turf/T = get_turf(cast_on)
	if(!T)
		return FALSE

	var/turf/source_turf = get_turf(H)
	if(!(T in get_hear(cast_range, source_turf)))
		to_chat(H, span_warning("I can't cast where I can't see!"))
		return FALSE

	new /obj/effect/temp_visual/gravity_trap(T)
	playsound(T, 'sound/magic/gravity.ogg', 80, TRUE, soundping = FALSE)
	addtimer(CALLBACK(src, PROC_REF(gravity_crush), T), telegraph_delay)
	return TRUE

/datum/action/cooldown/spell/gravity_magi2/proc/gravity_crush(turf/T)
	new /obj/effect/temp_visual/gravity(T)
	for(var/mob/living/L in T.contents)
		if(L.anti_magic_check())
			L.visible_message(span_warning("The gravity fades away around [L]!"))
			playsound(get_turf(L), 'sound/magic/magic_nulled.ogg', 100)
			continue
		var/target_zone = pick(BODY_ZONE_HEAD, BODY_ZONE_CHEST)
		var/adapted = L.mob_timers[MT_GRAVITY_ADAPTATION] && world.time < L.mob_timers[MT_GRAVITY_ADAPTATION] + GRAVITY_ADAPTATION_COOLDOWN
		if(adapted)
			var/remaining = round((L.mob_timers[MT_GRAVITY_ADAPTATION] + GRAVITY_ADAPTATION_COOLDOWN - world.time) / 10)
			L.balloon_alert_to_viewers("<font color='#7B68EE'>gravity adapted ([remaining]s)!</font>")
		if(L.STASTR <= str_threshold)
			arcyne_strike(owner, L, null, crush_damage, target_zone, BCLASS_BLUNT, \
				spell_name = "Gravity", damage_type = BRUTE, \
				npc_simple_damage_mult = npc_damage_mult, skip_animation = TRUE)
			if(!adapted)
				L.Knockdown(knockdown_time)
				L.mob_timers[MT_GRAVITY_ADAPTATION] = world.time
				to_chat(L, span_userdanger("I'm magically weighed down, losing my footing!"))
			else
				to_chat(L, span_userdanger("The gravity crushes me, but I keep my footing!"))
		else
			arcyne_strike(owner, L, null, resisted_damage, target_zone, BCLASS_BLUNT, \
				spell_name = "Gravity", damage_type = BRUTE, \
				npc_simple_damage_mult = npc_damage_mult, skip_animation = TRUE)
			if(!adapted)
				L.OffBalance(offbalance_time)
				L.mob_timers[MT_GRAVITY_ADAPTATION] = world.time
				to_chat(L, span_userdanger("I'm magically weighed down, but my strength resists!"))
			else
				to_chat(L, span_userdanger("The gravity crushes me, but I keep my footing!"))
		new /obj/effect/temp_visual/spell_impact(get_turf(L), spell_color, spell_impact_intensity)
