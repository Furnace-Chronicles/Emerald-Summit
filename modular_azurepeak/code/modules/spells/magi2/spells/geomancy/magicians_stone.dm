// Magician's Stone — Geomancy utility cantrip. Tears 3-5 stones from the earth at the caster's feet.

/datum/action/cooldown/spell/magicians_stone_magi2
	name = "Magician's Stone"
	desc = "Tear several stones from the earth itself and materialize them at my feet."
	button_icon = 'icons/mob/actions/mage_geomancy.dmi'
	button_icon_state = "magicians_stone"
	sound = 'sound/items/stonestone.ogg'
	spell_color = GLOW_COLOR_EARTHEN
	glow_intensity = GLOW_INTENSITY_LOW

	click_to_activate = FALSE
	self_cast_possible = TRUE

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_CANTRIP

	invocations = list("Emerge, Lapis.")
	invocation_type = INVOCATION_SHOUT

	charge_required = FALSE
	cooldown_time = 2 MINUTES

	associated_skill = /datum/skill/magic/arcane
	spell_tier = 1
	spell_impact_intensity = SPELL_IMPACT_NONE
	point_cost = 1
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_SAME_Z

	var/stone_count_min = 3
	var/stone_count_max = 5

/datum/action/cooldown/spell/magicians_stone_magi2/cast(atom/cast_on)
	. = ..()
	var/mob/living/user = owner
	if(!istype(user))
		return FALSE

	var/count = rand(stone_count_min, stone_count_max)
	var/turf/T = user.drop_location()
	var/handed = FALSE

	for(var/i in 1 to count)
		var/obj/item/natural/stone/S = new(T)
		if(!handed && user.put_in_hands(S))
			handed = TRUE

	playsound(user, 'sound/foley/stone_scrape.ogg', 50, TRUE)
	user.visible_message(
		span_notice("[user] clenches [user.p_their()] fist and [count] stones tear themselves from the earth."),
		span_notice("I tear [count] stones from the earth itself."),
	)
	return TRUE
