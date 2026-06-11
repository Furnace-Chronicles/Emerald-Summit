// Boulder Strike — Geomancy major projectile. Heavy single-target with fragmentation cloud on impact.

/datum/action/cooldown/spell/projectile/boulder_strike_magi2
	name = "Boulder Strike"
	desc = "Hurl a massive boulder at a target. On impact, it shatters into a cloud of stone fragments. \
		Deals 2x damage to structures."
	button_icon = 'icons/mob/actions/mage_geomancy.dmi'
	button_icon_state = "boulder_strike"
	sound = 'sound/combat/hits/onstone/stonedeath.ogg'
	spell_color = GLOW_COLOR_EARTHEN
	glow_intensity = GLOW_INTENSITY_HIGH
	attunement_school = ASPECT_NAME_GEOMANCY

	projectile_type = /obj/projectile/magic/boulder_magi2
	projectile_type_arc = /obj/projectile/magic/boulder_magi2/arc
	cast_range = SPELL_RANGE_PROJECTILE

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_MAJOR_PROJECTILE

	invocations = list("Moles Terrae!")
	invocation_type = INVOCATION_SHOUT

	click_to_activate = TRUE
	charge_required = TRUE
	weapon_cast_penalized = TRUE
	charge_time = CHARGETIME_MAJOR
	charge_drain = 1
	charge_slowdown = CHARGING_SLOWDOWN_MEDIUM
	charge_sound = 'sound/magic/charging_fire.ogg'
	cooldown_time = 15 SECONDS

	associated_skill = /datum/skill/magic/arcane
	spell_impact_intensity = SPELL_IMPACT_HIGH

/obj/projectile/magic/boulder_magi2
	name = "boulder"
	icon = 'icons/obj/magic_projectiles.dmi'
	icon_state = "rock"
	damage = 90
	nodamage = FALSE
	damage_type = BRUTE
	woundclass = BCLASS_BLUNT
	flag = "blunt"
	range = SPELL_RANGE_PROJECTILE
	speed = 3.5
	accuracy = 30
	// Dropped intdamfactor + object_damage_multiplier — AP-only projectile vars.
	hitsound = 'sound/combat/hits/onstone/stonedeath.ogg'
	var/frag_count = 8
	var/frag_damage = 15

/obj/projectile/magic/boulder_magi2/arc
	name = "arced boulder"
	damage = 68
	frag_count = 6
	arcshot = TRUE

/obj/projectile/magic/boulder_magi2/on_hit(target)
	. = ..()
	var/turf/impact = get_turf(src)
	if(!impact)
		return
	for(var/i in 1 to frag_count)
		var/obj/projectile/magic/gravel_blast_magi2/frag = new(impact)
		frag.damage = frag_damage
		frag.range = 3
		frag.ricochets_max = 0
		frag.ricochet_chance = 0
		frag.firer = firer
		frag.name = "gravel fragment"
		var/angle = rand(0, 359)
		frag.fire(angle)
	playsound(impact, 'sound/combat/hits/onstone/stonedeath.ogg', 100, TRUE, 5)

/obj/projectile/magic/boulder_magi2/Bump(atom/A)
	if(ismob(A))
		var/mob/living/M = A
		if(M.anti_magic_check())
			visible_message(span_warning("[src] shatters harmlessly against [M]!"))
			playsound(get_turf(M), 'sound/magic/magic_nulled.ogg', 100)
			qdel(src)
			return
		if(M == firer)
			damage = round(damage / 2)
	return ..()
