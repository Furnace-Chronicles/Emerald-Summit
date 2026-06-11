// Sawblade Volley — Ferramancy spread, 3 piercing sawblades. Per-blade DR within a volley.

#define MT_SAWBLADE_MAGI2 "sawblade_magi2"
#define SAWBLADE_HIT_IMMUNITY_MAGI2 (1 SECONDS)

/datum/action/cooldown/spell/projectile/sawblade_volley_magi2
	name = "Sawblade Volley"
	desc = "Launch a volley of three spinning arcyne sawblades in a spread. \
		Each blade shreds through up to 3 targets before dissipating. The blades stop on solid walls. \
		Targets already struck by another sawblade in the same volley take no damage."
	button_icon = 'icons/mob/actions/mage_ferramancy.dmi'
	button_icon_state = "sawblade_volley"
	sound = 'sound/magic/blade_burst.ogg'
	spell_color = GLOW_COLOR_METAL
	glow_intensity = GLOW_INTENSITY_MEDIUM
	attunement_school = ASPECT_NAME_FERRAMANCY

	projectile_type = /obj/projectile/magic/sawblade_magi2
	cast_range = SPELL_RANGE_PROJECTILE
	projectiles_per_fire = 3

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_MAJOR_PROJECTILE

	invocations = list("Serra Ferri!")
	invocation_type = INVOCATION_SHOUT

	click_to_activate = TRUE
	charge_required = TRUE
	weapon_cast_penalized = TRUE
	charge_time = CHARGETIME_POKE
	charge_drain = 1
	charge_slowdown = CHARGING_SLOWDOWN_SMALL
	charge_sound = 'sound/magic/charging.ogg'
	cooldown_time = 15 SECONDS

	associated_skill = /datum/skill/magic/arcane
	spell_tier = 2
	spell_impact_intensity = SPELL_IMPACT_MEDIUM
	displayed_damage = 60

	var/spread_step = 8

/datum/action/cooldown/spell/projectile/sawblade_volley_magi2/ready_projectile(obj/projectile/to_fire, atom/target, mob/user, iteration)
	. = ..()
	var/base_angle = to_fire.Angle
	if(isnull(base_angle))
		base_angle = Get_Angle(user, target)
	var/center_index = (projectiles_per_fire + 1) / 2
	to_fire.Angle = base_angle + ((iteration - center_index) * spread_step)

/obj/projectile/magic/sawblade_magi2
	name = "arcyne sawblade"
	icon = 'icons/effects/wizard_spell_effects.dmi'
	icon_state = "grassblade"
	damage = 60
	damage_type = BRUTE
	woundclass = BCLASS_CUT
	flag = "slash"
	npc_damage_mult = 1.5
	nodamage = FALSE
	speed = MAGE_PROJ_MEDIUM
	movement_type = UNSTOPPABLE
	range = SPELL_RANGE_PROJECTILE
	hitsound = 'sound/combat/newstuck.ogg'
	var/hits = 0
	var/max_hits = 3

/obj/projectile/magic/sawblade_magi2/on_hit(target)
	if(ismob(target))
		var/mob/living/M = target
		if(M.anti_magic_check())
			visible_message(span_warning("[src] shatters on contact with [target]!"))
			playsound(get_turf(target), 'sound/magic/magic_nulled.ogg', 100)
			qdel(src)
			return BULLET_ACT_BLOCK
		if(M.mob_timers[MT_SAWBLADE_MAGI2] && world.time < M.mob_timers[MT_SAWBLADE_MAGI2] + SAWBLADE_HIT_IMMUNITY_MAGI2)
			qdel(src)
			return BULLET_ACT_BLOCK
		M.mob_timers[MT_SAWBLADE_MAGI2] = world.time
		playsound(get_turf(target), hitsound, 80, TRUE)
	. = ..()
	if(!ismob(target))
		qdel(src)
		return . || BULLET_ACT_HIT
	hits++
	if(hits >= max_hits)
		qdel(src)
		return . || BULLET_ACT_HIT
	return BULLET_ACT_FORCE_PIERCE

#undef MT_SAWBLADE_MAGI2
#undef SAWBLADE_HIT_IMMUNITY_MAGI2
