// Seeker Volley — Telomancy 3-orb homing volley. Orbs deal trivial damage but mark and
// slow their fated quarry. Phase through anyone who isn't the original target.

/datum/action/cooldown/spell/projectile/seeker_volley_magi2
	name = "Seeker Volley"
	desc = "Lock onto a single target and loose a flight of slow arcyne orbs that pursue them relentlessly. \
		Each orb deals trivial damage but slows the chosen quarry to a crawl."
	button_icon = 'icons/mob/actions/mage_telomancy.dmi'
	button_icon_state = "seeker_volley"
	sound = 'sound/magic/vlightning.ogg'
	spell_color = GLOW_COLOR_ARCANE
	glow_intensity = GLOW_INTENSITY_LOW
	attunement_school = ASPECT_NAME_TELOMANCY

	projectile_type = /obj/projectile/magic/seeker_orb_magi2
	cast_range = SPELL_RANGE_PROJECTILE
	projectiles_per_fire = 3

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_MINOR_PROJECTILE

	invocations = list("Sequere, Telum!")
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
	spell_tier = 2
	spell_impact_intensity = SPELL_IMPACT_LOW
	displayed_damage = 5
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN

/datum/action/cooldown/spell/projectile/seeker_volley_magi2/ready_projectile(obj/projectile/to_fire, atom/target, mob/user, iteration)
	. = ..()
	if(istype(to_fire, /obj/projectile/magic/seeker_orb_magi2))
		var/obj/projectile/magic/seeker_orb_magi2/orb = to_fire
		orb.set_homing_target(target)
		orb.Angle += ((iteration - (projectiles_per_fire + 1) / 2) * 60)
		if(iteration != (projectiles_per_fire + 1) / 2)
			orb.woundclass = null

/obj/projectile/magic/seeker_orb_magi2
	name = "seeker orb"
	icon = 'icons/obj/magic_projectiles.dmi'
	icon_state = "seeker_orb"
	damage = 5
	damage_type = BRUTE
	woundclass = BCLASS_BLUNT
	flag = "blunt"
	range = 16
	speed = MAGE_PROJ_SLOW
	accuracy = 100
	npc_damage_mult = 1.5
	hitsound = 'sound/combat/hits/blunt/shovel_hit2.ogg'
	homing_turn_speed = 35
	homing_inaccuracy_max = 12

/obj/projectile/magic/seeker_orb_magi2/prehit(atom/target)
	if(isliving(target) && target != original)
		return FALSE
	return ..()

/obj/projectile/magic/seeker_orb_magi2/process_homing()
	if(QDELETED(homing_target))
		homing = FALSE
		return FALSE
	var/desired_angle = Get_Angle(src, homing_target)
	var/diff = closer_angle_difference(Angle, desired_angle)
	if(!isnum(diff))
		return FALSE
	setAngle(Angle + CLAMP(diff, -homing_turn_speed, homing_turn_speed))
	return TRUE

/obj/projectile/magic/seeker_orb_magi2/on_hit(target)
	hitsound = pick('sound/combat/hits/blunt/shovel_hit.ogg', 'sound/combat/hits/blunt/shovel_hit2.ogg', 'sound/combat/hits/blunt/shovel_hit3.ogg')
	if(ismob(target))
		var/mob/living/M = target
		if(M.anti_magic_check())
			visible_message(span_warning("[src] dissipates harmlessly against [target]!"))
			playsound(get_turf(target), 'sound/magic/magic_nulled.ogg', 100)
			qdel(src)
			return BULLET_ACT_BLOCK
		M.apply_status_effect(/datum/status_effect/debuff/seeker_marked_magi2)
	. = ..()

/datum/status_effect/debuff/seeker_marked_magi2
	id = "seeker_marked_magi2"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/seeker_marked_magi2
	duration = 8 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	effectedstats = list(STATKEY_SPD = -2)

/atom/movable/screen/alert/status_effect/debuff/seeker_marked_magi2
	name = "Marked"
	desc = "An arcyne weight clings to my limbs. The Telomancer's mark is upon me."
	icon_state = "debuff"

/datum/status_effect/debuff/seeker_marked_magi2/on_apply()
	. = ..()
	owner.balloon_alert_to_viewers("<font color='#b388ff'>marked!</font>")
