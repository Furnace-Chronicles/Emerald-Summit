// Spitfire — Pyromancy staple, port of Azure-Peak spitfire.dm
// MVP config: click_to_activate FALSE (fires in facing direction, no click intercept system yet),
// charge_required TRUE with short charge time so the charging visuals exercise.

/datum/action/cooldown/spell/projectile/spitfire_magi2
	name = "Spitfire"
	desc = "Shoot out a low-powered ball of fire that ignites a target with a small amount of fire on impact. \
		Damage is increased by 100% versus simple-minded creechurs."
	button_icon = 'icons/mob/actions/mage_pyromancy.dmi'
	button_icon_state = "spitfire"
	sound = 'sound/magic/whiteflame.ogg'
	spell_color = GLOW_COLOR_FIRE
	glow_intensity = GLOW_INTENSITY_LOW

	projectile_type = /obj/projectile/magic/spitfire_magi2
	projectile_type_arc = /obj/projectile/magic/spitfire_magi2/arc
	cast_range = SPELL_RANGE_PROJECTILE

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_MINOR_PROJECTILE

	invocations = list("Evomere Flammas!")
	invocation_type = INVOCATION_SHOUT

	click_to_activate = TRUE
	charge_required = TRUE
	charge_time = CHARGETIME_POKE
	charge_drain = 0
	charge_slowdown = CHARGING_SLOWDOWN_NONE
	charge_sound = 'sound/magic/charging_fire.ogg'
	cooldown_time = 5.5 SECONDS
	weapon_cast_penalized = TRUE
	attunement_school = ASPECT_NAME_PYROMANCY

	associated_skill = /datum/skill/magic/arcane
	spell_impact_intensity = SPELL_IMPACT_LOW

/obj/projectile/magic/spitfire_magi2
	name = "spitfire"
	icon_state = "fireball"
	light_color = "#f8af07"
	light_outer_range = 2
	speed = MAGE_PROJ_MEDIUM
	damage = 36
	npc_damage_mult = 2
	accuracy = 40
	damage_type = BURN
	woundclass = BCLASS_BURN
	nodamage = FALSE
	flag = "fire"
	hitsound = 'sound/blank.ogg'

/obj/projectile/magic/spitfire_magi2/arc
	name = "arced spitfire"
	damage = 27
	arcshot = TRUE

/obj/projectile/magic/spitfire_magi2/on_hit(target)
	. = ..()
	var/turf/epicenter = get_turf(target)
	if(epicenter)
		new /obj/effect/temp_visual/explosion(epicenter)
		playsound(epicenter, pick('sound/magic/fireball.ogg', 'sound/misc/explode/bottlebomb (2).ogg'), 120, TRUE, 8)
		playsound(epicenter, pick('sound/misc/explode/incendiary (1).ogg', 'sound/misc/explode/incendiary (2).ogg'), 100, TRUE, 4)
	if(ismob(target))
		var/mob/living/M = target
		if(!istype(M))
			return
		if(M.anti_magic_check())
			visible_message(span_warning("[src] fizzles on contact with [target]!"))
			playsound(get_turf(target), 'sound/magic/magic_nulled.ogg', 100)
			qdel(src)
			return BULLET_ACT_BLOCK
		// Frost-thaw: if the target has any Cryomancy frost stacks, consume one before
		// applying fire. Both effects happen (matches upstream — fire still ignites after
		// thawing one stack of frost).
		if(has_frost_stacks(M))
			remove_frost_stack(M)
			visible_message(span_warning("The fire thaws the frost on [target]!"))
			playsound(get_turf(target), 'sound/items/firesnuff.ogg', 100)
			new /obj/effect/temp_visual/snap_freeze(get_turf(M))
		M.adjust_fire_stacks(1)
		M.ignite_mob()
	else if(isatom(target))
		var/atom/A = target
		A.fire_act()
