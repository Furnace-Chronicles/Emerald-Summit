// Fire Curtain — Pyromancy ground-targeted persistent flame, port of Azure-Peak fire_curtain.dm
// MVP config: click_to_activate FALSE — curtain centers on the tile in front of caster.
// (Upstream uses click_to_activate TRUE so the curtain centers on a clicked ground target.)

/datum/action/cooldown/spell/fire_curtain_magi2
	name = "Fire Curtain"
	desc = "Conjure a 5x2 curtain of flame in front of you, perpendicular to your facing. \
		After a 3-second telegraph, the fire erupts. Burning for ~10 seconds. \
		The fire does not block movement but will burn anything that passes through or stands in it. \
		You are not immune to your own curtain."
	button_icon = 'icons/mob/actions/mage_pyromancy.dmi'
	button_icon_state = "fire_curtain"
	sound = 'sound/magic/fireball.ogg'
	spell_color = GLOW_COLOR_FIRE
	glow_intensity = GLOW_INTENSITY_HIGH
	attunement_school = ASPECT_NAME_PYROMANCY

	click_to_activate = TRUE
	cast_range = SPELL_RANGE_GROUND
	self_cast_possible = TRUE

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_MAJOR_AOE

	invocations = list("Velum Ignis!")
	invocation_type = INVOCATION_SHOUT

	charge_required = TRUE
	weapon_cast_penalized = TRUE
	charge_time = 1 SECONDS
	charge_drain = 1
	charge_slowdown = CHARGING_SLOWDOWN_MEDIUM
	charge_sound = 'sound/magic/charging_fire.ogg'
	cooldown_time = 25 SECONDS

	associated_skill = /datum/skill/magic/arcane
	spell_impact_intensity = SPELL_IMPACT_HIGH

	var/curtain_width = 5
	var/curtain_depth = 2
	var/telegraph_time = 3 SECONDS

/datum/action/cooldown/spell/fire_curtain_magi2/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE

	var/turf/center
	if(click_to_activate)
		center = get_turf(cast_on)
	else
		// Place the curtain center 2 tiles in front of the caster so the caster
		// isn't standing inside their own curtain.
		center = get_ranged_target_turf(H, H.dir, 2)
	if(!center)
		return FALSE

	var/list/affected_turfs = get_curtain_turfs_magi2(center, H.dir)

	for(var/turf/T in affected_turfs)
		new /obj/effect/temp_visual/trap_wall/fire_magi2(T)

	H.visible_message(span_danger("[H] conjures a wall of flame!"))
	playsound(get_turf(H), 'sound/magic/charging_fire.ogg', 60, TRUE)

	addtimer(CALLBACK(src, PROC_REF(spawn_curtain_magi2), affected_turfs), telegraph_time)
	return TRUE

/datum/action/cooldown/spell/fire_curtain_magi2/proc/get_curtain_turfs_magi2(turf/center, facing)
	var/list/row_turfs = list(center)
	var/spread_dir1
	var/spread_dir2
	if(facing == NORTH || facing == SOUTH)
		spread_dir1 = WEST
		spread_dir2 = EAST
	else
		spread_dir1 = NORTH
		spread_dir2 = SOUTH

	var/half = (curtain_width - 1) / 2
	var/turf/current = center
	for(var/i in 1 to half)
		current = get_step(current, spread_dir1)
		if(current)
			row_turfs += current
	current = center
	for(var/i in 1 to half)
		current = get_step(current, spread_dir2)
		if(current)
			row_turfs += current

	var/list/all_turfs = row_turfs.Copy()
	for(var/d in 1 to curtain_depth - 1)
		var/list/next_row = list()
		for(var/turf/T in row_turfs)
			var/turf/deep = get_step(T, facing)
			if(deep)
				all_turfs |= deep
				next_row += deep
		row_turfs = next_row
	return all_turfs

/datum/action/cooldown/spell/fire_curtain_magi2/proc/spawn_curtain_magi2(list/turfs)
	if(QDELETED(src) || QDELETED(owner))
		return
	for(var/turf/T in turfs)
		new /obj/effect/hotspot(T)
		new /obj/effect/temp_visual/fire(T)
	if(length(turfs))
		playsound(turfs[1], pick('sound/misc/explode/incendiary (1).ogg', 'sound/misc/explode/incendiary (2).ogg'), 120, TRUE, 6)

/obj/effect/temp_visual/trap_wall/fire_magi2
	color = GLOW_COLOR_FIRE
	light_color = GLOW_COLOR_FIRE
	duration = 3 SECONDS
