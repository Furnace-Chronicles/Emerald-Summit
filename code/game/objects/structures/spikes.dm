/**************
 * ITEM 
 ********************************/

/obj/item/siege_spikes
    name = "spikes"
    desc = "A handful of sharp spikes. Scatter them on the floor."
    icon = 'icons/roguetown/items/siege.dmi'
    icon_state = "metalspikes"
    w_class = WEIGHT_CLASS_TINY

    attack_self(mob/user)
        var/turf/T = get_turf(user)
        if(T) PlaceSpikes(T, user)

    afterattack(atom/target, mob/user, proximity, params)
        if(proximity && isturf(target))
            PlaceSpikes(target, user)

    throw_impact(atom/hit_atom, datum/thrownthing/thr)
        ..()
        var/turf/T = get_turf(src)
        if(T) PlaceSpikes(T)

/obj/item/siege_spikes/proc/PlaceSpikes(turf/T, mob/user)
    if(locate(/obj/structure/trap/spikes) in T)
        if(user) to_chat(user, span_notice("There are already spikes here."))
        return
    new /obj/structure/trap/spikes(T)
    if(user) visible_message(span_notice("[user] scatters spikes on the floor."))
    qdel(src)


/****************************************
 * TRAP 
 *******************************/

/obj/structure/trap/spikes
    name = "spikes"
    desc = "Scattered sharp spikes."
    icon = 'icons/roguetown/items/siege.dmi'
    icon_state = "spikesdropped"
    time_between_triggers = 10
    max_integrity = 200
    density = FALSE
    anchored = TRUE
    trap_damage = 50  

/obj/structure/trap/spikes/trap_effect(mob/living/L) //shit code
    add_mob_blood(L)
    if(ishuman(L))
        var/mob/living/carbon/human/H = L
        var/obj/item/shoes = null
        if(hasvar(H, "shoes"))
            shoes = H.shoes
        if(!shoes && hascall(H, "get_item_by_slot"))
            shoes = H.get_item_by_slot(SLOT_SHOES)
        if(shoes)
            if(hascall(shoes, "take_damage"))
                shoes.take_damage(trap_damage)
            else if(hasvar(shoes, "obj_integrity"))
                shoes.obj_integrity = max(shoes.obj_integrity - trap_damage, 0)
            if(is_item_broken(shoes))
                maybe_disable_boots(shoes, H)
                var/def_zone = pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
                var/did = H.apply_damage(trap_damage, BRUTE, def_zone, H.run_armor_check(def_zone, "stab", damage = trap_damage))
                if(did && hascall(H, "emote"))
                    H.emote("scream")  
                to_chat(H, span_userdanger("The spikes pierce through your ruined footwear!"))
            else
                to_chat(H, span_warning("Your footwear is shredded by spikes!"))
            return

        var/def_zone_bare = pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
        to_chat(H, span_danger("<B>You step on spikes!</B>"))
        L.apply_damage(trap_damage, BRUTE, def_zone_bare, L.run_armor_check(def_zone_bare, "stab", damage = trap_damage))
        return

    L.apply_damage(trap_damage, BRUTE)


/// fluff

/obj/structure/trap/spikes/proc/is_item_broken(obj/item/I)
    if(!I) return FALSE
    if(hasvar(I, "obj_integrity"))
        return I.obj_integrity <= 0
    return FALSE

/obj/structure/trap/spikes/proc/maybe_disable_boots(obj/item/I, mob/living/carbon/human/H)
    if(!I) return
    if(hasvar(I, "armor") && islist(I.armor))
        var/list/A = I.armor
        for(var/k in A) A[k] = 0
    if(hascall(I, "update_icon")) I.update_icon() //тесты нахуй
    if(H) to_chat(H, span_warning("Your ruined footwear no longer protects you!"))
