// Emerald-Summit compatibility shims for the Azure-Peak Neu_Food merge.
// These are small AP definitions ES never adopted but which the merged food set references.
// Kept in one file so the port surface stays isolated and easy to find/remove.

/* ---------------- Combat defines (AP penetration / integrity factors) ----------------
 * ES has no PEN_ weapon-penetration define set (AP-only system). The food code only uses the
 * trivial low end (PEN_NONE = 0 "no penetration", PEN_LIGHT = 1) on slap/poke food weapons,
 * plus the universal blunt integrity factor. Defined here as plain constants; guarded so a
 * future full AP penetration-system port won't collide. */
#ifndef PEN_NONE
#define PEN_NONE 0
#endif
#ifndef PEN_LIGHT
#define PEN_LIGHT 1
#endif
#ifndef BLUNT_DEFAULT_INT_DAMAGEFACTOR
#define BLUNT_DEFAULT_INT_DAMAGEFACTOR 1.6
#endif

/* ---------------- Spice items + reagents (AP produce.dm / powderspice.dm) ---------------- */
/* -------------- Pumpkin spice -------------- */
/obj/item/reagent_containers/food/snacks/pumpkinspice
	name = "pumpkin spice"
	desc = "Rich flavors from a humble origin."
	gender = PLURAL
	icon_state = "pumpkinspice"
	icon = 'icons/roguetown/items/produce.dmi'
	list_reagents = list(/datum/reagent/consumable/pumpkinspice = 1)
	grind_results = list(/datum/reagent/consumable/pumpkinspice = 10)
	volume = 1
	sellprice = 0

/datum/reagent/consumable/pumpkinspice
	name = "pumpkin spice"
	description = "Spiced delight."
	color = "#ffffff"

/* -------------- Pepper -------------- */
/obj/item/reagent_containers/food/snacks/pepper
	name = "pepper"
	desc = "Milled peppercorns, spicy as can be."
	icon = 'icons/roguetown/items/produce.dmi'
	icon_state = "pepper"
	tastes = list("tingling spiciness" = 1, "a subtle hint of bitterness" = 1)
	list_reagents = list(/datum/reagent/consumable/blackpepper = 1)

/* -------------- Allspice -------------- */
/obj/item/reagent_containers/food/snacks/allspice
	name = "allspice"
	desc = "A blend of spices that can liven up even the dreariest broths."
	icon = 'icons/roguetown/items/produce.dmi'
	icon_state = "spice_good"
	tastes = list("fragrant spices" = 1, "a pleasantly complex aroma" = 1)
	list_reagents = list(/datum/reagent/allspice = 1)
	sellprice = 30

/datum/reagent/allspice
	name = "allspice"
	description = "A blend of toasted spices, temptingly aromatic to the senses."
	color = "#CE8C33"
	overdose_threshold = 0
	metabolization_rate = 1
	taste_description = "fragrant spiciness"

/datum/reagent/allspice/on_mob_life(mob/living/carbon/M)
	M.apply_status_effect(/datum/status_effect/buff/greatmealbuff)
	return ..()

/* ---------------- Produce items (AP produce.dm; referenced by drying/stew recipes + dough) ---------------- */
/obj/item/reagent_containers/food/snacks/grown/fruit/tomato_sliced
	name = "split tomato"
	seed = /obj/item/seeds/tomato
	desc = "Split halves of a plump, red fruit with juicy flesh and a balanced sweet-tart flavor. Ruptured skin cradles a deliciously silky surprise, merely a palm away from being smeared into sauce atop flatdough."
	icon_state = "tomato_split"
	tastes = list("to" = 1, "mato" = 1)
	splat_color = "#CD5320"

/obj/item/reagent_containers/food/snacks/grown/fruit/tangerine_sugared
	name = "smothered tangerine"
	desc = "Sugared tangerines, smothered in sweetness and awaiting to be baptized in a pot of boiling fat."
	icon_state = "tangerinesugar"
	faretype = FARE_FINE
	splat_color = "#FFA500"
	tastes = list("overpoweringly sweet" = 1)
	list_reagents = list(/datum/reagent/consumable/nutriment = SNACK_NUTRITIOUS)
	deep_fried_type = /obj/item/reagent_containers/food/snacks/marmalade
	eat_effect = /datum/status_effect/buff/sweet

/obj/item/reagent_containers/food/snacks/grown/fruit/blackberry_sugared
	name = "smothered blackberry"
	desc = "Sugared blackberries, smothered in sweetness and awaiting to be baptized in a pot of boiling fat."
	icon_state = "blackberrysugar"
	faretype = FARE_FINE
	splat_color = "#272C3F"
	tastes = list("overpoweringly sweet" = 1)
	list_reagents = list(/datum/reagent/consumable/nutriment = SNACK_NUTRITIOUS)
	deep_fried_type = /obj/item/reagent_containers/food/snacks/jamtallow
	eat_effect = /datum/status_effect/buff/sweet

/obj/item/reagent_containers/food/snacks/grown/nut_sugared
	name = "smothered rocknut"
	desc = "Sugary rocknuts, smothered in herbal sweetness and awaiting a baptism in boiling fat."
	icon_state = "rocknutssugar"
	faretype = FARE_FINE
	tastes = list("overpoweringly sweet and nutty" = 1)
	filling_color = "#6b4d18"
	list_reagents = list(/datum/reagent/consumable/nutriment = SNACK_NUTRITIOUS)
	grind_results = list(/datum/reagent/consumable/acorn_powder = 4)
	deep_fried_type = /obj/item/reagent_containers/food/snacks/dragee
	eat_effect = /datum/status_effect/buff/sweet

/* ---------------- Caffiend charflaw (AP addiction.dm; sated by the caffeine drink) ---------------- */
/datum/charflaw/addiction/caffiend
	name = "Caffiend"
	desc = "I can't start my day without a cup of tea or coffee."
	time = 40 MINUTES
	needsate_text = "I need a hot brew."

/* ---------------- Oiled buff (AP grabbing.dm; applied by tallow/oil) ----------------
 * Adapted to ES: AP's on_move uses liquid_slip(), which ES lacks; ES uses /mob/proc/slip().
 * Behavior preserved (chance to slip while moving, harder to slip barefoot). */
/datum/status_effect/buff/oiled
	id = "oiled"
	duration = 5 MINUTES
	alert_type = /atom/movable/screen/alert/status_effect/oiled
	var/slip_chance = 2

/datum/status_effect/buff/oiled/on_apply()
	. = ..()
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))

/datum/status_effect/buff/oiled/on_remove()
	. = ..()
	UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)

/datum/status_effect/buff/oiled/proc/on_move(mob/living/mover, atom/oldloc, direction, forced)
	SIGNAL_HANDLER
	if(forced)
		return
	var/slipping_prob = slip_chance
	if(iscarbon(mover))
		var/mob/living/carbon/carbon = mover
		if(!carbon.shoes) // being barefoot makes you slip less
			slipping_prob /= 2
	if(!prob(slipping_prob))
		return
	if(istype(mover))
		mover.slip(2, null, null, 0)

/atom/movable/screen/alert/status_effect/oiled
	name = "Oiled"
	desc = "I'm covered in oil, making me slippery and harder to grab!"
	icon_state = "oiled"

/* ---------------- Fishing bait stat (AP fisher worms.dm) ----------------
 * ES's fisher worm base lacks AP's fishingMods var (used by aged cheese as bait). Declared on the
 * /obj/item base so any item (e.g. the aged-cheese bait in dairy.dm) can set it without erroring. */
/obj/item
	var/list/fishingMods = null
