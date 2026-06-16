/obj/projectile/bullet
	name = "bullet"
	icon_state = "bullet"
	damage = 60
	pass_flags = PASSTABLE | PASSGRILLE
	damage_type = BRUTE
	nodamage = FALSE
	flag = "piercing"
	hitsound_wall = "ricochet"
	impact_effect_type = /obj/effect/temp_visual/impact_effect
	// physical projectiles (bolts, arrows, bullets) shouldn't bounce off walls; the base
	// projectile defaults to ricochets_max = 2, which is meant for magic projectiles only
	ricochets_max = 0
