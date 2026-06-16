/*
The various projectiles used by the bombard.
Later, we'll get proper cannonballs or whatever for them to fire.
For the moment, just small 'charges'.
Listed as 'cannonballs' because we'll just differentiate via var later.
When? Whenever I get to it.
Additionally, these differ from the concepts, because I wish to see them in practice first.
 - Carl
*/
//This is a 'solid shot'. Does nothing, as of now.
/obj/item/cannonball
	name = "solid shot"
	desc = "A bombard charge capped by a plain iron slug. The simplest sort - no alchemy, no cleverness, just a dead weight that falls back to earth with a thunderous crack. Little more than a blank."
	icon = 'icons/roguetown/weapons/stationary/bombard_projectiles.dmi'
	icon_state = "basic"

/obj/item/cannonball/proc/detonate(turf/T)
	loud_message("An explosion echos in the ears of those whom hear it", hearing_distance = 32)
	forceMove(T)

//HE charge. This WILL delimb and cause many issues.
/obj/item/cannonball/explosive
	name = "high-explosive shell"
	desc = "A flat-nosed bombard charge packed to bursting with smokepowder. It detonates on landing in a storm of fire and splinters, tearing limb from body. Handle it with the gravest care."
	icon_state = "explosive"

/obj/item/cannonball/explosive/detonate(turf/T)
	..()
	explosion(T, 2, 4, 6, 8)

//Flare charge. Blinds in a wide radius.
//Intended to alert to number of players in area, but I'll do that later.
/obj/item/cannonball/flare
	name = "flare shell"
	desc = "A bombard charge bound in copper bands beneath a strange, luminous nose. On bursting it floods the sky with a blinding glare that sears the eyes of any who look upon it. Good for signalling - or for ruining an ambush."
	icon_state = "flare"

/obj/item/cannonball/flare/detonate(turf/T)
	..()
	for(var/mob/living/carbon/human/L in orange(24,T))
		L.flash_act()
		L.blind_eyes(6)
	explosion(T, 0, 0, 0, 7)

//Incendiary charge. Drops a huge blanket of flame across a wide area.
/obj/item/cannonball/incendiary
	name = "incendiary shell"
	desc = "A bombard charge weeping a tarry, volatile substance. Touch a torch to it before firing and it will blanket a wide swath of ground in clinging, unquenchable flame. \
	Be quick - light it and load it at once, or it cooks off where it sits!"
	icon_state = "incendiary"
	var/prepared = FALSE
	var/time_to_go = 100

/obj/item/cannonball/incendiary/process()
	time_to_go--
	if(time_to_go <= 0)
		//Cook-off: you weren't quick enough and it went off where it sits. Detonate once at our turf
		//and delete it - do NOT keep ticking and re-detonating every fastprocess tick.
		detonate(get_turf(src))
		qdel(src)

/obj/item/cannonball/incendiary/fire_act()
	light()

/obj/item/cannonball/incendiary/proc/light()
	if(prepared)
		return
	START_PROCESSING(SSfastprocess, src)
	icon_state += "_active"
	prepared = TRUE
	playsound(loc, 'sound/items/firelight.ogg', 100)
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_hands()

/obj/item/cannonball/incendiary/extinguish()
	snuff()

/obj/item/cannonball/incendiary/proc/snuff()
	if(!prepared)
		return
	prepared = FALSE
	STOP_PROCESSING(SSfastprocess, src)
	playsound(loc, 'sound/items/firesnuff.ogg', 100)
	icon_state = "incendiary"
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_hands()

/obj/item/cannonball/incendiary/detonate(turf/T)
	STOP_PROCESSING(SSfastprocess, src)//Detonation ends the fuse - never keep ticking/re-detonating.
	..()
	if(prepared)
		explosion(T, light_impact_range = 1, flame_range = 4)
	else
		explosion(T, light_impact_range = 1, flame_range = 1)

/obj/item/cannonball/incendiary/Destroy()
	STOP_PROCESSING(SSfastprocess, src)//Safety: never leave a deleted shell in the processing list.
	return ..()

//SMOKE CHARGES
//The normal sort.
/obj/item/cannonball/smoke
	name = "smoke shell"
	desc = "A flat-nosed bombard charge that smothers the impact in a thick, choking bank of grey smoke. It blinds and bewilders far more than it kills - a screen to advance behind, or a curtain to slip away through."
	icon_state = "basic"

/obj/item/cannonball/smoke/detonate(turf/T)
	..()
	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(4, T, 0)
	smoke.start()
	explosion(T, 0, 0, 0, 3)

//The poison sort.
/obj/item/cannonball/smoke_poison
	name = "poison smoke shell"
	desc = "A flat-nosed bombard charge that vents a roiling cloud of sickly vapour. Any left breathing it will feel their own lungs turn against them. Outlawed wherever decent folk still hold sway."
	icon_state = "poison"

/obj/item/cannonball/smoke_poison/detonate(turf/T)
	..()
	var/datum/effect_system/smoke_spread/poison_gas/smoke_p = new
	smoke_p.set_up(2, T, 0)
	smoke_p.start()
	explosion(T, 0, 0, 0, 3)

//The emberwine sort.
/obj/item/cannonball/smoke_emberwine
	name = "emberwine shell"
	desc = "A needle-nosed bombard charge, poorly bound in cloth and heavy with a draught of emberwine. It scatters the burning spirit in a fine mist; those it touches will wish they had stayed sober and far from here."
	icon_state = "emberwine"

/obj/item/cannonball/smoke_emberwine/Initialize()
	create_reagents(50)
	var/list/warcrime = list(/datum/reagent/consumable/ethanol/beer/emberwine = 50)
	reagents.add_reagent_list(warcrime)
	. = ..()

/obj/item/cannonball/smoke_emberwine/detonate(turf/T)
	..()
	var/datum/reagents/R = src.reagents
	var/datum/effect_system/smoke_spread/chem/smoke_e = new
	smoke_e.set_up(R, 1, T, FALSE)
	smoke_e.start()
	explosion(T, 0, 0, 0, 3)

//The custom sort.
/obj/item/cannonball/smoke_custom
	name = "payload shell"
	desc = "A hollow, flat-nosed bombard charge built to be filled with a draught of your own choosing before firing. Empty, it carries only a meagre puff of smoke - so pour something nastier in first."
	icon_state = "anychem_empty"
	possible_item_intents = list(INTENT_POUR, /datum/intent/fill, INTENT_SPLASH, INTENT_GENERIC)//ES: no INTENT_FILL define, use the raw path

/obj/item/cannonball/smoke_custom/update_icon()
	..()
	cut_overlays()
	if(reagents.total_volume > 0)
		var/mutable_appearance/internal = mutable_appearance('icons/roguetown/weapons/stationary/bombard_projectiles.dmi', "anychem_full_overlay")
		internal.color = mix_color_from_reagents(reagents.reagent_list)
		internal.alpha = mix_alpha_from_reagents(reagents.reagent_list)
		add_overlay(internal)
		icon_state = "anychem_full"
	else
		icon_state = "anychem_empty"
	return

/obj/item/cannonball/smoke_custom/Initialize()
	create_reagents(50, DRAINABLE | REFILLABLE | AMOUNT_VISIBLE)
	. = ..()

//The shell isn't a reagent_containers, so let any container (potion, vial, flask) tipped onto it pour
//its payload in - just click the shell with the container in hand. Mirrors the normal pour: a proper
//do_after action (progress dots), transferring a little at a time rather than filling instantly.
/obj/item/cannonball/smoke_custom/attackby(obj/item/I, mob/living/user, params)
	if(I.reagents && I.reagents.total_volume)
		if(reagents.holder_full())
			to_chat(user, span_warning("\The [src] is already full."))
			return TRUE
		var/amount_per_transfer = 10
		if(istype(I, /obj/item/reagent_containers))
			var/obj/item/reagent_containers/RC = I
			amount_per_transfer = RC.amount_per_transfer_from_this
		user.visible_message(span_notice("[user] pours [I] into [src]."), \
						span_notice("I pour [I] into [src]."))
		for(var/i in 1 to 11)
			if(do_after(user, 8, target = src))
				if(!I.reagents.total_volume)
					break
				if(reagents.holder_full())
					break
				I.reagents.trans_to(src, amount_per_transfer, transfered_by = user)
				update_icon()
			else
				break
		return TRUE
	return ..()

/obj/item/cannonball/smoke_custom/detonate(turf/T)
	..()
	var/datum/reagents/R = src.reagents
	if(reagents.total_volume > 0)
		var/datum/effect_system/smoke_spread/chem/smoke_c = new
		smoke_c.set_up(R, 1, T, FALSE)
		smoke_c.start()
	else
		var/datum/effect_system/smoke_spread/smoke_s = new
		smoke_s.set_up(1, T, 0)
		smoke_s.start()
	explosion(T, 0, 0, 0, 3)

//CANISTER CHARGES
//The actual proper canister charge, which disperses a huge chunk of shrapnel.
/obj/item/cannonball/canister
	name = "canister shot"
	desc = "A bombard charge fitted with a fluted, hollow-sounding nose and crammed with jagged stones. It cracks open on landing and flings the lot outward in a lethal spray that buries itself in flesh. \
	Nasty thing, outlawed in all reasonable realms of the land..."
	icon_state = "braced"

/obj/item/cannonball/canister/detonate(turf/T)
	..()
	explosion(T, 0, 0, 1, 0)//A small, flashless blast where the shell cracks open...
	canister_detonate()//...then it sprays its rocks outward.

//A secondary type of 'canister' charge. Small explosions on all turfs in view.
/obj/item/cannonball/cluster
	name = "cluster shell"
	desc = "A bombard charge bundled from a dozen small impact grenades in place of a single nose. It scatters its bomblets across the whole of the impact ground, churning everything caught beneath. \
	Nasty thing, outlawed in all reasonable realms of the land..."
	icon_state = "cluster"

/obj/item/cannonball/cluster/detonate(turf/T)
	..()
	//A bundle of impact grenades: scatter tiny sub-blasts across the impact area so it saturates the
	//ground. The old version looped oviewers() (which returns MOBS, not turfs), so on open ground it
	//hit nothing and only flashed - now it peppers actual terrain regardless of who's standing there.
	var/list/area_turfs = RANGE_TURFS(4, T)
	if(!length(area_turfs))
		return
	for(var/i in 1 to 20)
		explosion(pick(area_turfs), 0, 0, 1, 0)//Tiny, flashless sub-blast.

/*
The canister effect: the shell bursts and flings a fistful of real forks and spoons in every
direction - cutlery that buries itself in flesh and has to be torn out. A genuine warcrime.
*/
/obj/item/cannonball/proc/canister_detonate(atom/target)
	var/turf/epicenter = get_turf(src)
	if(!epicenter)
		return
	var/list/edge = RANGE_TURFS(12, epicenter) - RANGE_TURFS(11, epicenter)
	if(!length(edge))
		return
	for(var/i in 1 to 20)
		var/obj/item/shrap = new /obj/item/natural/stone/shrapnel(epicenter)
		shrap.throw_at(pick(edge), 12, 3, null, spin = TRUE)//Fling it outward; it embeds in the first body it meets.

//Rock shrapnel - jagged stones flung from the canister, sharp enough to lodge in flesh and need
//tearing out (or they fall out). Named distinctly from real stones: they share the stone icon, so
//without a different name players mistake spent shrapnel for craftable stones and wonder why it won't.
/obj/item/natural/stone/shrapnel
	name = "shrapnel"
	desc = "A jagged shard of stone flung from a canister shell. Too rough and irregular to be worked like a proper stone."
	embedding = list("embed_chance" = 60, "embedded_pain_multiplier" = 3, "embedded_impact_pain_multiplier" = 5, "embedded_fall_chance" = 8, "embedded_unsafe_removal_time" = 25, "embedded_ignore_throwspeed_threshold" = 1)

//Keep the varied rock look but skip the random naming/intents/personality lore for disposable shrapnel.
/obj/item/natural/stone/shrapnel/stone_lore()
	icon_state = "stone[rand(1,5)]"
