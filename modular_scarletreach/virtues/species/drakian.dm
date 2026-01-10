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
	desc = "My blood is blessed... lesser beings such as kobolds will do nicely for my hoard, being around them and protecting them satisifies some primal instinct. My hoard will grow with my horde.\nConditional buffs based on if you have a hoard of gold AND a horde of kobolds.\nAdds a new verb to recruit kobolds into your horde to hoard your gold."
	custom_text = "Only available to drakians."
	required_virtues = list(/datum/virtue/racial/drakian/hoard_keeper)
	races = list(
		/datum/species/dracon,
	)
/datum/virtue/racial/drakian/ember_blooded/apply_to_human(mob/living/carbon/human/recipient)
	recipient.apply_status_effect(/datum/status_effect/ember_blooded)
	recipient.verbs |= /mob/living/carbon/human/proc/recruit_kobold
	recipient.verbs |= /mob/living/carbon/human/proc/banish_kobold

/mob/living/COOLDOWN_DECLARE(recruit_kobold_cooldown)

// Verbs
/mob/living/carbon/human/proc/banish_kobold()
	set name = "Banish Kobold from Horde"
	set category = "IC"

	var/datum/status_effect/ember_blooded/hoard_master = has_status_effect(/datum/status_effect/ember_blooded)
	if(hoard_master.servants.len)
		var/choice = input(src, "Pick a kobold to abandon.", "Emberblood Servitude") in hoard_master.servants
		var/mob/living/target = choice
		if(!isliving(target) || QDELETED(target)) // mob has since been deleted/destroyed, skip
			hoard_master.servants -= target
			to_chat(src, span_boldwarning("The one I was trying to banish disappeared?!"))
			return
		hoard_master.servants -= target
		target.verbs -= /mob/living/carbon/human/proc/leave_horde
		REMOVE_TRAIT(target, TRAIT_EMBERBLOOD_HORDE, "ember_blooded")
		to_chat(src, span_boldwarning("I banish [target] from my horde."))
	else
		to_chat(src, span_boldwarning("I have no horde, who am I to banish, the air?"))

/mob/living/carbon/human/proc/recruit_kobold()
	set name = "Recruit nearby Kobolds"
	set category = "IC"
	if(!COOLDOWN_FINISHED(src, recruit_kobold_cooldown))
		return FALSE
	var/list/kobolds_nearby = list()
	for(var/mob/living/carbon/human/L in hearers(7, src))
		if(L == src)
			continue
		if(L.stat)
			continue
		if(istype(L.dna.species, /datum/species/kobold))
			if(!HAS_TRAIT(L, TRAIT_EMBERBLOOD_HORDE))
				kobolds_nearby += L
	if(!kobolds_nearby.len)
		to_chat(src, span_boldwarning("There were no kobolds nearby that were recruitable..."))
		return
	COOLDOWN_START(src, recruit_kobold_cooldown, 5 SECONDS)
	var/choice = input(src, "Pick a possible recruit.", "Emberblood Servitude") in kobolds_nearby
	var/mob/living/target = choice
	if(!isliving(target) || QDELETED(target)) // mob has since been deleted/destroyed, skip
		to_chat(src, span_boldwarning("My recruitment attempts failed! Where did they go?!"))
		return
	if(target.cmode)
		to_chat(src, span_boldwarning("They seem a little tense... perhaps I should wait for them to calm down."))
		return
	var/user_loc = get_turf(src)
	if(get_dist(get_turf(target), user_loc) <= 7)
		// var/prompt = tgui_alert(target, "Do you wish to serve [src]?", "DRAKIAN HORDE", list("MAKE IT SO", "I RESCIND"))
		// if(prompt != "MAKE IT SO")
		// 	return
		var/datum/status_effect/ember_blooded/hoard_master = has_status_effect(/datum/status_effect/ember_blooded)
		if(hoard_master)
			hoard_master.servants += target
			target.apply_status_effect(/datum/status_effect/ember_blooded_horde)
			var/datum/status_effect/ember_blooded_horde/servant = target.has_status_effect(/datum/status_effect/ember_blooded_horde)
			servant.hoard_master = src
			target.playsound_local(target, 'sound/misc/subtle_emote.ogg', 100)
			target.verbs |= /mob/living/carbon/human/proc/leave_horde
			ADD_TRAIT(target, TRAIT_EMBERBLOOD_HORDE, "ember_blooded")
		else
			to_chat(src, span_boldwarning("Some other force stopped me from recruiting them!"))
	else
		to_chat(src, span_boldwarning("They moved away... blasted, squirmy little buggers."))
	return

/mob/living/carbon/human/proc/leave_horde()
	set name = "Leave Horde"
	set category = "IC"

	if(!HAS_TRAIT(src, TRAIT_EMBERBLOOD_HORDE))
		to_chat(src, span_boldwarning("I belong to no horde..."))
		verbs -= /mob/living/carbon/human/proc/leave_horde
		return
	var/prompt = tgui_alert(target, "Do you wish to leave the horde?", "DRAKIAN HORDE", list("MAKE IT SO", "I RESCIND"))
	if(prompt != "MAKE IT SO")
		return
	var/datum/status_effect/ember_blooded_horde/servant = has_status_effect(/datum/status_effect/ember_blooded_horde)
	if(servant.hoard_master)
		var/datum/status_effect/ember_blooded/hoard_keeper = servant.hoard_master.has_status_effect(/datum/status_effect/ember_blooded)
		hoard_keeper.servants -= src
	to_chat(src, span_boldwarning("I abandon my horde, leaving them to fend against the world..."))
	verbs -= /mob/living/carbon/human/proc/leave_horde
	REMOVE_TRAIT(src, TRAIT_EMBERBLOOD_HORDE, "ember_blooded")

// Status effects and buffs
/datum/status_effect/ember_blooded
	id = "ember_blooded"
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = null
	tick_interval = 5 SECONDS
	/// List of kobolds that serve under the drakian.
	var/list/servants = list()

/datum/status_effect/ember_blooded_horde
	id = "ember_blooded_horde"
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = null
	tick_interval = 15 SECONDS
	/// The master of the horde
	var/mob/living/hoard_master
	COOLDOWN_DECLARE(initial_delay)

/datum/status_effect/ember_blooded_horde/on_apply()
	. = ..()
	COOLDOWN_START(src, initial_delay, tick_interval)

/datum/status_effect/ember_blooded_horde/tick(wait)
	if(!COOLDOWN_FINISHED(src, initial_delay))
		return
	if(isnull(hoard_master))
		owner.remove_status_effect(src)
	if(!HAS_TRAIT(owner, TRAIT_EMBERBLOOD_HORDE))
		owner.remove_status_effect(src)
		to_chat(owner, span_boldwarning("I have been banished or left my horde... It's so lonely."))

/datum/status_effect/ember_blooded/tick(wait)
	if(owner.stat)
		return
	if(!servants.len)
		return
	var/list/kobolds_nearby = list()
	for(var/mob/living/carbon/human/L in hearers(7, owner))
		if(L == owner)
			continue
		if(L.stat)
			continue
		if(istype(L.dna.species, /datum/species/kobold))
			if(HAS_TRAIT(L, TRAIT_EMBERBLOOD_HORDE) && (L in servants))
				kobolds_nearby += L
	var/buffed = FALSE
	if(kobolds_nearby.len)
		buffed = owner.has_status_effect(/datum/status_effect/hoard_keeper_buff)
		if(buffed)
			owner.apply_status_effect(/datum/status_effect/ember_blooded_buff/drakian/hoard_keeper)
		else
			owner.apply_status_effect(/datum/status_effect/ember_blooded_buff/drakian)
		owner.add_stress(/datum/stressevent/ember_blooded)
	for(var/mob/living/carbon/human/K in kobolds_nearby)
		if(buffed)
			K.apply_status_effect(/datum/status_effect/ember_blooded_buff/kobold/hoard_keeper)
		else
			K.apply_status_effect(/datum/status_effect/ember_blooded_buff/kobold)
		K.add_stress(/datum/stressevent/ember_blooded)

/datum/status_effect/ember_blooded_buff
	id = "ember_blooded_buff"
	duration = 15 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/buff/ember_blooded
	var/outline_color = "#ebcf34"

/datum/status_effect/ember_blooded_buff/on_apply()
	. = ..()
	var/filter = owner.get_filter("ember_blooded_filter")
	if(!filter)
		owner.add_filter("ember_blooded_filter", 2, list("type" = "outline", "color" = "[outline_color]", "alpha" = 60, "size" = 1))

/datum/status_effect/ember_blooded_buff/on_remove()
	. = ..()
	owner.remove_filter("ember_blooded_filter")
	owner.update_damage_hud()

/datum/status_effect/ember_blooded_buff/kobold
	id = "ember_blooded_buff_kobold"
	effectedstats = list(
		STATKEY_END = 1,
		STATKEY_CON = 1,
	)

/datum/status_effect/ember_blooded_buff/kobold/hoard_keeper
	id = "ember_blooded_buff_kobold_hk"
	effectedstats = list(
		STATKEY_PER = -2, // Fanatic little kobolds too focused on their drakian loving lyfe
		STATKEY_END = 1,
		STATKEY_CON = 1,
		STATKEY_LCK = 4,
	)

/datum/status_effect/ember_blooded_buff/kobold/hoard_keeper/tick()
	var/obj/effect/temp_visual/heal/H = new /obj/effect/temp_visual/heal_rogue(get_turf(owner))
	H.color = outline_color

/datum/status_effect/ember_blooded_buff/kobold/hoard_keeper/on_apply()
	. = ..()
	owner.remove_status_effect(/datum/status_effect/ember_blooded_buff/kobold)

/datum/status_effect/ember_blooded_buff/drakian
	id = "ember_blooded_buff_drakian"
	duration = 10 SECONDS
	effectedstats = list( 
		STATKEY_END = 2,
		STATKEY_CON = 2,
	)

/datum/status_effect/ember_blooded_buff/drakian/hoard_keeper
	id = "ember_blooded_buff_drakian_hk"
	duration = 5 SECONDS
	effectedstats = list( // Why these crazy stats? Because they're required to lay down to even get the buff... It's a fat wyrm homie.
		STATKEY_END = 4,
		STATKEY_CON = 4, // See below. Phat.
		STATKEY_STR = 2,
		STATKEY_SPD = -4, // Fat gold loving bastard.
	)

/datum/status_effect/ember_blooded_buff/drakian/hoard_keeper/on_apply()
	. = ..()
	owner.remove_status_effect(/datum/status_effect/ember_blooded_buff/drakian)

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

/atom/movable/screen/alert/status_effect/buff/ember_blooded
	name = "Horde Mentality"
	desc = "Being in a horde makes me feel at home..."
	icon_state = "buff"

// Stress events
/datum/stressevent/ember_blooded
	timer = 2 MINUTES
	stressadd = -5
	desc = "<span class='green'>For the hoard... and the horde!</span>"

#undef HOARD_KEEPER_LOW
#undef HOARD_KEEPER_HIGH