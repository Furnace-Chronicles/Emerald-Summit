/obj/structure/ritualcircle
	name = "ritual circle"
	desc = ""
	icon = 'icons/roguetown/misc/rituals.dmi'
	icon_state = "ritual_base"
	var/icon/icon_active = "astrata_active"
	layer = BELOW_OBJ_LAYER
	density = FALSE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/datum/circle_rite/rites_datum
	var/datum/circle_rite/new_datum
	var/datum/circle_rite/our_rite

/obj/structure/ritualcircle/attack_right(mob/living/carbon/human/user)
	user.visible_message(span_warning("[user] begins wiping away the rune"))
	if(do_after(user, 15))
		playsound(loc, 'sound/foley/cloth_wipe (1).ogg', 100, TRUE)
		qdel(src)

/* DATUMIZED RITES
* attack_hand is called when we touch a rune
* we make a new_datum which is based on rune's set rites_datum
* if we actually do select a rite and shit, it makes our_rite
* if choose_host TRUE in rite datum, we then do the host selection
* then we do the yapping via middle_part()
* after yapping is concluded, rite_proc is called on our rite
* rite_proc() is the actual rite itself
* idk what else to say actually
* if we want something special sauce, we can overwrite our procs
* usual & average rites don't have to overwrite anything except for rite_proc()
* if you want special sauce thing, then overwrite either one of the following procs: middle_part(), choose_host() and rite_proc()
* also added debug rite to astrata, just remove // to make un-comment it out
*/
/datum/circle_rite // i smoke 2blunts
	var/name = "rite"
	var/desc = "yuh yuh"
	var/datum/patron/patron
	var/list/rites_list = list()
	var/list/rites_list_string = list()
	var/rituals_name = "BROO!! CHANGE THIS!!"
	var/block_rite = TRUE

	var/choose_host = FALSE
	var/choose_host_patron = FALSE // only used for heretics for now, so that we dont give armor to non-heretics
	var/patron_trait = ""

// can like have 0, can have 1 or 10 strings
	var/list/chant_strings = list(
		"Change this string 1",
		"Change this string 2",
		"Change this string 3"
	)
	var/talking_done = FALSE

	var/cooldown = /datum/status_effect/debuff/ritesexpended_high // _low_very, _low, _medium, _high
	var/obj/structure/ritualcircle/linked_circle
	var/mob/living/rite_target

/datum/circle_rite/proc/pre_rite(mob/living/carbon/human/user)
	if((user.patron?.type) != patron)
		to_chat(user, span_smallred("I don't know the proper rites for this..."))
		return
	if(!HAS_TRAIT(user, TRAIT_RITUALIST))
		to_chat(user, span_smallred("I don't know the proper rites for this...")) // You need ritualist to use them
		return

	var/datum/circle_rite/riteselection = input(user, "[rituals_name]", src) as null|anything in rites_list_string // When you use a open hand on a rune, It'll give you a selection of all the rites available from that rune
	if(riteselection) // User selects Guiding Light, begins the stuff for it
		var/datum/circle_rite/picked_datum
		for(var/datum/circle_rite/datumie as anything in rites_list)
			if("[riteselection]" == "[datumie.name]")
				picked_datum = datumie
				break
		if(picked_datum.block_rite)
			if(HAS_TRAIT(user, TRAIT_RITES_BLOCKED))
				to_chat(user, span_smallred("I have performed enough rituals for the day... I must rest before communing more."))
				return

		linked_circle.our_rite = new picked_datum
		linked_circle.our_rite.linked_circle = src.linked_circle

/datum/circle_rite/proc/choose_host(mob/living/carbon/human/user)
	var/onrune = range(0, linked_circle.loc)
	var/list/folksonrune = list()
	for(var/mob/living/carbon/human/persononrune in onrune)
		if(choose_host_patron)
			if(HAS_TRAIT(persononrune, patron_trait))
				folksonrune += persononrune
		else
			folksonrune += persononrune
	var/target = input(user, "Choose a host") as null|anything in folksonrune
	if(!target)
		return
	rite_target = target

/datum/circle_rite/proc/middle_part(mob/living/carbon/human/user)
	if(chant_strings)
		for(var/string in chant_strings)
			if(!do_after(user, 40))
				return
			user.say("[string]")
			chant_strings -= string

	linked_circle.icon_state = "[linked_circle.icon_active]"
	spawn(120) // swap to addtimer
		linked_circle.icon_state = initial(linked_circle.icon_state)
	talking_done = TRUE

/datum/circle_rite/proc/rite_proc(mob/living/carbon/human/user)
	to_chat(user, span_bloody("BASE PROC CALLED. DEFINE A SPECIFIC PROC"))
	return

// This'll be our tutorial ritual for those who want to make more later, let's go into details in comments, mm? - Onutsio 
/obj/structure/ritualcircle/astrata
	name = "Rune of the Sun" // defines name of the circle itself
	icon_state = "astrata_chalky" // the icon state, so, the sprite the runes use on the floor. As of making, we have 6, each needs an active/inactive state.
	icon_active = "astrata_active"
	desc = "A Holy Rune of Astrata. Warmth irradiates from the rune." // description on examine
	rites_datum = /datum/circle_rite/astrata

/obj/structure/ritualcircle/astrata/attack_hand(mob/living/user) // if i wanna be super sayan swag god i could use call() but that'd require passing args, even like datum parent of proc itself all the fucking time vro
	if(!our_rite)
		new_datum = new rites_datum
		new_datum.linked_circle = src
		new_datum.pre_rite(user)
		if(our_rite)
			if(our_rite.choose_host)
				our_rite.choose_host(user)
				if(!our_rite.rite_target)
					qdel(new_datum) // cleanup
					qdel(our_rite)
					new_datum = null
					our_rite = null
					return
			our_rite.middle_part(user)
			if(our_rite.talking_done)
				our_rite.rite_proc(user)

			qdel(new_datum) // cleanup
			qdel(our_rite)
			new_datum = null
			our_rite = null

/datum/circle_rite/astrata
	rites_list = list(
		/datum/circle_rite/astrata/guiding_light,
//		/datum/circle_rite/astrata/debug,
	)
	rites_list_string = list(
		"Guiding Light",
//		"Debug",
	)
	rituals_name = "Rituals of the Sun"
	patron = /datum/patron/divine/astrata

/datum/circle_rite/astrata/guiding_light
	name = "Guiding Light"
	chant_strings = list(
		"I beseech the she-form of the Twinned God!!",
		"To bring Order to a world of naught!!",
		"Place your gaze upon me, oh Radiant one!!"
	)
	cooldown = /datum/status_effect/debuff/ritesexpended_high

/datum/circle_rite/astrata/guiding_light/rite_proc(mob/living/carbon/human/user)
	to_chat(user, span_danger("You feel the eye of Astrata turned upon you. Her warmth dances upon your cheek. You feel yourself warming up..."))
	if(!HAS_TRAIT(user, TRAIT_CHOSEN)) //Priests don't burst into flames.
		linked_circle.loc.visible_message(span_warning("[user]'s bursts to flames! Embraced by Her Warmth wholly!"))
		playsound(linked_circle.loc, 'sound/combat/hits/burn (1).ogg', 100, FALSE, -1)
		user.adjust_fire_stacks(10)
		user.ignite_mob()
		user.flash_fullscreen("redflash3")
		user.emote("firescream")
	var/ritualtargets = view(7, linked_circle.loc)
	for(var/mob/living/carbon/human/target in ritualtargets) // defines the target as every human in this range
		target.apply_status_effect(/datum/status_effect/buff/guidinglight) // applies the status effect
		to_chat(target, span_cultsmall("Astrata's light guides me forward, drawn to me by the Ritualist's pyre!"))
		playsound(target, 'sound/magic/holyshield.ogg', 80, FALSE, -1) // Cool sound!
	user.apply_status_effect(cooldown)

/datum/circle_rite/astrata/debug
	name = "Debug"
	chant_strings = list(
		"yoshi city!!",
		"Tbrung it down yughnaught!!",
		"swag swag yoshi nt one!!"
	)
	choose_host = TRUE
	cooldown = /datum/status_effect/debuff/ritesexpended_low_very

/datum/circle_rite/astrata/debug/rite_proc(mob/living/carbon/human/user)
	to_chat(world, "user is [user]")
	to_chat(world, "rite_target is [rite_target]")
	rite_target.adjust_fire_stacks(10)
	rite_target.ignite_mob()
	to_chat(world, "name of the rite datum is [name]")
	to_chat(world, "cooldown is [cooldown]")
	user.apply_status_effect(cooldown)

/obj/structure/ritualcircle/noc
	name = "Rune of the Moon"
	icon_state = "noc_chalky"
	desc = "A Holy Rune of Noc. Moonlight shines upon thee."
	var/lunarrites = list("Moonlight Dance") // list for more to be added later

/obj/structure/ritualcircle/noc/attack_hand(mob/living/user)
	if((user.patron?.type) != /datum/patron/divine/noc)
		to_chat(user,span_smallred("I don't know the proper rites for this..."))
		return
	if(!HAS_TRAIT(user, TRAIT_RITUALIST))
		to_chat(user,span_smallred("I don't know the proper rites for this..."))
		return
	var/riteselection = input(user, "Rituals of the Moon", src) as null|anything in lunarrites
	switch(riteselection) // put ur rite selection here
		if("Moonlight Dance")
			if(HAS_TRAIT(user, TRAIT_RITES_BLOCKED))
				to_chat(user,span_smallred("I have performed enough rituals for the day... I must rest before communing more."))
				return
			if(do_after(user, 50))
				user.say("I beseech the he-form of the Twinned God!!")
				if(do_after(user, 50))
					user.say("To bring Wisdom to a world of naught!!")
					if(do_after(user, 50))
						user.say("Place your gaze upon me, oh wise one!!")
						to_chat(user,span_cultsmall("The waning half of the Twin-God carries but one eye. With some effort, it can be drawn upon supplicants."))
						playsound(loc, 'sound/magic/holyshield.ogg', 80, FALSE, -1)
						moonlightdance(src)
						user.apply_status_effect(/datum/status_effect/debuff/ritesexpended_high)

/obj/structure/ritualcircle/noc/proc/moonlightdance(src)
	var/ritualtargets = view(7, loc)
	for(var/mob/living/carbon/human/target in ritualtargets)
		target.apply_status_effect(/datum/status_effect/buff/moonlightdance)

/obj/structure/ritualcircle/xylix
	name = "Rune of Trickery"
	icon_state = "xylix_chalky" //mortosasye sprite
	desc = "A Holy Rune of Xylix. You can hear the wind and distant bells, in the distance."

/obj/structure/ritualcircle/ravox
	name = "Rune of Justice"
	icon_state = "ravox_chalky" // mortosasye sprite
	desc = "A Holy Rune of Ravox. A blade to protect the weak with." // whiteknight the god. bruh

/obj/structure/ritualcircle/pestra
	name = "Rune of Plague"
	desc = "A Holy Rune of Pestra. A sickle to cleanse the weeds and bring forth life."
	icon_state = "pestra_chalky"
	var/plaguerites = list("Flylord's Triage", "Continuity")

/obj/structure/ritualcircle/pestra/attack_hand(mob/living/user)
	if((user.patron?.type) != /datum/patron/divine/pestra)
		to_chat(user,span_smallred("I don't know the proper rites for this..."))
		return
	if(!HAS_TRAIT(user, TRAIT_RITUALIST))
		to_chat(user,span_smallred("I don't know the proper rites for this..."))
		return
	var/riteselection = input(user, "Rituals of Plague", src) as null|anything in plaguerites
	switch(riteselection) // put ur rite selection here
		if("Flylord's Triage")
			if(HAS_TRAIT(user, TRAIT_RITES_BLOCKED))
				to_chat(user, span_smallred("I have performed enough rituals for the day... I must rest before communing more."))
				return
			if(do_after(user, 50))
				user.say("Buboes, phlegm, blood and guts!!")
				if(do_after(user, 50))
					user.say("Boils, bogeys, rots and pus!!")
					if(do_after(user, 50))
						user.say("Blisters, fevers, weeping sores!!")
						to_chat(user,span_danger("You feel something crawling up your throat, humming and scratching..."))
						if(do_after(user, 30))
							icon_state = "pestra_active"
							user.say("From your wounds, the fester pours!!")
							to_chat(user,span_cultsmall("My devotion to the Plague Queen allowing, her servants crawl up from my throat. Come now, father fly..."))
							loc.visible_message(span_warning("[user] opens their mouth, disgorging a great swarm of flies!"))
							playsound(loc, 'sound/misc/fliesloop.ogg', 100, FALSE, -1)
							flylordstriage(src)
							user.apply_status_effect(/datum/status_effect/debuff/ritesexpended_low)
							spawn(120)
								icon_state = "pestra_chalky"
		if("Continuity")
			if(HAS_TRAIT(user, TRAIT_RITES_BLOCKED))
				to_chat(user, span_smallred("I have performed enough rituals for the day... I must rest before communing more."))
				return
			var/list/valid_bodies = range(0, src.loc)
			var/mob/living/carbon/human/target
			var/mob/living/carbon/human/transfer_target
			for(target in valid_bodies)
				var/target_head = target.get_bodypart(BODY_ZONE_HEAD)
				if(istype(target_head, /obj/item/bodypart/head/prosthetic/continuity_head))
					if(target.getorganslot(ORGAN_SLOT_BRAIN))
						transfer_target = target
						to_chat(user, span_hierophant("This shall suffice... Does it have eyes and ears, even?"))
						break
					else
						to_chat(user, span_bloody("The body is fine, except the brain is missing! I should check for the other organs, too..."))
						return
				else
					to_chat(user, span_bloody("There's no suitable body for the ritual!"))
					return
			if(transfer_target)
				var/list/valids_on_rune = list()
				for(var/mob/living/carbon/human/peep in range(1, loc))
					if(transfer_target != peep)
						valids_on_rune += peep
				var/mob/living/carbon/human/victim = input(user, "Choose a host") as null|anything in valids_on_rune
				if(!victim || QDELETED(victim) || !Adjacent(victim) || !user || QDELETED(user) || !Adjacent(user))
					return
				if(do_after(user, 20)) // jak this number
					user.say("Pestra, Pestra, let me continue, anew!!")
					if(do_after(user, 20)) // jak this number
						user.say("To live, for as long as I wish!!")
						if(do_after(user, 20)) // jak this number
							icon_state = "pestra_active"
//							user.apply_status_effect(/datum/status_effect/debuff/ritesexpended_high)
							spawn(120)
								icon_state = "pestra_chalky"
							pestra_continuity(victim, transfer_target)

/obj/structure/ritualcircle/pestra/proc/flylordstriage(src)
	var/ritualtargets = range(0, loc)
	for(var/mob/living/carbon/human/target in ritualtargets)
		to_chat(target,span_userdanger("You feel them crawling into your wounds and pores. Their horrific hum rings through your ears as they do their work!"))
		target.flash_fullscreen("redflash3")
		target.emote("agony")
		target.Stun(200)
		target.Knockdown(200)
		to_chat(target, span_userdanger("UNIMAGINABLE PAIN!"))
		target.apply_status_effect(/datum/status_effect/buff/flylordstriage)

/obj/structure/ritualcircle/pestra/proc/pestra_continuity(mob/living/carbon/human/victim, mob/living/carbon/human/transfer_target)
	ADD_TRAIT(victim, TRAIT_NOSSDINDICATOR, TRAIT_GENERIC)
	transfer_target.ckey = victim.ckey
	transfer_target.mind = victim.mind
	victim.set_current_skill_holder(transfer_target)
	if(victim.actions)
		transfer_target.actions = victim.actions
		for(var/X in transfer_target.actions)
			var/datum/action/A = X
			A.Grant(transfer_target)
	if(victim.devotion)
		transfer_target.devotion = victim.devotion
	if(victim.status_traits)
		transfer_target.status_traits = victim.status_traits
	if(victim.patron)
		transfer_target.patron = victim.patron
	if(victim.language_holder)
		transfer_target.language_holder = victim.language_holder
	transfer_target.update_action_buttons()
	transfer_target.revive(full_heal = TRUE) // ???
	spawn(60) // jak this number
		victim.faction -= "neutral" // or just make the list empty idk
		victim.say("What have I done!!", forced = TRUE)
		victim.emote("scream", forced = TRUE)
		victim.cmode = TRUE
		victim.aggressive = TRUE
		victim.rude = TRUE
		victim.mode = NPC_AI_COMBAT
		victim.flee_in_pain = FALSE
		victim.wander = FALSE
		victim.base_intents = list(INTENT_HARM)
		for(var/obj/item/rogueweapon/weapon in victim.contents)
			if(weapon)
				victim.put_in_hands(weapon, FALSE, FALSE, TRUE)
				if(weapon.bigboy)
					weapon.wielded = TRUE
				break
		victim.retaliate(transfer_target)
		REMOVE_TRAIT(victim, TRAIT_NOSSDINDICATOR, TRAIT_GENERIC)

/obj/structure/ritualcircle/dendor
	name = "Rune of Beasts"
	desc = "A Holy Rune of Dendor. Becoming one with nature is to connect with ones true instinct."
	icon_state = "dendor_chalky"
	var/bestialrites = list("Rite of the Lesser Wolf")

/obj/structure/ritualcircle/dendor/attack_hand(mob/living/user)
	if((user.patron?.type) != /datum/patron/divine/dendor)
		to_chat(user,span_smallred("I don't know the proper rites for this..."))
		return
	if(!HAS_TRAIT(user, TRAIT_RITUALIST))
		to_chat(user,span_smallred("I don't know the proper rites for this..."))
		return
	var/riteselection = input(user, "Rituals of Beasts", src) as null|anything in bestialrites
	switch(riteselection) // put ur rite selection here
		if("Rite of the Lesser Wolf")
			if(HAS_TRAIT(user, TRAIT_RITES_BLOCKED))
				to_chat(user,span_smallred("I have performed enough rituals for the day... I must rest before communing more."))
				return
			if(do_after(user, 50))
				user.say("RRRGH GRRRHHHG GRRRRRHH!!")
				playsound(loc, 'sound/vo/mobs/vw/idle (1).ogg', 100, FALSE, -1)
				if(do_after(user, 50))
					user.say("GRRRR GRRRRHHHH!!")
					playsound(loc, 'sound/vo/mobs/vw/idle (4).ogg', 100, FALSE, -1)
					if(do_after(user, 50))
						loc.visible_message(span_warning("[user] snaps and snarls at the rune. Drool runs down their lip..."))
						playsound(loc, 'sound/vo/mobs/vw/bark (1).ogg', 100, FALSE, -1)
						if(do_after(user, 30))
							icon_state = "dendor_active"
							loc.visible_message(span_warning("[user] snaps their head upward, they let out a howl!"))
							playsound(loc, 'sound/vo/mobs/wwolf/howl (2).ogg', 100, FALSE, -1)
							lesserwolf(src)
							user.apply_status_effect(/datum/status_effect/debuff/ritesexpended_high)
							spawn(120)
								icon_state = "dendor_chalky"

/obj/structure/ritualcircle/dendor/proc/lesserwolf(src)
	var/ritualtargets = range(1, loc)
	for(var/mob/living/carbon/human/target in ritualtargets)
		target.apply_status_effect(/datum/status_effect/buff/lesserwolf)


/obj/structure/ritualcircle/malum
	name = "Rune of Forge"
	desc = "A Holy Rune of Malum. A hammer and heat, to fix any imperfections with."
	icon_state = "malum_chalky"
var/forgerites = list("Ritual of Blessed Reforgance")

/obj/structure/ritualcircle/malum/attack_hand(mob/living/user)
	if((user.patron?.type) != /datum/patron/divine/malum)
		to_chat(user,span_smallred("I don't know the proper rites for this..."))
		return
	if(!HAS_TRAIT(user, TRAIT_RITUALIST))
		to_chat(user,span_smallred("I don't know the proper rites for this..."))
		return
	var/riteselection = input(user, "Rituals of Creation", src) as null|anything in forgerites
	switch(riteselection) // put ur rite selection here
		if("Ritual of Blessed Reforgance")
			if(HAS_TRAIT(user, TRAIT_RITES_BLOCKED))
				to_chat(user,span_smallred("I have performed enough rituals for the day... I must rest before communing more."))
				return
			if(do_after(user, 50))
				user.say("God of craft and heat of the forge!!")
				if(do_after(user, 50))
					user.say("Take forth these metals and rebirth them in your furnaces!")
					if(do_after(user, 50))
						user.say("Grant unto me the metals in which to forge great works!")
						to_chat(user,span_danger("You feel a sudden heat rising within you, burning within your chest.."))
						if(do_after(user, 30))
							icon_state = "malum_active"
							user.say("From your forge, may these creations be remade!!")
							loc.visible_message(span_warning("A wave of heat rushes out from the ritual circle before [user]. The metal is reforged in a flash of light!"))
							playsound(loc, 'sound/magic/churn.ogg', 100, FALSE, -1)
							holyreforge(src)
							user.apply_status_effect(/datum/status_effect/debuff/ritesexpended_high)
							spawn(120)
								icon_state = "malum_chalky"

/obj/structure/ritualcircle/malum/proc/holyreforge(src)
	var/ritualtargets = view(7, loc)
	for(var/mob/living/carbon/human/target in ritualtargets)
		target.flash_fullscreen("whiteflash") //Cool effect!
	for (var/obj/item/ingot/silver/I in loc)
		qdel(I)
		new /obj/item/ingot/silverblessed(loc)
	for (var/obj/item/ingot/steel/I in loc)
		qdel(I)
		new /obj/item/ingot/steelholy(loc)

/obj/structure/ritualcircle/abyssor
	name = "Rune of Storm"
	desc = "A Holy Rune of Abyssor"
	icon_state = "abyssor_chalky"
	var/stormrites = list("Rite of the Crystal Spire")

// Ritual implementation
/obj/structure/ritualcircle/abyssor/attack_hand(mob/living/user)
	if((user.patron?.type) != /datum/patron/divine/abyssor)
		to_chat(user,span_smallred("I don't know the proper rites for this..."))
		return
	if(!HAS_TRAIT(user, TRAIT_RITUALIST))
		to_chat(user,span_smallred("I don't know the proper rites for this..."))
		return
	if(user.has_status_effect(/datum/status_effect/debuff/ritesexpended))
		to_chat(user,span_smallred("I have performed enough rituals for the day... I must rest before communing more."))
		return
	var/riteselection = input(user, "Rituals of Storm", src) as null|anything in stormrites
	switch(riteselection)
		if("Rite of the Crystal Spire")
			if(do_after(user, 50))
				user.say("Deep Father, hear my call!")
				if(do_after(user, 50))
					user.say("From the Abyss, split the earth!")
					if(do_after(user, 50))
						icon_state = "abyssor_active"
						user.say("Let your tempest chase away the craven ones!")
						to_chat(user, span_cultsmall("A crystalline shard forms at the center of the rune, humming with Abyssor's power."))
						new /obj/item/abyssal_marker(loc)
						user.apply_status_effect(/datum/status_effect/debuff/ritesexpended)
						spawn(240)
							icon_state = "abyssor_chalky"

/obj/item/abyssal_marker
	name = "abyssal marker"
	desc = "A pulsating crystal shard that hums with otherworldly energy."
	icon = 'icons/roguetown/misc/rituals.dmi'
	icon_state = "abyssal_marker"
	w_class = WEIGHT_CLASS_SMALL
	var/turf/marked_location
	var/effect_desc = " Use in-hand to mark a location, then activate it to break the barrier between the dream and this realm where you put a mark down earlier. You recall the teachings of your Hierophant... these things are dangerous to all."
	var/obj/rune_type = /obj/structure/active_abyssor_rune
	var/faith_locked = TRUE
	var/obj/upgraded_rune_type = /obj/structure/active_abyssor_rune/greater

/obj/item/abyssal_marker/volatile
	name = "volatile abyssal marker"
	effect_desc = " Whispers fill your head. The crystal yearns to be used, it shall bring forth a beautiful dream. The first use shall mark, the second shall unleash. Seems fragile, like it might explode violently with energies when thrown..."
	faith_locked = FALSE
	icon_state = "abyssal_marker_volatile"
	var/cooldown = 0
	var/creation_time

/obj/item/abyssal_marker/tidal
	name = "tidal abyssal marker"
	desc = "A pulsating crystal shard that hums with the power of the deep. It feels wet to the touch."
	icon_state = "abyssal_marker_tidal"
	effect_desc = " Use in-hand to mark a location, then activate it to break the barrier between the dream and this realm where you put a mark down earlier. This one calls forth the tidal waters of the abyss."
	rune_type = /obj/structure/active_abyssor_rune/tidal
	upgraded_rune_type = null

/obj/item/abyssal_marker/volatile/Initialize()
	. = ..()
	creation_time = world.time
	var/area/A = get_area(src)
	if(istype(A, /area/rogue/underworld/dream))
		cooldown = 3 MINUTES

/obj/item/abyssal_marker/volatile/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(cooldown > 0 && world.time < creation_time + cooldown)
		visible_message(span_warning("[src] bounces off the floor. It doesn't seem ready yet."))
		return ..()

	var/turf/T = get_turf(hit_atom)
	if(T)
		marked_location = T
		visible_message(span_warning("[src] shatters on impact!"))
		playsound(src, 'sound/magic/lightning.ogg', 50, TRUE)
		var/mob/thrower = throwingdatum?.thrower
		if(thrower && HAS_TRAIT(thrower, TRAIT_HERESIARCH) && upgraded_rune_type)
			rune_type = upgraded_rune_type
		new rune_type(T)
		qdel(src)
	else
		return ..()

/obj/item/abyssal_marker/examine(mob/user)
	. = ..()
	if(iscarbon(user))
		var/mob/living/carbon/c = user
		if(c.patron.type == /datum/patron/divine/abyssor || !faith_locked)
			. += span_info(effect_desc)

/obj/item/abyssal_marker/attack_self(mob/user)
	if(iscarbon(user))
		var/mob/living/carbon/c = user
		if(c.patron.type != /datum/patron/divine/abyssor && faith_locked)
			to_chat(user, span_warning("My connection to Abyssor's dream is too weak to invoke his power with this crystal."))
			return ..()
		//Heretics get FAR stronger spires!
		if(HAS_TRAIT(user, TRAIT_HERESIARCH) && upgraded_rune_type)
			rune_type = upgraded_rune_type
	if(do_after(user, 2 SECONDS) && !marked_location)
		marked_location = get_turf(user)
		to_chat(user, span_notice("You charge the crystal with the essence of this location."))
		playsound(src, 'sound/magic/vlightning.ogg', 50, TRUE)
	else if (marked_location)
		user.visible_message(span_warning("[user] crushes the [src] in their hands!"))
		playsound(src, 'sound/magic/lightning.ogg', 50, TRUE)
		new rune_type(marked_location)
		qdel(src)

/obj/item/abyssal_marker/volatile/attack_self(mob/user)
	if(cooldown > 0 && world.time < creation_time + cooldown)
		to_chat(user, span_warning("The crystal is still unstable. It needs more time to attune to this realm. Try again later."))
		return
	return ..()

/obj/structure/active_abyssor_rune
	name = "awakened abyssal rune"
	desc = "A violently pulsating rune emitting storm energy."
	icon = 'icons/roguetown/misc/rituals.dmi'
	icon_state = "abyssoralt_active"
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	density = FALSE
	light_outer_range = 3
	light_color = LIGHT_COLOR_BLUE
	var/spawn_time = 10 SECONDS
	var/obj/spire_type = /obj/structure/crystal_spire

/obj/structure/active_abyssor_rune/tidal
	spire_type = /obj/structure/crystal_spire/tidal
	icon_state = "abyssor_active"

/obj/structure/active_abyssor_rune/greater
	spire_type = /obj/structure/crystal_spire/greater

/obj/structure/active_abyssor_rune/Initialize()
	. = ..()
	addtimer(CALLBACK(src, .proc/spawn_spire), spawn_time)
	src.visible_message(span_userdanger("A glowing, pulsating rune etches itself into the ground. Reality cracks visibly around it! Something is coming!"))

/obj/structure/active_abyssor_rune/proc/spawn_spire()
	new spire_type(get_turf(src))

#define ABYSSAL_GLOW_FILTER "abyssal_glow"

// Crystal Spire Structure
/obj/structure/crystal_spire
	name = "crystal spire"
	desc = "A massive crystalline structure pulsing with abyssal energy. Dark ice spreads from its base."
	icon = 'icons/roguetown/misc/rituals.dmi'
	icon_state = "crystal_spire"
	anchored = TRUE
	density = TRUE
	resistance_flags = FIRE_PROOF | ACID_PROOF
	max_integrity = 500
	var/current_radius = 1
	var/max_radius = 4
	var/fiend_count = 0
	var/max_fiends = 3
	// Holds all the turf data so it can be unconverted.
	var/list/turf_data = list()
	var/expansion_timer = 3 MINUTES
	var/next_expansion_time = 0
	var/spawn_timer = 45 SECONDS
	var/next_fiend_time = 0
	var/awakened = FALSE
	var/converting = FALSE
	var/mob/living/initial_fiend = /mob/living/simple_animal/hostile/rogue/dreamfiend/major/unbound
	pixel_y = 8

/obj/structure/crystal_spire/greater
	name = "greater crystal spire"
	initial_fiend = /mob/living/simple_animal/hostile/rogue/dreamfiend/ancient/unbound
	max_integrity = 1000
	max_radius = 5
	max_fiends = 10

/obj/structure/crystal_spire/tidal/process()
	if(world.time >= next_expansion_time && current_radius < max_radius || !awakened)
		if(!awakened)
			awakened = TRUE
		expand_radius()
		next_expansion_time = world.time + expansion_timer

/obj/structure/crystal_spire/Destroy()
	for(var/turf/T in turf_data)
		T.ChangeTurf(turf_data[T], flags = CHANGETURF_IGNORE_AIR)
	turf_data.Cut()

	for(var/obj/structure/active_abyssor_rune/R in range(1, src))
		qdel(R)

	src.visible_message(span_danger("The spire shatters with a painful ringing. In an instant the dream recedes back to Abyssor's realm, restoring the world as it was."))
	STOP_PROCESSING(SSobj, src)
	playsound(src, 'sound/foley/glassbreak.ogg', 50, TRUE)
	new /obj/effect/particle_effect/smoke(src.loc)

	var/list/witnesses = view(7, src)
	for(var/mob/living/carbon/human/H in witnesses)
		teleport_to_dream(H, 1000, 1)

	return ..()

/obj/structure/crystal_spire/proc/start_conversion()
	converting = TRUE
	resistance_flags |= INDESTRUCTIBLE

	add_filter(ABYSSAL_GLOW_FILTER, 2, list("type" = "outline", "color" = "#6A0DAD", "alpha" = 0, "size" = 2))
	update_icon()

/obj/structure/crystal_spire/proc/end_conversion()
	converting = FALSE
	resistance_flags &= ~INDESTRUCTIBLE

	remove_filter(ABYSSAL_GLOW_FILTER)
	update_icon()

/obj/structure/crystal_spire/proc/convert_surroundings()
	start_conversion()
	var/turf/center = get_turf(src)
	var/radius_sq = current_radius * current_radius

	for(var/turf/T in spiral_range_turfs(current_radius, center))
		// Skip if already converted
		if(istype(T, /turf/open/floor/rogue/dark_ice))
			continue

		// Calculate distance from center
		// P.S I hate math :)
		var/dx = abs(T.x - center.x)
		var/dy = abs(T.y - center.y)
		var/dist_sq = dx*dx + dy*dy

		// Skip corners with higher probability
		var/is_corner = (dx == dy) || (dx == current_radius && dy == current_radius)
		if(is_corner && prob(60))
			continue

		// Skip random tiles (10% chance)
		if(prob(10))
			continue

		// Only convert tiles within circular radius
		if(dist_sq <= radius_sq)
			turf_data[T] = T.type
			T.ChangeTurf(/turf/open/floor/rogue/dark_ice, flags = CHANGETURF_IGNORE_AIR)
			playsound(T, 'sound/magic/fleshtostone.ogg', 30, TRUE)
			sleep(10)

	end_conversion()

/obj/structure/crystal_spire/proc/expand_radius()
	if(current_radius >= max_radius)
		return

	current_radius++
	convert_surroundings()

/obj/structure/crystal_spire/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)
	if(converting)
		visible_message(span_warning("The spire pulses with abyssal energy, deflecting the attack!"))
		playsound(src, 'sound/magic/repulse.ogg', 50, TRUE)
		return FALSE
	return ..()

/obj/structure/crystal_spire/proc/spawn_spire_fiend(turf/spawn_turf, obj/structure/crystal_spire/spire, mob/living/fiend_type = /mob/living/simple_animal/hostile/rogue/dreamfiend/unbound)
	if(!spawn_turf || !spire || !ispath(fiend_type))
		return FALSE

	var/mob/living/F = new fiend_type(spawn_turf)
	F.visible_message(span_danger("[F] manifests, countless teeth bared in hostility towards all life!"))

	var/datum/component/comp = F.AddComponent(/datum/component/spire_fiend, spire)
	return comp ? TRUE : FALSE

/obj/structure/crystal_spire/proc/spawn_fiends(amount, mob/living/fiend_type = /mob/living/simple_animal/hostile/rogue/dreamfiend/unbound)
	if(fiend_count >= max_fiends)
		return

	for(var/i in 1 to amount)
		if(fiend_count >= max_fiends)
			break

		var/turf/T = find_safe_spawn()
		if(T && spawn_spire_fiend(T, src, fiend_type))
			fiend_count++

/obj/structure/crystal_spire/proc/find_safe_spawn(outer_tele_radius = 3, inner_tele_radius = 2, include_dense = FALSE, include_teleport_restricted = FALSE)
	var/turf/target_turf = get_turf(src)
	var/list/turfs = list()

	for(var/turf/T in range(target_turf, outer_tele_radius))
		if(T in range(target_turf, inner_tele_radius))
			continue
		if(istransparentturf(T))
			continue
		if(T.density && !include_dense)
			continue
		if(T.teleport_restricted && !include_teleport_restricted)
			continue
		if(T.x>world.maxx-outer_tele_radius || T.x<outer_tele_radius)
			continue
		if(T.y>world.maxy-outer_tele_radius || T.y<outer_tele_radius)
			continue
		turfs += T

	if(!length(turfs))
		for(var/turf/T in orange(target_turf, outer_tele_radius))
			if(!(T in orange(target_turf, inner_tele_radius)))
				turfs += T

	if(!length(turfs))
		return null

	return pick(turfs)

/obj/structure/crystal_spire/proc/fiend_died()
	fiend_count = max(fiend_count - 1, 0)

/datum/component/spire_fiend
	var/obj/structure/crystal_spire/linked_spire

/datum/component/spire_fiend/Initialize(obj/structure/crystal_spire/spire)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	linked_spire = spire
	RegisterSignal(parent, COMSIG_LIVING_DEATH, .proc/on_death)

/datum/component/spire_fiend/proc/on_death()
	SIGNAL_HANDLER
	if(linked_spire)
		linked_spire.fiend_died()
	qdel(src)

/obj/structure/ritualcircle/abyssor_alt
	name = "Rune of Stirring"
	desc = "A Holy Rune of Abyssor. This one seems different to the rest. Something observes."
	icon_state = "abyssoralt_active"

/obj/structure/ritualcircle/abyssor_alt_inactive
	name = "Rune of Stirring"
	desc = "A Holy Rune of Abyssor. This one seems different to the rest. Something observes."
	icon_state = "abyssoralt_chalky"
	var/stirringrites = list("Rite of the Crystal Spire")
	var/list/dreamwalker_rites = list("Rite of Dreamcraft")

// Ritual implementation
/obj/structure/ritualcircle/abyssor_alt_inactive/attack_hand(mob/living/user)
	if((user.patron?.type) != /datum/patron/divine/abyssor)
		to_chat(user,span_smallred("I don't know the proper rites for this..."))
		return
	if(!HAS_TRAIT(user, TRAIT_RITUALIST))
		to_chat(user,span_smallred("I don't know the proper rites for this..."))
		return
	if(user.has_status_effect(/datum/status_effect/debuff/ritesexpended))
		to_chat(user,span_smallred("I have performed enough rituals for the day... I must rest before communing more."))
		return

	// Build available rites based on user's status
	var/list/available_rites = list()

	// Abyssorites get access to stirring rites
	if(user.patron?.type == /datum/patron/divine/abyssor)
		available_rites += stirringrites

		// Time check for Rite of the Crystal Spire
		var/time_elapsed = STATION_TIME_PASSED() / (1 MINUTES)
		if(time_elapsed < 30 && ("Rite of the Crystal Spire" in available_rites))
			var/time_left = 30 - time_elapsed
			to_chat(user, span_smallred("The veil is too thin to summon crystal spires. Wait another [round(time_left, 0.1)] minutes."))
			available_rites -= "Rite of the Crystal Spire"

	if(HAS_TRAIT(user, TRAIT_DREAMWALKER))
		available_rites += dreamwalker_rites

	if(!length(available_rites))
		to_chat(user,span_smallred("No rites are currently available."))
		return
	var/riteselection = input(user, "Rites of his dream", src) as null|anything in available_rites
	switch(riteselection)
		if("Rite of the Crystal Spire")
			if(do_after(user, 50))
				user.say("Deep Father, hear my call!")
				if(do_after(user, 50))
					user.say("From the Abyss, split the earth!")
					if(do_after(user, 50))
						icon_state = "abyssoralt_active"
						user.say("Let your tempest chase away the craven ones!")
						to_chat(user, span_cultsmall("A crystalline shard forms at the center of the rune, humming with Abyssor's power."))
						new /obj/item/abyssal_marker(loc)
						user.apply_status_effect(/datum/status_effect/debuff/ritesexpended)
						spawn(240)
							icon_state = "abyssoralt_chalky"
		if("Rite of Dreamcraft")
			if(!HAS_TRAIT(user, TRAIT_DREAMWALKER))
				return

			var/list/weapon_options = list(
				"Dreamreaver Greataxe" = image(icon = 'icons/roguetown/weapons/64.dmi', icon_state = "dreamaxe"),
				"Harmonious Spear" = image(icon = 'icons/roguetown/weapons/64.dmi', icon_state = "dreamspear"),
				"Oozing Sword" = image(icon = 'icons/roguetown/weapons/64.dmi', icon_state = "dreamsword"),
				"Thunderous Trident" = image(icon = 'icons/roguetown/weapons/64.dmi', icon_state = "dreamtri")
			)

			var/choice = show_radial_menu(user, src, weapon_options, require_near = TRUE, tooltips = TRUE)
			if(!choice)
				return
			if(!do_after(user, 5 SECONDS))
				return
			user.say("DREAM! DREAM! MANIFEST MY VISION!!")
			if(!do_after(user, 5 SECONDS))
				return
			user.say("DREAM! DREAM! BEND TO MY WILL!!")
			if(!do_after(user, 5 SECONDS))
				return
			user.say("DREAM! DREAM! FORGE MY WEAPON!!")
			if(!do_after(user, 5 SECONDS))
				return

			icon_state = "abyssoralt_active"
			user.apply_status_effect(/datum/status_effect/debuff/ritesexpended)
			dreamarmor(user)
			dreamcraft_weapon(user, choice)
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				if(H.mind)
					H.mind.special_role = "dreamwalker"
			spawn(240)
				icon_state = "abyssoralt_chalky"

/obj/structure/ritualcircle/abyssor_alt_inactive/proc/dreamcraft_weapon(mob/living/user, choice)
	var/obj/item/new_weapon
	var/datum/skill/skill_to_teach

	switch(choice)
		if("Harmonious Spear")
			new_weapon = new /obj/item/rogueweapon/halberd/glaive/dreamscape(user.loc)
			skill_to_teach = /datum/skill/combat/polearms
		if("Oozing Sword")
			new_weapon = new /obj/item/rogueweapon/greatsword/bsword/dreamscape(user.loc)
			skill_to_teach = /datum/skill/combat/swords
		if("Dreamreaver Greataxe")
			new_weapon = new /obj/item/rogueweapon/greataxe/dreamscape(user.loc)
			skill_to_teach = /datum/skill/combat/axes
		if("Thunderous Trident")
			new_weapon = new /obj/item/rogueweapon/spear/dreamscape_trident(user.loc)
			skill_to_teach = /datum/skill/combat/polearms

	if(new_weapon)
		user.put_in_hands(new_weapon)
		to_chat(user, span_warning("The dream solidifies into a [choice]!"))

		var/current_skill = user.get_skill_level(skill_to_teach)
		var/current_athletics = user.get_skill_level(/datum/skill/misc/athletics)
		if(current_skill < 4)
			user.adjust_skillrank_up_to(skill_to_teach, 4)
			to_chat(user, span_notice("Knowledge of [skill_to_teach] floods your mind!"))
		if(current_athletics < 6)
			user.adjust_skillrank_up_to(/datum/skill/misc/athletics, 6)
			to_chat(user, span_notice("Your endurance swells!"))
	else
		to_chat(user, span_warning("The dream fails to take shape."))

/obj/structure/ritualcircle/abyssor_alt_inactive/proc/dreamarmor(mob/living/carbon/human/target)
	if(!HAS_TRAIT(target, TRAIT_DREAMWALKER))
		loc.visible_message(span_cult("THE RITE REJECTS ONE WHO DOES NOT BEND THE DREAMS TO THEIR WILL."))
		return
	target.Stun(60)
	target.Knockdown(60)
	to_chat(target, span_userdanger("UNIMAGINABLE PAIN!"))
	target.emote("Agony")
	playsound(loc, 'sound/combat/newstuck.ogg', 50)
	loc.visible_message(span_cult("Ethereal tendrils emerge from the rune, wrapping around [target]'s body. Their form shifts and warps as dream-stuff solidifies into armor."))
	spawn(20)
		playsound(loc, 'sound/combat/hits/onmetal/grille (2).ogg', 50)
		target.equipOutfit(/datum/outfit/job/roguetown/dreamwalker_armorrite)
		target.apply_status_effect(/datum/status_effect/debuff/devitalised)
		spawn(40)
			to_chat(target, span_purple("Reality is but a fragile dream. You are the dreamer, and your will is law."))

/obj/structure/ritualcircle/abyssor/attack_hand(mob/living/user)
	// Allow both Abyssorites and Dreamwalkers to use the rune
	if((user.patron?.type) != /datum/patron/divine/abyssor && !HAS_TRAIT(user, TRAIT_DREAMWALKER))
		to_chat(user,span_smallred("I don't know the proper rites for this..."))
		return
	if(!HAS_TRAIT(user, TRAIT_RITUALIST))
		to_chat(user,span_smallred("I don't know the proper rites for this..."))
		return
	var/riteselection = input(user, "Rituals of the Storm", src) as null|anything in stormrites
	switch(riteselection)
		if("Rite of the Abyssal Call")
			if(HAS_TRAIT(user, TRAIT_RITES_BLOCKED))
				to_chat(user,span_smallred("I have performed enough rituals for the day... I must rest before communing more."))
				return
			if(do_after(user, 50))
				user.say("#ABYSSOR! LORD OF THE DEEP WATERS!")
				if(do_after(user, 50))
					user.say("#HEED MY CALL, MASTER OF THE ABYSS!")
				if(do_after(user, 50))
					user.say("#BRING FORTH YOUR SACRED ANGLER!")
				if(do_after(user, 50))
					icon_state = "abyssoralt_active"
					loc.visible_message(span_warning("[user] completes the ritual, and an angler fish materializes from the depths!"))
					to_chat(user,span_cultsmall("Abyssor's power flows through the rune, summoning a sacred angler fish from the abyss!"))
					playsound(loc, 'sound/foley/waterenter.ogg', 100, FALSE, -1)
					abyssor_angler_summoning_ritual(src)
					user.apply_status_effect(/datum/status_effect/debuff/ritesexpended_low_very)
					spawn(120)
						icon_state = "abyssor_chalky"

/obj/structure/ritualcircle/abyssor/proc/abyssor_angler_summoning_ritual(src)
	// Create an ultra rare angler fish at the ritual location
	var/obj/item/reagent_containers/food/snacks/fish/angler/angler_fish = new(loc)
	angler_fish.icon_state = "anglerultra"
	angler_fish.name = "ultra-rare anglerfish"
	angler_fish.desc = "A menacing abyssal predator summoned by Abyssor's power. Its bioluminescent lure pulses with otherworldly energy."
	angler_fish.sellprice = 60 
	angler_fish.dead = TRUE
	angler_fish.rarity_rank = 2

/obj/structure/ritualcircle/necra
	name = "Rune of Death"
	desc = "A Holy Rune of Necra. Quiet acceptance stirs within you."
	icon_state = "necra_chalky"
	var/deathrites = list("Undermaiden's Bargain", "Vow to the Undermaiden")

/obj/structure/ritualcircle/necra/attack_hand(mob/living/user)
	if((user.patron?.type) != /datum/patron/divine/necra)
		to_chat(user,span_smallred("I don't know the proper rites for this..."))
		return
	if(!HAS_TRAIT(user, TRAIT_RITUALIST))
		to_chat(user,span_smallred("I don't know the proper rites for this..."))
		return
	var/riteselection = input(user, "Rituals of Death", src) as null|anything in deathrites
	switch(riteselection) // put ur rite selection here
		if("Undermaiden's Bargain")
			if(HAS_TRAIT(user, TRAIT_RITES_BLOCKED))
				to_chat(user,span_smallred("I have performed enough rituals for the day... I must rest before communing more."))
				return
			loc.visible_message(span_warning("[user] sways before the rune, they open their mouth, though no words come out..."))
			playsound(user, 'sound/vo/mobs/ghost/whisper (3).ogg', 100, FALSE, -1)
			if(do_after(user, 60))
				loc.visible_message(span_warning("[user] silently weeps, yet their tears do not flow..."))
				playsound(user, 'sound/vo/mobs/ghost/whisper (1).ogg', 100, FALSE, -1)
				if(do_after(user, 60))
					loc.visible_message(span_warning("[user] locks up, as though someone had just grabbed them..."))
					to_chat(user,span_danger("You feel cold breath on the back of your neck..."))
					playsound(user, 'sound/vo/mobs/ghost/death.ogg', 100, FALSE, -1)
					if(do_after(user, 20))
						icon_state = "necra_active"
						user.say("Forgive me, the bargain is intoned!!")
						to_chat(user,span_cultsmall("My devotion to the Undermaiden has allowed me to strike a bargain for these souls...."))
						playsound(loc, 'sound/vo/mobs/ghost/moan (1).ogg', 100, FALSE, -1)
						undermaidenbargain(src)
						user.apply_status_effect(/datum/status_effect/debuff/ritesexpended_high)
						spawn(120)
							icon_state = "necra_chalky"
		if("Vow to the Undermaiden")
			if(HAS_TRAIT(user, TRAIT_RITES_BLOCKED))
				to_chat(user,span_smallred("I have performed enough rituals for the day... I must rest before communing more."))
				return
			if(user.construct)//golems can't benefit from miracles so they can't do this
				to_chat(user,span_warning("My body is already cold and lifeless. I have nothing to pledge."))
				return
			loc.visible_message(span_warning("[user] sways before the rune, they open their mouth, though no words come out..."))
			playsound(user, 'sound/vo/mobs/ghost/whisper (3).ogg', 100, FALSE, -1)
			if(do_after(user, 60))
				loc.visible_message(span_warning("[user] silently weeps, yet their tears do not flow..."))
				playsound(user, 'sound/vo/mobs/ghost/whisper (1).ogg', 100, FALSE, -1)
				if(do_after(user, 60))
					loc.visible_message(span_warning("[user] locks up, as though someone had just grabbed them..."))
					to_chat(user,span_danger("You feel cold breath on the back of your neck..."))
					playsound(user, 'sound/vo/mobs/ghost/death.ogg', 100, FALSE, -1)
					if(do_after(user, 20))
						icon_state = "necra_active"
						user.say("This soul pledges themselves to thee!!")
						to_chat(user,span_cultsmall("My devotion to the Undermaiden has allowed me to anoint a vow for this soul...."))
						if(undermaidenvow(src))
							playsound(loc, 'sound/vo/mobs/ghost/moan (1).ogg', 100, FALSE, -1)
							user.apply_status_effect(/datum/status_effect/debuff/ritesexpended_high)
							spawn(120)
								icon_state = "necra_chalky"
						else
							loc.visible_message(span_warning("Then... nothing. The Undermaiden does not care for the vows of the damned, or those of other faiths."))



/obj/structure/ritualcircle/necra/proc/undermaidenbargain(src)
	var/ritualtargets = view(7, loc)
	for(var/mob/living/carbon/human/target in ritualtargets)
		target.apply_status_effect(/datum/status_effect/buff/undermaidenbargain)
	
/obj/structure/ritualcircle/necra/proc/undermaidenvow(src)
	var/ritualtargets = range(1, loc)
	for(var/mob/living/carbon/human/target in ritualtargets)
		if(HAS_TRAIT(target, TRAIT_ROTMAN) || HAS_TRAIT(target, TRAIT_NOBREATH) || target.mob_biotypes & MOB_UNDEAD)	//No Undead, no Rotcured, no Deathless
			return FALSE
		if(target.patron.type != /datum/patron/divine/necra)
			return FALSE
		target.apply_status_effect(/datum/status_effect/buff/necras_vow)
		target.apply_status_effect(/datum/status_effect/buff/healing/necras_vow)
		return TRUE
	return FALSE

/obj/structure/ritualcircle/eora
	name = "Rune of Love"
	desc = "A Holy Rune of Eora. A gentle warmth and joy spreads across your soul."
	icon_state = "eora_chalky"

	var/peacerites = list("Rite of Pacification")

/obj/structure/ritualcircle/eora/attack_hand(mob/living/user)
	if((user.patron?.type) != /datum/patron/divine/eora)
		to_chat(user,span_smallred("I don't know the proper rites for this..."))
		return
	if(!HAS_TRAIT(user, TRAIT_RITUALIST))
		to_chat(user,span_smallred("I don't know the proper rites for this..."))
		return
	var/riteselection = input(user, "Rituals of Love", src) as null|anything in peacerites
	switch(riteselection) // put ur rite selection here
		if("Rite of Pacification")
			if(HAS_TRAIT(user, TRAIT_RITES_BLOCKED))
				to_chat(user,span_smallred("I have performed enough rituals for the day... I must rest before communing more."))
				return
			if(do_after(user, 50))
				user.say("#Blessed be your weary head...")
				if(do_after(user, 50))
					user.say("#Full of strife and pain...")
					if(do_after(user, 50))
						user.say("#Let Her ease your fear...")
						if(do_after(user, 50))
							icon_state = "eora_active"
							pacify(src)
							user.apply_status_effect(/datum/status_effect/debuff/ritesexpended_high)
							spawn(120)
								icon_state = "eora_chalky"

/obj/structure/ritualcircle/eora/proc/pacify(src)
	var/ritualtargets = range(0, loc)
	for(var/mob/living/carbon/human/target in ritualtargets)
		loc.visible_message(span_warning("[target] sways like windchimes in the wind..."))
		target.visible_message(span_green("I feel the burdens of my heart lifting. Something feels very wrong... I don't mind at all..."))
		target.apply_status_effect(/datum/status_effect/buff/pacify)

// up the psy

/obj/structure/ritualcircle/psydon // done as a joke, but it is good for Psydonites to decorate with.
	name = "Rune of Enduring"
	desc = "A Holy Rune of Psydon. It depicts His holy symbol, yet nothing stirs within you."
	icon_state = "psydon_chalky" // mortosasye

// TIME FOR THE ASCENDANT. These can be stronger. As they are pretty much antag exclusive - Iconoclast for Matthios, Lich for ZIZO. ZIZO!


/obj/structure/ritualcircle/zizo
	name = "Rune of Progress"
	desc = "A Holy Rune of ZIZO. Progress at any cost."
	icon_state = "zizo_chalky"
	var/zizorites = list("Rite of Armaments", "Rite of the Dark Crystal", "Path of Rituos")

/obj/structure/ritualcircle/zizo/attack_hand(mob/living/user)
	if((user.patron?.type) != /datum/patron/inhumen/zizo)
		to_chat(user,span_smallred("I don't know the proper rites for this..."))
		return
	if(!HAS_TRAIT(user, TRAIT_RITUALIST))
		to_chat(user,span_smallred("I don't know the proper rites for this..."))
		return
	var/riteselection = input(user, "Rituals of Progress", src) as null|anything in zizorites
	switch(riteselection)
		if("Rite of Armaments")
			if(HAS_TRAIT(user, TRAIT_RITES_BLOCKED))
				to_chat(user,span_smallred("I have performed enough rituals for the day... I must rest before communing more."))
				return
			var/onrune = range(1, loc)
			var/list/folksonrune = list()
			for(var/mob/living/carbon/human/persononrune in onrune)
				if(HAS_TRAIT(persononrune, TRAIT_CABAL))
					folksonrune += persononrune
			var/target = input(user, "Choose a host") as null|anything in folksonrune
			if(!target)
				return
			if(do_after(user, 50))
				user.say("ZIZO! ZIZO! DAME OF PROGRESS!!")
				if(do_after(user, 50))
					user.say("ZIZO! ZIZO! HEED MY CALL!!")
					if(do_after(user, 50))
						user.say("ZIZO! ZIZO! ARMS TO SLAY THE IGNORANT!!")
						if(do_after(user, 50))
							icon_state = "zizo_active"
							user.apply_status_effect(/datum/status_effect/debuff/ritesexpended_high)
							zizoarmaments(target)
							spawn(120)
								icon_state = "zizo_chalky"
		if("Rite of the Dark Crystal")
			if(HAS_TRAIT(user, TRAIT_RITES_BLOCKED))
				to_chat(user,span_smallred("I have performed enough rituals for the day... I must rest before communing more."))
				return
			if(do_after(user, 50))
				user.say("ZIZO! ZIZO! DAME OF PROGRESS!!")
				if(do_after(user, 50))
					user.say("ZIZO! ZIZO! GRANT THE CABAL THEIR RELIC!!")
					if(do_after(user, 50))
						user.say("ZIZO! ZIZO! THE DARK CRYSTAL TO COMMAND THE DEAD!!")
						if(do_after(user, 50))
							icon_state = "zizo_active"
							user.apply_status_effect(/datum/status_effect/debuff/ritesexpended_high)
							new /obj/item/necro_relics/necro_crystal(loc)
							loc.visible_message(span_purple("A dark crystal materializes in the center of the ritual circle, pulsing with necromantic energy!"))
							spawn(120)
								icon_state = "zizo_chalky"
		if("Path of Rituos")
			if(HAS_TRAIT(user, TRAIT_RITES_BLOCKED))
				to_chat(user,span_smallred("I have performed enough rituals for the day... I must rest before communing more."))
				return
			if(!Adjacent(user))
				to_chat(user, "You must stand close to the rune to receive Zizo's blessing.")
				return
			var/list/valids_on_rune = list()
			for(var/mob/living/carbon/human/peep in range(0, loc))
				if(HAS_TRAIT(peep, TRAIT_CABAL))
					valids_on_rune += peep
			if(!valids_on_rune.len)
				loc.visible_message(span_cult("THE RITE REJECTS ONE NOT OF THE CABAL!"))
				return
			var/mob/living/carbon/human/target = input(user, "Choose a host") as null|anything in valids_on_rune
			if(!target || QDELETED(target) || target.loc != loc)
				return
			if(do_after(user, 50))
				user.say("ZIZO! ZIZO! DAME OF PROGRESS!!")
				if(do_after(user, 50))
					user.say("ZIZO! ZIZO! HEED MY CALL!!")
					if(do_after(user, 50))
						user.say("ZIZO! ZIZO! STRIP OUR BONE OF ANY FLESH!!")
						if(do_after(user, 50))
							icon_state = "zizo_active"							
							rituosbone(target)
							user.apply_status_effect(/datum/status_effect/debuff/ritesexpended_high)
							spawn(120)
								icon_state = "zizo_chalky"


/obj/structure/ritualcircle/zizo/proc/zizoarmaments(src)
	var/onrune = range(0, loc)
	var/list/possible_targets = list()
	for(var/mob/living/carbon/human/persononrune in onrune)
		possible_targets += persononrune
	var/mob/living/carbon/human/target
	if(possible_targets.len)
		target = pick(possible_targets)
	else
		to_chat(usr, "No valid targets are standing on the rune! You must stand directly on the rune to receive Zizo's blessing.")
		return
	if(!HAS_TRAIT(target, TRAIT_CABAL))
		loc.visible_message(span_cult("THE RITE REJECTS ONE NOT OF THE CABAL"))
		return
	target.Stun(60)
	target.Knockdown(60)
	to_chat(target, span_userdanger("UNIMAGINABLE PAIN!"))
	target.emote("Agony")
	playsound(loc, 'sound/combat/newstuck.ogg', 50)
	if(HAS_TRAIT(target, TRAIT_INFINITE_STAMINA) || (target.mob_biotypes & MOB_UNDEAD))
		loc.visible_message(span_cult("Great hooks come from the rune, embedding into [target]'s ankles, pulling them onto the rune. Then, into their wrists. As their black, rotten lux is torn from their chest, the very essence of their body surges to form it into armor. "))
		target.Paralyze(120)
	else
		loc.visible_message(span_cult("Great hooks come from the rune, embedding into [target]'s ankles, pulling them onto the rune. Then, into their wrists. Their lux is torn from their chest, and reforms into armor. "))
	spawn(20)
		playsound(loc, 'sound/combat/hits/onmetal/grille (2).ogg', 50)
		target.equipOutfit(/datum/outfit/job/roguetown/darksteelrite)
		spawn(40)
			to_chat(target, span_purple("They are ignorant, backwards, without hope. You. You will be powerful."))

/datum/outfit/job/roguetown/darksteelrite/pre_equip(mob/living/carbon/human/H)
	..()
	var/list/items = list()
	items |= H.get_equipped_items(TRUE)
	for(var/I in items)
		H.dropItemToGround(I, TRUE)
	H.drop_all_held_items()
	armor = /obj/item/clothing/suit/roguetown/armor/plate/full/zizo
	pants = /obj/item/clothing/under/roguetown/platelegs/zizo
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor/zizo
	gloves = /obj/item/clothing/gloves/roguetown/plate/zizo
	head = /obj/item/clothing/head/roguetown/helmet/heavy/zizo
	backr = /obj/item/rogueweapon/sword/long/zizo
	neck = /obj/item/clothing/neck/roguetown/bevor


/obj/structure/ritualcircle/zizo/proc/rituosbone(mob/living/carbon/human/target)
	if(!target || QDELETED(target) || target.loc != loc)
		to_chat(usr, "Selected target is not on the rune! [target.p_they(TRUE)] must be directly on top of the rune to receive Zizo's blessing.")
		return
	if (!HAS_TRAIT(target, TRAIT_CABAL))
		loc.visible_message(span_cult("THE RITE REJECTS ONE NOT OF THE CABAL!"))
		return
	if (target.mob_biotypes & MOB_UNDEAD)
		loc.visible_message(span_cult("YOU HAVE NO MORE LYFE TO GIVE, FOR YOUR HEART DOES NOT BEAT!"))
		return
	if (target.mind?.has_antag_datum(/datum/antagonist/vampire/lesser))
		loc.visible_message(span_cult("YOU HAVE NO MORE LYFE TO GIVE, FOR YOUR HEART DOES NOT BEAT, CHILDE OF KAIN!"))
		return
	if (target.mind?.has_antag_datum(/datum/antagonist/werewolf/lesser))
		loc.visible_message(span_cult("YOU ARE CURSED BY DENDOR, UNDESERVING OF UNLYFE!"))
		return
	target.Stun(60)
	target.Knockdown(60)
	to_chat(target, span_userdanger("UNIMAGINABLE PAIN!"))
	target.emote("Agony")
	playsound(loc, 'sound/misc/astratascream.ogg', 50)
	loc.visible_message(span_cult("The pallor of the grave descends across [target]'s skin in a wave of arcyne energy... Then, their flesh is flayed, revealing a ghastly bone, blood splattering all around them."))
	spawn(20)
		playsound(loc, 'sound/combat/dismemberment/dismem (6).ogg', 50)
		playsound(target, 'sound/health/slowbeat.ogg', 50)
		target.mind?.RemoveSpell(new /obj/effect/proc_holder/spell/targeted/touch/prestidigitation) // gotta remove presiistitititginanon if you had one to avoid getting double
		ADD_TRAIT(target, TRAIT_NOHUNGER, "[type]")
		ADD_TRAIT(target, TRAIT_NOBREATH, "[type]")
		ADD_TRAIT(target, TRAIT_NOPAIN, "[type]")
		ADD_TRAIT(target, TRAIT_TOXIMMUNE, "[type]")
		ADD_TRAIT(target, TRAIT_STEELHEARTED, "[type]")
		ADD_TRAIT(target, TRAIT_INFINITE_STAMINA, "[type]")
		ADD_TRAIT(target, TRAIT_BLOODLOSS_IMMUNE, "[type]")
		ADD_TRAIT(target, TRAIT_LIMBATTACHMENT, "[type]")
		ADD_TRAIT(target, TRAIT_EASYDISMEMBER, "[type]")
		if (!HAS_TRAIT(target, TRAIT_ARCYNE_T3) && !HAS_TRAIT(target, TRAIT_ARCYNE_T4) || HAS_TRAIT(target, TRAIT_ARCYNE_T2))
			REMOVE_TRAIT(target, TRAIT_ARCYNE_T2, "[type]")
			ADD_TRAIT(target, TRAIT_ARCYNE_T3, "[type]")
		target.dna.species.species_traits |= NOBLOOD
		target.change_stat("speed", -1)
		target.change_stat("constitution", -2)
		var/arcyne_level = target.get_skill_level(/datum/skill/magic/arcane) // mages get better spellcasting skill, still no access to the greater fireball sloppp, should they??
		if (arcyne_level >= 3)
			target.adjust_skillrank(/datum/skill/magic/arcane, 1, TRUE)
		else
			target.adjust_skillrank(/datum/skill/magic/arcane, 3, TRUE)
		target.mind?.AddSpell(new /obj/effect/proc_holder/spell/targeted/touch/prestidigitation) // gotta remove if you already have it fuck?
		target.mind?.adjust_spellpoints(18)
		target.mob_biotypes |= MOB_UNDEAD
		spawn(40)
			to_chat(target, span_purple("They are ignorant, backwards, without hope. You. You will be powerful."))
		var/obj/item/bodypart/no_penis = target.getorganslot(ORGAN_SLOT_PENIS)
		if(no_penis)
			qdel(no_penis)
		var/obj/item/bodypart/no_vagina = target.getorganslot(ORGAN_SLOT_VAGINA)
		if(no_vagina)
			qdel(no_vagina)
		var/obj/item/bodypart/no_balls = target.getorganslot(ORGAN_SLOT_TESTICLES)
		if(no_balls)
			qdel(no_balls)
		var/obj/item/bodypart/no_breasts = target.getorganslot(ORGAN_SLOT_BREASTS)
		if(no_breasts)
			qdel(no_breasts)
		var/list/body_parts = target.bodyparts.Copy()
		for(var/obj/item/bodypart/part in body_parts)
			part.skeletonize(FALSE)
		var/list/eyes_replaced = target.internal_organs.Copy()
		var/obj/item/organ/eyes/eyes = target.getorganslot(eyes_replaced) // #define ORGAN_SLOT_PENIS "penis" ORGAN_SLOT_TESTICLES "testicles" ORGAN_SLOT_BREASTS "breasts" ORGAN_SLOT_VAGINA "vagina" do I wanna bother
		eyes = new /obj/item/organ/eyes/night_vision/zombie
		eyes.Insert(target)
		target.update_body_parts(TRUE)
		target.ritual_skeletonization = TRUE



/obj/structure/ritualcircle/matthios
	name = "Rune of Transaction"
	desc = "A Holy Rune of Matthios. All has a price."
	icon_state = "matthios_chalky"
	var/matthiosrites = list("Rite of Armaments")


/obj/structure/ritualcircle/matthios/attack_hand(mob/living/user)
	if((user.patron?.type) != /datum/patron/inhumen/matthios)
		to_chat(user,span_smallred("I don't know the proper rites for this..."))
		return
	if(!HAS_TRAIT(user, TRAIT_RITUALIST))
		to_chat(user,span_smallred("I don't know the proper rites for this..."))
		return
	var/riteselection = input(user, "Rituals of Transaction", src) as null|anything in matthiosrites
	switch(riteselection) // put ur rite selection here
		if("Rite of Armaments")
			if(HAS_TRAIT(user, TRAIT_RITES_BLOCKED))
				to_chat(user,span_smallred("I have performed enough rituals for the day... I must rest before communing more."))
				return
			var/onrune = view(1, loc)
			var/list/folksonrune = list()
			for(var/mob/living/carbon/human/persononrune in onrune)
				if(HAS_TRAIT(persononrune, TRAIT_COMMIE))
					folksonrune += persononrune
			var/target = input(user, "Choose a host") as null|anything in folksonrune
			if(!target)
				return
			if(do_after(user, 50))
				user.say("Gold and Silver, he feeds!!")
				if(do_after(user, 50))
					user.say("Pieces Tens, Hundreds, Thousands. The transactor feeds 'pon them all!!")
					if(do_after(user, 50))
						user.say("Arms to claim, Arms to take!!")
						if(do_after(user, 50))
							icon_state = "matthios_active"
							user.apply_status_effect(/datum/status_effect/debuff/ritesexpended_high)
							matthiosarmaments(target)
							spawn(120)
								icon_state = "matthios_chalky"

/obj/structure/ritualcircle/matthios/proc/matthiosarmaments(mob/living/carbon/human/target)
	if(!HAS_TRAIT(target, TRAIT_COMMIE))
		loc.visible_message(span_cult("THE RITE REJECTS ONE WITHOUT GREED IN THEIR HEART!!"))
		return
	target.Stun(60)
	target.Knockdown(60)
	to_chat(target, span_userdanger("UNIMAGINABLE PAIN!"))
	target.emote("Agony")
	playsound(loc, 'sound/misc/smelter_fin.ogg', 50)
	if(HAS_TRAIT(target, TRAIT_INFINITE_STAMINA) || (target.mob_biotypes & MOB_UNDEAD))
		loc.visible_message(span_cult("[target]'s rotten lux pours from their nose like viscous tar, sizzling and bubbling around the rune. The solution erupts upwards, searing their skin!"))
		target.adjustFireLoss(200) //This gets spread across all limbs, 500+ is needed before it knocks someone out.
		playsound(src,'sound/misc/lava_death.ogg', rand(30,60), TRUE)
		return
	loc.visible_message(span_cult("[target]'s lux pours from their nose, into the rune, gleaming golds sizzles. Molten gold and metals swirl into armor, seered to their skin."))
	spawn(20)
		playsound(loc, 'sound/combat/hits/onmetal/grille (2).ogg', 50)
		target.equipOutfit(/datum/outfit/job/roguetown/gildedrite)
		// target.apply_status_effect(/datum/status_effect/debuff/devitalised) // Removed: do not consume lux
		spawn(40)
			to_chat(target, span_cult("More to the maw, this shall help feed our greed."))


/datum/outfit/job/roguetown/gildedrite/pre_equip(mob/living/carbon/human/H)
	..()
	var/list/items = list()
	items |= H.get_equipped_items(TRUE)
	for(var/I in items)
		H.dropItemToGround(I, TRUE)
	H.drop_all_held_items()
	armor = /obj/item/clothing/suit/roguetown/armor/plate/full/matthios
	pants = /obj/item/clothing/under/roguetown/platelegs/matthios
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor/matthios
	gloves = /obj/item/clothing/gloves/roguetown/plate/matthios
	head = /obj/item/clothing/head/roguetown/helmet/heavy/matthios
	neck = /obj/item/clothing/neck/roguetown/chaincoif/chainmantle
	backr = /obj/item/rogueweapon/flail/peasantwarflail/matthios



/obj/structure/ritualcircle/graggar
	name = "Rune of Violence"
	desc = "A Holy Rune of Graggar. Fate broken once, His gift is true freedom for all."
	icon_state = "graggar_chalky"
	var/graggarrites = list("Rite of Armaments")

/obj/structure/ritualcircle/graggar/attack_hand(mob/living/user)
	if((user.patron?.type) != /datum/patron/inhumen/graggar)
		to_chat(user,span_smallred("I don't know the proper rites for this..."))
		return
	if(!HAS_TRAIT(user, TRAIT_RITUALIST))
		to_chat(user,span_smallred("I don't know the proper rites for this..."))
		return
	var/riteselection = input(user, "Rituals of Violence", src) as null|anything in graggarrites
	switch(riteselection) // put ur rite selection here
		if("Rite of Armaments")
			if(HAS_TRAIT(user, TRAIT_RITES_BLOCKED))
				to_chat(user,span_smallred("I have performed enough rituals for the day... I must rest before communing more."))
				return
			var/onrune = view(1, loc)
			var/list/folksonrune = list()
			for(var/mob/living/carbon/human/persononrune in onrune)
				if(HAS_TRAIT(persononrune, TRAIT_HORDE))
					folksonrune += persononrune
			var/target = input(user, "Choose a host") as null|anything in folksonrune
			if(!target)
				return
			if(do_after(user, 50))
				user.say("Motive force, oh, violence!!")
				if(do_after(user, 50))
					user.say("A gorgeous buffet of violence, for you, for you!!")
					if(do_after(user, 50))
						user.say("A slaughter awaits!!")
						if(do_after(user, 50))
							icon_state = "graggar_active"
							user.apply_status_effect(/datum/status_effect/debuff/ritesexpended_high)
							graggararmor(target)
							spawn(120)
								icon_state = "graggar_chalky" 

/obj/structure/ritualcircle/graggar/proc/graggararmor(src)
	var/onrune = range(0, loc)
	var/list/possible_targets = list()
	for(var/mob/living/carbon/human/persononrune in onrune)
		possible_targets += persononrune
	var/mob/living/carbon/human/target
	if(possible_targets.len)
		target = pick(possible_targets)
	else
		to_chat(usr, "No valid targets are standing on the rune! You must stand directly on the rune to receive Graggar's blessing.")
		return
	if(!HAS_TRAIT(target, TRAIT_HORDE))
		loc.visible_message(span_cult("THE RITE REJECTS ONE WITHOUT SLAUGHTER IN THEIR HEART!!"))
		return
	target.Stun(60)
	target.Knockdown(60)
	to_chat(target, span_userdanger("UNIMAGINABLE PAIN!"))
	target.emote("Agony")
	playsound(loc, 'sound/misc/smelter_fin.ogg', 50)
	if(HAS_TRAIT(target, TRAIT_INFINITE_STAMINA) || (target.mob_biotypes & MOB_UNDEAD))
		loc.visible_message(span_cult("[target]'s rotten lux pours from their nose like viscous tar, sizzling and bubbling around the rune. The solution erupts upwards, searing their skin!"))
		target.adjustFireLoss(200) //This gets spread across all limbs, 500+ is needed before it knocks someone out.
		playsound(src,'sound/misc/lava_death.ogg', rand(30,60), TRUE)
		return
	loc.visible_message(span_cult("[target]'s lux pours from their nose, into the rune, motive and metals swirl into armor, snug around their form!"))
	spawn(20)
		playsound(loc, 'sound/combat/hits/onmetal/grille (2).ogg', 50)
		target.equipOutfit(/datum/outfit/job/roguetown/viciousrite)
		// target.apply_status_effect(/datum/status_effect/debuff/devitalised) // Removed: do not consume lux
		spawn(40)
			to_chat(target, span_cult("Break them."))

/datum/outfit/job/roguetown/viciousrite/pre_equip(mob/living/carbon/human/H)
	..()
	var/list/items = list()
	items |= H.get_equipped_items(TRUE)
	for(var/I in items)
		H.dropItemToGround(I, TRUE)
	H.drop_all_held_items()
	armor = /obj/item/clothing/suit/roguetown/armor/plate/fluted/graggar
	pants = /obj/item/clothing/under/roguetown/platelegs/graggar
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor/graggar
	gloves = /obj/item/clothing/gloves/roguetown/plate/graggar
	head = /obj/item/clothing/head/roguetown/helmet/heavy/graggar
	neck = /obj/item/clothing/neck/roguetown/gorget/steel
	cloak = /obj/item/clothing/cloak/graggar
	r_hand = /obj/item/rogueweapon/greataxe/steel/doublehead/graggar

/obj/structure/ritualcircle/baotha
	name = "Rune of Hedonism"
	desc = "A Holy Rune of Baotha. Relief for the broken hearted."
	icon_state = "baotha_chalky"

/obj/structure/ritualcircle/psydon // done as a joke, but it is good for Psydonites to decorate with.
	name = "Rune of Enduring"
	desc = "A Holy Rune of Psydon. It depicts His holy symbol, yet nothing stirs within you."
	icon_state = "psydon_chalky"
