// Arcyne Salvo — Telomancy 3-bolt spread. Center bolt rolls for blunt crit/knockout.
// Bolts ricochet up to 2 times with strong auto-aim.

/datum/action/cooldown/spell/projectile/arcyne_salvo_magi2
	name = "Arcyne Salvo"
	desc = "Loose three heavy arcyne bolts in a wide spread toward a single target. \
		Each bolt strikes hard on its own; converging all three on the same foe is devastating. \
		The spread is wide enough that only a Telomancer willing to close the distance lands the full salvo."
	button_icon = 'icons/mob/actions/mage_telomancy.dmi'
	button_icon_state = "arcyne_salvo"
	sound = 'sound/magic/vlightning.ogg'
	spell_color = GLOW_COLOR_ARCANE
	glow_intensity = GLOW_INTENSITY_MEDIUM
	attunement_school = ASPECT_NAME_TELOMANCY

	projectile_type = /obj/projectile/magic/arcyne_salvo_magi2
	cast_range = SPELL_RANGE_PROJECTILE
	projectiles_per_fire = 3

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_MAJOR_PROJECTILE

	invocations = list("Tela Convergunt!")
	invocation_type = INVOCATION_SHOUT

	click_to_activate = TRUE
	charge_required = TRUE
	weapon_cast_penalized = TRUE
	charge_time = CHARGETIME_POKE
	charge_drain = 1
	charge_slowdown = CHARGING_SLOWDOWN_NONE
	charge_sound = 'sound/magic/charging.ogg'
	cooldown_time = 12 SECONDS

	associated_skill = /datum/skill/magic/arcane
	spell_tier = 3
	spell_impact_intensity = SPELL_IMPACT_MEDIUM
	displayed_damage = 30
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN

	var/spread_step = 15

/datum/action/cooldown/spell/projectile/arcyne_salvo_magi2/ready_projectile(obj/projectile/to_fire, atom/target, mob/user, iteration)
	. = ..()
	var/base_angle = to_fire.Angle
	if(isnull(base_angle))
		base_angle = Get_Angle(user, target)
	var/center_index = (projectiles_per_fire + 1) / 2
	to_fire.Angle = base_angle + ((iteration - center_index) * spread_step)
	if(iteration != center_index)
		to_fire.woundclass = null

/obj/projectile/magic/arcyne_salvo_magi2
	name = "arcyne bolt"
	icon = 'icons/obj/magic_projectiles.dmi'
	icon_state = "arcyne_bolt"
	damage = 30
	damage_type = BRUTE
	woundclass = BCLASS_BLUNT
	flag = "blunt"
	range = SPELL_RANGE_PROJECTILE
	speed = MAGE_PROJ_FAST
	accuracy = 60
	npc_damage_mult = 1.5
	hitsound = 'sound/combat/hits/blunt/shovel_hit2.ogg'
	ricochets_max = 2
	ricochet_chance = 100

/obj/projectile/magic/arcyne_salvo_magi2/on_hit(target)
	hitsound = pick('sound/combat/hits/blunt/shovel_hit.ogg', 'sound/combat/hits/blunt/shovel_hit2.ogg', 'sound/combat/hits/blunt/shovel_hit3.ogg')
	if(ismob(target))
		var/mob/living/M = target
		if(M.anti_magic_check())
			visible_message(span_warning("[src] dissipates harmlessly against [target]!"))
			playsound(get_turf(target), 'sound/magic/magic_nulled.ogg', 100)
			qdel(src)
			return BULLET_ACT_BLOCK
	. = ..()
