/datum/advclass/wretch/heretic
	name = "Heretic"
	tutorial = "You father your unholy cause through the most time-tested of ways: hard, heavy steel in both arms and armor."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	outfit = /datum/outfit/job/wretch/heretic
	category_tags = list(CTAG_WRETCH)
	extra_context = "If your patron is the following: Psydon, Astrata, Ravox, Necra or Eora, your patron will be set to ZIZO. Excommunication does not work on the Ten worshippers."

	traits_applied = list(TRAIT_RITUALIST, TRAIT_HEAVYARMOR, TRAIT_HERETIC_DEVOUT)
	// Heretic is by far the best class with access to rituals (as long as they play a god with ritual), holy and heavy armor. So they keep 7 points.
	// ... except templars get the same but aren't supposed to 1vX
	subclass_stats = list(
		STATKEY_STR = 2,
		STATKEY_CON = 2,
		STATKEY_END = 3
	)

	subclass_skills = list(
		/datum/skill/magic/holy = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/maces = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/swords = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/axes = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/shields = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/whipsflails = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/wrestling = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/swimming = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/unarmed = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/athletics = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/reading = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/medicine = SKILL_LEVEL_NOVICE,
	)

/datum/outfit/job/wretch/heretic
	has_loadout = TRUE

/datum/outfit/job/wretch/heretic/pre_equip(mob/living/carbon/human/H)
	..()
	if ((istype(H.patron, /datum/patron/divine/astrata) || istype(H.patron, /datum/patron/divine/necra) || istype(H.patron, /datum/patron/divine/eora) || istype(H.patron, /datum/patron/divine/ravox) || istype(H.patron, /datum/patron/old_god)))
		to_chat(H, span_warning("My former deity frowned upon my practices. I have since turned to ZIZO..."))
		H.set_patron(/datum/patron/inhumen/zizo)
	to_chat(H, span_warning("You father your unholy cause through the most time-tested of ways: hard, heavy steel in both arms and armor."))
	H.mind.current.faction += "[H.name]_faction"
	H.set_blindness(0)
	var/weapons = list("Longsword", "Mace", "Flail", "Axe", "Spear")
	var/weapon_choice = input(H, "Choose your weapon.", "TAKE UP ARMS") as anything in weapons
	switch(weapon_choice)
		if("Longsword")
			H.adjust_skillrank_up_to(/datum/skill/combat/swords, SKILL_LEVEL_EXPERT, TRUE)
			beltr = /obj/item/rogueweapon/scabbard/sword
			r_hand = /obj/item/rogueweapon/sword/long
		if("Mace")
			H.adjust_skillrank_up_to(/datum/skill/combat/maces, SKILL_LEVEL_EXPERT, TRUE)
			beltr = /obj/item/rogueweapon/mace/steel
		if("Flail")
			H.adjust_skillrank_up_to(/datum/skill/combat/whipsflails, SKILL_LEVEL_EXPERT, TRUE)
			beltr = /obj/item/rogueweapon/flail/sflail
		if("Axe")
			H.adjust_skillrank_up_to(/datum/skill/combat/axes, SKILL_LEVEL_EXPERT, TRUE)
			beltr = /obj/item/rogueweapon/stoneaxe/woodcut/steel
		if("Spear") //VT2 handmaiden ftw
			H.adjust_skillrank_up_to(/datum/skill/combat/polearms, SKILL_LEVEL_EXPERT, TRUE)
			r_hand = /obj/item/rogueweapon/spear
	if (istype (H.patron, /datum/patron/inhumen/zizo))
		if(H.mind)
			H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/minion_order)
			H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/gravemark)
			H.mind.current.faction += "[H.name]_faction"
		ADD_TRAIT(H, TRAIT_GRAVEROBBER, TRAIT_GENERIC)

	neck = /obj/item/clothing/neck/roguetown/gorget
	armor = /obj/item/clothing/suit/roguetown/armor/plate/half
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
	gloves = /obj/item/clothing/gloves/roguetown/chain
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	pants = /obj/item/clothing/under/roguetown/chainlegs
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor
	backl = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/shield/tower/metal
	belt = /obj/item/storage/belt/rogue/leather
	beltl = /obj/item/rogueweapon/huntingknife
	backpack_contents = list(
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/ritechalk = 1,
		/obj/item/flashlight/flare/torch/lantern/prelit = 1,
		/obj/item/rope/chain = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

	var/datum/devotion/C = new /datum/devotion(H, H.patron)
	C.grant_miracles(H, cleric_tier = CLERIC_T1, passive_gain = CLERIC_REGEN_MINOR, devotion_limit = CLERIC_REQ_4)	//Minor regen, can level up to T4.
	wretch_select_bounty(H)

/datum/outfit/job/wretch/heretic/choose_loadout(mob/living/carbon/human/H) // some got +1 to their relevant patron skill
	. = ..()
	switch(H.patron?.type)
		if(/datum/patron/inhumen/zizo)
			H.cmode_music = 'sound/music/combat_heretic.ogg'
			H.equip_to_slot_or_del(new /obj/item/clothing/head/roguetown/helmet/heavy/zizoid, SLOT_HEAD, TRUE)
			H.equip_to_slot_or_del(new /obj/item/clothing/neck/roguetown/zcross/iron, SLOT_RING, TRUE)
			H.equip_to_slot_or_del(new /obj/item/clothing/cloak/cape/crusader, SLOT_CLOAK, TRUE)
			H.equip_to_slot_or_del(new /obj/item/clothing/mask/rogue/facemask/steel, SLOT_WEAR_MASK, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/craft/alchemy, SKILL_LEVEL_APPRENTICE, TRUE) // zizo heretic already gets unique benefits, no reason to double down 
			H.adjust_skillrank_up_to(/datum/skill/misc/reading, SKILL_LEVEL_EXPERT, TRUE)
			ADD_TRAIT(H, TRAIT_NOSTINK, TRAIT_GENERIC)
			ADD_TRAIT(H, TRAIT_SOUL_EXAMINE, TRAIT_GENERIC)
		if(/datum/patron/inhumen/matthios)
			H.cmode_music = 'sound/music/combat_matthios.ogg'
			H.equip_to_slot_or_del(new /obj/item/clothing/head/roguetown/helmet/heavy/matt, SLOT_HEAD, TRUE)
			H.equip_to_slot_or_del(new /obj/item/clothing/neck/roguetown/zcross/matthios, SLOT_RING, TRUE)
			H.equip_to_slot_or_del(new /obj/item/clothing/cloak/cape/crusader, SLOT_CLOAK, TRUE)
			H.equip_to_slot_or_del(new /obj/item/clothing/mask/rogue/facemask/steel, SLOT_WEAR_MASK, TRUE)
			H.grant_language(/datum/language/thievescant)
			H.adjust_skillrank_up_to(/datum/skill/misc/sneaking, SKILL_LEVEL_NOVICE, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/misc/stealing, SKILL_LEVEL_NOVICE, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/misc/lockpicking, SKILL_LEVEL_NOVICE, TRUE) //unlike wanderer, normal heretic can get these bonuses
		if(/datum/patron/inhumen/baotha)
			H.cmode_music = 'sound/music/combat_baotha.ogg'
			H.equip_to_slot_or_del(new /obj/item/clothing/head/roguetown/helmet/bascinet/etruscan, SLOT_HEAD, TRUE)
			H.equip_to_slot_or_del(new /obj/item/clothing/cloak/cape/crusader, SLOT_CLOAK, TRUE)
			H.equip_to_slot_or_del(new /obj/item/clothing/mask/rogue/facemask/steel, SLOT_WEAR_MASK, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/misc/music, SKILL_LEVEL_JOURNEYMAN, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/craft/alchemy, SKILL_LEVEL_JOURNEYMAN, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/craft/cooking, SKILL_LEVEL_JOURNEYMAN, TRUE) // jessie we have to cook
			ADD_TRAIT(H, TRAIT_GOODLOVER, TRAIT_GENERIC)
		if(/datum/patron/inhumen/graggar)
			H.cmode_music = 'sound/music/combat_graggar.ogg'
			H.equip_to_slot_or_del(new /obj/item/clothing/head/roguetown/helmet/heavy/grag, SLOT_HEAD, TRUE)
			H.equip_to_slot_or_del(new /obj/item/clothing/cloak/cape/crusader, SLOT_CLOAK, TRUE)
			H.equip_to_slot_or_del(new /obj/item/clothing/mask/rogue/facemask/steel, SLOT_WEAR_MASK, TRUE)
			ADD_TRAIT(H, TRAIT_STEELHEARTED, TRAIT_GENERIC)
			H.adjust_skillrank_up_to(/datum/skill/misc/athletics, SKILL_LEVEL_MASTER, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/combat/unarmed, SKILL_LEVEL_EXPERT, TRUE) //small benefit here, graggar's already good enough for a heavy armor heretic
			ADD_TRAIT(H, TRAIT_NOSTINK, TRAIT_GENERIC)
//		if(/datum/patron/divine/astrata) // Just fuck off
//			cloak = /obj/item/clothing/cloak/tabard/crusader/astrata
//			id = /obj/item/clothing/neck/roguetown/psicross/astrata
//			head = /obj/item/clothing/head/roguetown/helmet/heavy/bucket/gold
//			H.adjust_skillrank(/datum/skill/magic/holy, 1, TRUE)
		if(/datum/patron/divine/abyssor)
			H.equip_to_slot_or_del(new /obj/item/clothing/neck/roguetown/psicross/abyssor, SLOT_RING, TRUE)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/roguetown/helmet/heavy, SLOT_HEAD, TRUE)
			H.equip_to_slot_or_del(new /obj/item/clothing/cloak/abyssortabard, SLOT_CLOAK, TRUE)
			H.equip_to_slot_or_del(new /obj/item/clothing/mask/rogue/facemask/steel, SLOT_WEAR_MASK, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/labor/fishing, SKILL_LEVEL_APPRENTICE, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/misc/swimming, SKILL_LEVEL_EXPERT, TRUE)
			ADD_TRAIT(H, TRAIT_WATERBREATHING, TRAIT_GENERIC)
		if(/datum/patron/divine/xylix)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/roguetown/helmet/heavy/knight/skettle, SLOT_HEAD, TRUE)
			H.equip_to_slot_or_del(new /obj/item/clothing/neck/roguetown/psicross/xylix, SLOT_RING, TRUE)
			H.equip_to_slot_or_del(new /obj/item/clothing/cloak/templar/xylixian, SLOT_CLOAK, TRUE)
			H.equip_to_slot_or_del(new /obj/item/clothing/mask/rogue/facemask/steel, SLOT_WEAR_MASK, TRUE)
			H.cmode_music = 'sound/music/combat_jester.ogg'
			H.adjust_skillrank_up_to(/datum/skill/misc/climbing, SKILL_LEVEL_EXPERT, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/misc/lockpicking, SKILL_LEVEL_NOVICE, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/misc/music, SKILL_LEVEL_NOVICE, TRUE)
		if(/datum/patron/divine/dendor)
			H.equip_to_slot_or_del(new /obj/item/clothing/neck/roguetown/psicross/dendor, SLOT_RING, TRUE)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/roguetown/helmet/heavy/volfplate, SLOT_HEAD, TRUE)
			H.equip_to_slot_or_del(new /obj/item/clothing/cloak/tabard/crusader/dendor, SLOT_CLOAK, TRUE)
			H.equip_to_slot_or_del(new /obj/item/clothing/mask/rogue/facemask/steel, SLOT_WEAR_MASK, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/labor/farming, SKILL_LEVEL_NOVICE, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/misc/climbing, SKILL_LEVEL_EXPERT, TRUE)
			H.grant_language(/datum/language/beast) //dendor antags can talk to WWs and druids
//		if(/datum/patron/divine/necra) // necrans kinda can be heretical but that'd require a different patron due to how grant_miracles functions
//			cloak = /obj/item/clothing/cloak/templar/necran
//			id = /obj/item/clothing/neck/roguetown/psicross/necra // and a different miracles list cos current ones are all anti-undead
//			head = /obj/item/clothing/head/roguetown/helmet/heavy/guard
//			ADD_TRAIT(H, TRAIT_NOSTINK, TRAIT_GENERIC)
//			ADD_TRAIT(H, TRAIT_SOUL_EXAMINE, TRAIT_GENERIC)
		if(/datum/patron/divine/pestra) // get +1 to med and alch so that they can be dedicated 'surgeons' when they arent fragging
			H.equip_to_slot_or_del(new /obj/item/clothing/neck/roguetown/psicross/pestra, SLOT_RING, TRUE)
			H.equip_to_slot_or_del(new /obj/item/clothing/cloak/templar/pestran, SLOT_CLOAK, TRUE)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/roguetown/helmet/heavy/pestran/heretic, SLOT_HEAD, TRUE)
			ADD_TRAIT(H, TRAIT_NOSTINK, TRAIT_GENERIC)
			H.adjust_skillrank_up_to(/datum/skill/misc/medicine, SKILL_LEVEL_JOURNEYMAN, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/craft/alchemy, SKILL_LEVEL_APPRENTICE, TRUE)
//		if(/datum/patron/divine/eora) // I like Eora but I find it impossible to come up with a reason for an Eoran to be a wretch heretic
//			cloak = /obj/item/clothing/cloak/templar/eoran
//			id = /obj/item/clothing/neck/roguetown/psicross/eora
//			head = /obj/item/clothing/head/roguetown/helmet/bascinet/pigface/hounskull
//			ADD_TRAIT(H, TRAIT_BEAUTIFUL, TRAIT_GENERIC)
//			ADD_TRAIT(H, TRAIT_EMPATH, TRAIT_GENERIC)
		if(/datum/patron/divine/noc)
			H.equip_to_slot_or_del(new /obj/item/clothing/neck/roguetown/psicross/noc, SLOT_RING, TRUE)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/roguetown/helmet/heavy/knight, SLOT_HEAD, TRUE)
			H.equip_to_slot_or_del(new /obj/item/clothing/cloak/tabard/crusader/noc, SLOT_CLOAK, TRUE)
			H.equip_to_slot_or_del(new /obj/item/clothing/mask/rogue/facemask/steel, SLOT_WEAR_MASK, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/misc/reading, SKILL_LEVEL_LEGENDARY, TRUE)// Really good at reading... does this really do anything? No. BUT it's soulful.
			H.adjust_skillrank_up_to(/datum/skill/craft/alchemy, SKILL_LEVEL_APPRENTICE, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/magic/arcane, SKILL_LEVEL_NOVICE, TRUE)
//		if(/datum/patron/divine/ravox) //validhunting god, not even Ares. Whiteknight the god, so no.
//			cloak = /obj/item/clothing/cloak/templar/ravox
//			id = /obj/item/clothing/neck/roguetown/psicross/ravox
//			head = /obj/item/clothing/head/roguetown/helmet/heavy/bucket
//			H.adjust_skillrank(/datum/skill/misc/athletics, 1, TRUE)
		if(/datum/patron/divine/malum) // get +1 to their patron skills compared to the usual, to be the 'smiths' when they are not fragging
			H.equip_to_slot_or_del(new /obj/item/clothing/neck/roguetown/psicross/malum, SLOT_RING, TRUE)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/roguetown/helmet/heavy/sheriff, SLOT_HEAD, TRUE)
			H.equip_to_slot_or_del(new /obj/item/clothing/cloak/templar/malumite, SLOT_CLOAK, TRUE)
			H.equip_to_slot_or_del(new /obj/item/clothing/mask/rogue/facemask/steel, SLOT_WEAR_MASK, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/craft/blacksmithing, SKILL_LEVEL_APPRENTICE, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/craft/armorsmithing, SKILL_LEVEL_APPRENTICE, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/craft/weaponsmithing, SKILL_LEVEL_APPRENTICE, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/craft/smelting, SKILL_LEVEL_APPRENTICE, TRUE)
//		if(/datum/patron/old_god) // Inquisition is psydonian, so no
//			head = /obj/item/clothing/head/roguetown/helmet/heavy/knight/armet
//			id = /obj/item/clothing/neck/roguetown/psicross
//			cloak = /obj/item/clothing/cloak/tabard/crusader/psydon
//			H.change_stat(STATKEY_END, 2) //ENDVRE

/datum/advclass/wretch/heretic/wanderer
	name = "Heretic Wanderer"
	tutorial = "Nimble of dagger and foot both, you are the shadowy herald of the cabal. They will not see you coming."
	outfit = /datum/outfit/job/wretch/heretic_wanderer

	traits_applied = list(TRAIT_RITUALIST, TRAIT_DODGEEXPERT, TRAIT_HERETIC_DEVOUT)
	//Slower than outlaw, but a bit more PER and INT
	subclass_stats = list(
		STATKEY_PER = 2,
		STATKEY_END = 2,
		STATKEY_SPD = 2,
		STATKEY_INT = 1
	)

	subclass_skills = list(
		/datum/skill/magic/holy = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/tracking = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/knives = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/swords = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/swimming = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/wrestling = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/unarmed = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/athletics = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/climbing = SKILL_LEVEL_MASTER,
		/datum/skill/misc/reading = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/sneaking = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/stealing = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/lockpicking = SKILL_LEVEL_EXPERT,
		/datum/skill/craft/traps = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/medicine = SKILL_LEVEL_NOVICE,
	)

/datum/outfit/job/wretch/heretic_wanderer
	has_loadout = TRUE

/datum/outfit/job/wretch/heretic_wanderer/pre_equip(mob/living/carbon/human/H)
	..()
	if ((istype(H.patron, /datum/patron/divine/astrata) || istype(H.patron, /datum/patron/divine/necra) || istype(H.patron, /datum/patron/divine/eora) || istype(H.patron, /datum/patron/divine/ravox) || istype(H.patron, /datum/patron/old_god)))
		to_chat(H, span_warning("My former deity frowned upon my practices. I have since turned to ZIZO..."))
		H.set_patron(/datum/patron/inhumen/zizo)
	to_chat(H, span_warning("Nimble of dagger and foot both, you are the shadowy herald of the cabal. They will not see you coming."))
	H.mind.current.faction += "[H.name]_faction"
	pants = /obj/item/clothing/under/roguetown/heavy_leather_pants
	armor = /obj/item/clothing/suit/roguetown/armor/leather/heavy/coat
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
	backl = /obj/item/storage/backpack/rogue/satchel
	belt = /obj/item/storage/belt/rogue/leather
	gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	neck = /obj/item/clothing/neck/roguetown/gorget
	wrists = /obj/item/clothing/wrists/roguetown/bracers/copper
	backpack_contents = list(
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/lockpickring/mundane = 1,
		/obj/item/flashlight/flare/torch/lantern/prelit = 1,
		/obj/item/rope/chain = 1,
		/obj/item/storage/roguebag = 1,
		/obj/item/ritechalk = 1,
		)
	H.cmode_music = 'sound/music/combat_heretic.ogg'
	var/weapons = list("Rapier","Dagger", "Whip & Hunting Knife", "Bow", "Crossbow")
	var/weapon_choice = input(H, "Choose your weapon.", "TAKE UP ARMS") as anything in weapons
	H.set_blindness(0)
	switch(weapon_choice)
		if("Rapier")
			H.adjust_skillrank_up_to(/datum/skill/combat/swords, SKILL_LEVEL_EXPERT, TRUE)
			beltl = /obj/item/rogueweapon/scabbard/sword
			l_hand = /obj/item/rogueweapon/sword/rapier
		if("Dagger")
			H.adjust_skillrank_up_to(/datum/skill/combat/knives, SKILL_LEVEL_EXPERT, TRUE)
			beltl = /obj/item/rogueweapon/scabbard/sheath
			l_hand = /obj/item/rogueweapon/huntingknife/idagger/steel/special
		if("Whip & Hunting Knife")
			H.adjust_skillrank_up_to(/datum/skill/combat/whipsflails, SKILL_LEVEL_EXPERT, TRUE) // no adjustment for knives skill cos thats how the others are done
			l_hand = /obj/item/rogueweapon/whip
			backpack_contents += /obj/item/rogueweapon/huntingknife
		if("Bow")
			H.adjust_skillrank_up_to(/datum/skill/combat/bows, SKILL_LEVEL_JOURNEYMAN, TRUE)
			beltl = /obj/item/quiver/arrows
			backr = /obj/item/gun/ballistic/revolver/grenadelauncher/bow/recurve
		if("Crossbow")
			H.adjust_skillrank_up_to(/datum/skill/combat/crossbows, SKILL_LEVEL_JOURNEYMAN, TRUE) //have to specifically go into bows/crossbows unlike outlaw
			beltr = /obj/item/quiver/bolts
			backr = /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow

	if (istype (H.patron, /datum/patron/inhumen/zizo))
		if(H.mind)
			H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/minion_order)
			H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/gravemark)
			H.mind.current.faction += "[H.name]_faction"
		ADD_TRAIT(H, TRAIT_GRAVEROBBER, TRAIT_GENERIC)
	var/datum/devotion/C = new /datum/devotion(H, H.patron)
	C.grant_miracles(H, cleric_tier = CLERIC_T1, passive_gain = CLERIC_REGEN_MINOR, devotion_limit = CLERIC_REQ_4)	//Minor regen, can level up to T4.
	wretch_select_bounty(H)

/datum/outfit/job/wretch/heretic_wanderer/choose_loadout(mob/living/carbon/human/H) // some got +1 to their patron skill, same deal as armoured heretics
	. = ..()
	switch(H.patron?.type)
		if(/datum/patron/inhumen/zizo)
			H.equip_to_slot_or_del(new /obj/item/clothing/neck/roguetown/zcross/iron, SLOT_RING, TRUE)
			H.equip_to_slot_or_del(new /obj/item/clothing/mask/rogue/facemask/copper, SLOT_WEAR_MASK, TRUE)
			H.equip_to_slot_or_del(new /obj/item/clothing/cloak/cape/crusader, SLOT_CLOAK, TRUE)
			H.cmode_music = 'sound/music/combat_heretic.ogg'
			H.adjust_skillrank_up_to(/datum/skill/craft/alchemy, SKILL_LEVEL_APPRENTICE, TRUE) // zizo heretic already gets unique benefits, no reason to double down 
			H.adjust_skillrank_up_to(/datum/skill/misc/reading, SKILL_LEVEL_EXPERT, TRUE)
			ADD_TRAIT(H, TRAIT_NOSTINK, TRAIT_GENERIC)
			ADD_TRAIT(H, TRAIT_SOUL_EXAMINE, TRAIT_GENERIC)
		if(/datum/patron/inhumen/matthios)
			H.equip_to_slot_or_del(new /obj/item/clothing/mask/rogue/facemask/copper, SLOT_WEAR_MASK, TRUE)
			H.equip_to_slot_or_del(new /obj/item/clothing/cloak/cape/crusader, SLOT_CLOAK, TRUE)
			H.cmode_music = 'sound/music/combat_matthios.ogg'
			H.grant_language(/datum/language/thievescant) // heretic wanderer is already flavorful enough for Matthios, don't want them to be too cracked and completely invalidate knave and outlaw
		if(/datum/patron/inhumen/baotha)
			H.equip_to_slot_or_del(new /obj/item/clothing/mask/rogue/facemask/copper, SLOT_WEAR_MASK, TRUE)
			H.equip_to_slot_or_del(new /obj/item/clothing/cloak/cape/crusader, SLOT_CLOAK, TRUE)
			H.cmode_music = 'sound/music/combat_baotha.ogg'
			H.adjust_skillrank_up_to(/datum/skill/misc/music, SKILL_LEVEL_JOURNEYMAN, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/craft/alchemy, SKILL_LEVEL_JOURNEYMAN, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/craft/cooking, SKILL_LEVEL_JOURNEYMAN, TRUE) // Jessie we have to cook
			ADD_TRAIT(H, TRAIT_GOODLOVER, TRAIT_GENERIC)
		if(/datum/patron/inhumen/graggar)
			H.equip_to_slot_or_del(new /obj/item/clothing/mask/rogue/facemask/copper, SLOT_WEAR_MASK, TRUE)
			H.equip_to_slot_or_del(new /obj/item/clothing/cloak/cape/crusader, SLOT_CLOAK, TRUE)
			H.cmode_music = 'sound/music/combat_graggar.ogg'
			ADD_TRAIT(H, TRAIT_STEELHEARTED, TRAIT_GENERIC)
			H.adjust_skillrank_up_to(/datum/skill/misc/athletics, SKILL_LEVEL_MASTER, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/combat/unarmed, SKILL_LEVEL_EXPERT, TRUE) // heretics get improved versions, don't want to go too overboard though
			ADD_TRAIT(H, TRAIT_NOSTINK, TRAIT_GENERIC)
//		if(/datum/patron/divine/astrata)
//			id = /obj/item/clothing/neck/roguetown/psicross/astrata
//			H.adjust_skillrank(/datum/skill/magic/holy, 1, TRUE)
		if(/datum/patron/divine/abyssor)
			H.equip_to_slot_or_del(new /obj/item/clothing/mask/rogue/facemask/copper, SLOT_WEAR_MASK, TRUE)
			H.equip_to_slot_or_del(new /obj/item/clothing/neck/roguetown/psicross/abyssor, SLOT_RING, TRUE)
			H.equip_to_slot_or_del(new /obj/item/clothing/cloak/abyssortabard, SLOT_CLOAK, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/labor/fishing, SKILL_LEVEL_APPRENTICE, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/misc/swimming, SKILL_LEVEL_MASTER, TRUE)
			ADD_TRAIT(H, TRAIT_WATERBREATHING, TRAIT_GENERIC)
		if(/datum/patron/divine/xylix)
			H.equip_to_slot_or_del(new /obj/item/clothing/mask/rogue/facemask/copper, SLOT_WEAR_MASK, TRUE)
			H.equip_to_slot_or_del(new /obj/item/clothing/neck/roguetown/psicross/xylix, SLOT_RING, TRUE)
			H.equip_to_slot_or_del(new /obj/item/clothing/cloak/templar/xylixian, SLOT_CLOAK, TRUE)
			H.cmode_music = 'sound/music/combat_jester.ogg'
			H.adjust_skillrank_up_to(/datum/skill/misc/climbing, SKILL_LEVEL_LEGENDARY, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/misc/lockpicking, SKILL_LEVEL_MASTER, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/misc/music, SKILL_LEVEL_NOVICE, TRUE)
		if(/datum/patron/divine/dendor)
			H.equip_to_slot_or_del(new /obj/item/clothing/mask/rogue/facemask/copper, SLOT_WEAR_MASK, TRUE)
			H.equip_to_slot_or_del(new /obj/item/clothing/neck/roguetown/psicross/dendor, SLOT_RING, TRUE)
			H.equip_to_slot_or_del(new /obj/item/clothing/cloak/tabard/crusader/dendor, SLOT_CLOAK, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/labor/farming, SKILL_LEVEL_NOVICE, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/misc/climbing, SKILL_LEVEL_LEGENDARY, TRUE)
			H.grant_language(/datum/language/beast) //dendor antags can talk to WWs and druids
//		if(/datum/patron/divine/necra) // necrans kinda can be heretical but that'd require a different patron due to how grant_miracles functions
//			id = /obj/item/clothing/neck/roguetown/psicross/necra // and a different miracles list cos current ones are all anti-undead
//			ADD_TRAIT(H, TRAIT_NOSTINK, TRAIT_GENERIC)
//			ADD_TRAIT(H, TRAIT_SOUL_EXAMINE, TRAIT_GENERIC)
		if(/datum/patron/divine/pestra)
			H.equip_to_slot_or_del(new /obj/item/clothing/mask/rogue/facemask/steel/pestra_beakmask, SLOT_WEAR_MASK, TRUE)
			H.equip_to_slot_or_del(new /obj/item/clothing/neck/roguetown/psicross/pestra, SLOT_RING, TRUE)
			H.equip_to_slot_or_del(new /obj/item/clothing/cloak/templar/pestran, SLOT_CLOAK, TRUE)
			ADD_TRAIT(H, TRAIT_NOSTINK, TRAIT_GENERIC)
			H.adjust_skillrank_up_to(/datum/skill/misc/medicine, SKILL_LEVEL_JOURNEYMAN, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/craft/alchemy, SKILL_LEVEL_APPRENTICE, TRUE)
//		if(/datum/patron/divine/eora)
//			id = /obj/item/clothing/neck/roguetown/psicross/eora
//			ADD_TRAIT(H, TRAIT_BEAUTIFUL, TRAIT_GENERIC)
//			ADD_TRAIT(H, TRAIT_EMPATH, TRAIT_GENERIC)
		if(/datum/patron/divine/noc)
			H.equip_to_slot_or_del(new /obj/item/clothing/mask/rogue/facemask/copper, SLOT_WEAR_MASK, TRUE)
			H.equip_to_slot_or_del(new /obj/item/clothing/neck/roguetown/psicross/noc, SLOT_RING, TRUE)
			H.equip_to_slot_or_del(new /obj/item/clothing/cloak/tabard/crusader/noc, SLOT_CLOAK, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/misc/reading, SKILL_LEVEL_LEGENDARY, TRUE)// Really good at reading... does this really do anything? No. BUT it's soulful.
			H.adjust_skillrank_up_to(/datum/skill/craft/alchemy, SKILL_LEVEL_APPRENTICE, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/magic/arcane, SKILL_LEVEL_NOVICE, TRUE)
//		if(/datum/patron/divine/ravox)
//			id = /obj/item/clothing/neck/roguetown/psicross/ravox
//			H.adjust_skillrank(/datum/skill/misc/athletics, 1, TRUE)
		if(/datum/patron/divine/malum)
			H.equip_to_slot_or_del(new /obj/item/clothing/mask/rogue/facemask/copper, SLOT_WEAR_MASK, TRUE)
			H.equip_to_slot_or_del(new /obj/item/clothing/neck/roguetown/psicross/malum, SLOT_RING, TRUE)
			H.equip_to_slot_or_del(new /obj/item/clothing/cloak/templar/malumite, SLOT_CLOAK, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/craft/blacksmithing, SKILL_LEVEL_APPRENTICE, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/craft/armorsmithing, SKILL_LEVEL_APPRENTICE, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/craft/weaponsmithing, SKILL_LEVEL_APPRENTICE, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/craft/smelting, SKILL_LEVEL_APPRENTICE, TRUE)
//		if(/datum/patron/old_god)
//			id = /obj/item/clothing/neck/roguetown/psicross
//			cloak = /obj/item/clothing/cloak/tabard/crusader/psydon
//			H.change_stat(STATKEY_END, 2) //ENDVRE
