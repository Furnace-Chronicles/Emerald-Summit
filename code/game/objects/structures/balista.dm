/obj/item/ammo_casing/caseless/rogue/bolt
	name = "ballista bolt"
	desc = "A massive hardened bolt for a balista."
	icon = 'icons/roguetown/weapons/ammo.dmi'
	icon_state = "bolt"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/ammo_casing/caseless/rogue/bolt/rope
	name = "rope bolt"
	desc = "A barbed bolt with a trailing rope."
	icon_state = "bolt"

/obj/effect/ballista_bolt
	name = "ballista bolt"
	icon = 'icons/roguetown/weapons/ammo.dmi'
	icon_state = "bolt_proj"
	anchored = TRUE
	density = FALSE
	layer = ABOVE_MOB_LAYER
	var/range = 20
	var/drag_steps = 6
	var/only_carbon = FALSE
	var/build_branches_on_hit = FALSE
	var/mob/living/firer
	var/obj/structure/balista/launcher
	var/turf/start_turf
	var/list/traveled

/obj/effect/ballista_bolt/Initialize()
	. = ..()
	traveled = list()

/obj/effect/ballista_bolt/proc/apply_cut_damage(mob/living/L, amount)
	if(hascall(L, "apply_damage"))
		call(L, "apply_damage")(amount, BRUTE, "cut")
	else if(hascall(L, "adjustBruteLoss"))
		call(L, "adjustBruteLoss")(amount)

/obj/effect/ballista_bolt/proc/knock_and_drag(mob/living/L, step_dir)
	if(!istype(L)) return
	if(hascall(L, "Knockdown"))
		call(L, "Knockdown")(30)
	else if(hascall(L, "Immobilize"))
		call(L, "Immobilize")(30)
	for(var/i in 1 to drag_steps)
		var/turf/next = get_step(L, step_dir)
		if(!istype(next) || next.density) break
		L.forceMove(next)

/obj/effect/ballista_bolt/proc/build_branches_along_path()
	if(!traveled) return
	for(var/turf/T in traveled)
		new /obj/structure/flora/newbranch/leafless(T)

/obj/effect/ballista_bolt/proc/hit_mob(mob/living/L, step_dir)
	apply_cut_damage(L, 150)
	knock_and_drag(L, step_dir)

/obj/effect/ballista_bolt/proc/hit_structure(atom/A)
	if(istype(A, /obj/structure))
		var/obj/structure/S = A
		if(hascall(S, "take_damage"))
			S.take_damage(500)
	else if(isturf(A))
		var/turf/T = A
		if(hascall(T, "take_damage"))
			call(T, "take_damage")(500, BRUTE, "blunt", 0)

/obj/effect/ballista_bolt/proc/collides_here(turf/T)
	for(var/mob/living/M in T)
		if(M == firer) continue
		if(only_carbon && !istype(M, /mob/living/carbon)) continue
		return M
	for(var/obj/O in T)
		if(O == src || O == launcher) continue
		if(O.density) return O
	if(T.density) return T
	return null

/obj/effect/ballista_bolt/proc/launch_to(turf/target)
	start_turf = get_turf(src)
	var/turf/current = start_turf
	var/steps = 0
	var/hit = null
	while(current && steps < range)
		steps++
		var/dir_to = get_dir(current, target)
		if(!dir_to)
			dir_to = get_dir(current, start_turf)
		var/turf/next = get_step(current, dir_to)
		if(!istype(next)) break
		forceMove(next)
		current = next
		traveled += current
		hit = collides_here(current)
		if(hit)
			if(isliving(hit))
				var/mob/living/L = hit
				hit_mob(L, dir_to)
			else
				hit_structure(hit)
				if(build_branches_on_hit)
					build_branches_along_path()
			break
		sleep(1)
	qdel(src)

/obj/effect/ballista_bolt/heavy
	range = 30
	drag_steps = 6
	only_carbon = FALSE
	build_branches_on_hit = FALSE
	icon_state = "bolt_proj"

/obj/effect/ballista_bolt/rope
	range = 7
	drag_steps = 6
	only_carbon = TRUE
	build_branches_on_hit = TRUE
	icon_state = "bolt_proj"

/obj/structure/balista
	name = "balista"
	desc = "A large stationary siege weapon designed to launch heavy bolts with devastating force."
	icon = 'icons/roguetown/items/siege.dmi'
	icon_state = "balistasiege"
	anchored = TRUE
	density = TRUE
	layer = BELOW_OBJ_LAYER
	max_integrity = 500
	resistance_flags = FIRE_PROOF
	can_buckle = TRUE
	max_buckled_mobs = 1
	buckleverb = "mount"
	var/cocked = FALSE
	var/loaded = FALSE
	var/reload_time = 50
	var/firing_cooldown = 30
	var/last_fire = 0
	var/obj/item/ammo_casing/caseless/rogue/bolt/loaded_bolt = null
	var/mob/living/operator = null
	var/fire_sound = 'sound/combat/Ranged/crossbow-small-shot-02.ogg'
	var/load_sound = 'sound/foley/nockarrow.ogg'

/obj/structure/balista/proc/user_is_behind(mob/living/user)
	if(!istype(user)) return FALSE
	var/turf/behind = get_step(src, turn(dir, 180))
	return (user.loc == behind)

/obj/structure/balista/post_buckle_mob(mob/living/M)
	..()
	if(!istype(M)) return
	operator = M
	to_chat(M, span_notice("I take position behind the balista."))
	M.setDir(dir)

/obj/structure/balista/post_unbuckle_mob(mob/living/M)
	..()
	if(operator == M)
		operator = null
		to_chat(M, span_notice("I leave the balista."))

/obj/structure/balista/MouseDrop_T(mob/living/M, mob/living/user)
	if(istype(M) && user == M && in_range(src, user))
		if(user_is_behind(user))
			if(!buckled_mobs || !(user in buckled_mobs))
				if(user_buckle_mob(user, user, FALSE))
					return TRUE
		else
			to_chat(user, span_warning("Stand directly behind the balista to mount it."))
	return ..()

/obj/structure/balista/attackby(obj/item/A, mob/user, params)
	if(istype(A, /obj/item/ammo_casing/caseless/rogue/bolt) || istype(A, /obj/item/ammo_casing/caseless/rogue/bolt/rope))
		if(loaded)
			to_chat(user, span_warning("The balista is already loaded."))
			return
		to_chat(user, span_info("I place [A] into the balista’s track..."))
		if(do_after(user, 20, target = src))
			loaded = TRUE
			loaded_bolt = A
			user.dropItemToGround(A)
			qdel(A)
			to_chat(user, span_notice("The balista is loaded."))
		return
	return ..()

/obj/structure/balista/attack_hand(mob/user)
	. = ..()
	if(.) return
	if(user != operator)
		if(!buckled_mobs || !(user in buckled_mobs))
			if(!user_is_behind(user))
				to_chat(user, span_warning("Stand directly behind the balista to mount it."))
				return
			user_buckle_mob(user, user, FALSE)
		return
	if(world.time < last_fire + firing_cooldown)
		to_chat(user, span_warning("The balista is still resetting!"))
		return
	if(!cocked)
		to_chat(user, span_info("I pull back the massive winch..."))
		if(do_after(user, reload_time, target = src))
			cocked = TRUE
			if(load_sound) playsound(src, load_sound, 100, FALSE)
			to_chat(user, span_notice("The balista is now cocked."))
		return
	if(!loaded)
		to_chat(user, span_warning("I need to load a bolt first."))
		return
	var/turf/T = get_step(src, dir)
	fire(user, T)

/obj/structure/balista/Click(location, control, params)
	. = ..()
	if(!operator) return
	if(operator.stat || operator.buckled != src) return
	aim_and_maybe_fire_by_icon(operator, params)

/obj/structure/balista/proc/dir_from_icon_params(params, mob/living/user, fallback_dir)
	var/d = fallback_dir ? fallback_dir : src.dir
	if(!params)
		return (user ? user.dir : d)
	var/list/p = params2list(params)
	if(!p) return (user ? user.dir : d)
	var/ix = text2num(p["icon-x"])
	var/iy = text2num(p["icon-y"])
	if(!isnum(ix) || !isnum(iy))
		return (user ? user.dir : d)
	if(ix < 1) ix = 1
	if(ix > 32) ix = 32
	if(iy < 1) iy = 1
	if(iy > 32) iy = 32
	var/dx = ix - 16
	var/dy = iy - 16
	if(dx == 0 && dy == 0)
		return (user ? user.dir : d)
	if(abs(dx) >= abs(dy))
		d = (dx >= 0) ? EAST : WEST
	else
		d = (dy >= 0) ? NORTH : SOUTH
	return d

/obj/structure/balista/proc/aim_and_maybe_fire_by_icon(mob/living/user, params)
	var/d = dir_from_icon_params(params, user, src.dir)
	if(d)
		setDir(d)
		user.setDir(d)
	if(world.time < last_fire + firing_cooldown)
		to_chat(user, span_warning("The balista is still resetting!"))
		return
	if(!cocked)
		to_chat(user, span_info("I pull back the massive winch..."))
		if(do_after(user, reload_time, target = src))
			cocked = TRUE
			if(load_sound) playsound(src, load_sound, 100, FALSE)
			to_chat(user, span_notice("The balista is now cocked."))
		return
	if(!loaded)
		to_chat(user, span_warning("I need to load a bolt first."))
		return
	var/turf/T = get_step(src, d)
	fire(user, T)

/obj/structure/balista/proc/aim_and_fire_at_turf(turf/T, mob/living/user)
	if(!T || user != operator) return
	var/d = get_dir(src, T)
	if(d)
		setDir(d)
		user.setDir(d)
	fire(user, T)

/obj/structure/balista/proc/fire(mob/living/user, turf/aim_turf)
	if(!loaded_bolt || !loaded || !cocked) return
	if(!aim_turf) aim_turf = get_step(src, dir)
	var/obj/effect/ballista_bolt/B
	if(istype(loaded_bolt, /obj/item/ammo_casing/caseless/rogue/bolt/rope))
		B = new /obj/effect/ballista_bolt/rope(src.loc)
	else
		B = new /obj/effect/ballista_bolt/heavy(src.loc)
	B.firer = user
	B.launcher = src
	if(fire_sound) playsound(src, fire_sound, 100, FALSE)
	visible_message(span_warning("[src] launches a massive bolt with a thunderous snap!"))
	B.launch_to(aim_turf)
	cocked = FALSE
	loaded = FALSE
	loaded_bolt = null
	last_fire = world.time

/obj/structure/balista/Destroy()
	if(loaded_bolt) qdel(loaded_bolt)
	..()

/turf/Click(location, control, params)
	. = ..()
	if(!usr) return
	if(!istype(usr, /mob/living)) return
	var/list/p = params2list(params)
	if(!p || !p["left"]) return
	var/mob/living/L = usr
	if(L.buckled && istype(L.buckled, /obj/structure/balista))
		var/obj/structure/balista/B = L.buckled
		B.aim_and_fire_at_turf(src, L)
