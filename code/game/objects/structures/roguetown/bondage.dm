/obj/structure/bondage
	name = "restraint"
	desc = "A crude restraint meant to hold someone in place."
	icon = 'icons/roguetown/misc/structure.dmi'
	anchored = TRUE
	density = TRUE
	can_buckle = TRUE
	max_buckled_mobs = 1
	buckle_lying = 0
	buckle_prevents_pull = TRUE
	buckleverb = "strap"
	breakoutextra = 10 MINUTES
	attacked_sound = list('sound/combat/hits/onwood/woodimpact (1).ogg', 'sound/combat/hits/onwood/woodimpact (2).ogg')
	destroy_sound = 'sound/combat/hits/onwood/destroyfurniture.ogg'
	blade_dulling = DULLING_BASHCHOP
	max_integrity = 200
	resistance_flags = NONE

	var/strap_self_time = 2 SECONDS
	var/strap_other_time = 4 SECONDS

/obj/structure/bondage/Initialize(mapload)
	. = ..()
	LAZYINITLIST(buckled_mobs)

/obj/structure/bondage/buckle_mob(mob/living/M, force = FALSE, check_loc = TRUE)
	if(!anchored)
		return FALSE

	if(force)
		return ..()

	var/mob/living/user = usr
	if(!user)
		return ..()

	if(!istype(M, /mob/living/carbon/human))
		to_chat(user, span_warning("It doesn't look like [M.p_they()] can fit into this properly!"))
		return FALSE

	if(M != user)
		var/valid_restraint = FALSE
		var/mob/living/carbon/carbon = M
		if(carbon.handcuffed)
			valid_restraint = TRUE

		if(!valid_restraint)
			for(var/obj/item/grabbing/G in M.grabbedby)
				if(G.grab_state >= GRAB_AGGRESSIVE)
					valid_restraint = TRUE
					break

		if(!valid_restraint)
			to_chat(user, span_warning("I must grab them more forcefully or restrain them to put them in [src]."))
			return FALSE

		M.visible_message(span_danger("[user] starts strapping [M] into [src]!"), \
			span_userdanger("[user] starts strapping you into [src]!"))

		if(!do_after(user, strap_other_time, src))
			return FALSE
	else
		M.visible_message(span_notice("[user] starts positioning [user.p_them()]self into [src]..."), \
			span_notice("I start positioning myself into [src]..."))

		if(!do_after(user, strap_self_time, src))
			return FALSE

	return ..(M, force, FALSE)

/obj/structure/bondage/chains
	name = "chains"
	desc = "Heavy chains bolted into place."
	icon_state = "CHAINS"
	base_pixel_x = 0
	base_pixel_y = 0
	pixel_x = 0
	pixel_y = 0
	density = FALSE
	layer = ABOVE_MOB_LAYER
	attacked_sound = list('sound/combat/hits/onmetal/metalimpact (1).ogg', 'sound/combat/hits/onmetal/metalimpact (2).ogg')
	destroy_sound = 'sound/combat/hits/onwood/destroyfurniture.ogg'
	buckleverb = "chain"

/obj/structure/bondage/x_pillory
	name = "x-pillory"
	desc = "A brutal restraint shaped like a cross."
	icon_state = "x_pillory"
	layer = OBJ_LAYER
	plane = GAME_PLANE
	var/buckle_offset_x = 0
	var/buckle_offset_y = 2

/obj/structure/bondage/x_pillory/post_buckle_mob(mob/living/M)
	. = ..()
	M.set_mob_offsets("bed_buckle", _x = buckle_offset_x, _y = buckle_offset_y)

/obj/structure/bondage/x_pillory/post_unbuckle_mob(mob/living/M)
	. = ..()
	M.reset_offsets("bed_buckle")

/obj/structure/bondage/x_pillory/user_unbuckle_mob(mob/living/buckled_mob, mob/living/user)
	// Someone else is unbuckling the victim
	if(user != buckled_mob)
		user.visible_message(span_notice("[user] starts unstrapping [buckled_mob] from [src]..."), \
			span_notice("You start unstrapping [buckled_mob] from [src]..."))
		if(do_after(user, 3 SECONDS, src))
			return ..()
		return

	// Victim trying to unbuckle self
	to_chat(user, span_warning("You struggle against the tight straps..."))
	if(do_after(user, 10 SECONDS, src))
		user.visible_message(span_warning("[user] manages to unstrap [user.p_them()]self from [src]!"), \
			span_notice("You manage to unstrap yourself from [src]!"))
		return ..()

/obj/structure/bondage/gloryhole
	name = "gloryhole"
	desc = "A wooden partition with a suspicious hole."
	icon_state = "gloryhole"
	density = TRUE
	layer = ABOVE_ALL_MOB_LAYER
	plane = GAME_PLANE_UPPER
	buckleverb = "position"
	var/buckle_offset_x = 0
	var/buckle_offset_y = 1

/obj/structure/bondage/gloryhole/post_buckle_mob(mob/living/M)
	. = ..()
	M.set_mob_offsets("bed_buckle", _x = buckle_offset_x, _y = buckle_offset_y)

/obj/structure/bondage/gloryhole/post_unbuckle_mob(mob/living/M)
	. = ..()
	M.reset_offsets("bed_buckle")

/obj/structure/bondage/torture_table
	name = "torture table"
	desc = "A cruel table meant for restraining captives."
	icon = 'icons/roguetown/misc/64x64.dmi'
	icon_state = "tort_table"
	base_pixel_x = -16
	base_pixel_y = 0
	pixel_x = -16
	pixel_y = 0
	layer = TABLE_LAYER
	plane = GAME_PLANE
	buckle_lying = 90
	breakoutextra = 2 MINUTES
	max_integrity = 250
	debris = list(/obj/item/natural/wood/plank = 1)
	var/buckle_offset_y = 8

/obj/structure/bondage/torture_table/post_buckle_mob(mob/living/M)
	. = ..()
	M.set_mob_offsets("bed_buckle", _x = 0, _y = buckle_offset_y)

/obj/structure/bondage/torture_table/post_unbuckle_mob(mob/living/M)
	. = ..()
	M.reset_offsets("bed_buckle")

/obj/structure/bondage/torture_table/user_unbuckle_mob(mob/living/buckled_mob, mob/living/user)
	// Someone else is unbuckling the victim
	if(user != buckled_mob)
		user.visible_message(span_notice("[user] starts unchaining [buckled_mob] from [src]..."), \
			span_notice("You start unchaining [buckled_mob] from [src]..."))
		if(do_after(user, 3 SECONDS, src))
			return ..()
		return

	// Victim trying to unbuckle self (long struggle)
	to_chat(user, span_warning("You struggle against the tight chains..."))
	if(do_after(user, 3 MINUTES, src))
		user.visible_message(span_warning("[user] manages to unstrap [user.p_them()]self from [src]!"), \
			span_notice("You manage to unstrap yourself from [src]!"))
		return ..()

/obj/structure/bondage/torture_table/lever
	name = "torture table lever"
	desc = "A torture table with a built-in lever mechanism."
	icon = 'icons/roguetown/misc/64x64.dmi'
	icon_state = "tort_table_lever"
