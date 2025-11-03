/obj/effect/particle_effect/blueshatter
	name = "shattering"
	icon = 'icons/effects/effects.dmi'
	icon_state = "blueshatter2"
	anchored = TRUE
	light_power = 2
	light_outer_range =  2
	light_color = LIGHT_COLOR_DARK_BLUE
	pixel_x = 0 // -16 both initially
	pixel_y = 0
	layer = ABOVE_LIGHTING_LAYER
	plane = ABOVE_LIGHTING_PLANE

/datum/effect_system/blueshatter
	effect_type = /obj/effect/particle_effect/blueshatter
	autocleanup = TRUE

