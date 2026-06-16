// Rune Ward structures — the actual trigger objects. Spawned by Battle Ward (battle_ward.dm)
// and the upstream Rune Ward touch spell (deferred). Five subtypes: stun, fire, chill, damage, alarm.

#define RUNE_WARD_IMMUNITY_DURATION_MAGI2 (3 SECONDS)
#define RUNE_WARD_IMMUNITY_KEY_MAGI2 "rune_ward_immunity_magi2"

/obj/structure/rune_ward_magi2
	name = "arcyne rune"
	desc = "A faintly glowing symbol etched into the ground."
	icon = 'icons/roguetown/misc/rune_wards.dmi'
	icon_state = "rune"
	attacked_sound = 'sound/magic/magic_nulled.ogg'
	density = FALSE
	anchored = TRUE
	alpha = 180
	layer = TURF_LAYER + 0.1
	max_integrity = 300

	var/datum/weakref/owner_ref
	var/owner_name = "unknown"
	var/owner_ckey = "unknown"
	var/list/allowed_names = list()
	var/checks_antimagic = TRUE
	/// Optional weakref to a /datum/action/cooldown/spell/touch/rune_ward_magi2. When set,
	/// the spell's live allowed_names list is preferred over the inline list above — this
	/// lets the player toggle allies after the rune is already placed. Battle Ward leaves
	/// this null and uses the inline list.
	var/datum/weakref/spell_ref

/obj/structure/rune_ward_magi2/Crossed(atom/movable/AM)
	if(!isliving(AM))
		return
	var/mob/living/L = AM
	var/mob/owner = owner_ref?.resolve()
	if(L == owner)
		return
	var/datum/action/cooldown/spell/touch/rune_ward_magi2/spell = spell_ref?.resolve()
	var/list/effective_allowed = spell ? spell.allowed_names : allowed_names
	if(L.real_name in effective_allowed)
		return
	if(checks_antimagic && L.anti_magic_check())
		trigger_visual()
		qdel(src)
		return
	if(AM.throwing)
		return
	if(L.movement_type & (FLYING|FLOATING))
		return
	if(L.is_jumping)
		return
	if(L.pulledby)
		return
	if(L.mob_timers[RUNE_WARD_IMMUNITY_KEY_MAGI2] && world.time < L.mob_timers[RUNE_WARD_IMMUNITY_KEY_MAGI2])
		return
	L.mob_timers[RUNE_WARD_IMMUNITY_KEY_MAGI2] = world.time + RUNE_WARD_IMMUNITY_DURATION_MAGI2
	log_combat(L, src, "triggered [name] placed by [owner_name] ([owner_ckey])")
	rune_effect(L)
	trigger_visual()
	qdel(src)

/obj/structure/rune_ward_magi2/proc/trigger_visual()
	alpha = 255
	flick(icon_state, src)

/obj/structure/rune_ward_magi2/proc/rune_effect(mob/living/L)
	return

/obj/structure/rune_ward_magi2/Destroy()
	owner_ref = null
	spell_ref = null
	return ..()

/obj/structure/rune_ward_magi2/examine(mob/user)
	. = ..()
	if(max_integrity <= 50)
		. += span_info("This rune looks very fragile — a few solid hits would destroy it.")
	. += span_info("Flying, jumping, or being thrown over the rune will not trigger it.")

/obj/structure/rune_ward_magi2/stun
	name = "shock rune"
	icon_state = RUNE_WARD_ICON_STUN

/obj/structure/rune_ward_magi2/stun/rune_effect(mob/living/L)
	to_chat(L, span_danger("<B>The rune locks my muscles in place!</B>"))
	playsound(src, 'sound/magic/lightning.ogg', 80, TRUE)
	L.electrocute_act(10, src, flags = SHOCK_NOGLOVES)
	L.Paralyze(6 SECONDS)

/obj/structure/rune_ward_magi2/fire
	name = "flame rune"
	icon_state = RUNE_WARD_ICON_FIRE

/obj/structure/rune_ward_magi2/fire/rune_effect(mob/living/L)
	to_chat(L, span_danger("<B>The rune erupts in flames!</B>"))
	playsound(src, pick('sound/misc/explode/incendiary (1).ogg', 'sound/misc/explode/incendiary (2).ogg'), 80, TRUE)
	new /obj/effect/hotspot(get_turf(src))
	L.Knockdown(30)
	L.Slowdown(2)
	L.adjust_fire_stacks(5)
	L.ignite_mob()

/obj/structure/rune_ward_magi2/chill
	name = "frost rune"
	icon_state = RUNE_WARD_ICON_CHILL

/obj/structure/rune_ward_magi2/chill/rune_effect(mob/living/L)
	to_chat(L, span_danger("<B>Frost erupts from the rune and seizes my limbs!</B>"))
	playsound(src, 'sound/spellbooks/crystal.ogg', 80, TRUE)
	L.Paralyze(20)
	L.adjustFireLoss(30)
	apply_frost_stack(L, 4)

/obj/structure/rune_ward_magi2/damage
	name = "force rune"
	icon_state = RUNE_WARD_ICON_DAMAGE
	var/rune_damage = 80

/obj/structure/rune_ward_magi2/damage/rune_effect(mob/living/L)
	to_chat(L, span_danger("<B>Arcyne blades erupt from the rune!</B>"))
	playsound(src, 'sound/magic/blade_burst.ogg', 80, TRUE)
	playsound(src, pick('sound/combat/hits/bladed/genstab (1).ogg', 'sound/combat/hits/bladed/genstab (2).ogg', 'sound/combat/hits/bladed/genstab (3).ogg'), 80, TRUE)
	new /obj/effect/temp_visual/blade_burst(get_turf(src))
	L.Knockdown(30)
	L.Slowdown(2)
	var/mob/living/carbon/human/owner = owner_ref?.resolve()
	if(ishuman(owner) && ishuman(L))
		arcyne_strike(owner, L, null, rune_damage, BODY_ZONE_CHEST, \
			BCLASS_STAB, armor_penetration = 30, spell_name = "Force Rune", \
			damage_type = BRUTE, skip_animation = TRUE)
	else
		L.adjustBruteLoss(rune_damage)

/obj/structure/rune_ward_magi2/alarm
	name = "alarm rune"
	icon_state = RUNE_WARD_ICON_ALARM
	alpha = 40

/obj/structure/rune_ward_magi2/alarm/rune_effect(mob/living/L)
	to_chat(L, span_danger("<B>The rune chimes loudly!</B>"))
	playsound(src, 'sound/magic/charging.ogg', 80, TRUE)
	var/mob/owner = owner_ref?.resolve()
	if(owner)
		var/area/A = get_area(src)
		var/area_name = A ? A.name : "an unknown location"
		to_chat(owner, span_warning("One of my alarm runes has been triggered at [area_name]!"))
		if(owner.client)
			SEND_SOUND(owner, sound('sound/magic/charging.ogg', volume = 40))

#undef RUNE_WARD_IMMUNITY_DURATION_MAGI2
#undef RUNE_WARD_IMMUNITY_KEY_MAGI2
