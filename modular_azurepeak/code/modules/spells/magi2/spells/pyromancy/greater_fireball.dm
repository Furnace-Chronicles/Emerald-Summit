// Greater Fireball — Pyromancy Mastery (T4 additive variant). Port of Azure-Peak
// fireball_greater.dm. Subtypes our ported fireball_magi2 projectile, inheriting the full
// blast/structural on_hit logic and just scaling up damage and radius.

/datum/action/cooldown/spell/projectile/fireball_magi2/greater
	name = "Greater Fireball"
	desc = "Shoot out an immense ball of fire that explodes on impact, scorching and slowing all nearby targets in a wide radius. \
		Damage is increased by 100% versus simple-minded creechurs.\n\
		Toggle arc mode (Ctrl+G) while the spell is active to fire it over intervening mobs. Arced attacks deal 25% less damage."
	button_icon_state = "fireball_greater"
	glow_intensity = GLOW_INTENSITY_VERY_HIGH

	projectile_type = /obj/projectile/magic/aoe/fireball/magi2/great
	projectile_type_arc = /obj/projectile/magic/aoe/fireball/magi2/great/arc

	primary_resource_cost = SPELLCOST_SUPER_PROJECTILE

	invocations = list("Maior Sphaera Ignis!")

	charge_slowdown = CHARGING_SLOWDOWN_MEDIUM
	cooldown_time = 30 SECONDS

	spell_tier = 4
	point_cost = 9
	spell_impact_intensity = SPELL_IMPACT_HIGH

/obj/projectile/magic/aoe/fireball/magi2/great
	name = "greater fireball"
	damage = 90
	arcyne_aoe_radius = 2
	structural_damage = 150

/obj/projectile/magic/aoe/fireball/magi2/great/arc
	name = "arced greater fireball"
	damage = 68
	arcshot = TRUE
