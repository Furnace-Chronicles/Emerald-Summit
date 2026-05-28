// Iron Tempest — Ferramancy zone-denial AOE projectile. On impact, spawns a 3x3 ring
// of whirling daggers that slashes anyone caught in the ring once per second for 10s.

/datum/action/cooldown/spell/projectile/iron_tempest_magi2
	name = "Iron Tempest"
	desc = "Hurl a blade that detonates into a whirling storm of arcyne daggers on impact. \
		The cloud persists for 10 seconds, slashing anyone who remains in the area. \
		Targets your aimed zone, with reduced accuracy for precise zones. \
		Each strike done every second deals 20 damage."
	button_icon = 'icons/mob/actions/mage_ferramancy.dmi'
	button_icon_state = "iron_tempest"
	sound = 'sound/magic/scrapeblade.ogg'
	spell_color = GLOW_COLOR_METAL
	glow_intensity = GLOW_INTENSITY_MEDIUM
	attunement_school = ASPECT_NAME_FERRAMANCY

	projectile_type = /obj/projectile/magic/iron_tempest_seed_magi2
	cast_range = SPELL_RANGE_PROJECTILE

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_MAJOR_AOE

	invocations = list("Nubem Gladiorum!")
	invocation_type = INVOCATION_SHOUT

	click_to_activate = TRUE
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

	var/tempest_duration = 10 SECONDS
	var/tempest_damage = 20
	var/tempest_radius = 1

/datum/action/cooldown/spell/projectile/iron_tempest_magi2/ready_projectile(obj/projectile/to_fire, atom/target, mob/user, iteration)
	. = ..()
	var/obj/projectile/magic/iron_tempest_seed_magi2/seed = to_fire
	if(istype(seed))
		seed.spell_ref = src

/obj/projectile/magic/iron_tempest_seed_magi2
	name = "arcyne blade"
	icon = 'icons/obj/magic_projectiles.dmi'
	icon_state = "tempest_projectile"
	damage = 0
	nodamage = TRUE
	arcshot = TRUE
	speed = 3
	range = 7
	hitsound = 'sound/combat/hits/bladed/genstab (1).ogg'
	var/datum/action/cooldown/spell/spell_ref

/obj/projectile/magic/iron_tempest_seed_magi2/on_hit(atom/target)
	. = ..()
	var/turf/impact = get_turf(target)
	if(impact)
		new /obj/effect/iron_tempest_magi2(impact, firer, spell_ref)
	qdel(src)
	return BULLET_ACT_HIT

/obj/projectile/magic/iron_tempest_seed_magi2/Range()
	. = ..()
	if(QDELETED(src))
		return
	if(range <= 0)
		var/turf/T = get_turf(src)
		if(T)
			new /obj/effect/iron_tempest_magi2(T, firer, spell_ref)
		qdel(src)

/obj/effect/iron_tempest_magi2
	name = "iron tempest"
	desc = "A whirling storm of arcyne blades!"
	icon = 'icons/effects/effects.dmi'
	icon_state = "sparks"
	anchored = TRUE
	density = FALSE
	layer = ABOVE_MOB_LAYER
	light_outer_range = 2
	light_color = GLOW_COLOR_METAL
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/mob/living/caster
	var/datum/action/cooldown/spell/source_spell
	var/ticks_remaining
	var/tick_damage = 20
	var/effect_radius = 1
	var/list/daggers = list()

/obj/effect/iron_tempest_magi2/Initialize(mapload, mob/living/summoner, datum/action/cooldown/spell/spell_ref)
	. = ..()
	caster = summoner
	source_spell = spell_ref

	var/tempest_duration = 10 SECONDS
	if(istype(spell_ref, /datum/action/cooldown/spell/projectile/iron_tempest_magi2))
		var/datum/action/cooldown/spell/projectile/iron_tempest_magi2/IT = spell_ref
		tempest_duration = IT.tempest_duration
		tick_damage = IT.tempest_damage
		effect_radius = IT.tempest_radius

	ticks_remaining = tempest_duration / (1 SECONDS)

	var/turf/center = get_turf(src)
	for(var/turf/T in range(effect_radius, center))
		if(T == center)
			continue
		var/obj/effect/temp_visual/spinning_dagger_magi2/D = new(center, tempest_duration + 2 SECONDS, FALSE)
		daggers += D
		var/dx = (T.x - center.x) * 32
		var/dy = (T.y - center.y) * 32
		animate(D, pixel_x = dx, pixel_y = dy, time = 3, easing = EASE_OUT)
		addtimer(CALLBACK(D, TYPE_PROC_REF(/obj/effect/temp_visual/spinning_dagger_magi2, start_spinning)), 3)

	playsound(src, 'sound/magic/scrapeblade.ogg', 80, TRUE)
	START_PROCESSING(SSprocessing, src)
	QDEL_IN(src, tempest_duration + 1 SECONDS)

/obj/effect/iron_tempest_magi2/Destroy()
	caster = null
	source_spell = null
	QDEL_LIST(daggers)
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/obj/effect/iron_tempest_magi2/process(delta_time)
	if(ticks_remaining <= 0)
		qdel(src)
		return

	ticks_remaining--
	playsound(src, pick('sound/combat/hits/bladed/genstab (1).ogg', 'sound/combat/hits/bladed/genstab (2).ogg', 'sound/combat/hits/bladed/genstab (3).ogg'), 60, TRUE)

	var/turf/center = get_turf(src)
	for(var/turf/T in range(effect_radius, center))
		if(T == center)
			continue
		for(var/mob/living/L in T.contents)
			if(L.anti_magic_check())
				continue
			if(ishuman(L) && ishuman(caster))
				var/mob/living/carbon/human/HC = caster
				var/target_zone = HC.zone_selected || BODY_ZONE_CHEST
				arcyne_strike(HC, L, null, tick_damage, target_zone, \
					BCLASS_CUT, spell_name = "Iron Tempest", \
					damage_type = BRUTE, npc_simple_damage_mult = 1, \
					skip_animation = TRUE, skip_message = TRUE, \
					allow_shield_check = TRUE)
			else
				L.adjustBruteLoss(tick_damage)
			new /obj/effect/temp_visual/spell_impact(get_turf(L), GLOW_COLOR_METAL, SPELL_IMPACT_MEDIUM)

/obj/effect/temp_visual/spinning_dagger_magi2
	name = "whirling blade"
	icon = 'icons/obj/magic_projectiles.dmi'
	icon_state = "tempest_blade"
	duration = 1 SECONDS
	layer = ABOVE_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	randomdir = FALSE

/obj/effect/temp_visual/spinning_dagger_magi2/Initialize(mapload, custom_duration, start_spin = TRUE)
	if(custom_duration)
		duration = custom_duration
	. = ..()
	if(start_spin)
		SpinAnimation(5, -1, pick(TRUE, FALSE))

/obj/effect/temp_visual/spinning_dagger_magi2/proc/start_spinning()
	SpinAnimation(5, -1, pick(TRUE, FALSE))
