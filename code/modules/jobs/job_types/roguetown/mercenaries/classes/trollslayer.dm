/datum/advclass/mercenary/trollslayer
    name = "Trollslayer" // barbarian-like subclass with soft-nudist (no armor) and no Fast Reflexes, supposed to soak up damage with their con and skinarmor and chop shit up with class-exclusive axes
    tutorial = "Atop the windy peaks of the dwarven Mountainhomes, you swore an Oath to Ravox, vowing to cleanse the land of monsters or die trying. You give yourself wholly to the Battlefather’s judgment, bearing your devotion as armor and your rage as a weapon. No creacher upon this world is safe from your divine wrath."
    allowed_sexes = list(MALE) // sorry ladies
    allowed_races = list(
        /datum/species/dwarf,
        /datum/species/dwarf/mountain
        )
    outfit = /datum/outfit/job/mercenary/trollslayer
    category_tags = list(CTAG_MERCENARY)
    class_select_category = CLASS_CAT_RACIAL
    cmode_music = 'sound/music/combat_dwarf.ogg'
    extra_context = "Only the dwarves who swore an Oath to Ravox may become Trollslayers." // dwarf exclusive and will force Ravox
    
    traits_applied = list(TRAIT_SLAYER, TRAIT_CRITICAL_RESISTANCE, TRAIT_NOPAINSTUN, TRAIT_CALTROPIMMUNE) //TRAIT_SLAYER prevents equip on the head, armor and shirt slots and enables class-specific weapons
    subclass_stats = list( 
        STATKEY_STR = 3, 
        STATKEY_CON = 5,
        STATKEY_END = 4,
        STATKEY_INT = -2,
    )

    subclass_skills = list(
        /datum/skill/combat/axes = SKILL_LEVEL_MASTER,
        /datum/skill/combat/wrestling = SKILL_LEVEL_JOURNEYMAN,
        /datum/skill/combat/unarmed = SKILL_LEVEL_JOURNEYMAN,
        /datum/skill/misc/athletics = SKILL_LEVEL_EXPERT,
        /datum/skill/misc/climbing = SKILL_LEVEL_APPRENTICE,
        /datum/skill/misc/tracking = SKILL_LEVEL_JOURNEYMAN,
        /datum/skill/labor/butchering = SKILL_LEVEL_NOVICE,
    )
    
/datum/outfit/job/mercenary/trollslayer/pre_equip(mob/living/carbon/human/H)
    ..()
    if(H.mind)

        to_chat(H, span_warning("You are a Slayer - an elite hunter of monsters, hailing from the windy peaks of the dwarven Mountainhomes. Your devotion to Ravox is matched only by your unbridled fury. You forgo defense, entrusting your life to the Just God’s favor and make a living by selling your trophies."))
        H.set_patron(/datum/patron/divine/ravox)
        H.mind.AddSpell(new /obj/effect/proc_holder/spell/self/axedance)
        armor = /obj/item/clothing/suit/roguetown/armor/skin_armor/slayer
        pants = /obj/item/clothing/under/roguetown/heavy_leather_pants
        backr = /obj/item/storage/backpack/rogue/satchel
        belt = /obj/item/storage/belt/rogue/leather/slayer
        beltr = /obj/item/storage/hip/headhook
        backpack_contents = list(
            /obj/item/rogueweapon/huntingknife = 1,
			/obj/item/roguekey/mercenary = 1,
            /obj/item/rope/chain = 1,
            /obj/item/natural/head/troll = 1 // will spawn inside of the belt but I can't be bothered to make it spawn in the headhook
        )
        var/weapons = list("Hatchets", "Greataxe")
        var/weapon_choice = input(H, "Choose your weapon", "How will you channel your rage?") as anything in weapons
        switch(weapon_choice)
            if("Greataxe")
                backl = /obj/item/rogueweapon/stoneaxe/battle/slayer
            if("Hatchets")
                backl = /obj/item/rogueweapon/stoneaxe/woodcut/steel/slayer
                beltl = /obj/item/rogueweapon/stoneaxe/woodcut/steel/slayer

/obj/item/rogueweapon/stoneaxe/woodcut/steel/slayer
    name = "slayer axe" // making this one strong, you spawn with two. If you lose them, that's on you
    desc = "A marvel of craftsdwarfship, this ornate handaxe attunes itself to those who have sworn the Oath."
    force = 28
    possible_item_intents = list(/datum/intent/axe/cut/battle, /datum/intent/axe/chop/battle, /datum/intent/axe/bash)
    gripped_intents = null
    icon_state = "slayer_axe"
    icon = 'icons/roguetown/weapons/axes32.dmi'
    wlength = WLENGTH_NORMAL
    wbalance = WBALANCE_SWIFT
    thrown_bclass = BCLASS_CHOP
    throwforce = 30
    embedding = list("embedded_pain_multiplier" = 4, "embed_chance" = 35, "embedded_fall_chance" = 10)
    resistance_flags = FIRE_PROOF
    max_blade_int = 250
    minstr = 13
    wdefense = 4
    smeltresult = /obj/item/ingot/steel

    var/original_force = null
    var/original_throwforce = null
    var/original_wbalance = null
    var/original_wlength = null
    var/debuffed = FALSE

/obj/item/rogueweapon/stoneaxe/woodcut/steel/slayer/pickup(mob/living/user) // nerfing the axe if someone who doesn't have TRAIT_SLAYER tries to pick it up
    ..()
    if(!user) return

    if(original_force == null)
        original_force = force
        original_throwforce = throwforce
        original_wbalance = wbalance
        original_wlength = wlength

    if(HAS_TRAIT(user, TRAIT_SLAYER))
        if(debuffed)
            debuffed = FALSE
            force = original_force
            throwforce = original_throwforce
            wbalance = original_wbalance
            wlength = original_wlength
        to_chat(user, span_notice("You feel the axe become an extension of your rage!"))

    else 
        if(!debuffed)
            debuffed = TRUE
            force = original_force / 2
            throwforce = original_throwforce / 3
            wbalance = null
            wlength = WLENGTH_SHORT
            to_chat(user, span_warning("The axe feels unwieldy in your hands."))

/obj/item/rogueweapon/stoneaxe/woodcut/steel/slayer/dropped(mob/living/user)
    ..()
    if(original_force != null)
        force = original_force
        throwforce = original_throwforce
        wbalance = original_wbalance
        wlength = original_wlength
        debuffed = FALSE

/obj/item/rogueweapon/stoneaxe/battle/slayer // had to take the /stoneaxe/battle as a baseline cuz /greataxe breaks shrink values for whatever reason idk
    name = "slayer greataxe" //same as the handaxe, strong af, tied to TRAIT_SLAYER
    desc = "A marvel of craftsdwarfship, this ornate greataxe attunes itself to those who have sworn the Oath."
    force = 20
    force_wielded = 38
    possible_item_intents = list(/datum/intent/axe/cut, /datum/intent/axe/chop, /datum/intent/mace/smash/flataxe)
    gripped_intents = list(/datum/intent/axe/cut/battle/greataxe, /datum/intent/axe/chop/battle/greataxe, /datum/intent/mace/smash/flataxe)
    icon_state = "slayer"
    icon = 'icons/roguetown/weapons/64.dmi'
    dropshrink = 0.6
    pixel_y = -16
    pixel_x = -16
    inhand_x_dimension = 64
    inhand_y_dimension = 64
    bigboy = TRUE
    gripsprite = TRUE
    w_class = WEIGHT_CLASS_BULKY
    slot_flags = ITEM_SLOT_BACK
    equip_delay_self = 1.5 SECONDS
    unequip_delay_self = 1.5 SECONDS
    wlength = WLENGTH_NORMAL
    resistance_flags = FIRE_PROOF
    max_blade_int = 350
    minstr = 13
    wdefense = 4
    pickup_sound = 'modular_helmsguard/sound/sheath_sounds/draw_greatsword.ogg'
    sheathe_sound = 'modular_helmsguard/sound/sheath_sounds/put_back_to_leather.ogg'

    var/original_force = null
    var/original_force_wielded = null
    var/original_wlength = null
    var/debuffed = FALSE

/obj/item/rogueweapon/stoneaxe/battle/slayer/getonmobprop(tag)
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.5,"sx" = -7,"sy" = 2,"nx" = 7,"ny" = 3,"wx" = -2,"wy" = 1,"ex" = 1,"ey" = 1,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = -38,"sturn" = 37,"wturn" = 30,"eturn" = -30,"nflip" = 0,"sflip" = 8,"wflip" = 8,"eflip" = 0)
			if("wielded")
				return list("shrink" = 0.5,"sx" = 5,"sy" = -3,"nx" = -5,"ny" = -2,"wx" = -5,"wy" = -1,"ex" = 3,"ey" = -2,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = 7,"sturn" = -7,"wturn" = 16,"eturn" = -22,"nflip" = 8,"sflip" = 0,"wflip" = 8,"eflip" = 0)
			if("onback")
				return list("shrink" = 0.4,"sx" = -1,"sy" = 2,"nx" = 0,"ny" = 2,"wx" = 2,"wy" = 1,"ex" = 0,"ey" = 1,"nturn" = 0,"sturn" = 0,"wturn" = 70,"eturn" = 15,"nflip" = 1,"sflip" = 1,"wflip" = 1,"eflip" = 1,"northabove" = 1,"southabove" = 0,"eastabove" = 0,"westabove" = 0)
	return ..()

/obj/item/rogueweapon/stoneaxe/battle/slayer/pickup(mob/living/user) // same as the handaxe
    ..()
    if(!user) return

    if(original_force == null)
        original_force = force 
        original_force_wielded = force_wielded
        original_wlength = wlength

    if(HAS_TRAIT(user, TRAIT_SLAYER))
        if(debuffed)
            debuffed = FALSE
            force = original_force
            force_wielded = original_force_wielded
            wlength = original_wlength
        to_chat(user, span_notice("You feel the axe become an extension of your rage!"))

    else 
        if(!debuffed)
            debuffed = TRUE
            force = original_force / 2
            force_wielded = original_force_wielded / 2.5
            wlength = WLENGTH_SHORT
            to_chat(user, span_warning("The axe feels unwieldy in your hands."))

/obj/item/rogueweapon/stoneaxe/battle/slayer/dropped(mob/living/user)
    ..()
    if(original_force != null)
        force = original_force
        force_wielded = original_force_wielded
        wlength = original_wlength
        debuffed = FALSE

/obj/item/clothing/suit/roguetown/armor/skin_armor/slayer // a bit of natural armor to offset the nudism and shitty dodge. not too hard to break but will slowly repair itself
    name = "rough skin"
    desc = ""
    icon_state = null
    armor = list("blunt" = 30, "slash" = 30, "stab" = 30, "piercing" = 30, "fire" = 15, "acid" = 15)
    prevent_crits = list(BCLASS_CUT, BCLASS_BLUNT)
    blocksound = SOFTHIT
    blade_dulling = DULLING_BASHCHOP
    slot_flags = ITEM_SLOT_SHIRT|ITEM_SLOT_ARMOR
    body_parts_covered = COVERAGE_FULL
    body_parts_inherent = COVERAGE_FULL
    r_sleeve_status = SLEEVE_NORMAL
    l_sleeve_status = SLEEVE_NORMAL
    allowed_race = list(
        /datum/species/dwarf,
        /datum/species/dwarf/mountain
        )
    surgery_cover = FALSE 
    max_integrity = 200
    sewrepair = FALSE
    var/repair_amount = 10 
    var/repair_time = 50 
    var/last_repair 

/obj/item/clothing/suit/roguetown/armor/skin_armor/slayer/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT)

/obj/item/clothing/suit/roguetown/armor/skin_armor/easttats/dropped(mob/living/carbon/human/user)
	. = ..()
	if(QDELETED(src))
		return
	qdel(src)

/obj/item/clothing/suit/roguetown/armor/skin_armor/slayer/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armor_penetration)
	. = ..()
	if(obj_integrity < max_integrity)
		START_PROCESSING(SSobj, src)
		return

/obj/item/clothing/suit/roguetown/armor/skin_armor/slayer/obj_destruction()
	visible_message(span_bloody("The dwarf flinches from the blow!"), vision_distance = 3) // visual que for breaking

/obj/item/clothing/suit/roguetown/armor/skin_armor/slayer/process()
	if(obj_integrity >= max_integrity) 
		STOP_PROCESSING(SSobj, src)
		src.visible_message(span_notice("Cuts and bruises on the [src] scarify."), vision_distance = 1) // visual que for full repair
		return
	else if(world.time > src.last_repair + src.repair_time)
		src.last_repair = world.time
		obj_integrity = min(obj_integrity + src.repair_amount, src.max_integrity)
	..()

/obj/effect/proc_holder/spell/self/axedance
    name = "Dance of the Axes" // rage button. gives maniac traits, some stats and removes the user's ability to dodge and parry. dunks stamina on expiration
    desc = "You channel your divine rage and turn into an unstoppable juggernaut of steel. You will not defend yourself from attacks while it lasts."
    overlay_state = "axedance"
    antimagic_allowed = TRUE
    recharge_time = 1800
    ignore_cockblock = TRUE
    invocation = "RAVOX, WITNESS ME!!!"
    invocation_type = "shout"
    sound = 'sound/magic/axedance.ogg'

/obj/effect/proc_holder/spell/self/axedance/cast(mob/living/user)
    user.apply_status_effect(/datum/status_effect/buff/axedance)

    return TRUE

#define AXEDANCE_FILTER "axedance_red"
/atom/movable/screen/alert/status_effect/buff/axedance
    name = "Dance of the Axes"
    desc = span_bloody("I AM AN AVATAR OF RAVOXIAN MIGHT")
    icon_state = "buff"
    
/datum/status_effect/buff/axedance
    var/outline_colour = "#EB4445"
    id = "axedance"
    alert_type = /atom/movable/screen/alert/status_effect/buff/axedance
    duration = 300 // should be enough to balance it out
    effectedstats = list("speed" = 3, "strength" = 5)

/datum/status_effect/buff/axedance/on_apply()
    . = ..()
    var/filter = owner.get_filter(AXEDANCE_FILTER)
    if (!filter)
        owner.add_filter(AXEDANCE_FILTER, 2, list("type" = "outline", "color" = outline_colour, "alpha" = 50, "size" = 1))
    to_chat(owner, span_warning("I AM AN AVATAR OF RAVOXIAN MIGHT!"))
    ADD_TRAIT(owner, TRAIT_HARDDISMEMBER, STATUS_EFFECT_TRAIT)
    ADD_TRAIT(owner, TRAIT_INFINITE_STAMINA, STATUS_EFFECT_TRAIT)
    ADD_TRAIT(owner, TRAIT_BLOODLOSS_IMMUNE, STATUS_EFFECT_TRAIT)
    ADD_TRAIT(owner, TRAIT_STRENGTH_UNCAPPED, STATUS_EFFECT_TRAIT)
    ADD_TRAIT(owner, TRAIT_NODEF, STATUS_EFFECT_TRAIT)

/datum/status_effect/buff/axedance/on_remove()
    . = ..()
    to_chat(owner, span_warning("My rage subsides. I feel exhausted."))
    owner.remove_filter(AXEDANCE_FILTER)
    REMOVE_TRAIT(owner, TRAIT_HARDDISMEMBER, STATUS_EFFECT_TRAIT)
    REMOVE_TRAIT(owner, TRAIT_INFINITE_STAMINA, STATUS_EFFECT_TRAIT)
    REMOVE_TRAIT(owner, TRAIT_BLOODLOSS_IMMUNE, STATUS_EFFECT_TRAIT)
    REMOVE_TRAIT(owner, TRAIT_STRENGTH_UNCAPPED, STATUS_EFFECT_TRAIT)
    REMOVE_TRAIT(owner, TRAIT_NODEF, STATUS_EFFECT_TRAIT)
    owner.stamina = 400

#undef AXEDANCE_FILTER

/obj/item/storage/belt/rogue/leather/slayer
    name = "rugged dwarven belt"
    desc = "The golden beard of the face plate doubles as a codpiece."
    icon_state = "slayer"
    item_state = "slayer" // only has dwarven onmob sprites. for whatever reason it doesn't compile if I race restrict it 
    sellprice = 50
    detail_tag = "_belt"
    sewrepair = FALSE
