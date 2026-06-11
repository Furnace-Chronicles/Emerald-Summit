// Gravel Blast — Geomancy minor staple, 5-projectile spread that ricochets off walls.

#define MT_ROCKSHOT_MAGI2 "rockshot_magi2"
#define ROCKSHOT_DR_DURATION_MAGI2 (1 SECONDS)

/datum/action/cooldown/spell/projectile/gravel_blast_magi2
	name = "Gravel Blast"
	desc = "Spray a volley of stones at a target. Stones ricochet off walls. Subsequent hits on the same target deal reduced damage. \
		Stones are particularly effective at degrading armor. Deals 2x damage to structures."
	button_icon = 'icons/mob/actions/mage_geomancy.dmi'
	button_icon_state = "gravel_blast"
	sound = 'sound/combat/hits/onstone/wallhit.ogg'
	spell_color = GLOW_COLOR_EARTHEN
	glow_intensity = GLOW_INTENSITY_LOW

	projectile_type = /obj/projectile/magic/gravel_blast_magi2
	projectile_type_arc = /obj/projectile/magic/gravel_blast_magi2/arc
	cast_range = SPELL_RANGE_PROJECTILE
	projectiles_per_fire = 5

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_MINOR_PROJECTILE

	invocations = list("Saxum Iaci!")
	invocation_type = INVOCATION_SHOUT

	click_to_activate = TRUE
	charge_required = TRUE
	weapon_cast_penalized = TRUE
	charge_time = CHARGETIME_POKE
	charge_drain = 1
	charge_slowdown = CHARGING_SLOWDOWN_NONE
	charge_sound = 'sound/magic/charging_fire.ogg'
	cooldown_time = 5.5 SECONDS
	attunement_school = ASPECT_NAME_GEOMANCY
	var/spread_step = 8

	associated_skill = /datum/skill/magic/arcane
	spell_impact_intensity = SPELL_IMPACT_LOW

/datum/action/cooldown/spell/projectile/gravel_blast_magi2/ready_projectile(obj/projectile/to_fire, atom/target, mob/user, iteration)
	. = ..()
	var/base_angle = to_fire.Angle
	if(isnull(base_angle))
		base_angle = Get_Angle(user, target)
	var/center_index = (projectiles_per_fire + 1) / 2
	to_fire.Angle = base_angle + ((iteration - center_index) * spread_step)
	// Only the center stone can roll for blunt crit/knockout
	if(iteration != center_index)
		to_fire.woundclass = null

/obj/projectile/magic/gravel_blast_magi2
	name = "gravel shot"
	icon = 'icons/obj/magic_projectiles.dmi'
	icon_state = "stone"
	damage = 26
	nodamage = FALSE
	damage_type = BRUTE
	woundclass = BCLASS_BLUNT
	flag = "blunt"
	range = SPELL_RANGE_PROJECTILE
	speed = MAGE_PROJ_SLOW
	accuracy = 50
	npc_damage_mult = 1.5
	hitsound = 'sound/combat/hits/onstone/wallhit.ogg'
	ricochets_max = 2
	ricochet_chance = 80
	// Dropped intdamfactor + object_damage_multiplier + ricochet_auto_aim_* +
	// ricochet_incidence_leeway + ricochet_decay_* — AP-specific projectile vars
	// that ES projectile doesn't declare. Stone-specific damage scaling and
	// ricochet refinements are lost in the pilot; standard ricochet behavior remains.
	var/reduced_damage = 11

/obj/projectile/magic/gravel_blast_magi2/arc
	name = "arced gravel shot"
	damage = 20
	arcshot = TRUE

/obj/projectile/magic/gravel_blast_magi2/on_hit(target)
	if(ismob(target))
		var/mob/living/M = target
		if(M.anti_magic_check())
			visible_message(span_warning("[src] shatters harmlessly against [target]!"))
			playsound(get_turf(target), 'sound/magic/magic_nulled.ogg', 100)
			qdel(src)
			return BULLET_ACT_BLOCK
		if(M == firer)
			damage = round(damage / 2)
		else if(M.mob_timers[MT_ROCKSHOT_MAGI2] && world.time < M.mob_timers[MT_ROCKSHOT_MAGI2] + ROCKSHOT_DR_DURATION_MAGI2)
			damage = reduced_damage
		else
			M.mob_timers[MT_ROCKSHOT_MAGI2] = world.time
	. = ..()

#undef MT_ROCKSHOT_MAGI2
#undef ROCKSHOT_DR_DURATION_MAGI2
