// Light — Fulgurmancy utility cantrip. Summons a condensed-light orb into the caster's hand.

/datum/action/cooldown/spell/light_magi2
	name = "Light"
	desc = "Summon a condensed orb of light into my hand. It burns brightly for ten minutes."
	button_icon = 'icons/mob/actions/roguespells.dmi'
	button_icon_state = "light"
	sound = 'sound/magic/whiteflame.ogg'
	spell_color = GLOW_COLOR_LIGHT
	glow_intensity = GLOW_INTENSITY_LOW

	click_to_activate = FALSE
	self_cast_possible = TRUE

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_CANTRIP

	invocations = list("Evoca Lucem.")
	invocation_type = INVOCATION_WHISPER

	charge_required = TRUE
	charge_time = 0.5 SECONDS
	charge_drain = 1
	charge_slowdown = CHARGING_SLOWDOWN_NONE
	charge_sound = 'sound/magic/charging.ogg'
	cooldown_time = 30 SECONDS

	associated_skill = /datum/skill/magic/arcane
	spell_tier = 1
	spell_impact_intensity = SPELL_IMPACT_NONE
	point_cost = 1
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_SAME_Z

	var/obj/item/held_orb
	var/item_type = /obj/item/flashlight/flare/light_magi2

/datum/action/cooldown/spell/light_magi2/cast(atom/cast_on)
	. = ..()
	var/mob/living/user = owner
	if(!istype(user))
		return FALSE
	if(held_orb && !QDELETED(held_orb))
		QDEL_NULL(held_orb)
	user.dropItemToGround(user.get_active_held_item())
	user.put_in_hands(make_orb(), TRUE)
	user.visible_message(
		span_info("An orb of light condenses in [user]'s hand!"),
		span_info("I condense an orb of pure light!"),
	)
	return TRUE

/datum/action/cooldown/spell/light_magi2/Destroy()
	if(held_orb)
		qdel(held_orb)
	return ..()

/datum/action/cooldown/spell/light_magi2/proc/make_orb()
	held_orb = new item_type
	var/mutable_appearance/glow = mutable_appearance('icons/obj/projectiles.dmi', "gumball")
	held_orb.add_overlay(glow)
	return held_orb

/obj/item/flashlight/flare/light_magi2
	name = "condensed light"
	desc = "An orb of condensed light, drawn from the soul of the magi who summoned it."
	w_class = WEIGHT_CLASS_NORMAL
	light_outer_range = 10
	light_color = "#ffffff"
	force = 10
	icon = 'icons/roguetown/rav/obj/cult.dmi'
	icon_state = "sphere0"
	item_state = "sphere0"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	on_damage = 10
	flags_1 = null
	possible_item_intents = list(/datum/intent/use)
	slot_flags = ITEM_SLOT_HIP
	max_integrity = 200
	fuel = 10 MINUTES
	light_depth = 0
	light_height = 0

/obj/item/flashlight/flare/light_magi2/Initialize()
	. = ..()
	on = TRUE
	update_brightness()
	START_PROCESSING(SSobj, src)

/obj/item/flashlight/flare/light_magi2/process()
	on = TRUE
	open_flame(heat)
	if(!fuel || !on)
		STOP_PROCESSING(SSobj, src)
		return

/obj/item/flashlight/flare/light_magi2/turn_off()
	playsound(src.loc, 'sound/items/firesnuff.ogg', 100)
	STOP_PROCESSING(SSobj, src)
	..()
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_hands()
		M.update_inv_belt()
	damtype = BRUTE
	qdel(src)
