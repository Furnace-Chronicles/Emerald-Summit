// Danger levels. Each danger level is defined as an ambush that can happen. Every time this fire, this number iterates.
#define DANGER_LEVEL_SAFE "Safe"
#define DANGER_LEVEL_LOW "Low"
#define DANGER_LEVEL_MODERATE "Moderate"
#define DANGER_LEVEL_DANGEROUS "Dangerous"
#define DANGER_LEVEL_BLEAK "Bleak"

#define THREAT_REGION_BLACK_BASIN "Black Basin"
#define THREAT_REGION_SCARLET_GROVE "Scarlet Grove"
#define THREAT_REGION_SCARLET_COAST "Scarlet Coast"
#define THREAT_REGION_MOUNT_DECAP "Mount Decapitation"
#define THREAT_REGION_TERRORBOG "Terrorbog"

#define LOWPOP_THRESHOLD 30 // When do we give highpop tick?
// Subsystem meant to handle regional threat level

SUBSYSTEM_DEF(regionthreat)
	name = "Regional Threat"
	wait = 15 MINUTES
	flags = SS_KEEP_TIMING | SS_BACKGROUND
	runlevels = RUNLEVEL_GAME
	// The first four regions are meant to be "tameable" for towner purposes.
	// Quest-surface params (allowed_quest_types / *_multiplier / kill_target_floor / evergreen_target)
	// ported from AP Quest 2. AP's 6th region (Underdark) folds into Terrorbog. The danger/ambush
	// numbers below are ES's own tuning and are deliberately left untouched.
	var/list/threat_regions = list(
		new /datum/threat_region(
			_region_name = THREAT_REGION_BLACK_BASIN,
			_latent_ambush = DANGER_LOW_FLOOR,
			_min_ambush = DANGER_SAFE_FLOOR,
			_max_ambush = DANGER_DANGEROUS_LIMIT, // Let's not go DIRE no matter what, in the future
			_fixed_ambush = FALSE,
			_lowpop_tick = 1,
			_highpop_tick = 1,
			_allowed_quest_types = list(QUEST_KILL_EASY, QUEST_CLEAR_OUT, QUEST_COURIER, QUEST_RETRIEVAL, QUEST_RECOVERY),
			_tp_budget_multiplier = 0.75,
			_kill_target_floor = 4,
			_evergreen_target = 3,
			_delivery_reward_multiplier = 1.0,
			_faction_weights = list(
				QUEST_FACTION_FOREST_GOBLIN = 60,
				QUEST_FACTION_SEA_GOBLIN = 40,
				QUEST_FACTION_HIGHWAYMAN = 5,
			),
		),
		new /datum/threat_region(
			_region_name = THREAT_REGION_SCARLET_GROVE,
			_latent_ambush = DANGER_MODERATE_FLOOR,
			_min_ambush = DANGER_SAFE_FLOOR,
			_max_ambush = DANGER_DANGEROUS_LIMIT,
			_fixed_ambush = FALSE,
			_lowpop_tick = 1,
			_highpop_tick = 1,
			// allowed_quest_types: default (full kill + evergreen set)
			_tp_budget_multiplier = 1.0,
			_kill_target_floor = 5,
			_evergreen_target = 3,
			_delivery_reward_multiplier = 1.5,
			_faction_weights = list(
				QUEST_FACTION_FOREST_GOBLIN = 40,
				QUEST_FACTION_HIGHWAYMAN = 30,
				QUEST_FACTION_STRAY_DEADITE = 20,
				QUEST_FACTION_WILD_BEAST = 10,
			),
		),
		new /datum/threat_region(
			_region_name = THREAT_REGION_TERRORBOG,
			_latent_ambush = DANGER_BLEAK_LIMIT,
			_min_ambush = DANGER_SAFE_FLOOR, // This is intended. A warden can engage in a long war to tame the terrorbog.
			_max_ambush = DANGER_BLEAK_LIMIT,
			_fixed_ambush = FALSE,
			_lowpop_tick = 1,
			_highpop_tick = 1,
			// Terrorbog also absorbs AP's Underdark pool (drow/mirespider/moon goblins) when the
			// faction system lands - its allowed set is the widest of the tameable regions.
			_allowed_quest_types = list(QUEST_CLEAR_OUT, QUEST_RAID, QUEST_BOUNTY, QUEST_COURIER, QUEST_RETRIEVAL, QUEST_RECOVERY, QUEST_TOWNER_SMITH_CARAVAN, QUEST_TOWNER_MINER_OREVEIN),
			_tp_budget_multiplier = 1.5,
			_kill_target_floor = 4,
			_evergreen_target = 3,
			_delivery_reward_multiplier = 2.0,
			// Terrorbog union: AP's native bog pool + the absorbed Underdark pool (drow/moon
			// goblin/lich/minotaur). MIRESPIDER appears in both AP tables, so its weight is summed.
			_faction_weights = list(
				QUEST_FACTION_MIRESPIDER = 50,
				QUEST_FACTION_BOGMAN = 40,
				QUEST_FACTION_DROW = 30,
				QUEST_FACTION_MOON_GOBLIN = 25,
				QUEST_FACTION_BOG_DEADITE = 20,
				QUEST_FACTION_BOG_TROLL = 10,
				QUEST_FACTION_LICH_DEADITE = 10,
				QUEST_FACTION_MINOTAUR = 10,
				QUEST_FACTION_FOREST_GOBLIN = 5,
			),
		),
		// All regions after are meant to stay somewhat dangerous no matter what
		new /datum/threat_region(
			_region_name = THREAT_REGION_SCARLET_COAST,
			_latent_ambush = DANGER_DANGEROUS_FLOOR,
			_min_ambush = DANGER_MODERATE_FLOOR,
			_max_ambush = DANGER_BLEAK_LIMIT,
			_fixed_ambush = FALSE,
			_lowpop_tick = 1,
			_highpop_tick = 1,
			_allowed_quest_types = list(QUEST_CLEAR_OUT, QUEST_RAID, QUEST_BOUNTY, QUEST_RECOVERY, QUEST_TOWNER_SMITH_CARAVAN, QUEST_TOWNER_MINER_OREVEIN),
			_tp_budget_multiplier = 1.2,
			_kill_target_floor = 3,
			_delivery_reward_multiplier = 1.8,
			_faction_weights = list(
				QUEST_FACTION_ORC = 30,
				QUEST_FACTION_SEA_GOBLIN = 25,
				QUEST_FACTION_GRONNMAN = 20,
				QUEST_FACTION_BLEAKISLE_REAVER = 15,
				QUEST_FACTION_HIGHWAYMAN = 10,
			),
		),
		new /datum/threat_region(
			_region_name = THREAT_REGION_MOUNT_DECAP,
			_latent_ambush = DANGER_DANGEROUS_FLOOR,
			_min_ambush = DANGER_MODERATE_FLOOR,
			_max_ambush = DANGER_BLEAK_LIMIT,
			_fixed_ambush = FALSE,
			_lowpop_tick = 1,
			_highpop_tick = 1,
			_allowed_quest_types = list(QUEST_CLEAR_OUT, QUEST_RAID, QUEST_BOUNTY, QUEST_RECOVERY, QUEST_TOWNER_SMITH_CARAVAN, QUEST_TOWNER_MINER_OREVEIN),
			_tp_budget_multiplier = 1.5,
			_kill_target_floor = 3,
			_delivery_reward_multiplier = 2.0,
			_faction_weights = list(
				QUEST_FACTION_HELL_GOBLIN = 25,
				QUEST_FACTION_TARICHEA_DEADITE = 20,
				QUEST_FACTION_MOUNT_REAVER = 20,
				QUEST_FACTION_MOUNTAIN_TROLL = 15,
				QUEST_FACTION_MINOTAUR = 10,
				QUEST_FACTION_GREAT_BEAST = 5,
				QUEST_FACTION_MADMAN = 5,
			),
		)
	)

/datum/controller/subsystem/regionthreat/fire(resumed)
	var/player_count = GLOB.player_list.len
	var/ishighpop = player_count >= LOWPOP_THRESHOLD
	for(var/T in threat_regions)
		var/datum/threat_region/TR = T
		if(ishighpop)
			TR.increase_latent_ambush(TR.highpop_tick)
		else
			TR.increase_latent_ambush(TR.lowpop_tick)

/datum/controller/subsystem/regionthreat/proc/get_region(region_name)
	for(var/T in threat_regions)
		var/datum/threat_region/TR = T
		if(TR.region_name == region_name)
			return TR
	return null

/// Weighted pick of a region that allows the given quest type, weighted by fill ratio
/// (latent_ambush / max_ambush). Regions with more relative threat are picked more often, so
/// as adventurers clear a region its quest share naturally drops. Returns null if no region
/// allows the type.
/datum/controller/subsystem/regionthreat/proc/pick_region_for_quest(quest_type)
	var/list/weights = list()
	for(var/T in threat_regions)
		var/datum/threat_region/TR = T
		if(!TR.allows_quest_type(quest_type))
			continue
		var/weight = TR.get_threat_weight()
		if(weight <= 0)
			continue
		weights[TR] = weight
	if(!length(weights))
		// Fall back: any region that allows the type, ignoring fill ratio.
		for(var/T in threat_regions)
			var/datum/threat_region/TR = T
			if(TR.allows_quest_type(quest_type))
				weights[TR] = 1
		if(!length(weights))
			return null
	return pickweight(weights)

/datum/threat_region_display
	var/region_name
	var/danger_level
	var/danger_color

/datum/controller/subsystem/regionthreat/proc/get_threat_regions_for_display()
	var/list/threat_region_displays = list()
	for(var/T in threat_regions)
		var/datum/threat_region/TR = T
		var/datum/threat_region_display/TRS = new /datum/threat_region_display
		TRS.region_name = TR.region_name
		TRS.danger_level = TR.get_danger_level()
		TRS.danger_color = TR.get_danger_color()
		threat_region_displays += TRS
	return threat_region_displays
