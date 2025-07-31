//Ascendant, effectively.
//This is just reworking that into a team antag, with adjustments accordingly.
//The relic contributions should reward the entire party, but... eh...
//There's enough luck to be shared that it's ten in total, and it can max someone out by round end.
//If not much sooner.

//Firstly, the landmarks.
/obj/effect/landmark/start/pontiff
	name = "Pontiff"
	icon_state = "arrow"
	delete_after_roundstart = FALSE

/obj/effect/landmark/start/pontiff/Initialize()
	. = ..()
	GLOB.pontiff_starts += loc

//Unused, but for later.
/obj/effect/landmark/start/pontifflate
	name = "Pontiff"
	icon_state = "arrow"
	delete_after_roundstart = FALSE
	jobspawn_override = list("Pontiff")

/obj/effect/landmark/start/pontifflate/Initialize()
	. = ..()
	GLOB.pontiff_starts += loc

//Objectives.
/datum/objective/pontiff
	name = "pontiff"
	explanation_text = "Return relics to the statue."
	triumph_count = 6//Good work, trooper.

/datum/objective/pontiff/check_completion()
	if(SSmapping.retainer.pontiff_stage >= SSmapping.retainer.pontiff_goal)
		return TRUE

//Now, the rest.
//Artefacts to find on the journey. Temp items, for now.
GLOBAL_LIST_INIT(pontiff_artefact_pool, list(
	/obj/item/ingot/blacksteel,//Many static spawns.
	/obj/item/riddleofsteel,//One static spawn exists. In a high end dungeon.
	/obj/item/clothing/ring/signet,//Spawns in both the lord's room and on latespawn nobles.
	/obj/item/clothing/ring/dragon_ring//They're capable of farming smithing, if all else fails.
))
//Consider: /obj/item/reagent_containers/lux
//Or not.

//Absolutely imperative to return. Temp items, for now.
GLOBAL_LIST_INIT(pontiff_relic_pool, list(
	/obj/item/clothing/ring/active/nomag,//Reason to explore the hamlet. Expose themselves.
	/obj/item/rogueweapon/sword/long/blackflamb,//Get that static spawn, or smith it.
	/obj/item/flashlight/flare/torch/lantern/bronzelamptern/malums_lamptern//It's a Psydonite relic. I swear. Hit that dungeon.
))

//The Pontiff statue.
/obj/structure/pontiff
	name = "psydonite statue"
	desc = "Made in His image. The work of a long dead Psydonite, cast of impure silver and steel."
	icon = 'icons/roguetown/misc/96x96.dmi'
	icon_state = "psy"
	pixel_x = -32
	var/ascend_stage = 0 //Stages of completion. 0 is base, 1 is 1st relic, 2 is 2nd relic, 3 is the complete set.
	var/ascendpoints = 0 //Artefacts found.

/obj/structure/pontiff/examine(mob/user)
	. = ..()
	if(!user.mind?.has_antag_datum(/datum/antagonist/pontiff))
		. += "Some matter of oppressive force stares back. Unseen. Unbothered."
		return

	var/obj/item/next_artefact = LAZYACCESS(GLOB.pontiff_artefact_pool, 1)
	var/obj/item/next_relic = LAZYACCESS(GLOB.pontiff_relic_pool, 1)
	if(next_artefact)
		. += "The next artefact in the region is \a [initial(next_artefact.name)]."
	else
		. += span_danger("I have all the artefacts in the region!")
	if(next_relic)
		. += "The next relic in the region is \a [initial(next_relic.name)]."
	else
		. += span_danger("I have collected all the relics in the region!")

/obj/structure/pontiff/attackby(obj/item/W, mob/living/user, params)
	if(!user.mind?.has_antag_datum(/datum/antagonist/pontiff))
		return ..()
//Handle the artefacts.
	if(consume_artefact(W, user))
		return
//Handle the relics.
	else if(consume_relic(W, user))
		return
	else
		to_chat(user, span_userdanger("This item is USELESS to me..."))

/obj/structure/pontiff/attack_right(mob/living/user)
	if(!user.mind?.has_antag_datum(/datum/antagonist/pontiff))
		to_chat(user, span_userdanger("I have no idea what this is."))
		return
	to_chat(user, span_userdanger("I have collected [ascend_stage] relics and [ascendpoints] artefacts."))

//Now, for the artefact stuff.
/obj/structure/pontiff/proc/consume_artefact(obj/item/I, mob/living/user)
	var/next_artefact = LAZYACCESS(GLOB.pontiff_artefact_pool, 1)
	if(!next_artefact)
		return FALSE
	if(!istype(I, next_artefact))
		return FALSE
	. = TRUE

	if(ascendpoints >= 4) // we already have 4 points, stop already!
		to_chat(user, span_danger("His work has begun, yet there are no more artefacts for me to collect. It is time I turn my mind elsewhere."))
		return

	ascendpoints++

//The reward for ascending a stage. Flat across the board, since this is liable to be used by multiple people.
	switch(ascendpoints)
		if(1)
			user.STALUC += 1
			user.playsound_local(user, 'sound/misc/psydong.ogg', 100, FALSE)
			to_chat(user, span_userdanger("A start. We must continue."))
		if(2)
			user.STALUC += 1
			user.playsound_local(user, 'sound/misc/psydong.ogg', 100, FALSE)
			to_chat(user, span_userdanger("The work must continue. We're hardly done."))
		if(3)
			user.STALUC += 1
			user.playsound_local(user, 'sound/misc/psydong.ogg', 100, FALSE)
			to_chat(user, span_userdanger("Almost there, for He is now whispering in my ear."))
		if(4)
			user.STALUC += 1
			user.playsound_local(user, 'sound/misc/psydong.ogg', 100, FALSE)
			to_chat(user, span_userdanger("His power flows through me. For but a moment, I know I've made Him proud."))
	GLOB.pontiff_artefact_pool.Cut(1, 2) // remove the first item
	qdel(I)

/obj/structure/pontiff/proc/consume_relic(obj/item/I, mob/living/user)
	var/obj/item/next_relic = LAZYACCESS(GLOB.pontiff_relic_pool, 1)
	if(!next_relic)
		return FALSE
	if(!istype(I, next_relic))
		return FALSE
	. = TRUE
	QDEL_NULL(I)
	GLOB.pontiff_relic_pool.Cut(1,2) // remove first item
	ascend(user)

/obj/structure/pontiff/proc/ascend(mob/living/user)
	ascend_stage++
	SSmapping.retainer.pontiff_stage += 1

	switch(ascend_stage)
//TODO: Make these give actual, physical rewards. Armour replacements?
//New weapons? Spells? I 'unno. Something other than the luck increase.

//The chosen undead is provided a token reward. The realm alerted to their progress.
		if(1)
			user.STALUC += 2
			user.playsound_local(user, 'sound/misc/psydong.ogg', 100, FALSE)
			to_chat(user, span_danger("The first step has been completed. A puzzle put into motion. Your life's work to be found."))
			priority_announce("The leylines tremble.", "His Hand", 'sound/villain/dreamer_warning.ogg')
//An omen. A warning.
			addomen(PONTIFF_ONE)

//The chosen undead is provided a boon to aid their journey. To obtain the final piece of the puzzle.
		if(2)
			user.STALUC += 2
			user.playsound_local(user, 'sound/misc/psydong.ogg', 100, FALSE)
			to_chat(user, span_danger("A boon. Proof that He yet draws breath, weeping as you do."))
			priority_announce("A foul, ominous presence washes over the land.", "His Gaze", 'sound/villain/dreamer_warning.ogg')
//An omen to herald their approaching victory.
			addomen(PONTIFF_TWO)

//It is done. The chosen undead has found the final piece, and has no further rewards to be given after this.
		if(3)
			user.STALUC += 2
			user.playsound_local(user, 'sound/misc/psydong.ogg', 100, FALSE)
			to_chat(user, span_reallybig("He looks upon you, knowing that you're His chosen. His last hope. A tool. An instrument."))
			priority_announce("For but a brief moment, the world goes dark.", "His Ire", 'sound/villain/dreamer_warning.ogg')
//The final bell to be rung.
			addomen(PONTIFF_THREE)
