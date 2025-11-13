/mob/living/carbon/human/species/golem/porcelain
	race = /datum/species/golem/porcelain
	construct = 1

/datum/species/golem/porcelain
	name = "Doll"
	id = "doll"
	is_subrace = TRUE
	origin_default = /datum/virtue/origin/otava
	origin = "Otava"
	base_name = "Construct"
	desc = "<b>Porcelain Doll: Servants of Civility</b><br>\
	After the discovery of the dwarven golems, wizards around the world attempted to replicate the miracle of the Automata to mixed results. \
	The imperial wizards of the far east made the Doll as an arcane piece of engineering leaned towards administrative and hospitality \
	needs for a court that valued beauty and civility in its servants. They were made to be elegant and intelligent, \
	and more than a few are unnerved as these quiet constructs begin to fill courts across the world as advisors and clerks in various guildhouses. \
	Some folk even suspect there is some foul conspiracy involved.<br> \
	<span style='color: #cc0f0f;text-shadow:-1px -1px 0 #000,1px -1px 0 #000,-1px 1px 0 #000,1px 1px 0 #000;'><b>-2 STR</span> |<span style='color: #6a8cb7;text-shadow:-1px -1px 0 #000,1px -1px 0 #000,-1px 1px 0 #000,1px 1px 0 #000;'> +2 INT | +1 SPD</b></span> </br> \
	<span style='color: #cc0f0f;text-shadow:-1px -1px 0 #000,1px -1px 0 #000,-1px 1px 0 #000,1px 1px 0 #000;'><b><span style='color: #6a8cb7;text-shadow:-1px -1px 0 #000,1px -1px 0 #000,-1px 1px 0 #000,1px 1px 0 #000;'>Hungerless, Insomnia, Bloodless. Extremely fragile.</span></b></br>\
	<span style='color: #cc0f0f;text-shadow:-1px -1px 0 #000,1px -1px 0 #000,-1px 1px 0 #000,1px 1px 0 #000;'><b><span style='color: #6a8cb7;text-shadow:-1px -1px 0 #000,1px -1px 0 #000,-1px 1px 0 #000,1px 1px 0 #000;'>Capable of installing skill exhibitors in themselves or other Golems.</span></b></br>"


	construct = 1
	skin_tone_wording = "Material"
	default_color = "FFFFFF"
	species_traits = list(EYECOLOR,HAIR,FACEHAIR,LIPS,STUBBLE,OLDGREY,NOBLOOD)
	default_features = MANDATORY_FEATURE_LIST
	use_skintones = 1
	possible_ages = ALL_AGES_LIST
	skinned_type = /obj/item/ingot/steel
	disliked_food = NONE
	liked_food = NONE
	inherent_traits = list(TRAIT_NOHUNGER, TRAIT_BLOODLOSS_IMMUNE, TRAIT_NOBREATH, TRAIT_NOSLEEP, TRAIT_CRITICAL_WEAKNESS,
	TRAIT_BEAUTIFUL, TRAIT_EASYDISMEMBER, TRAIT_LIMBATTACHMENT, TRAIT_NOMETABOLISM, TRAIT_NOPAIN, TRAIT_ZOMBIE_IMMUNE)
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | RACE_SWAP | SLIME_EXTRACT
	limbs_icon_m = 'icons/roguetown/mob/bodies/m/golem.dmi'
	limbs_icon_f = 'icons/roguetown/mob/bodies/f/golem.dmi'
	dam_icon = 'icons/roguetown/mob/bodies/dam/dam_male.dmi'
	dam_icon_f = 'icons/roguetown/mob/bodies/dam/dam_female.dmi'
	soundpack_m = /datum/voicepack/male
	soundpack_f = /datum/voicepack/female
	offset_features = list(
		OFFSET_ID = list(0,1), OFFSET_GLOVES = list(0,1), OFFSET_WRISTS = list(0,1),\
		OFFSET_CLOAK = list(0,1), OFFSET_FACEMASK = list(0,1), OFFSET_HEAD = list(0,1), \
		OFFSET_FACE = list(0,1), OFFSET_BELT = list(0,1), OFFSET_BACK = list(0,1), \
		OFFSET_NECK = list(0,1), OFFSET_MOUTH = list(0,1), OFFSET_PANTS = list(0,0), \
		OFFSET_SHIRT = list(0,1), OFFSET_ARMOR = list(0,1), OFFSET_HANDS = list(0,1), OFFSET_UNDIES = list(0,1), \
		OFFSET_ID_F = list(0,-1), OFFSET_GLOVES_F = list(0,0), OFFSET_WRISTS_F = list(0,0), OFFSET_HANDS_F = list(0,0), \
		OFFSET_CLOAK_F = list(0,0), OFFSET_FACEMASK_F = list(0,-1), OFFSET_HEAD_F = list(0,-1), \
		OFFSET_FACE_F = list(0,-1), OFFSET_BELT_F = list(0,0), OFFSET_BACK_F = list(0,-1), \
		OFFSET_NECK_F = list(0,-1), OFFSET_MOUTH_F = list(0,-1), OFFSET_PANTS_F = list(0,0), \
		OFFSET_SHIRT_F = list(0,0), OFFSET_ARMOR_F = list(0,0), OFFSET_UNDIES_F = list(0,-1), \
		)
	race_bonus = list(STAT_INTELLIGENCE = 2, STAT_SPEED = 1, STAT_STRENGTH = -2)
	enflamed_icon = "widefire"
	organs = list(
		ORGAN_SLOT_BRAIN = /obj/item/organ/brain/golem,
		ORGAN_SLOT_HEART = /obj/item/organ/heart/golem,
		ORGAN_SLOT_LUNGS = /obj/item/organ/lungs/golem,
		ORGAN_SLOT_EYES = /obj/item/organ/eyes/golem,
		ORGAN_SLOT_EARS = /obj/item/organ/ears,
		ORGAN_SLOT_TONGUE = /obj/item/organ/tongue/golem,
		ORGAN_SLOT_LIVER = /obj/item/organ/liver/golem,
		ORGAN_SLOT_STOMACH = /obj/item/organ/stomach/golem,
		)
	customizers = list(
		/datum/customizer/organ/eyes/humanoid,
		/datum/customizer/bodypart_feature/hair/head/humanoid,
		/datum/customizer/bodypart_feature/accessory,
		/datum/customizer/bodypart_feature/face_detail,
		/datum/customizer/bodypart_feature/underwear,
		/datum/customizer/bodypart_feature/legwear,
		/datum/customizer/organ/penis/anthro,
		/datum/customizer/organ/breasts/human,
		/datum/customizer/organ/vagina/human_anthro,
		/datum/customizer/organ/testicles/anthro,
		)
	body_marking_sets = list(
		/datum/body_marking_set/none,
	)
	body_markings = list(
	    /datum/body_marking/flushed_cheeks,
		/datum/body_marking/eyeliner,
		/datum/body_marking/tonage,
		/datum/body_marking/nose,
		/datum/body_marking/bangs,
		/datum/body_marking/bun,
	)

/datum/species/golem/porcelain/check_roundstart_eligible()
	return TRUE

/datum/species/golem/porcelain/get_skin_list()
	return list(
		"Porcelain" = DOLL_PORCELAIN,
		"Sienna" = DOLL_SIENNA,
		"Lotus" = DOLL_KAZENGUN,
		"Scarlet Reach" = DOLL_SCARLET_REACH,
		"Walnut" = DOLL_WALNUT,
		"Gloom" = DOLL_GLOOMHAVEN,
		"Ebon" = DOLL_EBON,
	)

/datum/species/golem/porcelain/get_skin_list_tooltip()
	return list(
		"Porcelain <span style='border: 1px solid #161616; background-color: #[DOLL_PORCELAIN];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" = DOLL_PORCELAIN,
		"Sienna <span style='border: 1px solid #161616; background-color: #[DOLL_SIENNA];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" = DOLL_SIENNA,
		"Lotus <span style='border: 1px solid #161616; background-color: #[DOLL_KAZENGUN];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" = DOLL_KAZENGUN,
		"Scarlet Reach <span style='border: 1px solid #161616; background-color: #[DOLL_SCARLET_REACH];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" = DOLL_SCARLET_REACH,
		"Walnut <span style='border: 1px solid #161616; background-color: #[DOLL_WALNUT];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" = DOLL_WALNUT,
		"Gloom <span style='border: 1px solid #161616; background-color: #[DOLL_GLOOMHAVEN];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" = DOLL_GLOOMHAVEN,
		"Ebon <span style='border: 1px solid #161616; background-color: #[DOLL_EBON];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" = DOLL_EBON,
	)

/datum/species/golem/porcelain/get_hairc_list()
	return sortList(list(

	"black - midnight" = "1d1b2b",

	"red - blood" = "822b2b"

	))

