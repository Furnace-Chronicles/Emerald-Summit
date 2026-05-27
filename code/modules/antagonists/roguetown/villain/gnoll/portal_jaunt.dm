// Stripped port of /obj/structure/portal_jaunt from upstream Ratwood dreamwalker.dm.
// ES does not have the dreamwalker antag (and thus no dreamfiend mob/summon proc),
// so the non-safe-passage dreamfiend branch from upstream is omitted entirely.
// Only the gnoll "blood rift" use case (safe_passage = TRUE clean teleport) is supported here.

/obj/structure/portal_jaunt
	name = "dream rift"
	desc = "A shimmering portal to another place. You hear countless whispers when you get close, seems dangerous."
	icon_state = "shitportal"
	icon = 'icons/roguetown/misc/structure.dmi'
	max_integrity = 250
	var/cooldown = 0
	var/uses = 0
	var/max_uses = 3
	var/turf/linked_turf
	var/safe_passage = FALSE

/obj/structure/portal_jaunt/Initialize(mapload)
	. = ..()
	cooldown = world.time + 4 SECONDS
	visible_message(span_warning("[src] shimmers into existence!"))
	playsound(src, 'sound/magic/charging_lightning.ogg', 50, TRUE)

/obj/structure/portal_jaunt/attack_hand(mob/user)
	if(!do_after(user, 1 SECONDS, target = src))
		to_chat(user, span_warning("I must stand still to use the portal."))
		return

	if(world.time < cooldown)
		var/time_left = (cooldown - world.time) * 0.1
		to_chat(user, span_warning("The portal is not stable yet. [time_left] seconds remaining."))
		return

	if(uses >= max_uses)
		to_chat(user, span_warning("The portal collapses as you touch it!"))
		qdel(src)
		return

	if(!linked_turf || !do_teleport(user, linked_turf))
		to_chat(user, span_warning("The portal flickers but nothing happens."))
		return

	uses++
	cooldown = world.time + 15 SECONDS

	visible_message(span_warning("[user] steps through [src]!"))
	playsound(src, 'sound/magic/lightning.ogg', 50, TRUE)

	if(uses >= max_uses)
		visible_message(span_danger("[src] collapses in on itself!"))
		QDEL_IN(src, 1)
