#define BCLASS_CHISEL			"chisel"
//................	Handsaw	............... //
/obj/item/rogueweapon/handsaw
	force = 5
	possible_item_intents = list(/datum/intent/dagger/cut, /datum/intent/dagger/chop/cleaver)
	gripped_intents = null
	name = "handsaw"
	desc = "Iron tool for woodworking."
	icon_state = "handsaw"
	icon = 'icons/roguetown/items/crafting.dmi'
	grid_width = 32
	grid_height = 96
	sharpness = IS_SHARP
	wdefense = 0
	wlength = WLENGTH_LONG
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = ITEM_SLOT_HIP
	tool_behaviour = TOOL_SAW
	swingsound = list('sound/combat/wooshes/blunt/shovel_swing.ogg','sound/combat/wooshes/blunt/shovel_swing2.ogg')
	drop_sound = 'sound/foley/dropsound/shovel_drop.ogg'
	smeltresult = /obj/item/ingot/iron
	associated_skill = /datum/skill/combat/axes		//Not an axe but fuck it - you're logging anyway.
	max_blade_int = 50

//................	Chisel	............... //
/obj/item/rogueweapon/chisel
	name = "chisel"
	desc = "Add something to strike it with before doing stonework. Like a mallet or a stone."
	icon_state = "chisel"
	icon = 'icons/roguetown/items/crafting.dmi'
	grid_width = 32
	grid_height = 64
	force = 10
	throwforce = 2
	possible_item_intents = list(/datum/intent/stab)
	sharpness = IS_SHARP
	wlength = WLENGTH_SHORT
	dropshrink = 0.9
	w_class = WEIGHT_CLASS_SMALL
	wdefense = 0
	blade_dulling = 0
	max_integrity = 140
	slot_flags = ITEM_SLOT_HIP
	swingsound = list('sound/combat/wooshes/blunt/shovel_swing.ogg','sound/combat/wooshes/blunt/shovel_swing2.ogg')
	drop_sound = 'sound/foley/dropsound/shovel_drop.ogg'
	associated_skill = /datum/skill/combat/knives	//Not a knife but kinda similar to etching so..
	max_blade_int = 50
	dropshrink = 0.9
	var/already_assembled

/obj/item/rogueweapon/chisel/attackby(obj/item/W, mob/living/user, params)
	. = ..()
	if(already_assembled)
		return

	if(istype(W,/obj/item/natural/stoneblock))
		playsound(user, 'sound/foley/brickdrop.ogg', 100)
		user.visible_message("<span class='info'>[user] adds a striking tool to the chisel set.</span>")
		var/obj/item/rogueweapon/chisel/assembly/stoneblock/F = new(src.loc)
		qdel(W)
		user.put_in_hands(F)
		qdel(src)
		return

	else if(istype(W,/obj/item/natural/stone))
		playsound(user, 'sound/foley/brickdrop.ogg', 100)
		user.visible_message("<span class='info'>[user] adds a striking tool to the chisel set.</span>")
		var/obj/item/rogueweapon/chisel/assembly/stone/F = new(src.loc)
		qdel(W)
		user.put_in_hands(F)
		qdel(src)
		return

	else if(istype(W, /obj/item/rogueweapon/hammer/steel))
		playsound(user, 'sound/foley/brickdrop.ogg', 100)
		user.visible_message("<span class='info'>[user] adds a striking tool to the chisel set.</span>")
		var/obj/item/rogueweapon/chisel/assembly/hammerclaw/F = new(src.loc)
		qdel(W)
		user.put_in_hands(F)
		qdel(src)
		return

	else if(istype(W, /obj/item/rogueweapon/hammer/iron))
		playsound(user, 'sound/foley/brickdrop.ogg', 100)
		user.visible_message("<span class='info'>[user] adds a striking tool to the chisel set.</span>")
		var/obj/item/rogueweapon/chisel/assembly/hammer/F = new(src.loc)
		qdel(W)
		user.put_in_hands(F)
		qdel(src)
		return

	else if(istype(W, /obj/item/rogueweapon/hammer/wood))
		playsound(user, 'sound/foley/brickdrop.ogg', 100)
		user.visible_message("<span class='info'>[user] adds a striking tool to the chisel set.</span>")
		var/obj/item/rogueweapon/chisel/assembly/mallet/F = new(src.loc)
		qdel(W)
		user.put_in_hands(F)
		qdel(src)
		return

//................	Chisel toolset	............... //
/obj/item/rogueweapon/chisel/assembly	// template
	name = "chisel set"
	desc = "Ready to shape stones when held in a steady grip. Can be separated easily."
	grid_width = 64
	grid_height = 64
	possible_item_intents = list(/datum/intent/hit)
	gripped_intents =  list(/datum/intent/chisel)
	already_assembled = TRUE

// Emerald addition: tool-only stance. Outside combat mode the chisel is just a tool — block attacks
// on anything that isn't a legitimate chiseling target. Enter cmode to use it as a weapon.
/obj/item/rogueweapon/chisel/assembly/pre_attack(atom/target, mob/living/user, params)
	if(!user)
		return ..()
	if(user.cmode)
		return ..()
	if(istype(target, /obj/item/natural/stone))
		return ..()
	if(istype(target, /obj/item/natural/rock))
		return ..()
	if(istype(target, /obj/structure/roguerock))
		return ..()
	if(isturf(target))
		return ..()
	to_chat(user, span_warning("I'd need to be in a fighting stance to swing this at [target]."))
	return TRUE

// Emerald addition: after each successful chisel, automatically continue with the next chiselable
// item on the same turf. Player only has to click ONE stone in a pile and the chisel walks through
// the rest until the tile's clear, they move away, or they swap held items.
/proc/chisel_chain_next(mob/living/user, obj/item/W, turf/T)
	if(!user || QDELETED(user) || !W || QDELETED(W) || !T)
		return
	if(user.used_intent?.type != /datum/intent/chisel)
		return
	if(user.get_active_held_item() != W)
		return
	if(!user.Adjacent(T))
		return
	// Look for the next chiselable on this turf. Order: stones, rocks, structures.
	var/obj/item/natural/stone/next_stone = locate() in T
	if(next_stone)
		next_stone.attackby(W, user)
		return
	var/obj/item/natural/rock/next_rock = locate() in T
	if(next_rock)
		next_rock.attackby(W, user)
		return
	var/obj/structure/roguerock/next_struct = locate() in T
	if(next_struct)
		next_struct.attackby(W, user)
		return

/obj/item/rogueweapon/chisel/assembly/mallet
	icon_state = "chiselm"
	item_state = "hammer_w"

/obj/item/rogueweapon/chisel/assembly/mallet/attack_right(mob/user)
	var/obj/item/rogueweapon/chisel/F = new(user.loc)
	var/obj/item/rogueweapon/hammer/wood/E = new(user.loc)
	user.put_in_hands(E)
	playsound(user, 'sound/foley/brickdrop.ogg', 100)
	qdel(src)
	user.put_in_hands(F)

/obj/item/rogueweapon/chisel/assembly/hammer
	icon_state = "chiselh"
	item_state = "hammer_i"

/obj/item/rogueweapon/chisel/assembly/hammer/attack_right(mob/user)
	var/obj/item/rogueweapon/chisel/F = new(user.loc)
	var/obj/item/rogueweapon/hammer/iron/E = new(user.loc)
	user.put_in_hands(E)
	playsound(user, 'sound/foley/brickdrop.ogg', 100)
	qdel(src)
	user.put_in_hands(F)

/obj/item/rogueweapon/chisel/assembly/hammerclaw
	icon_state = "chiselc"
	item_state = "hammer_s"
/obj/item/rogueweapon/chisel/assembly/hammerclaw/attack_right(mob/user)
	var/obj/item/rogueweapon/chisel/F = new(user.loc)
	var/obj/item/rogueweapon/hammer/steel/E = new(user.loc)
	user.put_in_hands(E)
	playsound(user, 'sound/foley/brickdrop.ogg', 100)
	qdel(src)
	user.put_in_hands(F)

/obj/item/rogueweapon/chisel/assembly/stone
	icon_state = "chisels"
	item_state = "stone"
/obj/item/rogueweapon/chisel/assembly/stone/attack_right(mob/user)
	var/obj/item/rogueweapon/chisel/F = new(user.loc)
	var/obj/item/natural/stone/E = new(user.loc)
	user.put_in_hands(E)
	playsound(user, 'sound/foley/brickdrop.ogg', 100)
	qdel(src)
	user.put_in_hands(F)

/obj/item/rogueweapon/chisel/assembly/stoneblock
	icon_state = "chiselb"
	item_state = "block"
/obj/item/rogueweapon/chisel/assembly/stoneblock/attack_right(mob/user)
	var/obj/item/rogueweapon/chisel/F = new(user.loc)
	var/obj/item/natural/stoneblock/E = new(user.loc)
	user.put_in_hands(E)
	playsound(user, 'sound/foley/brickdrop.ogg', 100)
	qdel(src)
	user.put_in_hands(F)


/datum/intent/chisel
	name = "chisel"
	icon_state = "inchisel"
	attack_verb = list("chisels")
	hitsound = list('sound/combat/hits/pick/genpick (1).ogg', 'sound/combat/hits/pick/genpick (2).ogg')
	animname = "strike"
	item_d_type = "stab"
	blade_class = BCLASS_CHISEL
	chargetime = 0
	swingdelay = 3
