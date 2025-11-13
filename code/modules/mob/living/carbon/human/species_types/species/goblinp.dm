/mob/living/carbon/human/species/goblinp
	race = /datum/species/goblinp

/datum/species/goblinp
	name = "Goblin"
	id = "goblinp"
	origin_default = /datum/virtue/origin/racial/gronn
	origin = "Gronn"
	is_subrace = TRUE
	base_name = "Ogroid"
	desc = "<b>Goblin: Nomadic Tribes of the Night</b><br>\
	Created by the hand of Noc as a creative and inquisitive species, \
	tribes of goblins spread across the world from the wind-whipped steppes of Gronn. \
	While their worship and their culture is different across the nations, a commonality is the nomadic nature of their clans across the wilds. \
	They have become a favorite of Graggar to capture and devour the souls, releasing empty violent husks into the world’s cities. \
	These well traveled peoples at times do settle down into villages or join established settlements, \
	where fast feet aid them when they are mistaken for portal-thralls. \
	Graggar’s hunger has led to there being more soulless husks in his armies than surviving goblins.<br>\
	<span style='color: #6a8cb7;text-shadow:-1px -1px 0 #000,1px -1px 0 #000,-1px 1px 0 #000,1px 1px 0 #000;'><b> +1 SPD</b></span> </br>\
	<span style='color: #6a8cb7;text-shadow:-1px -1px 0 #000,1px -1px 0 #000,-1px 1px 0 #000,1px 1px 0 #000;'><b> Inhumen Digestion</b></span> </br>"
	
	species_traits = list(EYECOLOR,LIPS,STUBBLE)
	inherent_traits = list(TRAIT_NASTY_EATER)
	possible_ages = ALL_AGES_LIST
	use_skintones = TRUE
	limbs_icon_m = 'icons/roguetown/mob/bodies/m/goblin.dmi'
	limbs_icon_f = 'icons/roguetown/mob/bodies/f/dwarf.dmi'
	dam_icon = 'icons/roguetown/mob/bodies/dam/dam_male.dmi'
	dam_icon_f = 'icons/roguetown/mob/bodies/dam/dam_female.dmi'
	soundpack_m = /datum/voicepack/male/goblin
	soundpack_f = /datum/voicepack/female/goblin
	custom_clothes = TRUE
	use_f = TRUE
	disliked_food = NONE
	clothes_id = "dwarf"
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | RACE_SWAP | SLIME_EXTRACT
	organs = list(
		ORGAN_SLOT_BRAIN = /obj/item/organ/brain,
		ORGAN_SLOT_HEART = /obj/item/organ/heart,
		ORGAN_SLOT_LUNGS = /obj/item/organ/lungs,
		ORGAN_SLOT_EYES = /obj/item/organ/eyes,
		ORGAN_SLOT_TONGUE = /obj/item/organ/tongue,
		ORGAN_SLOT_LIVER = /obj/item/organ/liver,
		ORGAN_SLOT_STOMACH = /obj/item/organ/stomach,
		ORGAN_SLOT_APPENDIX = /obj/item/organ/appendix,
		//ORGAN_SLOT_TESTICLES = /obj/item/organ/testicles,
		//ORGAN_SLOT_PENIS = /obj/item/organ/penis,
		//ORGAN_SLOT_BREASTS = /obj/item/organ/breasts,
		//ORGAN_SLOT_VAGINA = /obj/item/organ/vagina,
		)
	offset_features = list(
		OFFSET_ID = list(0,-4), OFFSET_GLOVES = list(0,-4), OFFSET_WRISTS = list(0,-4),\
		OFFSET_CLOAK = list(0,0), OFFSET_FACEMASK = list(0,-5), OFFSET_HEAD = list(0,-4), \
		OFFSET_FACE = list(0,-5), OFFSET_BELT = list(0,-4), OFFSET_BACK = list(0,-4), \
		OFFSET_NECK = list(0,-4), OFFSET_MOUTH = list(0,-4), OFFSET_PANTS = list(0,0), \
		OFFSET_SHIRT = list(0,0), OFFSET_ARMOR = list(0,0), OFFSET_HANDS = list(0,-3), OFFSET_UNDIES = list(0,-4), \
		OFFSET_ID_F = list(0,-5), OFFSET_GLOVES_F = list(0,-4), OFFSET_WRISTS_F = list(0,-4), OFFSET_HANDS_F = list(0,-4), \
		OFFSET_CLOAK_F = list(0,0), OFFSET_FACEMASK_F = list(0,-5), OFFSET_HEAD_F = list(0,-5), \
		OFFSET_FACE_F = list(0,-5), OFFSET_BELT_F = list(0,-4), OFFSET_BACK_F = list(0,-5), \
		OFFSET_NECK_F = list(0,-5), OFFSET_MOUTH_F = list(0,-5), OFFSET_PANTS_F = list(0,0), \
		OFFSET_SHIRT_F = list(0,0), OFFSET_ARMOR_F = list(0,0), OFFSET_UNDIES_F = list(0,-4), \
		)
	race_bonus = list(STAT_SPEED = 1)
	enflamed_icon = "widefire"
	attack_verb = "slash"
	attack_sound = 'sound/blank.ogg'
	miss_sound = 'sound/blank.ogg'
	customizers = list(
		/datum/customizer/organ/eyes/humanoid,
		/datum/customizer/bodypart_feature/hair/head/humanoid,
		/datum/customizer/bodypart_feature/hair/facial/humanoid,
		/datum/customizer/bodypart_feature/accessory,
		/datum/customizer/bodypart_feature/face_detail,
		/datum/customizer/bodypart_feature/underwear,
		/datum/customizer/bodypart_feature/legwear,
		/datum/customizer/organ/testicles/anthro,
		/datum/customizer/organ/penis/anthro,
		/datum/customizer/organ/breasts/human,
		/datum/customizer/organ/vagina/human_anthro,
		/datum/customizer/organ/ears/goblin,
		/datum/customizer/organ/horns/tusks,
		)
	languages = list(
		/datum/language/common,
		/datum/language/orcish
	)
	stress_examine = TRUE
	stress_desc = span_red("Horrid little goblin...")
	descriptor_choices = list(
		/datum/descriptor_choice/height,
		/datum/descriptor_choice/body,
		/datum/descriptor_choice/stature,
		/datum/descriptor_choice/face,
		/datum/descriptor_choice/face_exp,
		/datum/descriptor_choice/skin_all,
		/datum/descriptor_choice/voice,
		/datum/descriptor_choice/prominent_one_wild,
		/datum/descriptor_choice/prominent_two_wild,
		/datum/descriptor_choice/prominent_three_wild,
		/datum/descriptor_choice/prominent_four_wild,
	)

/datum/species/goblinp/check_roundstart_eligible()
	return TRUE

/datum/species/goblinp/qualifies_for_rank(rank, list/features)
	return TRUE

/datum/species/goblinp/get_skin_list()
	return list(
		"Ochre" = SKIN_COLOR_OCHRE,
		"Meadow" = SKIN_COLOR_MEADOW,
		"Olive" = SKIN_COLOR_OLIVE,
		"Green" = SKIN_COLOR_GREEN,
		"Moss" = SKIN_COLOR_MOSS,
		"Taiga" = SKIN_COLOR_TAIGA,
		"Bronze" = SKIN_COLOR_BRONZE,
		"Red" = SKIN_COLOR_RED,
		"Teal" = SKIN_COLOR_TEAL,
		"Frost" = SKIN_COLOR_FROST,
		"Abyss" = SKIN_COLOR_ABYSS,
		"Hadal" = SKIN_COLOR_HADAL,
		"Bone" = SKIN_COLOR_BONE,
		"Stone" = SKIN_COLOR_STONE
	)

/datum/species/goblinp/get_skin_list_tooltip()
	return list(
		"Ochre <span style='border: 1px solid #161616; background-color: #[SKIN_COLOR_OCHRE];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" = SKIN_COLOR_OCHRE,
		"Meadow <span style='border: 1px solid #161616; background-color: #[SKIN_COLOR_MEADOW];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" = SKIN_COLOR_MEADOW,
		"Olive <span style='border: 1px solid #161616; background-color: #[SKIN_COLOR_OLIVE];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" = SKIN_COLOR_OLIVE,
		"Green <span style='border: 1px solid #161616; background-color: #[SKIN_COLOR_GREEN];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" = SKIN_COLOR_GREEN,
		"Moss <span style='border: 1px solid #161616; background-color: #[SKIN_COLOR_MOSS];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" = SKIN_COLOR_MOSS,
		"Taiga <span style='border: 1px solid #161616; background-color: #[SKIN_COLOR_TAIGA];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" = SKIN_COLOR_TAIGA,
		"Bronze <span style='border: 1px solid #161616; background-color: #[SKIN_COLOR_BRONZE];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" = SKIN_COLOR_BRONZE,
		"Red <span style='border: 1px solid #161616; background-color: #[SKIN_COLOR_RED];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" = SKIN_COLOR_RED,
		"Teal <span style='border: 1px solid #161616; background-color: #[SKIN_COLOR_TEAL];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" = SKIN_COLOR_TEAL,
		"Frost <span style='border: 1px solid #161616; background-color: #[SKIN_COLOR_FROST];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" = SKIN_COLOR_FROST,
		"Abyss <span style='border: 1px solid #161616; background-color: #[SKIN_COLOR_ABYSS];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" = SKIN_COLOR_ABYSS,
		"Hadal <span style='border: 1px solid #161616; background-color: #[SKIN_COLOR_HADAL];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" = SKIN_COLOR_HADAL,
		"Bone <span style='border: 1px solid #161616; background-color: #[SKIN_COLOR_BONE];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" = SKIN_COLOR_BONE,
		"Stone <span style='border: 1px solid #161616; background-color: #[SKIN_COLOR_STONE];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" = SKIN_COLOR_STONE,
	)

/datum/species/goblinp/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	C.cmode_music = 'sound/music/combat_gronn.ogg'
	RegisterSignal(C, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/species/goblinp/on_species_loss(mob/living/carbon/C)
	. = ..()
	UnregisterSignal(C, COMSIG_MOB_SAY)
