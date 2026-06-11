// Battle Ward — Battlewardry rune AOE. Inscribes 5 rune wards in an X pattern.
// Wards are fragile (50 integrity) and indiscriminate — they hit allies and the caster too.
// Use Alt-Mode (Ctrl+G default) to cycle through Stun/Fire/Chill/Damage.

#define BATTLE_WARD_RUNE_DURATION_MAGI2 (1 MINUTES)
#define BATTLE_WARD_TELEGRAPH_TIME_MAGI2 (3 SECONDS)

/datum/action/cooldown/spell/battle_ward_magi2
	name = "Battle Ward"
	desc = "Channel arcyne energy to inscribe a pattern of five rune wards in an X formation. \
		The runes are fragile and last one minute. Battle Wards are indiscriminate — they will \
		hit my allies and myself. Use Alt-Mode to cycle between Stun, Fire, Chill, and Damage."
	button_icon = 'icons/mob/actions/mage_battlewardry.dmi'
	button_icon_state = "battle_ward"
	sound = 'sound/magic/charging.ogg'
	spell_color = GLOW_COLOR_WARD
	glow_intensity = GLOW_INTENSITY_MEDIUM
	attunement_school = ASPECT_NAME_BATTLEWARDRY

	click_to_activate = TRUE
	cast_range = SPELL_RANGE_GROUND
	self_cast_possible = FALSE

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_MAJOR_AOE

	invocations = list("Bellitutela Inscriptum!")
	invocation_type = INVOCATION_SHOUT

	charge_required = TRUE
	charge_time = CHARGETIME_HEAVY
	charge_drain = 1
	charge_slowdown = CHARGING_SLOWDOWN_HEAVY
	charge_sound = 'sound/magic/charging.ogg'
	cooldown_time = 20 SECONDS

	associated_skill = /datum/skill/magic/arcane
	spell_tier = 2
	spell_impact_intensity = SPELL_IMPACT_NONE
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_SAME_Z

	var/ward_mode = RUNE_WARD_STUN
	var/static/list/ward_modes = list(RUNE_WARD_STUN, RUNE_WARD_FIRE, RUNE_WARD_CHILL, RUNE_WARD_DAMAGE)
	var/static/list/ward_mode_labels = list(
		RUNE_WARD_STUN   = "STUN",
		RUNE_WARD_FIRE   = "FIRE",
		RUNE_WARD_CHILL  = "CHILL",
		RUNE_WARD_DAMAGE = "DMG",
	)

/datum/action/cooldown/spell/battle_ward_magi2/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE
	var/turf/center = get_turf(cast_on)
	if(!center)
		return FALSE

	var/rune_path = get_rune_path()
	if(!rune_path)
		return FALSE

	var/list/target_turfs = list(
		center,
		get_step(center, NORTHWEST),
		get_step(center, NORTHEAST),
		get_step(center, SOUTHWEST),
		get_step(center, SOUTHEAST),
	)

	for(var/turf/T in target_turfs)
		new /obj/effect/temp_visual/trap_wall_magi2(T)

	playsound(center, 'sound/magic/whiteflame.ogg', 60, TRUE)
	H.visible_message(
		span_warning("[H] completes a complex inscription — runes begin to materialize!"),
		span_notice("I finish inscribing the [ward_mode_labels[ward_mode]] ward pattern."),
	)
	addtimer(CALLBACK(src, PROC_REF(spawn_runes), target_turfs, rune_path, H.real_name, H.ckey || "no ckey", WEAKREF(H)), BATTLE_WARD_TELEGRAPH_TIME_MAGI2)
	return TRUE

/datum/action/cooldown/spell/battle_ward_magi2/proc/spawn_runes(list/turfs, rune_path, caster_name, caster_ckey, datum/weakref/caster_ref)
	for(var/turf/T in turfs)
		var/obj/structure/rune_ward_magi2/rune = new rune_path(T)
		rune.owner_name = caster_name
		rune.owner_ckey = caster_ckey
		rune.owner_ref = caster_ref
		rune.max_integrity = 50
		rune.obj_integrity = 50
		QDEL_IN(rune, BATTLE_WARD_RUNE_DURATION_MAGI2)

/datum/action/cooldown/spell/battle_ward_magi2/proc/get_rune_path()
	switch(ward_mode)
		if(RUNE_WARD_STUN)
			return /obj/structure/rune_ward_magi2/stun
		if(RUNE_WARD_FIRE)
			return /obj/structure/rune_ward_magi2/fire
		if(RUNE_WARD_CHILL)
			return /obj/structure/rune_ward_magi2/chill
		if(RUNE_WARD_DAMAGE)
			return /obj/structure/rune_ward_magi2/damage
	return null

/datum/action/cooldown/spell/battle_ward_magi2/toggle_alt_mode(mob/user)
	var/idx = ward_modes.Find(ward_mode)
	idx = (idx % length(ward_modes)) + 1
	ward_mode = ward_modes[idx]
	var/label = ward_mode_labels[ward_mode]
	user.balloon_alert(user, "[name]: [label]")
	to_chat(user, span_notice("Ward mode set to [label]."))
	return TRUE

#undef BATTLE_WARD_RUNE_DURATION_MAGI2
#undef BATTLE_WARD_TELEGRAPH_TIME_MAGI2
