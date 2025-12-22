/datum/advclass/ogre/dumdum
	name = "Dum Dum" 
	tutorial = " You left Gronn because you could not find enough to eat there, and mean men kept firing arrows at you! Now you are here, and you are hungry. Time to find food!"
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = /datum/species/ogre
	outfit = /datum/outfit/job/roguetown/ogre/dumdum
	category_tags = list(CTAG_OGRE)
	cmode_music = 'sound/music/combat_guard3.ogg' // i think this is unused, but i like the song


	traits_applied = list(TRAIT_BASHDOORS, TRAIT_NOPAINSTUN, TRAIT_CALTROPIMMUNE, TRAIT_STRONGBITE, TRAIT_STRENGTH_UNCAPPED, TRAIT_MEDIUMARMOR, TRAIT_NASTY_EATER, TRAIT_CRITICAL_RESISTANCE) //strongbite might be funny
	subclass_stats = list( 
		STATKEY_STR = 4, 
		STATKEY_CON = 4,
		STATKEY_END = 4,
		STATKEY_INT = -2,
	)

	subclass_skills = list(
		/datum/skill/combat/maces = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/axes = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/wrestling = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/unarmed = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/knives = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/athletics = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/climbing = SKILL_LEVEL_APPRENTICE,
		/datum/skill/craft/cooking = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/labor/butchering = SKILL_LEVEL_EXPERT,
	) 

/datum/outfit/job/roguetown/ogre/dumdum/pre_equip(mob/living/carbon/human/H)
	..()
	if(H.mind)
		to_chat(H, span_warning("You no Dum Dum, me Dum Dum. Dum Dum kill that bum-bum!"))
		shoes = /obj/item/clothing/shoes/roguetown/armor/ogre
		neck = /obj/item/storage/belt/rogue/pouch/coins/poor
		pants = /obj/item/clothing/under/roguetown/chainlegs/ogre
		gloves = /obj/item/clothing/gloves/roguetown/plate/ogre
		wrists = /obj/item/clothing/wrists/roguetown/bracers/ogre
		belt = /obj/item/storage/belt/rogue/leather/ogre
		armor = /obj/item/clothing/suit/roguetown/armor/plate/half/ogre
		beltr = /obj/item/rogueweapon/huntingknife/cleaver/ogre
		backr = /obj/item/storage/backpack/rogue/satchel
		backpack_contents = list(
			/obj/item/rogueweapon/mace/cudgel/ogre = 1,
			/obj/item/rope/chain = 1,
			/obj/item/flashlight/flare/torch/lantern = 1
		)
