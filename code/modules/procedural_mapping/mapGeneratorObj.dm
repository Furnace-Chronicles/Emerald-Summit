/obj/effect/landmark/mapGenerator
	var/startTurfX = 0
	var/startTurfY = 0
	var/startTurfZ = -1
	var/endTurfX = 0
	var/endTurfY = 0
	var/endTurfZ = -1
	var/mapGeneratorType = /datum/mapGenerator/beach
	var/datum/mapGenerator/mapGenerator

// These things suck. They really should be defined somewhere else, such as the map json.
// if we do that, we might be able to run them earlier than SSatoms and not have to in-place initialize everything.
/obj/effect/landmark/mapGenerator/Initialize(mapload)
	..()
	if(startTurfZ < 0)
		startTurfZ = z
	if(endTurfZ < 0)
		endTurfZ = z
	mapGenerator = new mapGeneratorType()
	mapGenerator.defineRegion(locate(startTurfX,startTurfY,startTurfZ), locate(endTurfX,endTurfY,endTurfZ))
	SSmap_procgen.queue_map_generator(mapGenerator)
	return INITIALIZE_HINT_QDEL

