// Soulshot — Kinesis major piercing beam. Hitscan, pierces up to 4 mobs, halved damage after first.

/datum/action/cooldown/spell/projectile/soulshot_magi2
	name = "Soulshot"
	desc = "Fire a devastating beam of kinetic force that pierces through up to 4 targets. Stopped by solid objects. \
		Damage is halved after the first target. \
		Deals 50% increased damage to simple-minded creechurs."
	button_icon = 'icons/mob/actions/mage_shared.dmi'
	button_icon_state = "soulshot"
	sound = 'sound/magic/soulshot.ogg'
	spell_color = GLOW_COLOR_KINESIS
	glow_intensity = GLOW_INTENSITY_MEDIUM

	projectile_type = /obj/projectile/magic/soulshot_magi2
	cast_range = SPELL_RANGE_PROJECTILE
	point_cost = 3

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_MAJOR_PROJECTILE

	invocations = list("Animus Ictus!")
	invocation_type = INVOCATION_SHOUT

	click_to_activate = TRUE
	charge_required = TRUE
	weapon_cast_penalized = TRUE
	charge_time = CHARGETIME_MAJOR
	charge_drain = 1
	charge_slowdown = CHARGING_SLOWDOWN_SMALL
	charge_sound = 'sound/magic/charging.ogg'
	cooldown_time = 8 SECONDS
	attunement_school = ASPECT_NAME_KINESIS

	associated_skill = /datum/skill/magic/arcane
	spell_tier = 2

/obj/projectile/magic/soulshot_magi2
	name = "soulshot"
	tracer_type = /obj/effect/projectile/tracer/bloodsteal
	muzzle_type = null
	impact_type = null
	hitscan = TRUE
	movement_type = UNSTOPPABLE
	damage = 95
	damage_type = BRUTE
	woundclass = BCLASS_STAB
	npc_damage_mult = 1.5
	accuracy = 40
	nodamage = FALSE
	speed = 0.3
	flag = "piercing"
	hitsound = 'sound/magic/obeliskbeam.ogg'
	light_color = "#9400D3"
	light_outer_range = 7
	var/hits = 0
	var/max_hits = 4

/obj/projectile/magic/soulshot_magi2/on_hit(target)
	. = ..()
	if(ismob(target))
		var/mob/M = target
		if(M.anti_magic_check())
			visible_message(span_warning("[src] fizzles on contact with [target]!"))
			playsound(get_turf(target), 'sound/magic/magic_nulled.ogg', 100)
			qdel(src)
			return BULLET_ACT_BLOCK
	if(!ismob(target))
		qdel(src)
		return . || BULLET_ACT_HIT
	hits++
	damage = (hits <= 1) ? 95 : round(95 * 0.5)
	if(hits >= max_hits)
		qdel(src)
		return . || BULLET_ACT_HIT
	return BULLET_ACT_FORCE_PIERCE
