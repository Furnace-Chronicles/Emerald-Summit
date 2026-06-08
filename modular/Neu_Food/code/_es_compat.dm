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

/* ---------------- Oiled grab-slip (AP living.dm/start_pulling) ----------------
 * Grabbing an oiled target on a BARE limb has a chance to slip free; covered
 * (clothed/armored) limbs give the oil nothing to act on. Called from core
 * /mob/living/start_pulling(); returns TRUE if the grab should fail. */
/mob/living/proc/check_oiled_grab_slip(mob/living/grabber)
	if(!grabber || !has_status_effect(/datum/status_effect/buff/oiled))
		return FALSE
	// Covered limbs aren't slippery — the grab lands normally.
	if(iscarbon(src))
		var/mob/living/carbon/C = src
		var/obj/item/bodypart/grabbed_limb = C.get_bodypart(check_zone(grabber.zone_selected || BODY_ZONE_CHEST))
		if(grabbed_limb && C.is_limb_covered(grabbed_limb))
			return FALSE
	if(!prob(50))
		return FALSE
	grabber.visible_message(span_warning("[src] slips away from [grabber]'s oily grasp!"), \
		span_warning("[src] slips away from my grip - they're too oily!"))
	log_combat(grabber, src, "failed to grab", addition="oiled skin")
	return TRUE

/// TRUE if any worn item covers the given limb (by body_parts_covered bitflag).
/mob/living/carbon/proc/is_limb_covered(obj/item/bodypart/limb)
	if(!limb)
		return FALSE
	for(var/obj/item/I in get_equipped_items())
		if(I.body_parts_covered & limb.body_part)
			return TRUE
	return FALSE

/* ---------------- Fishing bait stat (AP fisher worms.dm) ----------------
 * ES's fisher worm base lacks AP's fishingMods var (used by aged cheese as bait). Declared on the
 * /obj/item base so any item (e.g. the aged-cheese bait in dairy.dm) can set it without erroring. */
/obj/item
	var/list/fishingMods = null

/* ====================================================================================
 * AP PR #6328 ("Felina") — the three new systems ES's foodz merge didn't yet have.
 * Ported isolated here. NEW produce.dmi icon_states required (DMI, handled separately):
 *   pepperseed, pepper, lux_impure_combo, lux_slab, lux_powder
 * ==================================================================================== */

/* ---------------- Ambrosia cider (AP cider.dm + rt_alcohol_reagents.dm) ----------------
 * Ferment a gold apple (ambrosia) + sugar into a ludicrously potent, restorative cider. */
/datum/brewing_recipe/cider/ambrosia
	name = "Cider, Ambrosia"
	category = "Fruit"
	bottle_name = "ambrosia"
	bottle_desc = "A bottle of cider, faintly glowing with a golden hue. It holds the distilled essence of a divine fruit, made ludicrously intense for even the heartiest drinkers."
	reagent_to_brew = /datum/reagent/consumable/ethanol/cider/ambrosia
	needed_reagents = list(/datum/reagent/water = 198)
	needed_crops = list(/obj/item/reagent_containers/food/snacks/grown/apple/gold = 1, /obj/item/reagent_containers/food/snacks/sugar = 5)
	brewed_amount = 2
	brew_time = 15 MINUTES
	sell_value = 200

/datum/reagent/consumable/ethanol/cider/ambrosia
	name = "Ambrosia"
	boozepwr = 100 //Strong Lifeblood, in essence, that'll also leave you completely sloshed. In jubilation, of course!
	taste_description = "divine bliss with hints of appled crispness, followed by what feels like a greatmaul to the forehead"
	color = "#FFD700"
	quality = DRINK_FANTASTIC

/datum/reagent/consumable/ethanol/cider/ambrosia/on_mob_life(mob/living/carbon/M)
	if(ishuman(M))
		if(M.blood_volume < BLOOD_VOLUME_NORMAL)
			M.blood_volume = min(M.blood_volume+20, BLOOD_VOLUME_NORMAL)
	var/list/wCount = M.get_wounds()
	if(wCount.len > 0)
		M.heal_wounds(4)
	if(volume > 0.99)
		M.adjustBruteLoss(-5  * REAGENTS_EFFECT_MULTIPLIER, 0)
		M.adjustFireLoss(-5  * REAGENTS_EFFECT_MULTIPLIER, 0)
		M.adjustOxyLoss(-5, 0)
		M.adjustOrganLoss(ORGAN_SLOT_BRAIN, -5  * REAGENTS_EFFECT_MULTIPLIER)
		M.adjustCloneLoss(-5  * REAGENTS_EFFECT_MULTIPLIER, 0)
		M.adjustOrganLoss(ORGAN_SLOT_EYES, -5 * REAGENTS_EFFECT_MULTIPLIER)
	..()

/* ---------------- Pepper production chain (AP produce.dm + seeds.dm + houseware.dm) ----------------
 * Roast a poison jackberry -> pepperberries -> mill into pepper -> craft a peppermill.
 * (AP roasts the seed; ES seeds aren't food/cookable, so the cook hook lives on the berry, which
 *  also fits AP's own flavor that poison jackberries ARE peppercorns.) */
/obj/item/reagent_containers/food/snacks/grown/pepperseed
	name = "pepperberries"
	desc = "A relative to the Azurian jackberry, stripped free of its fruity skin. Roasting it seems to've dulled its humor-imbalancing \
	properties, though it'll still need to be milled down before it can be used for culinary matters."
	icon = 'icons/roguetown/items/produce.dmi'
	icon_state = "pepperseed"
	foodtype = GRAIN
	tastes = list("spiciness" = 1, "slightly less bitterness" = 1)
	grind_results = list(/datum/reagent/consumable/blackpepper = 1)
	mill_result = /obj/item/reagent_containers/food/snacks/pepper

/obj/item/reagent_containers/food/snacks/grown/berries/rogue/poison
	cooked_type = /obj/item/reagent_containers/food/snacks/grown/pepperseed

/datum/crafting_recipe/roguetown/survival/peppermill
	name = "peppermill"
	category = "Houseware"
	result = list(/obj/item/reagent_containers/peppermill)
	reqs = list(/obj/item/grown/log/tree/small = 1, /obj/item/natural/whetstone = 1, /obj/item/reagent_containers/food/snacks/pepper = 5) //Currently unrefillable, so see this as an equal exchange.
	skillcraft = /datum/skill/craft/carpentry
	craftdiff = 4

/* ---------------- Skysugar (AP produce.dm + alchemy.dm) ----------------
 * Black-market valuable: transmute raisins + lux + starsugar into the panacea, deep-fry it into a
 * skysugar slab, then break the slab into skysugar powder at an alchemy bench. (AP's "lux_impure"
 * maps to ES's single /obj/item/reagent_containers/lux.) */

// starsugar shipped with no taste_description (base default is ""), so anything mostly-starsugar — the
// whole skysugar line — tasted of nothing ("I can taste ."). Give it a flavour. Re-opened here to keep
// the port isolated; the base starsugar drug just gains a taste.
/datum/reagent/starsugar
	taste_description = "a crackling, sugary rush"

/obj/item/reagent_containers/food/snacks/grown/fruit/blackberry/skysugarbase
	name = "panacea of skysugar"
	desc = "A combination of perplexingly diverse ingredients, that - when specifically boiled in fat - merges together to create an \
	alchemically pure substance. South of Azuria's border, it's known as 'skysugar'; a Pestran heresy, rumored to've originally been \
	brewed to cure that which even a quicksilver poultice couldn't mend. Despite its fruity aroma, it probably shouldn't be nibbled at. \
	</br>It needs to be deep-fried in a pot of boiling fat to congeal into a skysugar slab."
	icon = 'icons/roguetown/items/produce.dmi'
	icon_state = "lux_impure_combo"
	faretype = FARE_IMPOVERISHED
	eat_effect = /datum/status_effect/debuff/uncookedfood
	tastes = list("a horrifically bad idea" = 1, "slightly fruity aftertaste" = 1)
	bitesize = 2
	list_reagents = list(/datum/reagent/toxin/killersice = 1, /datum/reagent/starsugar = 8, /datum/reagent/water = 7, /datum/reagent/consumable/nutriment = 3) //Feeling a little.. under the weather?
	deep_fried_type = /obj/item/reagent_containers/food/snacks/grown/skysugarslab
	sellprice = 23

/obj/item/reagent_containers/food/snacks/grown/skysugarslab
	name = "skysugar slab"
	desc = "A crystalline brick that radiates with an almost-ethereal hue, yet to be broken up at an alchemical lab. They call \
	it 'luchtblauw' in Old Azurian; alchemically purified starsugar, to a ninth-of-a-hundreth dram. Born of a Pestran heresy, this \
	mysterious substance is both ludicrously potent and condemned by the Church. Even so, it's worth its weight in gold; and in the \
	hands of a yeoman willing to 'break bad', it can be sold to an amoral Merchant or Bathmatron for a hefty sum."
	icon = 'icons/roguetown/items/produce.dmi'
	icon_state = "lux_slab"
	gender = PLURAL
	bitesize = 7
	faretype = FARE_IMPOVERISHED //Have you ever tried eating a solid chunk of soul-meth, before?
	tastes = list("a slightly less bad idea" = 1, "shards of fruit-tinged glass" = 1)
	list_reagents = list(/datum/reagent/starsugar = 16, /datum/reagent/water = 6, /datum/reagent/consumable/nutriment = 6)
	grind_results = list(/datum/reagent/starsugar = 98) //Add a custom reagent if you wish. I think that'd be pretty cool.
	sellprice = 137
	drop_sound = 'sound/foley/dropsound/glass_drop.ogg'

/obj/item/reagent_containers/powder/starsugar/skysugar
	name = "skysugar"
	desc = "A crystalline powder that radiates with an almost-ethereal hue, and feels deathly cold to the touch. They call \
	it 'luchtblauw' in Old Azurian; alchemically purified starsugar, to a ninth-of-a-hundreth dram. Born of a Pestran heresy, this \
	mysterious substance is both ludicrously potent and condemned by the Church. Even so, it's worth its weight in gold; and in the \
	hands of a yeoman willing to 'break bad', it can be sold to an amoral Merchant or Bathmatron for a hefty sum."
	icon = 'icons/roguetown/items/produce.dmi'
	icon_state = "lux_powder"
	item_state = "lux_powder"
	possible_transfer_amounts = list()
	volume = 38
	list_reagents = list(/datum/reagent/starsugar = 38, /datum/reagent/consumable/nutriment = 38) //Yeah, psyence!
	grind_results = list(/datum/reagent/starsugar = 38)
	sellprice = 123 //Tight, tight, tight! Blue, red, green; whatever, man, just bring me more!
	drop_sound = 'sound/foley/dropsound/glass_drop.ogg'

/datum/crafting_recipe/roguetown/alchemy/skysugarbase
	name = "panacea of skysugar"
	category = "Transmutation"
	result = list(/obj/item/reagent_containers/food/snacks/grown/fruit/blackberry/skysugarbase = 1)
	reqs = list(/obj/item/reagent_containers/food/snacks/rogue/raisins/blackberry = 1, /obj/item/reagent_containers/lux = 1, /obj/item/reagent_containers/powder/starsugar = 1)
	craftdiff = 5 //Better hope you've been practicing!
	verbage_simple = "transmute"

/datum/crafting_recipe/roguetown/alchemy/skysugar
	name = "skysugar slab to skysugar powder (x3)"
	category = "Transmutation"
	result = list(/obj/item/reagent_containers/powder/starsugar/skysugar,
					/obj/item/reagent_containers/powder/starsugar/skysugar,
					/obj/item/reagent_containers/powder/starsugar/skysugar)
	reqs = list(/obj/item/reagent_containers/food/snacks/grown/skysugarslab = 1)
	craftdiff = 1 //Hard part's done. Time to break it up!
	verbage_simple = "transmute"
