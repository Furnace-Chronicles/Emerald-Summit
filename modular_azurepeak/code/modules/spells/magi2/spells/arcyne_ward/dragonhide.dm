// Dragonhide ward — upgraded Arcyne Ward variant. 300 integrity, fire-resistance
// trait + outline filter while worn. Unlocked by binding the Autowardry minor aspect.

#define DRAGONHIDE_FILTER "dragonhide_glow"
#define UPGRADE_ARCYNE_INTEGRITY 300

/datum/status_effect/buff/dragonhide
	id = "dragonscaled"
	alert_type = /atom/movable/screen/alert/status_effect/buff/dragonhide
	duration = -1
	effectedstats = list(STATKEY_CON = 1)
	var/outline_colour = "#c23d09"

/atom/movable/screen/alert/status_effect/buff/dragonhide
	name = "Dragonhide"
	desc = "Draconic scales shield me from the worst of the flames."

/datum/status_effect/buff/dragonhide/on_apply()
	. = ..()
	ADD_TRAIT(owner, TRAIT_FIRE_RESIST, TRAIT_GENERIC)
	if(!owner.get_filter(DRAGONHIDE_FILTER))
		owner.add_filter(DRAGONHIDE_FILTER, 2, list("type" = "outline", "color" = outline_colour, "alpha" = 60, "size" = 1))

/datum/status_effect/buff/dragonhide/on_remove()
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_FIRE_RESIST, TRAIT_GENERIC)
	owner.remove_filter(DRAGONHIDE_FILTER)

/datum/action/cooldown/spell/conjure_arcyne_ward_magi2/dragonhide
	name = "Conjure Dragonhide Ward"
	desc = "Conjure a dragonhide ward - an upgraded arcyne ward hardened with draconic scales. \
		Grants fire resistance, halving fire damage and causing flames to burn out faster, and bolsters constitution. \
		300 integrity. Otherwise functions as a standard arcyne ward - yields coverage to real armor, does not regenerate. \
		Cast again to dismiss. Cooldown begins when dismissed or destroyed."
	button_icon = 'icons/mob/actions/mage_conjure.dmi'
	button_icon_state = "conjure_dragonhide"
	spell_color = GLOW_COLOR_METAL
	invocations = list("Draconis Congrego!")
	point_cost = 4
	ward_type = /obj/item/clothing/suit/roguetown/armor/arcyne_ward_magi2/dragonhide
	dismiss_invocation = "Draconis Dissipo!"

/obj/item/clothing/suit/roguetown/armor/arcyne_ward_magi2/dragonhide
	name = "dragonhide ward"
	desc = "An arcyne ward hardened with draconic scales. Resistant to flame."
	armor = ARMOR_DRAGONHIDE
	max_integrity = UPGRADE_ARCYNE_INTEGRITY
	arcyne_armor_tier = ARCYNE_WARD_TIER_GREATER
	ward_examine_phrase = "wrapped in a shimmering arcyne ward covered in draconic scales"

/obj/item/clothing/suit/roguetown/armor/arcyne_ward_magi2/dragonhide/setup_ward(mob/living/carbon/human/H)
	..()
	H.apply_status_effect(/datum/status_effect/buff/dragonhide)

/obj/item/clothing/suit/roguetown/armor/arcyne_ward_magi2/dragonhide/cleanup_ward()
	if(ward_owner)
		ward_owner.remove_status_effect(/datum/status_effect/buff/dragonhide)
	..()

#undef DRAGONHIDE_FILTER
#undef UPGRADE_ARCYNE_INTEGRITY
