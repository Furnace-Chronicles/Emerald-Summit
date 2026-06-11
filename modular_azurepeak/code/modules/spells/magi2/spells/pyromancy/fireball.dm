// Fireball — Pyromancy major projectile, port of Azure-Peak fireball.dm
// MVP config: click_to_activate FALSE so the spell fires in the caster's facing direction.

/datum/action/cooldown/spell/projectile/fireball_magi2
	name = "Fireball"
	desc = "Shoot out a ball of fire that explodes on impact, scorching and slowing nearby targets. \
		Toggle arc mode (Ctrl+G) while the spell is active to fire it over intervening mobs. Arced attacks deal 25% less damage."
	button_icon = 'icons/mob/actions/mage_pyromancy.dmi'
	button_icon_state = "fireball"
	sound = 'sound/magic/fireball.ogg'
	spell_color = GLOW_COLOR_FIRE
	glow_intensity = GLOW_INTENSITY_HIGH
	attunement_school = ASPECT_NAME_PYROMANCY

	projectile_type = /obj/projectile/magic/aoe/fireball/magi2
	projectile_type_arc = /obj/projectile/magic/aoe/fireball/magi2/arc
	cast_range = SPELL_RANGE_PROJECTILE
	point_cost = 6
	spell_impact_intensity = SPELL_IMPACT_MEDIUM

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_MAJOR_PROJECTILE

	invocations = list("Sphaera Ignis!")
	invocation_type = INVOCATION_SHOUT

	click_to_activate = TRUE
	charge_required = TRUE
	weapon_cast_penalized = TRUE
	charge_time = CHARGETIME_MAJOR
	charge_drain = 1
	charge_slowdown = CHARGING_SLOWDOWN_MEDIUM
	charge_sound = 'sound/magic/charging_fire.ogg'
	cooldown_time = 16 SECONDS

	associated_skill = /datum/skill/magic/arcane
	spell_tier = 3

/obj/projectile/magic/aoe/fireball/magi2
	name = "fireball"
	speed = MAGE_PROJ_VERY_SLOW
	exp_heavy = -1
	exp_light = -1
	exp_flash = 0
	exp_fire = 0
	damage = 70
	damage_type = BURN
	woundclass = BCLASS_BURN
	npc_damage_mult = 3
	accuracy = 40
	nodamage = FALSE
	flag = "fire"
	hitsound = 'sound/blank.ogg'
	aoe_range = 0
	var/arcyne_aoe_radius = 1
	var/arcyne_aoe_damage_ratio = 0.66
	var/structural_damage = 60
	var/structural_damage_radius = 0

/obj/projectile/magic/aoe/fireball/magi2/arc
	name = "arced fireball"
	damage = 53
	arcshot = TRUE

/obj/projectile/magic/aoe/fireball/magi2/on_hit(target)
	..()
	var/mob/living/M = ismob(target) ? target : null

	if(M?.anti_magic_check())
		visible_message(span_warning("[src] fizzles on contact with [target]!"))
		playsound(get_turf(target), 'sound/magic/magic_nulled.ogg', 100)
		qdel(src)
		return BULLET_ACT_BLOCK

	if(M)
		// Pyromancy/Cryomancy synergy: shatter one frost stack on the direct hit.
		if(has_frost_stacks(M))
			remove_frost_stack(M)
			M.visible_message(span_warning("The fireball thaws the frost on [M]!"))
			playsound(get_turf(M), 'sound/items/firesnuff.ogg', 100)
		M.adjust_fire_stacks(1)
		M.ignite_mob()

	var/aoe_damage = round(damage * arcyne_aoe_damage_ratio)
	var/turf/epicenter = get_turf(target)

	if(epicenter)
		new /obj/effect/temp_visual/explosion(epicenter)
		playsound(epicenter, pick('sound/misc/explode/bomb.ogg', 'sound/misc/explode/explosionclose (1).ogg', 'sound/misc/explode/explosionclose (2).ogg', 'sound/misc/explode/explosionclose (3).ogg'), 120, TRUE, 8)
		playsound(epicenter, pick('sound/misc/explode/incendiary (1).ogg', 'sound/misc/explode/incendiary (2).ogg'), 100, TRUE, 4)

	if(arcyne_aoe_radius > 0 && istype(firer, /mob/living/carbon/human))
		var/mob/living/carbon/human/caster = firer
		var/mob/living/direct_hit = M
		for(var/turf/T in range(arcyne_aoe_radius, epicenter))
			new /obj/effect/temp_visual/fire(T)
			for(var/mob/living/L in T)
				if(L == direct_hit || L.stat == DEAD)
					continue
				if(L.anti_magic_check())
					continue
				arcyne_strike(caster, L, null, aoe_damage, BODY_ZONE_CHEST, \
					BCLASS_BURN, spell_name = "Fireball (Blast)", \
					allow_shield_check = TRUE, damage_type = BURN, \
					npc_damage_mult = npc_damage_mult, \
					skip_animation = TRUE)
				L.adjust_fire_stacks(1)
				L.ignite_mob()
				L.Slowdown(1)

	if(arcyne_aoe_radius > 0)
		var/struct_radius = structural_damage_radius ? structural_damage_radius : arcyne_aoe_radius
		for(var/turf/T in range(struct_radius, epicenter))
			T.fire_act()
			for(var/atom/A in T)
				if(ismob(A))
					continue
				A.fire_act()
		if(structural_damage > 0)
			for(var/obj/structure/damaged in view(struct_radius, epicenter))
				if(!istype(damaged, /obj/structure/flora/newbranch))
					damaged.take_damage(structural_damage, BRUTE, "blunt", 1)
			for(var/turf/closed/wall/damagedwalls in view(struct_radius, epicenter))
				damagedwalls.take_damage(structural_damage, BRUTE, "blunt", 1)

	return TRUE
