/mob/living/carbon/human/species/human/halfelf
	race = /datum/species/human/halfelf

/datum/species/human/halfelf
	name = "Half-Elf"
	id = "helf"
	desc = "<b>Half Elf</b><br>\
	The child of an Elf and Humen, Half-Elves are generally frowned \
	upon by the more conservatively minded. However, as racial tensions lower, \
	the rate of Half-Elf births has continues to increase. So common has it become that some scholars \
	worry that someday it may be impossible to distinguish the Humens and Elves from one another. \
	From physical to cultural characteristics, Half-Elves are an incredibly diverse people, \
	thanks in no small part to the incredibly varied nature of their Humen halves. Indeed, no other race \
	embodies the term \"melting pot\" quite like the Half-Elves. Due to their half-breed nature, their physical \
	characteristics can be either more Elvish or more Humen, depending on which of their parents' genes \
	are more predominant. In terms of cultural identity, a Half-Elf will typically choose to lean more \
	towards either their Humen or Elvish heritages.<br>\
	(+1 Constitution, +1 Perception)" 

	skin_tone_wording = "Identity"
	default_color = "FFFFFF"
	species_traits = list(EYECOLOR,HAIR,FACEHAIR,LIPS,STUBBLE,OLDGREY)
	inherent_traits = list(TRAIT_NOMOBSWAP)
	default_features = MANDATORY_FEATURE_LIST
	use_skintones = 1
	possible_ages = ALL_AGES_LIST
	disliked_food = NONE
	liked_food = NONE
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | RACE_SWAP | SLIME_EXTRACT
	limbs_icon_m = 'icons/roguetown/mob/bodies/m/mt.dmi'
	limbs_icon_f = 'icons/roguetown/mob/bodies/f/fm.dmi'
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
		OFFSET_FACE_F = list(0,-1), OFFSET_BELT_F = list(0,-1), OFFSET_BACK_F = list(0,-1), \
		OFFSET_NECK_F = list(0,-1), OFFSET_MOUTH_F = list(0,-1), OFFSET_PANTS_F = list(0,0), \
		OFFSET_SHIRT_F = list(0,0), OFFSET_ARMOR_F = list(0,0), OFFSET_UNDIES_F = list(0,-1), \
		)
	race_bonus = list(STAT_PERCEPTION = 1, STAT_CONSTITUTION = 1)
	enflamed_icon = "widefire"
	organs = list(
		ORGAN_SLOT_BRAIN = /obj/item/organ/brain,
		ORGAN_SLOT_HEART = /obj/item/organ/heart,
		ORGAN_SLOT_LUNGS = /obj/item/organ/lungs,
		ORGAN_SLOT_EYES = /obj/item/organ/eyes/halfelf,
		ORGAN_SLOT_EARS = /obj/item/organ/ears,
		ORGAN_SLOT_TONGUE = /obj/item/organ/tongue,
		ORGAN_SLOT_LIVER = /obj/item/organ/liver,
		ORGAN_SLOT_STOMACH = /obj/item/organ/stomach,
		ORGAN_SLOT_APPENDIX = /obj/item/organ/appendix,
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
		/datum/customizer/organ/ears/elf,
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
		/datum/body_marking/bangs,
		/datum/body_marking/bun,
	)
	languages = list(
		/datum/language/common,
		/datum/language/elvish
	)

/datum/species/human/halfelf/on_species_gain(mob/living/carbon/literally_him, datum/species/old_species)
	..()
	languages(literally_him)

/datum/species/human/halfelf/get_skin_list()
	return list(
		"Timber-Gronn" = SKIN_COLOR_TIMBER_GRONN,
		"Giza-Scarlet" = SKIN_COLOR_GIZA_SCARLET,
		"Walnut-Stine" = SKIN_COLOR_WALNUT_STINE,
		"Etrustcan-Dandelion" = SKIN_COLOR_ETRUSTCAN_DANDELION,
		"Ebon-Born" = SKIN_COLOR_EBON_BORN,
		"Kaze-Lotus" = SKIN_COLOR_KAZE_LOTUS,
		"Grenzel-Scarlet" = SKIN_COLOR_GRENZEL_WOODS,
		"Etrusca-Lirvas" = SKIN_COLOR_ETRUSCA_LIRVAS,
		"Free Roamers" = SKIN_COLOR_FREE_FOLK,
		"Avar Borne"	= SKIN_COLOR_AVAR_BORNE,
		"Shalvine Roamer" = SKIN_COLOR_SHALVINE_SCARLET,
		"Lalve-Steppes" = SKIN_COLOR_LALVE_NALEDI,
		"Ebon-Otava" = SKIN_COLOR_EBON_OTAVA,
		"Grezel-Avar" = SKIN_COLOR_GRENZEL_AVAR,
		"Hammer-Gronn" = SKIN_COLOR_HAMMER_GRONN,
		"Commorah-kin" = SKIN_COLOR_COMMORAH,
		"Gloomhaven-kin" = SKIN_COLOR_GLOOMHAVEN,
		"Darkpila-kin" = SKIN_COLOR_DARKPILA,
		"Sshanntynlan-kin" = SKIN_COLOR_SSHANNTYNLAN,
		"Llurth Dreir-kin" = SKIN_COLOR_LLURTH_DREIR,
		"Tafravma-kin" = SKIN_COLOR_TAFRAVMA,
		"Yuethindrynn-kin" = SKIN_COLOR_YUETHINDRYNN,
		"Koredynn-kin" = SKIN_COLOR_KOREDYNN,
		"Aiseedrynn-kin" = SKIN_COLOR_AISEEDRYNN,
		"Grenduskra-kin" = SKIN_COLOR_GRENDUSKRA
	)

/datum/species/human/halfelf/get_skin_list_tooltip() // tooltip to let people know the skin colors at a glance
	return list(
		"Timber-Gronn <span style='border: 1px solid #161616; background-color: #ffe0d1;'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span> <b>ffe0d1</b>" = SKIN_COLOR_TIMBER_GRONN,
		"Giza-Scarlet <span style='border: 1px solid #161616; background-color: #fcccb3;'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span> <b>fcccb3</b>" = SKIN_COLOR_GIZA_SCARLET,
		"Walnut-Stine <span style='border: 1px solid #161616; background-color: #edc6b3;'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span> <b>edc6b3</b>" = SKIN_COLOR_WALNUT_STINE,
		"Etrustcan-Dandelion <span style='border: 1px solid #161616; background-color: #e2b9a3;'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span> <b>e2b9a3</b>" = SKIN_COLOR_ETRUSTCAN_DANDELION,
		"Ebon-Born <span style='border: 1px solid #161616; background-color: #5a4a41;'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span> <b>5a4a41</b>" = SKIN_COLOR_EBON_BORN,
		"Kaze-Lotus <span style='border: 1px solid #161616; background-color: #E0D5B8;'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span> <b>E0D5B8</b>" = SKIN_COLOR_KAZE_LOTUS,
		"Grenzel-Scarlet <span style='border: 1px solid #161616; background-color: #fff0e9;'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span> <b>fff0e9</b>" = SKIN_COLOR_GRENZEL_WOODS,
		"Etrusca-Lirvas <span style='border: 1px solid #161616; background-color: #d9a284;'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span> <b>d9a284</b>" = SKIN_COLOR_ETRUSCA_LIRVAS,
		"Free Roamers <span style='border: 1px solid #161616; background-color: #c9a893;'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span> <b>c9a893</b>" = SKIN_COLOR_FREE_FOLK,
		"Avar Borne <span style='border: 1px solid #161616; background-color: #ba9882;'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span> <b>ba9882</b>" = SKIN_COLOR_AVAR_BORNE,
		"Shalvine Roamer <span style='border: 1px solid #161616; background-color: #ac8369;'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span> <b>ac8369</b>" = SKIN_COLOR_SHALVINE_SCARLET,
		"Lalve-Steppes <span style='border: 1px solid #161616; background-color: #9c6f52;'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span> <b>9c6f52</b>" = SKIN_COLOR_LALVE_NALEDI,
		"Ebon-Otava <span style='border: 1px solid #161616; background-color: #4e3729;'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span> <b>4e3729</b>" = SKIN_COLOR_EBON_OTAVA,
		"Grezel-Avar <span style='border: 1px solid #161616; background-color: #fff0e9;'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span> <b>fff0e9</b>" = SKIN_COLOR_GRENZEL_AVAR,
		"Hammer-Gronn <span style='border: 1px solid #161616; background-color: #5d4c41;'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span> <b>5d4c41</b>" = SKIN_COLOR_HAMMER_GRONN,
		"Commorah-kin <span style='border: 1px solid #161616; background-color: #9796a9;'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span> <b>9796a9</b>" = SKIN_COLOR_COMMORAH,
		"Gloomhaven-kin <span style='border: 1px solid #161616; background-color: #897489;'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span> <b>897489</b>" = SKIN_COLOR_GLOOMHAVEN,
		"Darkpila-kin <span style='border: 1px solid #161616; background-color: #938f9c;'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span> <b>938f9c</b>" = SKIN_COLOR_DARKPILA,
		"Sshanntynlan-kin <span style='border: 1px solid #161616; background-color: #737373;'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span> <b>737373</b>" = SKIN_COLOR_SSHANNTYNLAN,
		"Llurth Dreir-kin <span style='border: 1px solid #161616; background-color: #6a616d;'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span> <b>6a616d</b>" = SKIN_COLOR_LLURTH_DREIR,
		"Tafravma-kin <span style='border: 1px solid #161616; background-color: #5f5f70;'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span> <b>5f5f70</b>" = SKIN_COLOR_TAFRAVMA,
		"Yuethindrynn-kin <span style='border: 1px solid #161616; background-color: #2f2f38;'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span> <b>2f2f38</b>" = SKIN_COLOR_YUETHINDRYNN,
		"Koredynn-kin <span style='border: 1px solid #161616; background-color: #242871;'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span> <b>242871</b>" = SKIN_COLOR_KOREDYNN,
		"Aiseedrynn-kin <span style='border: 1px solid #161616; background-color: #a3c1c9;'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span> <b>a3c1c9</b>" = SKIN_COLOR_AISEEDRYNN,
		"Grenduskra-kin <span style='border: 1px solid #161616; background-color: #969696;'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span> <b>969696</b>" = SKIN_COLOR_GRENDUSKRA,
	)

/datum/species/human/halfelf/proc/languages(mob/living/carbon/human/literally_him)
	if(literally_him.skin_tone == SKIN_COLOR_EBON_BORN)
		literally_him.grant_language(/datum/language/celestial)

/datum/species/human/halfelf/get_hairc_list()
	return sortList(list(
	"black - oil" = "181a1d",
	"black - cave" = "201616",
	"black - rogue" = "2b201b",
	"black - midnight" = "1d1b2b",

	"brown - mud" = "362e25",
	"brown - oats" = "584a3b",
	"brown - grain" = "58433b",
	"brown - soil" = "48322a",

	"red - berry" = "48322a",
	"red - wine" = "82534c",
	"red - sunset" = "82462b",
	"red - blood" = "822b2b",

	"blond - pale" = "9d8d6e",
	"blond - dirty" = "88754f",
	"blond - drywheat" = "8f8766",
	"blond - strawberry" = "977033"

	))

/datum/species/human/halfelf/random_name(gender,unique,lastname)
	var/randname
	if(unique)
		if(gender == MALE)
			for(var/i in 1 to 10)
				randname = pick( world.file2list("strings/rt/names/elf/elfwm.txt") )
				if(!findname(randname))
					break
		if(gender == FEMALE)
			for(var/i in 1 to 10)
				randname = pick( world.file2list("strings/rt/names/elf/elfwf.txt") )
				if(!findname(randname))
					break
	else
		if(gender == MALE)
			randname = pick( world.file2list("strings/rt/names/elf/elfwm.txt") )
		if(gender == FEMALE)
			randname = pick( world.file2list("strings/rt/names/elf/elfwf.txt") )
	randname += " Halfelven"
	return randname

/datum/species/human/halfelf/random_surname()
	return ""

