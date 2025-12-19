/mob/living/carbon/human/species/ogre
	race = /datum/species/ogre

/datum/species/ogre
	name = "Ogre"
	id = "ogre"
	origin_default = /datum/virtue/origin/racial/gronn
	origin = "Gronn"
	is_subrace = TRUE
	base_name = "Ogroid"
	desc = "<b>Ogres</b><br>\
	Creatures born from the labors of Graggar, Ogres are his favorite children in all creation. Massive in appetite and size they are titans of the battlefield. Maneaters who smash all who oppose their strength and take as they please from the world. Native to the windswept steppes of Gronn, they have migrated across the world in search of food and riches, as conquerors and mercenaries. Not all ogres are Graggarites, and many have converted as they are either simple minded enough to convince to convert, or cunning enough to see the benefit of adopting a new faith in a new land..<br>\
	<span style='color: #6a8cb7;text-shadow:-1px -1px 0 #000,1px -1px 0 #000,-1px 1px 0 #000,1px 1px 0 #000;'><b> +2 STR | +2 CON | | +2 END | -1 SPD</b></span> </br>\
	<span style='color: #6a8cb7;text-shadow:-1px -1px 0 #000,1px -1px 0 #000,-1px 1px 0 #000,1px 1px 0 #000;'><b> LANGUAGE: Orcish - ,o</b></span> </br>"

	skin_tone_wording = "Region"
	species_traits = list(EYECOLOR,HAIR,FACEHAIR,LIPS,STUBBLE,OLDGREY)
	inherent_traits = list(TRAIT_NOMOBSWAP)
	default_features = MANDATORY_FEATURE_LIST
	use_skintones = 1
	disliked_food = NONE
	liked_food = NONE
	possible_ages = ALL_AGES_LIST
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | RACE_SWAP | SLIME_EXTRACT
	limbs_icon_m = 'icons/roguetown/mob/bodies/m/ogre.dmi'
	limbs_icon_f = 'icons/roguetown/mob/bodies/f/ogre.dmi'
	dam_icon = 'icons/roguetown/mob/bodies/dam/ogre.dmi' //honestly super fucked & needs an entirely new sprite but it'll be fine for now, probably
	dam_icon_f = 'icons/roguetown/mob/bodies/dam/ogre.dmi' // see above
	use_m = TRUE
	soundpack_m = /datum/voicepack/male/warrior
	soundpack_f = /datum/voicepack/female/dwarf //idfk bruh
	offset_features = list(OFFSET_ID = list(0,1), OFFSET_GLOVES = list(0,0), OFFSET_WRISTS = list(0,0),\
	OFFSET_CLOAK = list(0,0), OFFSET_FACEMASK = list(0,6), OFFSET_HEAD = list(0,0), \
	OFFSET_FACE = list(0,6), OFFSET_BELT = list(0,0), OFFSET_BACK = list(0,6), \
	OFFSET_NECK = list(0,6), OFFSET_MOUTH = list(0,6), OFFSET_PANTS = list(0,0), \
	OFFSET_SHIRT = list(0,0), OFFSET_ARMOR = list(0,0), OFFSET_HANDS = list(0,0), OFFSET_UNDIES = list(0,0), \
	OFFSET_ID_F = list(0,1), OFFSET_GLOVES_F = list(0,1), OFFSET_WRISTS_F = list(0,0), OFFSET_HANDS_F = list(0,0), \
	OFFSET_CLOAK_F = list(0,0), OFFSET_FACEMASK_F = list(0,6), OFFSET_HEAD_F = list(0,0), \
	OFFSET_FACE_F = list(0,6), OFFSET_BELT_F = list(0,0), OFFSET_BACK_F = list(0,6), \
	OFFSET_NECK_F = list(0,6), OFFSET_MOUTH_F = list(0,6), OFFSET_PANTS_F = list(0,0), \
	OFFSET_SHIRT_F = list(0,0), OFFSET_ARMOR_F = list(0,0), OFFSET_UNDIES_F = list(0,-1))
	race_bonus = list(STAT_STRENGTH = 2, STAT_CONSTITUTION = 2, STAT_ENDURANCE = 1, STAT_INTELLIGENCE = -3, STAT_SPEED = -1)
	enflamed_icon = "widefire"
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
		/datum/body_marking/bigtonage,
	)
	customizers = list(
		/datum/customizer/organ/eyes/humanoid,
		/datum/customizer/bodypart_feature/hair/head/humanoid,
		/datum/customizer/bodypart_feature/hair/facial/humanoid,
		/datum/customizer/bodypart_feature/accessory,
		/datum/customizer/bodypart_feature/face_detail,
		/datum/customizer/bodypart_feature/underwear,
		/datum/customizer/bodypart_feature/legwear,
		)
	stress_examine = TRUE
	stress_desc = span_red("HOLY SHIT! AN OGRE!")
	languages = list(
		/datum/language/common,
		/datum/language/orcish
	)

/datum/species/ogre/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	RegisterSignal(C, COMSIG_MOB_SAY, PROC_REF(handle_speech), override = TRUE)

/datum/species/ogre/after_creation(mob/living/carbon/C)
	..()
	to_chat(C, "<span class='info'>I can speak Orcish with ,o before my speech.</span>")

/datum/species/ogre/on_species_loss(mob/living/carbon/C)
	. = ..()
	UnregisterSignal(C, COMSIG_MOB_SAY)

/datum/species/ogre/qualifies_for_rank(rank, list/features)
	return TRUE

/datum/species/ogre/get_skin_list()
	return list(
		"Grenzelhoft" = SKIN_COLOR_GRENZELHOFT,
		"Hammerhold" = SKIN_COLOR_HAMMERHOLD,
		"Avar" = SKIN_COLOR_AVAR,
		"Scarlet Reach" = SKIN_COLOR_SCARLET_REACH,
		"Otava" = SKIN_COLOR_OTAVA,
		"Etrusca" = SKIN_COLOR_ETRUSCA,
		"Gronn" = SKIN_COLOR_GRONN,
		"Giza" = SKIN_COLOR_GIZA,
		"Shalvistine" = SKIN_COLOR_SHALVISTINE,
		"Lalvestine" = SKIN_COLOR_LALVESTINE,
		"Ebon" = SKIN_COLOR_EBON,
		"Kazengun" = SKIN_COLOR_KAZENGUN,
		"Naledi" = SKIN_COLOR_NALEDI
	)

/datum/species/ogre/get_skin_list_tooltip()
	return list(
		"Grenzelhoft <span style='border: 1px solid #161616; background-color: #[SKIN_COLOR_GRENZELHOFT];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" = SKIN_COLOR_GRENZELHOFT,
		"Hammerhold <span style='border: 1px solid #161616; background-color: #[SKIN_COLOR_HAMMERHOLD];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" = SKIN_COLOR_HAMMERHOLD,
		"Avar <span style='border: 1px solid #161616; background-color: #[SKIN_COLOR_AVAR];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" = SKIN_COLOR_AVAR,
		"Scarlet Reach <span style='border: 1px solid #161616; background-color: #[SKIN_COLOR_SCARLET_REACH];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" = SKIN_COLOR_SCARLET_REACH,
		"Otava <span style='border: 1px solid #161616; background-color: #[SKIN_COLOR_OTAVA];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" = SKIN_COLOR_OTAVA,
		"Etrusca <span style='border: 1px solid #161616; background-color: #[SKIN_COLOR_ETRUSCA];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" = SKIN_COLOR_ETRUSCA,
		"Gronn <span style='border: 1px solid #161616; background-color: #[SKIN_COLOR_GRONN];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" = SKIN_COLOR_GRONN,
		"Giza <span style='border: 1px solid #161616; background-color: #[SKIN_COLOR_GIZA];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" = SKIN_COLOR_GIZA,
		"Shalvistine <span style='border: 1px solid #161616; background-color: #[SKIN_COLOR_SHALVISTINE];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" = SKIN_COLOR_SHALVISTINE,
		"Lalvestine <span style='border: 1px solid #161616; background-color: #[SKIN_COLOR_LALVESTINE];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" = SKIN_COLOR_LALVESTINE,
		"Ebon <span style='border: 1px solid #161616; background-color: #[SKIN_COLOR_EBON];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" = SKIN_COLOR_EBON,
		"Kazengun <span style='border: 1px solid #161616; background-color: #[SKIN_COLOR_KAZENGUN];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" = SKIN_COLOR_KAZENGUN,
		"Naledi <span style='border: 1px solid #161616; background-color: #[SKIN_COLOR_NALEDI];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" = SKIN_COLOR_NALEDI,
	)

/datum/species/ogre/check_roundstart_eligible()
	return TRUE

/datum/species/ogre/get_hairc_list()
	return sortList(list(
	"Minotaur" = "58433b",
	"Volf" = "48322a",
	"Maneater" = "458745",
	"Mud" = "201616",
	))

/datum/species/ogre/random_name(gender,unique,lastname)

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

/datum/species/ogre/random_surname()
	return
