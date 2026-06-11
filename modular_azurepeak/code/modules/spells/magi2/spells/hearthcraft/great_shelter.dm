// Great Shelter — Hearthcraft conjuration. 4x4 footprint south-facing arcyne house
// with bed, hearth, and oven. 15-minute duration on every conjured structure.
// Port of Azure-Peak utility/great_shelter.dm.

#define GREAT_SHELTER_DURATION_MAGI2 (15 MINUTES)

/datum/action/cooldown/spell/great_shelter_magi2
	name = "Great Shelter"
	desc = "Conjure a cramped but functional shelter from arcyne force. \
		Contains a bed, a hearth, and an oven. Bring my own cooking tools. \
		The shelter lasts for 15 minutes. Door always faces south."
	button_icon = 'icons/mob/actions/mage_conjure.dmi'
	button_icon_state = "great_shelter"
	sound = 'sound/spellbooks/crystal.ogg'
	spell_color = GLOW_COLOR_HEARTH
	glow_intensity = GLOW_INTENSITY_MEDIUM

	click_to_activate = TRUE
	cast_range = 5
	self_cast_possible = FALSE

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_CONJURE

	invocations = list("Domus Arcana!")
	invocation_type = INVOCATION_SHOUT

	charge_required = TRUE
	charge_time = 5 SECONDS
	charge_drain = 2
	charge_slowdown = CHARGING_SLOWDOWN_HEAVY
	charge_sound = 'sound/magic/charging.ogg'
	cooldown_time = 5 MINUTES

	associated_skill = /datum/skill/magic/arcane
	spell_tier = 1
	spell_impact_intensity = SPELL_IMPACT_NONE
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_NO_MOVE | SPELL_REQUIRES_SAME_Z

/datum/action/cooldown/spell/great_shelter_magi2/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return . | SPELL_CANCEL_CAST
	var/turf/center = get_turf(cast_on)
	if(!center)
		return . | SPELL_CANCEL_CAST
	for(var/list/offset as anything in build_shelter_offsets())
		var/turf/T = locate(center.x + offset[1], center.y + offset[2], center.z)
		if(!T || T.density)
			to_chat(H, span_warning("There isn't enough space to conjure a shelter here!"))
			return . | SPELL_CANCEL_CAST
		for(var/obj/structure/S in T)
			if(S.density)
				to_chat(H, span_warning("There isn't enough space to conjure a shelter here!"))
				return . | SPELL_CANCEL_CAST

/datum/action/cooldown/spell/great_shelter_magi2/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE
	var/turf/center = get_turf(cast_on)
	if(!center)
		return FALSE

	playsound(center, 'sound/spellbooks/crystal.ogg', 100, TRUE)
	H.visible_message(span_warning("[H] conjures a shelter from arcyne force!"))

	for(var/list/offset as anything in build_shelter_offsets())
		var/turf/T = locate(center.x + offset[1], center.y + offset[2], center.z)
		var/tile_type = offset[3]
		switch(tile_type)
			if("wall")
				new /obj/structure/forcefield_weak/shelter_wall_magi2(T, H)
			if("bed")
				new /obj/structure/bed/rogue/conjured_magi2(T)
			if("hearth")
				new /obj/machinery/light/rogue/hearth/conjured_magi2(T)
				new /obj/machinery/light/rogue/oven/conjured_magi2(T)
			if("empty")
				continue
	return TRUE

// Fixed south-facing layout. No rotation.
//   [wall] [wall] [wall] [wall]
//   [wall] [bed ] [hrth] [wall]
//   [wall] [empt] [empt] [wall]
//   [wall] [empt] [wall] [wall]
/datum/action/cooldown/spell/great_shelter_magi2/proc/build_shelter_offsets()
	return list(
		list(-1,  2, "wall"), list( 0,  2, "wall"), list( 1,  2, "wall"),   list( 2,  2, "wall"),
		list(-1,  1, "wall"), list( 0,  1, "bed"),  list( 1,  1, "hearth"), list( 2,  1, "wall"),
		list(-1,  0, "wall"), list( 0,  0, "empty"),list( 1,  0, "empty"),  list( 2,  0, "wall"),
		list(-1, -1, "wall"), list( 0, -1, "empty"),list( 1, -1, "wall"),   list( 2, -1, "wall"),
	)

// ============================================================================
// Conjured structures — all auto-qdel after the shelter duration.
// ============================================================================

/obj/structure/forcefield_weak/shelter_wall_magi2
	name = "arcyne wall"
	desc = "A shimmering wall of arcyne force. It hums faintly."
	max_integrity = 200
	timeleft = 0 // Disable parent's 20s auto-delete — we use the shelter duration instead.
	opacity = TRUE
	color = "#6495ED"

/obj/structure/forcefield_weak/shelter_wall_magi2/Initialize(mapload, mob/summoner)
	. = ..()
	QDEL_IN(src, GREAT_SHELTER_DURATION_MAGI2)

/obj/structure/bed/rogue/conjured_magi2
	name = "arcyne bed"
	desc = "A bed conjured from arcyne force. It looks uncomfortable, but functional."
	color = "#6495ED"

/obj/structure/bed/rogue/conjured_magi2/Initialize(mapload)
	. = ..()
	QDEL_IN(src, GREAT_SHELTER_DURATION_MAGI2)

/obj/machinery/light/rogue/hearth/conjured_magi2
	name = "arcyne hearth"
	desc = "A hearth of blue arcyne flame. It burns without fuel."
	color = "#6495ED"

/obj/machinery/light/rogue/hearth/conjured_magi2/Initialize()
	. = ..()
	QDEL_IN(src, GREAT_SHELTER_DURATION_MAGI2)

/obj/machinery/light/rogue/oven/conjured_magi2
	name = "arcyne oven"
	desc = "An oven conjured from arcyne force. It glows with a faint blue heat."
	color = "#6495ED"

/obj/machinery/light/rogue/oven/conjured_magi2/Initialize()
	. = ..()
	QDEL_IN(src, GREAT_SHELTER_DURATION_MAGI2)

#undef GREAT_SHELTER_DURATION_MAGI2
