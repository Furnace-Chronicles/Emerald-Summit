// Who can impregnate whom
GLOBAL_LIST_INIT(species_compatibility, list(

    /datum/species/human/northern = list(
        /datum/species/human/northern,
        /datum/species/human/halfelf,
        /datum/species/demihuman,
        /datum/species/anthromorph,
        /datum/species/elf/sun,
        /datum/species/elf/wood,
        /datum/species/elf/dark,
        /datum/species/dwarf,
        /datum/species/aasimar,
        /datum/species/akula,
        /datum/species/anthromorphsmall,
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
        /datum/species/tieberian
    ),

    /datum/species/elf/sun = list(
        /datum/species/elf/sun,
        /datum/species/elf/wood,
        /datum/species/human/northern
    ),

    /datum/species/elf/wood = list(
        /datum/species/elf/wood,
        /datum/species/elf/sun,
        /datum/species/human/northern,
		/datum/species/elf/dark
    ),

    /datum/species/elf/dark = list(
        /datum/species/elf/dark,
        /datum/species/elf/wood
    ),

    /datum/species/dwarf = list(
        /datum/species/dwarf,
        /datum/species/human/northern
    ),

    // INFERTILE
    /datum/species/golem = list(),
    /datum/species/dullahan = list()
))
