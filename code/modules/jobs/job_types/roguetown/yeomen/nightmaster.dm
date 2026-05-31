/datum/job/roguetown/niteman
	title = "Nightmaster"
	f_title = "Nightmistress"
	flag = NITEMASTER
	department_flag = YEOMEN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	allowed_races = RACES_ALL_KINDS
	tutorial = "You own the brothel in the city. You provide security to the nightmaidens and help them to find work-- when you're not being a trouble-making rake that others suffer to tolerate."
	allowed_sexes = list(MALE, FEMALE)
	outfit = /datum/outfit/job/niteman
	display_order = JDO_NITEMASTER
	give_bank_account = 150
	min_pq = 10
	max_pq = null
	bypass_lastclass = TRUE
	round_contrib_points = 3
	social_rank = SOCIAL_RANK_YEOMAN

	job_traits = list(TRAIT_SEEPRICES_SHITTY, TRAIT_CICERONE, TRAIT_NUTCRACKER, TRAIT_GOODLOVER)

	advclass_cat_rolls = list(CTAG_BATHMOM = 2)
	job_subclasses = list(
		/datum/advclass/bathmaster
	)

/datum/advclass/bathmaster
	name = "Bathmaster"
	tutorial = "You are renting out the bathhouse in a joint operation with the Innkeep. You provide security for the bathwenches and help them to find work--when you're not being a trouble-making rake that others suffer to tolerate."
	outfit = /datum/outfit/job/niteman/basic
	category_tags = list(CTAG_BATHMOM)

	subclass_languages = list(
		/datum/language/thievescant,
	)

	subclass_stats = list(
		STATKEY_END = 2,
		STATKEY_STR = 1,
		STATKEY_CON = 1,
		STATKEY_INT = -1
	)

	subclass_skills = list(
		/datum/skill/combat/wrestling = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/unarmed = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/whipsflails = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/reading = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/sneaking = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/stealing = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/lockpicking = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/climbing = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/medicine = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/riding = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/swimming = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/athletics = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/knives = SKILL_LEVEL_JOURNEYMAN,
	)

/datum/outfit/job/niteman/basic/pre_equip(mob/living/carbon/human/H)
	..()
	H.adjust_blindness(-3)
	head = /obj/item/lockpick/goldpin/silver
	shoes = /obj/item/clothing/shoes/roguetown/boots
	belt = /obj/item/storage/belt/rogue/leather/black
	shirt = /obj/item/clothing/suit/roguetown/shirt/tunic/purple
	wrists = /obj/item/storage/keyring/nightman
	neck = /obj/item/storage/belt/rogue/pouch/coins/rich
	pants = /obj/item/clothing/under/roguetown/trou/leather
	beltl = /obj/item/rogueweapon/whip

	backl = /obj/item/storage/backpack/rogue/satchel
	backpack_contents = list(/obj/item/reagent_containers/food/snacks/grown/rogue/swampweeddry = 2, /obj/item/reagent_containers/powder/moondust = 2, /obj/item/reagent_containers/powder/spice = 1)

	if(should_wear_masc_clothes(H))
		armor = /obj/item/clothing/suit/roguetown/armor/leather/vest/sailor/nightman
		H.dna.species.soundpack_m = new /datum/voicepack/male/zeth()
	else if(should_wear_femme_clothes(H))
		armor = /obj/item/clothing/suit/roguetown/armor/armordress/alt

	if(H.mind)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/bathhouse_appraisal)

// Emerald addition: tile-target spell that marks items for BRASSFACE vault income generation.
// Without this mark, items sitting on bathbricks in the vault don't contribute — prevents non-Nightmasters
// from abusing the brothel as a passive-income generator.
/obj/effect/proc_holder/spell/invoked/bathhouse_appraisal
	name = "Bathhouse Appraisal"
	desc = "Cast on a tile to inspect every item resting on it (and any items inside closets on that tile). Reports their value and estimated BRASSFACE vault income, then asks for confirmation before marking them. Only items I have personally appraised contribute to my BRASSFACE's passive income — without my mark, valuables are inert as far as the vault is concerned."
	overlay_state = "appraise"
	releasedrain = 5
	chargedrain = 0
	chargetime = 0
	range = 1
	warnie = "sydwarning"
	movement_interrupt = FALSE
	invocation_type = "none"
	associated_skill = /datum/skill/misc/reading
	antimagic_allowed = TRUE
	recharge_time = 3 SECONDS
	miracle = FALSE
	devotion_cost = 0

/obj/effect/proc_holder/spell/invoked/bathhouse_appraisal/cast(list/targets, mob/living/user)
	var/turf/T = get_turf(targets[1])
	if(!T)
		return
	// Collect every item directly on the turf plus items in any closet sitting on it — matches the
	// BRASSFACE income tick's collection scope so what the Nightmaster sees here is what gets counted.
	var/list/obj/item/found_items = list()
	for(var/obj/item/I in T.contents)
		if(!isturf(I.loc))
			continue
		found_items += I
	for(var/obj/structure/closet/closet in T.contents)
		for(var/obj/item/I in closet)
			found_items += I

	if(!length(found_items))
		to_chat(user, span_warning("Nothing of note rests here to appraise."))
		return

	// Pre-pass: figure out which items would actually contribute, and compute the preview before
	// committing. Items get marked only after the Nightmaster confirms.
	var/list/seen_types = list()
	var/list/messages = list()
	var/list/obj/item/to_mark = list()
	var/total_estimate = 0
	var/already_marked = 0

	for(var/obj/item/I in found_items)
		var/price = I.get_real_price()
		if(price <= 0 || istype(I, /obj/item/roguecoin))
			continue
		var/income_factor = SSBMtreasury.interest_rate
		var/duplicate_steps = seen_types[I.type]
		if(isnull(duplicate_steps))
			seen_types[I.type] = 0
		else
			duplicate_steps += 1
			seen_types[I.type] = duplicate_steps
			for(var/i = 1 to duplicate_steps)
				income_factor *= SSBMtreasury.multiple_item_penalty
		var/estimated_income = round(price * income_factor, 1)
		total_estimate += estimated_income
		if(I.bathhouse_appraised)
			already_marked += 1
		else
			to_mark += I
		messages += "&bull; [I.name] (value [price] mammons, est. +[estimated_income] mammons/tick)[I.bathhouse_appraised ? " <i>\[already marked\]</i>" : ""]"

	if(!length(messages))
		to_chat(user, span_warning("Nothing here has any vault value."))
		return

	// Show the preview, then ask for confirmation.
	to_chat(user, span_notice("<b>Bathhouse Appraisal of [T]:</b>"))
	for(var/line in messages)
		to_chat(user, span_info(line))
	to_chat(user, span_notice("Estimated total income from this tile: <b>+[total_estimate] mammons/tick</b>."))

	if(!length(to_mark))
		to_chat(user, span_smallnotice("Every item here is already appraised. Nothing to do."))
		return

	var/confirm = tgui_alert(user, "Appraise these [length(to_mark)] item\s?", "Bathhouse Appraisal", list("Yes", "No"))
	if(confirm != "Yes")
		to_chat(user, span_warning("Appraisal cancelled. No marks applied."))
		return

	// User confirmed — apply the mark. Re-verify each item still exists in case time passed during the prompt.
	var/marked_count = 0
	for(var/obj/item/I as anything in to_mark)
		if(QDELETED(I))
			continue
		if(I.bathhouse_appraised)
			continue
		I.bathhouse_appraised = TRUE
		marked_count += 1

	to_chat(user, span_notice("Marked [marked_count] item\s. Vault income ticks every 5-8 minutes."))

/obj/effect/proc_holder/spell/self/convertrole/prostitute
	name = "Hire Prostitute"
	new_role = "Nightswain"
	overlay_state = "recruit_servant"
	recruitment_faction = "Prostitute"
	recruitment_message = "Work for me, %RECRUIT."
	accept_message = "I will."
	refuse_message = "I refuse."
