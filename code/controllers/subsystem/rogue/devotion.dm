/// DEFINITIONS ///
#define CLERIC_ORI -1
#define CLERIC_T0 0
#define CLERIC_T1 1
#define CLERIC_T2 2
#define CLERIC_T3 3
#define CLERIC_T4 4

#define CLERIC_REQ_0 0
#define CLERIC_REQ_1 250
#define CLERIC_REQ_2 400
#define CLERIC_REQ_3 750
#define CLERIC_REQ_4 1000

#define CLERIC_REGEN_DEVOTEE 0.3
#define CLERIC_REGEN_MINOR 0.5
#define CLERIC_REGEN_MAJOR 1
#define CLERIC_REGEN_ABSOLVER 5

// Cleric Holder Datums

/datum/devotion
	/// Mob that owns this datum
	var/mob/living/carbon/human/holder
	/// Patron this holder is for
	var/datum/patron/patron
	/// Current devotion we are holding
	var/devotion = 0
	/// Maximum devotion we can hold at once
	var/max_devotion = CLERIC_REQ_3 * 2
	/// Current progression (experience)
	var/progression = 0
	/// Maximum progression (experience) we can achieve
	var/max_progression = CLERIC_REQ_4
	/// Current spell tier, basically
	var/level = CLERIC_T0
	/// Last spell tier, to prevent duplicating miracles
	var/last_level = null
	/// How much devotion is gained per process call
	var/passive_devotion_gain = 0
	/// How much progression is gained per process call
	var/passive_progression_gain = 0
	/// How much devotion is gained per prayer cycle
	var/prayer_effectiveness = 2
	/// Spells we have granted thus far
	var/list/granted_spells

	/// Can pray everywhere (true) or church-only (false). Controlled by church core.
	var/allow_prayer_everywhere = FALSE
	/// Auto-regeneration toggle from church core (for clergy/renegade)
	var/auto_regen_enabled = FALSE
	/// +50% passive bonus toggle from church core
	var/passive_bonus_on = FALSE
	/// Manual learning tier for clergy: 0=only patron, 1=+divine, 2=+inhumen
	var/clergy_learn_tier = 0

/datum/devotion/New(mob/living/carbon/human/holder, datum/patron/patron)
	. = ..()
	src.holder = holder
	holder?.devotion = src
	src.patron = patron
	if (patron.type == /datum/patron/inhumen/zizo || patron.type == /datum/patron/divine/necra)
		ADD_TRAIT(holder, TRAIT_DEATHSIGHT, "devotion")

/datum/devotion/Destroy(force)
	. = ..()
	if (patron.type == /datum/patron/inhumen/zizo || patron.type == /datum/patron/divine/necra)
		REMOVE_TRAIT(holder, TRAIT_DEATHSIGHT, "devotion")
	holder?.devotion = null
	holder = null
	patron = null
	granted_spells = null
	STOP_PROCESSING(SSobj, src)

/datum/devotion/process()
	if(HAS_TRAIT(holder, TRAIT_CLERGY) || HAS_TRAIT(holder, TRAIT_RENEGADE))
		if(!auto_regen_enabled || (!passive_devotion_gain && !passive_progression_gain))
			return PROCESS_KILL
	else
		if(!passive_devotion_gain && !passive_progression_gain)
			return PROCESS_KILL

	var/mul = 1.0
	if(holder?.mind)
		mul += (holder.get_skill_level(/datum/skill/magic/holy) / SKILL_LEVEL_LEGENDARY)
	if(passive_bonus_on)
		mul *= 1.5

	update_devotion(passive_devotion_gain * mul, passive_progression_gain * mul, silent = TRUE)

/datum/devotion/proc/check_devotion(obj/effect/proc_holder/spell/spell)
	if(devotion - spell.devotion_cost < 0)
		return FALSE
	return TRUE

/datum/devotion/proc/update_devotion(dev_amt, prog_amt, silent = FALSE)
	devotion = clamp(devotion + dev_amt, 0, max_devotion)
	// Max devotion limit
	if((devotion >= max_devotion) && !silent)
		to_chat(holder, span_warning("I have reached the limit of my devotion..."))
	if(!prog_amt) // expenditure-only, no progression changes
		return TRUE

	progression = clamp(progression + prog_amt, 0, max_progression)
	switch(level)
		if(CLERIC_T0)
			if(progression >= CLERIC_REQ_1) level = CLERIC_T1
		if(CLERIC_T1)
			if(progression >= CLERIC_REQ_2) level = CLERIC_T2
		if(CLERIC_T2)
			if(progression >= CLERIC_REQ_3) level = CLERIC_T3
		if(CLERIC_T3)
			if(progression >= CLERIC_REQ_4) level = CLERIC_T4

	if(!holder?.mind)
		return FALSE
	if(level != last_level)
		try_add_spells(silent = silent)
		last_level = level
	return TRUE

/datum/devotion/proc/try_add_spells(silent = FALSE)
	if(HAS_TRAIT(holder, TRAIT_CLERGY) || HAS_TRAIT(holder, TRAIT_RENEGADE))
		return FALSE

	if(length(patron.miracles))
		for(var/spell_type in patron.miracles)
			if(patron.miracles[spell_type] <= level)
				if(holder.mind.has_spell(spell_type))
					continue
				var/newspell = new spell_type
				if(!silent)
					to_chat(holder, span_boldnotice("I have unlocked a new spell: [newspell]"))
				holder.mind.AddSpell(newspell)
				LAZYADD(granted_spells, newspell)

	if(length(patron.traits_tier))
		for(var/trait in patron.traits_tier)
			if(patron.traits_tier[trait] <= level)
				ADD_TRAIT(holder, trait, TRAIT_MIRACLE)
	return TRUE

/datum/devotion/proc/set_prayer_everywhere(enabled = TRUE)
	allow_prayer_everywhere = !!enabled

/datum/devotion/proc/set_auto_regen(enabled = TRUE)
	auto_regen_enabled = !!enabled
	if(!holder) return
	if(HAS_TRAIT(holder, TRAIT_CLERGY) || HAS_TRAIT(holder, TRAIT_RENEGADE))
		if(auto_regen_enabled && (passive_devotion_gain || passive_progression_gain))
			START_PROCESSING(SSobj, src)
		else
			STOP_PROCESSING(SSobj, src)
	else
		if(passive_devotion_gain || passive_progression_gain)
			START_PROCESSING(SSobj, src)
		else
			STOP_PROCESSING(SSobj, src)

/datum/devotion/proc/set_passive_bonus(enabled = TRUE)
	passive_bonus_on = !!enabled

/datum/devotion/proc/can_pray_here(mob/living/carbon/human/H)
	if(allow_prayer_everywhere)
		return TRUE
	if(!H) H = holder
	if(!H) return FALSE
	if(patron)
		return patron.can_pray(H)
	var/area/A = get_area(H)
	if(istype(A, /area/rogue/indoors/town/church)) return TRUE
	if(istype(A, /area/rogue/indoors/town/church/chapel)) return TRUE
	return FALSE

//The main proc that distributes all the needed devotion tweaks to the given class.
//cleric_tier 		- The cleric tier that the holder will get spells of immediately.
//passive_gain 		- Passive devotion gain, if any, will begin processing this datum.
//devotion_limit	- The CLERIC_REQ max_devotion and max_progression will be set to. Devotee overrides this with its own value!
//start_maxed		- Whether this class starts out with all devotion maxed. Mostly used by Acolytes & Priests to spawn with everything.
/datum/devotion/proc/grant_miracles(mob/living/carbon/human/H, cleric_tier = CLERIC_T0, passive_gain = 0, devotion_limit, start_maxed = FALSE)
	if(!H || !H.mind || !patron)
		return
	level = cleric_tier
	if(devotion_limit) // Upper devotion limit
		max_devotion = devotion_limit
		max_progression = devotion_limit

	if(HAS_TRAIT(H, TRAIT_CLERGY) || HAS_TRAIT(H, TRAIT_RENEGADE))
		passive_devotion_gain = passive_gain
		passive_progression_gain = passive_gain
		if(auto_regen_enabled && (passive_gain > 0))
			START_PROCESSING(SSobj, src)
	else
		if(passive_gain)
			passive_devotion_gain = passive_gain
			passive_progression_gain = passive_gain
			START_PROCESSING(SSobj, src)

	if(start_maxed) // Mainly for Acolytes & Priests
		max_devotion = CLERIC_REQ_4
		devotion = max_devotion
		update_devotion(max_devotion, CLERIC_REQ_4, silent = TRUE)
	else
		update_devotion(50, 50, silent = TRUE)

	H.verbs += list(/mob/living/carbon/human/proc/devotionreport, /mob/living/carbon/human/proc/clericpray)

	if(HAS_TRAIT(H, TRAIT_CLERGY) || HAS_TRAIT(H, TRAIT_RENEGADE))
		if(!H.mind.has_spell(/obj/effect/proc_holder/spell/self/learnmiracle))
			var/obj/effect/proc_holder/spell/self/learnmiracle/L = new
			H.mind.AddSpell(L)

// Debug verb
/mob/living/carbon/human/proc/devotionchange()
	set name = "(DEBUG)Change Devotion"
	set category = "-Special Verbs-"

	if(!devotion)
		return FALSE

	var/changeamt = input(src, "My devotion is [devotion.devotion]. How much to change?", "How much to change?") as null|num
	if(!changeamt)
		return FALSE
	devotion.update_devotion(changeamt)
	return TRUE

/mob/living/carbon/human/proc/devotionreport()
	set name = "Check Devotion"
	set category = "Cleric"

	if(!devotion)
		return FALSE

	to_chat(src,"My devotion is [devotion.devotion].")
	return TRUE

/mob/living/carbon/human/proc/clericpray()
	set name = "Give Prayer"
	set category = "Cleric"

	if(!devotion)
		return FALSE

	if(!devotion.can_pray_here(src))
		if(HAS_TRAIT(src, TRAIT_CLERGY) || HAS_TRAIT(src, TRAIT_RENEGADE))
			to_chat(src, span_warning("I must pray within the church."))
		return FALSE

	var/prayersesh = 0
	visible_message("[src] kneels their head in prayer to the Gods.", "I kneel my head in prayer to [devotion.patron.name].")
	for(var/i in 1 to 50)
		if(devotion.devotion >= devotion.max_devotion)
			to_chat(src, span_warning("I have reached the limit of my devotion..."))
			break
		if(!do_after(src, 30))
			break
		var/mul = 1
		if(mind)
			mul += (get_skill_level(/datum/skill/magic/holy) / SKILL_LEVEL_LEGENDARY)
		var/effective = round(devotion.prayer_effectiveness * mul)
		devotion.update_devotion(effective, effective)
		prayersesh += effective
	visible_message("[src] concludes their prayer.", "I conclude my prayer.")
	to_chat(src, "<font color='purple'>I gained [prayersesh] devotion!</font>")
	return TRUE

/mob/living/carbon/human/proc/changevoice()
	set name = "Change Second Voice (Can only use Once!)"
	set category = "Virtue"

	var/newcolor = input(src, "Choose your character's SECOND voice color:", "VIRTUE","#a0a0a0") as color|null
	if(newcolor)
		second_voice = sanitize_hexcolor(newcolor)
		src.verbs -= /mob/living/carbon/human/proc/changevoice
		return TRUE
	else
		return FALSE

/mob/living/carbon/human/proc/swapvoice()
	set name = "Swap Voice"
	set category = "Virtue"

	if(!second_voice)
		to_chat(src, span_info("I haven't decided on my second voice yet."))
		return FALSE
	if(voice_color != second_voice)
		original_voice = voice_color
		voice_color = second_voice
		to_chat(src, span_info("I've changed my voice to the second one."))
	else
		voice_color = original_voice
		to_chat(src, span_info("I've returned to my natural voice."))
	return TRUE

/mob/living/carbon/human/proc/toggleblindness()
	set name = "Toggle Colorblindness"
	set category = "Virtue"

	if(!get_client_color(/datum/client_colour/monochrome))
		add_client_colour(/datum/client_colour/monochrome)
	else
		remove_client_colour(/datum/client_colour/monochrome)

/datum/devotion/proc/excommunicate(mob/living/carbon/human/H)
	if (!devotion)
		return
	prayer_effectiveness = 0
	devotion = 0
	passive_devotion_gain = 0
	passive_progression_gain = 0
	STOP_PROCESSING(SSobj, src)
	to_chat(H, span_boldnotice("I have been excommunicated. I am now unable to gain devotion."))

/datum/devotion/proc/recommunicate(mob/living/carbon/human/H)
	prayer_effectiveness = 2
	if (!passive_devotion_gain && !passive_progression_gain)
		passive_devotion_gain = CLERIC_REGEN_DEVOTEE
		passive_progression_gain = CLERIC_REGEN_DEVOTEE
		START_PROCESSING(SSobj, src)
	to_chat(H, span_boldnotice("I have been welcomed back to the Church. I am now able to gain devotion again."))

/proc/_is_clergy_like(mob/living/carbon/human/H)
	if(!H) return FALSE
	return HAS_TRAIT(H, TRAIT_CLERGY) || HAS_TRAIT(H, TRAIT_RENEGADE)

/proc/_find_churchcore_settings()
	var/scope = "church"
	var/auto_regen = FALSE
	var/bonus = 0
	for(var/obj/structure/fluff/statue/shrine/churchcore/C in world)
		scope = C.prayer_scope           
		auto_regen = C.passive_enabled   
		bonus = C.passive_bonus          
		break
	return list("scope" = scope, "auto" = auto_regen, "bonus" = bonus)

/proc/_in_chapel(mob/living/carbon/human/H)
	if(!H) return FALSE
	var/area/A = get_area(H)
	return istype(A, /area/rogue/indoors/town/church/chapel)

/proc/_apply_devotion_upgrades_to_all()
	var/settings = _find_churchcore_settings()
	var/scope = settings["scope"]
	var/auto  = settings["auto"]
	var/bonus = settings["bonus"]

	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(!H?.devotion) continue
		H.devotion.set_prayer_everywhere(scope == "all")
		H.devotion.set_auto_regen(auto)
		H.devotion.set_passive_bonus(bonus >= 50)
