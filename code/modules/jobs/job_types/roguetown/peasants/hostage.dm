/datum/job/roguetown/hostage
	title = "Hostage (Bandit)"
	flag = HOSTAGE
	department_flag = PEASANTS
	faction = "Station"
	total_positions = 2
	spawn_positions = 2

	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	tutorial = "You're too valuable to outright kill yet not a free person. You either messed up really bad or got very unlucky. Either way, the bandits have held you hostage until your ransom is paid, as if that would ever happen. Might as well start praying to whatever god you find solace in."

	outfit = /datum/outfit/job/roguetown/hostage
	bypass_jobban = TRUE
	display_order = JDO_HOSTAGE
	give_bank_account = 10
	min_pq = -14
	max_pq = null
	can_random = FALSE

	cmode_music = 'sound/music/combat_bum.ogg'

	advclass_cat_rolls = list(CTAG_HOSTAGE = 20)

/datum/outfit/job/roguetown/hostage/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H) return
	neck = /obj/item/clothing/neck/roguetown/gorget/cursed_collar
	pants = /obj/item/clothing/under/roguetown/tights/black
	shirt = /obj/item/clothing/suit/roguetown/shirt/tunic/white

/datum/job/roguetown/hostage/after_spawn(mob/living/L, mob/M, latejoin = TRUE)
	. = ..()
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		H.advsetup = 1
		H.invisibility = INVISIBILITY_MAXIMUM
		H.become_blind("advsetup")

/datum/job/roguetown/hostage/special_check_latejoin(client/C)
	return FALSE

//noble
/datum/outfit/job/roguetown/hostage_noble
	name = "Hostage Noble"

/datum/outfit/job/roguetown/hostage_noble/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H) return
	..() // Call base hostage outfit
	if(H.mind)
		H.adjust_skillrank(/datum/skill/combat/unarmed, 1, TRUE)
		H.adjust_skillrank(/datum/skill/combat/knives, 2, TRUE)
		H.adjust_skillrank(/datum/skill/misc/sewing, 1, TRUE)
		H.adjust_skillrank(/datum/skill/craft/cooking, 1, TRUE)
		H.adjust_skillrank(/datum/skill/misc/riding, 2, TRUE)
		H.adjust_skillrank(/datum/skill/misc/reading, 3, TRUE)
		H.adjust_skillrank(/datum/skill/labor/farming, 1, TRUE)
		if(H.age == AGE_OLD)
			H.adjust_skillrank(/datum/skill/labor/farming, 1, TRUE)
			H.adjust_skillrank(/datum/skill/misc/reading, 1, TRUE)
		H.change_stat("intelligence", 1)
		H.change_stat("endurance", 1)
		H.change_stat("perception", 2)
		H.change_stat("speed", 1)
		ADD_TRAIT(H, TRAIT_NOBLE, TRAIT_GENERIC)
		ADD_TRAIT(H, TRAIT_CICERONE, TRAIT_GENERIC)

/datum/advclass/hostage_noble
	parent_type = /datum/advclass
	outfit = /datum/outfit/job/roguetown/hostage_noble
	name = "Hostage Noble"
	category_tags = list(CTAG_HOSTAGE)

//farmer
/datum/outfit/job/hostage_farmer
	name = "Hostage Farmer"

/datum/outfit/job/hostage_farmer/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H) return
	..() // Call base hostage outfit for collar/loincloth
	if(H.mind)
		H.adjust_skillrank(/datum/skill/combat/unarmed, 2, TRUE)
		H.adjust_skillrank(/datum/skill/combat/knives, 1, TRUE)
		H.adjust_skillrank(/datum/skill/craft/crafting, 2, TRUE)
		H.adjust_skillrank(/datum/skill/labor/farming, 5, TRUE)
		H.adjust_skillrank(/datum/skill/misc/medicine, 1, TRUE)
		H.adjust_skillrank(/datum/skill/misc/sewing, 1, TRUE)
		H.adjust_skillrank(/datum/skill/craft/cooking, 1, TRUE)
		H.adjust_skillrank(/datum/skill/craft/carpentry, 2, TRUE)
		H.adjust_skillrank(/datum/skill/craft/masonry, 1, TRUE)
		H.adjust_skillrank(/datum/skill/craft/tanning, 3, TRUE)
		H.adjust_skillrank(/datum/skill/misc/riding, 3, TRUE)
		H.adjust_skillrank(/datum/skill/labor/butchering, 5, TRUE)
		H.adjust_skillrank(/datum/skill/misc/reading, 1, TRUE)
		H.adjust_skillrank(/datum/skill/misc/athletics, 4, TRUE)
		if(H.age == AGE_OLD)
			H.adjust_skillrank(/datum/skill/labor/farming, 1, TRUE)
			H.adjust_skillrank(/datum/skill/labor/butchering, 1, TRUE)
		H.change_stat("strength", 1)
		H.change_stat("constitution", 1)
		H.change_stat("endurance", 2)
		H.change_stat("speed", 1)
		ADD_TRAIT(H, TRAIT_SEEDKNOW, TRAIT_GENERIC)
		ADD_TRAIT(H, TRAIT_NOSTINK, TRAIT_GENERIC)
		ADD_TRAIT(H, TRAIT_LONGSTRIDER, TRAIT_GENERIC)

/datum/advclass/hostage_farmer
	parent_type = /datum/advclass
	outfit = /datum/outfit/job/hostage_farmer
	name = "Hostage Farmer"
	category_tags = list(CTAG_HOSTAGE)

//blacksmith
/datum/outfit/job/hostage_blacksmith
	name = "Hostage Blacksmith"

/datum/outfit/job/hostage_blacksmith/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H) return
	H.adjust_skillrank(/datum/skill/misc/athletics, 2, TRUE)
	H.adjust_skillrank(/datum/skill/combat/axes, 2, TRUE)
	H.adjust_skillrank(/datum/skill/combat/maces, 2, TRUE)
	H.adjust_skillrank(/datum/skill/combat/unarmed, 2, TRUE)
	H.adjust_skillrank(/datum/skill/craft/crafting, 3, TRUE)
	H.adjust_skillrank(/datum/skill/craft/blacksmithing, 5, TRUE)
	H.adjust_skillrank(/datum/skill/craft/armorsmithing, 5, TRUE)
	H.adjust_skillrank(/datum/skill/craft/weaponsmithing, 5, TRUE)
	H.adjust_skillrank(/datum/skill/craft/smelting, 4, TRUE)
	H.adjust_skillrank(/datum/skill/misc/reading, 2, TRUE)
	H.change_stat("strength", 2)
	H.change_stat("intelligence", 1)
	H.change_stat("endurance", 2)
	H.change_stat("constitution", 2)
	ADD_TRAIT(H, TRAIT_TRAINED_SMITH, TRAIT_GENERIC)

/datum/advclass/hostage_blacksmith
	parent_type = /datum/advclass
	outfit = /datum/outfit/job/hostage_blacksmith
	name = "Hostage Blacksmith"
	category_tags = list(CTAG_HOSTAGE)

//minstrel
/datum/outfit/job/hostage_minstrel
	name = "Hostage Minstrel"

/datum/outfit/job/hostage_minstrel/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H) return
	if(H) to_chat(H, "DEBUG: hostage_minstrel pre_equip called")
	..() // Call base hostage outfit for collar/loincloth
	H.adjust_skillrank(/datum/skill/combat/knives, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/sneaking, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/lockpicking, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/swimming, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/athletics, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/music, 4, TRUE)
	H.adjust_skillrank(/datum/skill/misc/reading, 4, TRUE)
	H.adjust_skillrank(/datum/skill/misc/sewing, 2, TRUE)
	H.adjust_skillrank(/datum/skill/craft/crafting, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/riding, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/medicine, 1, TRUE)
	H.adjust_skillrank(/datum/skill/craft/cooking, 1, TRUE)
	H.change_stat("speed", 3)
	H.change_stat("endurance", 2)
	H.change_stat("perception", 1)
	ADD_TRAIT(H, TRAIT_KEENEARS, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_GOODLOVER, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_EMPATH, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_BEAUTIFUL, TRAIT_GENERIC)

/datum/advclass/hostage_minstrel
	parent_type = /datum/advclass
	outfit = /datum/outfit/job/hostage_minstrel
	name = "Hostage Minstrel"
	category_tags = list(CTAG_HOSTAGE)

//doctor
/datum/advclass/hostage_towndoctor
	parent_type = /datum/advclass
	outfit = /datum/outfit/job/hostage_towndoctor
	name = "Hostage Barber Surgeon"
	category_tags = list(CTAG_HOSTAGE)

/datum/outfit/job/hostage_towndoctor/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H) return
	H.adjust_skillrank(/datum/skill/combat/knives, 2, TRUE)
	H.adjust_skillrank(/datum/skill/craft/crafting, 2, TRUE)
	H.adjust_skillrank(/datum/skill/craft/carpentry, 2, TRUE)
	H.adjust_skillrank(/datum/skill/labor/lumberjacking, 1, TRUE)
	H.adjust_skillrank(/datum/skill/misc/athletics, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/reading, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/climbing, 1, TRUE)
	H.adjust_skillrank(/datum/skill/misc/sneaking, 1, TRUE)
	H.adjust_skillrank(/datum/skill/misc/medicine, 5, TRUE)
	H.adjust_skillrank(/datum/skill/misc/sewing, 3, TRUE)
	H.adjust_skillrank(/datum/skill/craft/alchemy, 2, TRUE)
	H.change_stat("intelligence", 3)
	H.change_stat("fortune", 1)
	ADD_TRAIT(H, TRAIT_EMPATH, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_NOSTINK, TRAIT_GENERIC)

//miner
/datum/advclass/hostage_miner
	parent_type = /datum/advclass
	outfit = /datum/outfit/job/hostage_miner
	name = "Hostage Miner"
	category_tags = list(CTAG_HOSTAGE)

/datum/outfit/job/hostage_miner/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H) return
	H.adjust_skillrank(/datum/skill/combat/axes, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/athletics, 2, TRUE)
	H.adjust_skillrank(/datum/skill/combat/unarmed, 1, TRUE)
	H.adjust_skillrank(/datum/skill/combat/knives, 1, TRUE)
	H.adjust_skillrank(/datum/skill/combat/polearms, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/swimming, 1, TRUE)
	H.adjust_skillrank(/datum/skill/misc/climbing, 2, TRUE)
	H.adjust_skillrank(/datum/skill/craft/crafting, 2, TRUE)
	H.adjust_skillrank(/datum/skill/craft/traps, 2, TRUE)
	H.adjust_skillrank(/datum/skill/craft/engineering, 1, TRUE)
	H.adjust_skillrank(/datum/skill/craft/carpentry, 1, TRUE)
	H.adjust_skillrank(/datum/skill/craft/masonry, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/medicine, 1, TRUE)
	H.adjust_skillrank(/datum/skill/labor/mining, 4, TRUE)
	H.adjust_skillrank(/datum/skill/craft/smelting, 4, TRUE)
	H.adjust_skillrank(/datum/skill/misc/reading, 1, TRUE)
	H.change_stat("strength", 2)
	H.change_stat("endurance", 1)
	H.change_stat("constitution", 2)
	H.change_stat("fortune", 2)
	ADD_TRAIT(H, TRAIT_DARKVISION, TRAIT_GENERIC)

//cleric
/datum/advclass/hostage_cleric
	name = "Hostage Cleric"
	tutorial = "You cling to your religious symbols for comfort."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	outfit = /datum/outfit/job/hostage/cleric
	category_tags = list(CTAG_HOSTAGE)

/datum/outfit/job/hostage/cleric/pre_equip(mob/living/carbon/human/H)
	..()
	// Add druidic skill for Dendor followers
	if(H.patron?.type == /datum/patron/inhumen/graggar)
		ADD_TRAIT(H, TRAIT_STEELHEARTED, TRAIT_GENERIC)
		H.adjust_skillrank(/datum/skill/misc/athletics, 1, TRUE)
		ADD_TRAIT(H, TRAIT_NOSTINK, TRAIT_GENERIC)
	if(H.patron?.type == /datum/patron/inhumen/matthios)
		H.grant_language(/datum/language/thievescant)
		H.adjust_skillrank(/datum/skill/misc/sneaking, 1, TRUE)
		H.adjust_skillrank(/datum/skill/misc/stealing, 1, TRUE)
		H.adjust_skillrank(/datum/skill/misc/lockpicking, 1, TRUE)
	if(H.patron?.type == /datum/patron/inhumen/zizo)
		H.adjust_skillrank(/datum/skill/craft/alchemy, 1, TRUE)
		H.adjust_skillrank(/datum/skill/misc/reading, 1, TRUE)
		ADD_TRAIT(H, TRAIT_NOSTINK, TRAIT_GENERIC)
		ADD_TRAIT(H, TRAIT_SOUL_EXAMINE, TRAIT_GENERIC)
		ADD_TRAIT(H, TRAIT_GRAVEROBBER, TRAIT_GENERIC)
	if(H.patron?.type == /datum/patron/inhumen/baotha)
		H.adjust_skillrank(/datum/skill/misc/music, 2, TRUE)
		H.adjust_skillrank(/datum/skill/craft/alchemy, 2, TRUE)
		H.adjust_skillrank(/datum/skill/craft/cooking, 2, TRUE)
		ADD_TRAIT(H, TRAIT_GOODLOVER, TRAIT_GENERIC)
	if(istype(H.patron, /datum/patron/divine/dendor))
		H.adjust_skillrank(/datum/skill/magic/druidic, 3, TRUE)
		to_chat(H, span_notice("As a follower of Dendor, you have innate knowledge of druidic magic."))
		ADD_TRAIT(H, TRAIT_SEEDKNOW, TRAIT_GENERIC)
		H.adjust_skillrank(/datum/skill/labor/farming, 1, TRUE)
		H.adjust_skillrank(/datum/skill/misc/climbing, 1, TRUE)
		H.adjust_skillrank(/datum/skill/craft/crafting, 1, TRUE) // we are a literal forest dweller, we should atleast not be cluless about such things, even abyssorites get badass combat stuff
		H.adjust_skillrank(/datum/skill/craft/cooking, 1, TRUE)
		H.adjust_skillrank(/datum/skill/labor/fishing, 1, TRUE)
	if(H.patron?.type == /datum/patron/divine/astrata)
		H.adjust_skillrank(/datum/skill/magic/holy, 1, TRUE)
	if(H.patron?.type == /datum/patron/divine/noc)
		H.adjust_skillrank(/datum/skill/misc/reading, 3, TRUE) // Really good at reading... does this really do anything? No. BUT it's soulful.
		H.adjust_skillrank(/datum/skill/craft/alchemy, 1, TRUE)
		H.adjust_skillrank(/datum/skill/magic/arcane, 1, TRUE)
	if(H.patron?.type == /datum/patron/divine/abyssor)
		H.adjust_skillrank(/datum/skill/labor/fishing, 2, TRUE)
		H.adjust_skillrank(/datum/skill/misc/swimming, 2, TRUE)
		ADD_TRAIT(H, TRAIT_WATERBREATHING, TRAIT_GENERIC)
	if(H.patron?.type == /datum/patron/divine/necra)
		ADD_TRAIT(H, TRAIT_NOSTINK, TRAIT_GENERIC)
		ADD_TRAIT(H, TRAIT_SOUL_EXAMINE, TRAIT_GENERIC)
	if(H.patron?.type == /datum/patron/divine/pestra)
		H.adjust_skillrank(/datum/skill/misc/medicine, 1, TRUE)
		H.adjust_skillrank(/datum/skill/craft/alchemy, 1, TRUE)
		ADD_TRAIT(H, TRAIT_NOSTINK, TRAIT_GENERIC)
	if(H.patron?.type == /datum/patron/divine/eora)
		ADD_TRAIT(H, TRAIT_BEAUTIFUL, TRAIT_GENERIC)
		ADD_TRAIT(H, TRAIT_EMPATH, TRAIT_GENERIC)
	if(H.patron?.type == /datum/patron/divine/malum)
		H.adjust_skillrank(/datum/skill/craft/blacksmithing, 1, TRUE)
		H.adjust_skillrank(/datum/skill/craft/armorsmithing, 1, TRUE)
		H.adjust_skillrank(/datum/skill/craft/weaponsmithing, 1, TRUE)
		H.adjust_skillrank(/datum/skill/craft/smelting, 1, TRUE)
	if(H.patron?.type == /datum/patron/divine/ravox)
		H.adjust_skillrank(/datum/skill/misc/athletics, 1, TRUE)
	if(H.patron?.type == /datum/patron/divine/xylix)
		H.adjust_skillrank(/datum/skill/misc/climbing, 1, TRUE)
		H.adjust_skillrank(/datum/skill/misc/lockpicking, 1, TRUE)
		H.adjust_skillrank(/datum/skill/misc/music, 1, TRUE)
	// -- End of section for god specific bonuses --
	// Missionary skills without equipment
	H.adjust_skillrank(/datum/skill/combat/polearms, 2, TRUE)
	H.adjust_skillrank(/datum/skill/magic/holy, 4, TRUE)
	H.adjust_skillrank(/datum/skill/combat/unarmed, 1, TRUE)
	H.adjust_skillrank(/datum/skill/misc/swimming, 1, TRUE)
	H.adjust_skillrank(/datum/skill/misc/climbing, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/athletics, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/reading, 4, TRUE)
	H.adjust_skillrank(/datum/skill/misc/medicine, 2, TRUE)
	H.cmode_music = 'sound/music/combat_holy.ogg'
	H.change_stat("intelligence", 2)
	H.change_stat("endurance", 1)
	H.change_stat("perception", 2)
	H.change_stat("speed", 1)

	// Faith-specific cross on wrist instead of neck
	switch(H.patron?.type)
		if(/datum/patron/old_god)
			wrists = /obj/item/clothing/neck/roguetown/psicross
		if(/datum/patron/divine/astrata)
			wrists = /obj/item/clothing/neck/roguetown/psicross/astrata
		if(/datum/patron/divine/noc)
			wrists = /obj/item/clothing/neck/roguetown/psicross/noc
		if(/datum/patron/divine/abyssor)
			wrists = /obj/item/clothing/neck/roguetown/psicross/abyssor
		if(/datum/patron/divine/dendor)
			wrists = /obj/item/clothing/neck/roguetown/psicross/dendor
			H.cmode_music = 'sound/music/combat_druid.ogg'
		if(/datum/patron/divine/necra)
			wrists = /obj/item/clothing/neck/roguetown/psicross/necra
		if(/datum/patron/divine/pestra)
			wrists = /obj/item/clothing/neck/roguetown/psicross/pestra
		if(/datum/patron/divine/ravox)
			wrists = /obj/item/clothing/neck/roguetown/psicross/ravox
		if(/datum/patron/divine/malum)
			wrists = /obj/item/clothing/neck/roguetown/psicross/malum
		if(/datum/patron/divine/eora)
			wrists = /obj/item/clothing/neck/roguetown/psicross/eora
		if(/datum/patron/inhumen/zizo)
			H.cmode_music = 'sound/music/combat_cult.ogg'
			wrists = /obj/item/roguekey/inhumen
		if (/datum/patron/inhumen/matthios)
			H.cmode_music = 'sound/music/combat_cult.ogg'
		if(/datum/patron/divine/xylix) // no longer random, rejoice my fellow xylixians!
			wrists = /obj/item/clothing/neck/roguetown/psicross/xylix
	// Grant miracles like missionary
	var/datum/devotion/C = new /datum/devotion(H, H.patron)
	C.grant_miracles(H, cleric_tier = CLERIC_T1, passive_gain = CLERIC_REGEN_MINOR)	//Minor regen, can level up to T4.
	if(istype(H.patron, /datum/patron/divine))
		// For now, only Tennites get this. Heretics can have a special treat later
		H.mind?.AddSpell(new /obj/effect/proc_holder/spell/invoked/projectile/divineblast)
	if(istype(H.patron, /datum/patron/inhumen))
		H.mind?.AddSpell(new /obj/effect/proc_holder/spell/invoked/projectile/unholyblast)
