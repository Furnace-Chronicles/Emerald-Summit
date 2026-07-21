#define DANGER_SAFE_FLOOR 0
#define DANGER_SAFE_LIMIT 10
#define DANGER_LOW_FLOOR 11
#define DANGER_LOW_LIMIT 20
#define DANGER_MODERATE_FLOOR 21
#define DANGER_MODERATE_LIMIT 30
#define DANGER_DANGEROUS_FLOOR 31
#define DANGER_DANGEROUS_LIMIT 40
#define DANGER_BLEAK_FLOOR 41
#define DANGER_BLEAK_LIMIT 60

// Threat Point (TP) tier ladder — the "cost" of a single NPC to the quest kill-budget system
// (ported from AP #6849/#7000 regional_threat.dm). set on mob subtypes in questing/threat_points.dm.
// A kill quest spends a tp_budget composing its warband; each mob's threat_point is its price.
#define THREAT_TRASH 8       // Fox, raccoon, bigrat, mire crawler, all goblins - trivial critters
#define THREAT_LOW 10        // Wolf, bobcat, badger, honeyspider, supereasy/medium skeleton
#define THREAT_MODERATE 14   // Mossback, mole, easy/pirate/bogguard skeleton, highwayman, searaider, militia deserter
#define THREAT_HIGH 20       // Bog deserter, orc footsoldier, mutated spider
#define THREAT_TOUGH 25      // Upgraded bog deserter, hard skeleton, orc berserker/marauder, drow raider
#define THREAT_DANGEROUS 30  // Troll, bog troll, minotaur, direbear, drider
#define THREAT_ELITE 50      // Treasure hunter, mirespider lurker/paralytic, dwarf skeleton - boss-tier mobs

// Threat Points removed from a region's latent ambush pressure per "band" a kill quest clears.
#define THREAT_POINTS_PER_BAND 50
