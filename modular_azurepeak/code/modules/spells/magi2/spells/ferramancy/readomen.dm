// Read Omen — Ferramancy utility cantrip. Reveals the current storyteller via vague flavor.
// Casters whose patron matches the storyteller get a clearer reading.

/datum/action/cooldown/spell/readomen_magi2
	name = "Read Omen"
	desc = "Draw upon the leylines themselves to reveal secrets of fate itself. \
		Gives a vague impression of the current storyteller. If your patron matches the storyteller, \
		the impression is far less vague."
	button_icon = 'icons/mob/actions/mage_augmentation.dmi'
	button_icon_state = "readomen"
	sound = 'sound/magic/whiteflame.ogg'
	spell_color = GLOW_COLOR_ARCANE
	glow_intensity = GLOW_INTENSITY_LOW

	click_to_activate = FALSE
	self_cast_possible = TRUE

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_CANTRIP

	invocations = list("Miror quid.")
	invocation_type = INVOCATION_WHISPER

	charge_required = TRUE
	charge_time = 2 SECONDS
	charge_drain = 1
	charge_slowdown = CHARGING_SLOWDOWN_SMALL
	charge_sound = 'sound/magic/charging.ogg'
	cooldown_time = 2 MINUTES

	associated_skill = /datum/skill/magic/arcane
	spell_tier = 1
	spell_impact_intensity = SPELL_IMPACT_NONE
	point_cost = 1
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_SAME_Z

/datum/action/cooldown/spell/readomen_magi2/cast(atom/cast_on)
	. = ..()
	var/mob/living/user = owner
	if(!istype(user))
		return FALSE

	user.visible_message(
		span_info("The eyes of [user] roll back into their head for a moment!"),
		span_info("I roll my eyes back into my head and reach for the threads of fate!"),
	)

	var/datum/storyteller/current_storyteller = SSgamemode.current_storyteller
	var/datum/patron/patron = user.patron

	if(istype(current_storyteller, /datum/storyteller/astrata))
		if(istype(patron, /datum/patron/divine/astrata))
			to_chat(user, span_warning("I know this feeling well. That is the warmth of the sun on my cheeks. Astrata's light beams upon me in this moment."))
		else
			to_chat(user, span_warning("I feel warm for a moment, like I am beginning to flush from a fever, and then it fades."))
		return TRUE

	if(istype(current_storyteller, /datum/storyteller/noc))
		if(istype(patron, /datum/patron/divine/noc))
			to_chat(user, span_warning("Darkness — the comforting darkness of night. I know this feeling."))
		else
			to_chat(user, span_warning("With my eyes rolled back, I feel nothing but the oppressive darkness inside my skull."))
		return TRUE

	if(istype(current_storyteller, /datum/storyteller/abyssor))
		if(istype(patron, /datum/patron/divine/abyssor))
			to_chat(user, span_warning("I am hit with the familiar feeling of a lucid dream — I know this feeling well."))
		else
			to_chat(user, span_warning("I feel myself drift for a moment, like the feeling right before falling asleep."))
		return TRUE

	if(istype(current_storyteller, /datum/storyteller/dendor))
		if(istype(patron, /datum/patron/divine/dendor))
			to_chat(user, span_warning("Peaceful nature fills my ears. Winds billowing through trees, a distant volf bark. It is comforting."))
		else
			to_chat(user, span_warning("Nothing quite different, though I swear I hear the sound of a nearby rustling tree."))
		return TRUE

	if(istype(current_storyteller, /datum/storyteller/ravox))
		if(istype(patron, /datum/patron/divine/ravox))
			to_chat(user, span_warning("That feeling right before a fight — excitement, duty, honor. It fades as the adrenaline drains."))
		else
			to_chat(user, span_warning("A brief jump of adrenaline before nothing once more."))
		return TRUE

	if(istype(current_storyteller, /datum/storyteller/eora))
		if(istype(patron, /datum/patron/divine/eora))
			to_chat(user, span_warning("Butterflies in the stomach before a confession, the excitement, the small fear. This is love. I know it well."))
		else
			to_chat(user, span_warning("Something flutters in my stomach — a feeling akin to butterflies."))
		return TRUE

	if(istype(current_storyteller, /datum/storyteller/necra))
		if(istype(patron, /datum/patron/divine/necra))
			to_chat(user, span_warning("A deathly stillness in the air. I bask in the peacefulness of it for a moment before reality returns."))
		else
			to_chat(user, span_warning("Something whispers in my ear for a moment. Perhaps it was the wind?"))
		return TRUE

	if(istype(current_storyteller, /datum/storyteller/pestra))
		if(istype(patron, /datum/patron/divine/pestra))
			to_chat(user, span_warning("The distinct smell of decay floods my mind with all sorts of machinations."))
		else
			to_chat(user, span_warning("A damned fly keeps distracting me until I lose concentration entirely."))
		return TRUE

	if(istype(current_storyteller, /datum/storyteller/malum))
		if(istype(patron, /datum/patron/divine/malum))
			to_chat(user, span_warning("Familiar warmth on my cheeks, like sticking my head before a forge or oven."))
		else
			to_chat(user, span_warning("I sit in silence, but I swear I hear the distant ting of a blacksmith at work."))
		return TRUE

	if(istype(current_storyteller, /datum/storyteller/zizo))
		if(istype(patron, /datum/patron/inhumen/zizo))
			to_chat(user, span_warning("I know the answer already."))
		else
			to_chat(user, span_warning("Something does not feel right. I can't quite put my thumb on it."))
		return TRUE

	if(istype(current_storyteller, /datum/storyteller/matthios))
		if(istype(patron, /datum/patron/inhumen/matthios))
			to_chat(user, span_warning("Someone brushes up against me, and I instinctively reach for my coin pouch — only to realize that it never happened."))
		else
			to_chat(user, span_warning("I begin to question if this was really worth casting before it's all over. What a ripoff."))
		return TRUE

	if(istype(current_storyteller, /datum/storyteller/baotha))
		if(istype(patron, /datum/patron/inhumen/baotha))
			to_chat(user, span_warning("Absolutely nothing — the same feeling after a line of Ozium. Dull and numb."))
		else
			to_chat(user, span_warning("My stomach immediately churns. I am not sure if it's guilt or too much drink. It feels horrible."))
		return TRUE

	if(istype(current_storyteller, /datum/storyteller/graggar))
		if(istype(patron, /datum/patron/inhumen/graggar))
			to_chat(user, span_warning("Rage, excitement, the thirst I know so well. I snap back to reality, heart beating fast."))
		else
			to_chat(user, span_warning("After a few moments I don't feel much difference. It leaves me frustrated and angry."))
		return TRUE

	if(istype(current_storyteller, /datum/storyteller/psydon))
		if(istype(patron, /datum/patron/old_god))
			to_chat(user, span_warning("Nothing happens. It is a nice moment of peace."))
		else
			to_chat(user, span_warning("Nothing happens."))
		return TRUE

	if(istype(current_storyteller, /datum/storyteller/xylix))
		if(istype(patron, /datum/patron/divine/xylix))
			to_chat(user, span_warning("A feeling of s— no. No that isn't right. That was a trick! Heehee, can't trick me that easily."))
		else
			var/list/possible_messages = list(
				"I feel warm for a moment, like I am beginning to flush from a fever, and then it fades.",
				"With my eyes rolled back, I feel nothing but the oppressive darkness inside my skull.",
				"I feel myself drift for a moment, like the feeling right before falling asleep.",
				"Nothing quite different, though I swear I hear the sound of a nearby rustling tree.",
				"A brief jump of adrenaline before nothing once more.",
				"Something flutters in my stomach — a feeling akin to butterflies.",
				"Something whispers in my ear for a moment. Perhaps it was the wind?",
				"A damned fly keeps distracting me until I lose concentration entirely.",
				"I sit in silence, but I swear I hear the distant ting of a blacksmith at work.",
				"Something does not feel right. I can't quite put my thumb on it.",
				"I begin to question if this was really worth casting before it's all over. What a ripoff.",
				"My stomach immediately churns. I am not sure if it's guilt or too much drink. It feels horrible.",
				"After a few moments I don't feel much difference. It leaves me frustrated and angry.",
				"Nothing happens.",
			)
			to_chat(user, span_warning(pick(possible_messages)))
		return TRUE

	return TRUE
