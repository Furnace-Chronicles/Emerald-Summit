// Blink — Displacement teleport. Click any reachable line-of-sight tile within 5
// paces and you arrive there, leaving an afterimage at the start and a purple
// lightning trail between. Refuses to teleport into walls, doors, bars, gates,
// open air, or teleport-restricted turfs. Port of Azure-Peak misc/blink.dm with
// upstream's arcyne_validate_blink_dest/path helpers inlined as private methods.

/datum/action/cooldown/spell/blink_magi2
	name = "Blink"
	desc = "Teleport to a targeted location within my field of view. Limited to a range of 5 tiles. Only works on the same plane as the caster."
	button_icon = 'icons/mob/actions/roguespells.dmi'
	button_icon_state = "rune6"
	sound = 'sound/magic/blink.ogg'
	spell_color = GLOW_COLOR_DISPLACEMENT
	glow_intensity = GLOW_INTENSITY_LOW

	click_to_activate = TRUE
	self_cast_possible = FALSE

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_TELEPORT

	invocations = list("Saltus Arcanus!")
	invocation_type = INVOCATION_SHOUT

	charge_required = TRUE
	weapon_cast_penalized = FALSE
	charge_time = CHARGETIME_POKE
	charge_drain = 1
	charge_slowdown = CHARGING_SLOWDOWN_SMALL
	charge_sound = 'sound/magic/charging.ogg'
	cooldown_time = 12 SECONDS

	associated_skill = /datum/skill/magic/arcane
	point_cost = 3
	spell_tier = 2
	spell_impact_intensity = SPELL_IMPACT_NONE
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_SAME_Z

	var/max_range = 5
	var/phase_path = /obj/effect/temp_visual/blink_magi2
	var/phase_sound = 'sound/magic/blink.ogg'
	var/phase_beam = "purple_lightning"

/datum/action/cooldown/spell/blink_magi2/cast(atom/cast_on)
	. = ..()
	var/turf/dest = get_turf(cast_on)
	var/turf/start = get_turf(owner)

	var/dest_err = validate_blink_dest(dest, owner)
	if(dest_err)
		to_chat(owner, span_warning(dest_err))
		return FALSE

	if(get_dist(start, dest) > max_range)
		to_chat(owner, span_warning("That location is too far away! I can only blink up to [max_range] tiles."))
		return FALSE

	var/path_err = validate_blink_path(start, dest)
	if(path_err)
		to_chat(owner, span_warning(path_err))
		return FALSE

	owner.visible_message(
		span_warning("<b>[owner]'s body begins to shimmer with arcyne energy as [owner.p_they()] prepare[owner.p_s()] to blink!</b>"),
		span_notice("<b>I focus my arcyne energy, preparing to blink across space!</b>"),
	)

	var/obj/spot_one = new phase_path(start, owner.dir)
	var/obj/spot_two = new phase_path(dest, owner.dir)
	if(phase_beam)
		spot_one.Beam(spot_two, phase_beam, time = 1.5 SECONDS)
	playsound(start, phase_sound, 65, TRUE)
	playsound(dest, phase_sound, 25, TRUE)

	var/mob/living/L = owner
	if(istype(L) && L.buckled)
		L.buckled.unbuckle_mob(L, TRUE)

	// Afterimage at the departure point.
	var/obj/effect/after_image/img = new(start, 0, 0, 0, 0, 0.5 SECONDS, 2 SECONDS, 0)
	img.name = owner.name
	img.appearance = owner.appearance
	img.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	img.alpha = 120
	animate(img, alpha = 0, time = 1.5 SECONDS, easing = LINEAR_EASING)
	QDEL_IN(img, 1.5 SECONDS)

	do_teleport(owner, dest, channel = TELEPORT_CHANNEL_MAGIC)

	owner.visible_message(
		span_danger("<b>[owner] vanishes in a mysterious purple flash!</b>"),
		span_notice("<b>I blink through space in an instant!</b>"),
	)
	return TRUE

// Inlined from upstream classunique/spellblade/anime_spells_helper.dm. The helpers
// are public there because Caedo (spellblade) shares them; in Emerald Summit we
// keep Magi 2 self-contained so we don't drag in the Spellblade port chain.

/datum/action/cooldown/spell/blink_magi2/proc/validate_blink_dest(turf/dest, mob/user)
	if(!dest)
		return "Invalid target location!"
	if(dest.teleport_restricted)
		return "I can't teleport here!"
	var/turf/start = get_turf(user)
	if(dest.z != start.z)
		return "I can only teleport on the same plane!"
	if(istransparentturf(dest))
		return "I cannot teleport to the open air!"
	if(dest.density)
		return "I cannot teleport into a wall!"
	for(var/obj/structure/roguewindow/W in dest)
		if(W.density)
			return "I cannot teleport through a window!"
	for(var/obj/structure/mineral_door/door in dest)
		if(door.density)
			return "I cannot teleport through a door!"
	for(var/obj/structure/bars/B in dest)
		if(B.density)
			return "I cannot teleport through bars!"
	for(var/obj/structure/gate/G in dest)
		if(G.density)
			return "I cannot teleport through a gate!"
	return null

/datum/action/cooldown/spell/blink_magi2/proc/validate_blink_path(turf/start, turf/dest)
	var/list/turf_list = getline(start, dest)
	if(length(turf_list) > 0)
		turf_list.len--
	for(var/turf/T as anything in turf_list)
		if(T == start)
			continue
		if(T.density)
			return "I cannot teleport through walls!"
		for(var/obj/structure/mineral_door/door in T.contents)
			if(door.density)
				return "I cannot teleport through doors!"
		for(var/obj/structure/roguewindow/window in T.contents)
			if(window.density && !window.climbable)
				return "I cannot teleport through windows!"
		for(var/obj/structure/bars/B in T.contents)
			if(B.density)
				return "I cannot teleport through bars!"
		for(var/obj/structure/gate/G in T.contents)
			if(G.density)
				return "I cannot teleport through gates!"
	return null

/obj/effect/temp_visual/blink_magi2
	icon = 'icons/effects/effects.dmi'
	icon_state = "hierophant_blast"
	name = "teleportation magic"
	desc = "Get out of the way!"
	randomdir = FALSE
	duration = 4 SECONDS
	layer = MASSIVE_OBJ_LAYER
	light_outer_range = 2
	light_color = COLOR_PALE_PURPLE_GRAY
