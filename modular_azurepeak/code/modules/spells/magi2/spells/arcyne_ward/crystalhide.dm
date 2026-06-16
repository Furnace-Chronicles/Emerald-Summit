// Crystalhide ward — upgraded Arcyne Ward variant. 300 integrity, brigandine-tier
// armor + intelligence bolster while worn. Shatters violently on break, knocking
// nearby foes back. Unlocked by binding the Autowardry minor aspect.

#define CRYSTALHIDE_FILTER "crystalhide_glow"
#define UPGRADE_ARCYNE_INTEGRITY 300

/datum/status_effect/buff/crystalhide
	id = "crystalhide"
	alert_type = /atom/movable/screen/alert/status_effect/buff/crystalhide
	duration = -1
	effectedstats = list(STATKEY_INT = 1)
	var/outline_colour = "#3aa8ff"

/atom/movable/screen/alert/status_effect/buff/crystalhide
	name = "Crystalhide Aggregatemind"
	desc = "Crystal lattice carries thoughts not my own; my mind expandeth in its echoes."

/datum/status_effect/buff/crystalhide/on_apply()
	. = ..()
	if(!owner.get_filter(CRYSTALHIDE_FILTER))
		owner.add_filter(CRYSTALHIDE_FILTER, 2, list("type" = "outline", "color" = outline_colour, "alpha" = 40, "size" = 1))

/datum/status_effect/buff/crystalhide/on_remove()
	. = ..()
	owner.remove_filter(CRYSTALHIDE_FILTER)

/datum/action/cooldown/spell/conjure_arcyne_ward_magi2/crystalhide
	name = "Conjure Crystalhide Ward"
	desc = "Conjure a crystalhide ward - an upgraded arcyne ward crystallized with leyline energy. \
		Grants brigandine-tier protection and bolsters intelligence. Shatters violently when broken, \
		knocking back nearby foes. 300 integrity. Otherwise functions as a standard arcyne ward - \
		yields coverage to real armor, does not regenerate. Cast again to dismiss."
	button_icon = 'icons/mob/actions/mage_conjure.dmi'
	button_icon_state = "conjure_crystalhide"
	spell_color = GLOW_COLOR_ARCANE
	invocations = list("Psymagia Congrego!")
	charge_time = 5 SECONDS
	point_cost = 4
	spell_tier = 3
	ward_type = /obj/item/clothing/suit/roguetown/armor/arcyne_ward_magi2/crystalhide
	dismiss_invocation = "Psymagia Dissipo!"

/obj/item/clothing/suit/roguetown/armor/arcyne_ward_magi2/crystalhide
	name = "crystalhide ward"
	desc = "An arcyne ward crystallized with leyline energy. Tough against blunt force but less rigid than plate. Shatters violently when broken."
	armor = ARMOR_BRIGANDINE
	max_integrity = UPGRADE_ARCYNE_INTEGRITY
	arcyne_armor_tier = ARCYNE_WARD_TIER_GREATER
	ward_examine_phrase = "wrapped in a shimmering arcyne ward sheathed in a lattice of crystal"

/obj/item/clothing/suit/roguetown/armor/arcyne_ward_magi2/crystalhide/setup_ward(mob/living/carbon/human/H)
	..()
	H.apply_status_effect(/datum/status_effect/buff/crystalhide)

/obj/item/clothing/suit/roguetown/armor/arcyne_ward_magi2/crystalhide/cleanup_ward()
	if(ward_owner)
		ward_owner.remove_status_effect(/datum/status_effect/buff/crystalhide)
	..()

/obj/item/clothing/suit/roguetown/armor/arcyne_ward_magi2/crystalhide/obj_break()
	if(ward_owner)
		blast_back(ward_owner)
	..()

/obj/item/clothing/suit/roguetown/armor/arcyne_ward_magi2/crystalhide/proc/blast_back(mob/living/wearer)
	if(!wearer)
		return
	for(var/mob/living/target in oview(1, wearer))
		var/throwtarget = get_edge_target_turf(wearer, get_dir(wearer, get_step_away(target, wearer)))
		target.safe_throw_at(throwtarget, 2, 1, wearer, spin = FALSE, force = MOVE_FORCE_EXTREMELY_STRONG)
		target.adjustBruteLoss(20)

#undef CRYSTALHIDE_FILTER
#undef UPGRADE_ARCYNE_INTEGRITY
