/mob/living/carbon/human/species/elf/wood
	race = /datum/species/elf/wood

/datum/species/elf/wood
	name = "Elf"
	id = "elfw"
	psydonic = TRUE
	sub_name = "Wood Elf"
	desc = "<b>Wood Elf: Guardians of the Grove</b><br>\
	In the creation of Enigma, Abyssor and Dendor were tasked with making its creatures and lands. \
	Dendor wanted appreciation for his works, and he made the first race of the world, and the elves looked upon the wilds and praised him. \
	Typically living 500 years they would carefully protect his sacred groves, \
	which have become the only wilds untainted by the corruption of a sickened mind. Many elves mourn Dendor but still believe he can be healed, \
	feverishly protecting the groves and keeping their locations secret. At times they leave for the cities, even siring children with humans.<br>\
	<span style='color: #6a8cb7;text-shadow:-1px -1px 0 #000,1px -1px 0 #000,-1px 1px 0 #000,1px 1px 0 #000;'><b> +1 SPD</b></span> </br>\
	<span style='color: #6a8cb7;text-shadow:-1px -1px 0 #000,1px -1px 0 #000,-1px 1px 0 #000,1px 1px 0 #000;'><b> LANGUAGE: Elvish - ,e</b></span> </br>"

	skin_tone_wording = "Tribal Identity"

	default_color = "FFFFFF"
	species_traits = list(EYECOLOR,HAIR,FACEHAIR,LIPS,OLDGREY)
	default_features = MANDATORY_FEATURE_LIST
	use_skintones = 1
	disliked_food = NONE
	liked_food = NONE
	possible_ages = ALL_AGES_LIST
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | RACE_SWAP | SLIME_EXTRACT
	limbs_icon_m = 'icons/roguetown/mob/bodies/m/wood_elf.dmi'
	limbs_icon_f = 'icons/roguetown/mob/bodies/f/human.dmi'
	dam_icon = 'icons/roguetown/mob/bodies/dam/dam_male.dmi'
	dam_icon_f = 'icons/roguetown/mob/bodies/dam/dam_female.dmi'
	use_f = TRUE
	soundpack_m = /datum/voicepack/male/elf
	soundpack_f = /datum/voicepack/female/elf
	offset_features = list(
		OFFSET_ID = list(0,2), OFFSET_GLOVES = list(0,0), OFFSET_WRISTS = list(0,1),\
		OFFSET_CLOAK = list(0,2), OFFSET_FACEMASK = list(0,1), OFFSET_HEAD = list(0,1), \
		OFFSET_FACE = list(0,1), OFFSET_BELT = list(0,1), OFFSET_BACK = list(0,2), \
		OFFSET_NECK = list(0,1), OFFSET_MOUTH = list(0,2), OFFSET_PANTS = list(0,2), \
		OFFSET_SHIRT = list(0,2), OFFSET_ARMOR = list(0,2), OFFSET_HANDS = list(0,2), OFFSET_UNDIES = list(0,0), \
		OFFSET_ID_F = list(0,-1), OFFSET_GLOVES_F = list(0,0), OFFSET_WRISTS_F = list(0,0), OFFSET_HANDS_F = list(0,0), \
		OFFSET_CLOAK_F = list(0,0), OFFSET_FACEMASK_F = list(0,-1), OFFSET_HEAD_F = list(0,-1), \
		OFFSET_FACE_F = list(0,-1), OFFSET_BELT_F = list(0,0), OFFSET_BACK_F = list(0,-1), \
		OFFSET_NECK_F = list(0,-1), OFFSET_MOUTH_F = list(0,-1), OFFSET_PANTS_F = list(0,0), \
		OFFSET_SHIRT_F = list(0,0), OFFSET_ARMOR_F = list(0,0), OFFSET_UNDIES_F = list(0,-1), \
		)
	race_bonus = list(STAT_SPEED = 1)
	enflamed_icon = "widefire"
	organs = list(
		ORGAN_SLOT_BRAIN = /obj/item/organ/brain,
		ORGAN_SLOT_HEART = /obj/item/organ/heart,
		ORGAN_SLOT_LUNGS = /obj/item/organ/lungs,
		ORGAN_SLOT_EYES = /obj/item/organ/eyes,
		ORGAN_SLOT_EARS = /obj/item/organ/ears/elfw,
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
		/datum/customizer/bodypart_feature/legwear,
		/datum/customizer/organ/ears/elf,
		/datum/customizer/organ/testicles/anthro,
		/datum/customizer/organ/penis/anthro,
		/datum/customizer/organ/breasts/human,
		/datum/customizer/organ/vagina/human_anthro,
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
		/datum/body_marking/nose,
		/datum/body_marking/bangs,
		/datum/body_marking/bun,
	)
/datum/species/elf/wood/get_span_language(datum/language/message_language)
	if(!message_language)
		return
//	if(message_language.type == /datum/language/elvish)
//		return list(SPAN_SELF)
//	if(message_language.type == /datum/language/common)
//		return list(SPAN_SELF)
	return message_language.spans

/datum/species/elf/wood/get_skin_list()
	return list(
		"Ghost" = SKIN_COLOR_GHOST,
		"Grenzel Woods" = SKIN_COLOR_GRENZEL_WOODS,
		"Dandelion Creek" = SKIN_COLOR_DANDELION_CREEK,
		"Roseveil" = SKIN_COLOR_ROSEVEIL,
		"Scarletgrove" = SKIN_COLOR_SCARLETGROVE,
		"Arborshome" = SKIN_COLOR_ARBORSHOME,
		"Almondvalle" = SKIN_COLOR_ALMONDVALLE,
		"Walnut Woods" = SKIN_COLOR_WALNUT_WOODS,
		"Timberborn" = SKIN_COLOR_TIMBERBORN,
		"Lotus Coast" = SKIN_COLOR_LOTUS_COAST,
		"Etruscan Swamps" = SKIN_COLOR_ETRUSCAN_SWAMPS,
		"Shalvine Forests" = SKIN_COLOR_SHALVINE_FORESTS,
		"Lalvestine Thickets" = SKIN_COLOR_LALVE_STEPPES,
		"Ebon Coverts" = SKIN_COLOR_EBON_COAST
	)

/datum/species/elf/wood/get_skin_list_tooltip()
	return list(
		"Ghost <span style='border: 1px solid #161616; background-color: #[SKIN_COLOR_GHOST];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" = SKIN_COLOR_GHOST,
		"Grenzel Woods <span style='border: 1px solid #161616; background-color: #[SKIN_COLOR_GRENZEL_WOODS];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" = SKIN_COLOR_GRENZEL_WOODS,
		"Dandelion Creek <span style='border: 1px solid #161616; background-color: #[SKIN_COLOR_DANDELION_CREEK];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" = SKIN_COLOR_DANDELION_CREEK,
		"Roseveil <span style='border: 1px solid #161616; background-color: #[SKIN_COLOR_ROSEVEIL];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" = SKIN_COLOR_ROSEVEIL,
		"Scarletgrove <span style='border: 1px solid #161616; background-color: #[SKIN_COLOR_SCARLETGROVE];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" = SKIN_COLOR_SCARLETGROVE,
		"Arborshome <span style='border: 1px solid #161616; background-color: #[SKIN_COLOR_ARBORSHOME];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" = SKIN_COLOR_ARBORSHOME,
		"Almondvalle <span style='border: 1px solid #161616; background-color: #[SKIN_COLOR_ALMONDVALLE];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" = SKIN_COLOR_ALMONDVALLE,
		"Walnut Woods <span style='border: 1px solid #161616; background-color: #[SKIN_COLOR_WALNUT_WOODS];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" = SKIN_COLOR_WALNUT_WOODS,
		"Timberborn <span style='border: 1px solid #161616; background-color: #[SKIN_COLOR_TIMBERBORN];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" = SKIN_COLOR_TIMBERBORN,
		"Lotus Coast <span style='border: 1px solid #161616; background-color: #[SKIN_COLOR_LOTUS_COAST];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" = SKIN_COLOR_LOTUS_COAST,
		"Etruscan Swamps <span style='border: 1px solid #161616; background-color: #[SKIN_COLOR_ETRUSCAN_SWAMPS];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" = SKIN_COLOR_ETRUSCAN_SWAMPS,
		"Shalvine Forests <span style='border: 1px solid #161616; background-color: #[SKIN_COLOR_SHALVINE_FORESTS];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" = SKIN_COLOR_SHALVINE_FORESTS,
		"Lalvestine Thickets <span style='border: 1px solid #161616; background-color: #[SKIN_COLOR_LALVE_STEPPES];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" = SKIN_COLOR_LALVE_STEPPES,
		"Ebon Coverts <span style='border: 1px solid #161616; background-color: #[SKIN_COLOR_EBON_COAST];'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>" = SKIN_COLOR_EBON_COAST,
	)

/datum/species/elf/wood/get_hairc_list()
	return sortList(list(
	"black - oil" = "181a1d",
	"black - cave" = "201616",
	"black - rogue" = "2b201b",
	"black - midnight" = "1d1b2b",

	"blond - pale" = "9d8d6e",
	"blond - dirty" = "88754f",
	"blond - drywheat" = "d5ba7b",
	"blond - strawberry" = "c69b71",

	"white - snow" = "dee9ed",
	"white - ice" = "f4f4f4",

	"brown - mud" = "362e25",
	"brown - oats" = "584a3b",
	"brown - grain" = "58433b",
	"brown - soil" = "48322a",

	"red - berry" = "48322a",
	"red - wine" = "82534c",
	"red - sunset" = "82462b",
	"red - blood" = "822b2b",

	"green - grass" = "2a482c",
	"green - swamp" = "3b482a",
	"green - leaf" = "2f3c2e",
	"green - moss" = "3b3c2a"

	))

/datum/species/elf/wood/random_name(gender,unique,lastname)

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
	return randname

/datum/species/elf/wood/random_surname()
	return " [pick(world.file2list("strings/rt/names/elf/elfwlast.txt"))]"
