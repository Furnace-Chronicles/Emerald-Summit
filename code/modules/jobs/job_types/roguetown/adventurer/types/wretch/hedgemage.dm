// Hedge Mage, a pure mage adventurer sidegrade to Necromancer without the Necromancer free spells and forced patron. More spellpoints, otherwise mostly the same.
/datum/advclass/wretch/hedgemage
	name = "Hedge Mage"
	tutorial = "They reject your genius, they cast you out, they call you unethical. They do not understand the SACRIFICES you must make. But it does not matter anymore, your power eclipse any of those fools, save for the Court Magos themselves. Show them true magic. Why do I have an eyepatch?"
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	outfit = /datum/outfit/job/wretch/hedgemage
	category_tags = list(CTAG_WRETCH)
	cmode_music = 'sound/music/combat_bandit_mage.ogg'
	extra_context = "Choose between 2 options: 27 spellpoints or 21 spellpoints and Dodge Expert."

	traits_applied = list(TRAIT_MAGEARMOR, TRAIT_ARCYNE_T3)
	// Same stat spread as necromancer, same reasoning
	subclass_stats = list(
		STATKEY_INT = 4,
		STATKEY_PER = 2,
		STATKEY_END = 1,
		STATKEY_SPD = 1
	)

	subclass_spellpoints = 21 // Unlike Rogue Mage, who gets 6 but DExpert, this one don't have DExpert but have more spell points than anyone but the CM.

	subclass_skills = list(
		/datum/skill/combat/polearms = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/athletics = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/wrestling = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/unarmed = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/reading = SKILL_LEVEL_MASTER,
		/datum/skill/craft/alchemy = SKILL_LEVEL_EXPERT,
		/datum/skill/magic/arcane = SKILL_LEVEL_EXPERT,
	)

// Hedge Mage on purpose has nearly the same fit as a Adv Mage / Mage Associate who cast conjure armor roundstart. Call it meta disguise.
/datum/outfit/job/wretch/hedgemage/pre_equip(mob/living/carbon/human/H)
	mask = /obj/item/clothing/mask/rogue/eyepatch // Chuunibyou up to 11.
	head = /obj/item/clothing/head/roguetown/roguehood/black
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	pants = /obj/item/clothing/under/roguetown/heavy_leather_pants
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather/heavy
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	if(should_wear_femme_clothes(H))
		armor = /obj/item/clothing/suit/roguetown/armor/leather/studded/bikini
	else
		armor = /obj/item/clothing/suit/roguetown/armor/leather/studded
	gloves = /obj/item/clothing/gloves/roguetown/angle
	cloak = /obj/item/clothing/suit/roguetown/shirt/robe/black
	belt = /obj/item/storage/belt/rogue/leather
	beltr = /obj/item/reagent_containers/glass/bottle/rogue/manapot
	neck = /obj/item/clothing/neck/roguetown/leather // No iron gorget vs necro. They will have to acquire one in round.
	beltl = /obj/item/storage/magebag/starter
	backl = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/woodstaff/ruby
	backpack_contents = list(
		/obj/item/spellbook_unfinished/pre_arcyne = 1,
		/obj/item/roguegem/amethyst = 1,
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/flashlight/flare/torch/lantern/prelit = 1,
		/obj/item/rope/chain = 1,
		/obj/item/ritechalk = 1,
		/obj/item/rogueweapon/huntingknife = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/recipe_book/magic,
	)

	H.dna.species.soundpack_m = new /datum/voicepack/male/wizard()

	if(H.age == AGE_OLD)
		H.adjust_skillrank_up_to(/datum/skill/magic/arcane, SKILL_LEVEL_MASTER, TRUE)
		H?.mind.adjust_spellpoints(6)
	var/classes = list("Hedge Mage","Rogue Mage")
	var/classchoice = input(H, "Choose your archetypes", "Available archetypes") as anything in classes
	switch(classchoice)
		if("Hedge Mage")
			H?.mind.adjust_spellpoints(6)
		if("Rogue Mage")
			ADD_TRAIT(H, TRAIT_DODGEEXPERT, TRAIT_GENERIC)
	wretch_select_bounty(H)
