//wip wip wup
/obj/structure/mirror
	name = "mirror"
	desc = "Mirror, mirror, on the wall..."
	icon = 'icons/roguetown/misc/structure.dmi'
	icon_state = "mirror"
	density = FALSE
	anchored = TRUE
	shine = SHINE_REFLECTIVE
	max_integrity = 200
	integrity_failure = 0.9
	break_sound = "glassbreak"
	attacked_sound = 'sound/combat/hits/onglass/glasshit.ogg'
	pixel_y = 32
	var/mutable_appearance/mirror_reflection
	var/datum/weakref/mirror_target
	var/static/icon/mirror_mask_icon
	var/static/icon/fancy_mirror_mask_icon

/obj/structure/mirror/fancy
	icon_state = "fancymirror"
	pixel_y = 32

/obj/structure/mirror/Initialize(mapload)
	. = ..()
	if(icon_state == "mirror_broke" && !obj_broken)
		obj_break(null, mapload)
	AddComponent(/datum/component/connect_range, src, list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_neighbor_changed),
		COMSIG_ATOM_EXITED = PROC_REF(on_neighbor_changed),
	), 1, FALSE)
	START_PROCESSING(SSobj, src)

/obj/structure/mirror/Destroy()
	clear_mirror_reflection()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/mirror/proc/clear_mirror_reflection()
	unregister_mirror_target()
	if(mirror_reflection)
		cut_overlay(mirror_reflection)
	mirror_reflection = null
	mirror_target = null

/obj/structure/mirror/proc/unregister_mirror_target()
	var/mob/living/L = mirror_target?.resolve()
	if(L)
		UnregisterSignal(L, list(COMSIG_ATOM_DIR_CHANGE, COMSIG_ATOM_UPDATE_ICON, COMSIG_MOVABLE_MOVED))
	mirror_target = null

/obj/structure/mirror/proc/register_mirror_target(mob/living/L)
	if(!L)
		return
	var/mob/living/current = mirror_target?.resolve()
	if(current && current != L)
		UnregisterSignal(current, list(COMSIG_ATOM_DIR_CHANGE, COMSIG_ATOM_UPDATE_ICON, COMSIG_MOVABLE_MOVED))
	mirror_target = WEAKREF(L)
	RegisterSignal(L, COMSIG_ATOM_DIR_CHANGE, PROC_REF(on_mirror_target_changed))
	RegisterSignal(L, COMSIG_ATOM_UPDATE_ICON, PROC_REF(on_mirror_target_changed))
	RegisterSignal(L, COMSIG_MOVABLE_MOVED, PROC_REF(on_mirror_target_changed))

/obj/structure/mirror/proc/on_mirror_target_changed(datum/source, ...)
	var/mob/living/L = mirror_target?.resolve()
	if(!L || source != L)
		return
	var/list/args_list = args
	var/new_dir = null
	if(length(args_list) >= 3)
		var/old_value = args_list[2]
		var/next_value = args_list[3]
		if(isnum(old_value) && isnum(next_value))
			new_dir = next_value
	update_mirror_reflection(L, new_dir)

/obj/structure/mirror/proc/get_mirror_target()
	var/list/search_tiles = list(loc)
	var/turf/front = get_step(src, dir || SOUTH)
	if(front && !(front in search_tiles))
		search_tiles += front
	var/turf/south = get_step(src, SOUTH)
	if(south && !(south in search_tiles))
		search_tiles += south

	var/mob/living/with_client
	for(var/turf/T in search_tiles)
		for(var/mob/living/L in T)
			if(L.invisibility)
				continue
			if(L.client)
				return L
			if(!with_client)
				with_client = L
	return with_client

/obj/structure/mirror/process()
	if(obj_broken)
		clear_mirror_reflection()
		return

	var/mob/living/L = get_mirror_target()
	if(!L)
		clear_mirror_reflection()
		return

	if(mirror_target?.resolve() != L)
		register_mirror_target(L)

	update_mirror_reflection(L)

/obj/structure/mirror/proc/on_neighbor_changed(datum/source, atom/movable/mover, ...)
	SIGNAL_HANDLER
	if(QDELETED(src))
		return
	if(obj_broken)
		clear_mirror_reflection()
		return
	var/mob/living/L = get_mirror_target()
	if(!L)
		clear_mirror_reflection()
		return
	if(mirror_target?.resolve() != L)
		register_mirror_target(L)
	update_mirror_reflection(L)

/obj/structure/mirror/proc/update_mirror_reflection(mob/living/L, new_dir)
	if(!L || obj_broken)
		clear_mirror_reflection()
		return
	if(mirror_reflection)
		cut_overlay(mirror_reflection)

	mirror_reflection = copy_appearance_filter_overlays(L.appearance)
	mirror_reflection.plane = src.plane
	mirror_reflection.layer = src.layer + 0.01
	mirror_reflection.pixel_x = 0
	mirror_reflection.pixel_y = 0
	mirror_reflection.alpha = 220
	var/dir_to_use = new_dir || L.dir
	if(src.dir & (NORTH|SOUTH))
		if(dir_to_use == NORTH || dir_to_use == SOUTH)
			dir_to_use = turn(dir_to_use, 180)
	else if(src.dir & (EAST|WEST))
		if(dir_to_use == EAST || dir_to_use == WEST)
			dir_to_use = turn(dir_to_use, 180)
	mirror_reflection.dir = dir_to_use

	apply_dir_recursive(mirror_reflection, dir_to_use)

	var/list/bounds = get_mirror_mask_bounds()
	var/center_x = (bounds[1] + bounds[3]) / 2
	var/center_y = (bounds[2] + bounds[4]) / 2
	mirror_reflection.pixel_x = round(center_x - (world.icon_size / 2)) + 2
	mirror_reflection.pixel_y = round(center_y - (world.icon_size / 2)) + -3

	// Mask the reflection to the mirror's visible area
	var/icon/mask_icon = get_mirror_mask_icon()
	mirror_reflection.filters += filter(type = "alpha", icon = mask_icon)

	add_overlay(mirror_reflection)

/obj/structure/mirror/proc/get_mirror_mask_icon()
	if(icon_state == "fancymirror")
		if(!fancy_mirror_mask_icon)
			fancy_mirror_mask_icon = build_mirror_mask(8, 6, 23, 22)
		return fancy_mirror_mask_icon
	if(!mirror_mask_icon)
		mirror_mask_icon = build_mirror_mask(9, 8, 22, 25)
	return mirror_mask_icon

/obj/structure/mirror/proc/get_mirror_mask_bounds()
	if(icon_state == "fancymirror")
		return list(8, 6, 23, 22)
	return list(9, 8, 22, 25)

/obj/structure/mirror/proc/build_mirror_mask(x1, y1, x2, y2)
	var/icon/I = icon('icons/effects/effects.dmi', "nothing")
	I.DrawBox(rgb(255, 255, 255, 255), x1, y1, x2, y2)
	return I

/obj/structure/mirror/proc/apply_dir_recursive(mutable_appearance/appearance, dir_value)
	if(!appearance)
		return
	appearance.dir = dir_value
	if(length(appearance.overlays))
		var/list/new_overlays = list()
		for(var/mutable_appearance/overlay_item as anything in appearance.overlays)
			if(isnull(overlay_item))
				continue
			var/mutable_appearance/real = new()
			real.appearance = overlay_item
			apply_dir_recursive(real, dir_value)
			new_overlays += real
		appearance.overlays = new_overlays
	if(length(appearance.underlays))
		var/list/new_underlays = list()
		for(var/mutable_appearance/underlay_item as anything in appearance.underlays)
			if(isnull(underlay_item))
				continue
			var/mutable_appearance/real = new()
			real.appearance = underlay_item
			apply_dir_recursive(real, dir_value)
			new_underlays += real
		appearance.underlays = new_underlays
/obj/structure/mirror/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(!ishuman(user))
		return

	var/mob/living/carbon/human/H = user

	if(obj_broken || !Adjacent(user))
		return

	if(!HAS_TRAIT(H, TRAIT_MIRROR_MAGIC))
		to_chat(H, span_warning("You look into the mirror but see only your normal reflection."))
		if(HAS_TRAIT(user, TRAIT_BEAUTIFUL))
			H.add_stress(/datum/stressevent/beautiful)
			to_chat(H, span_smallgreen("I look great!"))
			// Apply Xylix buff when examining someone with the beautiful trait
			if(HAS_TRAIT(H, TRAIT_XYLIX) && !H.has_status_effect(/datum/status_effect/buff/xylix_joy))
				H.apply_status_effect(/datum/status_effect/buff/xylix_joy)
				to_chat(H, span_info("My beauty brings a smile to my face, and fortune to my steps!"))
		if(HAS_TRAIT(H, TRAIT_UNSEEMLY))
			to_chat(H, span_warning("Another reminder of my own horrid visage."))
			H.add_stress(/datum/stressevent/unseemly)
		return
	else
		perform_mirror_transform(H)

/obj/structure/mirror/examine_status(mob/user)
	if(obj_broken)
		return list() // no message spam
	return ..()

/obj/structure/mirror/obj_break(damage_flag, mapload)
	if(!obj_broken && !(flags_1 & NODECONSTRUCT_1))
		icon_state = "[icon_state]1"
		if(!mapload)
			new /obj/item/natural/glass_shard (get_turf(src))
		obj_broken = TRUE
	..()

/obj/structure/mirror/deconstruct(disassembled = TRUE)
//	if(!(flags_1 & NODECONSTRUCT_1))
//		if(!disassembled)
//			new /obj/item/shard( src.loc )
	..()

/obj/structure/mirror/welder_act(mob/living/user, obj/item/I)
	..()
	if(user.used_intent.type == INTENT_HARM)
		return FALSE

	if(!obj_broken)
		return TRUE

	if(!I.tool_start_check(user, amount=0))
		return TRUE

	to_chat(user, span_notice("I begin repairing [src]..."))
	if(I.use_tool(src, user, 10, volume=50))
		to_chat(user, span_notice("I repair [src]."))
		obj_broken = 0
		icon_state = initial(icon_state)
		desc = initial(desc)

	return TRUE


/obj/structure/mirror/magic
	name = "magic mirror"
	desc = ""
	icon_state = "magic_mirror"
	var/list/choosable_races = list()

/obj/structure/mirror/magic/New()
	if(!choosable_races.len)
		for(var/speciestype in subtypesof(/datum/species))
			var/datum/species/S = speciestype
			if(initial(S.changesource_flags) & MIRROR_MAGIC)
				choosable_races += initial(S.id)
		choosable_races = sortList(choosable_races)
	..()

/obj/structure/mirror/magic/lesser/New()
	var/list/selectable_species = get_selectable_species()
	choosable_races = selectable_species.Copy()
	..()

/obj/structure/mirror/magic/badmin/New()
	for(var/speciestype in subtypesof(/datum/species))
		var/datum/species/S = speciestype
		if(initial(S.changesource_flags) & MIRROR_BADMIN)
			choosable_races += initial(S.id)
	..()

/obj/structure/mirror/magic/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(!ishuman(user))
		return

	var/mob/living/carbon/human/H = user
	var/should_update = FALSE

	var/choice = input(user, "Something to change?", "Magical Grooming") as null|anything in list("name", "race", "gender", "hair", "eyes", "accessory", "face detail")

	if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return

	switch(choice)
		if("name")
			var/newname = copytext(sanitize_name(input(H, "Who are we again?", "Name change", H.name) as null|text),1,MAX_NAME_LEN)

			if(!newname)
				return
			if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
				return
			H.real_name = newname
			H.name = newname
			if(H.dna)
				H.dna.real_name = newname
			if(H.mind)
				H.mind.name = newname

		if("race")
			var/newrace
			var/racechoice = input(H, "What are we again?", "Race change") as null|anything in choosable_races
			newrace = GLOB.species_list[racechoice]

			if(!newrace)
				return
			if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
				return
			H.set_species(newrace, icon_update=0)

			if(H.dna.species.use_skintones)
				var/new_s_tone = input(user, "Choose your skin tone:", "Race change")  as null|anything in GLOB.skin_tones
				if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
					return

				if(new_s_tone)
					H.skin_tone = new_s_tone
					H.dna.update_ui_block(DNA_SKIN_TONE_BLOCK)

			if(MUTCOLORS in H.dna.species.species_traits)
				var/new_mutantcolor = input(user, "Choose your skin color:", "Race change","#"+H.dna.features["mcolor"]) as color|null
				if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
					return
				if(new_mutantcolor)
					var/temp_hsv = RGBtoHSV(new_mutantcolor)

					if(ReadHSV(temp_hsv)[3] >= ReadHSV("#7F7F7F")[3]) // mutantcolors must be bright
						H.dna.features["mcolor"] = sanitize_hexcolor(new_mutantcolor)

					else
						to_chat(H, span_notice("Invalid color. Your color is not bright enough."))

			H.update_body()
			H.update_hair()
			H.update_body_parts()

		if("hair")
			var/hairchoice = alert(H, "Hairstyle or hair color?", "Change Hair", "Style", "Color")
			if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
				return
			if(hairchoice == "Style") //So you just want to use a mirror then?
				..()
			else
				var/new_hair_color = input(H, "Choose your hair color", "Hair Color","#"+H.hair_color) as color|null
				if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
					return
				if(new_hair_color)
					H.hair_color = sanitize_hexcolor(new_hair_color)
					H.facial_hair_color = H.hair_color
					H.dna.update_ui_block(DNA_HAIR_COLOR_BLOCK)
				if(H.gender == "male")
					var/new_face_color = input(H, "Choose your facial hair color", "Hair Color","#"+H.facial_hair_color) as color|null
					if(new_face_color)
						H.facial_hair_color = sanitize_hexcolor(new_face_color)
						H.dna.update_ui_block(DNA_FACIAL_HAIR_COLOR_BLOCK)
				H.update_hair()

		if("eyes")
			var/new_eye_color = color_pick_sanitized(user, "Choose your eye color", "Eye Color", H.eye_color)
			if(new_eye_color)
				new_eye_color = sanitize_hexcolor(new_eye_color, 6, TRUE)
				var/obj/item/organ/eyes/eyes = H.getorganslot(ORGAN_SLOT_EYES)
				if(eyes)
					eyes.Remove(H)
					eyes.eye_color = new_eye_color
					eyes.Insert(H, TRUE, FALSE)
				H.eye_color = new_eye_color
				H.dna.features["eye_color"] = new_eye_color
				H.dna.update_ui_block(DNA_EYE_COLOR_BLOCK)
				H.update_body_parts()
				should_update = TRUE

		if("accessory")
			var/datum/customizer_choice/bodypart_feature/accessory/accessory_choice = CUSTOMIZER_CHOICE(/datum/customizer_choice/bodypart_feature/accessory)
			var/list/valid_accessories = list("none")
			for(var/accessory_type in accessory_choice.sprite_accessories)
				var/datum/sprite_accessory/accessory/acc = new accessory_type()
				valid_accessories[acc.name] = accessory_type

			var/new_style = input(user, "Choose your accessory", "Accessory Styling") as null|anything in valid_accessories
			if(new_style)
				var/obj/item/bodypart/head/head = H.get_bodypart(BODY_ZONE_HEAD)
				if(head && head.bodypart_features)
					// Remove existing accessory if any
					for(var/datum/bodypart_feature/accessory/old_acc in head.bodypart_features)
						head.remove_bodypart_feature(old_acc)
						break

					// Add new accessory if not "none"
					if(new_style != "none")
						var/datum/bodypart_feature/accessory/accessory_feature = new()
						accessory_feature.set_accessory_type(valid_accessories[new_style], H.hair_color, H)
						head.add_bodypart_feature(accessory_feature)
					should_update = TRUE

		if("face detail")
			var/datum/customizer_choice/bodypart_feature/face_detail/face_choice = CUSTOMIZER_CHOICE(/datum/customizer_choice/bodypart_feature/face_detail)
			var/list/valid_details = list("none")
			for(var/detail_type in face_choice.sprite_accessories)
				var/datum/sprite_accessory/face_detail/detail = new detail_type()
				valid_details[detail.name] = detail_type

			var/new_detail = input(user, "Choose your face detail", "Face Detail") as null|anything in valid_details
			if(new_detail)
				var/obj/item/bodypart/head/head = H.get_bodypart(BODY_ZONE_HEAD)
				if(head && head.bodypart_features)
					// Remove existing face detail if any
					for(var/datum/bodypart_feature/face_detail/old_detail in head.bodypart_features)
						head.remove_bodypart_feature(old_detail)
						break

					// Add new face detail if not "none"
					if(new_detail != "none")
						var/datum/bodypart_feature/face_detail/detail_feature = new()
						detail_feature.set_accessory_type(valid_details[new_detail], H.hair_color, H)
						head.add_bodypart_feature(detail_feature)
					should_update = TRUE

	if(should_update)
		H.update_body()

/obj/structure/mirror/magic/proc/curse(mob/living/user)
	return

/obj/item/handmirror
	name = "hand mirror"
	desc = "Mirror, mirror, in my hand, who's the fairest in the land?"
	icon = 'icons/roguetown/items/misc.dmi'
	icon_state = "handmirror"
	grid_width = 32
	grid_height = 64
	dropshrink = 0.8

/obj/item/handmirror/attack_self(mob/user)
	if(!ishuman(user))
		return

	var/mob/living/carbon/human/H = user

	if(!HAS_TRAIT(H, TRAIT_MIRROR_MAGIC))
		to_chat(H, span_warning("You look into [src] but see only your normal reflection."))
		if(HAS_TRAIT(user, TRAIT_BEAUTIFUL))
			H.add_stress(/datum/stressevent/beautiful)
			H.visible_message(span_notice("[H] admires [H.p_their()] reflection in [src]."), span_smallgreen("I look great!"))
			// Apply Xylix buff when examining someone with the beautiful trait
			if(HAS_TRAIT(H, TRAIT_XYLIX) && !H.has_status_effect(/datum/status_effect/buff/xylix_joy))
				H.apply_status_effect(/datum/status_effect/buff/xylix_joy)
				to_chat(H, span_info("My beauty brings a smile to my face, and fortune to my steps!"))
		if(HAS_TRAIT(H, TRAIT_UNSEEMLY))
			to_chat(H, span_warning("Another reminder of my own horrid visage."))
			H.add_stress(/datum/stressevent/unseemly)
	else
		to_chat(H, span_info("You tilt your jaw from side to side, concentrating on the glamoring magicks limning your form..."))
		if (do_after(H, 3 SECONDS))
			perform_mirror_transform(H)
