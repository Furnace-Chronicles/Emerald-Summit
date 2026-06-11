/datum/advclass/vagabond_mage
	name = "Failed Apprentice"
	tutorial = "Your master found you talentless, and cast you from their tower with nothing but your staff and dreams of what could've been."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	outfit = /datum/outfit/job/vagabond/mage
	category_tags = list(CTAG_VAGABOND)
	subclass_social_rank = SOCIAL_RANK_PEASANT

	traits_applied = list(TRAIT_MAGEARMOR, TRAIT_ARCYNE_T2, TRAIT_TALENTED_ALCHEMIST)
	subclass_stats = list(
		STATKEY_INT = 2,
		STATKEY_CON = -1,
		STATKEY_END = -1
	)

	// Magi 2 (T2 novice caster): 0 major / 1 minor / 4 utilities, universal arcyne ward.
	subclass_spellpoints = 0
	mage_aspect_config = list("major" = 0, "minor" = 1, "utilities" = 4, "ward" = TRUE)

	subclass_skills = list(
		/datum/skill/magic/arcane = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/reading = SKILL_LEVEL_EXPERT,
		/datum/skill/craft/alchemy = SKILL_LEVEL_NOVICE,
		/datum/skill/craft/crafting = SKILL_LEVEL_APPRENTICE,
	)

/datum/outfit/job/vagabond/mage/pre_equip(mob/living/carbon/human/H)
	..()
	if(should_wear_femme_clothes(H))
		armor = /obj/item/clothing/suit/roguetown/shirt/rags
	else if(should_wear_masc_clothes(H))
		pants = /obj/item/clothing/under/roguetown/tights/vagrant
		if(prob(50))
			pants = /obj/item/clothing/under/roguetown/tights/vagrant/l
		shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/vagrant
		if(prob(50))
			shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/vagrant/l

	if(prob(33))
		cloak = /obj/item/clothing/cloak/half/brown
		gloves = /obj/item/clothing/gloves/roguetown/fingerless

	r_hand = /obj/item/rogueweapon/woodstaff/implement_magi2 // Magi 2: lesser staff implement (T2 novice)
