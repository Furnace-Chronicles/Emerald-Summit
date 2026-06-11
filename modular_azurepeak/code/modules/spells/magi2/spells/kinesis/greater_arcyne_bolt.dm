// Greater Arcyne Bolt — Kinesis minor staple. Pure-arcane bolt, blunt damage.

/datum/action/cooldown/spell/projectile/greater_arcyne_bolt_magi2
	name = "Greater Arcyne Bolt"
	desc = "Fire a concentrated bolt of arcyne energy at a single target. \
		Deals 50% increased damage to simple-minded creechurs."
	button_icon = 'icons/mob/actions/mage_shared.dmi'
	button_icon_state = "greater_arcyne_bolt"
	sound = 'sound/magic/vlightning.ogg'
	spell_color = GLOW_COLOR_ARCANE
	glow_intensity = GLOW_INTENSITY_MEDIUM
	attunement_school = ASPECT_NAME_KINESIS

	projectile_type = /obj/projectile/magic/greater_arcyne_bolt_magi2
	projectile_type_arc = /obj/projectile/magic/greater_arcyne_bolt_magi2/arc
	cast_range = SPELL_RANGE_PROJECTILE
	point_cost = 3

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_MINOR_PROJECTILE

	invocations = list("Magicae Sagitta!")
	invocation_type = INVOCATION_SHOUT

	click_to_activate = TRUE
	charge_required = TRUE
	weapon_cast_penalized = TRUE
	charge_time = CHARGETIME_POKE
	charge_drain = 1
	charge_slowdown = CHARGING_SLOWDOWN_NONE
	charge_sound = 'sound/magic/charging.ogg'
	cooldown_time = 5.5 SECONDS

	associated_skill = /datum/skill/magic/arcane
	spell_tier = 2
	spell_impact_intensity = SPELL_IMPACT_MEDIUM

/obj/projectile/magic/greater_arcyne_bolt_magi2
	name = "greater arcyne bolt"
	icon = 'icons/obj/magic_projectiles.dmi'
	icon_state = "arcyne_bolt"
	damage = 45 // AP #6666 "GAB buff to 45 dam" (ES had it at 54)
	damage_type = BRUTE
	flag = "blunt"
	woundclass = BCLASS_BLUNT
	npc_damage_mult = 1.5
	nodamage = FALSE
	speed = MAGE_PROJ_FAST
	range = SPELL_RANGE_PROJECTILE
	hitsound = 'sound/combat/hits/blunt/shovel_hit2.ogg'

/obj/projectile/magic/greater_arcyne_bolt_magi2/arc
	name = "arced greater arcyne bolt"
	damage = 41
	arcshot = TRUE

/obj/projectile/magic/greater_arcyne_bolt_magi2/on_hit(target)
	hitsound = pick('sound/combat/hits/blunt/shovel_hit.ogg', 'sound/combat/hits/blunt/shovel_hit2.ogg', 'sound/combat/hits/blunt/shovel_hit3.ogg')
	if(ismob(target))
		var/mob/M = target
		if(M.anti_magic_check())
			visible_message(span_warning("[src] fizzles on contact with [target]!"))
			playsound(get_turf(target), 'sound/magic/magic_nulled.ogg', 100)
			qdel(src)
			return BULLET_ACT_BLOCK
		playsound(get_turf(target), hitsound, 80, TRUE)
	return ..()
