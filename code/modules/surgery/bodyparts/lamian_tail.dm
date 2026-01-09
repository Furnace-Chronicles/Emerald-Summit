// LAMIA
/obj/item/bodypart/lamian_tail
	name = "lamian tail"
	desc = ""
	icon = 'icons/mob/species/taurs.dmi'
	icon_state = ""
	attack_verb = list("hit")
	max_damage = 300
	body_zone = BODY_ZONE_LAMIAN_TAIL
	body_part = LEGS
	body_damage_coeff = 1
	px_x = -16
	px_y = 12
	max_stamina_damage = 50
	subtargets = list(BODY_ZONE_L_LEG, BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_R_FOOT, BODY_ZONE_LAMIAN_TAIL)
	grabtargets = list(BODY_ZONE_LAMIAN_TAIL)
	dismemberable = FALSE //if you lose your tail, it's fucking GG bruh. you can't get the donor anywhere, so no. you can't dismember it brah

	// Taur stuff!
	// offset_x forces the limb_icon to be shifted on x relative to the human (since these are >32x32)
	var/offset_x = -16
	// taur_icon_state sets which icon to use from icons/mob/taurs.dmi to render
	// (we don't use icon_state to avoid duplicate rendering on dropped organs)
	var/tail_icon_state = ""
	var/tail_tip_icon_state = ""
	var/tail_markings_icon_state = ""
	var/tail_markings_tip_icon_state = ""

	// We can Blend() a color with the base greyscale color, only some tails support this
	var/has_tail_color = TRUE
	var/color_blend_mode = BLEND_ADD
	var/tail_color = null
	var/tail_markings_color = "#d4c5c5"

/obj/item/bodypart/lamian_tail/New()
	. = ..()

/obj/item/bodypart/lamian_tail/generate_limb_cache_key(dropped, hideaux)
	var/key = ..()
	return "[key]-[tail_icon_state]-[tail_tip_icon_state]-[tail_markings_icon_state]-[tail_markings_tip_icon_state]-[tail_color]-[tail_markings_color]"

/obj/item/bodypart/lamian_tail/get_limb_icon(dropped, hideaux = FALSE)
	var/new_cache_key = generate_limb_cache_key(dropped, hideaux)
	if(limb_appearance_cache_key == new_cache_key && cached_base_appearances)
		return cached_base_appearances.Copy()

	// List of overlays
	. = list()

	var/image_dir = 0
	if(dropped)
		image_dir = SOUTH

// This section is based on Virgo's human rendering, there may be better ways to do this now

	var/icon/tail_s = new/icon("icon" = icon, "icon_state" = tail_icon_state, "dir" = image_dir)
	var/icon/tail_s_tip = new/icon("icon" = icon, "icon_state" = tail_tip_icon_state, "dir" = image_dir)
	var/icon/tail_markings = new/icon("icon" = icon, "icon_state" = tail_markings_icon_state, "dir" = image_dir)
	var/icon/tail_markings_tip = new/icon("icon" = icon, "icon_state" = tail_markings_tip_icon_state, "dir" = image_dir)
	if(has_tail_color)
		tail_s.Blend(tail_color, color_blend_mode)
		tail_s_tip.Blend(tail_color, color_blend_mode)
		tail_markings.Blend(tail_markings_color, color_blend_mode)
		tail_markings_tip.Blend(tail_markings_color, color_blend_mode)

	var/image/working_markings = image(tail_markings)
	working_markings.layer = -BODY_ADJ_LAYER
	working_markings.pixel_x = offset_x

	. += working_markings

	var/image/working_markings_tip = image(tail_markings_tip)
	working_markings_tip.layer = -BODY_FRONT_FRONT_LAYER
	working_markings_tip.pixel_x = offset_x

	. += working_markings_tip

	var/image/working_tip = image(tail_s_tip)
	working_tip.layer = -BODY_FRONT_LAYER 
	working_tip.pixel_x = offset_x

	. += working_tip

	var/image/working = image(tail_s)
	working.layer = -BODYPARTS_LAYER // baseline bodypart layer aka chest I think?
	working.pixel_x = offset_x

	. += working

	cached_base_appearances = _list_copy(.)
	limb_appearance_cache_key = new_cache_key



GLOBAL_LIST_INIT(tail_types, subtypesof(/obj/item/bodypart/lamian_tail))

/obj/item/bodypart/lamian_tail/lamian_tail
	name = "lamia tail"

	offset_x = -16
	tail_icon_state = "lamia_tail"
	tail_tip_icon_state = "lamia_tail_tip"
	tail_markings_icon_state = "lamia_tail_markings"
	tail_markings_tip_icon_state = "lamia_tail_markings_tip"

	has_tail_color = TRUE

/obj/item/bodypart/lamian_tail/mermaid_tail
	name = "mermaid tail"

	offset_x = -16
	tail_icon_state = "mermaid_tail"
	tail_tip_icon_state = "mermaid_tail_tip"
	tail_markings_icon_state = "mermaid_tail_markings" // done by ooooooog/ShadowDeath6
	tail_markings_tip_icon_state = "mermaid_tail_markings_tip" // done by ooooooog/ShadowDeath6

	has_tail_color = TRUE

/obj/item/bodypart/lamian_tail/mermaid_tail_alt
	name = "mermaid tail, alt"

	offset_x = -16
	tail_icon_state = "mermaid_tail_alt"
	tail_tip_icon_state = "mermaid_tail_alt_tip"
	tail_markings_icon_state = "mermaid_tail_alt_markings" // done by ooooooog/ShadowDeath6
	tail_markings_tip_icon_state = "mermaid_tail_alt_markings_tip" // done by ooooooog/ShadowDeath6

	has_tail_color = TRUE
