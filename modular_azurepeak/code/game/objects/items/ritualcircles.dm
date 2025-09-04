/obj/structure/ritualcircle
	name = "ritual circle"
	desc = ""
	icon = 'icons/roguetown/misc/rituals.dmi'
	icon_state = "ritual_base"
	layer = BELOW_OBJ_LAYER
	density = FALSE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/structure/ritualcircle/attack_right(mob/living/carbon/human/user)
	user.visible_message(span_warning("[user] begins wiping away the rune"))
	if(do_after(user, 15))
		playsound(loc, 'sound/foley/cloth_wipe (1).ogg', 100, TRUE)
		qdel(src)

// This'll be our tutorial ritual for those who want to make more later, let's go into details in comments, mm? - Onutsio 
/obj/structure/ritualcircle/astrata
	name = "Rune of the Sun" // defines name of the circle itself
	icon_state = "astrata_chalky" // the icon state, so, the sprite the runes use on the floor. As of making, we have 6, each needs an active/inactive state. 
	desc = "A Holy Rune of Astrata. Warmth irradiates from the rune." // description on examine
	var/solarrites = list("Guiding Light") // This is important - This is the var which stores every ritual option available to a ritualist - Ideally, we'd have like, 3 for each God. Right now, just 1.

/obj/structure/ritualcircle/astrata/attack_hand(mob/living/user) 
	if((user.patron?.type) != /datum/patron/divine/astrata)
		to_chat(user,span_smallred("I don't know the proper rites for this..."))
		return
	if(!HAS_TRAIT(user, TRAIT_RITUALIST))
		to_chat(user,span_smallred("I don't know the proper rites for this...")) // You need ritualist to use them
		return
	if(user.has_status_effect(/datum/status_effect/debuff/ritesexpended))
		to_chat(user,span_smallred("I have performed enough rituals for the day... I must rest before communing more.")) // If you have already done a ritual in the last 30 minutes, you cannot do another.
		return
	var/riteselection = input(user, "Rituals of the Sun", src) as null|anything in solarrites // When you use a open hand on a rune, It'll give you a selection of all the rites available from that rune
	switch(riteselection) // rite selection goes in this section, try to do something fluffy. Presentation is most important here, truthfully.
		if("Guiding Light") // User selects Guiding Light, begins the stuff for it
			if(do_after(user, 50)) // just flavor stuff before activation
				user.say("I beseech the she-form of the Twinned God!!")
				if(do_after(user, 50))
					user.say("To bring Order to a world of naught!!")
					if(do_after(user, 50))
						user.say("Place your gaze upon me, oh Radiant one!!")
						to_chat(user,span_danger("You feel the eye of Astrata turned upon you. Her warmth dances upon your cheek. You feel yourself warming up...")) // A bunch of flavor stuff, slow incanting.
						icon_state = "astrata_active"
						if(!HAS_TRAIT(user, TRAIT_CHOSEN)) //Priests don't burst into flames.
							loc.visible_message(span_warning("[user]'s bursts to flames! Embraced by Her Warmth wholly!"))
							playsound(loc, 'sound/combat/hits/burn (1).ogg', 100, FALSE, -1)
							user.adjust_fire_stacks(10)
							user.IgniteMob()
							user.flash_fullscreen("redflash3")
							user.emote("firescream")
						guidinglight(src) // Actually starts the proc for applying the buff
						user.apply_status_effect(/datum/status_effect/debuff/ritesexpended)
						spawn(120)
							icon_state = "astrata_chalky"

/obj/structure/ritualcircle/astrata/proc/guidinglight(src)
	var/ritualtargets = view(7, loc) // Range of 7 from the source, which is the rune
	for(var/mob/living/carbon/human/target in ritualtargets) // defines the target as every human in this range
		target.apply_status_effect(/datum/status_effect/buff/guidinglight) // applies the status effect
		to_chat(target,span_cultsmall("Astrata's light guides me forward, drawn to me by the Ritualist's pyre!"))
		playsound(target, 'sound/magic/holyshield.ogg', 80, FALSE, -1) // Cool sound!
// If you want to review a more complicated one, Undermaiden's Bargain is probs the most complicated of the starting set. - Have fun! - Onutsio 🏳️‍⚧️


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
	if(user.has_status_effect(/datum/status_effect/debuff/ritesexpended))
		to_chat(user,span_smallred("I have performed enough rituals for the day... I must rest before communing more."))
		return
	var/riteselection = input(user, "Rituals of the Moon", src) as null|anything in lunarrites
	switch(riteselection) // put ur rite selection here
		if("Moonlight Dance")
			if(do_after(user, 50))
				user.say("I beseech the he-form of the Twinned God!!")
				if(do_after(user, 50))
					user.say("To bring Wisdom to a world of naught!!")
					if(do_after(user, 50))
						user.say("Place your gaze upon me, oh wise one!!")
						to_chat(user,span_cultsmall("The waning half of the Twin-God carries but one eye. With some effort, it can be drawn upon supplicants."))
						playsound(loc, 'sound/magic/holyshield.ogg', 80, FALSE, -1)
						moonlightdance(src)
						user.apply_status_effect(/datum/status_effect/debuff/ritesexpended)

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
	var/plaguerites = list("Flylord's Triage")


/obj/structure/ritualcircle/pestra/attack_hand(mob/living/user)
	if((user.patron?.type) != /datum/patron/divine/pestra)
		to_chat(user,span_smallred("I don't know the proper rites for this..."))
		return
	if(!HAS_TRAIT(user, TRAIT_RITUALIST))
		to_chat(user,span_smallred("I don't know the proper rites for this..."))
		return
	if(user.has_status_effect(/datum/status_effect/debuff/ritesexpended))
		to_chat(user,span_smallred("I have performed enough rituals for the day... I must rest before communing more."))
		return
	var/riteselection = input(user, "Rituals of Plague", src) as null|anything in plaguerites
	switch(riteselection) // put ur rite selection here
		if("Flylord's Triage")
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
							user.apply_status_effect(/datum/status_effect/debuff/ritesexpended)
							spawn(120)
								icon_state = "pestra_chalky"

/obj/structure/ritualcircle/pestra/proc/flylordstriage(src)
	var/ritualtargets = view(0, loc)
	for(var/mob/living/carbon/human/target in ritualtargets)
		to_chat(target,span_userdanger("You feel them crawling into your wounds and pores. Their horrific hum rings through your ears as they do their work!"))
		target.flash_fullscreen("redflash3")
		target.emote("agony")
		target.Stun(200)
		target.Knockdown(200)
		to_chat(target, span_userdanger("UNIMAGINABLE PAIN!"))
		target.apply_status_effect(/datum/status_effect/buff/flylordstriage)

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
	if(user.has_status_effect(/datum/status_effect/debuff/ritesexpended))
		to_chat(user,span_smallred("I have performed enough rituals for the day... I must rest before communing more."))
		return
	var/riteselection = input(user, "Rituals of Beasts", src) as null|anything in bestialrites
	switch(riteselection) // put ur rite selection here
		if("Rite of the Lesser Wolf")
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
							user.apply_status_effect(/datum/status_effect/debuff/ritesexpended)
							spawn(120)
								icon_state = "dendor_chalky"

/obj/structure/ritualcircle/dendor/proc/lesserwolf(src)
	var/ritualtargets = view(1, loc)
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
	if(user.has_status_effect(/datum/status_effect/debuff/ritesexpended))
		to_chat(user,span_smallred("I have performed enough rituals for the day... I must rest before communing more."))
		return
	var/riteselection = input(user, "Rituals of Creation", src) as null|anything in forgerites
	switch(riteselection) // put ur rite selection here
		if("Ritual of Blessed Reforgance")
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
							user.apply_status_effect(/datum/status_effect/debuff/ritesexpended)
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
	if(user.has_status_effect(/datum/status_effect/debuff/ritesexpended))
		to_chat(user,span_smallred("I have performed enough rituals for the day... I must rest before communing more."))
		return
	var/riteselection = input(user, "Rituals of the Storm", src) as null|anything in stormrites
	switch(riteselection)
		if("Rite of the Abyssal Call")
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
					user.apply_status_effect(/datum/status_effect/debuff/ritesexpended)
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
	if(user.has_status_effect(/datum/status_effect/debuff/ritesexpended))
		to_chat(user,span_smallred("I have performed enough rituals for the day... I must rest before communing more."))
		return
	var/riteselection = input(user, "Rituals of Death", src) as null|anything in deathrites
	switch(riteselection) // put ur rite selection here
		if("Undermaiden's Bargain")
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
						user.apply_status_effect(/datum/status_effect/debuff/ritesexpended)
						spawn(120)
							icon_state = "necra_chalky"
		if("Vow to the Undermaiden")
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
							user.apply_status_effect(/datum/status_effect/debuff/ritesexpended)
							spawn(120)
								icon_state = "necra_chalky"
						else
							loc.visible_message(span_warning("Then... nothing. The Undermaiden does not care for the vows of the damned, or those of other faiths."))



/obj/structure/ritualcircle/necra/proc/undermaidenbargain(src)
	var/ritualtargets = view(7, loc)
	for(var/mob/living/carbon/human/target in ritualtargets)
		target.apply_status_effect(/datum/status_effect/buff/undermaidenbargain)
	
/obj/structure/ritualcircle/necra/proc/undermaidenvow(src)
	var/ritualtargets = view(1, loc)
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
	if(user.has_status_effect(/datum/status_effect/debuff/ritesexpended))
		to_chat(user,span_smallred("I have performed enough rituals for the day... I must rest before communing more."))
		return
	var/riteselection = input(user, "Rituals of Love", src) as null|anything in peacerites
	switch(riteselection) // put ur rite selection here
		if("Rite of Pacification")
			if(do_after(user, 50))
				user.say("#Blessed be your weary head...")
				if(do_after(user, 50))
					user.say("#Full of strife and pain...")
					if(do_after(user, 50))
						user.say("#Let Her ease your fear...")
						if(do_after(user, 50))
							icon_state = "eora_active"
							pacify(src)
							user.apply_status_effect(/datum/status_effect/debuff/ritesexpended)
							spawn(120)
								icon_state = "eora_chalky"

/obj/structure/ritualcircle/eora/proc/pacify(src)
	var/ritualtargets = view(0, loc)
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
	var/zizorites = list("Rite of Armaments", "Rite of the Dark Crystal", "Conversion", "Path of Rituos")

/obj/structure/ritualcircle/zizo/attack_hand(mob/living/user)
	if((user.patron?.type) != /datum/patron/inhumen/zizo)
		to_chat(user,span_smallred("I don't know the proper rites for this..."))
		return
	if(!HAS_TRAIT(user, TRAIT_RITUALIST))
		to_chat(user,span_smallred("I don't know the proper rites for this..."))
		return
	if(user.has_status_effect(/datum/status_effect/debuff/ritesexpended))
		to_chat(user,span_smallred("I have performed enough rituals for the day... I must rest before communing more."))
		return
	var/riteselection = input(user, "Rituals of Progress", src) as null|anything in zizorites
	switch(riteselection)
		if("Rite of Armaments")
			var/onrune = view(1, loc)
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
							user.apply_status_effect(/datum/status_effect/debuff/ritesexpended)
							zizoarmaments(target)
							spawn(120)
								icon_state = "zizo_chalky"
		if("Rite of the Dark Crystal")
			if(do_after(user, 50))
				user.say("ZIZO! ZIZO! DAME OF PROGRESS!!")
				if(do_after(user, 50))
					user.say("ZIZO! ZIZO! GRANT THE CABAL THEIR RELIC!!")
					if(do_after(user, 50))
						user.say("ZIZO! ZIZO! THE DARK CRYSTAL TO COMMAND THE DEAD!!")
						if(do_after(user, 50))
							icon_state = "zizo_active"
							user.apply_status_effect(/datum/status_effect/debuff/ritesexpended)
							new /obj/item/necro_relics/necro_crystal(loc)
							loc.visible_message(span_purple("A dark crystal materializes in the center of the ritual circle, pulsing with necromantic energy!"))
							spawn(120)
								icon_state = "zizo_chalky"
		if("Conversion")
			if(!Adjacent(user))
				to_chat(user, "You must stand close to the rune to receive Zizo's blessing.")
				return
			var/list/valids_on_rune = list()
			for(var/mob/living/carbon/human/peep in range(0, loc))
				if(HAS_TRAIT(peep, TRAIT_CABAL))
					continue
				valids_on_rune += peep
			if(!valids_on_rune.len)
				to_chat(user, "No valid targets on the rune!")
				return
			var/mob/living/carbon/human/target = input(user, "Choose a host") as null|anything in valids_on_rune
			if(!target || QDELETED(target) || target.loc != loc)
				return
			if(do_after(user, 50))
				user.say("ZIZO! ZIZO! DAME OF PROGRESS!!")
				if(do_after(user, 50))
					user.say("ZIZO! ZIZO! HEED MY CALL!!")
					if(do_after(user, 50))
						user.say("ZIZO! ZIZO! LET THEM KNOW YOUR WORKS!!")
						if(do_after(user, 50))
							icon_state = "zizo_active"
							zizoconversion(target) // removed CD bc it's gonna be coal to sit there and wait for it to go off rite cooldown, this one is purely social in its nature
							spawn(120)
								icon_state = "zizo_chalky"
		if("Path of Rituos")
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
							user.apply_status_effect(/datum/status_effect/debuff/ritesexpended)
							spawn(120)
								icon_state = "zizo_chalky"


/obj/structure/ritualcircle/zizo/proc/zizoarmaments(src)
	var/onrune = view(0, loc)
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
		target.update_body_parts()
		var/list/eyes_replaced = target.internal_organs.Copy()
		var/obj/item/organ/eyes/eyes = target.getorganslot(eyes_replaced) // #define ORGAN_SLOT_PENIS "penis" ORGAN_SLOT_TESTICLES "testicles" ORGAN_SLOT_BREASTS "breasts" ORGAN_SLOT_VAGINA "vagina" do I wanna bother
		eyes = new /obj/item/organ/eyes/night_vision/zombie
		eyes.Insert(target)
		target.update_body_parts()
		target.ritual_skeletonization = TRUE

/obj/structure/ritualcircle/zizo/proc/zizoconversion(mob/living/carbon/human/target)
	if(!target || QDELETED(target) || target.loc != loc)
		to_chat(usr, "Selected target is not on the rune! [target.p_they(TRUE)] must be directly on top of the rune to receive Zizo's blessing.")
		return
	if(HAS_TRAIT(target, TRAIT_CABAL))
		loc.visible_message(span_cult("THE RITE REJECTS ONE ALREADY OF THE CABAL"))
		return
	if(target.already_converted_once)
		loc.visible_message(span_cult("BLOODY FOOL!!"))
		target.apply_damage(150, BRUTE, BODY_ZONE_HEAD)
		return
	var/prompt = alert(target, "SUBMISSION OR DEATH",, "SUBMISSION", "DEATH")
	if(prompt == "SUBMISSION")
		to_chat(target, span_warning("Images of Her Work most grandoise flood your mind, as the heretical knowledge is seared right into your very body and soul."))
		target.Stun(60)
		target.Knockdown(60)
		to_chat(target, span_userdanger("UNIMAGINABLE PAIN!"))
		target.emote("Agony")
		playsound(loc, 'sound/combat/newstuck.ogg', 50)
		loc.visible_message(span_cult("Great hooks come from the rune, embedding into [target]'s ankles, pulling them onto the rune. Then, into their wrists. [target] is convulsing on the ground, as they finally accept the truth. "))
		spawn(20)
			playsound(target, 'sound/health/slowbeat.ogg', 60)
			playsound(loc, 'sound/ambience/creepywind.ogg', 80)
			target.adjust_skillrank(/datum/skill/misc/reading, 2, TRUE)
			target.adjust_skillrank(/datum/skill/craft/alchemy, 1, TRUE)
			target.adjust_skillrank(/datum/skill/misc/medicine, 1, TRUE)
			spawn(40)
				playsound(loc, 'sound/misc/boatleave.ogg', 100)
				to_chat(target, span_purple("They are ignorant, backwards, without hope. You. You will fight in the name of Progress."))
				if(target.devotion == null) // why can't it just go 'huh null? yeah ok dont care let's continue' why do i have to write this
					target.set_patron(new /datum/patron/inhumen/zizo)
					target.already_converted_once = TRUE
					return
				else
					var/previous_level = target.devotion.level // IF NULL JUST MOVE ON WHAT'S YOUR PROBLEM HOLY FUCKING SHIT!!!
					target.set_patron(new /datum/patron/inhumen/zizo) //now you might ask why we get previous_level variable before switching le patron. reason is when swapping patrons it completely fucks up devotion data for people
					var/datum/devotion/C = new /datum/devotion(target, target.patron)
					if(previous_level == 4)
						target.mind?.RemoveAllMiracles()
						C.grant_miracles(target, cleric_tier = CLERIC_T4, passive_gain = CLERIC_REGEN_MAJOR, start_maxed = TRUE) // gotta change?
					if(previous_level == 3)
						target.mind?.RemoveAllMiracles()
						C.grant_miracles(target, cleric_tier = CLERIC_T3, passive_gain = CLERIC_REGEN_MAJOR, devotion_limit = CLERIC_REQ_3) // gotta change?
					if(previous_level == 2)
						target.mind?.RemoveAllMiracles()
						C.grant_miracles(target, cleric_tier = CLERIC_T2, passive_gain = CLERIC_REGEN_MINOR, devotion_limit = CLERIC_REQ_2)
					if(previous_level == 1)
						target.mind?.RemoveAllMiracles()
						C.grant_miracles(target, cleric_tier = CLERIC_T1, passive_gain = CLERIC_REGEN_DEVOTEE, devotion_limit = CLERIC_REQ_1)
					target.already_converted_once = TRUE 
	if(prompt == "DEATH")
		to_chat(target, span_warning("Images of Her Work most grandoise flood your mind yet... you choose to reject them. Only final death awaits now, you foolish thing."))
		target.Stun(60)
		target.Knockdown(60)
		to_chat(target, span_userdanger("UNIMAGINABLE PAIN!"))
		target.apply_damage(100, BURN, BODY_ZONE_HEAD)
		target.emote("Agony")
		loc.visible_message(span_cult("[target] is violently thrashing atop the rune, writhing, as they dare to defy ZIZO."))




/obj/structure/ritualcircle/matthios
	name = "Rune of Transaction"
	desc = "A Holy Rune of Matthios. All has a price."
	icon_state = "matthios_chalky"
	var/matthiosrites = list("Rite of Armaments", "Conversion")


/obj/structure/ritualcircle/matthios/attack_hand(mob/living/user)
	if((user.patron?.type) != /datum/patron/inhumen/matthios)
		to_chat(user,span_smallred("I don't know the proper rites for this..."))
		return
	if(!HAS_TRAIT(user, TRAIT_RITUALIST))
		to_chat(user,span_smallred("I don't know the proper rites for this..."))
		return
	if(user.has_status_effect(/datum/status_effect/debuff/ritesexpended))
		to_chat(user,span_smallred("I have performed enough rituals for the day... I must rest before communing more."))
		return
	var/riteselection = input(user, "Rituals of Transaction", src) as null|anything in matthiosrites
	switch(riteselection) // put ur rite selection here
		if("Rite of Armaments")
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
							user.apply_status_effect(/datum/status_effect/debuff/ritesexpended)
							matthiosarmaments(target)
							spawn(120)
								icon_state = "matthios_chalky"
		if("Conversion")
			if(!Adjacent(user))
				to_chat(user, "You must stand close to the rune to receive Matthios' blessing.")
				return
			var/list/valids_on_rune = list()
			for(var/mob/living/carbon/human/peep in range(0, loc))
				if(HAS_TRAIT(peep, TRAIT_COMMIE))
					continue
				valids_on_rune += peep
			if(!valids_on_rune.len)
				to_chat(user, "No valid targets on the rune!")
				return
			var/mob/living/carbon/human/target = input(user, "Choose a host") as null|anything in valids_on_rune
			if(!target || QDELETED(target) || target.loc != loc)
				return
			if(do_after(user, 50))
				user.say("Gold and Silver, he feeds!!")
				if(do_after(user, 50))
					user.say("Pieces Tens, Hundreds, Thousands. The transactor feeds 'pon them all!!")
					if(do_after(user, 50))
						user.say("Take what is offered, for a deal is struck!!")
						if(do_after(user, 50))
							icon_state = "matthios_active"
							matthiosconversion(target) // again no CD since it's a social thing babajing
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

/obj/structure/ritualcircle/matthios/proc/matthiosconversion(mob/living/carbon/human/target)
	if(!target || QDELETED(target) || target.loc != loc)
		to_chat(usr, "Selected target is not on the rune! [target.p_they(TRUE)] must be directly on top of the rune to receive Matthios' blessing.")
		return
	if(HAS_TRAIT(target, TRAIT_COMMIE))
		loc.visible_message(span_cult("THE RITE REJECTS ONE WITH GREED IN THEIR HEART ALREADY PRESENT!!"))
		return
	if(target.already_converted_once)
		loc.visible_message(span_cult("BLOODY FOOL!!"))
		target.apply_damage(150, BRUTE, BODY_ZONE_HEAD)
		return
	var/prompt = alert(target, "GOOD DEAL?",, "GOOD DEAL!", "NO DEAL!")
	if(prompt == "GOOD DEAL!")
		target.Stun(60)
		target.Knockdown(60)
		target.emote("Laugh")
		playsound(loc, 'sound/misc/smelter_fin.ogg', 50)
		loc.visible_message(span_cult("[target]'s eyes gleam and shine with a glimmer of a thousand gems and jewels, as they give in to their lust for wealth."))
		spawn(20)
			playsound(loc, 'sound/combat/hits/onmetal/grille (2).ogg', 50)
			target.adjust_skillrank(/datum/skill/misc/climbing, 1, TRUE) //fuck do they gotta get? a better grip
			target.adjust_skillrank(/datum/skill/misc/lockpicking, 1, TRUE)
			target.adjust_skillrank(/datum/skill/misc/stealing, 1, TRUE)
			spawn(40)
				to_chat(target, span_cult("More to the maw, for [target] shall feed their own greed along with us!"))
				playsound(loc, 'sound/items/matidol2.ogg', 50)
				if(target.devotion == null) // why can't it just go 'huh null? yeah ok dont care let's continue' why do i have to write this
					target.set_patron(new /datum/patron/inhumen/matthios)
					return
				else
					var/previous_level = target.devotion.level // IF NULL JUST MOVE ON WHAT'S YOUR PROBLEM HOLY FUCKING SHIT!!!
					target.set_patron(new /datum/patron/inhumen/matthios) //now you might ask why we get previous_level variable before switching le patron. reason is when swapping patrons it completely fucks up devotion data for people
					var/datum/devotion/C = new /datum/devotion(target, target.patron)
					if(previous_level == 4)
						target.mind?.RemoveAllMiracles()
						C.grant_miracles(target, cleric_tier = CLERIC_T4, passive_gain = CLERIC_REGEN_MAJOR, start_maxed = TRUE) // gotta change?
					if(previous_level == 3)
						target.mind?.RemoveAllMiracles()
						C.grant_miracles(target, cleric_tier = CLERIC_T3, passive_gain = CLERIC_REGEN_MAJOR, devotion_limit = CLERIC_REQ_3) // gotta change?
					if(previous_level == 2)
						target.mind?.RemoveAllMiracles()
						C.grant_miracles(target, cleric_tier = CLERIC_T2, passive_gain = CLERIC_REGEN_MINOR, devotion_limit = CLERIC_REQ_2)
					if(previous_level == 1)
						target.mind?.RemoveAllMiracles()
						C.grant_miracles(target, cleric_tier = CLERIC_T1, passive_gain = CLERIC_REGEN_DEVOTEE, devotion_limit = CLERIC_REQ_1)
	if(prompt == "NO DEAL!")
		to_chat(target, span_warning("All that does glimmer could be yours... if only you would submit to your own greedy nature. Only final death awaits now, you, fellow most austere."))
		target.Stun(60)
		target.Knockdown(60)
		to_chat(target, span_userdanger("UNIMAGINABLE PAIN!"))
		target.emote("Agony")
		target.apply_damage(100, BURN, BODY_ZONE_HEAD)
		loc.visible_message(span_cult("[target] is violently thrashing atop the rune, writhing, as they dare to defy MATTHIOS."))



/obj/structure/ritualcircle/graggar
	name = "Rune of Violence"
	desc = "A Holy Rune of Graggar. Fate broken once, His gift is true freedom for all."
	icon_state = "graggar_chalky"
	var/graggarrites = list("Rite of Armaments", "Conversion")

/obj/structure/ritualcircle/graggar/attack_hand(mob/living/user)
	if((user.patron?.type) != /datum/patron/inhumen/graggar)
		to_chat(user,span_smallred("I don't know the proper rites for this..."))
		return
	if(!HAS_TRAIT(user, TRAIT_RITUALIST))
		to_chat(user,span_smallred("I don't know the proper rites for this..."))
		return
	if(user.has_status_effect(/datum/status_effect/debuff/ritesexpended))
		to_chat(user,span_smallred("I have performed enough rituals for the day... I must rest before communing more."))
		return
	var/riteselection = input(user, "Rituals of Violence", src) as null|anything in graggarrites
	switch(riteselection) // put ur rite selection here
		if("Rite of Armaments")
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
							user.apply_status_effect(/datum/status_effect/debuff/ritesexpended)
							graggararmor(target)
							spawn(120)
								icon_state = "graggar_chalky" 
		if("Conversion")
			if(!Adjacent(user))
				to_chat(user, "You must stand close to the rune to receive Graggar's blessing.")
				return
			var/list/valids_on_rune = list()
			for(var/mob/living/carbon/human/peep in range(0, loc))
				if(HAS_TRAIT(peep, TRAIT_HORDE))
					continue
				valids_on_rune += peep
			if(!valids_on_rune.len)
				to_chat(user, "No valid targets on the rune!")
				return
			var/mob/living/carbon/human/target = input(user, "Choose a host") as null|anything in valids_on_rune
			if(!target || QDELETED(target) || target.loc != loc)
				return
			if(do_after(user, 50))
				user.say("MOTIVE FORCE, OH, VIOLENCE!!")
				if(do_after(user, 50))
					user.say("A GORGEOUS BUFFET AWAITS US!!")
					if(do_after(user, 50))
						user.say("LET US CULL AND HUNT, CULL AND HUNT, TOGETHER!!")
						if(do_after(user, 50))
							icon_state = "graggar_active"
							graggarconversion(target)
							spawn(120)
								icon_state = "graggar_chalky" 

/obj/structure/ritualcircle/graggar/proc/graggararmor(src)
	var/onrune = view(0, loc)
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

/obj/structure/ritualcircle/graggar/proc/graggarconversion(mob/living/carbon/human/target)
	if(!target || QDELETED(target) || target.loc != loc)
		to_chat(usr, "Selected target is not on the rune! [target.p_they(TRUE)] must be directly on top of the rune to receive Graggar's blessing.")
		return
	if(HAS_TRAIT(target, TRAIT_HORDE))
		loc.visible_message(span_cult("THE RITE REJECTS ONE WITH SLAUGHTER IN THEIR HEART!!"))
		return
	if(target.already_converted_once)
		loc.visible_message(span_cult("BLOODY FOOL!!"))
		target.apply_damage(150, BRUTE, BODY_ZONE_HEAD)
		return 
	var/prompt = alert(target, "CULL AND HUNT!",, "KILL KILL KILL!!", "I DEFY YOU!!")
	if(prompt == "KILL KILL KILL!!")
		target.Stun(60)
		target.Knockdown(60)
		to_chat(target, span_userdanger("UNIMAGINABLE PAIN!"))
		target.emote("Warcry")
		loc.visible_message(span_cult("[target]'s mind if flooded with images of slaughter most sublime, as they embrace their violent nature, casting away shackles of honour and empathy.")) // i cant
		spawn(20)
			playsound(target, 'sound/misc/heroin_rush.ogg', 100)
			playsound(target, 'sound/health/fastbeat.ogg', 100)
			target.adjust_skillrank(/datum/skill/misc/athletics, 1, TRUE)
			target.adjust_skillrank(/datum/skill/labor/butchering, 1, TRUE)
			spawn(40)
				to_chat(target, span_cult("Break them."))
				target.say("SLAUGHTER!!") // many enemies bring much honour
				if(target.devotion == null) // why can't it just go 'huh null? yeah ok dont care let's continue' why do i have to write this
					target.set_patron(new /datum/patron/inhumen/graggar)
					return
				else
					var/previous_level = target.devotion.level // IF NULL JUST MOVE ON WHAT'S YOUR PROBLEM HOLY FUCKING SHIT!!!
					target.set_patron(new /datum/patron/inhumen/graggar) //now you might ask why we get previous_level variable before switching le patron. reason is when swapping patrons it completely fucks up devotion data for people
					var/datum/devotion/C = new /datum/devotion(target, target.patron)
					if(previous_level == 4)
						target.mind?.RemoveAllMiracles()
						C.grant_miracles(target, cleric_tier = CLERIC_T4, passive_gain = CLERIC_REGEN_MAJOR, start_maxed = TRUE) // gotta change?
					if(previous_level == 3)
						target.mind?.RemoveAllMiracles()
						C.grant_miracles(target, cleric_tier = CLERIC_T3, passive_gain = CLERIC_REGEN_MAJOR, devotion_limit = CLERIC_REQ_3) // gotta change?
					if(previous_level == 2)
						target.mind?.RemoveAllMiracles()
						C.grant_miracles(target, cleric_tier = CLERIC_T2, passive_gain = CLERIC_REGEN_MINOR, devotion_limit = CLERIC_REQ_2)
					if(previous_level == 1)
						target.mind?.RemoveAllMiracles()
						C.grant_miracles(target, cleric_tier = CLERIC_T1, passive_gain = CLERIC_REGEN_DEVOTEE, devotion_limit = CLERIC_REQ_1)
	if(prompt == "I DEFY YOU!!")
		to_chat(target, span_warning("AAAAAAAAAAAAAAAAHHHH!!"))
		target.Stun(60)
		target.Knockdown(60)
		to_chat(target, span_userdanger("UNIMAGINABLE PAIN!"))
		target.emote("Agony")
		target.say("DIE, WRETCHES!!") // many enemies bring much honour
		target.apply_damage(100, BURN, BODY_ZONE_HEAD)
		loc.visible_message(span_cult("[target] is violently thrashing atop the rune, writhing, as they dare to defy GRAGGAR."))




/obj/structure/ritualcircle/baotha
	name = "Rune of Desire"
	desc = "A Holy Rune of Baotha. Relief for the broken hearted."
	icon_state = "baotha_chalky" // mortosasye
	var/baotharites = list("Conversion")

/obj/structure/ritualcircle/baotha/attack_hand(mob/living/user)
	if((user.patron?.type) != /datum/patron/inhumen/baotha)
		to_chat(user,span_smallred("I don't know the proper rites for this..."))
		return
	if(!HAS_TRAIT(user, TRAIT_RITUALIST))
		to_chat(user,span_smallred("I don't know the proper rites for this..."))
		return
	if(user.has_status_effect(/datum/status_effect/debuff/ritesexpended))
		to_chat(user,span_smallred("I have performed enough rituals for the day... I must rest before communing more."))
		return
	var/riteselection = input(user, "Rituals of Desire", src) as null|anything in baotharites
	switch(riteselection) // put ur rite selection here
		if("Conversion")
			if(!Adjacent(user))
				to_chat(user, "You must stand close to the rune to receive Baotha's blessing.")
				return
			var/list/valids_on_rune = list()
			for(var/mob/living/carbon/human/peep in range(0, loc))
				if(HAS_TRAIT(peep, TRAIT_DEPRAVED))
					continue
				valids_on_rune += peep
			if(!valids_on_rune.len)
				to_chat(user, "No valid targets on the rune!")
				return
			var/mob/living/carbon/human/target = input(user, "Choose a host") as null|anything in valids_on_rune
			if(!target || QDELETED(target) || target.loc != loc)
				return
			if(do_after(user, 50))
				user.say("#Lady pleasure, comfort and please us...")
				if(do_after(user, 50))
					user.say("#We are alone. Abandoned. Embrace us both...")
					if(do_after(user, 50))
						user.say("#The world's momentary pleasures have left us wanting...") // ty zeratino and pyrzal
						if(do_after(user, 50))
							icon_state = "baotha_active" // mortosasye
							baothaconversion(target) // removed CD bc it's gonna be coal to sit there and wait for it to go off rite cooldown, this one is purely social in its nature
							spawn(120)
								icon_state = "baotha_chalky" // mortosasye

/obj/structure/ritualcircle/baotha/proc/baothaconversion(mob/living/carbon/human/target)
	if(!target || QDELETED(target) || target.loc != loc)
		to_chat(usr, "Selected target is not on the rune! [target.p_they(TRUE)] must be directly on top of the rune to receive Baotha's blessing.")
		return
	if(HAS_TRAIT(target, TRAIT_DEPRAVED))
		loc.visible_message(span_cult("THE RITE REJECTS ONE ALREADY DEPRAVED ENOUGH!!"))
		return
	if(target.already_converted_once)
		loc.visible_message(span_cult("BLOODY FOOL!!"))
		target.apply_damage(150, BRUTE, BODY_ZONE_HEAD)
		return 
	var/prompt = alert(target, "LEASH OF SUBMISSION OR LASH OF DEFIANCE?",, "LEASH", "LASH")
	if(prompt == "LEASH")
		to_chat(target, span_warning("Hedonistic visions of excess and indulgence echo in your brain, as a drug-addled haze settles over your mind. Your body yearns for more.")) // helloooOOOOOOOO
		target.Stun(60)
		target.Knockdown(60)
		to_chat(target, span_userdanger("PLEASURE FOR PLEASURE'S SAKE!"))
		target.sexcon.set_arousal(300) 
		loc.visible_message(span_cult("[target] writhes and moans as sensations of pleasure and pain surge through their body...")) // warhammer 3 slaaneshi daemonette quotes
		spawn(20)
			playsound(target, 'sound/health/fastbeat.ogg', 60)
			playsound(loc, 'sound/ambience/creepywind.ogg', 80)
			target.adjust_skillrank(/datum/skill/misc/athletics, 1, TRUE)
			target.adjust_skillrank(/datum/skill/misc/music, 1, TRUE)
			target.adjust_skillrank(/datum/skill/misc/riding, 1, TRUE) // haha get it?
			spawn(40)
				to_chat(target, span_purple("Enjoy yourself, for what is lyfe without pleasure, ha?")) // help
				if(target.devotion == null)
					target.set_patron(new /datum/patron/inhumen/baotha)
					return
				else
					var/previous_level = target.devotion.level //now you might ask why we get previous_level variable before switching le patron. reason is when swapping patrons it completely fucks up devotion data for people
					target.set_patron(new /datum/patron/inhumen/baotha)
					var/datum/devotion/C = new /datum/devotion(target, target.patron)
					if(previous_level == 4)
						target.mind?.RemoveAllMiracles()
						C.grant_miracles(target, cleric_tier = CLERIC_T4, passive_gain = CLERIC_REGEN_MAJOR, start_maxed = TRUE) // gotta change?
					if(previous_level == 3)
						target.mind?.RemoveAllMiracles()
						C.grant_miracles(target, cleric_tier = CLERIC_T3, passive_gain = CLERIC_REGEN_MAJOR, devotion_limit = CLERIC_REQ_3) // gotta change?
					if(previous_level == 2)
						target.mind?.RemoveAllMiracles()
						C.grant_miracles(target, cleric_tier = CLERIC_T2, passive_gain = CLERIC_REGEN_MINOR, devotion_limit = CLERIC_REQ_2)
					if(previous_level == 1)
						target.mind?.RemoveAllMiracles()
						C.grant_miracles(target, cleric_tier = CLERIC_T1, passive_gain = CLERIC_REGEN_DEVOTEE, devotion_limit = CLERIC_REQ_1)	
	if(prompt == "LASH")
		to_chat(target, span_warning("All too austere, aloof and prudish, aren't you? Bah, I shall not waste any more of my time on you.")) // gotta change it too
		target.Stun(60)
		target.Knockdown(60)
		to_chat(target, span_userdanger("UNIMAGINABLE PAIN!"))
		target.emote("Agony")
		target.apply_damage(100, BURN, BODY_ZONE_HEAD)
		loc.visible_message(span_cult("[target] is violently thrashing atop the rune, writhing, as they dare to defy Baotha."))
