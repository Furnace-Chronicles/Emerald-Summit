#define DISGRACE_KNIGHT_COOLDOWN (30 SECONDS)
#define FIRE_GUARD_COOLDOWN (30 SECONDS)

/datum/job/roguetown/hand
	title = "Hand"
	flag = HAND
	department_flag = NOBLEMEN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	allowed_races = RACES_ALL_KINDS	//Duke selects his hand.
	allowed_patrons = NON_PSYDON_PATRONS
	allowed_sexes = list(MALE, FEMALE)
	outfit = /datum/outfit/job/roguetown/hand
	advclass_cat_rolls = list(CTAG_HAND = 20)
	display_order = JDO_HAND
	tutorial = "Whether by outstanding merit or petty favoritism, you are the Archduke’s most trusted representative and advisor. Your authority is second only to the Archduke themselves. The weight of your words can shape policy, stir conflict, or silence dissent. Let none forget whose will you carry, and do not fail your benefactor."
	whitelist_req = TRUE
	give_bank_account = 44
	noble_income = 22
	min_pq = 20 //The second most powerful person in the realm...
	max_pq = null
	round_contrib_points = 3
	cmode_music = 'sound/music/combat_noble.ogg'
	social_rank = SOCIAL_RANK_NOBLE

	job_traits = list(TRAIT_NOBLE)
	job_subclasses = list(
		/datum/advclass/hand/hand,
		/datum/advclass/hand/spymaster,
		/datum/advclass/hand/advisor
	)

/*
/datum/job/roguetown/hand/special_job_check(mob/dead/new_player/player)
	if(!player)
		return
	if(!player.ckey)
		return
	for(var/mob/dead/new_player/Lord in GLOB.player_list)
		if(Lord.mind.assigned_role == "King")
			if(Lord.brohand == player.ckey)
				return TRUE
*/

/datum/outfit/job/roguetown/hand
	shoes = /obj/item/clothing/shoes/roguetown/boots
	belt = /obj/item/storage/belt/rogue/leather/steel
	r_hand = /obj/item/rogueweapon/sword/rapier/dec
	beltr = /obj/item/rogueweapon/scabbard/sword
	beltl = /obj/item/rogueweapon/scabbard/sheath
	job_bitflag = BITFLAG_ROYALTY

/datum/job/roguetown/hand/after_spawn(mob/living/L, mob/M, latejoin = TRUE)
	. = ..()
	if(L)
		var/mob/living/carbon/human/H = L
		if(istype(H))
			H.verbs |= list(/mob/living/carbon/human/proc/disgrace_knight, /mob/living/carbon/human/proc/fire_guard)
			H.hand_disgrace_cooldown = 0
			H.hand_fire_guard_cooldown = 0
	addtimer(CALLBACK(src, PROC_REF(know_agents), L), 5 SECONDS)

/datum/job/roguetown/hand/proc/know_agents(var/mob/living/carbon/human/H)
	if(!GLOB.court_agents.len)
		to_chat(H, span_notice("You begun the week with no agents."))
	else
		to_chat(H, span_notice("We begun the week with these agents:"))
		for(var/name in GLOB.court_agents)
			to_chat(H, span_notice(name))

// Disgrace Knight verb - available to Duke and Hand
/mob/living/carbon/human
	var/hand_disgrace_cooldown = 0
	var/hand_fire_guard_cooldown = 0

/mob/living/carbon/human/proc/disgrace_knight()
	set name = "Disgrace Knight"
	set category = "Nobility"

	if(stat)
		return

	// Check cooldown and show remaining time BEFORE input
	if(hand_disgrace_cooldown > world.time)
		to_chat(src, span_warning("I need to wait [DisplayTimeText(hand_disgrace_cooldown - world.time)] before disgracing another knight."))
		return FALSE

	// Must be in the throne room
	if(!istype(get_area(src), /area/rogue/indoors/town/manor))
		to_chat(src, span_warning("I need to do this from the keep's manor."))
		return FALSE

	var/inputty = input("Disgrace or restore a knight's honor. Enter their name:", "Knight Honor") as text|null
	if(!inputty)
		return

	// Find target knight
	var/mob/living/carbon/human/target
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H == src)
			continue
		if(H.real_name == inputty)
			target = H
			break

	if(!target)
		to_chat(src, span_warning("Could not find anyone by that name."))
		return FALSE

	// Check if target is actually a Knight or Knight Captain
	if(!(target.job == "Knight" || target.job == "Dame" || target.job == "Knight Captain"))
		to_chat(src, span_warning("[target.real_name] is not a knight."))
		return FALSE

	hand_disgrace_cooldown = world.time + DISGRACE_KNIGHT_COOLDOWN

	// If already disgraced, restore their honor
	if(HAS_TRAIT(target, TRAIT_DISGRACED_KNIGHT))
		REMOVE_TRAIT(target, TRAIT_DISGRACED_KNIGHT, TRAIT_GENERIC)
		target.remove_stress(/datum/stressevent/disgracedknight)
		target.remove_status_effect(/datum/status_effect/debuff/disgracedknight_town)
		target.remove_status_effect(/datum/status_effect/debuff/disgracedknight_keep)
		
		to_chat(target, span_notice("Your honor and knighthood have been restored by [real_name]!"))
		priority_announce("[real_name] has restored [inputty]'s honor and knighthood!", title = "Honor Restored", sound = 'sound/misc/bell.ogg')
		return TRUE

	// Otherwise, disgrace them
	ADD_TRAIT(target, TRAIT_DISGRACED_KNIGHT, TRAIT_GENERIC)
	target.add_stress(/datum/stressevent/disgracedknight)
	// Add two debuffs to cancel out the knight town and keep buffs because of the perma-testmerged PR
	// I'll fix this implementation after that PR gets merged, or closed.
	target.apply_status_effect(/datum/status_effect/debuff/disgracedknight_town)
	target.apply_status_effect(/datum/status_effect/debuff/disgracedknight_keep)
	
	to_chat(target, span_boldwarning("You have been stripped of your knighthood and honor by order of [real_name]!"))
	priority_announce("[real_name] has disgraced [inputty], stripping them of their knighthood!", title = "DISHONOR", sound = 'sound/misc/excomm.ogg')
	
	return TRUE

// Fire Guard verb - available to Duke, Hand, and Marshal
/mob/living/carbon/human/proc/fire_guard()
	set name = "Fire Guard"
	set category = "Nobility"

	if(stat)
		return

	// Check cooldown and show remaining time BEFORE input
	if(hand_fire_guard_cooldown > world.time)
		to_chat(src, span_warning("I need to wait [DisplayTimeText(hand_fire_guard_cooldown - world.time)] before firing another guard."))
		return FALSE

	var/inputty = input("Fire a guard from service. They cannot be re-hired. Enter their name:", "Fire Guard") as text|null
	if(!inputty)
		return

	// Find target
	var/mob/living/carbon/human/target
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H == src)
			continue
		if(H.real_name == inputty)
			target = H
			break

	if(!target)
		to_chat(src, span_warning("Could not find anyone by that name."))
		return FALSE

	// Check if target is actually a Man at Arms (guard with TRAIT_GUARDSMAN)
	if(!(target.job == "Man at Arms" || target.job == "Woman at Arms"))
		to_chat(src, span_warning("[target.real_name] is not a guard."))
		return FALSE

	if(!HAS_TRAIT(target, TRAIT_GUARDSMAN))
		to_chat(src, span_warning("[target.real_name] is not currently serving as a guard."))
		return FALSE

	hand_fire_guard_cooldown = world.time + FIRE_GUARD_COOLDOWN

	// Fire them - remove guard trait and change job to Towner
	REMOVE_TRAIT(target, TRAIT_GUARDSMAN, JOB_TRAIT)
	target.remove_status_effect(/datum/status_effect/buff/guardbuffone) // Remove the guard buff immediately
	target.job = "Towner"
	target.advjob = null // Clear their subclass so they don't show as their old advclass, yes I know this is hacky.
	if(target.mind)
		target.mind.assigned_role = "Towner"

	to_chat(target, span_boldwarning("You have been dismissed from the guard by [real_name]!"))
	priority_announce("[real_name] has dismissed [inputty] from the guard!", title = "Dismissal", sound = 'sound/misc/bell.ogg')

	return TRUE



/datum/advclass/hand/hand
	name = "Hand"
	tutorial = "You serve as both soldier and strategist to the Noble-Family, wielding steel and intrigue with potent ability. Let no man forget whose ear you whisper into, your stratagems have claimed more lives than any spymaster's plots ever could."
	outfit = /datum/outfit/job/roguetown/hand/handclassic

	category_tags = list(CTAG_HAND)

	traits_applied = list(TRAIT_STEELHEARTED, TRAIT_HEAVYARMOR)
	subclass_stats = list(
		STATKEY_PER = 3,
		STATKEY_INT = 3,
		STATKEY_STR = 2
	)

	subclass_skills = list(
		/datum/skill/combat/polearms = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/maces = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/crossbows = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/wrestling = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/unarmed = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/swords = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/swimming = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/lockpicking = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/athletics = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/reading = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/riding = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/tracking = SKILL_LEVEL_APPRENTICE,
	)

//Classical hand start - same as before, nothing changed.
/datum/outfit/job/roguetown/hand/handclassic/pre_equip(mob/living/carbon/human/H)
	..()
	H.dna.species.soundpack_m = new /datum/voicepack/male/tyrant()
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/guard
	backr = /obj/item/storage/backpack/rogue/satchel/black
	backpack_contents = list(/obj/item/rogueweapon/huntingknife/idagger/dtace = 1, /obj/item/storage/keyring/hand = 1)
	armor = /obj/item/clothing/suit/roguetown/armor/leather/vest/hand
	pants = /obj/item/clothing/under/roguetown/tights/black
	id = /obj/item/scomstone/garrison

/datum/advclass/hand/spymaster
	name = "Spymaster"
	tutorial = "You serve as both spymaster and confidant to the Noble-Family, wielding cloak and dagger schemes with potent ability. Let no man forget whose ear you whisper into, your plots have claimed more lives than any strategist's steel ever could."
	outfit = /datum/outfit/job/roguetown/hand/spymaster
	category_tags = list(CTAG_HAND)

	subclass_languages = list(
	/datum/language/thievescant,
	)

	traits_applied = list(TRAIT_MEDIUMARMOR, TRAIT_DODGEEXPERT, TRAIT_PERFECT_TRACKER, TRAIT_KEENEARS)
	subclass_stats = list(
		STATKEY_SPD = 3,
		STATKEY_PER = 2,
		STATKEY_INT = 2
	)

	subclass_skills = list(
		/datum/skill/combat/maces = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/crossbows = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/bows = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/wrestling = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/unarmed = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/swords = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/knives = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/swimming = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/climbing = SKILL_LEVEL_LEGENDARY,
		/datum/skill/misc/athletics = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/reading = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/riding = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/tracking = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/sneaking = SKILL_LEVEL_MASTER,
		/datum/skill/misc/stealing = SKILL_LEVEL_MASTER,
		/datum/skill/misc/lockpicking = SKILL_LEVEL_MASTER, // not like they're gonna break into the vault.
	)

//Spymaster start. More similar to the rogue adventurer - loses heavy armor for more sneaky stuff.
/datum/outfit/job/roguetown/hand/spymaster/pre_equip(mob/living/carbon/human/H)
	..()
	H.dna.species.soundpack_m = new /datum/voicepack/male/tyrant()
	backr = /obj/item/storage/backpack/rogue/satchel/black
	backpack_contents = list(/obj/item/rogueweapon/huntingknife/idagger/dtace = 1, /obj/item/storage/keyring/hand = 1, /obj/item/lockpickring/mundane)
	if(H.dna.species.type in NON_DWARVEN_RACE_TYPES)
		shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/shadowrobe
		cloak = /obj/item/clothing/cloak/half/shadowcloak
		gloves = /obj/item/clothing/gloves/roguetown/fingerless/shadowgloves
		mask = /obj/item/clothing/mask/rogue/shepherd/shadowmask
		pants = /obj/item/clothing/under/roguetown/trou/shadowpants
		id = /obj/item/scomstone/garrison
	else
		cloak = /obj/item/clothing/cloak/raincloak/mortus //cool spymaster cloak
		shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/guard
		backr = /obj/item/storage/backpack/rogue/satchel/black
		armor = /obj/item/clothing/suit/roguetown/armor/leather/vest/hand
		pants = /obj/item/clothing/under/roguetown/tights/black
		id = /obj/item/scomstone/garrison

/datum/advclass/hand/advisor
	name = "Advisor"
	tutorial = "You serve as both scholar and advisor to the Noble-Family, wielding knowledge and magicks with potent ability. Let no man forget whose ear you whisper into, your sage advice has saved more lives than any strategist's orders or spymaster's schemes could ever claim to."
	outfit = /datum/outfit/job/roguetown/hand/advisor
	category_tags = list(CTAG_HAND)

	traits_applied = list(TRAIT_MAGEARMOR, TRAIT_ARCYNE_T2, TRAIT_INTELLECTUAL, TRAIT_SEEPRICES_SHITTY)
	subclass_stats = list(
		STATKEY_INT = 4,
		STATKEY_PER = 3,
	)

	subclass_spellpoints = 15

	subclass_skills = list(
		/datum/skill/combat/crossbows = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/swords = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/swimming = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/athletics = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/wrestling = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/reading = SKILL_LEVEL_MASTER,
		/datum/skill/misc/riding = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/tracking = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/sneaking = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/craft/alchemy = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/medicine = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/lockpicking = SKILL_LEVEL_EXPERT,
		/datum/skill/magic/arcane = SKILL_LEVEL_APPRENTICE,
	)

//Advisor start. Trades combat skills for more knowledge and skills - for older hands, hands that don't do combat - people who wanna play wizened old advisors.
/datum/outfit/job/roguetown/hand/advisor/pre_equip(mob/living/carbon/human/H)
	..()
	H.dna.species.soundpack_m = new /datum/voicepack/male/tyrant()
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/guard
	backr = /obj/item/storage/backpack/rogue/satchel/black
	backpack_contents = list(/obj/item/rogueweapon/huntingknife/idagger/dtace = 1, /obj/item/storage/keyring/hand = 1, /obj/item/lockpickring/mundane = 1, /obj/item/reagent_containers/glass/bottle/rogue/poison = 1) //starts with a vial of poison, like all wizened evil advisors do!
	armor = /obj/item/clothing/suit/roguetown/armor/leather/vest/hand
	pants = /obj/item/clothing/under/roguetown/tights/black
	id = /obj/item/scomstone/garrison

	if(H.age == AGE_OLD)
		H.change_stat("speed", -1)
		H.change_stat("strength", -1)
		H.change_stat("intelligence", 1)
		H.change_stat("perception", 1)
		H?.mind.adjust_spellpoints(3)
