/*
	HUGBOX MODE DEFINES

	This file contains defines for critical hit damage thresholds.
	When HUGBOX is defined, high damage_dividend values are required for critical hits, meaning that severe limb damage is required for a critical hit to occur.
	Additionally, the overkill thresholds are set so that random critical hits can only occur if the damage dealt is greater than the threshold + the owner's constitution.

	When HUGBOX is not defined (commented out), all thresholds are set to 0, making all crits possible regardless of limb damage as long as the damage is greater than the owner's constitution.
	This is the intended behavior for the game as it is meant to be played. 

	The overkill threshold dynamically reduces as the owner takes damage up to -50% (or -20% for characters with crit resistance), making it easier to get an overkill crit as the limb suffers more damage.
	
	HUGBOX mode is turned on by default because our playerbase are a bunch of baby bitches.
*/

#define HUGBOX

#ifdef HUGBOX
	#define CRIT_LIMB_FRACTURE_DIVISOR			0.6
	#define CRIT_GROIN_FRACTURE_DIVISOR			0.7
	#define CRIT_CHEST_ORGAN_STAB_DIVISOR		0.7
	#define CRIT_CHEST_ORGAN_SLASH_DIVISOR		0.8
	#define CRIT_CHEST_ORGAN_BLUNT_DIVISOR		0.75
	#define CRIT_BRAIN_PENETRATION_DIVISOR		0.8
	
	#define CRIT_OVERKILL_THRESHOLD_EASY		55
	#define CRIT_OVERKILL_THRESHOLD_NORMAL		60
	#define CRIT_OVERKILL_THRESHOLD_HARD		65
	#define CRIT_OVERKILL_THRESHOLD_VERY_HARD	70
#else
	#define CRIT_LIMB_FRACTURE_DIVISOR			0
	#define CRIT_GROIN_FRACTURE_DIVISOR			0
	#define CRIT_CHEST_ORGAN_STAB_DIVISOR		0
	#define CRIT_CHEST_ORGAN_SLASH_DIVISOR		0
	#define CRIT_CHEST_ORGAN_BLUNT_DIVISOR		0
	#define CRIT_BRAIN_PENETRATION_DIVISOR		0

	#define CRIT_OVERKILL_THRESHOLD_EASY		0
	#define CRIT_OVERKILL_THRESHOLD_NORMAL		0
	#define CRIT_OVERKILL_THRESHOLD_HARD		0
	#define CRIT_OVERKILL_THRESHOLD_VERY_HARD	0
#endif
