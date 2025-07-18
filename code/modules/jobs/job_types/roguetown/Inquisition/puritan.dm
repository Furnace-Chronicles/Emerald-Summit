/datum/job/roguetown/puritan
	title = "Inquisitor"
	flag = PURITAN
	department_flag = INQUISITION
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_SHUNNED_UP//You're not doing good work. You are the bad guy, to be frank.
	allowed_patrons = ALL_DIVINE_PATRONS //psydon is dead confirmed
	tutorial = "You have been sent here as an envoy from the Sovereignty of Holy see of the Ten : a silver-tipped olive branch, unmatched in aptitude and unshakable in faith to the Ten. Though you might be ostracized due to your overzealous beliefs, neither the Church nor Crown can deny your value, whenever matters of inhumenity arise to threaten this fief."
	whitelist_req = TRUE
	cmode_music = 'sound/music/inquisitorcombat.ogg'
	selection_color = JCOLOR_INQUISITION

	outfit = /datum/outfit/job/roguetown/puritan
	display_order = JDO_PURITAN
	advclass_cat_rolls = list(CTAG_PURITAN = 20)
	give_bank_account = 30
	min_pq = 10
	max_pq = null
	round_contrib_points = 2
	var/inquisition_points = 15

/datum/outfit/job/roguetown/puritan
	name = "Inquisitor"
	jobtype = /datum/job/roguetown/puritan
	job_bitflag = BITFLAG_CHURCH	//Counts as church.

/datum/job/roguetown/puritan/after_spawn(mob/living/L, mob/M, latejoin = TRUE)
	. = ..()
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		H.grant_language(/datum/language/otavan)
		H.advsetup = 1
		H.invisibility = INVISIBILITY_MAXIMUM
		H.become_blind("advsetup")
		var/datum/devotion/C = new /datum/devotion(H, H.patron)
		C.grant_miracles(H, cleric_tier = CLERIC_T1, passive_gain = FALSE, devotion_limit = CLERIC_REQ_1)	//Capped to T1 miracles.



////Classic Inquisitor with a much more underground twist. Use listening devices, sneak into places to gather evidence, track down suspicious individuals. Has relatively the same utility stats as Confessor, but fulfills a different niche in terms of their combative job as the head honcho.

/datum/advclass/puritan/inspector
	name = "Inquisitor"
	tutorial = "Investigators from countless backgrounds, personally chosen by the High Bishop of the Otavan Sovereignty to root out heresy all across the world. Dressed in fashionable leathers and armed with a plethora of equipment, these beplumed officers are ready to tackle the inhumen: anywhere, anytime. Ideal for those who prefer sleuthy-and-clandestine affairs."
	outfit = /datum/outfit/job/roguetown/puritan/inspector

	category_tags = list(CTAG_PURITAN)

/datum/outfit/job/roguetown/puritan/inspector/pre_equip(mob/living/carbon/human/H)
	..()
	H.adjust_skillrank(/datum/skill/misc/lockpicking, 5, TRUE)
	H.adjust_skillrank(/datum/skill/misc/tracking, 5, TRUE)
	H.adjust_skillrank(/datum/skill/misc/sneaking, 5, TRUE)
	H.adjust_skillrank(/datum/skill/combat/swords, 4, TRUE)
	H.adjust_skillrank(/datum/skill/combat/whipsflails, 4, TRUE)
	H.adjust_skillrank(/datum/skill/combat/knives, 4, TRUE)
	H.adjust_skillrank(/datum/skill/misc/climbing, 4, TRUE)
	H.adjust_skillrank(/datum/skill/misc/athletics, 4, TRUE)
	H.adjust_skillrank(/datum/skill/combat/crossbows, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/unarmed, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/shields, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/reading, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/medicine, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/sewing, 2, TRUE)
	H.change_stat("strength", 2)
	H.change_stat("endurance", 2)
	H.change_stat("constitution", 3)
	H.change_stat("perception", 3)
	H.change_stat("speed", 1)
	H.change_stat("intelligence", 3)
	H.verbs |= /mob/living/carbon/human/proc/torture_victim
	ADD_TRAIT(H, TRAIT_STEELHEARTED, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_MEDIUMARMOR, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_SILVER_BLESSED, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_INQUISITION, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_PERFECT_TRACKER, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_PURITAN, JOB_TRAIT)
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/puritan
	belt = /obj/item/storage/belt/rogue/leather/knifebelt/black/psydon
	neck = /obj/item/clothing/neck/roguetown/gorget
	shoes = /obj/item/clothing/shoes/roguetown/boots/otavan/inqboots
	pants = /obj/item/clothing/under/roguetown/heavy_leather_pants
	backr = /obj/item/storage/backpack/rogue/satchel
	backl = /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow
	beltr = /obj/item/quiver/bolts
	head = /obj/item/clothing/head/roguetown/inqhat
	gloves = /obj/item/clothing/gloves/roguetown/otavan/inqgloves
	beltl = /obj/item/rogueweapon/sword/rapier
	armor = /obj/item/clothing/suit/roguetown/armor/plate/scale/inqcoat

	backpack_contents = list(/obj/item/storage/keyring/puritan = 1, /obj/item/lockpickring/mundane = 1, /obj/item/rogueweapon/huntingknife/idagger/silver/psydagger, /obj/item/grapplinghook = 1, /obj/item/storage/belt/rogue/pouch/coins/rich = 1, /obj/item/clothing/neck/roguetown/psicross/silver = 1, /obj/item/storage/roguebag) //these will be renamed to show that Psydon is dead after the next knife update



///The dirty, violent side of the Inquisition. Meant for confrontational, conflict-driven situations as opposed to simply sneaking around and asking questions. Templar with none of the miracles, but with all the muscles and more.

/datum/advclass/puritan/ordinator
	name = "Ordinator"
	tutorial = "Adjudicators who - through valor and martiality - have proven themselves to be champions in all-but-name. Now, they have been personally chosen by the High Bishop of the Otavan Sovereignty for a mission-most-imperative: to hunt down and destroy the monsters threatening this fief. Ideal for those who prefer overt-and-chivalrous affairs."
	outfit = /datum/outfit/job/roguetown/puritan/ordinator
	cmode_music = 'sound/music/combat_inqordinator.ogg'

	category_tags = list(CTAG_PURITAN)

/datum/outfit/job/roguetown/puritan/ordinator/pre_equip(mob/living/carbon/human/H)
	..()
	H.adjust_skillrank(/datum/skill/misc/lockpicking, 5, TRUE)
	H.adjust_skillrank(/datum/skill/misc/tracking, 5, TRUE)
	H.adjust_skillrank(/datum/skill/misc/sneaking, 5, TRUE)
	H.adjust_skillrank(/datum/skill/combat/swords, 4, TRUE)
	H.adjust_skillrank(/datum/skill/combat/whipsflails, 4, TRUE)
	H.adjust_skillrank(/datum/skill/combat/knives, 4, TRUE)
	H.adjust_skillrank(/datum/skill/misc/climbing, 4, TRUE)
	H.adjust_skillrank(/datum/skill/misc/athletics, 4, TRUE)
	H.adjust_skillrank(/datum/skill/combat/crossbows, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/unarmed, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/shields, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/reading, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/medicine, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/sewing, 2, TRUE)
	H.change_stat("strength", 2)
	H.change_stat("endurance", 2)
	H.change_stat("constitution", 3)
	H.change_stat("perception", 3)
	H.change_stat("speed", 1)
	H.change_stat("intelligence", 3)
	H.verbs |= /mob/living/carbon/human/proc/torture_victim
	ADD_TRAIT(H, TRAIT_STEELHEARTED, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_MEDIUMARMOR, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_SILVER_BLESSED, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_INQUISITION, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_PERFECT_TRACKER, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_PURITAN, JOB_TRAIT)
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	armor = /obj/item/clothing/suit/roguetown/armor/plate/half/fluted/ornate
	belt = /obj/item/storage/belt/rogue/leather/steel
	neck = /obj/item/clothing/neck/roguetown/chaincoif/chainmantle
	shoes = /obj/item/clothing/shoes/roguetown/boots/otavan/inqboots
	pants = /obj/item/clothing/under/roguetown/chainlegs/kilt
	cloak = /obj/item/clothing/cloak/cape/puritan
	backr = /obj/item/storage/backpack/rogue/satchel/black
	backl = /obj/item/rogueweapon/shield/tower/metal
	beltr = /obj/item/storage/belt/rogue/pouch/coins/rich
	head = /obj/item/clothing/head/roguetown/helmet/heavy/psydonhelm
	gloves = /obj/item/clothing/gloves/roguetown/otavan/inqgloves
	beltl = /obj/item/rogueweapon/sword/long/psysword

	backpack_contents = list(/obj/item/storage/keyring/puritan = 1, /obj/item/lockpickring/mundane = 1, /obj/item/rogueweapon/huntingknife/idagger/silver/psydagger/preblessed, /obj/item/grapplinghook = 1, /obj/item/storage/belt/rogue/pouch/coins/rich = 1)

/obj/item/clothing/gloves/roguetown/chain/blk
		color = CLOTHING_GREY

/obj/item/clothing/under/roguetown/chainlegs/blk
		color = CLOTHING_GREY

/obj/item/clothing/suit/roguetown/armor/plate/blk
		color = CLOTHING_GREY

/obj/item/clothing/shoes/roguetown/boots/armor/blk
		color = CLOTHING_GREY


/datum/advclass/puritan/untouchable //Incompetent morons that find themselves
	name = "Untouchable"
	tutorial = "Noble families will at times send their misborn, incompetent successors too important to simply prune like any misborn branch, yet too much of a failure to entrust with any bureaucratic duties. The Holy Inquisition appreciates the grand donations that accompany these buffoons."
	outfit = /datum/outfit/job/roguetown/puritan/untouchable

	category_tags = list(CTAG_PURITAN)

/datum/outfit/job/roguetown/puritan/untouchable/pre_equip(mob/living/carbon/human/H)
	..()
	H.adjust_skillrank(/datum/skill/misc/lockpicking, 5, TRUE)
	H.adjust_skillrank(/datum/skill/misc/climbing, 5, TRUE)
	H.adjust_skillrank(/datum/skill/misc/sneaking, 5, TRUE)
	H.adjust_skillrank(/datum/skill/misc/tracking, 5, TRUE)
	H.adjust_skillrank(/datum/skill/misc/athletics, 4, TRUE)
	H.adjust_skillrank(/datum/skill/misc/reading, 5, TRUE)
	H.adjust_skillrank(/datum/skill/misc/medicine, 4, TRUE)
	H.adjust_skillrank(/datum/skill/misc/sewing, 4, TRUE)
	H.change_stat("speed", 7)
	H.change_stat("intelligence", -3)
	H.verbs |= /mob/living/carbon/human/proc/torture_victim
	ADD_TRAIT(H, TRAIT_STEELHEARTED, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_DODGEEXPERT, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_SILVER_BLESSED, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_INQUISITION, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_PURITAN, JOB_TRAIT)
	ADD_TRAIT(H, TRAIT_NOBLE, TRAIT_GENERIC)
	pants = /obj/item/clothing/under/roguetown/tights
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/guard
	shoes = /obj/item/clothing/shoes/roguetown/shortboots
	backl = /obj/item/storage/backpack/rogue/satchel
	belt = /obj/item/storage/belt/rogue/leather
	id = /obj/item/scomstone/bad
	backpack_contents = list(/obj/item/storage/keyring/puritan = 1, /obj/item/grapplinghook = 1, /obj/item/storage/roguebag) //these will be renamed to show that Psydon is dead after the next knife update
	GLOB.inquisition_points += 10

/mob/living/carbon/human/proc/torture_victim()
	set name = "Interrogate"
	set category = "Inquisition"
	var/obj/item/grabbing/I = get_active_held_item()
	var/mob/living/carbon/human/H
	if(!istype(I) || !ishuman(I.grabbed))
		to_chat(src, span_warning("I don't have a victim in my hands!"))
		return
	H = I.grabbed
	if(H == src)
		to_chat(src, span_warning("I already torture myself."))
		return
	if(H.stat == DEAD)
		to_chat(src, span_warning("[H] is dead already..."))
		return
	if(!H.stat)
		SEND_SIGNAL(src, COMSIG_TORTURE_PERFORMED, H)
		H.emote("agony", forced = TRUE)
		H.add_stress(/datum/stressevent/tortured)
		H.interrogation(src) //Reach for the skies, immortal smoke!
		return
	to_chat(src, span_warning("This one is not in a ready state to be questioned..."))

/mob/living/carbon/human/proc/interrogation(mob/living/carbon/human/interrogator)
	if(stat == DEAD)
		return
	var/resist_chance = 0
	var/mob/living/carbon/human/H = src
	//Why anyone thought that someone wouldn't want to resist torture is beyond me.
	resist_chance = (STAINT + STAEND) + 10
	if(istype(buckled, /obj/structure/fluff/walldeco/chains))		// If the victim is on hanging chains, apply a resist penalty
		resist_chance -= 10
	if(H.has_status_effect(/datum/status_effect/buff/drunk))		// Loose lips sink ships.
		resist_chance -= 10
	if(H.has_status_effect(/datum/status_effect/debuff/revived))	//Weakened body and mind
		resist_chance -= 5
	if(H.has_status_effect(/datum/status_effect/debuff/devitalised))	//Weakened soul and mind
		resist_chance -= 10
	if(HAS_TRAIT(H, TRAIT_DECEIVING_MEEKNESS))						// Guarded bonus. You're very good at keeping your lips tight.
		resist_chance += 45
	if(HAS_TRAIT(H, TRAIT_CRITICAL_WEAKNESS))						// Negative for being bully-bait.
		resist_chance -= 15
	if(HAS_TRAIT(H, TRAIT_NOPAIN)) //Logic
		resist_chance += 115
	var/painpercent = (H.get_complex_pain() / (H.STAEND * 10)) * 100
	if(painpercent < 100)											// If beaten/badly wounded, penalty.
		resist_chance -= 15

	if(!prob(resist_chance))
		var/datum/patron/victim_patron = src.patron
		if(istype(victim_patron, /datum/patron/inhumen/zizo))
			if(prob(20))
				src.praise_zizo()
			else
				var/list/cult_list = list()
				for(var/mob/living/cultist in GLOB.player_list)
					if(istype(cultist.patron, /datum/patron/inhumen/zizo))
						cult_list += cultist.real_name
				var/cultist_name = pick(cult_list)
				say("[cultist_name]!", spans = list("torture"), forced = TRUE)

			return
		else if(istype(victim_patron, /datum/patron/old_god))//It only really makes sense for psydonites to have confession lines tbqh
			say(pick(victim_patron.confess_lines), spans = list("torture"), forced = TRUE)
			//They're 'mostly' innocent or unaffiliated with any organized cult movement
			//A false confession
		else
			var/list/people_list = list()
			for(var/mob/living/character in GLOB.player_list)
				people_list += character.real_name
			var/person_name = pick(people_list)
			say("[person_name]!", spans = list("torture"), forced = TRUE)
	else
		to_chat(src, span_good("I resist the torture!"))
		to_chat(interrogator, span_warning("I need to hurt them MORE."))
	return
