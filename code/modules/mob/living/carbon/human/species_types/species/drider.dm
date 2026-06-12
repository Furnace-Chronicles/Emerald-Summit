/mob/living/carbon/human/species/drider
	race = /datum/species/drider

// Drider — a Beastvolk subrace: a humanoid torso atop a great spider's body. Reuses the lamian/taur
// lower-body pipeline (LAMIAN_TAIL trait + lamian_tail bodypart), so the tail picker, tail colour and
// rendering all work; on species gain the legs are swapped for the spider lower body, and on loss they
// revert to normal legs. The spider leg sprites live in icons/mob/species/taurs.dmi.
/datum/species/drider
	name = "Drider"
	id = "drider"
	is_subrace = TRUE
	origin_default = /datum/virtue/origin/etrusca
	origin = "Etrusca"
	use_titles = TRUE
	race_titles = list("Drider", "Arachne", "Webweaver", "Spinneret", "Spider-kin")
	base_name = "Beastvolk"
	sub_name = "Drider"
	desc = "<b>Drider</b><br>\
	A humanoid torso rising from the body of a great spider. Driders are reclusive weavers of the deep \
	woods, caverns and ruins, scuttling across walls and webs with unsettling ease. Shunned for their \
	monstrous shape, most keep to the wilds and the dark, though a rare few walk among the other races. \
	They move freely across the webs of their kin and the spines of caltrops trouble them not.<br> \
	<span style='color: #cc0f0f;text-shadow:-1px -1px 0 #000,1px -1px 0 #000,-1px 1px 0 #000,1px 1px 0 #000;'><b>-1 SPD</span> |<span style='color: #6a8cb7;text-shadow:-1px -1px 0 #000,1px -1px 0 #000,-1px 1px 0 #000,1px 1px 0 #000;'> +1 STR</b></span> </br> \
	<span style='color: #cc0f0f;text-shadow:-1px -1px 0 #000,1px -1px 0 #000,-1px 1px 0 #000,1px 1px 0 #000;'><b>Can't wear boots</span> | <span style='color: #6a8cb7;text-shadow:-1px -1px 0 #000,1px -1px 0 #000,-1px 1px 0 #000,1px 1px 0 #000;'>Strong kicks, Longstrider, Webwalker, Skilled Climber, Strong stomach</span></b>"
	default_color = "FFFFFF"
	species_traits = list(EYECOLOR, LIPS, HAIR, LAMIAN_TAIL, OLDGREY, MUTCOLORS)
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | RACE_SWAP | SLIME_EXTRACT
	possible_ages = ALL_AGES_LIST
	limbs_icon_m = 'icons/roguetown/mob/bodies/m/human.dmi'
	limbs_icon_f = 'icons/roguetown/mob/bodies/f/human.dmi'
	dam_icon = 'icons/roguetown/mob/bodies/dam/dam_male.dmi'
	dam_icon_f = 'icons/roguetown/mob/bodies/dam/dam_female.dmi'
	// Boots/pants are blocked dynamically while the spider lower body is present (see can_equip's
	// get_lamian_tail() gate); if it's ever surgically replaced with legs, leg gear becomes wearable.
	no_equip = list()
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
	inherent_traits = list(TRAIT_LONGSTRIDER, TRAIT_WILD_EATER, TRAIT_LAMIAN_TAIL, TRAIT_CALTROPIMMUNE, TRAIT_WEBWALK)
	disliked_food = NONE
	race_bonus = list(STAT_STRENGTH = 1, STAT_SPEED = -1)
	enflamed_icon = "widefire"
	organs = list(
		ORGAN_SLOT_BRAIN = /obj/item/organ/brain,
		ORGAN_SLOT_HEART = /obj/item/organ/heart,
		ORGAN_SLOT_LUNGS = /obj/item/organ/lungs,
		ORGAN_SLOT_EYES = /obj/item/organ/eyes,
		ORGAN_SLOT_EARS = /obj/item/organ/ears,
		ORGAN_SLOT_TONGUE = /obj/item/organ/tongue,
		ORGAN_SLOT_LIVER = /obj/item/organ/liver,
		ORGAN_SLOT_STOMACH = /obj/item/organ/stomach,
		ORGAN_SLOT_APPENDIX = /obj/item/organ/appendix,
		)
	bodypart_features = list(
		/datum/bodypart_feature/hair/head,
		/datum/bodypart_feature/hair/facial,
	)
	customizers = list(
		/datum/customizer/organ/eyes/humanoid,
		/datum/customizer/bodypart_feature/hair/head/humanoid,
		/datum/customizer/bodypart_feature/hair/facial/humanoid,
		/datum/customizer/bodypart_feature/accessory,
		/datum/customizer/bodypart_feature/face_detail,
		/datum/customizer/bodypart_feature/underwear,
		/datum/customizer/organ/horns/lamia,
		/datum/customizer/organ/penis/anthro,
		/datum/customizer/organ/testicles/anthro,
		/datum/customizer/organ/breasts/human,
		/datum/customizer/organ/vagina/anthro,
		)
	body_marking_sets = list(
		/datum/body_marking_set/none,
	)
	languages = list(
		/datum/language/common,
	)
	body_markings = list(
		/datum/body_marking/flushed_cheeks,
		/datum/body_marking/cheek_grease,
		/datum/body_marking/eyeliner,
		/datum/body_marking/plain,
		/datum/body_marking/nose,
	)
	descriptor_choices = list(
		/datum/descriptor_choice/height,
		/datum/descriptor_choice/body,
		/datum/descriptor_choice/stature,
		/datum/descriptor_choice/face,
		/datum/descriptor_choice/face_exp,
		/datum/descriptor_choice/voice,
		/datum/descriptor_choice/prominent_one_wild,
		/datum/descriptor_choice/prominent_two_wild,
		/datum/descriptor_choice/prominent_three_wild,
		/datum/descriptor_choice/prominent_four_wild,
	)

	allowed_tail_types = list(
		/obj/item/bodypart/lamian_tail/drider,
	)

/datum/species/drider/check_roundstart_eligible()
	return TRUE

/datum/species/drider/qualifies_for_rank(rank, list/features)
	return TRUE

/datum/species/drider/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	C.Driderize()
	C.adjust_skillrank(/datum/skill/misc/climbing, 5, TRUE) // scuttling across walls and webs
	// Natural chitin armor is granted by the drider legs bodypart itself (attach_limb), so it
	// follows the lower body rather than the species. See lamian_tail.dm.

/datum/species/drider/on_species_loss(mob/living/carbon/C)
	. = ..()
	C.de_Lamia() // gives normal legs back

/datum/species/drider/spec_fully_heal(mob/living/carbon/human/H)
	H.Driderize()

// Drider chitin — natural armor on the spider legs (see lamian_legs base in lamia.dm / harpy talon skin).
/obj/item/clothing/suit/roguetown/armor/skin_armor/lamian_legs/drider
	name = "chitinous legs"

/obj/item/clothing/suit/roguetown/armor/skin_armor/lamian_legs/drider/obj_destruction()
	visible_message("The chitin cracks!", span_bloody("<b>THE CHITIN ON MY LEGS CRACKS!!</b>"))
