/datum/reagent/drug
	name = "Drug"
	metabolization_rate = 0.1
	taste_description = "bitterness"
	var/trippy = TRUE //Does this drug make you trip?

/datum/reagent/drug/on_mob_end_metabolize(mob/living/M)
	if(trippy)
		SEND_SIGNAL(M, COMSIG_CLEAR_MOOD_EVENT, "[type]_high")

/datum/reagent/drug/space_drugs
	name = "Space drugs"
	description = "An illegal chemical compound used as drug."
	color = "#60A584" // rgb: 96, 165, 132
	overdose_threshold = 30

/datum/reagent/drug/space_drugs/on_mob_life(mob/living/carbon/M)
	M.set_drugginess(30)
	if(prob(5))
		if(M.gender == FEMALE)
			M.emote(pick("twitch_s","giggle"))
		else
			M.emote(pick("twitch_s","chuckle"))
	M.apply_status_effect(/datum/status_effect/buff/weed)
	if(M.has_flaw(/datum/charflaw/addiction/smoker))
		M.sate_addiction()
	..()

/datum/reagent/drug/space_drugs/on_mob_end_metabolize(mob/living/M)
	M.clear_fullscreen("weedsm")
	M.update_body_parts_head_only()

/*
	if(M.client)
		SSdroning.play_area_sound(get_area(M), M.client)
*/

/datum/reagent/drug/space_drugs/on_mob_metabolize(mob/living/M)
	..()
	M.set_drugginess(30)
	M.update_body_parts_head_only()
	M.overlay_fullscreen("weedsm", /atom/movable/screen/fullscreen/weedsm)

/*
	if(M.client)
		SSdroning.area_entered(get_area(M), M.client)
*/

/atom/movable/screen/fullscreen/weedsm
	icon_state = "smok"
	plane = BLACKNESS_PLANE
	layer = AREA_LAYER
	blend_mode = 0
	alpha = 100
	show_when_dead = FALSE

/atom/movable/screen/fullscreen/weedsm/Initialize()
	. = ..()
//			if(L.has_status_effect(/datum/status_effect/buff/weed))
	filters += filter(type="angular_blur",x=5,y=5,size=1)

/datum/reagent/drug/space_drugs/overdose_start(mob/living/M)
	to_chat(M, "<span class='danger'>I start tripping hard!</span>")
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "[type]_overdose", /datum/mood_event/overdose, name)

/datum/reagent/drug/space_drugs/overdose_process(mob/living/M)
	M.adjustToxLoss(0.1*REM, 0)
	M.adjustOxyLoss(1.1*REM, 0)
	..()

/datum/reagent/drug/nicotine
	name = "Nicotine"
	description = "Slightly reduces stun times. If overdosed it will deal toxin and oxygen damage."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132
	addiction_threshold = 999
	taste_description = "smoke"
	trippy = FALSE
	overdose_threshold=999
	metabolization_rate = 0.1 * REAGENTS_METABOLISM


/datum/reagent/drug/nicotine/on_mob_end_metabolize(mob/living/M)
//	M.remove_stress(/datum/stressevent/pweed)
	..()

/datum/reagent/drug/nicotine/on_mob_metabolize(mob/living/M)
	var/mob/living/carbon/V = M
	V.add_stress(/datum/stressevent/pweed)
	..()

/datum/reagent/drug/nicotine/on_mob_life(mob/living/carbon/M)
/*	if(prob(1))
		var/smoke_message = pick("You feel relaxed.", "You feel calmed.","You feel alert.","You feel rugged.")
		to_chat(M, "<span class='notice'>[smoke_message]</span>")
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "smoked", /datum/mood_event/smoked, name)
	M.AdjustStun(-5, FALSE)
	M.AdjustKnockdown(-5, FALSE)
	M.AdjustUnconscious(-5, FALSE)
	M.AdjustParalyzed(-5, FALSE)
	M.AdjustImmobilized(-5, FALSE)*/
	if(M.has_flaw(/datum/charflaw/addiction/smoker))
		M.sate_addiction()
	..()
	. = 1

/datum/reagent/drug/nicotine/overdose_process(mob/living/M)
	M.adjustToxLoss(0.1*REM, 0)
	M.adjustOxyLoss(1.1*REM, 0)
	..()
	. = 1

/datum/reagent/drug/mentha // distinct from SS13 menthol, for the mentha zigs
	name = "Mentha"
	description = "Extract from the mentha herb. Produces a cooling sensation."
	reagent_state = LIQUID
	color = "#3eb489"
	addiction_threshold = 999
	taste_description = "mentha"
	trippy = FALSE
	overdose_threshold=999
	metabolization_rate = 0.1 * REAGENTS_METABOLISM

/datum/reagent/drug/mentha/on_mob_end_metabolize(mob/living/M)
	..()

/datum/reagent/drug/mentha/on_mob_metabolize(mob/living/M)
	var/mob/living/carbon/V = M
	V.add_stress(/datum/stressevent/menthasmoke)
	..()

/datum/reagent/drug/mentha/on_mob_life(mob/living/carbon/M)
	..()
	. = 1

/datum/reagent/drug/mentha/overdose_process(mob/living/M)
	M.adjustToxLoss(0.1*REM, 0)
	M.adjustOxyLoss(1.1*REM, 0)
	..()
	. = 1

/datum/reagent/drug/crank
	name = "Crank"
	description = "Reduces stun times by about 200%. If overdosed or addicted it will deal significant Toxin, Brute and Brain damage."
	reagent_state = LIQUID
	color = "#FA00C8"
	overdose_threshold = 20
	addiction_threshold = 10

/datum/reagent/drug/crank/on_mob_life(mob/living/carbon/M)
	if(prob(5))
		var/high_message = pick("You feel jittery.", "You feel like you gotta go fast.", "You feel like you need to step it up.")
		to_chat(M, "<span class='notice'>[high_message]</span>")
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "tweaking", /datum/mood_event/stimulant_medium, name)
	M.AdjustStun(-20, FALSE)
	M.AdjustKnockdown(-20, FALSE)
	M.AdjustUnconscious(-20, FALSE)
	M.AdjustImmobilized(-20, FALSE)
	M.AdjustParalyzed(-20, FALSE)
	..()
	. = 1

/datum/reagent/drug/crank/overdose_process(mob/living/M)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2*REM)
	M.adjustToxLoss(2*REM, 0)
	M.adjustBruteLoss(2*REM, FALSE, FALSE, BODYPART_ORGANIC)
	..()
	. = 1

/datum/reagent/drug/crank/addiction_act_stage1(mob/living/M)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 5*REM)
	..()

/datum/reagent/drug/crank/addiction_act_stage2(mob/living/M)
	M.adjustToxLoss(5*REM, 0)
	..()
	. = 1

/datum/reagent/drug/crank/addiction_act_stage3(mob/living/M)
	M.adjustBruteLoss(5*REM, 0)
	..()
	. = 1

/datum/reagent/drug/crank/addiction_act_stage4(mob/living/M)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 3*REM)
	M.adjustToxLoss(5*REM, 0)
	M.adjustBruteLoss(5*REM, 0)
	..()
	. = 1

/datum/reagent/drug/methamphetamine
	name = "Methamphetamine"
	description = "Reduces stun times by about 300%, speeds the user up, and allows the user to quickly recover stamina while dealing a small amount of Brain damage. If overdosed the subject will move randomly, laugh randomly, drop items and suffer from Toxin and Brain damage. If addicted the subject will constantly jitter and drool, before becoming dizzy and losing motor control and eventually suffer heavy toxin damage."
	reagent_state = LIQUID
	color = "#FAFAFA"
	overdose_threshold = 20
	addiction_threshold = 10
	metabolization_rate = 0.75 * REAGENTS_METABOLISM

/datum/reagent/drug/methamphetamine/on_mob_metabolize(mob/living/L)
	..()
	L.add_movespeed_modifier(type, update=TRUE, priority=100, multiplicative_slowdown=-2, blacklisted_movetypes=(FLYING|FLOATING))

/datum/reagent/drug/methamphetamine/on_mob_end_metabolize(mob/living/L)
	L.remove_movespeed_modifier(type)
	..()

/datum/reagent/drug/methamphetamine/on_mob_life(mob/living/carbon/M)
	var/high_message = pick("You feel hyper.", "You feel like you need to go faster.", "You feel like you can run the world.")
	if(prob(5))
		to_chat(M, "<span class='notice'>[high_message]</span>")
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "tweaking", /datum/mood_event/stimulant_medium, name)
	M.AdjustStun(-40, FALSE)
	M.AdjustKnockdown(-40, FALSE)
	M.AdjustUnconscious(-40, FALSE)
	M.AdjustParalyzed(-40, FALSE)
	M.AdjustImmobilized(-40, FALSE)
	M.adjustStaminaLoss(-2, 0)
	M.Jitter(2)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, rand(1,4))
	if(prob(5))
		M.emote(pick("twitch", "shiver"))
	..()
	. = 1

/datum/reagent/drug/methamphetamine/overdose_process(mob/living/M)
	if((M.mobility_flags & MOBILITY_MOVE) && !ismovableatom(M.loc))
		for(var/i in 1 to 4)
			step(M, pick(GLOB.cardinals))
	if(prob(20))
		M.emote("laugh")
	if(prob(33))
		M.visible_message("<span class='danger'>[M]'s hands flip out and flail everywhere!</span>")
		M.drop_all_held_items()
	..()
	M.adjustToxLoss(1, 0)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, pick(0.5, 0.6, 0.7, 0.8, 0.9, 1))
	. = 1

/datum/reagent/drug/methamphetamine/addiction_act_stage1(mob/living/M)
	M.Jitter(5)
	if(prob(20))
		M.emote(pick("twitch","drool","moan"))
	..()

/datum/reagent/drug/methamphetamine/addiction_act_stage2(mob/living/M)
	M.Jitter(10)
	M.Dizzy(10)
	if(prob(30))
		M.emote(pick("twitch","drool","moan"))
	..()

/datum/reagent/drug/methamphetamine/addiction_act_stage3(mob/living/M)
	if((M.mobility_flags & MOBILITY_MOVE) && !ismovableatom(M.loc))
		for(var/i = 0, i < 4, i++)
			step(M, pick(GLOB.cardinals))
	M.Jitter(15)
	M.Dizzy(15)
	if(prob(40))
		M.emote(pick("twitch","drool","moan"))
	..()

/datum/reagent/drug/methamphetamine/addiction_act_stage4(mob/living/carbon/human/M)
	if((M.mobility_flags & MOBILITY_MOVE) && !ismovableatom(M.loc))
		for(var/i = 0, i < 8, i++)
			step(M, pick(GLOB.cardinals))
	M.Jitter(20)
	M.Dizzy(20)
	M.adjustToxLoss(5, 0)
	if(prob(50))
		M.emote(pick("twitch","drool","moan"))
	..()
	. = 1

/datum/reagent/drug/aranesp
	name = "Aranesp"
	description = "Amps you up, gets you going, and rapidly restores stamina damage. Side effects include breathlessness and toxicity."
	reagent_state = LIQUID
	color = "#78FFF0"

/datum/reagent/drug/aranesp/on_mob_life(mob/living/carbon/M)
	var/high_message = pick("You feel amped up.", "You feel ready.", "You feel like you can push it to the limit.")
	if(prob(5))
		to_chat(M, "<span class='notice'>[high_message]</span>")
	M.adjustStaminaLoss(-18, 0)
	M.adjustToxLoss(0.5, 0)
	if(prob(50))
		M.losebreath++
		M.adjustOxyLoss(1, 0)
	..()
	. = 1

/datum/reagent/drug/happiness
	name = "Happiness"
	description = "Fills you with ecstasic numbness and causes minor brain damage. Highly addictive. If overdosed causes sudden mood swings."
	reagent_state = LIQUID
	color = "#FFF378"
	addiction_threshold = 10
	overdose_threshold = 20

/datum/reagent/drug/happiness/on_mob_metabolize(mob/living/L)
	..()
	ADD_TRAIT(L, TRAIT_FEARLESS, type)
	SEND_SIGNAL(L, COMSIG_ADD_MOOD_EVENT, "happiness_drug", /datum/mood_event/happiness_drug)

/datum/reagent/drug/happiness/on_mob_delete(mob/living/L)
	REMOVE_TRAIT(L, TRAIT_FEARLESS, type)
	SEND_SIGNAL(L, COMSIG_CLEAR_MOOD_EVENT, "happiness_drug")
	..()

/datum/reagent/drug/happiness/on_mob_life(mob/living/carbon/M)
	M.jitteriness = 0
	M.confused = 0
	M.disgust = 0
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.2)
	..()
	. = 1

/datum/reagent/drug/happiness/overdose_process(mob/living/M)
	if(prob(30))
		var/reaction = rand(1,3)
		switch(reaction)
			if(1)
				M.emote("laugh")
				SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "happiness_drug", /datum/mood_event/happiness_drug_good_od)
			if(2)
				M.emote("sway")
				M.Dizzy(25)
			if(3)
				M.emote("frown")
				SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "happiness_drug", /datum/mood_event/happiness_drug_bad_od)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.5)
	..()
	. = 1

/datum/reagent/drug/happiness/addiction_act_stage1(mob/living/M)// all work and no play makes jack a dull boy
	var/datum/component/mood/mood = M.GetComponent(/datum/component/mood)
	mood.setSanity(min(mood.sanity, SANITY_DISTURBED))
	M.Jitter(5)
	if(prob(20))
		M.emote(pick("twitch","laugh","frown"))
	..()

/datum/reagent/drug/happiness/addiction_act_stage2(mob/living/M)
	var/datum/component/mood/mood = M.GetComponent(/datum/component/mood)
	mood.setSanity(min(mood.sanity, SANITY_UNSTABLE))
	M.Jitter(10)
	if(prob(30))
		M.emote(pick("twitch","laugh","frown"))
	..()

/datum/reagent/drug/happiness/addiction_act_stage3(mob/living/M)
	var/datum/component/mood/mood = M.GetComponent(/datum/component/mood)
	mood.setSanity(min(mood.sanity, SANITY_CRAZY))
	M.Jitter(15)
	if(prob(40))
		M.emote(pick("twitch","laugh","frown"))
	..()

/datum/reagent/drug/happiness/addiction_act_stage4(mob/living/carbon/human/M)
	var/datum/component/mood/mood = M.GetComponent(/datum/component/mood)
	mood.setSanity(SANITY_INSANE)
	M.Jitter(20)
	if(prob(50))
		M.emote(pick("twitch","laugh","frown"))
	..()
	. = 1

/datum/reagent/drug/pumpup
	name = "Pump-Up"
	description = "Take on the world! A fast acting, hard hitting drug that pushes the limit on what you can handle."
	reagent_state = LIQUID
	color = "#e38e44"
	metabolization_rate = 2 * REAGENTS_METABOLISM
	overdose_threshold = 30

/datum/reagent/drug/pumpup/on_mob_metabolize(mob/living/L)
	..()
	ADD_TRAIT(L, TRAIT_STUNRESISTANCE, type)

/datum/reagent/drug/pumpup/on_mob_end_metabolize(mob/living/L)
	REMOVE_TRAIT(L, TRAIT_STUNRESISTANCE, type)
	..()

/datum/reagent/drug/pumpup/on_mob_life(mob/living/carbon/M)
	M.Jitter(5)

	if(prob(5))
		to_chat(M, "<span class='notice'>[pick("Go! Go! GO!", "You feel ready...", "You feel invincible...")]</span>")
	if(prob(15))
		M.losebreath++
		M.adjustToxLoss(2, 0)
	..()
	. = 1

/datum/reagent/drug/pumpup/overdose_start(mob/living/M)
	to_chat(M, "<span class='danger'>I can't stop shaking, my heart beats faster and faster...</span>")

/datum/reagent/drug/pumpup/overdose_process(mob/living/M)
	M.Jitter(5)
	if(prob(5))
		M.drop_all_held_items()
	if(prob(15))
		M.emote(pick("twitch","drool"))
	if(prob(20))
		M.losebreath++
		M.adjustStaminaLoss(4, 0)
	if(prob(15))
		M.adjustToxLoss(2, 0)
	..()

/datum/reagent/drug/blackberry
	name = "Blackberry"
	description = "Extract from the blackberry. Produces a sweet-tart sensation."
	reagent_state = LIQUID
	color = "#4D0135"
	addiction_threshold = 999
	taste_description = "blackberry"
	trippy = FALSE
	overdose_threshold = 999
	metabolization_rate = 0.1 * REAGENTS_METABOLISM

/datum/reagent/drug/blackberry/on_mob_metabolize(mob/living/M)
	var/mob/living/carbon/V = M
	V.add_stress(/datum/stressevent/blackberrysmoke)
	..()

/datum/reagent/drug/blackberry/on_mob_life(mob/living/carbon/M)
	..()
	. = 1

/datum/reagent/drug/blackberry/overdose_process(mob/living/M)
	M.adjustToxLoss(0.1 * REAGENTS_EFFECT_MULTIPLIER, 0)
	M.adjustOxyLoss(1.1 * REAGENTS_EFFECT_MULTIPLIER, 0)
	..()
	. = 1

/datum/reagent/drug/apple
	name = "Apple"
	description = "Extract from the apple. Produces a sourness and coolness sensation."
	reagent_state = LIQUID
	color = "#AF4D43"
	addiction_threshold = 999
	taste_description = "apple"
	trippy = FALSE
	overdose_threshold = 999
	metabolization_rate = 0.1 * REAGENTS_METABOLISM

/datum/reagent/drug/apple/on_mob_metabolize(mob/living/M)
	var/mob/living/carbon/V = M
	V.add_stress(/datum/stressevent/applesmoke)
	..()

/datum/reagent/drug/apple/on_mob_life(mob/living/carbon/M)
	..()
	. = 1

/datum/reagent/drug/apple/overdose_process(mob/living/M)
	M.adjustToxLoss(0.1 * REAGENTS_EFFECT_MULTIPLIER, 0)
	M.adjustOxyLoss(1.1 * REAGENTS_EFFECT_MULTIPLIER, 0)
	..()
	. = 1

/datum/reagent/drug/strawberry
	name = "Strawberry"
	description = "Extract from the strawberry. Produces a sweet and refreshing sensation."
	reagent_state = LIQUID
	color = "#FC5A8D"
	addiction_threshold = 999
	taste_description = "strawberry"
	trippy = FALSE
	overdose_threshold = 999
	metabolization_rate = 0.1 * REAGENTS_METABOLISM

/datum/reagent/drug/strawberry/on_mob_metabolize(mob/living/M)
	var/mob/living/carbon/V = M
	V.add_stress(/datum/stressevent/strawberrysmoke)
	..()

/datum/reagent/drug/strawberry/on_mob_life(mob/living/carbon/M)
	..()
	. = 1

/datum/reagent/drug/strawberry/overdose_process(mob/living/M)
	M.adjustToxLoss(0.1 * REAGENTS_EFFECT_MULTIPLIER, 0)
	M.adjustOxyLoss(1.1 * REAGENTS_EFFECT_MULTIPLIER, 0)
	..()
	. = 1

/datum/reagent/drug/carrot
	name = "Carrot"
	description = "Extract from the carrot. Produces a sweet and refreshing sensation."
	reagent_state = LIQUID
	color = "#ED9121"
	addiction_threshold = 999
	taste_description = "carrot"
	trippy = FALSE
	overdose_threshold = 999
	metabolization_rate = 0.1 * REAGENTS_METABOLISM

/datum/reagent/drug/carrot/on_mob_metabolize(mob/living/M)
	var/mob/living/carbon/V = M
	V.add_stress(/datum/stressevent/carrotsmoke)
	..()

/datum/reagent/drug/carrot/on_mob_life(mob/living/carbon/M)
	..()
	. = 1

/datum/reagent/drug/carrot/overdose_process(mob/living/M)
	M.adjustToxLoss(0.1 * REAGENTS_EFFECT_MULTIPLIER, 0)
	M.adjustOxyLoss(1.1 * REAGENTS_EFFECT_MULTIPLIER, 0)
	..()
	. = 1

/datum/reagent/drug/lime
	name = "Lime"
	description = "Extract from the lime. Produces a sweet and refreshing sensation."
	reagent_state = LIQUID
	color = "#BFFF00"
	addiction_threshold = 999
	taste_description = "lime"
	trippy = FALSE
	overdose_threshold = 999
	metabolization_rate = 0.1 * REAGENTS_METABOLISM

/datum/reagent/drug/lime/on_mob_metabolize(mob/living/M)
	var/mob/living/carbon/V = M
	V.add_stress(/datum/stressevent/limesmoke)
	..()

/datum/reagent/drug/lime/on_mob_life(mob/living/carbon/M)
	..()
	. = 1

/datum/reagent/drug/lime/overdose_process(mob/living/M)
	M.adjustToxLoss(0.1 * REAGENTS_EFFECT_MULTIPLIER, 0)
	M.adjustOxyLoss(1.1 * REAGENTS_EFFECT_MULTIPLIER, 0)
	..()
	. = 1

/datum/reagent/drug/salvia
	name = "Salvia"
	description = "Extract from the salvia. Produces a spicy, earthy and bitter sensation."
	reagent_state = LIQUID
	color = "#FF33FF"
	addiction_threshold = 999
	taste_description = "salvia"
	trippy = FALSE
	overdose_threshold = 999
	metabolization_rate = 0.1 * REAGENTS_METABOLISM

/datum/reagent/drug/salvia/on_mob_metabolize(mob/living/M)
	var/mob/living/carbon/V = M
	V.add_stress(/datum/stressevent/salviasmoke)
	..()

/datum/reagent/drug/salvia/on_mob_life(mob/living/carbon/M)
	..()
	. = 1

/datum/reagent/drug/salvia/overdose_process(mob/living/M)
	M.adjustToxLoss(0.1 * REAGENTS_EFFECT_MULTIPLIER, 0)
	M.adjustOxyLoss(1.1 * REAGENTS_EFFECT_MULTIPLIER, 0)
	..()
	. = 1

/datum/reagent/drug/valeriana
	name = "Valeriana"
	description = "Extract from the valeriana. Produces a bitter-spicy and tart sensation."
	reagent_state = LIQUID
	color = "#4a3c5f"
	addiction_threshold = 999
	taste_description = "valeriana"
	trippy = FALSE
	overdose_threshold = 999
	metabolization_rate = 0.1 * REAGENTS_METABOLISM

/datum/reagent/drug/valeriana/on_mob_metabolize(mob/living/M)
	var/mob/living/carbon/V = M
	V.add_stress(/datum/stressevent/valerianasmoke)
	if(prob(20))
		M.drowsyness += 3
		M.emote(pick("yawn"))
		M.visible_message(span_notice("[M] looks sleepy and relaxed."))
	..()

/datum/reagent/drug/valeriana/overdose_process(mob/living/M)
	M.adjustToxLoss(0.1 * REAGENTS_EFFECT_MULTIPLIER, 0)
	M.adjustOxyLoss(1.1 * REAGENTS_EFFECT_MULTIPLIER, 0)
	..()
	. = 1

/datum/reagent/drug/calendula
	name = "Calendula"
	description = "Extract from the calendula. Produces a bitter-spicy and tart sensation with mild healing properties."
	reagent_state = LIQUID
	color = "#a57006"
	addiction_threshold = 999
	taste_description = "calendula"
	trippy = FALSE
	overdose_threshold = 30 // lower, cuz of its healing properties
	metabolization_rate = 0.2 * REAGENTS_METABOLISM

/datum/reagent/drug/calendula/on_mob_metabolize(mob/living/M)
	var/list/wCount = M.get_wounds()
	M.adjustBruteLoss(-0.5 * REAGENTS_EFFECT_MULTIPLIER, 0)
	M.adjustFireLoss(-0.5 * REAGENTS_EFFECT_MULTIPLIER, 0)
	M.adjustOxyLoss(-0.25, 0)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, -1 * REAGENTS_EFFECT_MULTIPLIER)
	M.adjustCloneLoss(-0.5 * REAGENTS_EFFECT_MULTIPLIER, 0)
	if(wCount.len > 0)
		M.heal_wounds(0.5) // twice worse than the tea
	..()

/datum/reagent/drug/calendula/on_mob_life(mob/living/carbon/M)
	..()
	. = 1

/datum/reagent/drug/calendula/overdose_process(mob/living/M)
	M.adjustToxLoss(0.1 * REAGENTS_EFFECT_MULTIPLIER, 0)
	M.adjustOxyLoss(1.1 * REAGENTS_EFFECT_MULTIPLIER, 0)
	..()
	. = 1

/datum/reagent/drug/petun
	name = "Petun"
	description = "A highly concentrated form of nicotine. Causes a sore throat and mild relaxation."
	reagent_state = LIQUID
	color = "#7ed9ad"
	addiction_threshold = 999
	taste_description = "concentrated bitterness"
	trippy = FALSE
	overdose_threshold = 999
	metabolization_rate = 0.1 * REAGENTS_METABOLISM

/datum/reagent/drug/petun/on_mob_metabolize(mob/living/M)
	var/mob/living/carbon/V = M
	V.add_stress(/datum/stressevent/zweed)
	if(prob(10))
		M.emote(pick("drool","sigh"))
	if(prob(5))
		M.visible_message(span_notice("[M] looks pleasantly relaxed."))
	..()

/datum/reagent/drug/petun/on_mob_life(mob/living/carbon/M)
	if(HAS_TRAIT(M, TRAIT_TOXIMMUNE))
		M.adjustToxLoss(0.1)
	..()
	. = 1

/datum/reagent/drug/petun/overdose_process(mob/living/M)
	M.adjustToxLoss(0.1 * REAGENTS_EFFECT_MULTIPLIER, 0)
	M.adjustOxyLoss(1.1 * REAGENTS_EFFECT_MULTIPLIER, 0)
	..()
	. = 1

/datum/reagent/drug/jacksberries
	name = "jacksberries"
	description = "Extract from jacksberries. Produces a sore throat and mild relaxation."
	reagent_state = LIQUID
	color = "#57628C"
	addiction_threshold = 999
	taste_description = "jacksberries"
	trippy = FALSE
	overdose_threshold = 999
	metabolization_rate = 0.1 * REAGENTS_METABOLISM

/datum/reagent/drug/jacksberries/on_mob_metabolize(mob/living/M)
	var/mob/living/carbon/V = M
	V.add_stress(/datum/stressevent/jacksberriessmoke)
	..()

/datum/reagent/drug/jacksberries/on_mob_life(mob/living/carbon/M)
	..()
	. = 1

/datum/reagent/drug/jacksberries/overdose_process(mob/living/M)
	M.adjustToxLoss(0.1 * REAGENTS_EFFECT_MULTIPLIER, 0)
	M.adjustOxyLoss(1.1 * REAGENTS_EFFECT_MULTIPLIER, 0)
	..()
	. = 1

/datum/reagent/drug/abyss
	name = "Abyss"
	description = "A dark extract laced with jacksberries. Causes a sore throat and a creeping unease."
	reagent_state = LIQUID
	color = "#5C0120"
	addiction_threshold = 999
	taste_description = "jacksberries"
	trippy = FALSE
	overdose_threshold = 999
	metabolization_rate = 0.1 * REAGENTS_METABOLISM

/datum/reagent/drug/abyss/on_mob_metabolize(mob/living/M)
	var/mob/living/carbon/V = M
	V.add_stress(/datum/stressevent/abysssmoke)
	if(prob(10))
		M.emote(pick("drool","gasp"))
	if(prob(3))
		M.visible_message(span_notice("[M] feels slightly uneasy, [M.p_their()] gaze puzzled and distant."))
	..()

/datum/reagent/drug/abyss/on_mob_life(mob/living/carbon/M)
	if(HAS_TRAIT(M, TRAIT_TOXIMMUNE))
		M.adjustOxyLoss(0.1)
	M.apply_status_effect(/datum/status_effect/buff/abyss)
	..()
	. = 1

/datum/reagent/drug/abyss/overdose_process(mob/living/M)
	M.adjustToxLoss(0.1 * REAGENTS_EFFECT_MULTIPLIER, 0)
	M.adjustOxyLoss(1.1 * REAGENTS_EFFECT_MULTIPLIER, 0)
	..()
	. = 1
