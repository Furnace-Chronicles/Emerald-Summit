// Mending — Augmentation utility. Restores 20% of an item's max integrity plus an
// Intelligence scaling bonus. Cooldown 20s.

/datum/action/cooldown/spell/mending_magi2
	name = "Mending"
	desc = "Use arcyne energy to mend an item. Effect of repair scales off of my Intelligence."
	button_icon = 'icons/mob/actions/roguespells.dmi'
	button_icon_state = "mending"
	sound = 'sound/magic/whiteflame.ogg'
	spell_color = GLOW_COLOR_BUFF
	glow_intensity = GLOW_INTENSITY_LOW

	click_to_activate = TRUE
	self_cast_possible = FALSE
	cast_range = SPELL_RANGE_GROUND
	charge_required = TRUE
	charge_time = 4 SECONDS
	charge_message = "Concentrating..."
	// Mending specifically targets items, so middle-clicks on an item must reach the
	// cast instead of falling through to normal item handling (pickup/attack). Without
	// this, InterceptClickOn returns FALSE for every /obj/item target and the spell
	// silently does nothing. Matches Fridigitation, the other item-targeting spell.
	targets_items = TRUE

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_CANTRIP

	invocations = list("Reficio")
	invocation_type = INVOCATION_SHOUT

	cooldown_time = 20 SECONDS

	associated_skill = /datum/skill/magic/arcane
	spell_tier = 1
	spell_impact_intensity = SPELL_IMPACT_NONE
	point_cost = 2
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_SAME_Z | SPELL_REQUIRES_NO_MOVE

	var/repair_percent = 0.20

/datum/action/cooldown/spell/mending_magi2/cast(atom/cast_on)
	. = ..()
	var/mob/living/user = owner
	if(!istype(user))
		return FALSE
	if(!istype(cast_on, /obj/item))
		to_chat(user, span_warning("I need to target an item!"))
		return FALSE

	var/obj/item/I = cast_on
	if(!I.anvilrepair && !I.sewrepair)
		to_chat(user, span_warning("Not even magic can mend this item!"))
		return FALSE
	if(I.obj_integrity >= I.max_integrity && I.body_parts_covered_dynamic == I.body_parts_covered)
		to_chat(user, span_info("[I] appears to be in perfect condition."))
		return FALSE

	var/int_bonus = CLAMP((user.STAINT * 0.01), 0.01, 0.9)
	var/applied = (initial(repair_percent) + int_bonus) * I.max_integrity

	I.obj_integrity = min(I.obj_integrity + applied, I.max_integrity)
	user.visible_message(span_info("[I] glows in a faint mending light."))
	playsound(I, 'sound/magic/whiteflame.ogg', 35, TRUE, -2)

	if(I.obj_integrity >= I.max_integrity)
		if(I.obj_broken)
			I.obj_fix()
		if(I.body_parts_covered_dynamic != I.body_parts_covered)
			I.repair_coverage()
			to_chat(user, span_info("[I]'s shorn layers mend together, completely."))

	return TRUE
