/datum/virtue/racial/shared/claws
	name = "Sharpened Claws"
	desc = "I have focused on my claws in a younger age allowing me to extend and retract my claws."
	added_skills = list(
		list(/datum/skill/combat/unarmed, 2, 2),
	)
	races = list(
		/datum/species/tabaxi,
		/datum/species/lupian,
		/datum/species/dracon,
	)

/datum/virtue/racial/shared/claws/apply_to_human(mob/living/carbon/human/recipient)
    recipient.AddSpell(new /obj/effect/proc_holder/spell/self/virtue_claws)

// Spells
/obj/effect/proc_holder/spell/self/virtue_claws
	name = "Claws"
	desc = "!"
	overlay_state = "claws"
	antimagic_allowed = TRUE
	recharge_time = 20 //2 seconds
	ignore_cockblock = TRUE
	var/extended = FALSE

/obj/effect/proc_holder/spell/self/virtue_claws/cast(mob/user = usr)
	..()
	// Bhi!
	var/obj/item/rogueweapon/claw/left/l
	var/obj/item/rogueweapon/claw/right/r

	l = user.get_active_held_item()
	r = user.get_inactive_held_item()
	if(extended)
		if(istype(user.get_active_held_item(), /obj/item/rogueweapon/claw))
			user.dropItemToGround(l, TRUE)
			user.dropItemToGround(r, TRUE)
			qdel(l)
			qdel(r)
			user.visible_message("Your claws retract.", "You feel your claws retracting.", "You hear a sound of claws retracting.")
			extended = FALSE
	else
		l = new(user,1)
		r = new(user,2)
		user.put_in_hands(l, TRUE, FALSE, TRUE)
		user.put_in_hands(r, TRUE, FALSE, TRUE)
		user.visible_message("Your claws extend.", "You feel your claws extending.", "You hear a sound of claws extending.")
		extended = TRUE

/obj/item/rogueweapon/claw //Like a less defense dagger
	name = "claw"
	desc = ""
	item_state = null
	lefthand_file = null
	righthand_file = null
	icon = 'icons/roguetown/weapons/misc32.dmi'
	max_blade_int = 600
	max_integrity = 600
	force = 20
	block_chance = 0
	wdefense = 2
	blade_dulling = DULLING_SHAFT_WOOD
	associated_skill = /datum/skill/combat/unarmed
	wlength = WLENGTH_NORMAL
	wbalance = WBALANCE_NORMAL
	w_class = WEIGHT_CLASS_NORMAL
	can_parry = TRUE
	sharpness = IS_SHARP
	parrysound = "bladedmedium"
	swingsound = list('sound/combat/wooshes/bladed/wooshsmall (1).ogg','sound/combat/wooshes/bladed/wooshsmall (2).ogg','sound/combat/wooshes/bladed/wooshsmall (3).ogg')
	parrysound = list('sound/combat/parry/bladed/bladedsmall (1).ogg','sound/combat/parry/bladed/bladedsmall (2).ogg','sound/combat/parry/bladed/bladedsmall (3).ogg')
	possible_item_intents = list(/datum/intent/dagger/cut)
	embedding = list("embedded_pain_multiplier" = 0, "embed_chance" = 0, "embedded_fall_chance" = 0)
	item_flags = DROPDEL
	experimental_inhand = FALSE

/obj/item/rogueweapon/claw/right
	icon_state = "claw_r"

/obj/item/rogueweapon/claw/left
	icon_state = "claw_l"

/obj/item/rogueweapon/claw/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_NOEMBED, TRAIT_GENERIC)