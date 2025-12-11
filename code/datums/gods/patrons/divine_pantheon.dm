/datum/patron/divine
	name = null
	associated_faith = /datum/faith/divine

/datum/patron/divine/astrata
	name = "Astrata"
	domain = "Twinned Goddess of the Sun, Day, and Order"
	desc = "The she-form of the Twinned Gods, the combined amalgam of single-bodied Astrata and Noc that opens her eyes at glorious Dae. Men bask under the gift of the Sun. A single form begets two Gods that shift at Dusk and Dawn but always endures, even at night."
	worshippers = "The Noble Hearted, Zealots and Farmers"
	mob_traits = list(TRAIT_APRICITY)
	miracles = list(/obj/effect/proc_holder/spell/targeted/touch/orison			= CLERIC_ORI,
					/obj/effect/proc_holder/spell/invoked/ignition				= CLERIC_T0,
					/obj/effect/proc_holder/spell/self/astrata_gaze				= CLERIC_T0,
					/obj/effect/proc_holder/spell/invoked/lesser_heal 			= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/blood_heal			= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/projectile/lightningbolt/sacred_flame_rogue	= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/heal					= CLERIC_T2,
					/obj/effect/proc_holder/spell/invoked/revive				= CLERIC_T3,
					/obj/effect/proc_holder/spell/invoked/wound_heal			= CLERIC_T4,
	)
	confess_lines = list(
		"ASTRATA IS MY LIGHT!",
		"ASTRATA BRINGS LAW!",
		"I SERVE THE GLORY OF THE SUN!",
	)
	miracle_healing_lines = list(
		"A wreath of gentle light passes over %TARGET!"
	)
	storyteller = /datum/storyteller/astrata

/datum/patron/divine/astrata/situational_bonus(mob/living/follower, mob/living/target)
	return list((GLOB.tod == "day"), 2)

/datum/patron/divine/noc
	name = "Noc"
	domain = "Twinned God of the Moon, Night, and Knowledge"
	desc = "The he-form of the Twinned Gods, the combined amalgam of single-bodied Noc and Astrata that opens his eyes during pondorous Night. He gifted man knowledge of divinity and magicks. A single form begets two Gods that shift at Dusk and Dawn but always endures, even at dae."
	worshippers = "Wizards and Scholars"
	mob_traits = list(TRAIT_NIGHT_OWL, TRAIT_DARKVISION)
	miracles = list(/obj/effect/proc_holder/spell/targeted/touch/orison			= CLERIC_ORI,
					/obj/effect/proc_holder/spell/invoked/noc_sight				= CLERIC_T0,
					/obj/effect/proc_holder/spell/targeted/touch/darkvision/miracle	= CLERIC_T0,
					/obj/effect/proc_holder/spell/invoked/lesser_heal 			= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/blood_heal			= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/invisibility/miracle	= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/blindness				= CLERIC_T2,
					/obj/effect/proc_holder/spell/self/noc_spell_bundle			= CLERIC_T3,
					/obj/effect/proc_holder/spell/invoked/wound_heal			= CLERIC_T4,
	)
	confess_lines = list(
		"NOC IS NIGHT!",
		"NOC SEES ALL!",
		"I SEEK THE MYSTERIES OF THE MOON!",
	)
	miracle_healing_lines = list(
		"A shroud of soft moonlight falls upon %TARGET!"
	)
	storyteller = /datum/storyteller/noc

/datum/patron/divine/noc/situational_bonus(mob/living/follower, mob/living/target)
	return list((GLOB.tod == "night"), 2)

/datum/patron/divine/dendor
	name = "Dendor"
	domain = "God of the Earth and Nature"
	desc = "The God of Wilds, born from Abyssor's feverish dreams. Spilt forth life from the oceans to land in a wild craze. The Father of Ground-Lyfe. Treefather."
	worshippers = "Druids, Beasts, Madmen"
	mob_traits = list(TRAIT_KNEESTINGER_IMMUNITY, TRAIT_LEECHIMMUNE)
	miracles = list(/obj/effect/proc_holder/spell/targeted/touch/orison			= CLERIC_ORI,
					/obj/effect/proc_holder/spell/invoked/spiderspeak 			= CLERIC_T0,
					/obj/effect/proc_holder/spell/targeted/blesscrop			= CLERIC_T0,
					/obj/effect/proc_holder/spell/invoked/lesser_heal 			= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/blood_heal			= CLERIC_T1,
					/obj/effect/proc_holder/spell/targeted/wildshape			= CLERIC_T2,
					/obj/effect/proc_holder/spell/targeted/beasttame			= CLERIC_T2,
					/obj/effect/proc_holder/spell/targeted/conjure_glowshroom	= CLERIC_T3,
					/obj/effect/proc_holder/spell/targeted/conjure_vines 		= CLERIC_T3,
					/obj/effect/proc_holder/spell/invoked/wound_heal			= CLERIC_T4,
					/obj/effect/proc_holder/spell/self/howl/call_of_the_moon	= CLERIC_T4,
	)
	confess_lines = list(
		"DENDOR PROVIDES!",
		"THE TREEFATHER BRINGS BOUNTY!",
		"I ANSWER THE CALL OF THE WILD!",
	)
	miracle_healing_lines = list(
		"A rush of primal energy spirals about %TARGET!"
	)
	storyteller = /datum/storyteller/dendor

/datum/patron/divine/dendor/situational_bonus(mob/living/follower, mob/living/target)
	var/list/natural_stuff = list(/obj/structure/flora/roguegrass, /obj/structure/flora/roguetree, /obj/structure/flora/rogueshroom, /obj/structure/soil, /obj/structure/flora/newtree, /obj/structure/flora/tree, /obj/structure/glowshroom)
	var/situational_bonus = 0
	// the more natural stuff around US, the more we heal
	for (var/obj/O in oview(5, follower))
		if (O in natural_stuff)
			situational_bonus = min(situational_bonus + 0.1, 2)
	for (var/obj/structure/flora/roguetree/wise/O in oview(5, follower))
		situational_bonus += 1.5
	return list((situational_bonus > 0), situational_bonus)

/datum/patron/divine/abyssor
	name = "Abyssor"
	domain = "The great dreamer, primordial father of the tides. The ancient one, the most warped and potent of the ten."
	desc = "The strongest of the Ten; when awakened, the world flooded for a thousand daes and a thousand nights before he was put to slumber. Resting fitfully did Dendor split from his skull like a gaping wound. Communes rarely with his followers, only offering glimpses in dreams. Gifted primordial Man water. "
	worshippers = "Men of the Sea, Primitive Aquatics"
	mob_traits = list(TRAIT_ABYSSOR_SWIM, TRAIT_SEA_DRINKER)
	miracles = list(/obj/effect/proc_holder/spell/targeted/touch/orison			= CLERIC_ORI,
					/obj/effect/proc_holder/spell/invoked/aquatic_compulsion	= CLERIC_T0,
					/obj/effect/proc_holder/spell/self/abyssor_wind				= CLERIC_T0,
					/obj/effect/proc_holder/spell/invoked/lesser_heal 			= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/blood_heal			= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/abyssor_bends			= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/abyssheal				= CLERIC_T2,
					/obj/effect/proc_holder/spell/invoked/call_mossback			= CLERIC_T3,
					/obj/effect/proc_holder/spell/invoked/wound_heal			= CLERIC_T4,
					/obj/effect/proc_holder/spell/invoked/call_dreamfiend		= CLERIC_T4,
					/obj/effect/proc_holder/spell/invoked/abyssal_infusion		= CLERIC_T4
	)
	confess_lines = list(
		"ABYSSOR COMMANDS THE WAVES!",
		"THE OCEAN'S FURY IS ABYSSOR'S WILL!",
		"I AM DRAWN BY THE PULL OF THE TIDE!",
	)
	miracle_healing_lines = list(
		"A mist of salt-scented vapour settles on %TARGET!"
	)

	storyteller = /datum/storyteller/abyssor

/datum/patron/divine/abyssor/situational_bonus(mob/living/follower, mob/living/target)
	// if we're standing in water
	return list((istype(get_turf(follower), /turf/open/water)), 1.5)

/datum/patron/divine/ravox
	name = "Ravox"
	domain = "God of Justice, Glory, Battle"
	desc = "Stalwart warrior, glorious justicier; legends say he came down to the Basin to repel the vile hordes of demons with his own hands, and that he seeks warriors for his divine army among mortals."
	worshippers = "Warriors, Sellswords & those who seek Justice"
	mob_traits = list(TRAIT_SHARPER_BLADES)
	miracles = list(/obj/effect/proc_holder/spell/targeted/touch/orison			= CLERIC_ORI,
					/obj/effect/proc_holder/spell/invoked/tug_of_war			= CLERIC_T0,
					/obj/effect/proc_holder/spell/invoked/lesser_heal 			= CLERIC_T1,
					/obj/effect/proc_holder/spell/self/divine_strike			= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/blood_heal			= CLERIC_T1,
					/obj/effect/proc_holder/spell/self/call_to_arms				= CLERIC_T2,
					/obj/effect/proc_holder/spell/invoked/persistence			= CLERIC_T3,
					/obj/effect/proc_holder/spell/invoked/wound_heal			= CLERIC_T4,
	)
	confess_lines = list(
		"RAVOX IS JUSTICE!",
		"THROUGH STRIFE, GRACE!",
		"THROUGH PERSISTENCE, GLORY!",
	)
	miracle_healing_lines = list(
		"An air of righteous defiance rises near %TARGET!"
	)
	storyteller = /datum/storyteller/ravox

/datum/patron/divine/ravox/situational_bonus(mob/living/follower, mob/living/target)
	var/situational_bonus = 0
	// the bloodier the area around our target is, the more we heal
	for (var/obj/effect/decal/cleanable/blood/O in oview(5, follower))
		situational_bonus = min(situational_bonus + 0.1, 2)
	return list((situational_bonus > 0), situational_bonus)

/datum/patron/divine/necra
	name = "Necra"
	domain = "Goddess of Death and the Afterlife"
	desc = "Veiled Lady of the underworld, equally feared and respected by mortals. She taught mortals the inevitability of death and cares for them as they reach the afterlife."
	worshippers = "The Dead, Mourners, Gravekeepers"
	mob_traits = list(TRAIT_SOUL_EXAMINE, TRAIT_NOSTINK)	//No stink is generic but they deal with dead bodies so.. makes sense, I suppose?
	miracles = list(/obj/effect/proc_holder/spell/targeted/touch/orison			= CLERIC_ORI,
					/obj/effect/proc_holder/spell/invoked/necras_sight			= CLERIC_T0,
					/obj/effect/proc_holder/spell/invoked/lesser_heal 			= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/avert					= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/deaths_door			= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/blood_heal			= CLERIC_T1,
					/obj/effect/proc_holder/spell/targeted/abrogation			= CLERIC_T2,
					/obj/effect/proc_holder/spell/invoked/speakwithdead			= CLERIC_T3,
					/obj/effect/proc_holder/spell/invoked/fieldburials			= CLERIC_T3,
					/obj/effect/proc_holder/spell/invoked/wound_heal			= CLERIC_T4,
	)
	confess_lines = list(
		"ALL SOULS FIND THEIR WAY TO NECRA!",
		"THE UNDERMAIDEN IS OUR FINAL REPOSE!",
		"I FEAR NOT DEATH, MY LADY AWAITS ME!",
	)
	miracle_healing_lines = list(
		"A sense of quiet respite radiates from %TARGET."
	)
	storyteller = /datum/storyteller/necra

/datum/patron/divine/necra/situational_bonus(mob/living/follower, mob/living/target)
	// if the target is closer to death
	return list((target.health <= target.maxHealth * 0.25), 2.5)

/datum/patron/divine/xylix
	name = "Xylix"
	domain = "God of Trickery, Freedom and Inspiration"
	desc = "The Laughing God, both famous and infamous for his sway over the forces of luck. Xylix is known for the inspiration of many a bards lyric. Speaks through his gift to man; the Tarot deck."
	worshippers = "Gamblers, Bards, Artists, and the Silver-Tongued"
	mob_traits = list(TRAIT_XYLIX)
	miracles = list(/obj/effect/proc_holder/spell/targeted/touch/orison			= CLERIC_ORI,
					/obj/effect/proc_holder/spell/self/xylixslip				= CLERIC_T0,
					/obj/effect/proc_holder/spell/invoked/lesser_heal 			= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/wheel					= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/mockery				= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/blood_heal			= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/mastersillusion		= CLERIC_T2,
					/obj/effect/proc_holder/spell/invoked/wound_heal			= CLERIC_T4,
	)
	confess_lines = list(
		"ASTRATA IS MY LIGHT!",
		"NOC IS NIGHT!",
		"DENDOR PROVIDES!",
		"ABYSSOR COMMANDS THE WAVES!",
		"RAVOX IS JUSTICE!",
		"ALL SOULS FIND THEIR WAY TO NECRA!",
		"HAHAHAHA! AHAHAHA! HAHAHAHA!",
		"PESTRA SOOTHES ALL ILLS!",
		"MALUM IS MY MUSE!",
		"EORA BRINGS US TOGETHER!",
		"LONG LIVE ZIZO!",
		"GRAGGAR IS THE BEAST I WORSHIP!",
		"MATTHIOS IS MY LORD!",
		"BAOTHA IS MY JOY!",
		"REBUKE THE HERETICAL- PSYDON ENDURES!",
	)
	miracle_healing_lines = list(
		"A mirthful breeze swirls around %TARGET!"
	)
	storyteller = /datum/storyteller/xylix

/datum/patron/divine/xylix/situational_bonus(mob/living/follower, mob/living/target)
	// half of the time, heal a little (or a lot) more - flip the coin
	return list(prob(50), rand(1, 2.5))

/datum/patron/divine/pestra
	name = "Pestra"
	domain = "Goddess of Decay, Disease and Medicine"
	desc = "Goddess that blessed many a saint with healing hands, Pestra taught man the arts of medicine and its benefits."
	worshippers = "The Sick, Phyicians, Apothecaries"
	mob_traits = list(TRAIT_EMPATH, TRAIT_ROT_EATER)
	miracles = list(/obj/effect/proc_holder/spell/targeted/touch/orison			= CLERIC_ORI,
					/obj/effect/proc_holder/spell/invoked/diagnose				= CLERIC_ORI,
					/obj/effect/proc_holder/spell/invoked/pestra_leech			= CLERIC_T0,
					/obj/effect/proc_holder/spell/invoked/lesser_heal 			= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/heal					= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/infestation			= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/blood_heal			= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/attach_bodypart		= CLERIC_T2,
					/obj/effect/proc_holder/spell/invoked/cure_rot				= CLERIC_T3,
					/obj/effect/proc_holder/spell/invoked/wound_heal			= CLERIC_T4,
	)
	confess_lines = list(
		"PESTRA SOOTHES ALL ILLS!",
		"DECAY IS A CONTINUATION OF LIFE!",
		"MY AFFLICTION IS MY TESTAMENT!",
	)
	miracle_healing_lines = list(
		"An aura of clinical care encompasses %TARGET!"
	)
	storyteller = /datum/storyteller/pestra

/datum/patron/divine/pestra/situational_bonus(mob/living/follower, mob/living/target)
	if (!iscarbon(follower))
		return list(FALSE, 0)

	// situational bonus only if whatever we're healing is low on blood
	var/mob/living/carbon/C = target
	return list((C.blood_volume <= (BLOOD_VOLUME_NORMAL / 2)), 2.5)

/datum/patron/divine/malum
	name = "Malum"
	domain = "God of Fire, Destruction and Rebirth"
	desc = "Opinionless god of the crafts. He teaches that great works for killing or saving are great works, either way. The well-oiled guillotine and the well-sharpened axe are tools, and there is no good and evil to their craft."
	worshippers = "Smiths, Miners, Engineers"
	mob_traits = list(TRAIT_FORGEBLESSED, TRAIT_BETTER_SLEEP)
	miracles = list(/obj/effect/proc_holder/spell/targeted/touch/orison			= CLERIC_ORI,
					/obj/effect/proc_holder/spell/invoked/malum_flame_rogue 	= CLERIC_T0,
					/obj/effect/proc_holder/spell/invoked/lesser_heal 			= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/vigorousexchange		= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/blood_heal			= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/heatmetal				= CLERIC_T2,
					/obj/effect/proc_holder/spell/invoked/hammerfall			= CLERIC_T3,
					/obj/effect/proc_holder/spell/invoked/wound_heal			= CLERIC_T3,
	)
	confess_lines = list(
		"MALUM IS MY MUSE!",
		"TRUE VALUE IS IN THE TOIL!",
		"I AM AN INSTRUMENT OF CREATION!",
	)
	miracle_healing_lines = list(
		"A dispassionate glow smoulders around %TARGET!"
	)
	storyteller = /datum/storyteller/malum

/datum/patron/divine/malum/situational_bonus(mob/living/follower, mob/living/target)
	// extra healing for every source of fire/light near us
	var/list/firey_stuff = list(/obj/machinery/light/rogue/torchholder, /obj/machinery/light/rogue/campfire, /obj/machinery/light/rogue/hearth, /obj/machinery/light/rogue/wallfire, /obj/machinery/light/rogue/wallfire/candle, /obj/machinery/light/rogue/forge)
	var/situational_bonus = 0
	for (var/obj/O in oview(5, follower))
		if (O.type in firey_stuff)
			situational_bonus = min(situational_bonus + 0.5, 2.5)
	return list((situational_bonus > 0), situational_bonus)

/datum/patron/divine/eora
	name = "Eora"
	domain = "Goddess of Love, Life and Beauty"
	desc = "Baotha's fairer half, made from blind, unconditional love. She is without a shred of hate in her heart and taught mankind that true love can even transcend Necra's grasp."
	worshippers = "Lovers, the romantically inclined, and Doting Grandparents"
	mob_traits = list(TRAIT_EMPATH, TRAIT_EXTEROCEPTION)
	miracles = list(/obj/effect/proc_holder/spell/targeted/touch/orison			= CLERIC_ORI,
					/obj/effect/proc_holder/spell/invoked/eora_blessing			= CLERIC_T0,
					/obj/effect/proc_holder/spell/invoked/lesser_heal 			= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/bless_food            = CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/bud					= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/blood_heal			= CLERIC_T1,
					/obj/effect/proc_holder/spell/invoked/heartweave			= CLERIC_T2,
					/obj/effect/proc_holder/spell/invoked/eoracurse				= CLERIC_T3,
					/obj/effect/proc_holder/spell/invoked/wound_heal			= CLERIC_T4,
					/obj/effect/proc_holder/spell/invoked/pomegranate			= CLERIC_T4,
	)
	confess_lines = list(
		"EORA BRINGS US TOGETHER!",
		"HER BEAUTY IS EVEN IN THIS TORMENT!",
		"I LOVE YOU, EVEN AS YOU TRESPASS AGAINST ME!",
	)
	miracle_healing_lines = list(
		"A gentle light blossoms around %TARGET!"
	)
	traits_tier = list(TRAIT_EORAN_CALM = CLERIC_T0, TRAIT_EORAN_SERENE = CLERIC_T2)
	storyteller = /datum/storyteller/eora

/datum/patron/divine/eora/situational_bonus(mob/living/follower, mob/living/target)
	// if the either the target or we are a pacifist, increase bonuses
	var/situational_bonus = 0
	if (HAS_TRAIT(target, TRAIT_PACIFISM))
		situational_bonus = 2.5
	if (HAS_TRAIT(follower, TRAIT_PACIFISM))
		situational_bonus += 1.5
	return list((situational_bonus > 0), situational_bonus)

/////////////////////////////////
// Does God Hear Your Prayer ? //
/////////////////////////////////

// Astrata - In daylight, church, cross, or ritual chalk.
/datum/patron/divine/astrata/can_pray(mob/living/follower)
	. = ..()
	// Allows prayer near psycross
	for(var/obj/structure/fluff/psycross/cross in view(4, get_turf(follower)))
		if(cross.divine == FALSE)
			to_chat(follower, span_danger("That defiled cross interupts my prayers!"))
			return FALSE
		return TRUE
	// Allows prayer in the church
	if(istype(get_area(follower), /area/rogue/indoors/town/church))
		return TRUE
	// Allows prayer during daytime if outside.
	if(istype(get_area(follower), /area/rogue/outdoors) && (GLOB.tod == "day" || GLOB.tod == "dawn"))
		return TRUE
	to_chat(follower, span_danger("For Astrata to hear my prayer I must either be in her blessed daylight, within the church, or near a psycross.."))
	return FALSE


// Noc - In moonlight, church, cross, or ritual chalk
/datum/patron/divine/noc/can_pray(mob/living/follower)
	. = ..()
	// Allows prayer near psycross
	for(var/obj/structure/fluff/psycross/cross in view(4, get_turf(follower)))
		if(cross.divine == FALSE)
			to_chat(follower, span_danger("That defiled cross interupts my prayers!"))
			return FALSE
		return TRUE
	// Allows prayer in the church
	if(istype(get_area(follower), /area/rogue/indoors/town/church))
		return TRUE
	// Allows prayer during nightime if outside.
	if(istype(get_area(follower), /area/rogue/outdoors) && (GLOB.tod == "night" || GLOB.tod == "dusk"))
		return TRUE
	// Allows praying atop ritual chalk of the god.
	for(var/obj/structure/ritualcircle/noc in view(1, get_turf(follower)))
		return TRUE
	to_chat(follower, span_danger("For Noc to hear my prayer I must either be in his blessed moonlight, within the church, or near a psycross."))
	return FALSE


// Dendor - In grove, bog, cross, or ritual chalk
// Yes, he is NOT calling the master cus he's unique. Whole bog is his prayer zone. Druids exist for a reason instead of in the church.
/datum/patron/divine/dendor/can_pray(mob/living/follower)
	. = ..()
	// Allows prayer near psycross
	for(var/obj/structure/fluff/psycross/cross in view(4, get_turf(follower)))
		if(cross.divine == FALSE)
			to_chat(follower, span_danger("That defiled cross interupts my prayers!"))
			return FALSE
		return TRUE
	// Allows prayer in the druid tower + houses in the forest
	if(istype(get_area(follower), /area/rogue/indoors/shelter/woods))
		return TRUE
	// Allows prayer in outdoors wilderness, such as bog
	if(istype(get_area(follower), /area/rogue/outdoors/rtfield))
		return TRUE
	for(var/obj/structure/flora/roguetree/wise in view(4, get_turf(follower)))
		return TRUE
	to_chat(follower, span_danger("I must either be in Dendor's wilds, the Grove, near a wise tree, or near a Panetheon Cross for the 'Tree Father' to hear my prays..."))
	return FALSE


// Abyssor - Near water, cross, or within the church.
/datum/patron/divine/abyssor/can_pray(mob/living/follower)
	. = ..()
	// Allows prayer near psycross
	for(var/obj/structure/fluff/psycross/cross in view(4, get_turf(follower)))
		if(cross.divine == FALSE)
			to_chat(follower, span_danger("That defiled cross interupts my prayers!"))
			return FALSE
		return TRUE
	// Allows prayer in the church
	if(istype(get_area(follower), /area/rogue/indoors/town/church))
		return TRUE
	// Allows prayer near any body of water turf.
	for(var/turf/open/water in view(4, get_turf(follower)))
		return TRUE
	to_chat(follower, span_danger("For Abyssor to hear my prayer I must either pray within the church, near a psycross, or at any body of water so that the tides of prayer may flow.."))
	return FALSE


// Ravox - Near a knight statue, cross, or within the church
/datum/patron/divine/ravox/can_pray(mob/living/follower)
	. = ..()
	// Allows prayer near psycross
	for(var/obj/structure/fluff/psycross/cross in view(4, get_turf(follower)))
		if(cross.divine == FALSE)
			to_chat(follower, span_danger("That defiled cross interupts my prayers!"))
			return FALSE
		return TRUE
	// Allows prayer in the church
	if(istype(get_area(follower), /area/rogue/indoors/town/church))
		return TRUE
	// Allows prayer near any knight statue and its subtypes.
	for(var/obj/structure/fluff/statue/knight/K in view(4, get_turf(follower)))
		return TRUE
	to_chat(follower, span_danger("For Ravox to hear my prayer I must either pray within the church, near a psycross, or near a knighly statue in memorium of the fallen.."))
	return FALSE


// Necra - Near a grave, cross, or within the church
/datum/patron/divine/necra/can_pray(mob/living/follower)
	. = ..()
	// Allows prayer near psycross
	for(var/obj/structure/fluff/psycross/cross in view(4, get_turf(follower)))
		if(cross.divine == FALSE)
			to_chat(follower, span_danger("That defiled cross interupts my prayers!"))
			return FALSE
		return TRUE
	// Allows prayer in the church
	if(istype(get_area(follower), /area/rogue/indoors/town/church))
		return TRUE
	// Allows prayer near a grave.
	for(var/obj/structure/closet/dirthole/grave/G in view(4, get_turf(follower)))
		return TRUE
	to_chat(follower, span_danger("For Necra to hear my prayer I must either pray within the church, near a psycross, or near a grave where we all go to be given our final embrace.."))
	return FALSE


// Xylix - Near a gambling machine, cross, or within the church
/datum/patron/divine/xylix/can_pray(mob/living/follower)
	. = ..()
	// Allows prayer near psycross
	for(var/obj/structure/fluff/psycross/cross in view(4, get_turf(follower)))
		if(cross.divine == FALSE)
			to_chat(follower, span_danger("That defiled cross interupts my prayers!"))
			return FALSE
		return TRUE
	// Allows prayer in the church
	if(istype(get_area(follower), /area/rogue/indoors/town/church))
		return TRUE
	// Allows prayer near gambling machines.
	for(var/obj/structure/roguemachine/lottery_roguetown/L in view(4, get_turf(follower)))
		return TRUE
	to_chat(follower, span_danger("For Xylix to hear my prayer I must either pray within the church, near a psycross, or near a machine of fortune blessed by the grand jester.."))
	return FALSE


// Pestra - Near a well, cross, within the physicians, or within the church
/datum/patron/divine/pesta/can_pray(mob/living/follower)
	. = ..()
	// Allows prayer near psycross
	for(var/obj/structure/fluff/psycross/cross in view(4, get_turf(follower)))
		if(cross.divine == FALSE)
			to_chat(follower, span_danger("That defiled cross interupts my prayers!"))
			return FALSE
		return TRUE
	// Allows prayer in the church
	if(istype(get_area(follower), /area/rogue/indoors/town/church))
		return TRUE
	// Allows prayer in the appothocary's building.
	if(istype(get_area(follower), /area/rogue/indoors/town/physician))
		return TRUE
	// Allows prayer near wells. Weird one, but makes sense for health and disease. Miasma, water, etc.
	for(var/obj/structure/well/W in view(4, get_turf(follower)))
		return TRUE
	to_chat(follower, span_danger("For Pestra to hear my prayer I must either pray within the church, phyisican's building, near a psycross, or near a well to observe the full circle of life.."))
	return FALSE


// Malum - Near a smelter, hearth, cross, within the smithy, or within the church
/datum/patron/divine/malum/can_pray(mob/living/follower)
	. = ..()
	// Allows prayer near psycross
	for(var/obj/structure/fluff/psycross/cross in view(4, get_turf(follower)))
		if(cross.divine == FALSE)
			to_chat(follower, span_danger("That defiled cross interupts my prayers!"))
			return FALSE
		return TRUE
	// Allows prayer in the church
	if(istype(get_area(follower), /area/rogue/indoors/town/church))
		return TRUE
	// Allows prayer in the smith's building.
	if(istype(get_area(follower), /area/rogue/indoors/town/dwarfin))
		return TRUE
	// Allows prayer near hearths.
	for(var/obj/machinery/light/rogue/hearth/H in view(4, get_turf(follower)))
		return TRUE
	// Allows prayer near smelters.
	for(var/obj/machinery/light/rogue/smelter/H in view(4, get_turf(follower)))
		return TRUE
	to_chat(follower, span_danger("For Malum to hear my prayer I must either pray within the church, the smithy's workshop, near a psycross, near a smelter, or hearth to bask in Malum's glory.."))
	return FALSE

// Eora - Near a gambling machine, cross, or within the church
/datum/patron/divine/eora/can_pray(mob/living/follower)
	. = ..()
	// Allows prayer near psycross
	for(var/obj/structure/fluff/psycross/cross in view(4, get_turf(follower)))
		if(cross.divine == FALSE)
			to_chat(follower, span_danger("That defiled cross interupts my prayers!"))
			return FALSE
		return TRUE
	// Allows prayer in the church
	if(istype(get_area(follower), /area/rogue/indoors/town/church))
		return TRUE
	// Allows Eorans to pray using flowers
	var/obj/item/held_item = follower.get_active_held_item()
	if(istype(held_item, /obj/item/reagent_containers/food/snacks/grown/rogue/poppy))
		qdel(held_item)
		return TRUE
	// Allows player to pray while wearing eoran bud.
	if(HAS_TRAIT(follower, TRAIT_PACIFISM))
		return TRUE
	to_chat(follower, span_danger("For Eora to hear my prayer I must either pray within the church, near a psycross, offering her poppy flowers, or wearing one of her blessed flowers atop my head.."))
	return FALSE
