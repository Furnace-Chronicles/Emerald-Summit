// Ferramancy shared types — telegraph trap visual + Iron Skin status effect.
// Reuses ES /obj/effect/temp_visual/blade_burst from invoked_aoe/blade_burst.dm.

/obj/effect/temp_visual/trap/ferramancy_magi2
	color = GLOW_COLOR_METAL
	light_color = GLOW_COLOR_METAL

// ---- Iron Skin status effect ----
// Upstream's mechanical effect (25% reduction to incoming armor integrity damage)
// hooks elsewhere in AP's armor system; ES doesn't have that hook, so the buff is
// currently visual + chat flavor only. Filter and messaging match upstream.

#define IRON_SKIN_FILTER "iron_skin_glow"

/atom/movable/screen/alert/status_effect/buff/iron_skin
	name = "Iron Skin"
	desc = "Bits of arcyne iron and steel surround my armor, any attacks against me are blunted."
	icon_state = "buff"

/datum/status_effect/buff/iron_skin
	var/outline_colour = "#708090"
	id = "iron_skin"
	alert_type = /atom/movable/screen/alert/status_effect/buff/iron_skin
	duration = STAT_BUFF_SELF_DURATION

/datum/status_effect/buff/iron_skin/on_creation(mob/living/new_owner, new_duration = null)
	if(new_duration)
		duration = new_duration
	. = ..()

/datum/status_effect/buff/iron_skin/on_apply()
	. = ..()
	if(!owner.get_filter(IRON_SKIN_FILTER))
		owner.add_filter(IRON_SKIN_FILTER, 2, list("type" = "outline", "color" = outline_colour, "alpha" = 40, "size" = 1))
	to_chat(owner, span_notice("Bits of arcyne iron and steel surround my armor, any blows and attacks against me are blunted."))

/datum/status_effect/buff/iron_skin/on_remove()
	. = ..()
	to_chat(owner, span_warning("The iron shell flakes away."))
	owner.remove_filter(IRON_SKIN_FILTER)

#undef IRON_SKIN_FILTER
