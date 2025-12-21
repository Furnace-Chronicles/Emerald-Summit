/datum/advclass/pioneer //minecraft griefer class that tnts your house dog and ass
	name = "Pioneer"
	tutorial = "Pioneers redraw the battlefield. They cut roads through obstacles, unhinge gates, and lace the ground with clever devices-making allies swift and enemies slow."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	outfit = /datum/outfit/job/bandit/pioneer
	category_tags = list(CTAG_BANDIT)
	cmode_music = 'sound/music/combat_bandit.ogg'

	subclass_stats = list(
		STATKEY_INT = 3,
		STATKEY_LCK = 1,
		STATKEY_STR = 2,
		STATKEY_CON = 2,
		STATKEY_PER = 2,
		STATKEY_END = 2 //a lot of stats but no any traits, literally
	)

	subclass_skills = list(
		/datum/skill/combat/bows = SKILL_LEVEL_MASTER,
		/datum/skill/combat/crossbows = SKILL_LEVEL_MASTER,
		/datum/skill/combat/polearms = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/axes = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/maces = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/knives = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/wrestling = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/craft/crafting = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/craft/carpentry = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/labor/lumberjacking = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/craft/masonry = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/athletics = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/reading = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/lockpicking = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/craft/engineering = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/craft/blacksmithing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/craft/armorsmithing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/craft/weaponsmithing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/craft/smelting = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/labor/mining = SKILL_LEVEL_JOURNEYMAN
		
	)


/datum/outfit/job/bandit/pioneer/pre_equip(mob/living/carbon/human/H)
	..()
	if (!(istype(H.patron, /datum/patron/inhumen/zizo) || istype(H.patron, /datum/patron/inhumen/matthios) || istype(H.patron, /datum/patron/inhumen/graggar) || istype(H.patron, /datum/patron/inhumen/baotha)))
		to_chat(H, span_warning("My former deity has abandoned me.. Matthios is my new master."))
		H.set_patron(/datum/patron/inhumen/matthios)
	belt =	/obj/item/storage/belt/rogue/leather
	head = /obj/item/clothing/head/roguetown/helmet/kettle
	pants = /obj/item/clothing/under/roguetown/trou/leather
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/councillor //gambeson but black
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor //toe safety first
	mask = /obj/item/clothing/mask/rogue/facemask/steel
	neck = /obj/item/clothing/neck/roguetown/coif
	gloves = /obj/item/clothing/gloves/roguetown/angle/grenzelgloves/blacksmith
	armor = /obj/item/clothing/suit/roguetown/armor/leather/studded
	backl = /obj/item/storage/backpack/rogue/backpack/
	backr = /obj/item/rogueweapon/shovel/saperka //40 force +1.5 dmg SMASH but SLOW. If your enemy is a mental retard and stays on one place you delete them
	beltl = /obj/item/rogueweapon/pick/steel
	beltr = /obj/item/flashlight/flare/torch/lantern
	backpack_contents = list(
		/obj/item/lockpickring/mundane = 1,
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/restraints/legcuffs/beartrap = 2,
		/obj/item/flint = 1,
		/obj/item/rogueore/coal=1,
		/obj/item/rogueore/iron=1,
		/obj/item/rogueweapon/hammer/iron = 1,
		/obj/item/rogueweapon/tongs = 1
	)
	id = /obj/item/scomstone/mattcoin
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/pioneer/plant_bogtrap_delayed)

// Their snowflake mine//

/obj/effect/proc_holder/spell/targeted/pioneer/plant_bogtrap_delayed
	name = "Set Bogtrap (Delayed)"
	desc = "After 60 seconds, a bogtrap arms beneath your feet."
	range = 0
	overlay_state = "trap"
	releasedrain = 0
	recharge_time = 90 SECONDS
	max_targets = 0
	cast_without_targets = TRUE
	antimagic_allowed = TRUE
	associated_skill = /datum/skill/craft/traps
	invocation = "Measure twice… set once."
	invocation_type = "whisper"
	miracle = FALSE
	req_items = list(/obj/item/rogueweapon/shovel/)

	var/setup_delay = 30 SECONDS
	var/pending = FALSE
	var/trap_path = /obj/structure/trap/bogtrap/bomb

/obj/effect/proc_holder/spell/targeted/pioneer/plant_bogtrap_delayed/proc/_has_saperka(mob/living/user)
	for(var/obj/item/rogueweapon/shovel/saperka/S in user)
		return TRUE
	return FALSE

/obj/effect/proc_holder/spell/targeted/pioneer/plant_bogtrap_delayed/proc/_clear_existing_bogtrap(turf/T) //no 1000 traps on one tile
	if(!T) return
	for(var/obj/structure/trap/bogtrap/BT in T)
		qdel(BT)

/obj/effect/proc_holder/spell/targeted/pioneer/plant_bogtrap_delayed/proc/_spawn_bogtrap(turf/T, trap_path)
	if(!T || !trap_path) return
	var/obj/structure/trap/bogtrap/B = new trap_path(T)
	B.armed = TRUE
	B.alpha = 100
	B.update_icon()

/obj/effect/proc_holder/spell/targeted/pioneer/plant_bogtrap_delayed/proc/_is_town_blocked(turf/T)
	if(!T) return TRUE
	var/area/A = get_area(T)
	return istype(A, /area/rogue/outdoors/town)

/obj/effect/proc_holder/spell/targeted/pioneer/plant_bogtrap_delayed/cast(list/targets, mob/living/user = usr)
	. = ..()
	if(!isliving(user))
		return FALSE

	if(pending)
		to_chat(user, span_warning("I'm already rigging a delayed charge!"))
		return FALSE

	if(!_has_saperka(user))
		to_chat(user, span_warning("I need a shovel to set this trap."))
		revert_cast()
		return FALSE

	var/turf/T = get_turf(user)
	if(!T || !isturf(T))
		revert_cast()
		return FALSE

	if(_is_town_blocked(T))
		to_chat(user, span_warning("I cannot set a bogtrap here; the ground is too hard."))
		revert_cast()
		return FALSE

	for(var/obj/structure/fluff/traveltile/TT in range(1, T))
		to_chat(user, span_warning("Should find better place to set up the trap."))
		revert_cast()
		return FALSE

	var/list/trap_choices = list(
		"Bomb"         = /obj/structure/trap/bogtrap/bomb,
		"Frost"        = /obj/structure/trap/bogtrap/freeze,
		"Kneestingers" = /obj/structure/trap/bogtrap/kneestingers,
		"Toxic"        = /obj/structure/trap/bogtrap/poison
	)

	var/choice = input(user, "Select the trap type to rig:", "Bogtrap") as null|anything in trap_choices
	if(!choice)
		revert_cast()
		return FALSE

	var/trap_path = trap_choices[choice]

	pending = TRUE

	user.visible_message(
		span_notice("[user] kneels and starts rigging something beneath their feet…"),
		span_notice("I begin setting a [choice] bogtrap.")
	)
	playsound(user, 'sound/misc/clockloop.ogg', 50, TRUE)

	if(!do_after(user, setup_delay, target = T))
		pending = FALSE
		to_chat(user, span_warning("I stop setting the bogtrap."))
		revert_cast()
		return FALSE

	for(var/obj/structure/fluff/traveltile/TT in range(1, T))
		pending = FALSE
		to_chat(user, span_warning("Should find better place to set up the trap."))
		revert_cast()
		return FALSE

	_clear_existing_bogtrap(T)
	_spawn_bogtrap(T, trap_path)

	user.visible_message(
		span_warning("A hidden mechanism clicks into place under [user]!"),
		span_notice("The [choice] bogtrap arms beneath my feet.")
	)
	playsound(T, 'sound/misc/chains.ogg', 50, TRUE)

	pending = FALSE
	return TRUE
