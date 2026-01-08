/datum/advclass/mercenary/freelancer
	name = "Vuorisvärda"
	tutorial = "You have learned the ways of the Av Aves - schools of combat trained in the lessons of the Avian cultures of Avar’s highest mountaintops. While your terrestrial origin restricts you from the same aerial dance of the Falc’s blademaster warbirds, you have trained yourself extensively in adapting their lightness, swiftness, and terrible lethality. Armor is unnecessary; a burden, and nothing more. You have swung one weapon ten thousand times; and swing yourself with the same grace as blade and bird alike. Fall from the peak, cut through the sky - and cleave the earth in twain."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	outfit = /datum/outfit/job/mercenary/freelancer
	category_tags = list(CTAG_MERCENARY)
	class_select_category = CLASS_CAT_AAVNR
	cmode_music = 'sound/music/combat_noble.ogg'
	origin_override_type = /datum/virtue/origin/avar

	subclass_languages = list(
		/datum/language/aavnic,	//Your character could not have possibly "graduated" without atleast some basic knowledge of Aavnic.
	)

	traits_applied = list(TRAIT_BADTRAINER)
	subclass_stats = list(
		STATKEY_INT = 3, // 4 when hired
		STATKEY_PER = 2, // 3 when hired
		STATKEY_CON = 2
	)

	hiredbuff = /datum/status_effect/buff/merchired/freifechter

	subclass_skills = list(
		/datum/skill/combat/swords = SKILL_LEVEL_MASTER,
		/datum/skill/misc/athletics = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/knives = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/wrestling = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/reading = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/climbing = SKILL_LEVEL_APPRENTICE,	//I got told that having zero climbing is a PITA. Bare minimum for a combat class.
	)

/datum/status_effect/buff/merchired/freifechter
	effectedstats = list(STATKEY_INT = 1, STATKEY_PER = 1)

/datum/outfit/job/mercenary/freelancer/pre_equip(mob/living/carbon/human/H)
	..()
	to_chat(H, span_warning("You are a master in the arts of the longsword. Wielder of the world's most versatile and noble weapon, you needn't anything else. You can choose a regional longsword."))

	l_hand = /obj/item/rogueweapon/scabbard/sword
	armor = /obj/item/clothing/suit/roguetown/armor/plate/half/fencer	//Experimental.
	var/weapons = list("Modified Training Sword !!!CHALLENGE!!!", "Etruscan Longsword", "Kriegsmesser", "Field Longsword")
	var/weapon_choice = input(H, "Choose your weapon.", "TAKE UP ARMS") as anything in weapons
	switch(weapon_choice)
		if("Modified Training Sword !!!CHALLENGE!!!")		//A sharp feder. Less damage, better defense. Definitely not a good choice.
			r_hand = /obj/item/rogueweapon/sword/long/frei
			beltr = /obj/item/rogueweapon/huntingknife/idagger
		if("Etruscan Longsword")		//A longsword with a compound ricasso. Accompanied by a traditional flip knife.
			r_hand = /obj/item/rogueweapon/sword/long/etruscan
			beltr = /obj/item/rogueweapon/huntingknife/idagger/navaja
		if("Kriegsmesser")		//Och- eugh- German!
			r_hand = /obj/item/rogueweapon/sword/long/kriegmesser
			beltr = /obj/item/rogueweapon/huntingknife/idagger
		if("Field Longsword")		//A common longsword.
			r_hand = /obj/item/rogueweapon/sword/long
			beltr = /obj/item/rogueweapon/huntingknife/idagger
	belt = /obj/item/storage/belt/rogue/leather/sash
	beltl = /obj/item/flashlight/flare/torch/lantern
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/freifechter
	pants = /obj/item/clothing/under/roguetown/heavy_leather_pants/otavan/generic
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced/short
	gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
	backr = /obj/item/storage/backpack/rogue/satchel/short

	backpack_contents = list(/obj/item/roguekey/mercenary)

/datum/advclass/mercenary/freelancer/lancer
	name = "Lancetanssija"
	tutorial = "Polearms are the weapon of choice for the common land-dweller of Avar; equally effective against seaborne or sky-faring foes - a harpoon, a lance, the tool of every Fjällshem on the foggy highlands. You have learned from the best; earning your title as Lancetanssija - or ‘lance dancer.’ Naturally, you put complete trust in your polearm, the most effective weapon within the Known World - and have mastered its uses for status, protection, or visceral application. Puncture the sky, and pierce the heavens."
	outfit = /datum/outfit/job/mercenary/freelancer_lancer
	origin_override_type = /datum/virtue/origin/avar

	subclass_languages = list(
		/datum/language/aavnic,	//Your character could not have possibly "graduated" without atleast some basic knowledge of Aavnic.
	)

	traits_applied = list(TRAIT_BADTRAINER)
	//To give you an edge in specialty moves like feints and stop you from being feinted
	subclass_stats = list(
		STATKEY_CON = 3,//This is going to need live testing, since I'm not sure they should be getting this much CON without using a statpack to spec. Revision pending.
		STATKEY_PER = 2,
		STATKEY_SPD = 1, //We want to encourage backstepping since you no longer get an extra layer of armour. I don't think this will break much of anything.
		STATKEY_STR = 1,
		STATKEY_END = -2
	)
	hiredbuff = /datum/status_effect/buff/merchired/freifechterlancer

	subclass_skills = list(
		/datum/skill/combat/polearms = SKILL_LEVEL_MASTER,	//This is the danger zone. Ultimately, the class won't be picked without this. I took the liberty of adjusting everything around to make this somewhat inoffensive, but we'll see if it sticks.
		/datum/skill/combat/unarmed = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/athletics = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/wrestling = SKILL_LEVEL_NOVICE,	//Wrestling is a swordsman's luxury.
		/datum/skill/misc/reading = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/climbing = SKILL_LEVEL_APPRENTICE,	//I got told that having zero climbing is a PITA. Bare minimum for a combat class.
	)

/datum/status_effect/buff/merchired/freifechterlancer
	effectedstats = list(STATKEY_CON = 1, STATKEY_PER = 1)

/datum/outfit/job/mercenary/freelancer_lancer/pre_equip(mob/living/carbon/human/H)
	..()
	to_chat(H, span_warning("You put complete trust in your polearm, the most effective weapon the world has seen. Why wear armour when you cannot be hit? You can choose your polearm, and are exceptionally accurate."))

	armor = /obj/item/clothing/suit/roguetown/armor/leather/heavy/freifechter
	var/weapons = list("Graduate's Spear", "Boar Spear", "Lucerne")
	var/weapon_choice = input(H, "Choose your weapon.", "TAKE UP ARMS") as anything in weapons
	switch(weapon_choice)
		if("Graduate's Spear")		//A steel spear with a cool-looking stick & a banner sticking out of it.
			r_hand = /obj/item/rogueweapon/spear/boar/frei
			l_hand = /obj/item/rogueweapon/katar/punchdagger/frei
		if("Boar Spear")
			r_hand = /obj/item/rogueweapon/spear/boar
			beltr = /obj/item/rogueweapon/katar/punchdagger
		if("Lucerne")		//A normal lucerne for the people that get no drip & no bitches.
			r_hand = /obj/item/rogueweapon/eaglebeak/lucerne
			beltr = /obj/item/rogueweapon/katar/punchdagger

	belt = /obj/item/storage/belt/rogue/leather/sash
	beltl = /obj/item/flashlight/flare/torch/lantern
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/freifechter
	pants = /obj/item/clothing/under/roguetown/heavy_leather_pants/otavan/generic
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced/short
	gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
	backr = /obj/item/storage/backpack/rogue/satchel/short

	backpack_contents = list(/obj/item/roguekey/mercenary)
