/datum/patron/inhumen
	name = null
	associated_faith = /datum/faith/inhumen
	undead_hater = FALSE
	var/crafting_recipes = list(/datum/crafting_recipe/roguetown/structure/zizo_shrine)			//Allows construction of unique bad shrine.
	profane_words = list("cock","dick","fuck","shit","pussy","cuck","cunt","asshole", "pintle")	//Same as master but 'Zizo' is allowed now.
	confess_lines = list(
		"PSYDON IS THE DEMIURGE!",
		"THE TEN ARE WORTHLESS COWARDS!",
		"THE TEN ARE DECEIVERS!",
	)

/datum/patron/inhumen/on_gain()
	. = ..()
	if(ishuman(usr))
		var/mob/living/carbon/human/H = usr
		if(H.mind)
			H.mind.teach_crafting_recipe(/datum/crafting_recipe/roguetown/structure/zizo_shrine)

/datum/patron/inhumen/zizo
	name = "Zizo"
	domain = "Progress, Undeath, Hubris, Left Hand Magicks"
	desc = "A once-mortal snow elf turned god. Her hubris in thinking she could harvest lux from the planet itself led to the elimination of her entire race. Her works are still used to this dae in some cases."
	worshippers = "Necromancers, Researchers, Warlocks, and the Undead"
	mob_traits = list(TRAIT_CABAL, TRAIT_ZIZOSIGHT, TRAIT_ZOMBIE_IMMUNE)
	miracles = list(/obj/effect/proc_holder/spell/targeted/touch/orison					= CLERIC_ORI,
					/obj/effect/proc_holder/spell/self/zizo_snuff						= CLERIC_T0,
					/obj/effect/proc_holder/spell/invoked/lesser_heal 					= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/blood_heal					= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/projectile/profane/miracle 	= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/raise_lesser_undead/miracle 	= CLERIC_T2,
					/obj/effect/proc_holder/spell/invoked/rituos/miracle 				= CLERIC_T3,
					/obj/effect/proc_holder/spell/invoked/wound_heal					= CLERIC_T4,
	)
	confess_lines = list(
		"PRAISE ZIZO!",
		"LONG LIVE ZIZO!",
		"ZIZO IS QUEEN!",
	)
	miracle_healing_lines = list(
		"Vital energies congeal about %TARGET!"
	)
	storyteller = /datum/storyteller/zizo

/datum/patron/inhumen/zizo/situational_bonus(mob/living/follower, mob/living/target)
	// set up a ritual pile of bones (or just cast near a stack of bones whatever) around us for massive bonuses
	var/situational_bonus = 0
	for (var/obj/item/natural/bone/O in oview(5, follower))
		situational_bonus += (0.5)
	for (var/obj/item/natural/bundle/bone/S in oview(5, follower))
		situational_bonus += (S.amount * 0.5)
	if (situational_bonus > 0)
		situational_bonus = min(situational_bonus, 5)
	return list((situational_bonus > 0), situational_bonus)

/datum/patron/inhumen/graggar
	name = "Graggar"
	domain = "God of Might Makes Right, Conquest, War, Brutality"
	desc = "Graggar is a ruthless god who exalts strength, domination, and the crushing of the weak. His followers do not seek honor or fairness, only victory and the right to rule through force. Mercy is weakness, and compassion is a lie for the feeble. Graggar demands conquest, subjugation, and the endless struggle for supremacy. He is worshipped by those who revel in cruelty, oppression, and the law of the strong."
	worshippers = "Tyrants, Warlords, Slavers, and the Cruel"
	mob_traits = list(TRAIT_HORDE, TRAIT_ORGAN_EATER)
	miracles = list(/obj/effect/proc_holder/spell/targeted/touch/orison					= CLERIC_ORI,
					/obj/effect/proc_holder/spell/self/graggar_bloodrage				= CLERIC_T0,
					/obj/effect/proc_holder/spell/invoked/lesser_heal 					= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/blood_heal					= CLERIC_T1,
					/obj/effect/proc_holder/spell/self/call_to_slaughter 				= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/projectile/blood_net 			= CLERIC_T2,
					/obj/effect/proc_holder/spell/invoked/revel_in_slaughter 			= CLERIC_T3,
					/obj/effect/proc_holder/spell/invoked/wound_heal					= CLERIC_T4,
	)
	confess_lines = list(
		"GRAGGAR IS THE BEAST I WORSHIP!",
		"THROUGH VIOLENCE, DIVINITY!",
		"THE GOD OF CONQUEST DEMANDS BLOOD!",
	)
	miracle_healing_lines = list(
		"A riotous roar of energy envelops %TARGET!"
	)
	storyteller = /datum/storyteller/graggar

/datum/patron/inhumen/graggar/situational_bonus(mob/living/follower, mob/living/target)
	// if you've got lingering toxin damage, you get healed more, but your bonus healing doesn't affect toxin
	// also this kind of sucks and isn't very graggary at all
	return list((follower.getToxLoss() > 0), 2.5)

/datum/patron/inhumen/matthios
	name = "Matthios"
	domain = "God of Exchange, Alchemy, Theft, and Greed"
	desc = "The Man who stole fire from the sun and used it in his pursuit of immortality; exchanging the knowledge of how to make fire with the lessers for safety in doing so. He guides those who live in the dark, away from the flame of civilization; and those who believe in his cause bring the wealth of the undeserving in the light to the deserving in the dark."
	worshippers = "Highwaymen, Alchemists, Downtrodden Peasants, and Merchants"
	mob_traits = list(TRAIT_COMMIE, TRAIT_MATTHIOS_EYES, TRAIT_CULTIC_THIEF)
	miracles = list(/obj/effect/proc_holder/spell/targeted/touch/orison					= CLERIC_ORI,
					/obj/effect/proc_holder/spell/invoked/appraise						= CLERIC_ORI,
					/obj/effect/proc_holder/spell/targeted/touch/lesserknock/miracle	= CLERIC_T0,
					/obj/effect/proc_holder/spell/invoked/transact						= CLERIC_T0,
					/obj/effect/proc_holder/spell/invoked/lesser_heal 					= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/blood_heal					= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/equalize						= CLERIC_T2,
					/obj/effect/proc_holder/spell/invoked/churnwealthy					= CLERIC_T3,
					/obj/effect/proc_holder/spell/invoked/wound_heal					= CLERIC_T4,
	)
	confess_lines = list(
		"MATTHIOS STEALS FROM THE WORTHLESS!",
		"MATTHIOS IS JUSTICE!",
		"MATTHIOS IS MY LORD!",
	)
	miracle_healing_lines = list(
		"Aureate embers coruscate around %TARGET!"
	)
	storyteller = /datum/storyteller/matthios

/datum/patron/inhumen/matthios/situational_bonus(mob/living/follower, mob/living/target)
	// other matthiosians benefit from our miracles more
	return list(HAS_TRAIT(target, TRAIT_COMMIE), 2.5)

/datum/patron/inhumen/baotha
	name = "Baotha"
	domain = "Goddess of Hedonism, Addiction, Anguish, and Heartbreak"
	desc = "The twin sister of Eora, fallen to disgrace. She brings comfort to those who can't find it elsewhere but the bottom of a bottle; and she tempts those who have lost much into her fold through offers of relief and pleasure, yet they soon find themselves unable to escape her grasp. Seen as a scorned lover by many, and followed by such."
	worshippers = "Widows, Gamblers, Addicts, and Scorned Lovers"
	mob_traits = list(TRAIT_DEPRAVED, TRAIT_CRACKHEAD)
	miracles = list(/obj/effect/proc_holder/spell/targeted/touch/orison					= CLERIC_ORI,
					/obj/effect/proc_holder/spell/invoked/baothavice					= CLERIC_T0,
					/obj/effect/proc_holder/spell/invoked/lesser_heal 					= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/blood_heal					= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/baothablessings				= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/projectile/blowingdust		= CLERIC_T2,
					/obj/effect/proc_holder/spell/invoked/painkiller					= CLERIC_T3,
					/obj/effect/proc_holder/spell/invoked/wound_heal					= CLERIC_T4,
	)
	confess_lines = list(
		"BAOTHA DEMANDS PLEASURE!",
		"LIVE, LAUGH, LOVE!",
		"BAOTHA IS MY JOY!",
	)
	miracle_healing_lines = list(
		"Lurid whispers entwine about %TARGET!"
	)
	storyteller = /datum/storyteller/baotha

/datum/patron/inhumen/baotha/situational_bonus(mob/living/follower, mob/living/target)
	// if we're high on drugs or drunk, our miracles are stronger
	var/situational_bonus = 0
	if (follower.has_status_effect(/datum/status_effect/buff/ozium) || follower.has_status_effect(/datum/status_effect/buff/moondust) || follower.has_status_effect(/datum/status_effect/buff/moondust_purest) || follower.has_status_effect(/datum/status_effect/buff/druqks) || follower.has_status_effect(/datum/status_effect/buff/starsugar))
		situational_bonus += 2.5
	if (follower.has_status_effect(/datum/status_effect/buff/drunk))
		situational_bonus += 1.5
	return list((situational_bonus > 0), situational_bonus)

/////////////////////////////////
// Does God Hear Your Prayer ? //
/////////////////////////////////

// Zizo - When the sun is blotted out, zchurch, bad-cross, or ritual chalk
/datum/patron/inhumen/zizo/can_pray(mob/living/follower)
	. = ..()
	// Allows prayer in the Zzzzzzzurch(!)
	if(istype(get_area(follower), /area/rogue/indoors/shelter/mountains))
		return TRUE
	// Allows prayer near EEEVIL psycross
	for(var/obj/structure/fluff/psycross/zizocross/cross in view(4, get_turf(follower)))
		if(cross.divine == TRUE)
			to_chat(follower, span_danger("That acursed cross interupts my prayers!"))
			return FALSE
		return TRUE
	// Allows prayer near a grave.
	for(var/obj/structure/closet/dirthole/grave/G in view(4, get_turf(follower)))
		return TRUE
	// Allows prayer during the sun being blotted from the sky.
	if(hasomen(OMEN_SUNSTEAL))
		return TRUE
	// Allows praying atop ritual chalk of the god.
	for(var/obj/structure/ritualcircle/zizo in view(1, get_turf(follower)))
		return TRUE
	to_chat(follower, span_danger("For Zizo to hear my prayers I must either be in the church of the abandoned, near an inverted psycross, atop a drawn Zizite symbol, or while the sun is blotted from the sky!"))
	return FALSE


// Graggar - When bleeding, near blood on ground, zchurch, bad-cross, or ritual chalk
/datum/patron/inhumen/graggar/can_pray(mob/living/follower)
	. = ..()
	// Allows prayer in the Zzzzzzzurch(!)
	if(istype(get_area(follower), /area/rogue/indoors/shelter/mountains))
		return TRUE
	// Allows prayer near EEEVIL psycross
	for(var/obj/structure/fluff/psycross/zizocross/cross in view(4, get_turf(follower)))
		if(cross.divine == TRUE)
			to_chat(follower, span_danger("That acursed cross interupts my prayers!"))
			return FALSE
		return TRUE
	// Allows prayer if actively bleeding.
	if(follower.bleed_rate > 0)
		return TRUE
	// Allows prayer near blood.
	for(var/obj/effect/decal/cleanable/blood in view(3, get_turf(follower)))
		return TRUE
	// Allows praying atop ritual chalk of the god.
	for(var/obj/structure/ritualcircle/graggar in view(1, get_turf(follower)))
		return TRUE
	to_chat(follower, span_danger("For Graggar to hear my prayers I must either be in the church of the abandoned, near an inverted psycross, near fresh blood or draw blood of my own!"))
	return FALSE

// Matthios - When near coin of at least 100 mammon, zchurch, bad-cross, or ritual talk
/datum/patron/inhumen/matthios/can_pray(mob/living/follower)
	. = ..()
	// Allows prayer in the Zzzzzzzurch(!)
	if(istype(get_area(follower), /area/rogue/indoors/shelter/mountains))
		return TRUE
	// Allows prayer near EEEVIL psycross
	for(var/obj/structure/fluff/psycross/zizocross/cross in view(4, get_turf(follower)))
		if(cross.divine == TRUE)
			to_chat(follower, span_danger("That acursed cross interupts my prayers!"))
			return FALSE
		return TRUE
	// Allows prayer if the user has more than 100 mammon on them.
	var/mammon_count = get_mammons_in_atom(follower)
	if(mammon_count >= 100)
		return TRUE
	// Spend 5/10 mammon to pray. Megachurch pastors be like.....
	var/obj/item/held_item = follower.get_active_held_item()
	var/helditemvalue = held_item.get_real_price()
	if(istype(held_item, /obj/item/roguecoin) && helditemvalue >= 5)
		qdel(held_item)
		return TRUE
	// Allows praying atop ritual chalk of the god.
	for(var/obj/structure/ritualcircle/matthios in view(1, get_turf(follower)))
		return TRUE
	to_chat(follower, span_danger("For Matthios to hear my prayers I must either be in the church of the abandoned, near an inverted psycross, flaunting wealth upon me of at least 100 mammon, or offer a coin of at least five mammon up to him!"))
	return FALSE

// Baotha
/datum/patron/inhumen/baotha/can_pray(mob/living/follower)
	. = ..()
	// Allows prayer in the Zzzzzzzurch(!)
	if(istype(get_area(follower), /area/rogue/indoors/shelter/mountains))
		return TRUE
	// Allows prayer near EEEVIL psycross
	for(var/obj/structure/fluff/psycross/zizocross/cross in view(4, get_turf(follower)))
		if(cross.divine == TRUE)
			to_chat(follower, span_danger("That acursed cross interupts my prayers!"))
			return FALSE
		return TRUE
	// Allows prayers in the bath house - whore.
	if(istype(get_area(follower), /area/rogue/indoors/town/bath))
		return TRUE
	// Allows prayers if actively high on drugs.
	if(follower.has_status_effect(/datum/status_effect/buff/ozium) || follower.has_status_effect(/datum/status_effect/buff/moondust) || follower.has_status_effect(/datum/status_effect/buff/moondust_purest) || follower.has_status_effect(/datum/status_effect/buff/druqks) || follower.has_status_effect(/datum/status_effect/buff/starsugar))
		return TRUE
	// Allows prayers if the user is drunk.
	if(follower.has_status_effect(/datum/status_effect/buff/drunk))
		return TRUE
	// Allows praying atop ritual chalk of the god.
	for(var/obj/structure/ritualcircle/baotha in view(1, get_turf(follower)))
		return TRUE
	to_chat(follower, span_danger("For Baotha to hear my prayers I must either be in the church of the abandoned, near an inverted psycross, within the town's bathhouse, or actively partaking in one of various types of nose-candy!"))
	return FALSE
