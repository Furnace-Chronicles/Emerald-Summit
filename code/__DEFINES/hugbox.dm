/*
	HUGBOX MODE DEFINES

	This file contains defines for critical hit damage thresholds.
	When HUGBOX is defined, high damage_dividend values are required for critical hits, meaning that severe limb damage is required for a critical hit to occur.
	When HUGBOX is not defined (commented out), all thresholds are set to 0, making all crits possible regardless of limb damage. This is the intended behavior
	for the game as it is meant to be played. This is turned on by default because our playerbase are a bunch of baby bitches.
*/

#define HUGBOX

#ifdef HUGBOX
	#define CRIT_LIMB_FRACTURE_DIVISOR			0.6
	#define CRIT_GROIN_FRACTURE_DIVISOR			0.7
	#define CRIT_CHEST_ORGAN_STAB_DIVISOR		0.3
	#define CRIT_CHEST_ORGAN_SLASH_DIVISOR		0.5
	#define CRIT_CHEST_ORGAN_BLUNT_DIVISOR		0.75
	#define CRIT_BRAIN_PENETRATION_DIVISOR		0.8
#else
	#define CRIT_LIMB_FRACTURE_DIVISOR			0
	#define CRIT_GROIN_FRACTURE_DIVISOR			0
	#define CRIT_CHEST_ORGAN_STAB_DIVISOR		0
	#define CRIT_CHEST_ORGAN_SLASH_DIVISOR		0
	#define CRIT_CHEST_ORGAN_BLUNT_DIVISOR		0
	#define CRIT_BRAIN_PENETRATION_DIVISOR		0
#endif
