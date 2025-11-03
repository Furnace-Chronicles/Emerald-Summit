/obj/item/ritechalk
	name = "ritual chalk"
	icon_state = "chalk"
	desc = "Simple white chalk. A useful tool for rites."
	icon = 'icons/roguetown/misc/rituals.dmi'
	w_class = WEIGHT_CLASS_TINY
	experimental_inhand = FALSE

/obj/item/ritechalk/attack_self(mob/living/user)
	if(!HAS_TRAIT(user, TRAIT_RITUALIST) && !((user.get_skill_level(/datum/skill/magic/arcane)) > SKILL_LEVEL_NONE))
		to_chat(user, span_smallred("I don't know what I'm doing with this..."))
		return

	var/ritechoices = list()
	if(HAS_TRAIT(user, TRAIT_RITUALIST))
		switch (user.patron?.type)
			if(/datum/patron/inhumen/graggar)
				ritechoices += "Rune of Violence"
			if(/datum/patron/inhumen/zizo)
				ritechoices += "Rune of ZIZO" 
			if(/datum/patron/inhumen/matthios)
				ritechoices += "Rune of Transaction" 
			if(/datum/patron/inhumen/baotha) 
				ritechoices += "Rune of Desire"
			if(/datum/patron/divine/astrata)
				ritechoices += "Rune of Sun"
			if(/datum/patron/divine/noc)
				ritechoices += "Rune of Moon"
			if(/datum/patron/divine/dendor)
				ritechoices += "Rune of Beasts"
			if(/datum/patron/divine/malum)
				ritechoices += "Rune of Forge"
			if(/datum/patron/divine/xylix)
				ritechoices += "Rune of Trickery"
			if(/datum/patron/divine/necra)
				ritechoices += "Rune of Death"
			if(/datum/patron/divine/pestra)
				ritechoices += "Rune of Plague"
			if(/datum/patron/divine/eora)
				ritechoices += "Rune of Love"
			if(/datum/patron/divine/ravox)
				ritechoices += "Rune of Justice"
			if(/datum/patron/divine/abyssor)
				ritechoices += "Rune of Storm"
			if(/datum/patron/old_god)
				ritechoices += "Rune of Enduring"

	var/list/runes_to_draw = list()
	var/list/runes_to_draw_names = list()

	if((user.get_skill_level(/datum/skill/magic/arcane)) > SKILL_LEVEL_NONE)
		for(var/obj/effect/decal/cleanable/roguerune/arcyne/rune as null|anything in subtypesof(/obj/effect/decal/cleanable/roguerune/arcyne))
			if(rune.tier <= 2)
				runes_to_draw += rune
				ritechoices += "[rune.name]"
				runes_to_draw_names += "[rune.name]"

	var/runeselection = input(user, "Which rune shall I inscribe?", src) as null|anything in ritechoices
	var/turf/step_turf = get_turf(user)
	switch(runeselection)
		if("Rune of Sun")
			to_chat(user,span_cultsmall("I begin inscribing the rune of Her Radiance..."))
			if(do_after(user, 30, src))
				playsound(src, 'sound/foley/scribble.ogg', 40, TRUE)
				new /obj/structure/ritualcircle/astrata(step_turf)
		if("Rune of Moon")
			to_chat(user, span_cultsmall("I begin inscribing the rune of His Wisdom..."))
			if(do_after(user, 30, src))
				playsound(src, 'sound/foley/scribble.ogg', 40, TRUE)
				new /obj/structure/ritualcircle/noc(step_turf)
		if("Rune of Beasts")
			to_chat(user,span_cultsmall("I begin inscribing the rune of His Madness..."))
			if(do_after(user, 30, src))
				playsound(src, 'sound/foley/scribble.ogg', 40, TRUE)
				new /obj/structure/ritualcircle/dendor(step_turf)
		if("Rune of Forge")
			to_chat(user,span_cultsmall("I begin inscribing the rune of Their Craft..."))
			if(do_after(user, 30, src))
				playsound(src, 'sound/foley/scribble.ogg', 40, TRUE)
				new /obj/structure/ritualcircle/malum(step_turf)
		if("Rune of Trickery")
			to_chat(user,span_cultsmall("I begin inscribing the rune of His Trickery..."))
			if(do_after(user, 30, src))
				playsound(src, 'sound/foley/scribble.ogg', 40, TRUE)
				new /obj/structure/ritualcircle/xylix(step_turf)
		if("Rune of Death")
			to_chat(user,span_cultsmall("I begin inscribing the rune of Her Embrace..."))
			if(do_after(user, 30, src))
				playsound(src, 'sound/foley/scribble.ogg', 40, TRUE)
				new /obj/structure/ritualcircle/necra(step_turf)
		if("Rune of Plague")
			to_chat(user,span_cultsmall("I begin inscribing the rune of Her Plague..."))
			if(do_after(user, 30, src))
				playsound(src, 'sound/foley/scribble.ogg', 40, TRUE)
				new /obj/structure/ritualcircle/pestra(step_turf)
		if("Rune of Love")
			to_chat(user,span_cultsmall("I begin inscribing the rune of Her Love..."))
			if(do_after(user, 30, src))
				playsound(src, 'sound/foley/scribble.ogg', 40, TRUE)
				new /obj/structure/ritualcircle/eora(step_turf)
		if("Rune of Justice")
			to_chat(user,span_cultsmall("I begin inscribing the rune of His Prowess..."))
			if(do_after(user, 30, src))
				playsound(src, 'sound/foley/scribble.ogg', 40, TRUE)
				new /obj/structure/ritualcircle/ravox(step_turf)
		if("Rune of Storm")
			to_chat(user,span_cultsmall("I begin inscribing the rune of His Storm..."))
			if(do_after(user, 30, src))
				playsound(src, 'sound/foley/scribble.ogg', 40, TRUE)
				new /obj/structure/ritualcircle/abyssor(step_turf)
		if("Rune of Enduring")
			to_chat(user,span_cultsmall("I begin inscribing His holy symbol..."))
			if(do_after(user, 30, src))
				playsound(src, 'sound/foley/scribble.ogg', 40, TRUE)
				new /obj/structure/ritualcircle/psydon(step_turf)
		if("Rune of ZIZO")
			to_chat(user,span_cultsmall("I begin inscribing the rune of Her Knowledge..."))
			if(do_after(user, 30, src))
				playsound(src, 'sound/foley/scribble.ogg', 40, TRUE)
				new /obj/structure/ritualcircle/zizo(step_turf)
		if("Rune of Transaction")
			to_chat(user,span_cultsmall("I begin inscribing the rune of His Transactions..."))
			if(do_after(user, 30, src))
				playsound(src, 'sound/foley/scribble.ogg', 40, TRUE)
				new /obj/structure/ritualcircle/matthios(step_turf)
		if("Rune of Violence")
			to_chat(user,span_cultsmall("I begin inscribing the rune of Slaughter..."))
			if(do_after(user, 30, src))
				playsound(src, 'sound/foley/scribble.ogg', 40, TRUE)
				new /obj/structure/ritualcircle/graggar(step_turf)
		if("Rune of Desire")
			to_chat(user,span_cultsmall("I begin inscribing the rune of Desire..."))
			if(do_after(user, 30, src))
				playsound(src, 'sound/foley/scribble.ogg', 40, TRUE)
				new /obj/structure/ritualcircle/baotha(step_turf)

	if(runeselection in runes_to_draw_names)
		var/obj/effect/decal/cleanable/roguerune/arcyne/rune_to_draw
		for(var/obj/effect/decal/cleanable/roguerune/arcyne/rune as anything in runes_to_draw)
			if(runeselection == rune.name)
				rune_to_draw = rune
		var/structures_in_way = check_for_structures_and_closed_turfs(user.loc, rune_to_draw)
		if(structures_in_way)
			to_chat(user, span_cult("There is a structure, rune or wall in the way."))
			return
		user.visible_message(span_cultsmall("\The [user] begins to drag [user.p_their()] [name] over \the [step_turf], inscribing intricate symbols and sigils inside a circle."), span_cultsmall("I start to drag my [name] over \the [step_turf], inscribing intricate symbols and sigils on a circle."))
		playsound(user, 'sound/magic/chalkdraw.ogg', 100, TRUE)
		if(do_after(user, 40, src))
			user.visible_message(span_warning("[user] draws an arcyne rune with [user.p_their()] [name]!"), \
			span_cultsmall("I finish tracing ornate symbols and circles with my [name], leaving behind a ritual rune."))
			playsound(src, 'sound/foley/scribble.ogg', 40, TRUE)
			new rune_to_draw(step_turf)

/obj/item/ritechalk/proc/check_for_structures_and_closed_turfs(loc, var/obj/effect/decal/cleanable/roguerune/rune_to_scribe)
	for(var/turf/T in range(loc, rune_to_scribe.runesize))
		//check for /sturcture subtypes in the turf's contents
		for(var/obj/structure/S in T.contents)
			return TRUE		//Found a structure, no need to continue

		//check if turf itself is a /turf/closed subtype
		if(istype(T,/turf/closed))
			return TRUE
		//check if rune in the turfs contents
		for(var/obj/effect/decal/cleanable/roguerune/R in T.contents)
			return TRUE
		//Return false if nothing in range was found
	return FALSE
