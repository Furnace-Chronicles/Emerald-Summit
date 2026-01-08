// Who can impregnate whom
GLOBAL_LIST_INIT(species_compatibility, list(

    // =====================
    // HUMANS
    // =====================
    /datum/species/human/northern = list(
        /datum/species/human/northern,
        /datum/species/human/halfelf,
        /datum/species/demihuman,              // half-kin
        /datum/species/anthromorph,            // wild-kin
        /datum/species/elf/sun,
        /datum/species/elf/wood,
        /datum/species/elf/dark,
        /datum/species/dwarf,
        /datum/species/aasimar,
        /datum/species/akula,                  // axian
        /datum/species/anthromorphsmall,       // verminfolk
        /datum/species/dracon,
        /datum/species/lizardfolk,
        /datum/species/kobold,
        /datum/species/lamia,
        /datum/species/halforc,
        /datum/species/goblinp,
        /datum/species/ogre,
        /datum/species/harpy,
        /datum/species/tabaxi,
        /datum/species/vulpkanin,
        /datum/species/lupian,
        /datum/species/tieberian               // tiefling
    ),

    // =====================
    // HALF-KIN / WILD-KIN
    // =====================
    /datum/species/demihuman = list(
        /datum/species/demihuman,
        /datum/species/human/northern
    ),

    /datum/species/anthromorph = list(
        /datum/species/anthromorph,
        /datum/species/human/northern
    ),

    // =====================
    // ELVES
    // =====================
    /datum/species/elf/sun = list(
        /datum/species/elf/sun,
        /datum/species/elf/wood,
        /datum/species/human/northern,
        /datum/species/human/halfelf,
        /datum/species/elf/dark
    ),

    /datum/species/elf/wood = list(
        /datum/species/elf/wood,
        /datum/species/elf/sun,
        /datum/species/human/northern,
        /datum/species/human/halfelf,
        /datum/species/elf/dark
    ),

    /datum/species/elf/dark = list(
        /datum/species/elf/dark,
        /datum/species/human/northern,
        /datum/species/human/halfelf,
        /datum/species/elf/wood,
        /datum/species/elf/sun
    ),

    // =====================
    // DWARF
    // =====================
    /datum/species/dwarf = list(
        /datum/species/dwarf,
        /datum/species/human/northern
    ),

    // =====================
    // CELESTIAL / AQUATIC / SMALLFOLK
    // =====================
    /datum/species/aasimar = list(
        /datum/species/aasimar,
        /datum/species/human/northern
    ),

    /datum/species/akula = list(
        /datum/species/akula,
        /datum/species/human/northern
    ),

    /datum/species/anthromorphsmall = list(
        /datum/species/anthromorphsmall,
        /datum/species/human/northern
    ),

	// =====================
	// TIEFLING
	// =====================
	/datum/species/tieberian = list(
    	/datum/species/tieberian,
    	/datum/species/human/northern

	),

    // =====================
    // DRACONIC / REPTILIAN
    // =====================
    /datum/species/dracon = list(
        /datum/species/dracon,
        /datum/species/human/northern,
        /datum/species/lizardfolk,
        /datum/species/kobold
    ),

    /datum/species/lizardfolk = list(
        /datum/species/lizardfolk,
        /datum/species/human/northern,
        /datum/species/dracon,
        /datum/species/kobold
    ),

    /datum/species/kobold = list(
        /datum/species/kobold,
        /datum/species/human/northern,
        /datum/species/lizardfolk,
        /datum/species/dracon
    ),

    /datum/species/lamia = list(
        /datum/species/lamia,
        /datum/species/human/northern
    ),

    // =====================
    // ORC / GOBLIN
    // =====================
    /datum/species/halforc = list(
        /datum/species/halforc,
        /datum/species/goblinp,
        /datum/species/human/northern
    ),

    /datum/species/goblinp = list(
        /datum/species/goblinp,
        /datum/species/human/northern,
        /datum/species/halforc
    ),

    /datum/species/ogre = list(
        /datum/species/ogre,
        /datum/species/human/northern,
        /datum/species/halforc
    ),

    // =====================
    // BEASTFOLK
    // =====================
    /datum/species/tabaxi = list(
        /datum/species/tabaxi,
        /datum/species/human/northern,
        /datum/species/lupian,
        /datum/species/vulpkanin
    ),

    /datum/species/vulpkanin = list(
        /datum/species/vulpkanin,
        /datum/species/human/northern,
        /datum/species/lupian,
        /datum/species/tabaxi
    ),

    /datum/species/lupian = list(
        /datum/species/lupian,
        /datum/species/human/northern,
        /datum/species/vulpkanin,
        /datum/species/tabaxi
    ),

    // =====================
    // OTHERS
    // =====================
    /datum/species/harpy = list(
        /datum/species/harpy,
        /datum/species/human/northern
    ),

    // =====================
    // INFERTILE
    // =====================
    /datum/species/golem = list(),		//sorry golem players, your artifical 
    /datum/species/dullahan = list()
))
