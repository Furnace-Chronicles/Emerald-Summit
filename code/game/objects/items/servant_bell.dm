/obj/item/servant_bell
	name = "service bell"
	desc = "Summon a servant to you. While ineffective against those who live in death, the latent silver in this bell resonates its chime in the minds of those who serve you."
	icon = 'icons/roguetown/items/misc.dmi'
	//icon_state = "servantbell"
	detail_tag = "_detail"
	slot_flags = ITEM_SLOT_HIP
	w_class = WEIGHT_CLASS_SMALL
	detail_color = CLOTHING_BLUE

	dropshrink = 0.7
	grid_height = 32
	grid_width = 32

	var/hear_distance = 40 // Might need to be adjusted later.
	// if other roles needed these it can be subtyped with this. in the future it might be better to bind these
	// to players but that's not really necessary atm
	var/list/servant_types = list(/datum/job/roguetown/butler, /datum/job/roguetown/servant)

	COOLDOWN_DECLARE(nearby_ring_bell)
	var/nearby_cooldown = 5 SECONDS
	COOLDOWN_DECLARE(ring_bell_noble)
	var/noble_cooldown = 1 MINUTES
	COOLDOWN_DECLARE(ring_bell)
	var/cooldown = 3 MINUTES

/obj/item/servant_bell/attack_self(mob/living/user, params)
	. = ..()
	if(HAS_TRAIT(user, TRAIT_NOBLE))
		if(COOLDOWN_FINISHED(src, ring_bell_noble))
			ring_bell(user)
			COOLDOWN_START(src, ring_bell_noble, noble_cooldown)
			COOLDOWN_START(src, nearby_ring_bell, nearby_cooldown)
			return
	else if(COOLDOWN_FINISHED(src, ring_bell))
		ring_bell(user)
		COOLDOWN_START(src, ring_bell, cooldown)
		COOLDOWN_START(src, nearby_ring_bell, nearby_cooldown)
		return

	//A fake ring that doesnt ping all the servants if we're on cooldown
	if(COOLDOWN_FINISHED(src, nearby_ring_bell))
		nearby_ring_bell(user)
		COOLDOWN_START(src, nearby_ring_bell, nearby_cooldown)
		//resets our cooldowns to the minimum here so we can't double up and do weird stuff
		if(COOLDOWN_TIMELEFT(src, ring_bell_noble) < nearby_cooldown)
			COOLDOWN_START(src, ring_bell_noble, nearby_cooldown)
		if(COOLDOWN_TIMELEFT(src, ring_bell) < nearby_cooldown)
			COOLDOWN_START(src, ring_bell, nearby_cooldown)


//just the local sound
/obj/item/servant_bell/proc/nearby_ring_bell(mob/living/user)
	// This sound was also done by fem_tanyl
	playsound(src, 'sound/items/servant_bell.ogg', 100, TRUE)

/obj/item/servant_bell/proc/ring_bell(mob/living/user)
	user.visible_message("[user] rings [src].")
	nearby_ring_bell(user)
	var/turf/origin_turf = get_turf(src)
	var/list/originMultiZ = get_multiz_accessible_levels(origin_turf.z)
	for(var/mob/living/player in GLOB.player_list)
		if(player.stat == DEAD)
			continue
		if(isbrain(player))
			continue
		//if(player == user)
		//	continue
		if(!(player.z in originMultiZ))
			continue
		var/jobFound = FALSE
		for(var/sType in servant_types)
			if(istype(player.mind.assigned_role, sType))
				jobFound = TRUE
		if(!jobFound)
			continue
		if(!player.can_hear())
			continue

		var/distance = get_dist(player, origin_turf)
		if(distance > hear_distance)
			continue
		player.apply_status_effect(/datum/status_effect/signal_horn/servant_bell, null, origin_turf)
		var/dirText = ""
		if(player.z > origin_turf.z)
			dirText = " above me"
		if(player.z < origin_turf.z)
			dirText = " below me"

		//sound played for other players, by fem_tanyl !!!1!!
		to_chat(player, span_warning("I hear a service bell being rang[dirText]."))
		if(distance <= 7)
			continue
		player.playsound_local(get_turf(player), 'sound/items/servant_bell.ogg', 35, FALSE, pressure_affected = FALSE)

/datum/status_effect/signal_horn/servant_bell
	id = "servant bell indicator"
	duration = 15 SECONDS
	//alert_type = /atom/movable/screen/alert/status_effect/servant_bell

/atom/movable/screen/alert/status_effect/servant_bell
	name = "Servant Bell"
	desc = "I've been summoned by the bell."
	//icon_state = "servant_bell"
