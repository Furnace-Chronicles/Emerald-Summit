// Some species datums are never directly spawned and thus don't need changesource flags. Need to update this test to identify them and skip them.

// /datum/unit_test/species_whitelist_check/Run()
// 	for(var/typepath in subtypesof(/datum/species))
// 		var/datum/species/S = typepath
// 		if(initial(S.changesource_flags) == NONE)
// 			Fail("A species type was detected with no changesource flags: [S]")
