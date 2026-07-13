// Rune Ward — Battlewardry touch spell. Hold the spell to keep a focused hand active, then:
//   - DRAW intent + ash item: pick a rune type from a radial and inscribe it on the floor
//   - CLEAN intent: scrub an existing rune. Journeyman+ arcyne does it silently; unskilled
//     attempts risk triggering the rune.
//   - USE intent on self: open the "memorize allies" dialog. Memorized names walk over the
//     player's runes without setting them off.
//
// Inscribed runes are permanent until destroyed (no timer), unlike Battle Ward's 1-minute
// rune pattern. The spell costs no stamina; the per-rune ash cost is the throttle.

#define RUNE_WARD_MAX_MAGI2 10
#define RUNE_WARD_DRAW_TIME_MAGI2 (4 SECONDS)
#define RUNE_WARD_SCRUB_TIME_SKILLED_MAGI2 (3 SECONDS)
#define RUNE_WARD_SCRUB_TIME_UNSKILLED_MAGI2 (8 SECONDS)

/datum/action/cooldown/spell/touch/rune_ward_magi2
	name = "Rune Ward"
	desc = "Focus arcyne energy into my hand. With the DRAW intent and a piece of ash, inscribe a rune of my choice; \
		with CLEAN, scrub an existing rune (journeymen scrub silently, novices may trigger the trap); \
		with USE on myself, memorize allies who can safely cross my runes."
	button_icon = 'icons/mob/actions/mage_battlewardry.dmi'
	button_icon_state = "battle_ward"
	sound = null
	spell_color = GLOW_COLOR_WARD
	glow_intensity = GLOW_INTENSITY_LOW
	attunement_school = ASPECT_NAME_BATTLEWARDRY

	primary_resource_type = SPELL_COST_NONE
	primary_resource_cost = 0

	charge_required = FALSE
	cooldown_time = 1 SECONDS

	can_cast_on_self = TRUE
	infinite_use = TRUE

	hand_path = /obj/item/melee/touch_attack_magi2/rune_ward

	draw_message = "I focus arcyne lines into my hand — I can now inscribe, scrub, or memorize."
	drop_message = "I let the arcyne lines fade from my hand."

	associated_skill = /datum/skill/magic/arcane
	spell_tier = 2
	spell_impact_intensity = SPELL_IMPACT_NONE
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_SAME_Z

	/// Names that may walk over this caster's runes without triggering them.
	var/list/allowed_names = list()
	/// Live list of rune structures placed by this spell (weakrefs).
	var/list/active_runes = list()

/datum/action/cooldown/spell/touch/rune_ward_magi2/Destroy()
	for(var/datum/weakref/ref as anything in active_runes)
		var/obj/structure/rune_ward_magi2/rune = ref?.resolve()
		if(rune)
			rune.spell_ref = null
	active_runes.Cut()
	return ..()

/datum/action/cooldown/spell/touch/rune_ward_magi2/cast_on_hand_hit(atom/target, mob/living/carbon/caster, proximity_flag)
	if(!proximity_flag)
		return FALSE
	if(!caster?.used_intent)
		return FALSE

	switch(caster.used_intent.type)
		if(/datum/intent/hand/draw)
			return draw_rune(target, caster)
		if(/datum/intent/hand/clean)
			return scrub_rune(target, caster)
		if(/datum/intent/use)
			if(target == caster)
				return memorize_allies(caster)
			to_chat(caster, span_warning("USE only opens the memorize dialog when targeting myself."))
			return FALSE
	to_chat(caster, span_warning("Switch to DRAW, CLEAN, or USE to interact with [name]."))
	return FALSE

/datum/action/cooldown/spell/touch/rune_ward_magi2/proc/draw_rune(atom/target, mob/living/carbon/caster)
	var/turf/T = get_turf(target)
	if(!T)
		return FALSE
	if(locate(/obj/structure/rune_ward_magi2) in T)
		to_chat(caster, span_warning("There is already a rune here."))
		return FALSE
	// Count only the live runes belonging to this caster.
	prune_dead_runes()
	if(length(active_runes) >= RUNE_WARD_MAX_MAGI2)
		to_chat(caster, span_warning("I am sustaining the maximum of [RUNE_WARD_MAX_MAGI2] runes. I must scrub an older one first."))
		return FALSE

	var/obj/item/ash/ash = locate() in caster.held_items
	if(!ash)
		to_chat(caster, span_warning("I need a piece of ash in my hand to inscribe a rune."))
		return FALSE

	var/static/list/rune_choices
	if(!rune_choices)
		rune_choices = list(
			RUNE_WARD_STUN   = image('icons/roguetown/misc/rune_wards.dmi', RUNE_WARD_ICON_STUN),
			RUNE_WARD_FIRE   = image('icons/roguetown/misc/rune_wards.dmi', RUNE_WARD_ICON_FIRE),
			RUNE_WARD_CHILL  = image('icons/roguetown/misc/rune_wards.dmi', RUNE_WARD_ICON_CHILL),
			RUNE_WARD_DAMAGE = image('icons/roguetown/misc/rune_wards.dmi', RUNE_WARD_ICON_DAMAGE),
			RUNE_WARD_ALARM  = image('icons/roguetown/misc/rune_wards.dmi', RUNE_WARD_ICON_ALARM),
		)

	var/picked = show_radial_menu(caster, caster, rune_choices, require_near = TRUE, tooltips = TRUE)
	if(!picked)
		return FALSE
	if(QDELETED(ash) || (ash != (locate(/obj/item/ash) in caster.held_items)))
		to_chat(caster, span_warning("I no longer have the ash."))
		return FALSE
	if(locate(/obj/structure/rune_ward_magi2) in T)
		return FALSE

	caster.visible_message(
		span_warning("[caster] starts inscribing a rune on the ground."),
		span_notice("I begin drawing a [picked] rune."),
	)
	if(!do_after(caster, RUNE_WARD_DRAW_TIME_MAGI2, target = T))
		to_chat(caster, span_warning("My inscription is interrupted."))
		return FALSE
	if(QDELETED(ash) || ash.loc != caster)
		to_chat(caster, span_warning("I no longer have the ash."))
		return FALSE
	if(locate(/obj/structure/rune_ward_magi2) in T)
		return FALSE

	var/rune_path = rune_path_for(picked)
	if(!rune_path)
		return FALSE

	var/obj/structure/rune_ward_magi2/rune = new rune_path(T)
	rune.owner_ref = WEAKREF(caster)
	rune.owner_name = caster.real_name
	rune.owner_ckey = caster.ckey || "no ckey"
	rune.spell_ref = WEAKREF(src)
	active_runes += WEAKREF(rune)

	qdel(ash)
	playsound(T, 'sound/magic/whiteflame.ogg', 50, TRUE)
	to_chat(caster, span_notice("I finish inscribing the [picked] rune."))
	return TRUE

/datum/action/cooldown/spell/touch/rune_ward_magi2/proc/scrub_rune(atom/target, mob/living/carbon/caster)
	var/turf/T = get_turf(target)
	if(!T)
		return FALSE
	var/obj/structure/rune_ward_magi2/rune = locate() in T
	if(!rune)
		to_chat(caster, span_warning("There is no rune here to scrub."))
		return FALSE

	var/skill = caster.get_skill_level(/datum/skill/magic/arcane) || 0
	var/skilled = skill >= SKILL_LEVEL_JOURNEYMAN
	var/scrub_time = skilled ? RUNE_WARD_SCRUB_TIME_SKILLED_MAGI2 : RUNE_WARD_SCRUB_TIME_UNSKILLED_MAGI2

	if(skilled)
		to_chat(caster, span_notice("I carefully begin unbinding the rune."))
	else
		caster.visible_message(
			span_warning("[caster] starts roughly scratching at the rune."),
			span_warning("I scratch awkwardly at the rune — this might set it off."),
		)

	if(!do_after(caster, scrub_time, target = T))
		to_chat(caster, span_warning("I lose focus and stop scrubbing."))
		return FALSE
	if(QDELETED(rune))
		return FALSE

	// Unskilled scrubbers risk triggering the rune on themselves.
	if(!skilled && prob(30))
		to_chat(caster, span_danger("I bungle the unbinding — the rune flares!"))
		rune.rune_effect(caster)
		rune.trigger_visual()
		qdel(rune)
		return TRUE

	qdel(rune)
	to_chat(caster, span_notice("I scrub the rune away."))
	return TRUE

/datum/action/cooldown/spell/touch/rune_ward_magi2/proc/memorize_allies(mob/living/carbon/caster)
	if(!caster.mind?.known_people || !length(caster.mind.known_people))
		to_chat(caster, span_warning("I don't know anyone yet."))
		return FALSE

	var/list/options = list()
	for(var/person_name in caster.mind.known_people)
		var/marker = (person_name in allowed_names) ? "✓ " : "  "
		options["[marker][person_name]"] = person_name

	var/choice = input(caster, "Toggle whose passage my runes will ignore. Currently allowed: [length(allowed_names) ? allowed_names.Join(", ") : "no one"]", "Memorize Allies") as null|anything in options
	if(!choice)
		return FALSE
	var/picked_name = options[choice]
	if(picked_name in allowed_names)
		allowed_names -= picked_name
		to_chat(caster, span_notice("My runes will no longer ignore [picked_name]."))
	else
		allowed_names += picked_name
		to_chat(caster, span_notice("My runes will now ignore [picked_name]."))
	return TRUE

/datum/action/cooldown/spell/touch/rune_ward_magi2/proc/prune_dead_runes()
	for(var/datum/weakref/ref as anything in active_runes.Copy())
		var/obj/structure/rune_ward_magi2/rune = ref?.resolve()
		if(QDELETED(rune))
			active_runes -= ref

/datum/action/cooldown/spell/touch/rune_ward_magi2/proc/rune_path_for(rune_id)
	switch(rune_id)
		if(RUNE_WARD_STUN)
			return /obj/structure/rune_ward_magi2/stun
		if(RUNE_WARD_FIRE)
			return /obj/structure/rune_ward_magi2/fire
		if(RUNE_WARD_CHILL)
			return /obj/structure/rune_ward_magi2/chill
		if(RUNE_WARD_DAMAGE)
			return /obj/structure/rune_ward_magi2/damage
		if(RUNE_WARD_ALARM)
			return /obj/structure/rune_ward_magi2/alarm
	return null

// ============================================================================
// Hand subtype — exposes the draw/clean/use intents to the player.
// ============================================================================

/obj/item/melee/touch_attack_magi2/rune_ward
	name = "warding hand"
	desc = "Arcyne lines crawl across my palm, ready to inscribe."
	icon = 'icons/mob/actions/mage_battlewardry.dmi'
	icon_state = "battle_ward"
	possible_item_intents = list(
		/datum/intent/hand/draw,
		/datum/intent/hand/clean,
		/datum/intent/use,
	)

#undef RUNE_WARD_MAX_MAGI2
#undef RUNE_WARD_DRAW_TIME_MAGI2
#undef RUNE_WARD_SCRUB_TIME_SKILLED_MAGI2
#undef RUNE_WARD_SCRUB_TIME_UNSKILLED_MAGI2
