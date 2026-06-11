// Artillery Fireball — Pyromancy tier-4 fireball variant (ported from Azure-Peak PR #6666).
// Subtypes our ported fireball_magi2 spell + projectile, inheriting the full blast/structural
// on_hit logic and scaling up structural devastation (it "destroys structures with ease").
//
// Registered (AP-faithful) as Pyromancy's "grenzelhoftian" variant: it SWAPS base Fireball for
// Artillery rather than being a pointbuy pick. It only reaches a player whose mage class config
// requests that variant, i.e. mage_aspect_config["variants"] = list(<pyromancy aspect> = "grenzelhoftian").
// No such class exists on our branch yet, so Artillery is defined + wired but not yet handed to anyone.

/datum/action/cooldown/spell/projectile/fireball_magi2/artillery
	name = "Artillery Fireball"
	desc = "An artillery fireball that destroys structures with ease and creates a large impact of smoke and flame. \
	Damage is increased by 140% versus simple-minded creechurs.\n\
	Toggle arc mode (Ctrl+G) while the spell is active to fire it over intervening mobs. Arced attacks deal 25% less damage."
	button_icon_state = "fireball_artillery"
	glow_intensity = GLOW_INTENSITY_VERY_HIGH

	projectile_type = /obj/projectile/magic/aoe/fireball/magi2/artillery
	projectile_type_arc = /obj/projectile/magic/aoe/fireball/magi2/artillery/arc

	primary_resource_cost = SPELLCOST_MAJOR_PROJECTILE

	invocations = list("Ignis Sphaera Bombardae!")

	charge_time = CHARGETIME_HEAVY
	charge_slowdown = CHARGING_SLOWDOWN_HEAVY
	cooldown_time = 18 SECONDS

	spell_tier = 4
	point_cost = 9
	spell_impact_intensity = SPELL_IMPACT_HIGH

/obj/projectile/magic/aoe/fireball/magi2/artillery
	name = "artillery fireball"
	damage = 70
	npc_damage_mult = 2.4 // our base projectile uses npc_damage_mult (AP split this into npc_simple_damage_mult)
	accuracy = 40
	arcyne_aoe_radius = 1
	structural_damage = 300
	structural_damage_radius = 1

/obj/projectile/magic/aoe/fireball/magi2/artillery/arc
	name = "arced artillery fireball"
	damage = 45
	arcshot = TRUE
