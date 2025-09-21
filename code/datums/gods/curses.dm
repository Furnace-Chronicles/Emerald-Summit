/mob/living/carbon/human
	var/list/curses = list()
	COOLDOWN_DECLARE(priest_curse)
	COOLDOWN_DECLARE(priest_apostasy)

/mob/living/carbon/human/proc/handle_curses()
    for(var/curse in curses)
        var/datum/curse/C = curse
        C.on_life(src)

/mob/living/carbon/human/proc/add_curse(datum/curse/C)
	if(is_cursed(C))
		return FALSE

	C = new C()
	curses += C
	var/curse_resist = FALSE
	if(HAS_TRAIT(src, TRAIT_CURSE_RESIST))
		curse_resist = 0.5
	C.on_gain(src, curse_resist)
	return TRUE

/mob/living/carbon/human/proc/remove_curse(datum/curse/C)
	if(!is_cursed(C))
		return FALSE

	var/curse_resist = FALSE
	if(HAS_TRAIT(src, TRAIT_CURSE_RESIST))
		curse_resist = 0.5
	for(var/datum/curse/curse in curses)
		if(curse.name == C.name)
			curse.on_loss(src, curse_resist)
			curses -= curse
			return TRUE
	return FALSE

/mob/living/carbon/human/proc/is_cursed(datum/curse/C)
    if(!C)
        return FALSE

    for(var/datum/curse/curse in curses)
        if(curse.name == C.name)
            return TRUE
    return FALSE

/datum/curse
    var/name = "Debug Curse"
    var/description = "This is a debug curse."
    var/trait

/datum/curse/proc/on_life(mob/living/carbon/human/owner)
    return

/datum/curse/proc/on_death(mob/living/carbon/human/owner)
    return

/datum/curse/proc/on_gain(mob/living/carbon/human/owner)
    ADD_TRAIT(owner, trait, TRAIT_CURSE)
    to_chat(owner, span_userdanger("Something is wrong... I feel cursed."))
    to_chat(owner, span_danger(description))
    owner.playsound_local(get_turf(owner), 'sound/misc/excomm.ogg', 80, FALSE, pressure_affected = FALSE)
    return

/datum/curse/proc/on_loss(mob/living/carbon/human/owner)
    REMOVE_TRAIT(owner, trait, TRAIT_CURSE)
    to_chat(owner, span_userdanger("Something has changed... I feel relieved."))
    owner.playsound_local(get_turf(owner), 'sound/misc/bell.ogg', 80, FALSE, pressure_affected = FALSE)
    qdel(src)
    return

//////////////////////
///   TEN CURSES   ///
//////////////////////

/datum/curse/astrata
	name = "Curse of Astrata"
	description = "I am forsaken by the Sun. I will find no rest under Her unwavering gaze."
	trait = TRAIT_CURSE_ASTRATA

/datum/curse/abyssor
    name = "Abyssor's Curse"
    description = "I hear the ocean whisper in my mind. Fear of drowning has left me... but so has reason."
    trait = TRAIT_CURSE_ABYSSOR

/datum/curse/dendor
	name = "Curse of Dendor"
	description = "I am forsaken by the Treefather. Reason and common sense abandon me."
	trait = TRAIT_CURSE_DENDOR

/datum/curse/eora
    name = "Eora's Curse"
    description = "I am unable to show any kind of affection or love, whether carnal or platonic."
    trait = TRAIT_CURSE_EORA

/datum/curse/malum
    name = "Malum's Curse"
    description = "My thoughts race with endless designs I cannot build. The tools tremble in my hands."
    trait = TRAIT_CURSE_MALUM

/datum/curse/noc
	name = "Curse of Noc"
	description = "I am forsaken by the Moon. I will find no salvation in His grace."
	trait = TRAIT_CURSE_NOC

/datum/curse/necra
    name = "Necra's Curse"
    description = "Necra has claimed my soul. No one will bring me back from the dead."
    trait = TRAIT_CURSE_NECRA

/datum/curse/pestra
    name = "Pestra's Curse"
    description = "I feel sick to my stomach, and my skin is slowly starting to rot."
    trait = TRAIT_CURSE_PESTRA

/datum/curse/ravox
    name = "Ravox's Curse"
    description = "Violence disgusts me. I cannot bring myself to wield any kind of weapon."
    trait = TRAIT_CURSE_RAVOX

////////////////////////////
///   ASCENDANT CURSES   ///
////////////////////////////
/datum/curse/zizo
	name = "Curse of Zizo"
	description = "I am forsaken by the Architect. Her grasp reaches for my heart."
	trait = TRAIT_CURSE_ZIZO

/datum/curse/graggar
	name = "Curse of Graggar"
	description = "I am forsaken by the Warlord. Bloodlust is only thing I know for real."
	trait = TRAIT_CURSE_GRAGGAR

/datum/curse/matthios
	name = "Curse of Matthios"
	description = "I am forsaken by the Dragon. Greed will be my only salvation."
	trait = TRAIT_CURSE_MATTHIOS

/datum/curse/baotha
	name = "Curse of Baotha"
	description = "I am forsaken by the Heartbreaker. I am drowning in her promises."
	trait = TRAIT_CURSE_BAOTHA

//////////////////////
///	ON LIFE	 ///
//////////////////////

//Astrata's Curse

/datum/curse/astrata/on_life(mob/user)
	if(!user)
		return
	var/mob/living/carbon/human/H = user
	if(H.stat == DEAD)
		return
	if(H.advsetup)
		return

	if(world.time % 5)
		if(GLOB.tod != "night")
			if(isturf(H.loc))
				var/turf/T = H.loc
				if(T.can_see_sky())
					if(T.get_lumcount() > 0.15)
						H.fire_act(1,5)

//Noc's Curse

/datum/curse/noc/on_life(mob/user)
	if(!user)
		return
	var/mob/living/carbon/human/H = user
	if(H.stat == DEAD)
		return
	if(H.advsetup)
		return

	if(world.time % 5)
		if(GLOB.tod != "day")
			if(isturf(H.loc))
				var/turf/T = H.loc
				if(T.can_see_sky())
					if(T.get_lumcount() > 0.15)
						H.fire_act(1,5)

//Pestra's Curse

/datum/curse/pestra/on_life(mob/living/carbon/human/owner)
	. = ..()
	if(owner.mob_timers["pestra_curse"])
		if(world.time < owner.mob_timers["pestra_curse"] + rand(30,60)SECONDS)
			return
	owner.mob_timers["pestra_curse"] = world.time
	var/effect = rand(1, 3)
	switch(effect)
		if(1)
			owner.vomit()
		if(2)
			owner.Unconscious(20)
		if(3)
			owner.blur_eyes(10)

//////////////////////
/// ON GAIN / LOSS ///
//////////////////////

//TENNITES//

//ASTRATA//
/datum/curse/astrata/on_gain(mob/living/carbon/human/owner, curse_resist = FALSE)
	. = ..()
	if(curse_resist && prob(50))
		return
	ADD_TRAIT(owner, TRAIT_NOSLEEP, TRAIT_CURSE)

/datum/curse/astrata/on_loss(mob/living/carbon/human/owner, curse_resist = FALSE)
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_NOSLEEP, TRAIT_CURSE)

//NECRA//
/datum/curse/necra/on_gain(mob/living/carbon/human/owner, curse_resist = FALSE)
	. = ..()
	owner.STACON -= (10 * (1 - curse_resist))
	if(curse_resist && prob(50))
		return
	ADD_TRAIT(owner, TRAIT_CRITICAL_WEAKNESS, TRAIT_CURSE)

/datum/curse/necra/on_loss(mob/living/carbon/human/owner, curse_resist = FALSE)
	. = ..()
	owner.STACON += (10 * (1 - curse_resist))
	REMOVE_TRAIT(owner, TRAIT_CRITICAL_WEAKNESS, TRAIT_CURSE)

//PESTRA//
/datum/curse/pestra/on_gain(mob/living/carbon/human/owner, curse_resist = FALSE)
	. = ..()
	owner.STAEND -= (10 * (1 - curse_resist))
	if(curse_resist && prob(50))
		return
	ADD_TRAIT(owner, TRAIT_NORUN, TRAIT_CURSE)
	ADD_TRAIT(owner, TRAIT_MISSING_NOSE, TRAIT_CURSE)

/datum/curse/pestra/on_loss(mob/living/carbon/human/owner, curse_resist = FALSE)
	. = ..()
	owner.STAEND += (10 * (1 - curse_resist))
	REMOVE_TRAIT(owner, TRAIT_NORUN, TRAIT_CURSE)
	REMOVE_TRAIT(owner, TRAIT_MISSING_NOSE, TRAIT_CURSE)

//XYLIX//
/datum/curse/xylix/on_gain(mob/living/carbon/human/owner, curse_resist = FALSE)
	. = ..()
	owner.STALUC -= (20 * (1 - curse_resist))

/datum/curse/xylix/on_loss(mob/living/carbon/human/owner, curse_resist = FALSE)
	. = ..()
	owner.STALUC += (20 * (1 - curse_resist))

//EORA//
/datum/curse/eora/on_gain(mob/living/carbon/human/owner, curse_resist = FALSE)
	. = ..()
	var/curse_chance = (100 * (1 - curse_resist))
	if(prob(curse_chance))
		ADD_TRAIT(owner, TRAIT_LIMPDICK, TRAIT_CURSE)
	if(!HAS_TRAIT(owner, TRAIT_BEAUTIFUL)) // Eora has already endowed you with beauty and would not want to make you ugly.
		if(prob(curse_chance))
			ADD_TRAIT(owner, TRAIT_UNSEEMLY, TRAIT_CURSE)
	if(prob(curse_chance))
		ADD_TRAIT(owner, TRAIT_BAD_MOOD, TRAIT_CURSE)

/datum/curse/eora/on_loss(mob/living/carbon/human/owner, curse_resist = FALSE)
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_LIMPDICK, TRAIT_CURSE)
	if(HAS_TRAIT(owner, TRAIT_UNSEEMLY))
		REMOVE_TRAIT(owner, TRAIT_UNSEEMLY, TRAIT_CURSE)
	REMOVE_TRAIT(owner, TRAIT_BAD_MOOD, TRAIT_CURSE)

//ASCENDANTS//

//ZIZO//
/datum/curse/zizo/on_gain(mob/living/carbon/human/owner, curse_resist = FALSE)
	. = ..()
	owner.STAINT -= (20 * (1 - curse_resist))
	ADD_TRAIT(owner, TRAIT_SPELLCOCKBLOCK, TRAIT_CURSE)

/datum/curse/zizo/on_loss(mob/living/carbon/human/owner, curse_resist = FALSE)
	. = ..()
	owner.STAINT += (20 * (1 - curse_resist))
	REMOVE_TRAIT(owner, TRAIT_SPELLCOCKBLOCK, TRAIT_CURSE)

//GRAGGAR//
/datum/curse/graggar/on_gain(mob/living/carbon/human/owner, curse_resist = FALSE)
	. = ..()
	owner.STASTR -= (14 * (1 - curse_resist))
	ADD_TRAIT(owner, TRAIT_DISFIGURED, TRAIT_CURSE)
	ADD_TRAIT(owner, TRAIT_INHUMEN_ANATOMY, TRAIT_CURSE)

/datum/curse/graggar/on_loss(mob/living/carbon/human/owner, curse_resist = FALSE)
	. = ..()
	owner.STASTR += (14 * (1 - curse_resist))
	REMOVE_TRAIT(owner, TRAIT_DISFIGURED, TRAIT_CURSE)
	REMOVE_TRAIT(owner, TRAIT_INHUMEN_ANATOMY, TRAIT_CURSE)

//MATTHIOS//
/datum/curse/matthios/on_gain(mob/living/carbon/human/owner, curse_resist = FALSE)
	. = ..()
	owner.STALUC -= (14 * (1 - curse_resist))
	ADD_TRAIT(owner, TRAIT_CLUMSY, TRAIT_CURSE)

/datum/curse/matthios/on_loss(mob/living/carbon/human/owner, curse_resist = FALSE)
	. = ..()
	owner.STALUC += (14 * (1 - curse_resist))
	REMOVE_TRAIT(owner, TRAIT_CLUMSY, TRAIT_CURSE)

//BAOTHA//
/datum/curse/baotha/on_gain(mob/living/carbon/human/owner, curse_resist = FALSE)
	. = ..()
	var/curse_chance = (100 * (1 - curse_resist))
	if(prob(curse_chance))
		ADD_TRAIT(owner, TRAIT_NUDIST, TRAIT_CURSE)
	if(prob(curse_chance))
		ADD_TRAIT(owner, TRAIT_NUDE_SLEEPER, TRAIT_CURSE)
	if(prob(curse_chance))
		ADD_TRAIT(owner, TRAIT_LIMPDICK, TRAIT_CURSE)

/datum/curse/baotha/on_loss(mob/living/carbon/human/owner, curse_resist = FALSE)
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_NUDIST, TRAIT_CURSE)
	REMOVE_TRAIT(owner, TRAIT_NUDE_SLEEPER, TRAIT_CURSE)
	REMOVE_TRAIT(owner, TRAIT_LIMPDICK, TRAIT_CURSE)
