// AP Quest 2 port - Chunk 3 MINIMAL shell: landmark registry only.
// The full quest-generation pool (pool/regen/fire/ledgers, init_quest_factions, kill+evergreen
// targeting; ~590 lines) lands in Chunk 4 and REPLACES this file. Landmarks self-register here
// (quest_spawner Initialize/Destroy) so the type index is ready when generation is wired up.
SUBSYSTEM_DEF(questpool)
	name = "Quest Pool"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_DEFAULT
	var/list/landmarks_by_type = list()

/datum/controller/subsystem/questpool/Initialize()
	for(var/obj/effect/landmark/quest_spawner/landmark as anything in GLOB.quest_landmarks_list)
		register_landmark(landmark)
	return ..()

/datum/controller/subsystem/questpool/proc/register_landmark(obj/effect/landmark/quest_spawner/landmark)
	if(!landmark?.quest_type)
		return
	for(var/qtype in landmark.quest_type)
		var/list/bucket = landmarks_by_type[qtype]
		if(!bucket)
			bucket = list()
			landmarks_by_type[qtype] = bucket
		bucket |= landmark

/datum/controller/subsystem/questpool/proc/unregister_landmark(obj/effect/landmark/quest_spawner/landmark)
	if(!landmark?.quest_type)
		return
	for(var/qtype in landmark.quest_type)
		var/list/bucket = landmarks_by_type[qtype]
		if(!bucket)
			continue
		bucket -= landmark
		if(!length(bucket))
			landmarks_by_type -= qtype

