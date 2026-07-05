/datum/advclass/gnoll/knight
	name = "Gnoll Knight"
	maximum_possible_slots = 1
	tutorial = "You were forged in the fires of the volcano, burn marks have long since healed, but the armor hammered against your muscle isn't so fleeting."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = list(/datum/species/gnoll)
	outfit = /datum/outfit/job/roguetown/gnoll/knight
	category_tags = list(CTAG_GNOLL)
	applies_post_equipment = FALSE
	// TRAIT_HEAVYARMOR "flavoring" dropped -- inert on a nudist species; the knight's edge is
	// the thickest hide (plate-tier prevent_crits, 800 integrity) instead.
	traits_applied = list()

	subclass_stats = list(
		STATKEY_END = 5,
		STATKEY_CON = 5,
		STATKEY_SPD = 2,
		STATKEY_INT = 1
	)
	subclass_skills = list(
		/datum/skill/combat/wrestling = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/swimming = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/unarmed = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/athletics = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/climbing = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/tracking = SKILL_LEVEL_LEGENDARY,
		/datum/skill/misc/sneaking = SKILL_LEVEL_EXPERT, // all gnolls stalk their prey (matches shaman/impure)
		/datum/skill/misc/medicine = SKILL_LEVEL_EXPERT,
		/datum/skill/craft/crafting = SKILL_LEVEL_NOVICE
	)
	cmode_music = 'sound/music/combat_graggar.ogg'

/datum/outfit/job/roguetown/gnoll/knight/pre_equip(mob/living/carbon/human/H)
	if(H.mind)
		H.set_species(/datum/species/gnoll)
		H.skin_armor = new /obj/item/clothing/suit/roguetown/armor/regenerating/skin/gnoll_armor/knight(H)
		neck = /obj/item/storage/belt/rogue/pouch/healing
		don_pelt(H)

/obj/item/clothing/suit/roguetown/armor/regenerating/skin/gnoll_armor/knight
	icon_state = "knight"
	max_integrity = 800
	armor = ARMOR_GNOLL_STRONG
	prevent_crits = list(BCLASS_CUT, BCLASS_STAB, BCLASS_CHOP, BCLASS_BLUNT, BCLASS_TWIST, BCLASS_SMASH) // plate-tier: armor hammered against muscle
	// Inherits the 5-minute repair_time from the gnoll_armor base.
