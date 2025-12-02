/*------------------------\
| ARMOR INTEGRITY DEFINES | // Use these when possible on armor to keep value consistent.
\------------------------*/
// Side = Non-chest armor integrity
// For now. Steel vs Iron will be a difference of 75% integrity without rating differences.
// So Iron will actually be pretty decent and there shouldn't be a compulsive need to upgrade.

// Helmet
#define ARMOR_INT_HELMET_ANTAG 600
#define ARMOR_INT_HELMET_BLACKSTEEL 500
#define ARMOR_INT_HELMET_HEAVY_STEEL 400
#define ARMOR_INT_HELMET_HEAVY_IRON 300
#define ARMOR_INT_HELMET_HEAVY_DECREPIT 200
#define ARMOR_INT_HELMET_HEAVY_ADJUSTABLE_PENALTY 50 // Integrity reduction, if a helmet is adjustable
#define ARMOR_INT_HELMET_STEEL 300
#define ARMOR_INT_HELMET_IRON 225
#define ARMOR_INT_HELMET_HARDLEATHER 250
#define ARMOR_INT_HELMET_LEATHER 200
#define ARMOR_INT_HELMET_CLOTH 100

// Chest / Armor Pieces

// HEAVY
#define ARMOR_INT_CHEST_PLATE_ANTAG 700
#define ARMOR_INT_CHEST_PLATE_BLACKSTEEL 600
#define ARMOR_INT_CHEST_PLATE_STEEL 500
#define ARMOR_INT_CHEST_PLATE_BRIGANDINE 350
#define ARMOR_INT_CHEST_PLATE_PSYDON 400 // You get free training, less int
#define ARMOR_INT_CHEST_PLATE_IRON 375
#define ARMOR_INT_CHEST_PLATE_DECREPIT 250

// MEDIUM
#define ARMOR_INT_CHEST_MEDIUM_STEEL 300
#define ARMOR_INT_CHEST_MEDIUM_IRON 225
#define ARMOR_INT_CHEST_MEDIUM_SCALE 200 // More coverage, less integrity
#define ARMOR_INT_CHEST_MEDIUM_DECREPIT 150

// LIGHT
#define ARMOR_INT_CHEST_LIGHT_MASTER 300 // High tier cloth / leather armor
#define ARMOR_INT_CHEST_LIGHT_MEDIUM 250 // Medium tier cloth / leather armor
#define ARMOR_INT_CHEST_LIGHT_BASE 200
#define ARMOR_INT_CHEST_LIGHT_STEEL 180
#define ARMOR_INT_CHEST_CIVILIAN 100

// LEG PIECES - Leg Armor
#define ARMOR_INT_LEG_ANTAG 600
#define ARMOR_INT_LEG_BLACKSTEEL 500
#define ARMOR_INT_LEG_STEEL_PLATE 400
#define ARMOR_INT_LEG_IRON_PLATE 300
#define ARMOR_INT_LEG_DECREPIT_PLATE 200
#define ARMOR_INT_LEG_STEEL_CHAIN 300
#define ARMOR_INT_LEG_BRIGANDINE 250 // Iron grade but whatever.
#define ARMOR_INT_LEG_IRON_CHAIN 225
#define ARMOR_INT_LEG_DECREPIT_CHAIN 150
#define ARMOR_INT_LEG_HARDLEATHER 250
#define ARMOR_INT_LEG_LEATHER 200
#define ARMOR_INT_LEG_CLOTH 10

// SIDE PIECES - Non-Chest armor
#define ARMOR_INT_SIDE_ANTAG 500 // Integrity for antag pieces
#define ARMOR_INT_SIDE_BLACKSTEEL 400 // Integrity for blacksteel pieces
#define ARMOR_INT_SIDE_STEEL 300 // Integrity for steel pieces
#define ARMOR_INT_SIDE_IRON 225 // Integrity for iron pieces
#define ARMOR_INT_SIDE_HARDLEATHER 250 // Integrity for hardened leather pieces
#define ARMOR_INT_SIDE_LEATHER 200 // Integrity for leather / copper pieces
#define ARMOR_INT_SIDE_DECREPIT 150 // Integrity for decrepit pieces
#define ARMOR_INT_SIDE_CLOTH 100 // Integrity for cloth / aesthetic oriented pieces


/*--------------------\
| ARMOR VALUE DEFINES |
\--------------------*/
// Misc defines. These are here just in case. Inherited by their relevant subtypes.
#define ARMOR_MACHINERY list("blunt" = 25, "slash" = 25, "stab" = 25,  "piercing" = 10, "fire" = 50, "acid" = 70)
#define ARMOR_STRUCTURE list("blunt" = 0, "slash" = 0, "stab" = 0, "piercing" = 0, "fire" = 50, "acid" = 50)
#define ARMOR_DISPLAYCASE list("blunt" = 30, "slash" = 30, "stab" = 30,  "piercing" = 0, "fire" = 70, "acid" = 100)
#define ARMOR_CLOSET list("blunt" = 20, "slash" = 10, "stab" = 15, "piercing" = 10, "fire" = 70, "acid" = 60)
#define ARMOR_BLACKBAG list("blunt" = 100, "slash" = 100, "stab" = 100, "piercing" = 100, "fire" = 75, "acid" = 100)

// Light AC | Chest
#define ARMOR_CLOTHING list("blunt" = 0, "slash" = 10, "stab" = 20, "piercing" = 0, "fire" = 0, "acid" = 0)
#define ARMOR_PADDED_GOOD list("blunt" = 80, "slash" = 50, "stab" = 50, "piercing" = 80, "fire" = 0, "acid" = 0)
#define ARMOR_PADDED list("blunt" = 60, "slash" = 40, "stab" = 30, "piercing" = 50, "fire" = 0, "acid" = 0)
#define ARMOR_PADDED_BAD list("blunt" = 40, "slash" = 30, "stab" = 20, "piercing" = 40, "fire" = 0, "acid" = 0)
#define ARMOR_LIGHTCUIRASS list("blunt" = 30, "slash" = 70, "stab" = 70, "piercing" = 30, "fire" = 0, "acid" = 0)

#define ARMOR_LEATHER list("blunt" = 60, "slash" = 50, "stab" = 40, "piercing" = 20, "fire" = 0, "acid" = 0)
#define ARMOR_LEATHER_GOOD list("blunt" = 100, "slash" = 70, "stab" = 50, "piercing" = 30, "fire" = 0, "acid" = 0)
#define ARMOR_LEATHER_STUDDED list("blunt" = 80, "slash" = 80, "stab" = 60, "piercing" = 20, "fire" = 0, "acid" = 0)

// Medium AC | Chest
#define ARMOR_CUIRASS list("blunt" = 40, "slash" = 100, "stab" = 80, "piercing" = 60, "fire" = 0, "acid" = 0)
#define ARMOR_MAILLE list("blunt" = 40, "slash" = 100, "stab" = 80, "piercing" = 50, "fire" = 0, "acid" = 0)

// Heavy AC | Chest
#define ARMOR_PLATE list("blunt" = 10, "slash" = 100, "stab" = 80, "piercing" = 75, "fire" = 0, "acid" = 0)
#define ARMOR_PLATE_GOOD list("blunt" = 50, "slash" = 100, "stab" = 80, "piercing" = 80, "fire" = 0, "acid" = 0)
#define ARMOR_PLATE_BSTEEL list("blunt" = 80, "slash" = 100, "stab" = 90, "piercing" = 80, "fire" = 0, "acid" = 0) // It's EVIL. OH GOD.

// Boot Armor
#define ARMOR_BOOTS_PLATED list("blunt" = 10, "slash" = 100, "stab" = 80, "piercing" = 75, "fire" = 0, "acid" = 0)
#define ARMOR_BOOTS_PLATED_IRON list("blunt" = 10, "slash" = 100, "stab" = 70, "piercing" = 50, "fire" = 0, "acid" = 0)
#define ARMOR_BOOTS_BAD list("blunt" = 30, "slash" = 10, "stab" = 20, "piercing" = 0, "fire" = 0, "acid" = 0)
#define ARMOR_BOOTS list("blunt" = 30, "slash" = 40, "stab" = 60, "piercing" = 20, "fire" = 0, "acid" = 0)

// Glove Armor
#define ARMOR_GLOVES_LEATHER list("blunt" = 60, "slash" = 10, "stab" = 20, "piercing" = 0, "fire" = 0, "acid" = 0)
#define ARMOR_GLOVES_LEATHER_GOOD list("blunt" = 60, "slash" = 25, "stab" = 40, "piercing" = 20, "fire" = 0, "acid" = 0)
#define ARMOR_GLOVES_CHAIN list("blunt" = 20, "slash" = 100, "stab" = 60, "piercing" = 50, "fire" = 0, "acid" = 0)
#define ARMOR_GLOVES_PLATE list("blunt" = 5, "slash" = 100, "stab" = 80, "piercing" = 75, "fire" = 0, "acid" = 0)
#define ARMOR_GLOVES_PLATE_GOOD list("blunt" = 20, "slash" = 100, "stab" = 80, "piercing" = 85, "fire" = 0, "acid" = 0)

//  Head Armor
#define ARMOR_HEAD_CLOTHING list("blunt" = 0, "slash" = 20, "stab" = 20, "piercing" = 0, "fire" = 0, "acid" = 0)
#define ARMOR_HEAD_BAD list("blunt" = 50, "slash" = 20, "stab" = 30, "piercing" = 10, "fire" = 0, "acid" = 0)
#define ARMOR_HEAD_HELMET_BAD list("blunt" = 50, "slash" = 50, "stab" = 50, "piercing" = 20, "fire" = 0, "acid" = 0)
#define ARMOR_HEAD_HELMET list("blunt" = 50, "slash" = 100, "stab" = 80, "piercing" = 60, "fire" = 0, "acid" = 0)
#define ARMOR_HEAD_HELMET_VISOR list("blunt" = 40, "slash" = 100, "stab" = 80, "piercing" = 65, "fire" = 0, "acid" = 0)
#define ARMOR_HEAD_PSYDON list("blunt" = 70, "slash" = 70, "stab" = 50, "piercing" = 30, "fire" = 0, "acid" = 0)	//Yeah they just have their own thing going on.
#define ARMOR_HEAD_LEATHER list("blunt" = 90, "slash" = 60, "stab" = 30, "piercing" = 20, "fire" = 0, "acid" = 0)

// Mask Armor
#define ARMOR_MASK_EYEPATCH list("blunt" = 5, "slash" = 10, "stab" = 5, "piercing" = 2, "fire" = 0, "acid" = 0)
#define ARMOR_MASK_METAL_BAD list("blunt" = 50, "slash" = 50, "stab" = 50, "piercing" = 50, "fire" = 0, "acid" = 0)
#define ARMOR_MASK_METAL list("blunt" = 50, "slash" = 100, "stab" = 80, "piercing" = 50, "fire" = 0, "acid" = 0)

// Neck Armor
#define ARMOR_BEVOR list("blunt" = 20, "slash" = 100, "stab" = 80, "piercing" = 70, "fire" = 0, "acid" = 0)
#define ARMOR_GORGET list("blunt" = 40, "slash" = 100, "stab" = 80, "piercing" = 50, "fire" = 0, "acid" = 0)
#define ARMOR_NECK_BAD list("blunt" = 50, "slash" = 50, "stab" = 40, "piercing" = 20, "fire" = 0, "acid" = 0)

//Pants Armor
#define ARMOR_PANTS_LEATHER list("blunt" = 80, "slash" = 50, "stab" = 40, "piercing" = 10, "fire" = 0, "acid" = 0)
#define ARMOR_PANTS_CHAIN list("blunt" = 40, "slash" = 100, "stab" = 80, "piercing" = 50, "fire" = 0, "acid" = 0)
#define ARMOR_PANTS_BRIGANDINE list("blunt" = 40, "slash" = 70, "stab" = 70, "piercing" = 50, "fire" = 0, "acid" = 0)

//Antag / Special / Unique armor defines
#define ARMOR_VAMP list("blunt" = 100, "slash" = 100, "stab" = 90, "piercing" = 80, "fire" = 0, "acid" = 0)
#define ARMOR_WWOLF list("blunt" = 100, "slash" = 90, "stab" = 80, "piercing" = 70, "fire" = 40, "acid" = 0)
#define ARMOR_DRAGONSCALE list("blunt" = 100, "slash" = 100, "stab" = 100, "fire" = 50, "acid" = 0)
#define ARMOR_ASCENDANT list("blunt" = 50, "slash" = 100, "stab" = 80, "piercing" = 80, "fire" = 0, "acid" = 0)
#define ARMOR_SPELLSINGER list("blunt" = 70, "slash" = 70, "stab" = 50, "piercing" = 30, "fire" = 0, "acid" = 0)
#define ARMOR_GRUDGEBEARER list("blunt" = 40, "slash" = 200, "stab" = 200, "piercing" = 100, "fire" = 0, "acid" = 0)
#define ARMOR_ZIZOCONCSTRUCT list("blunt" = 60, "slash" = 70, "stab" = 70, "piercing" = 60, "fire" = 40, "acid" = 10)

// Weapon balance defines
#define WBALANCE_NORMAL 0
#define WBALANCE_HEAVY -1
#define WBALANCE_SWIFT 1

//Coverage defines
#define COVERAGE_HEAD_NOSE		( HEAD | HAIR | EARS | NOSE )
#define COVERAGE_HEAD			( HEAD | HAIR | EARS )
#define COVERAGE_NASAL			( HEAD | HAIR | NOSE )
#define COVERAGE_SKULL			( HEAD | HAIR )

#define COVERAGE_VEST			( CHEST | VITALS )
#define COVERAGE_SHIRT			( CHEST | VITALS | ARMS )
#define COVERAGE_TORSO			( CHEST | GROIN | VITALS )
#define COVERAGE_ALL_BUT_ARMS	( CHEST | GROIN | VITALS | LEGS )
#define COVERAGE_ALL_BUT_LEGS	( CHEST | GROIN | VITALS | ARMS )
#define COVERAGE_FULL			( CHEST | GROIN | VITALS | LEGS | ARMS )

#define COVERAGE_PANTS			( GROIN | LEGS )
#define COVERAGE_FULL_LEG		( LEGS | FEET )

/*
Balloon Alert / Floating Text defines
*/
#define XP_SHOW_COOLDOWN (0.5 SECONDS)

//used in various places
#define ALL_RACES_TYPES list(\
	/datum/species/human/northern,\
	/datum/species/human/halfelf,\
	/datum/species/elf/dark,\
	/datum/species/elf/wood,\
	/datum/species/dwarf/mountain,\
	/datum/species/tieberian,\
	/datum/species/aasimar,\
	/datum/species/lizardfolk,\
	/datum/species/lupian,\
	/datum/species/tabaxi,\
	/datum/species/vulpkanin,\
	/datum/species/akula,\
	/datum/species/moth,\
	/datum/species/dracon,\
	/datum/species/anthromorph,\
	/datum/species/demihuman,\
	/datum/species/halforc,\
	/datum/species/kobold,\
	/datum/species/goblinp,\
	/datum/species/dullahan,\
	/datum/species/lamia,\
	/datum/species/harpy,\
)

#define RACES_NOBILITY_ELIGIBLE \
    /datum/species/human/northern,\
    /datum/species/elf/wood,\
    /datum/species/human/halfelf,\
    /datum/species/demihuman,\
    /datum/species/dwarf/mountain,\

#define RACES_CHURCH_FAVORED \
	/datum/species/aasimar,\

#define RACES_APPOINTED_OUTCASTS \
    /datum/species/tieberian,\
    /datum/species/elf/dark,\

#define RACES_MANMADE \
	/datum/species/golem/metal,\
	/datum/species/golem/porcelain,\

#define RACES_WILDKIN \
	/datum/species/anthromorph,\
	/datum/species/harpy,\

#define RACES_SECOND_CLASS \
    /datum/species/vulpkanin,\
    /datum/species/lupian,\
    /datum/species/moth,\
    /datum/species/anthromorph,\
    /datum/species/anthromorphsmall,\
    /datum/species/tabaxi,\
    /datum/species/lizardfolk,\
    /datum/species/dracon,\
    /datum/species/akula,\
	/datum/species/lamia,\
	/datum/species/harpy,\

#define RACES_FEARED \
	/datum/species/halforc,\

#define RACES_WIDELY_REVILED \
    /datum/species/kobold,\
    /datum/species/goblinp,\
    /datum/species/anthromorphsmall,\
  	/datum/species/dullahan,\
	/datum/species/lamia,\


#define RACES_NOBILITY_ELIGIBLE_UP list(RACES_NOBILITY_ELIGIBLE)

#define RACES_CHURCH_FAVORED_UP list(RACES_NOBILITY_ELIGIBLE, RACES_CHURCH_FAVORED)

#define RACES_CHURCH_FAVORED_UP_PLUS_WILDKIN list(RACES_NOBILITY_ELIGIBLE, RACES_CHURCH_FAVORED, RACES_WILDKIN)

#define RACES_INQUISITOR list(RACES_NOBILITY_ELIGIBLE, RACES_CHURCH_FAVORED, /datum/species/elf/dark)

#define RACES_ABSOLVER list(RACES_NOBILITY_ELIGIBLE, RACES_CHURCH_FAVORED, RACES_WILDKIN, /datum/species/elf/dark)

#define RACES_APPOINTED_OUTCASTS_UP list(RACES_NOBILITY_ELIGIBLE, RACES_CHURCH_FAVORED, RACES_APPOINTED_OUTCASTS)

#define RACES_MANMADE_UP list(RACES_NOBILITY_ELIGIBLE, RACES_CHURCH_FAVORED, RACES_APPOINTED_OUTCASTS, RACES_MANMADE)

#define RACES_SECOND_CLASS_UP list(RACES_NOBILITY_ELIGIBLE, RACES_CHURCH_FAVORED, RACES_APPOINTED_OUTCASTS, RACES_MANMADE, RACES_SECOND_CLASS)

#define RACES_SECOND_CLASS_NO_GOLEM list(RACES_NOBILITY_ELIGIBLE, RACES_CHURCH_FAVORED, RACES_APPOINTED_OUTCASTS, RACES_SECOND_CLASS)

#define RACES_FEARED_UP list(RACES_NOBILITY_ELIGIBLE, RACES_CHURCH_FAVORED, RACES_APPOINTED_OUTCASTS, RACES_MANMADE, RACES_SECOND_CLASS, RACES_FEARED)

#define RACES_ALL_KINDS list(RACES_NOBILITY_ELIGIBLE, RACES_CHURCH_FAVORED, RACES_APPOINTED_OUTCASTS, RACES_MANMADE, RACES_SECOND_CLASS, RACES_FEARED, RACES_WIDELY_REVILED)

#define RACES_NO_GOLEM list(RACES_NOBILITY_ELIGIBLE, RACES_CHURCH_FAVORED, RACES_APPOINTED_OUTCASTS, RACES_SECOND_CLASS, RACES_FEARED, RACES_WIDELY_REVILED)

#define NOBLE_RACES_TYPES list(\
	/datum/species/human/northern,\
	/datum/species/human/halfelf,\
	/datum/species/elf/dark,\
	/datum/species/elf/wood,\
	/datum/species/dwarf/mountain,\
	/datum/species/tieberian,\
	/datum/species/aasimar,\
	/datum/species/lizardfolk,\
	/datum/species/lupian,\
	/datum/species/tabaxi,\
	/datum/species/vulpkanin,\
	/datum/species/akula,\
	/datum/species/moth,\
	/datum/species/dracon,\
	/datum/species/anthromorph,\
	/datum/species/anthromorphsmall,\
	/datum/species/demihuman,\
	/datum/species/kobold,\
	/datum/species/goblinp,\
	/datum/species/golem/metal,\
	/datum/species/golem/porcelain,\
	/datum/species/dullahan,\
	/datum/species/lamia,\
	/datum/species/harpy,\
)

#define CLOTHED_RACES_TYPES list(\
	/datum/species/human/northern,\
	/datum/species/human/halfelf,\
	/datum/species/elf/dark,\
	/datum/species/elf/wood,\
	/datum/species/dwarf/mountain,\
	/datum/species/tieberian,\
	/datum/species/aasimar,\
	/datum/species/lizardfolk,\
	/datum/species/lupian,\
	/datum/species/tabaxi,\
	/datum/species/vulpkanin,\
	/datum/species/akula,\
	/datum/species/moth,\
	/datum/species/dracon,\
	/datum/species/anthromorph,\
	/datum/species/anthromorphsmall,\
	/datum/species/demihuman,\
	/datum/species/halforc,\
	/datum/species/kobold,\
	/datum/species/goblinp,\
	/datum/species/golem/metal,\
	/datum/species/golem/porcelain,\
	/datum/species/dullahan,\
	/datum/species/lamia,\
	/datum/species/harpy,\
)

// they usually share the same clothing sprites, so like.... BRAH...
#define SHORT_RACE_TYPES list(\
	/datum/species/dwarf/mountain,\
	/datum/species/anthromorphsmall,\
	/datum/species/kobold,\
	/datum/species/goblinp,\
)

// Non-dwarf non-kobold non-goblin mostly
#define NON_DWARVEN_RACE_TYPES list(\
	/datum/species/human/northern,\
	/datum/species/human/halfelf,\
	/datum/species/elf/dark,\
	/datum/species/elf/wood,\
	/datum/species/tieberian,\
	/datum/species/aasimar,\
	/datum/species/lizardfolk,\
	/datum/species/lupian,\
	/datum/species/tabaxi,\
	/datum/species/vulpkanin,\
	/datum/species/akula,\
	/datum/species/moth,\
	/datum/species/dracon,\
	/datum/species/anthromorph,\
	/datum/species/demihuman,\
	/datum/species/halforc,\
	/datum/species/golem/metal,\
	/datum/species/golem/porcelain,\
	/datum/species/dullahan,\
	/datum/species/lamia,\
	/datum/species/harpy,\
)

#define NON_DWARVEN_NON_GOLEM_RACE_TYPES list(\
	/datum/species/human/northern,\
	/datum/species/human/halfelf,\
	/datum/species/elf/dark,\
	/datum/species/elf/wood,\
	/datum/species/tieberian,\
	/datum/species/aasimar,\
	/datum/species/lizardfolk,\
	/datum/species/lupian,\
	/datum/species/tabaxi,\
	/datum/species/vulpkanin,\
	/datum/species/akula,\
	/datum/species/moth,\
	/datum/species/dracon,\
	/datum/species/anthromorph,\
	/datum/species/demihuman,\
	/datum/species/halforc,\
	/datum/species/dullahan,\
	/datum/species/lamia,\
	/datum/species/harpy,\
)

// Non-elf non-dwarf non-kobold non-goblin mostly
#define HUMANLIKE_RACE_TYPES list(\
	/datum/species/human/northern,\
	/datum/species/tieberian,\
	/datum/species/aasimar,\
	/datum/species/lizardfolk,\
	/datum/species/lupian,\
	/datum/species/tabaxi,\
	/datum/species/vulpkanin,\
	/datum/species/akula,\
	/datum/species/moth,\
	/datum/species/dracon,\
	/datum/species/anthromorph,\
	/datum/species/demihuman,\
	/datum/species/golem/metal,\
	/datum/species/golem/porcelain,\
	/datum/species/dullahan,\
	/datum/species/lamia,\
	/datum/species/harpy,\
)
#define ALL_CLERIC_PATRONS list(/datum/patron/divine/astrata, /datum/patron/divine/noc, /datum/patron/divine/dendor, /datum/patron/divine/necra, /datum/patron/divine/pestra, /datum/patron/divine/ravox, /datum/patron/divine/malum, /datum/patron/divine/eora) // Currently unused.

#define ALL_PALADIN_PATRONS list(/datum/patron/divine/astrata, /datum/patron/divine/noc, /datum/patron/divine/abyssor, /datum/patron/divine/dendor, /datum/patron/divine/necra, /datum/patron/divine/pestra, /datum/patron/divine/ravox, /datum/patron/divine/malum, /datum/patron/divine/eora, /datum/patron/divine/xylix, /datum/patron/old_god) // Currently unused.

#define ALL_ACOLYTE_PATRONS list(/datum/patron/divine/astrata, /datum/patron/divine/noc, /datum/patron/divine/dendor, /datum/patron/divine/pestra, /datum/patron/divine/ravox, /datum/patron/divine/eora, /datum/patron/divine/xylix, /datum/patron/divine/necra, /datum/patron/divine/abyssor, /datum/patron/divine/malum) // Currently unused.

#define ALL_DIVINE_PATRONS list(/datum/patron/divine/astrata, /datum/patron/divine/noc, /datum/patron/divine/dendor, /datum/patron/divine/abyssor, /datum/patron/divine/ravox, /datum/patron/divine/necra, /datum/patron/divine/xylix, /datum/patron/divine/pestra, /datum/patron/divine/malum, /datum/patron/divine/eora)

#define ALL_INHUMEN_PATRONS list(/datum/patron/inhumen/zizo, /datum/patron/inhumen/graggar, /datum/patron/inhumen/matthios, /datum/patron/inhumen/baotha)

#define NON_PSYDON_PATRONS list(/datum/patron/divine/astrata, /datum/patron/divine/noc, /datum/patron/divine/dendor, /datum/patron/divine/abyssor, /datum/patron/divine/ravox, /datum/patron/divine/necra, /datum/patron/divine/xylix, /datum/patron/divine/pestra, /datum/patron/divine/malum, /datum/patron/divine/eora, /datum/patron/inhumen/zizo, /datum/patron/inhumen/graggar, /datum/patron/inhumen/matthios, /datum/patron/inhumen/baotha)	//For lord/heir usage

#define ALL_PATRONS  list(/datum/patron/divine/astrata, /datum/patron/divine/noc, /datum/patron/divine/dendor, /datum/patron/divine/abyssor, /datum/patron/divine/ravox, /datum/patron/divine/necra, /datum/patron/divine/xylix, /datum/patron/divine/pestra, /datum/patron/divine/malum, /datum/patron/divine/eora, /datum/patron/old_god, /datum/patron/inhumen/zizo, /datum/patron/inhumen/graggar, /datum/patron/inhumen/matthios, /datum/patron/inhumen/baotha)

#define PLATEHIT "plate"
#define CHAINHIT "chain"
#define SOFTHIT "soft"
#define SOFTUNDERHIT "softunder" // This is just for the soft underarmors like gambesons and arming jackets so they can be worn with light armors that use the same sound like studded leather

/proc/get_armor_sound(blocksound, blade_dulling)
	switch(blocksound)
		if(PLATEHIT)
			if(blade_dulling == BCLASS_CUT||blade_dulling == BCLASS_CHOP)
				return pick('sound/combat/hits/armor/plate_slashed (1).ogg','sound/combat/hits/armor/plate_slashed (2).ogg','sound/combat/hits/armor/plate_slashed (3).ogg','sound/combat/hits/armor/plate_slashed (4).ogg')
			if(blade_dulling == BCLASS_STAB||blade_dulling == BCLASS_PICK||blade_dulling == BCLASS_BITE)
				return pick('sound/combat/hits/armor/plate_stabbed (1).ogg','sound/combat/hits/armor/plate_stabbed (2).ogg','sound/combat/hits/armor/plate_stabbed (3).ogg')
			else
				return pick('sound/combat/hits/armor/plate_blunt (1).ogg','sound/combat/hits/armor/plate_blunt (2).ogg','sound/combat/hits/armor/plate_blunt (3).ogg')
		if(CHAINHIT)
			if(blade_dulling == BCLASS_BITE||blade_dulling == BCLASS_STAB||blade_dulling == BCLASS_PICK||blade_dulling == BCLASS_CUT||blade_dulling == BCLASS_CHOP)
				return pick('sound/combat/hits/armor/chain_slashed (1).ogg','sound/combat/hits/armor/chain_slashed (2).ogg','sound/combat/hits/armor/chain_slashed (3).ogg','sound/combat/hits/armor/chain_slashed (4).ogg')
			else
				return pick('sound/combat/hits/armor/chain_blunt (1).ogg','sound/combat/hits/armor/chain_blunt (2).ogg','sound/combat/hits/armor/chain_blunt (3).ogg')
		if(SOFTHIT)
			if(blade_dulling == BCLASS_BITE||blade_dulling == BCLASS_STAB||blade_dulling == BCLASS_PICK||blade_dulling == BCLASS_CUT||blade_dulling == BCLASS_CHOP)
				return pick('sound/combat/hits/armor/light_stabbed (1).ogg','sound/combat/hits/armor/light_stabbed (2).ogg','sound/combat/hits/armor/light_stabbed (3).ogg')
			else
				return pick('sound/combat/hits/armor/light_blunt (1).ogg','sound/combat/hits/armor/light_blunt (2).ogg','sound/combat/hits/armor/light_blunt (3).ogg')
		if(SOFTUNDERHIT)
			if(blade_dulling == BCLASS_BITE||blade_dulling == BCLASS_STAB||blade_dulling == BCLASS_PICK||blade_dulling == BCLASS_CUT||blade_dulling == BCLASS_CHOP)
				return pick('sound/combat/hits/armor/light_stabbed (1).ogg','sound/combat/hits/armor/light_stabbed (2).ogg','sound/combat/hits/armor/light_stabbed (3).ogg')
			else
				return pick('sound/combat/hits/armor/light_blunt (1).ogg','sound/combat/hits/armor/light_blunt (2).ogg','sound/combat/hits/armor/light_blunt (3).ogg')

GLOBAL_LIST_INIT(lockhashes, list())
GLOBAL_LIST_INIT(lockids, list())
GLOBAL_LIST_EMPTY(credits_icons)
GLOBAL_LIST_EMPTY(indexed)
GLOBAL_LIST_EMPTY(cursedsamples)
GLOBAL_LIST_EMPTY(accused)
GLOBAL_LIST_EMPTY(confessors)


GLOBAL_LIST_EMPTY(head_bounties)
GLOBAL_LIST_EMPTY(board_viewers)
GLOBAL_LIST_EMPTY(noticeboard_posts)
GLOBAL_LIST_EMPTY(premium_noticeboardposts)
GLOBAL_LIST_EMPTY(job_respawn_delays)
GLOBAL_LIST_EMPTY(round_join_times)

//stress levels
#define STRESS_MAX 30
#define STRESS_INSANE 7
#define STRESS_VBAD 5
#define STRESS_BAD 3
#define STRESS_NEUTRAL 2
#define STRESS_GOOD 1
#define STRESS_VGOOD 0

/*
	Formerly bitflags, now we are strings
	Currently used for classes
*/

#define CTAG_ALLCLASS		"CAT_ALLCLASS"		// Just a define for allclass to not deal with actively typing strings
#define CTAG_DISABLED 		"CAT_DISABLED" 		// Disabled, aka don't make it fuckin APPEAR
#define CTAG_PILGRIM 		"CAT_PILGRIM"  		// Pilgrim classes
#define CTAG_ADVENTURER 	"CAT_ADVENTURER"  	// Adventurer classes
#define CTAG_TOWNER 		"CAT_TOWNER"  		// Villager class - Villagers can use it
#define CTAG_ANTAG 			"CAT_ANTAG"  		// Antag class - results in an antag
#define CTAG_BANDIT			"CAT_BANDIT"		// Bandit class - Tied to the bandit antag really
#define CTAG_CHALLENGE 		"CAT_CHALLENGE"  	// Challenge class - Meant to be free for everyone
#define CTAG_VAGABOND		"CAT_VAGABOND"		// Vagabond class - start with nothing and work your way up
#define CTAG_INQUISITION	"CAT_INQUISITION"	// For Orthodoxist subclasses
#define CTAG_PURITAN		"CAT_PURITAN"		// For Inquisitor subclasses
#define CTAG_ABSOLVER		"CAT_ABSOLVER"		// For Absolver (sub)class
#define CTAG_COURTAGENT		"CAT_COURTAGENT"	// Court agent classes
#define CTAG_WRETCH			"CAT_WRETCH"		// Wretch classes untethered from adventurer
#define CTAG_LSKELETON		"CAT_LSKELETON"		// Lich Fortified Skeleton classes
#define CTAG_NSKELETON		"CAT_NSKELETON"		// Necromancer Greater Skeleton classes
#define CTAG_LICKER_WRETCH  "CAT_LICKER_WRETCH" // Licker wretch. Nuff said.

#define CTAG_WARDEN			"CAT_WARDEN"		// Warden class - Handles warden class selector.
#define CTAG_WATCH			"CAT_WATCH"			// Watch class - Handles Town Watch class selector
#define CTAG_MENATARMS		"CAT_MENATARMS"		// Men-at-Arms class - Handles Men-at-Arms class selector
#define CTAG_SERGEANT		"CAT_SERGEANT"		// Sergeant class - Handles Sergeant class selector (weapons selection)
#define CTAG_ROYALGUARD		"CAT_ROYALGUARD"	// Royal Guard class - Handles Royal Guard class selector
#define CTAG_CONSORT		"CAT_CONSORT"		// Consort/Suitor subclasses
#define CTAG_MERCENARY		"CAT_MERCENARY"		// Mercenary class - Handles Mercenary class selector
#define CTAG_HAND			"CAT_HAND"			// Hand class - Handles Hand class selector
#define CTAG_TEMPLAR		"CAT_TEMPLAR"		// Templar class - Handles Templar class selector
#define CTAG_HEIR			"CAT_HEIR"			// Prince(cess) class - Handles Heir class selector
#define CTAG_LORD			"CAT_LORD"			// Lord class - Handles Lord class selector
#define CTAG_SQUIRE			"CAT_SQUIRE"		// Squire class - Handles Squire class selector
#define CTAG_GATEMASTER		"CAT_GATEMASTER"	// Gatemaster class - Handles Gatemaster class selector
#define CTAG_VETERAN		"CAT_VETERAN"		// Veteran class - Handles Veteran class selector
#define CTAG_MARSHAL		"CAT_MARSHAL"		// Marshal class
#define CTAG_SENESCHAL		"CAT_SENESCHAL"		// Seneschal's aesthetic choices.
#define CTAG_SERVANT		"CAT_SERVANT"		// Servant's aesthetic choices.
#define CTAG_CAPTAIN		"CAT_CAPTAIN"		// Handles Captain class selector
#define CTAG_WAPPRENTICE	"CTAG_WAPPRENTICE"	// Mage Apprentice Classes - Handles Mage Apprentices class selector
#define CTAG_GUILDMASTER 	"CAT_GUILDMASTER"	// Guildmaster class - Handles Guildmaster class selector
#define CTAG_GUILDSMEN 		"CAT_GUILDSMEN"		// Guildsmen class - Handles Guildsmen class selector
#define CTAG_NIGHTMAIDEN	"CAT_NIGHTMAIDEN"	// Bathhouse Attendant's aesthetic choices.
#define CTAG_PRISONER "CAT_PRISONER"

#define CTAG_HFT_LORD "CAT_HFT_LORD"  // Heartfelt Lord Class - Handles Heartfelt Lord class selector.
#define CTAG_HFT_HAND "CAT_HFT_HAND"  // Heartfelt Hand Class - Handles Heartfelt Hand class selector.
#define CTAG_HFT_KNIGHT "CAT_HFT_KNIGHT"  // Heartfelt Knight Class - Handles Heartfelt Knight class selector.
#define CTAG_HFT_RETINUE "CAT_HFT_RETINUE"  // Heartfelt Retinue Class - Handles Heartfelt Retinue class selector.

// List of mono-class categories. Only here for standardisation sake, but can be added on if desired.
#define CTAG_DUNGEONEER		"CAT_DUNGEONEER"

#define CTAG_BISHOP			"CAT_BISHOP"
#define CTAG_MARTYR			"CAT_MARTYR"
#define CTAG_ACOLYTE		"CAT_ACOLYTE"
#define CTAG_CHURCHLING		"CAT_CHURCHLING"
#define CTAG_DRUID			"CAT_DRUID"

#define CTAG_STEWARD		"CAT_STEWARD"
#define CTAG_CLERK			"CAT_CLERK"
#define CTAG_COUNCILLOR		"CAT_COUNCIL"

#define CTAG_COURTMAGE		"CAT_COURTMAGE"

#define CTAG_COURTPHYS		"CAT_COURTPHYS"
#define CTAG_APOTH			"CAT_APOTH"

#define CTAG_MERCH			"CAT_MERCH"
#define CTAG_SHOPHAND		"CAT_SHOPHAND"
#define CTAG_ARCHIVIST		"CAT_ARCHIVIST"
#define CTAG_LOUDMOUTH		"CAT_LOUDMOUTH"
#define CTAG_TAILOR			"CAT_TAILOR"
#define CTAG_SOILBRIDE		"CAT_SOILBRIDE"
#define CTAG_INNKEEPER		"CAT_INNKEEPER"
#define CTAG_COOK			"CAT_COOK"
#define CTAG_BATHMOM		"CAT_BATHMOM"
#define CTAG_TAPSTER		"CAT_TAPSTER"
#define CTAG_LUNATIC		"CAT_LUNATIC"

/*
	Defines for class select categories
*/

//Adventurer categories
#define CLASS_CAT_NOBLE	"Noble"
#define CLASS_CAT_CLERIC "Cleric"
#define CLASS_CAT_ROGUE	"Rogue"
#define CLASS_CAT_RANGER "Ranger"
#define CLASS_CAT_MAGE "Mage"
#define CLASS_CAT_WARRIOR "Warrior"
#define CLASS_CAT_TRADER "Trader"
#define CLASS_CAT_NOMAD "Nomad"

//Mercenary categories
#define CLASS_CAT_ETRUSCA "Etrusca"
#define CLASS_CAT_GRENZELHOFT "Grenzelhoft"
#define CLASS_CAT_NALEDI "Naledi"
#define CLASS_CAT_RANESHENI "Ranesheni"
#define CLASS_CAT_AAVNR "Aavnr"
#define CLASS_CAT_GRONN "Gronn"
#define CLASS_CAT_OTAVA "Otava"
#define CLASS_CAT_KAZENGUN "Kazengun"
#define CLASS_CAT_RACIAL "Race Exclusive" //Used for black oaks, grudgebearer dwarves, etc.

//Migrant categories
#define CLASS_CAT_HFT_COURT "Upper Court"
#define CLASS_CAT_HFT_GUARD "House Guard"
#define CLASS_CAT_HFT_WORKER "Workers"



// Social rank defines
#define SOCIAL_RANK_DIRT 1
#define SOCIAL_RANK_PEASANT 2
#define SOCIAL_RANK_YEOMAN 3
#define SOCIAL_RANK_MINOR_NOBLE 4
#define SOCIAL_RANK_NOBLE 5
#define SOCIAL_RANK_ROYAL 6

/*
	Defines for the triumph buy datum categories
*/
#define TRIUMPH_CAT_ROUND_EFX "ROUND-EFX"
#define TRIUMPH_CAT_CHARACTER "CHARACTER"
#define TRIUMPH_CAT_MISC "MISC!"
#define TRIUMPH_CAT_ACTIVE_DATUMS "ACTIVE"

#define ARMOR_CLASS_NONE 0
#define ARMOR_CLASS_LIGHT 1
#define ARMOR_CLASS_MEDIUM 2
#define ARMOR_CLASS_HEAVY 3

#define BASE_PARRY_STAMINA_DRAIN 5 	// Unmodified stamina drain for parry, now a var instead of setting on simplemobs
#define BAD_GUARD_FATIGUE_DRAIN 20 	// Percentage of your green bar lost on letting a guard expire.
#define GUARD_PEEL_REDUCTION 2		// How many Peel stacks to lose if a Guard is hit.
#define BAIT_PEEL_REDUCTION 1		// How many Peel stacks to lose if we perfectly bait.

/*
Medical defines
*/
#define ARTERY_LIMB_BLEEDRATE 20	//This is used as a reference point for dynamic wounds, so it's better off as a define.
#define CONSTITUTION_BLEEDRATE_MOD 0.1	//How much slower we'll be bleeding for every CON point. 0.1 = 10% slower.
#define CONSTITUTION_BLEEDRATE_CAP 15	//The CON value up to which we get a bleedrate reduction.

/*
	Red Potion defines
*/
#define BLOOD_VOLUME_POTION_MAX 600
