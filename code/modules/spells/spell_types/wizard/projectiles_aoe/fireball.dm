/obj/effect/proc_holder/spell/invoked/projectile/fireball
	name = "Fireball"
	desc = "Shoot out a ball of fire that emits a light explosion on impact, setting the target alight."
	clothes_req = FALSE
	range = 8
	projectile_type = /obj/projectile/magic/aoe/fireball/rogue
	overlay_state = "fireball"
	sound = list('sound/magic/fireball.ogg')
	releasedrain = 30
	chargedrain = 1
	chargetime = 25
	recharge_time = 15 SECONDS
	warnie = "spellwarning"
	no_early_release = TRUE
	movement_interrupt = FALSE
	charging_slowdown = 3
	spell_tier = 3 // AOE
	invocation = "Sphaera Ignis!"
	invocation_type = "shout"
	glow_color = GLOW_COLOR_FIRE
	glow_intensity = GLOW_INTENSITY_HIGH
	chargedloop = /datum/looping_sound/invokefire
	associated_skill = /datum/skill/magic/arcane
	cost = 6
	xp_gain = TRUE

/obj/projectile/magic/aoe/fireball/rogue
	name = "fireball"
	exp_heavy = 0
	exp_light = 0
	exp_flash = 0
	exp_fire = 1
	damage = 60
	damage_type = BURN
	npc_damage_mult = 2 // HAHAHA
	accuracy = 40 // Base accuracy is lower for burn projectiles because they bypass armor
	nodamage = FALSE
	flag = "magic"
	hitsound = 'sound/blank.ogg'
	aoe_range = 0

/obj/projectile/magic/aoe/fireball/rogue/fireball_noc
	name = "luaflame"
	damage = 80
	damage_type = BURN
	npc_damage_mult = 3 // STRAIGHTEST SHOOTER, FUCK YEAH, GYATDAMN!!
	accuracy = 60 // Base accuracy is lower for burn projectiles because they bypass armor
	icon_state = "fireball_noc"
	light_color = "#18313b"
	light_outer_range =  3

/obj/projectile/magic/aoe/fireball/rogue/on_hit(target)
	. = ..()
	if(isliving(target))
		var/mob/living/M = target
		if(M.anti_magic_check())
			visible_message(span_warning("[src] fizzles on contact with [target]!"))
			playsound(get_turf(target), 'sound/magic/magic_nulled.ogg', 100)
			qdel(src)
			return BULLET_ACT_BLOCK
		else
			M.adjust_fire_stacks(2) //1 pats to put it out
			visible_message(span_warning("[src] ignites [target]!"))
			M.ignite_mob()
	return FALSE

