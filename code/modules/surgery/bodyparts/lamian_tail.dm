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
	dismember_wound = /datum/wound/dismemberment/lamian_tail

	// Taur stuff!
	// offset_x forces the limb_icon to be shifted on x relative to the human (since these are >32x32)
	var/offset_x = -16
	// taur_icon_state sets which icon to use from icons/mob/taurs.dmi to render
	// (we don't use icon_state to avoid duplicate rendering on dropped organs)
	var/tail_icon_state

	// We can Blend() a color with the base greyscale color, only some tails support this
	var/has_tail_color = TRUE
	var/color_blend_mode = BLEND_ADD
	var/tail_color = null

	var/icon/clip_mask_icon = 'icons/mob/species/taurs_clipmasks_64.dmi'
	var/clip_mask_state
	var/icon/clip_mask = null

/obj/item/bodypart/lamian_tail/New()
	. = ..()

	if(clip_mask_state)
		clip_mask = icon(icon = clip_mask_icon, icon_state = clip_mask_state)
//		clip_mask = new/image(icon = clip_mask_icon, icon_state = clip_mask_state)

/*
	if(clip_mask_state)

		if(src.dir == SOUTH)
			clip_mask_state = clip_mask_state_SOUTH
		if(src.dir == NORTH)
			clip_mask_state = clip_mask_state_NORTH
		if(src.dir == WEST)
			clip_mask_state = clip_mask_state_WEST
		if(src.dir == EAST)
			clip_mask_state = clip_mask_state_EAST

		if(src.dir == SOUTH)
			var/image_dir = SOUTH
			clip_mask = new/icon("icon" = clip_mask_icon, "icon_state" = clip_mask_state, "dir" = image_dir)
		if(src.dir == NORTH)
			var/image_dir = NORTH
			clip_mask = new/icon("icon" = clip_mask_icon, "icon_state" = clip_mask_state, "dir" = image_dir)
		if(src.dir == WEST)
			var/image_dir = WEST
			clip_mask = new/icon("icon" = clip_mask_icon, "icon_state" = clip_mask_state, "dir" = image_dir)
		if(src.dir == WEST)
			var/image_dir = WEST
			clip_mask = new/icon("icon" = clip_mask_icon, "icon_state" = clip_mask_state, "dir" = image_dir)
*/

///obj/item/bodypart/lamian_tail/get_specific_markings_overlays(list/specific_markings, aux = FALSE, mob/living/carbon/human/human_owner, override_color)
//	. = list()

/obj/item/bodypart/lamian_tail/get_limb_icon(dropped, hideaux = FALSE)
	// List of overlays
	. = list()

	var/image_dir = 0
	if(dropped)
		image_dir = SOUTH

	// This section is based on Virgo's human rendering, there may be better ways to do this now
//	var/icon/tail_s = image("icon" = icon, "icon_state" = taur_icon_state, "layer" = BODYPARTS_LAYER, "dir" = image_dir, "pixel_x" = -16) // why doesnt this work
	var/icon/tail_s = new/icon("icon" = icon, "icon_state" = tail_icon_state, "dir" = image_dir)
	if(has_tail_color)
		tail_s.Blend(tail_color, color_blend_mode)
	
//	if(!skeletonized) // kill me obladaet
//		var/list/marking_overlays = get_markings_overlays(override_color)
//		if(marking_overlays)
//			. += marking_overlays

	var/image/working = image(tail_s)
	// because these can overlap other organs, we need to layer slightly higher
	working.layer = -BODYPARTS_LAYER // -FRONT_MUTATIONS_LAYER = tail renders over tits, -BODYPARTS_LAYER = tail renders underneath the tits, as it should
	working.pixel_x = offset_x

	. += working

GLOBAL_LIST_INIT(tail_types, subtypesof(/obj/item/bodypart/lamian_tail))

/obj/item/bodypart/lamian_tail/lamian_tail
	name = "lamian tail"

	offset_x = -16
	tail_icon_state = "og_lamia_tail"
	clip_mask_state = "og_lamia_tail_clipmask"
	has_tail_color = TRUE

/obj/item/bodypart/lamian_tail/mermaid_tail
	name = "mermaid tail"

	offset_x = -16
	tail_icon_state = "og_mermaid_tail"
	clip_mask_state = "og_mermaid_tail_clipmask"
	has_tail_color = TRUE
