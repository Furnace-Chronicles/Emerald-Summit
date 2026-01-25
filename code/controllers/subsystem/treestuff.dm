SUBSYSTEM_DEF(treesetup)
	name = "treesetup"
	init_order = INIT_ORDER_TREES
	flags = SS_NO_FIRE

	var/list/initialize_me = list()

/datum/controller/subsystem/treesetup/Initialize(timeofday)
	var/msg = "TREES: Building [length(initialize_me)] trees."
	to_chat_immediate(GLOB.admins, span_admin(msg))
	log_world(msg)

	InitializeTrees()
	return ..()

/datum/controller/subsystem/treesetup/proc/InitializeTrees()
	for(var/obj/structure/flora/newtree/T as anything in initialize_me)
		T.build_branches()
		CHECK_TICK

	for(var/obj/structure/flora/newtree/T as anything in initialize_me)
		T.build_leafs()
		CHECK_TICK

	initialize_me = list()
