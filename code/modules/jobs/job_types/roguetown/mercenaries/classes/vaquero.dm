/datum/advclass/mercenary/vaquero
	name = "Vaquero"
	tutorial = "Originating in the vibrant Kingdom of Etrusca, a 'vaquero' had originally been a mere cattle-driver... Now, though, it has become a title for roaming swashbucklers. Whether they set out as a defender of the commonfolk or a pilferer of purses, the Vaquero is defined by the tale they carve across continents - and more frequently - by their story's violent end."
	outfit = /datum/outfit/job/mercenary/vaquero
	cmode_music = 'sound/music/combat_vaquero.ogg'
	category_tags = list(CTAG_MERCENARY)
	class_select_category = CLASS_CAT_ETRUSCA
	origin_override_type = /datum/virtue/origin/etrusca

	subclass_languages = list(
		/datum/language/etruscan,
	)

	traits_applied = list(TRAIT_DODGEEXPERT, TRAIT_DECEIVING_MEEKNESS, TRAIT_MEDIUMARMOR)
	subclass_stats = list(
		STATKEY_SPD = 2,
		STATKEY_INT = 2,
		STATKEY_END = 1
	)
	hiredbuff = /datum/status_effect/buff/merchired/vaquero

	subclass_skills = list(
		/datum/skill/combat/swords = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/crossbows = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/bows = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/athletics = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/wrestling = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/unarmed = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/knives = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/swimming = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/reading = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/sneaking = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/stealing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/riding = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/lockpicking = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/music = SKILL_LEVEL_EXPERT,
	)

/datum/status_effect/buff/merchired/vaquero
	effectedstats = list(STATKEY_SPD = 1, STATKEY_END = 1)

/datum/outfit/job/mercenary/vaquero/pre_equip(mob/living/carbon/human/H)
	..()
	head = /obj/item/clothing/head/roguetown/bardhat
	mouth = /obj/item/alch/rosa
	shoes = /obj/item/clothing/shoes/roguetown/boots
	neck = /obj/item/clothing/neck/roguetown/gorget
	pants = /obj/item/clothing/under/roguetown/heavy_leather_pants
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt
	belt = /obj/item/storage/belt/rogue/leather
	gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	armor = /obj/item/clothing/suit/roguetown/armor/leather/heavy/coat
	cloak = /obj/item/clothing/cloak/half/rider/red
	backl = /obj/item/storage/backpack/rogue/satchel
	beltl = /obj/item/rogueweapon/scabbard/sword
	l_hand = /obj/item/rogueweapon/sword/rapier/vaquero
	beltr = /obj/item/rogueweapon/scabbard/sheath
	r_hand = /obj/item/rogueweapon/huntingknife/idagger/steel/parrying/vaquero
	backpack_contents = list(
					/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
					/obj/item/rogueweapon/huntingknife/idagger/navaja = 1,
					/obj/item/lockpick = 1,
					/obj/item/flashlight/flare/torch = 1,
					/obj/item/roguekey/mercenary = 1
					)
	var/weapons = list("Accordion","Bagpipe","Drum","Guitar","Harp","Hurdy-Gurdy","Jaw Harp","Lute","Trumpet","Viola","Vocal Talisman")
	var/weapon_choice = input(H, "Choose your instrument.", "TAKE UP ARMS") as anything in weapons
	H.set_blindness(0)
	if (H.mind)
		H.AddSpell(new /obj/effect/proc_holder/spell/self/choose_riding_virtue_mount)
	switch(weapon_choice)
		if("Harp")
			H.put_in_hands(new /obj/item/rogue/instrument/harp(H), TRUE)
		if("Lute")
			H.put_in_hands(new /obj/item/rogue/instrument/lute(H), TRUE)
		if("Accordion")
			H.put_in_hands(new /obj/item/rogue/instrument/accord(H), TRUE)
		if("Guitar")
			H.put_in_hands(new /obj/item/rogue/instrument/guitar(H), TRUE)
		if("Hurdy-Gurdy")
			H.put_in_hands(new /obj/item/rogue/instrument/hurdygurdy(H), TRUE)
		if("Viola")
			H.put_in_hands(new /obj/item/rogue/instrument/viola(H), TRUE)
		if("Vocal Talisman")
			H.put_in_hands(new /obj/item/rogue/instrument/vocals(H), TRUE)
		if("Trumpet")
			H.put_in_hands(new /obj/item/rogue/instrument/trumpet(H), TRUE)
		if("Bagpipe")
			H.put_in_hands(new /obj/item/rogue/instrument/bagpipe(H), TRUE)
		if("Jaw Harp")
			H.put_in_hands(new /obj/item/rogue/instrument/jawharp(H), TRUE)
		if("Drum")
			H.put_in_hands(new /obj/item/rogue/instrument/drum(H), TRUE)
