/*------------------------\
|   ARMOR RATING TIERS    | // Tier constants ported from AP. Armor VALUE defines below now use these tiers
\------------------------*/ // (DR_* / DBLOCK_*) instead of 0-100 percentages. Integrity defines stay numeric.

// Penetration tiers (0-4). Weapon attacks.
#define PEN_NONE			0	// No penetration. Training weapons, base cuts/chops.
#define PEN_LIGHT			1	// Falx cut, axe chop. Penetrates trash armor (NPC cloth/bad leather).
#define PEN_MEDIUM			2	// Sword thrusts, longsword chop. Penetrates player light armor (gambeson, hardened leather).
#define PEN_HEAVY			3	// Spear, estoc. Penetrates mail/brigandine/plate.
#define PEN_BSTEEL			4	// Halfsword, dagger pick. Penetrates plate fully, blacksteel.

// Damage Blocking tiers (0-4). Armor clothing.
#define DBLOCK_NONE			0	// No blocking. Unarmored skin.
#define DBLOCK_LIGHT		1	// Cloth, bad leather, NPC trash armor.
#define DBLOCK_MEDIUM		2	// Gambeson, padded, hardened leather, studded — player light armor.
#define DBLOCK_HEAVY		3	// Brigandine, mail, cuirass, plate.
#define DBLOCK_BSTEEL		4	// Blacksteel, antagonist.

// Damage reduction tiers (0-5). Used by blunt (absorb), fire, acid (pierce).
// Note that blunt by default have 1.6x Integrity Multiplier.
// Damage multiplier = 1 / (1 + 0.2 * tier)
// Blunt: all damage absorbed by armor. Fire/Acid: reduced damage still hits HP.
#define DR_NONE				0	// Nothing. 100% damage. EDPS: 160%
#define DR_LIGHT			1	// Plate / Metal. 20% EHP increase. EDPS: 133%
#define DR_MEDIUM			2	// Mail. 40% EHP increase. EDPS: 114%
#define DR_HEAVY			3	// Bad Light Armor. 60% EHP increase. EDPS: 100%
#define DR_SUPER			4	// Medium Light Armor. 80% EHP increase. EDPS: 89%
#define DR_ULTRA			5	// Best quality light armor. 100% EHP increase. EDPS: 80%

// Damage-type families — which resolution path each type takes in run_armor_check().
#define ARMOR_DR_ABSORB_TYPES list("blunt")						// Armor absorbs ALL HP damage; the hit lands on integrity instead.
#define ARMOR_DR_PIERCE_TYPES list("fire", "acid")				// DR reduces damage, but the reduced damage still reaches HP.
#define ARMOR_DBLOCK_TYPES list("slash", "stab", "piercing")	// Weapon PEN tier vs armor DBLOCK tier.

// Penetration passthrough fractions
#define PEN_PASSTHROUGH_RATIO	0.1		// Damage through per pen "dot" (pen vs armor + relevant stat above 10). 0.1 = 10%
#define PEN_PASSTHROUGH_PROJ_EQUAL 0.2	// Projectile, pen == armor: 20% through
#define PEN_PASSTHROUGH_PROJ_MORE 0.8	// Projectile, pen > armor: 80% through
#define PEN_PASSTHROUGH_CAP	8			// Max pen "dots" (pen vs armor + 1 per relevant stat above 10)


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
#define ARMOR_INT_SIDE_BRONZE 250 // Integrity for bronze pieces
#define ARMOR_INT_SIDE_IRON 225 // Integrity for iron pieces
#define ARMOR_INT_SIDE_HARDLEATHER 250 // Integrity for hardened leather pieces
#define ARMOR_INT_SIDE_LEATHER 200 // Integrity for leather / copper pieces
#define ARMOR_INT_SIDE_DECREPIT 150 // Integrity for decrepit pieces
#define ARMOR_INT_SIDE_CLOTH 100 // Integrity for cloth / aesthetic oriented pieces


/*--------------------\
| ARMOR VALUE DEFINES | // Tier values. blunt/fire/acid = DR_* ; slash/stab/piercing = DBLOCK_*
\--------------------*/
// Misc defines. These are here just in case. Inherited by their relevant subtypes.
#define ARMOR_MACHINERY list("blunt" = DR_LIGHT, "slash" = DBLOCK_LIGHT, "stab" = DBLOCK_LIGHT, "piercing" = DBLOCK_LIGHT, "fire" = DR_HEAVY, "acid" = DR_SUPER)
#define ARMOR_STRUCTURE list("blunt" = DR_NONE, "slash" = DBLOCK_NONE, "stab" = DBLOCK_NONE, "piercing" = DBLOCK_NONE, "fire" = DR_HEAVY, "acid" = DR_HEAVY)
#define ARMOR_DISPLAYCASE list("blunt" = DR_MEDIUM, "slash" = DBLOCK_LIGHT, "stab" = DBLOCK_LIGHT, "piercing" = DBLOCK_NONE, "fire" = DR_SUPER, "acid" = DR_ULTRA)
#define ARMOR_CLOSET list("blunt" = DR_LIGHT, "slash" = DBLOCK_LIGHT, "stab" = DBLOCK_LIGHT, "piercing" = DBLOCK_LIGHT, "fire" = DR_SUPER, "acid" = DR_HEAVY)
#define ARMOR_BLACKBAG list("blunt" = DR_ULTRA, "slash" = DBLOCK_HEAVY, "stab" = DBLOCK_HEAVY, "piercing" = DBLOCK_HEAVY, "fire" = DR_SUPER, "acid" = DR_ULTRA)

// Light AC | Chest
#define ARMOR_CLOTHING list("blunt" = DR_NONE, "slash" = DBLOCK_LIGHT, "stab" = DBLOCK_LIGHT, "piercing" = DBLOCK_NONE, "fire" = DR_NONE, "acid" = DR_NONE)
#define ARMOR_PADDED_GOOD list("blunt" = DR_SUPER, "slash" = DBLOCK_MEDIUM, "stab" = DBLOCK_MEDIUM, "piercing" = DBLOCK_HEAVY, "fire" = DR_MEDIUM, "acid" = DR_NONE)
#define ARMOR_PADDED list("blunt" = DR_HEAVY, "slash" = DBLOCK_LIGHT, "stab" = DBLOCK_LIGHT, "piercing" = DBLOCK_MEDIUM, "fire" = DR_MEDIUM, "acid" = DR_NONE)
#define ARMOR_PADDED_BAD list("blunt" = DR_MEDIUM, "slash" = DBLOCK_LIGHT, "stab" = DBLOCK_LIGHT, "piercing" = DBLOCK_LIGHT, "fire" = DR_MEDIUM, "acid" = DR_NONE)
#define ARMOR_LIGHTCUIRASS list("blunt" = DR_MEDIUM, "slash" = DBLOCK_MEDIUM, "stab" = DBLOCK_MEDIUM, "piercing" = DBLOCK_LIGHT, "fire" = DR_MEDIUM, "acid" = DR_NONE)

#define ARMOR_LEATHER list("blunt" = DR_HEAVY, "slash" = DBLOCK_MEDIUM, "stab" = DBLOCK_LIGHT, "piercing" = DBLOCK_LIGHT, "fire" = DR_MEDIUM, "acid" = DR_NONE)
#define ARMOR_LEATHER_GOOD list("blunt" = DR_ULTRA, "slash" = DBLOCK_MEDIUM, "stab" = DBLOCK_MEDIUM, "piercing" = DBLOCK_LIGHT, "fire" = DR_MEDIUM, "acid" = DR_NONE)
#define ARMOR_LEATHER_STUDDED list("blunt" = DR_SUPER, "slash" = DBLOCK_HEAVY, "stab" = DBLOCK_MEDIUM, "piercing" = DBLOCK_LIGHT, "fire" = DR_MEDIUM, "acid" = DR_NONE)

// Medium AC | Chest
#define ARMOR_CUIRASS list("blunt" = DR_MEDIUM, "slash" = DBLOCK_HEAVY, "stab" = DBLOCK_HEAVY, "piercing" = DBLOCK_MEDIUM, "fire" = DR_LIGHT, "acid" = DR_NONE)
#define ARMOR_MAILLE list("blunt" = DR_MEDIUM, "slash" = DBLOCK_HEAVY, "stab" = DBLOCK_HEAVY, "piercing" = DBLOCK_MEDIUM, "fire" = DR_LIGHT, "acid" = DR_NONE)

// Heavy AC | Chest
#define ARMOR_PLATE list("blunt" = DR_LIGHT, "slash" = DBLOCK_HEAVY, "stab" = DBLOCK_HEAVY, "piercing" = DBLOCK_HEAVY, "fire" = DR_LIGHT, "acid" = DR_NONE)
#define ARMOR_PLATE_GOOD list("blunt" = DR_HEAVY, "slash" = DBLOCK_HEAVY, "stab" = DBLOCK_HEAVY, "piercing" = DBLOCK_HEAVY, "fire" = DR_LIGHT, "acid" = DR_NONE)
#define ARMOR_PLATE_BSTEEL list("blunt" = DR_SUPER, "slash" = DBLOCK_HEAVY, "stab" = DBLOCK_HEAVY, "piercing" = DBLOCK_HEAVY, "fire" = DR_LIGHT, "acid" = DR_NONE) // It's EVIL. OH GOD.

// Boot Armor
#define ARMOR_BOOTS_PLATED list("blunt" = DR_LIGHT, "slash" = DBLOCK_HEAVY, "stab" = DBLOCK_HEAVY, "piercing" = DBLOCK_HEAVY, "fire" = DR_LIGHT, "acid" = DR_NONE)
#define ARMOR_BOOTS_PLATED_IRON list("blunt" = DR_LIGHT, "slash" = DBLOCK_HEAVY, "stab" = DBLOCK_MEDIUM, "piercing" = DBLOCK_MEDIUM, "fire" = DR_LIGHT, "acid" = DR_NONE)
#define ARMOR_BOOTS_BAD list("blunt" = DR_MEDIUM, "slash" = DBLOCK_LIGHT, "stab" = DBLOCK_LIGHT, "piercing" = DBLOCK_NONE, "fire" = DR_MEDIUM, "acid" = DR_NONE)
#define ARMOR_BOOTS list("blunt" = DR_MEDIUM, "slash" = DBLOCK_LIGHT, "stab" = DBLOCK_MEDIUM, "piercing" = DBLOCK_LIGHT, "fire" = DR_MEDIUM, "acid" = DR_NONE)

// Glove Armor
#define ARMOR_GLOVES_LEATHER list("blunt" = DR_HEAVY, "slash" = DBLOCK_LIGHT, "stab" = DBLOCK_LIGHT, "piercing" = DBLOCK_NONE, "fire" = DR_MEDIUM, "acid" = DR_NONE)
#define ARMOR_GLOVES_LEATHER_GOOD list("blunt" = DR_HEAVY, "slash" = DBLOCK_LIGHT, "stab" = DBLOCK_LIGHT, "piercing" = DBLOCK_LIGHT, "fire" = DR_MEDIUM, "acid" = DR_NONE)
#define ARMOR_GLOVES_CHAIN list("blunt" = DR_LIGHT, "slash" = DBLOCK_HEAVY, "stab" = DBLOCK_MEDIUM, "piercing" = DBLOCK_MEDIUM, "fire" = DR_LIGHT, "acid" = DR_NONE)
#define ARMOR_GLOVES_PLATE list("blunt" = DR_LIGHT, "slash" = DBLOCK_HEAVY, "stab" = DBLOCK_HEAVY, "piercing" = DBLOCK_HEAVY, "fire" = DR_LIGHT, "acid" = DR_NONE)
#define ARMOR_GLOVES_PLATE_GOOD list("blunt" = DR_LIGHT, "slash" = DBLOCK_HEAVY, "stab" = DBLOCK_HEAVY, "piercing" = DBLOCK_HEAVY, "fire" = DR_LIGHT, "acid" = DR_NONE)

//  Head Armor
#define ARMOR_HEAD_CLOTHING list("blunt" = DR_NONE, "slash" = DBLOCK_LIGHT, "stab" = DBLOCK_LIGHT, "piercing" = DBLOCK_NONE, "fire" = DR_NONE, "acid" = DR_NONE)
#define ARMOR_HEAD_BAD list("blunt" = DR_HEAVY, "slash" = DBLOCK_LIGHT, "stab" = DBLOCK_LIGHT, "piercing" = DBLOCK_LIGHT, "fire" = DR_MEDIUM, "acid" = DR_NONE)
#define ARMOR_HEAD_HELMET_BAD list("blunt" = DR_HEAVY, "slash" = DBLOCK_MEDIUM, "stab" = DBLOCK_MEDIUM, "piercing" = DBLOCK_LIGHT, "fire" = DR_LIGHT, "acid" = DR_NONE)
#define ARMOR_HEAD_HELMET list("blunt" = DR_HEAVY, "slash" = DBLOCK_HEAVY, "stab" = DBLOCK_HEAVY, "piercing" = DBLOCK_MEDIUM, "fire" = DR_LIGHT, "acid" = DR_NONE)
#define ARMOR_HEAD_HELMET_VISOR list("blunt" = DR_MEDIUM, "slash" = DBLOCK_HEAVY, "stab" = DBLOCK_HEAVY, "piercing" = DBLOCK_MEDIUM, "fire" = DR_LIGHT, "acid" = DR_NONE)
#define ARMOR_HEAD_PSYDON list("blunt" = DR_SUPER, "slash" = DBLOCK_MEDIUM, "stab" = DBLOCK_MEDIUM, "piercing" = DBLOCK_LIGHT, "fire" = DR_LIGHT, "acid" = DR_NONE)	//Yeah they just have their own thing going on.
#define ARMOR_HEAD_LEATHER list("blunt" = DR_ULTRA, "slash" = DBLOCK_MEDIUM, "stab" = DBLOCK_LIGHT, "piercing" = DBLOCK_LIGHT, "fire" = DR_MEDIUM, "acid" = DR_NONE)

// Mask Armor
#define ARMOR_MASK_EYEPATCH list("blunt" = DR_LIGHT, "slash" = DBLOCK_LIGHT, "stab" = DBLOCK_LIGHT, "piercing" = DBLOCK_LIGHT, "fire" = DR_NONE, "acid" = DR_NONE)
#define ARMOR_MASK_METAL_BAD list("blunt" = DR_HEAVY, "slash" = DBLOCK_MEDIUM, "stab" = DBLOCK_MEDIUM, "piercing" = DBLOCK_MEDIUM, "fire" = DR_LIGHT, "acid" = DR_NONE)
#define ARMOR_MASK_METAL list("blunt" = DR_HEAVY, "slash" = DBLOCK_HEAVY, "stab" = DBLOCK_HEAVY, "piercing" = DBLOCK_MEDIUM, "fire" = DR_LIGHT, "acid" = DR_NONE)

// Neck Armor
#define ARMOR_BEVOR list("blunt" = DR_LIGHT, "slash" = DBLOCK_HEAVY, "stab" = DBLOCK_HEAVY, "piercing" = DBLOCK_MEDIUM, "fire" = DR_LIGHT, "acid" = DR_NONE)
#define ARMOR_GORGET list("blunt" = DR_MEDIUM, "slash" = DBLOCK_HEAVY, "stab" = DBLOCK_HEAVY, "piercing" = DBLOCK_MEDIUM, "fire" = DR_LIGHT, "acid" = DR_NONE)
#define ARMOR_NECK_BAD list("blunt" = DR_HEAVY, "slash" = DBLOCK_MEDIUM, "stab" = DBLOCK_LIGHT, "piercing" = DBLOCK_LIGHT, "fire" = DR_MEDIUM, "acid" = DR_NONE)

//Pants Armor
#define ARMOR_PANTS_LEATHER list("blunt" = DR_SUPER, "slash" = DBLOCK_MEDIUM, "stab" = DBLOCK_LIGHT, "piercing" = DBLOCK_LIGHT, "fire" = DR_MEDIUM, "acid" = DR_NONE)
#define ARMOR_PANTS_CHAIN list("blunt" = DR_MEDIUM, "slash" = DBLOCK_HEAVY, "stab" = DBLOCK_HEAVY, "piercing" = DBLOCK_MEDIUM, "fire" = DR_LIGHT, "acid" = DR_NONE)
#define ARMOR_PANTS_BRIGANDINE list("blunt" = DR_MEDIUM, "slash" = DBLOCK_MEDIUM, "stab" = DBLOCK_MEDIUM, "piercing" = DBLOCK_MEDIUM, "fire" = DR_MEDIUM, "acid" = DR_NONE)

//Antag / Special / Unique armor defines
#define ARMOR_REGENERATING_BROKEN list("blunt" = DR_LIGHT, "slash" = DBLOCK_LIGHT, "stab" = DBLOCK_LIGHT, "piercing" = DBLOCK_LIGHT, "fire" = DR_NONE, "acid" = DR_NONE)
#define ARMOR_VAMP list("blunt" = DR_ULTRA, "slash" = DBLOCK_BSTEEL, "stab" = DBLOCK_BSTEEL, "piercing" = DBLOCK_BSTEEL, "fire" = DR_NONE, "acid" = DR_NONE) // Blacksteel antag plate — top of the DBLOCK scale.
#define ARMOR_WWOLF list("blunt" = DR_ULTRA, "slash" = DBLOCK_HEAVY, "stab" = DBLOCK_HEAVY, "piercing" = DBLOCK_MEDIUM, "fire" = DR_MEDIUM, "acid" = DR_NONE)
// Gnoll hide tiers scale monotonically: STRONG > STANDARD > WEAK for every damage type.
// Hide keeps its character (slightly tougher vs slash/stab than blunt) but the tank hide is no longer
// blunt-weakest. piercing is largely moot — gnolls are TRAIT_PIERCEIMMUNE.
#define ARMOR_GNOLL_WEAK list("blunt" = DR_HEAVY, "slash" = DBLOCK_MEDIUM, "stab" = DBLOCK_MEDIUM, "piercing" = DBLOCK_MEDIUM, "fire" = DR_MEDIUM, "acid" = DR_NONE)
#define ARMOR_GNOLL_STANDARD list("blunt" = DR_SUPER, "slash" = DBLOCK_HEAVY, "stab" = DBLOCK_HEAVY, "piercing" = DBLOCK_HEAVY, "fire" = DR_MEDIUM, "acid" = DR_NONE)
#define ARMOR_GNOLL_STRONG list("blunt" = DR_ULTRA, "slash" = DBLOCK_BSTEEL, "stab" = DBLOCK_BSTEEL, "piercing" = DBLOCK_HEAVY, "fire" = DR_MEDIUM, "acid" = DR_NONE)
#define ARMOR_DRAGONSCALE list("blunt" = DR_ULTRA, "slash" = DBLOCK_HEAVY, "stab" = DBLOCK_HEAVY, "fire" = DR_HEAVY, "acid" = DR_NONE)
#define ARMOR_ASCENDANT list("blunt" = DR_HEAVY, "slash" = DBLOCK_HEAVY, "stab" = DBLOCK_HEAVY, "piercing" = DBLOCK_HEAVY, "fire" = DR_NONE, "acid" = DR_NONE)
#define ARMOR_SPELLSINGER list("blunt" = DR_SUPER, "slash" = DBLOCK_MEDIUM, "stab" = DBLOCK_MEDIUM, "piercing" = DBLOCK_LIGHT, "fire" = DR_NONE, "acid" = DR_NONE)
#define ARMOR_GRUDGEBEARER list("blunt" = DR_MEDIUM, "slash" = DBLOCK_BSTEEL, "stab" = DBLOCK_BSTEEL, "piercing" = DBLOCK_HEAVY, "fire" = DR_NONE, "acid" = DR_NONE)
#define ARMOR_ZIZOCONCSTRUCT list("blunt" = DR_HEAVY, "slash" = DBLOCK_MEDIUM, "stab" = DBLOCK_MEDIUM, "piercing" = DBLOCK_MEDIUM, "fire" = DR_MEDIUM, "acid" = DR_LIGHT)
// Blocks every hit, at least once
#define ARMOR_GRONN_LIGHT list("blunt" = DR_SUPER, "slash" = DBLOCK_HEAVY, "stab" = DBLOCK_LIGHT, "piercing" = DBLOCK_LIGHT, "fire" = DR_NONE, "acid" = DR_NONE)
