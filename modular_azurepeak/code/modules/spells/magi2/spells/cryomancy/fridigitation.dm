// Fridigitation — utility cantrip that deep-freezes food to extend its shelf life.
// MVP config: keep click_to_activate TRUE so the player clicks the food they want to freeze
// (utility targeting on specific items doesn't make sense in facing direction).
// This is the first spell to keep click_to_activate=TRUE in the pilot; it relies on the
// click-intercept work that's still TODO. Currently clicking the action button will route
// through Trigger and PreActivate(usr) — the user IS the cast_on. The cast() proc then
// resolves the target via the click. NOT YET FUNCTIONAL until click-intercept handlers port.
// Left in for aspect completeness; players can't actually use it yet.

/datum/action/cooldown/spell/fridigitation_magi2
	name = "Fridigitation"
	desc = "Deeply freeze a food item, greatly extending its shelf life. \n\
		(OOC Note: it does not work on produce, only foods, removes rot timer entirely.) \
		NOTE (pilot): click-to-target is not yet wired up; this spell is not currently usable."
	button_icon = 'icons/mob/actions/mage_cryomancy.dmi'
	button_icon_state = "fridigitation"
	sound = 'sound/misc/bamf.ogg'
	spell_color = GLOW_COLOR_ICE
	glow_intensity = GLOW_INTENSITY_LOW

	click_to_activate = TRUE
	self_cast_possible = FALSE
	targets_items = TRUE
	cast_range = 5

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_CANTRIP

	invocations = list("Clamor glacialis!")
	invocation_type = INVOCATION_SHOUT

	charge_required = TRUE
	charge_time = CHARGETIME_POKE
	cooldown_time = 30 SECONDS

	associated_skill = /datum/skill/magic/arcane
	spell_tier = 1
	spell_impact_intensity = SPELL_IMPACT_NONE

	point_cost = 2

	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_SAME_Z

/datum/action/cooldown/spell/fridigitation_magi2/cast(atom/cast_on)
	. = ..()
	if(!istype(cast_on, /obj/item/reagent_containers/food/snacks/rogue))
		to_chat(owner, span_warning("That is not a valid target for Fridigitation."))
		return FALSE
	var/obj/item/reagent_containers/food/snacks/rogue/F = cast_on
	var/turf/T = get_turf(F)
	F.rotprocess = null
	F.add_filter("fridigitation_glow", 2, list("type" = "outline", "color" = "#87CEEB", "alpha" = 150, "size" = 1))
	if(T)
		var/mutable_appearance/chilly = mutable_appearance('icons/effects/effects.dmi', "mist", layer = 10)
		T.add_overlay(chilly)
		addtimer(CALLBACK(T, TYPE_PROC_REF(/atom, cut_overlay), chilly), 1 SECONDS)
	to_chat(owner, "The [F.name] is frozen, greatly extending its shelf life.")
	F.name = "[F.name] (frozen)"
	return TRUE
