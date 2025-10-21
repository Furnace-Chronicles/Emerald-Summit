/***********************
 * AMMO 
 *********************************/

/obj/item/trebuchet_ammo
    name = "trebuchet ammo"
    desc = "A heavy projectile for a trebuchet."
    icon = 'icons/roguetown/items/trebushet.dmi'
    icon_state = "ammo_generic"
    w_class = WEIGHT_CLASS_BULKY

/obj/item/trebuchet_ammo/explosive
    name = "explosive payload"
    icon_state = "ammo_explosive"

/obj/item/trebuchet_ammo/flame
    name = "incendiary payload"
    icon_state = "ammo_flame"

/obj/item/trebuchet_ammo/cluster
    name = "cluster payload"
    icon_state = "ammo_cluster"


/********************************
 * IMPACT!!! 
 **********************/

/obj/effect/trebuchet_marker
    name = "trebuchet mark"
    desc = "Impact marker."
    anchored = TRUE
    density = FALSE
    layer = ABOVE_MOB_LAYER
    mouse_opacity = MOUSE_OPACITY_TRANSPARENT
    var/time_left_ds = 0  
    var/started = 0

/obj/effect/trebuchet_marker/Initialize(mapload)
    . = ..()
    if(!started) START_PROCESSING(SSobj, src)

/obj/effect/trebuchet_marker/Destroy()
    STOP_PROCESSING(SSobj, src)
    return ..()

/obj/effect/trebuchet_marker/proc/update_maptext()
    var/sec = max(round(time_left_ds / 10), 0)
    maptext = "<span style='font-size:14px;font-weight:bold;color:#ff4444;text-shadow:1px 1px #000;'>[sec]</span>"

/obj/effect/trebuchet_marker/process()
    if(time_left_ds <= 0)
        QDEL_NULL(src)
        return
    time_left_ds -= 1
    update_maptext()


/***************************************
 * TREBUCHET 
 *****************
 ***********************/

/obj/structure/trebuchet
    name = "trebuchet"
    desc = "A counterweight trebuchet capable of hurling payloads across the map."
    icon = 'icons/roguetown/items/trebushet.dmi'
    icon_state = "trebushetempty"
    anchored = TRUE
    density = TRUE
    max_integrity = 600
    resistance_flags = FIRE_PROOF
    layer = BELOW_OBJ_LAYER
    var/loaded = FALSE
    var/loaded_ammo_path = null
    var/mob/living/loaded_mob = null
    var/reload_time = 50
    var/firing_cooldown = 30
    var/last_fire = 0
    var/impact_delay = 10 SECONDS
    var/fire_sound = null
    var/load_sound = null
    can_buckle = TRUE
    buckle_lying = FALSE
    max_buckled_mobs = 1

/obj/structure/trebuchet/update_icon()
    icon_state = (loaded || loaded_mob) ? "trebuchet" : "trebushetempty"


/***********************************************
 * load your payload inside it UwU

 **************************************/

/obj/structure/trebuchet/attack_hand(mob/living/user)
    return aim_and_fire_ui(user)

/obj/structure/trebuchet/attackby(obj/item/I, mob/living/user, params)
    if(istype(I, /obj/item/trebuchet_ammo))
        if(loaded || loaded_mob)
            to_chat(user, span_warning("Уже заряжено."))
            return TRUE
        to_chat(user, span_info("Я кладу снаряд в ложемент..."))
        if(do_after(user, reload_time, target = src))
            loaded = TRUE
            loaded_ammo_path = I.type
            if(user) user.dropItemToGround(I)
            qdel(I)
            if(load_sound)  
                playsound(src, load_sound, 50, FALSE)
            to_chat(user, span_notice("Требушет заряжен."))
            update_icon()
        return TRUE
    return ..()

/obj/structure/trebuchet/AltClick(mob/living/user)
    if(get_dist(src, user) > 1) return
    if(loaded || loaded_mob)
        to_chat(user, span_warning("Требушет уже заряжен."))
        return
    if(isliving(user.pulling) && get_dist(src, user.pulling) <= 1)
        var/mob/living/V = user.pulling
        attach_victim(user, V)
    else
        to_chat(user, span_info("Drag a victim next to it and drag them onto the trebuchet to load."))

/obj/structure/trebuchet/MouseDrop_T(atom/movable/AM, mob/living/user)
    if(!isliving(AM)) return ..()
    if(loaded || loaded_mob)
        to_chat(user, span_warning("Trebuchet is already loaded."))
        return
    var/mob/living/V = AM
    if(get_dist(src, user) > 1 || get_dist(src, V) > 1)
        return
    if(user.pulling && user.pulling != V)
        return
    attach_victim(user, V)
    return

/obj/structure/trebuchet/proc/attach_victim(mob/living/user, mob/living/V)
    if(loaded || loaded_mob) return
    if(!V || V.stat == DEAD)
        to_chat(user, span_warning("Труп не подходит."))
        return

    if(hasvar(V, "buckled") && V.buckled && hascall(V, "unbuckle_mob"))
        V.unbuckle_mob(TRUE)

    var/succeeded = FALSE //не ебу это тесты
    if(hascall(src, "buckle_mob"))
        succeeded = src.buckle_mob(V)        /
    else if(hascall(V, "buckle_mob"))
        succeeded = V.buckle_mob(src)     

    if(!succeeded)
        V.forceMove(src)

    loaded_mob = V
    to_chat(user, span_notice("Вы закрепляете [V] в ложементе требушета."))
    visible_message(span_danger("[src] подготовлен к запуску живого груза!"))
    update_icon()


/*********************************
 
  Fluff 2
 ***************************************/

/obj/structure/trebuchet/proc/columns_clear_between(xc, yc, z1, z2)
    var/low = min(z1, z2)
    var/high = max(z1, z2)
    if(high <= low) return TRUE
    for(var/zl = low + 1, zl <= high, zl++)
        var/turf/T = locate(xc, yc, zl)
        if(!T) continue
        if(!istype(T, /turf/open/transparent/openspace))
            return FALSE
    return TRUE

/obj/structure/trebuchet/proc/aim_and_fire_ui(mob/living/user)
    if(world.time < last_fire + firing_cooldown)
        to_chat(user, span_warning("Требушет перезаряжается!"))
        return TRUE
    if(!loaded && !loaded_mob)
        to_chat(user, span_warning("Сначала нужно загрузить снаряд — предмет или тушу."))
        return TRUE

    var/tx = input(user, "Target X:", "Trebuchet", src.x) as null|num
    if(isnull(tx)) return TRUE
    var/ty = input(user, "Target Y:", "Trebuchet", src.y) as null|num
    if(isnull(ty)) return TRUE
    var/default_z = z
    if(default_z < 1 || default_z > world.maxz) default_z = 1
    var/tz = input(user, "Target Z (1..[world.maxz]):", "Trebuchet", default_z) as null|num
    if(isnull(tz)) return TRUE

    tx = round(tx); ty = round(ty); tz = round(tz)
    if(tx < 1 || ty < 1 || tz < 1 || tx > world.maxx || ty > world.maxy || tz > world.maxz)
        to_chat(user, span_warning("Координаты вне границ карты."))
        return TRUE

    var/turf/target = locate(tx, ty, tz)
    if(!target)
        to_chat(user, span_warning("Неверная целевая клетка."))
        return TRUE

    if(!columns_clear_between(src.x, src.y, z, tz))
        to_chat(user, span_warning("Над требушетом есть препятствия. Очистите уровни [min(z,tz)+1]..[max(z,tz)]."))
        return TRUE
    if(!columns_clear_between(tx, ty, tz, z))
        to_chat(user, span_warning("Над целью есть препятствия. Очистите уровни [min(z,tz)+1]..[max(z,tz)]."))
        return TRUE

    fire(user, target)
    return TRUE

/obj/structure/trebuchet/proc/fire(mob/living/user, turf/target)
    if((!loaded && !loaded_mob) || !target) return
    last_fire = world.time

    var/obj/effect/trebuchet_marker/M = new(target)
    M.time_left_ds = impact_delay / 10
    M.started = 1
    M.update_maptext()

    if(fire_sound) playsound(src, fire_sound, 80, FALSE)
    visible_message(span_warning("[src] launches its payload!"))

    var/path_ammo = loaded ? loaded_ammo_path : null
    var/mob/living/payload_mob = loaded_mob
    loaded = FALSE
    loaded_ammo_path = null
    loaded_mob = null
    update_icon()

    addtimer(CALLBACK(src, PROC_REF(resolve_impact), target, path_ammo, payload_mob), impact_delay)


/********************************

ебучий маркет

*******************/

/obj/structure/trebuchet/proc/resolve_impact(turf/T, path_type, mob/living/payload_mob)
    if(!T) return

    if(payload_mob)
        resolve_impact_mob(T, payload_mob)
    else
        switch(path_type)
            if(/obj/item/trebuchet_ammo/explosive)
                explosion(T, devastation_range = 6, heavy_impact_range = 8, light_impact_range = 10, flame_range = 5, smoke = TRUE, soundin = pick('sound/misc/explode/bottlebomb (1).ogg','sound/misc/explode/bottlebomb (2).ogg'))
                damage_floor_disk(T, 6)
            if(/obj/item/trebuchet_ammo/flame)
                explosion(T, devastation_range = 0, heavy_impact_range = 0, light_impact_range = 0, flame_range = 7, smoke = FALSE)
            if(/obj/item/trebuchet_ammo/cluster)
                cluster_barrage(T, 10)
            else
                explosion(T, devastation_range = 1, heavy_impact_range = 2, light_impact_range = 3, flame_range = 0, smoke = FALSE)
    for(var/obj/effect/trebuchet_marker/M in T)
        qdel(M)
/obj/structure/trebuchet/proc/resolve_impact_mob(turf/T, mob/living/V)
    if(!T || !V) return
    if(hasvar(V, "buckled") && V.buckled == src && hascall(V, "unbuckle_mob")) //я не ебу потом исправлю
        V.unbuckle_mob(TRUE)
    V.forceMove(T)
    add_mob_blood(V)
    spawn_gibs_ring(T, 1, 8)
    if(hascall(V, "emote")) V.emote("scream")
    if(ishuman(V))
        var/mob/living/carbon/human/H = V
        var/list/zones = list(
            BODY_ZONE_HEAD, BODY_ZONE_CHEST,
            BODY_ZONE_L_ARM, BODY_ZONE_R_ARM,
            BODY_ZONE_L_LEG, BODY_ZONE_R_LEG
        )
        for(var/i = 1 to 3)
            if(!length(zones)) break
            var/zone = pick(zones); zones -= zone
            H.apply_damage(200, BRUTE, zone, H.run_armor_check(zone, "blunt", damage = 200))
    else
        for(var/i = 1 to 3)
            V.apply_damage(200, BRUTE)

    // can make it break the floor under impact because its funny
    // break_floor_disk(T, 1)


/*****************************************
 * FLUFF 
 ***********************************/

/obj/structure/trebuchet/proc/spawn_gibs_ring(turf/center, radius = 1, density = 8)
    if(!center) return
    var/placed = 0
    for(var/turf/T in range(radius, center))
        if(T == center) continue
        if(placed >= density) break
        if(prob(70))
            new /obj/effect/decal/cleanable/blood/gibs(T)
            placed++

/obj/structure/trebuchet/proc/damage_floor_disk(turf/center, radius)
    if(!center || radius <= 0) return
    for(var/turf/T in range(radius, center))
        if(T.z != center.z) continue
        if(istype(T, /turf/open/floor))
            var/turf/open/floor/F = T
            F.take_damage(500, BRUTE, "blunt", 0)

/obj/structure/trebuchet/proc/break_floor_disk(turf/center, radius)
    if(!center || radius <= 0) return
    for(var/turf/T in range(radius, center))
        if(T.z != center.z) continue
        if(istype(T, /turf/open/floor))
            var/turf/open/floor/F = T
            if(F) { F.make_plating(); continue }
        if(hascall(T, "ScrapeAway"))
            call(T, "ScrapeAway")(flags = CHANGETURF_INHERIT_AIR)

/obj/structure/trebuchet/proc/cluster_barrage(turf/center, size)
    if(!center) return
    var/half = max(round(size/2), 1)
    var/blasts = 8
    for(var/i = 1 to blasts)
        var/dx = center.x + rand(-half, half)
        var/dy = center.y + rand(-half, half)
        dx = CLAMP(dx, 1, world.maxx)
        dy = CLAMP(dy, 1, world.maxy)
        var/turf/T = locate(dx, dy, center.z)
        if(T)
            explosion(T, devastation_range = 0, heavy_impact_range = 1, light_impact_range = 2, flame_range = 0, smoke = FALSE)
