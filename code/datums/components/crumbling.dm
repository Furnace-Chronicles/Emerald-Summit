//If you have this, everything on your person begins to crumble away slowly
/datum/component/crumbling
	

/datum/component/crumbling/Initialize()
	. = ..()
	if(ismob(parent))
		var/mob/living/carbon/human/skeleton = parent
		var/list/items_to_corrupt = skeleton.get_equipped_items()
		items_to_corrupt += skeleton.get_held_items()
		for(var/obj/O in items_to_corrupt)
			O.AddComponent(/datum/component/crumbling)
		
/datum/component/crumbling/proc/activate()
	if(ismob(parent))
		var/mob/living/carbon/human/skeleton = parent
		var/list/items_to_corrupt = skeleton.get_equipped_items()
		items_to_corrupt += skeleton.get_held_items()
		for(var/obj/O in items_to_corrupt)
			addtimer(CALLBACK(src, PROC_REF(trigger), O), pick(1 MINUTES, 3 MINUTES))
		addtimer(CALLBACK(src, PROC_REF(trigger), skeleton), pick(3 MINUTES, 5 MINUTES))
	else 
		if(isobj(parent))
			activate(parent)


/datum/component/crumbling/proc/trigger(var/atom/movable/thing)
	thing.visible_message(span_notice("\the [thing] crumbles away to nothingness."))
	thing.particles += new/particles/crumbling
	var/obj/particle_emitter/emitter = thing.MakeParticleEmitter(/particles/crumbling, TRUE)
	emitter.appearance_flags = RESET_TRANSFORM
	thing.vis_contents += emitter
	var/SLEEPtime = pick(10 SECONDS, 30 SECONDS)
	animate(thing, alpha= 0, time = SLEEPtime)
	QDEL_IN(thing, SLEEPtime+1)
 

/particles/crumbling
	width = 64
	height = 64
	count = 30
	spawning = 2
	lifespan = 10
	position = generator("circle", 16, -16)
	gravity = list(0,1)
	drift = generator("circle" ,-0.5, 0.5)
	fade = 3

	fadein = 2
	color = "#0a0a0ab0"

/obj/item/dropped() //EVIL override
	..()
	var/datum/component/crumbling/C = GetComponent(/datum/component/crumbling) //Covers dropped weapons, basically.
	if(C)
		C.activate()
/mob/living/carbon/human/species/skeleton/death()
	..()
	var/datum/component/crumbling/C = GetComponent(/datum/component/crumbling)
	if(C)
		C.activate()
