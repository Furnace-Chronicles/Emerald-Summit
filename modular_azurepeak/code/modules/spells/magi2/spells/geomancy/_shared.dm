// Geomancy shared types — pillar structure spawned by Emergence and the telegraph trap visual.
// /obj/effect/temp_visual/kinetic_blast and /obj/effect/temp_visual/ensnare both already
// exist in ES, so they're reused as-is.

/obj/effect/temp_visual/trap/emergence_magi2
	color = GLOW_COLOR_EARTHEN
	light_color = GLOW_COLOR_EARTHEN
	duration = TELEGRAPH_SKILLSHOT

/obj/structure/earthen_pillar_magi2
	name = "stone pillar"
	desc = "A pillar of conjured stone. Sturdy, but not indestructible. Shatters into gravel when destroyed."
	icon = 'icons/obj/flora/rocks.dmi'
	icon_state = "basalt1"
	break_sound = 'sound/combat/hits/onstone/stonedeath.ogg'
	attacked_sound = list('sound/combat/hits/onstone/wallhit.ogg', 'sound/combat/hits/onstone/wallhit2.ogg', 'sound/combat/hits/onstone/wallhit3.ogg')
	density = TRUE
	opacity = TRUE
	max_integrity = 150
	anchored = TRUE
	var/datum/weakref/caster_ref
	var/fragment_count = 3
	var/fragment_damage = 15

/obj/structure/earthen_pillar_magi2/Destroy()
	caster_ref = null
	return ..()

/obj/structure/earthen_pillar_magi2/obj_break()
	shatter_fragments()
	return ..()

/obj/structure/earthen_pillar_magi2/proc/shatter_fragments()
	var/turf/T = get_turf(src)
	if(!T)
		return
	var/mob/caster = caster_ref?.resolve()
	var/list/dirs = list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
	for(var/i in 1 to fragment_count)
		if(!length(dirs))
			break
		var/dir = pick_n_take(dirs)
		var/turf/target = get_ranged_target_turf(T, dir, 3)
		var/obj/projectile/magic/gravel_blast_magi2/frag = new(T)
		frag.damage = fragment_damage
		if(caster)
			frag.firer = caster
		frag.preparePixelProjectile(target, T)
		frag.fire()
