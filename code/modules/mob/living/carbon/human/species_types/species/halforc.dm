/mob/living/carbon/human/species/halforc
	race = /datum/species/halforc

/datum/species/halforc
	name = "Half-Orc"
	id = "halforc"
	origin_default = /datum/virtue/origin/racial/gronn
	origin = "Gronn"
	base_name = "Ogroid"
	desc = "<b>Half Orcs: Conquerors yet Conquered</b><br>\
	Created by the hand of Ravox to serve his law and justice, orcs were dutiful and strong people. \
	Yet when the orcish slave Graggar ascended he dominated a large swath of the species, stealing them away from his creator’s control. \
	From the steppes of Gronn to the mountains of Kazugan, the orcish tribes have either scattered or been conquered and absorbed in the horde of the Ironmask. \
	Not all orcs have fallen to the corruption of Graggar, and many flee for safer lands, taking partners among dwarves, elves and humans; \
	without their clans, they often adopt their non-orcish culture.<br>\
	<span style='color: #6a8cb7;text-shadow:-1px -1px 0 #000,1px -1px 0 #000,-1px 1px 0 #000,1px 1px 0 #000;'><b> +1 STR</b></span> </br>\
	<span style='color: #6a8cb7;text-shadow:-1px -1px 0 #000,1px -1px 0 #000,-1px 1px 0 #000,1px 1px 0 #000;'><b> LANGUAGE: Orcish - ,o</b></span> </br>"

	skin_tone_wording = "Clan"

	species_traits = list(EYECOLOR,HAIR,FACEHAIR,LIPS,STUBBLE,OLDGREY)
	inherent_traits = list(TRAIT_NOMOBSWAP)
	default_features = MANDATORY_FEATURE_LIST
	use_skintones = 1
	disliked_food = NONE
	liked_food = NONE
	possible_ages = ALL_AGES_LIST
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | RACE_SWAP | SLIME_EXTRACT
	limbs_icon_m = 'icons/roguetown/mob/bodies/m/orc.dmi'
	limbs_icon_f = 'icons/roguetown/mob/bodies/f/orc.dmi'
	dam_icon = 'icons/roguetown/mob/bodies/dam/dam_male.dmi'
	dam_icon_f = 'icons/roguetown/mob/bodies/dam/dam_male.dmi'
	use_m = TRUE
	soundpack_m = /datum/voicepack/male/elf
	soundpack_f = /datum/voicepack/female/elf
	offset_features = list(OFFSET_ID = list(0,1), OFFSET_GLOVES = list(0,1), OFFSET_WRISTS = list(0,1),\
	OFFSET_CLOAK = list(0,1), OFFSET_FACEMASK = list(0,1), OFFSET_HEAD = list(0,1), \
	OFFSET_FACE = list(0,1), OFFSET_BELT = list(0,1), OFFSET_BACK = list(0,1), \
	OFFSET_NECK = list(0,1), OFFSET_MOUTH = list(0,1), OFFSET_PANTS = list(0,0), \
	OFFSET_SHIRT = list(0,1), OFFSET_ARMOR = list(0,1), OFFSET_HANDS = list(0,1), OFFSET_UNDIES = list(0,1), \
	OFFSET_ID_F = list(0,1), OFFSET_GLOVES_F = list(0,1), OFFSET_WRISTS_F = list(0,1), OFFSET_HANDS_F = list(0,1), \
	OFFSET_CLOAK_F = list(0,1), OFFSET_FACEMASK_F = list(0,1), OFFSET_HEAD_F = list(0,1), \
	OFFSET_FACE_F = list(0,1), OFFSET_BELT_F = list(0,1), OFFSET_BACK_F = list(0,1), \
	OFFSET_NECK_F = list(0,1), OFFSET_MOUTH_F = list(0,1), OFFSET_PANTS_F = list(0,1), \
	OFFSET_SHIRT_F = list(0,1), OFFSET_ARMOR_F = list(0,1), OFFSET_UNDIES_F = list(0,1))
	race_bonus = list(STAT_STRENGTH = 1)
	enflamed_icon = "widefire"
	organs = list(
		ORGAN_SLOT_BRAIN = /obj/item/organ/brain,
		ORGAN_SLOT_HEART = /obj/item/organ/heart,
		ORGAN_SLOT_LUNGS = /obj/item/organ/lungs,
		ORGAN_SLOT_EYES = /obj/item/organ/eyes,
		ORGAN_SLOT_EARS = /obj/item/organ/ears/halforc,
		ORGAN_SLOT_TONGUE = /obj/item/organ/tongue,
		ORGAN_SLOT_LIVER = /obj/item/organ/liver,
		ORGAN_SLOT_STOMACH = /obj/item/organ/stomach,
		ORGAN_SLOT_APPENDIX = /obj/item/organ/appendix,
		//ORGAN_SLOT_TESTICLES = /obj/item/organ/testicles,
		//ORGAN_SLOT_PENIS = /obj/item/organ/penis,
		//ORGAN_SLOT_BREASTS = /obj/item/organ/breasts,
		//ORGAN_SLOT_VAGINA = /obj/item/organ/vagina,
		)
	body_marking_sets = list(
		/datum/body_marking_set/none,
		/datum/body_marking_set/belly,
		/datum/body_marking_set/bellysocks,
		/datum/body_marking_set/tiger,
		/datum/body_marking_set/tiger_dark,
	)
	body_markings = list(
		/datum/body_marking/flushed_cheeks,
		/datum/body_marking/eyeliner,
		/datum/body_marking/tonage,
	)
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
		/datum/customizer/organ/horns/tusks,
		/datum/customizer/organ/ears/halforc,
		)
	languages = list(
		/datum/language/common,
		/datum/language/orcish
	)

/datum/species/halforc/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	RegisterSignal(C, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/species/halforc/after_creation(mob/living/carbon/C)
	..()
	to_chat(C, "<span class='info'>I can speak Orcish with ,o before my speech.</span>")

/datum/species/halforc/on_species_loss(mob/living/carbon/C)
	. = ..()
	UnregisterSignal(C, COMSIG_MOB_SAY)

/datum/species/halforc/qualifies_for_rank(rank, list/features)
	return TRUE

/datum/species/halforc/get_skin_list()
	return list(
		"Shellcrest" = SKIN_COLOR_SHELLCREST,
		"Bloodaxe" = SKIN_COLOR_BLOOD_AXE,
		"Splitjaw" = SKIN_COLOR_GROONN, //Changed name from Gronn, which no longer aligned with lore here or elsewhere.
		"Blackhammer" = SKIN_COLOR_BLACK_HAMMER,
		"Skullseeker" = SKIN_COLOR_SKULL_SEEKER,
		"Crescent Fang" = SKIN_COLOR_CRESCENT_FANG,
		"Murkwalker" = SKIN_COLOR_MURKWALKER,
		"Shatterhorn" = SKIN_COLOR_SHATTERHORN,
		"Spirit Crusher" = SKIN_COLOR_SPIRITCRUSHER
	)

/datum/species/halforc/get_skin_list_tooltip()
	return list(
		"Shellcrest <span style='border: 1px solid #161616; background-color: #[SKIN_COLOR_SHELLCREST];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" = SKIN_COLOR_SHELLCREST,
		"Bloodaxe <span style='border: 1px solid #161616; background-color: #[SKIN_COLOR_BLOOD_AXE];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" = SKIN_COLOR_BLOOD_AXE,
		"Splitjaw <span style='border: 1px solid #161616; background-color: #[SKIN_COLOR_GROONN];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" = SKIN_COLOR_GROONN,
		"Blackhammer <span style='border: 1px solid #161616; background-color: #[SKIN_COLOR_BLACK_HAMMER];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" = SKIN_COLOR_BLACK_HAMMER,
		"Skullseeker <span style='border: 1px solid #161616; background-color: #[SKIN_COLOR_SKULL_SEEKER];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" = SKIN_COLOR_SKULL_SEEKER,
		"Crescent Fang <span style='border: 1px solid #161616; background-color: #[SKIN_COLOR_CRESCENT_FANG];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" = SKIN_COLOR_CRESCENT_FANG,
		"Murkwalker <span style='border: 1px solid #161616; background-color: #[SKIN_COLOR_MURKWALKER];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" = SKIN_COLOR_MURKWALKER,
		"Shatterhorn <span style='border: 1px solid #161616; background-color: #[SKIN_COLOR_SHATTERHORN];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" = SKIN_COLOR_SHATTERHORN,
		"Spirit Crusher <span style='border: 1px solid #161616; background-color: #[SKIN_COLOR_SPIRITCRUSHER];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" = SKIN_COLOR_SPIRITCRUSHER
	)

/datum/species/halforc/get_hairc_list()
	return sortList(list(
	"Minotaur" = "58433b",
	"Volf" = "48322a",
	"Maneater" = "458745",
	"Mud" = "201616",
	))

/datum/species/halforc/random_name(gender,unique,lastname)

	var/randname
	if(unique)
		if(gender == MALE)
			for(var/i in 1 to 10)
				randname = pick( world.file2list("strings/rt/names/other/halforcm.txt") )
				if(!findname(randname))
					break
		if(gender == FEMALE)
			for(var/i in 1 to 10)
				randname = pick( world.file2list("strings/rt/names/other/halforcf.txt") )
				if(!findname(randname))
					break
	else
		if(gender == MALE)
			randname = pick( world.file2list("strings/rt/names/other/halforcm.txt") )
		if(gender == FEMALE)
			randname = pick( world.file2list("strings/rt/names/other/halforcf.txt") )
	return randname

/datum/species/halforc/random_surname()
	return
