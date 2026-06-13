// Bolt of Lightning — Fulgurmancy major projectile, hitscan CC + burn damage.
// Lightning Adaptation: CC reapplication gated by 15s timer using MT_LIGHTNING_ADAPTATION.

/datum/action/cooldown/spell/projectile/lightning_bolt_magi2
	name = "Bolt of Lightning"
	desc = "Emit a bolt of lightning that burns a target, preventing them from attacking and slowing them down for 6 seconds. \
		Damage is increased by 100% versus simple-minded creechurs. \
		The CC effects cannot be reapplied to the same target within 15 seconds."
	button_icon = 'icons/mob/actions/mage_fulgurmancy.dmi'
	button_icon_state = "lightning_bolt"
	sound = 'sound/magic/lightning.ogg'
	spell_color = GLOW_COLOR_LIGHTNING
	glow_intensity = GLOW_INTENSITY_MEDIUM
	attunement_school = ASPECT_NAME_FULGURMANCY

	projectile_type = /obj/projectile/magic/lightning_magi2
	cast_range = SPELL_RANGE_PROJECTILE

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_MAJOR_PROJECTILE

	invocations = list("Fulmen!")
	invocation_type = INVOCATION_SHOUT

	click_to_activate = TRUE
	charge_required = TRUE
	weapon_cast_penalized = TRUE
	charge_time = CHARGETIME_MAJOR
	charge_drain = 1
	charge_slowdown = CHARGING_SLOWDOWN_MEDIUM
	charge_sound = 'sound/magic/charging.ogg'
	cooldown_time = 15 SECONDS

	associated_skill = /datum/skill/magic/arcane
	spell_impact_intensity = SPELL_IMPACT_MEDIUM

/obj/projectile/magic/lightning_magi2
	name = "bolt of lightning"
	tracer_type = /obj/effect/projectile/tracer/stun
	muzzle_type = null
	impact_type = null
	hitscan = TRUE
	movement_type = UNSTOPPABLE
	light_color = LIGHT_COLOR_WHITE
	damage = 45
	npc_damage_mult = 2
	damage_type = BURN
	accuracy = 40
	nodamage = FALSE
	speed = 0.3
	flag = "fire"
	light_outer_range = 7

/obj/projectile/magic/lightning_magi2/on_hit(target)
	. = ..()
	if(ismob(target))
		var/mob/M = target
		if(M.anti_magic_check())
			visible_message(span_warning("[src] fizzles on contact with [target]!"))
			playsound(get_turf(target), 'sound/magic/magic_nulled.ogg', 100)
			qdel(src)
			return BULLET_ACT_BLOCK
		if(isliving(target))
			var/mob/living/L = target
			L.electrocute_act(1, src, 1, SHOCK_NOSTUN)
			// Lightning Adaptation: all CC effects gated behind a 15s adaptation timer
			// so the target can't be perma-locked by spamming the spell.
			if(!L.mob_timers[MT_LIGHTNING_ADAPTATION] || world.time > L.mob_timers[MT_LIGHTNING_ADAPTATION] + LIGHTNING_ADAPTATION_COOLDOWN)
				L.Immobilize(0.5 SECONDS)
				L.apply_status_effect(/datum/status_effect/debuff/clickcd, 6 SECONDS)
				L.apply_status_effect(/datum/status_effect/buff/lightningstruck, 6 SECONDS)
				L.balloon_alert_to_viewers("<font color='#ffcc00'>shocked! (6s)</font>")
				L.mob_timers[MT_LIGHTNING_ADAPTATION] = world.time
			else
				var/remaining = round((L.mob_timers[MT_LIGHTNING_ADAPTATION] + LIGHTNING_ADAPTATION_COOLDOWN - world.time) / 10)
				L.balloon_alert_to_viewers("<font color='#ffcc00'>shock adapted ([remaining]s)</font>")
	else if(isatom(target))
		var/atom/A = target
		A.fire_act()
	qdel(src)
