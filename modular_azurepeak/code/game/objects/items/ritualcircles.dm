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
	var/bestialrites = list("Rite of the Lesser Wolf","Borrowed Madness","Spider Kinship")

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
		if("Borrowed Madness")
			if(HAS_TRAIT(user, TRAIT_RITES_BLOCKED))
				to_chat(user,span_smallred("I have performed enough rituals for the day... I must rest before communing more."))
				return
			if(do_after(user, 50))
				user.say("I pray for strength...")
				playsound(loc, 'sound/vo/mobs/vw/idle (1).ogg', 100, FALSE, -1)
				if(do_after(user, 50))
					user.say("I pray for pain...")
					playsound(loc, 'sound/vo/mobs/vw/idle (4).ogg', 100, FALSE, -1)
					if(do_after(user, 50))
						loc.visible_message(span_warning("[user] produces an eerie as they titter quietly, softly weeping. Their body twitches ever so slightly..."))
						playsound(loc, 'sound/vo/mobs/vw/bark (1).ogg', 100, FALSE, -1)
						if(do_after(user, 30))
							icon_state = "dendor_active"
							loc.visible_message(span_warning("[user] suddenly snaps their head upward, letting out a twisted howl!"))
							playsound(loc, 'sound/vo/mobs/wwolf/howl (2).ogg', 100, FALSE, -1)
							requestmadness(src)
							user.apply_status_effect(/datum/status_effect/debuff/ritesexpended_high)
							spawn(120)
								icon_state = "dendor_chalky"
		if("Spider Kinship")
			if(HAS_TRAIT(user, TRAIT_RITES_BLOCKED))
				to_chat(user,span_smallred("I have performed enough rituals for the day... I must rest before communing more."))
				return
			if(do_after(user, 50))
				user.say("I call to the ruthless wilds,")
				playsound(loc, 'sound/vo/mobs/spider/idle (1).ogg', 100, FALSE, -1)
				if(do_after(user, 50))
					user.say("... grant me an agile form of your dominion..!")
					playsound(loc, 'sound/vo/mobs/spider/idle (3).ogg', 100, FALSE, -1)
					if(do_after(user, 30))
						icon_state = "dendor_active"
						loc.visible_message(span_warning("[user] seizes up, suddenly covered in a mess of silky webs, which then slough away into a sticky pile!"))
						playsound(loc, 'sound/vo/mobs/spider/pain.ogg', 100, FALSE, -1)
						spiderkin(src)
						user.apply_status_effect(/datum/status_effect/debuff/ritesexpended_high)
						spawn(120)
							icon_state = "dendor_chalky"								

/obj/structure/ritualcircle/dendor/proc/lesserwolf(src)
	var/ritualtargets = range(1, loc)
	for(var/mob/living/carbon/human/target in ritualtargets)
		target.apply_status_effect(/datum/status_effect/buff/lesserwolf)

/obj/structure/ritualcircle/dendor/proc/requestmadness(src)
	var/ritualtargets = range(0, loc)
	for(var/mob/living/carbon/human/target in ritualtargets)
		if((target.patron?.type) != /datum/patron/divine/dendor)
			to_chat(target, span_warning("The ritual's power does not recognize me..."))
			continue
		to_chat(target,span_userdanger("Do you like hurting other people?"))
		target.flash_fullscreen("redflash3")
		target.emote("agony")
		target.Unconscious(200)
		target.Knockdown(200)
		target.mind?.AddSpell(new /obj/effect/proc_holder/spell/targeted/shapeshift/dendormole)

/obj/structure/ritualcircle/dendor/proc/spiderkin(src)
	var/ritualtargets = range(0, loc)
	for(var/mob/living/carbon/human/target in ritualtargets)
		if((target.patron?.type) != /datum/patron/divine/dendor)
			to_chat(target, span_warning("The ritual's power does not recognize me..."))
			continue
		to_chat(target,span_userdanger("The webs of madness and nature whisper to me. The webs are eternal. Long live the Nest!"))
		target.flash_fullscreen("redflash3")
		target.emote("agony")
		target.Unconscious(100)
		target.Knockdown(200)
		target.mind?.AddSpell(new /obj/effect/proc_holder/spell/targeted/shapeshift/mireboi)

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
	desc = "A Holy Rune of Abyssor. You sense your mind getting pulled into the drawn spiral."
	icon_state = "abyssor_chalky" // mortosasye
	var/stormrites = list("Rite of the Abyssal Call")

/obj/structure/ritualcircle/abyssor_alt // For future use with more malicious rituals, for example.
	name = "Rune of Stirring"
	desc = "A Holy Rune of Abyssor. This one seems different to the rest. Something observes."
	icon_state = "abyssoralt_active" // change to abyssoralt_chalky if adding a new ritual, and use the active state instead for it.

/obj/structure/ritualcircle/abyssor/attack_hand(mob/living/user)
	if((user.patron?.type) != /datum/patron/divine/abyssor)
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
		target.equipOutfit(/datum/outfit/job/darksteelrite)
		spawn(40)
			to_chat(target, span_purple("They are ignorant, backwards, without hope. You. You will be powerful."))

/datum/outfit/job/darksteelrite/pre_equip(mob/living/carbon/human/H)
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
	if (target.mind?.has_antag_datum(/datum/antagonist/vampire))
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
		ADD_TRAIT(target, TRAIT_INFINITE_ENERGY, "[type]")
		ADD_TRAIT(target, TRAIT_SLOW_SWIMMER, "[type]")
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
		target.equipOutfit(/datum/outfit/job/gildedrite)
		// target.apply_status_effect(/datum/status_effect/debuff/devitalised) // Removed: do not consume lux
		spawn(40)
			to_chat(target, span_cult("More to the maw, this shall help feed our greed."))


/datum/outfit/job/gildedrite/pre_equip(mob/living/carbon/human/H)
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
		target.equipOutfit(/datum/outfit/job/viciousrite)
		// target.apply_status_effect(/datum/status_effect/debuff/devitalised) // Removed: do not consume lux
		spawn(40)
			to_chat(target, span_cult("Break them."))

/datum/outfit/job/viciousrite/pre_equip(mob/living/carbon/human/H)
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
	name = "Rune of Desire"
	desc = "A Holy Rune of Baotha. Relief for the broken hearted."
	icon_state = "baotha_chalky" // mortosasye
	var/baotharites = list("Rite of Joy")

/obj/structure/ritualcircle/baotha/attack_hand(mob/living/user)
	if((user.patron?.type) != /datum/patron/inhumen/baotha)
		to_chat(user,span_smallred("I don't know the proper rites for this..."))
		return
	if(!HAS_TRAIT(user, TRAIT_RITUALIST))
		to_chat(user,span_smallred("I don't know the proper rites for this..."))
		return
	var/riteselection = input(user, "Rituals of Bliss", src) as null|anything in baotharites
	switch(riteselection) // put ur rite selection here
		if("Rite of Joy")
			if(HAS_TRAIT(user, TRAIT_RITES_BLOCKED))
				to_chat(user,span_smallred("I have performed enough rituals for the day... I must rest before communing more."))
				return
			var/onrune = view(1, loc)
			var/list/folksonrune = list()
			for(var/mob/living/carbon/human/persononrune in onrune)
				if(HAS_TRAIT(persononrune, TRAIT_DEPRAVED))
					folksonrune += persononrune
			var/target = input(user, "Choose a host") as null|anything in folksonrune
			if(!target)
				return
			if(do_after(user, 50))
				user.say("Let the wine flow, let the music crash!")
				if(do_after(user, 50))
					user.say("Away with tears, away with shame!")
					to_chat(user, span_notice("The memory of sorrow fades into a haze of bliss."))
					if(do_after(user, 50))
						user.say("Grant me the bliss, grant me the rush!")
						if(do_after(user, 50))
							icon_state = "baotha_active"
							user.say("Baotha, fill my cup with endless mirth!")
							playsound(loc, 'sound/misc/evilevent.ogg', 100, FALSE, -1)
							user.apply_status_effect(/datum/status_effect/joybringer)
							user.apply_status_effect(/datum/status_effect/debuff/ritesexpended_high)
							spawn(120)
								icon_state = "baotha_chalky" 
