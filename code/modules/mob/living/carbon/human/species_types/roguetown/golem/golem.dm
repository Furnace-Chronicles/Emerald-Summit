/mob/living/carbon/human/species/golem/metal
	race = /datum/species/golem/metal
	construct = 1

/datum/species/golem/metal
	name = "Golem"
	id = "golem"
	desc = "<b>Golem</b><br>\
	Masterworks of craftsmanship, the first Golems were constructed in the Merchant Republic of Giza with similar designs \
	spreading  spreading across the lands. Created to be the perfect servants, they do not sleep, eat or bleed and the \
	materials composing their shells makes them more resilient if not slower than most. As of late, a rebellion amongst \
	the Golems of Giza has given way to a new generation of individualistic arcyne-forged. Much of society as a whole is \
	conflicted on Golems, for their sensibilities vary wildly from one to the next. \
	into cohabitation with races they'd deem lesser.<br> \
	(Insomnia, No hunger, no blood.) \
	(+1 Constitution, -2 Speed)"

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
	inherent_traits = list(TRAIT_NOHUNGER, TRAIT_BLOODLOSS_IMMUNE, TRAIT_NOBREATH, TRAIT_NOSLEEP)
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | RACE_SWAP | SLIME_EXTRACT
	limbs_icon_m = 'icons/roguetown/mob/bodies/m/mcom.dmi'
	limbs_icon_f = 'icons/roguetown/mob/bodies/f/fcom.dmi'
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
	race_bonus = list(STAT_CONSTITUTION = 1, STAT_SPEED = -2)
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
		/datum/customizer/bodypart_feature/crest,
		/datum/customizer/bodypart_feature/hair/head/humanoid,
		/datum/customizer/bodypart_feature/hair/facial/humanoid,
		/datum/customizer/bodypart_feature/accessory,
		/datum/customizer/bodypart_feature/face_detail,
		/datum/customizer/bodypart_feature/underwear,
		/datum/customizer/organ/ears/demihuman,
		/datum/customizer/organ/horns/demihuman,
		/datum/customizer/organ/tail/demihuman,
		/datum/customizer/organ/wings/anthro,
		/datum/customizer/organ/penis/anthro,
		/datum/customizer/organ/breasts/human,
		/datum/customizer/organ/vagina/human_anthro,
		)
	body_marking_sets = list(
		/datum/body_marking_set/none,
	)
	body_markings = list(
		/datum/body_marking/eyeliner,
		/datum/body_marking/plain,
		/datum/body_marking/tonage,
		/datum/body_marking/nose,
	)

/datum/species/golem/metal/check_roundstart_eligible()
	return TRUE

/datum/species/golem/metal/get_skin_list()
	return list(
		"Brass" = GOLEM_BRASS,
		"Iron" = GOLEM_IRON,
		"Steel" = GOLEM_STEEL,
		"Bronze" = GOLEM_BRONZE,
		"Marble" = GOLEM_MARBLE,
		"Coal" = GOLEM_COAL,
		"Cobalt" = GOLEM_COBALT,
		"Granite" = GOLEM_GRANITE,
		"Jade" = GOLEM_JADE
	)

/datum/species/golem/metal/get_hairc_list()
	return sortList(list(

	"black - midnight" = "1d1b2b",

	"red - blood" = "822b2b"

	))

