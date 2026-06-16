// Stygian Efflorescence — Ferramancy 3-shard spread of sharpened obsidian.
// Reduced damage to a target struck more than once in 1s by shards in the same volley.

#define MT_STYGIAN_MAGI2 "stygian_magi2"
#define STYGIAN_DR_DURATION_MAGI2 (1 SECONDS)

/datum/action/cooldown/spell/projectile/stygian_efflorescence_magi2
	name = "Stygian Efflorescence"
	desc = "Burst forth a volley of sharpened obsidian shards in a wide spread. \
		Additional shards striking the same target deal reduced damage."
	button_icon = 'icons/mob/actions/mage_ferramancy.dmi'
	button_icon_state = "stygian"
	sound = 'sound/magic/scrapeblade.ogg'
	spell_color = GLOW_COLOR_METAL
	glow_intensity = GLOW_INTENSITY_LOW
	attunement_school = ASPECT_NAME_FERRAMANCY

	projectile_type = /obj/projectile/energy/stygian_magi2
	cast_range = SPELL_RANGE_PROJECTILE
	projectiles_per_fire = 3

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_MINOR_PROJECTILE

	invocations = list("Golgothae Acies!")
	invocation_type = INVOCATION_SHOUT

	click_to_activate = TRUE
	charge_required = TRUE
	weapon_cast_penalized = TRUE
	charge_time = CHARGETIME_POKE
	charge_drain = 1
	charge_slowdown = CHARGING_SLOWDOWN_NONE
	charge_sound = 'sound/magic/charging.ogg'
	cooldown_time = 6 SECONDS

	associated_skill = /datum/skill/magic/arcane
	spell_tier = 2
	spell_impact_intensity = SPELL_IMPACT_MEDIUM
	displayed_damage = 34
	point_cost = 3
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN

	var/spread_step = 12

/datum/action/cooldown/spell/projectile/stygian_efflorescence_magi2/ready_projectile(obj/projectile/to_fire, atom/target, mob/user, iteration)
	. = ..()
	var/base_angle = to_fire.Angle
	if(isnull(base_angle))
		base_angle = Get_Angle(user, target)
	var/center_index = (projectiles_per_fire + 1) / 2
	to_fire.Angle = base_angle + ((iteration - center_index) * spread_step)
	// Only the center shard rolls for stab crit.
	if(iteration != center_index)
		to_fire.woundclass = null

/obj/projectile/energy/stygian_magi2
	name = "stygian harpe"
	icon = 'icons/obj/magic_projectiles.dmi'
	icon_state = "stygian"
	damage = 34
	damage_type = BRUTE
	woundclass = BCLASS_STAB
	armor_penetration = 10
	npc_damage_mult = 1.5
	speed = MAGE_PROJ_SLOW
	accuracy = 65
	flag = "piercing"
	range = 5
	hitsound = 'sound/combat/hits/bladed/genstab (1).ogg'
	var/reduced_damage = 18

/obj/projectile/energy/stygian_magi2/on_hit(target)
	if(ismob(target))
		var/mob/living/M = target
		if(M.anti_magic_check())
			visible_message(span_warning("[src] shatters harmlessly against [target]!"))
			playsound(get_turf(target), 'sound/magic/magic_nulled.ogg', 100)
			qdel(src)
			return BULLET_ACT_BLOCK
		if(M.mob_timers[MT_STYGIAN_MAGI2] && world.time < M.mob_timers[MT_STYGIAN_MAGI2] + STYGIAN_DR_DURATION_MAGI2)
			damage = reduced_damage
		else
			M.mob_timers[MT_STYGIAN_MAGI2] = world.time
	. = ..()

#undef MT_STYGIAN_MAGI2
#undef STYGIAN_DR_DURATION_MAGI2
