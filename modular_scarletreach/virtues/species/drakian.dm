#define HOARD_KEEPER_LOW 25
#define HOARD_KEEPER_HIGH 75
/datum/virtue/racial/drakian/hoard_keeper
	name = "Hoard Keeper"
	desc = "I find myself being drawn to large hoards of wealth and when I rest atop such a horde, I find it calming and a feeling of being blessed."
	custom_text = "Only available to drakians.\nWhen lying down on a tile that has alot of worth, you will receive a fortune buff, as well as heals you slowly as if by a miracle.\nIt's a brain trauma..."
	added_traits = list(TRAIT_HOARDKEEPER, TRAIT_SEEPRICES_SHITTY)
	races = list(
		/datum/species/dracon
	)
/datum/virtue/racial/drakian/hoard_keeper/apply_to_human(mob/living/carbon/human/recipient)
	// apply Hoard Keeper status effect
	recipient.apply_status_effect(/datum/status_effect/hoard_keeper)

/datum/virtue/racial/drakian/ember_blooded
	name = "Ember Blooded"
	desc = "My scales burn hotter than others. Fire does not merely spare me, it answers to me. When flame licks my scales, I feel a welcoming warmth instead of searing pain. However, it has come at a cost to my physical prowess.\n-2 STR"
	added_traits = list(TRAIT_NOFIRE)
	custom_text = "Only available to drakians."
	required_virtues = list(/datum/virtue/racial/drakian/hoard_keeper)
	races = list(
		/datum/species/dracon,
	)
/datum/virtue/racial/drakian/ember_blooded/apply_to_human(mob/living/carbon/human/recipient)
	recipient.change_stat(STATKEY_STR, -2)

// Status effects and buffs

/datum/status_effect/hoard_keeper
	id = "hoard_keeper"
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = null
	tick_interval = 5 SECONDS
	// You'll need growing amounts of mammon to satisfy the horde.
	/// Amount of mammons required to satisfy the Hoard Keeper
	var/required_mammons = 0
	/// Moderates the speed of mammon requirement growth. Only reset upon actually meeting the requirements.
	COOLDOWN_DECLARE(mammon_increase)

/datum/status_effect/hoard_keeper/on_creation(mob/living/new_owner, ...)
	. = ..()
	COOLDOWN_START(src, mammon_increase, rand(15 MINUTES, 25 MINUTES))
	required_mammons = ceil(rand(HOARD_KEEPER_LOW, HOARD_KEEPER_HIGH))

/datum/status_effect/hoard_keeper/tick(wait)
	if(owner.resting) // Resting
		// Gets the sell value of all items on this tile.
		var/turf/T = get_turf(owner)
		var/totalvalue = 0
		for(var/obj/O in T.contents)
			if(O.sellprice)
				totalvalue += O.get_real_price()
		var/has_status = !owner.has_status_effect(/datum/status_effect/hoard_keeper_buff)
		if(totalvalue > required_mammons)
			if(COOLDOWN_FINISHED(src, mammon_increase))
				to_chat(owner, span_warning("My greed grows... MORE... MORE MORE!!!"))
				required_mammons += ceil(rand(HOARD_KEEPER_LOW, HOARD_KEEPER_HIGH))
				COOLDOWN_START(src, mammon_increase, rand(15 MINUTES, 25 MINUTES))
				return // Ensure that we meet the new requirements.
			if(has_status)
				to_chat(owner, span_warning("My greed is satisfied..."))
			owner.apply_status_effect(/datum/status_effect/hoard_keeper_buff)
		else
			if(!has_status)
				to_chat(owner, span_warning("My wealth... WHERE DID IT GO?!!"))
			owner.remove_status_effect(/datum/status_effect/hoard_keeper_buff)
	else
		owner.remove_status_effect(/datum/status_effect/hoard_keeper_buff)

/datum/status_effect/hoard_keeper_buff
	id = "hoard_keeper_buff"
	duration = -1 // Infinite
	alert_type = /atom/movable/screen/alert/status_effect/buff/healing/hoard_keeper
	effectedstats = list(
		STATKEY_LCK = 4,
	)
	var/healing_on_tick = 3

/datum/status_effect/hoard_keeper_buff/on_apply()
	. = ..()
	var/filter = owner.get_filter("hoard_keeper_filter")
	if(!filter)
		owner.add_filter("hoard_keeper_filter", 2, list("type" = "outline", "color" = "#c42424", "alpha" = 60, "size" = 1))
	var/list/wCount = owner.get_wounds()
	if(wCount.len > 0) // Shamelessly stolen from miracle healing in roguebuffs.dm
		var/pain_killed = FALSE //to see if we did actually painkill something
		for(var/datum/wound/ouchie in wCount)
			if(!ouchie.pain_reduced)
				ouchie.pain_reduced = TRUE //halve the pain of our wounds but only once to avoid perma spamming
				ouchie.woundpain /= 2
				pain_killed = TRUE
		if(pain_killed)
			to_chat(owner, span_notice("The healing aura soothes my wounds' pain."))
	return TRUE

/datum/status_effect/hoard_keeper_buff/on_remove()
	owner.remove_filter("hoard_keeper_filter")
	owner.update_damage_hud()

/datum/status_effect/hoard_keeper_buff/tick()
	var/obj/effect/temp_visual/heal/H = new /obj/effect/temp_visual/heal_rogue(get_turf(owner))
	H.color = "#FF0000"
	var/list/wCount = owner.get_wounds()
	if(owner.blood_volume < BLOOD_VOLUME_NORMAL)
		owner.blood_volume = min(owner.blood_volume+healing_on_tick, BLOOD_VOLUME_NORMAL)
	if(wCount.len > 0)
		owner.heal_wounds(healing_on_tick)
		owner.update_damage_overlays()
	if(HAS_TRAIT(owner, TRAIT_SIMPLE_WOUNDS))
		owner.simple_bleeding = max(0, owner.simple_bleeding-(healing_on_tick/2))
	owner.adjustBruteLoss(-healing_on_tick, 0)
	owner.adjustFireLoss(-healing_on_tick, 0)
	owner.adjustOxyLoss(-healing_on_tick, 0)
	owner.adjustToxLoss(-healing_on_tick, 0)
	owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, -healing_on_tick)
	owner.adjustCloneLoss(-healing_on_tick, 0)
	owner.energy_add(10) // Extra energy refill from being on a large sum of MONIE

/atom/movable/screen/alert/status_effect/buff/healing/hoard_keeper
	name = "Hoard Warmth"
	desc = "You feel a warm sense of pride and accomplishment."
	icon_state = "buff"

#undef HOARD_KEEPER_LOW
#undef HOARD_KEEPER_HIGH