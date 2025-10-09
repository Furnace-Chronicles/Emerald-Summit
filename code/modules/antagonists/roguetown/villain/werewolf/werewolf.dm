/datum/antagonist/werewolf
	name = "Verevolf"
	roundend_category = "Werewolves"
	antagpanel_category = "Werewolf"
	job_rank = ROLE_WEREWOLF
	var/list/inherent_traits = list(TRAIT_NOPAIN, TRAIT_NOPAINSTUN, TRAIT_CRITICAL_RESISTANCE, TRAIT_NOFALLDAMAGE1, TRAIT_KNEESTINGER_IMMUNITY, TRAIT_SHOCKIMMUNE)
	confess_lines = list(
		"THE BEAST INSIDE ME!",
		"BEWARE THE BEAST!",
		"MY LUPINE MARK!",
	)
	rogue_enabled = TRUE
	var/special_role = ROLE_WEREWOLF
	var/transformed
	var/transforming
	var/untransforming
	var/wolfname = "Verevolf"
	var/attributes_applied = FALSE

	//Edit these to make stronger or weaker wolf versions
	var/night_attribute_magnitude	=	20
	var/day_attribute_magnitude	=	10

	//This is a temporary variable do not edit it
	var/attribute_magnitude = 20

/datum/antagonist/werewolf/lesser
	name = "Lesser Verevolf"
	increase_votepwr = FALSE

/datum/antagonist/werewolf/lesser/roundend_report()
	return

/datum/antagonist/werewolf/examine_friendorfoe(datum/antagonist/examined_datum,mob/examiner,mob/examined)
	if(istype(examined_datum, /datum/antagonist/werewolf/lesser))
		return span_boldnotice("A young lupine kin.")
	if(istype(examined_datum, /datum/antagonist/werewolf))
		return span_boldnotice("An elder lupine kin.")
	if(examiner.Adjacent(examined))
		if(istype(examined_datum, /datum/antagonist/vampirelord/lesser))
			if(transformed)
				return span_boldwarning("A lesser Vampire.")
		if(istype(examined_datum, /datum/antagonist/vampirelord))
			if(transformed)
				return span_boldwarning("An Ancient Vampire. I must be careful!")

/datum/antagonist/werewolf/on_gain()
	greet()
	owner.special_role = name
	if(increase_votepwr)
		forge_werewolf_objectives()

	wolfname = "[pick(GLOB.wolf_prefixes)] [pick(GLOB.wolf_suffixes)]"
	return ..()

/datum/antagonist/werewolf/on_removal()
	if(!silent && owner.current)
		to_chat(owner.current,span_danger("I am no longer a [special_role]!"))
	owner.special_role = null
	return ..()

/datum/antagonist/werewolf/proc/add_objective(datum/objective/O)
	objectives += O

/datum/antagonist/werewolf/proc/remove_objective(datum/objective/O)
	objectives -= O

/datum/antagonist/werewolf/proc/forge_werewolf_objectives()
	if(!(locate(/datum/objective/escape) in objectives))
		var/datum/objective/werewolf/escape_objective = new
		escape_objective.owner = owner
		add_objective(escape_objective)
		return

/datum/antagonist/werewolf/greet()
	to_chat(owner.current, span_userdanger("Since a bite long, long ago, Dendor's Madness has welled within me. Before the Moonlight, I will sate my hallowed Hunger."))
	return ..()

/datum/antagonist/werewolf/lesser/greet()
	// leave this empty so that lesser verevolf's dont get the greeting on bite.
	// there is probably a better way to do this but this works until sm1 smarter inevitably rewrites WW.

/datum/antagonist/werewolf/do_time_change()
	.=..()
	update_attributes()


	//Armour is restored at the start of a new night, if you stayed in wolf form all day
	if (GLOB.tod == "night")
		var/mob/living/carbon/human/species/werewolf/W = owner.current
		if (!istype(W))	return

		var/obj/item/clothing/suit/roguetown/armor/skin_armor/werewolf_skin/skin = W.skin_armor
		if (skin.obj_integrity < skin.max_integrity)
			skin.repair_coverage()
			skin.obj_fix()
			playsound(W.loc, 'sound/foley/sewflesh.ogg', 50, TRUE, -2)
			to_chat(owner.current, span_userdanger("You feel your flesh knit, as your damaged skin is made whole again."))


/datum/antagonist/werewolf/apply_innate_effects(mob/living/mob_override)
	.=..(mob_override)
	update_attributes()

/datum/antagonist/werewolf/proc/update_attributes()
	var/mob/living/carbon/human/species/werewolf/W = owner.current

	//Check if the mob is actually in wolf form
	if (!istype(W))
		//IF they've converted back to human, thats fine, the wolf is deleted on change and the attributes were attached to it, so they are gone
		attributes_applied = FALSE
		return


	if(attributes_applied)
		//
		W.STASTR -= attribute_magnitude // LOCK IN
		W.STACON -= attribute_magnitude
		W.STAEND -= attribute_magnitude
		attributes_applied = FALSE

	if (transformed)
		if (GLOB.tod == "night")
			attribute_magnitude = night_attribute_magnitude
		else
			attribute_magnitude = day_attribute_magnitude

	W.STASTR += attribute_magnitude
	W.STACON += attribute_magnitude
	W.STAEND += attribute_magnitude
	attributes_applied = TRUE


/mob/living/carbon/human/proc/can_werewolf()
	if(!mind)
		return FALSE
	if(mind.has_antag_datum(/datum/antagonist/vampirelord))
		return FALSE
	if(mind.has_antag_datum(/datum/antagonist/werewolf))
		return FALSE
	if(mind.has_antag_datum(/datum/antagonist/skeleton))
		return FALSE
	if(HAS_TRAIT(src, TRAIT_SILVER_BLESSED))
		return FALSE
	if(HAS_TRAIT(src, TRAIT_HOLLOW_LIFE))
		return FALSE
	return TRUE

/mob/living/carbon/human/proc/werewolf_check(werewolf_type = /datum/antagonist/werewolf/lesser)
	if(!mind)
		return
	var/already_wolfy = mind.has_antag_datum(/datum/antagonist/werewolf)
	if(already_wolfy)
		return already_wolfy
	if(!can_werewolf())
		return
	return mind.add_antag_datum(werewolf_type)

/mob/living/carbon/human/proc/werewolf_infect_attempt()
	var/datum/antagonist/werewolf/wolfy = werewolf_check()
	if(!wolfy)
		return
	if(stat >= DEAD) //do shit the natural way i guess
		return
	to_chat(src, span_danger("I feel horrible... REALLY horrible..."))
	mob_timers["puke"] = world.time
	vomit(1, blood = TRUE, stun = FALSE)
	return wolfy

/mob/living/carbon/human/proc/werewolf_feed(mob/living/carbon/human/target, healing_amount = 10)
	if(!istype(target))
		return
	if(src.has_status_effect(/datum/status_effect/debuff/silver_curse))
		to_chat(src, span_notice("My power is weakened, I cannot heal!"))
		return
	if(target.mind)
		if(target.mind.has_antag_datum(/datum/antagonist/zombie))
			to_chat(src, span_warning("I should not feed on rotten flesh."))
			return
		if(target.mind.has_antag_datum(/datum/antagonist/vampirelord))
			to_chat(src, span_warning("I should not feed on corrupted flesh."))
			return
		if(target.mind.has_antag_datum(/datum/antagonist/werewolf))
			to_chat(src, span_warning("I should not feed on my kin's flesh."))
			return

	to_chat(src, span_warning("I feed on succulent flesh. I feel reinvigorated."))
	return src.reagents.add_reagent(/datum/reagent/medicine/healthpot, healing_amount)

/obj/item/clothing/suit/roguetown/armor/skin_armor/werewolf_skin
	slot_flags = null
	name = "verevolf's skin"
	desc = ""
	icon_state = null
	body_parts_covered = FULL_BODY
	body_parts_inherent = FULL_BODY
	armor = ARMOR_WWOLF
	prevent_crits = list(BCLASS_CUT, BCLASS_CHOP, BCLASS_STAB, BCLASS_BLUNT, BCLASS_TWIST)
	blocksound = SOFTHIT
	blade_dulling = DULLING_BASHCHOP
	sewrepair = FALSE
	max_integrity = 550
	item_flags = DROPDEL

/datum/intent/simple/werewolf
	name = "claw"
	icon_state = "inchop"
	blade_class = BCLASS_CHOP
	attack_verb = list("claws", "mauls", "eviscerates")
	animname = "chop"
	hitsound = "genslash"
	penfactor = 50
	candodge = TRUE
	canparry = TRUE
	miss_text = "slashes the air!"
	miss_sound = "bluntwooshlarge"
	item_d_type = "slash"

/obj/item/rogueweapon/werewolf_claw
	name = "Verevolf Claw"
	desc = ""
	item_state = null
	lefthand_file = null
	righthand_file = null
	icon = 'icons/roguetown/weapons/misc32.dmi'
	max_blade_int = 900
	max_integrity = 900
	force = 25
	block_chance = 0
	wdefense = 2
	armor_penetration = 15
	associated_skill = /datum/skill/combat/unarmed
	wlength = WLENGTH_NORMAL
	wbalance = WBALANCE_HEAVY
	w_class = WEIGHT_CLASS_BULKY
	can_parry = TRUE
	sharpness = IS_SHARP
	parrysound = "bladedmedium"
	swingsound = BLADEWOOSH_MED
	possible_item_intents = list(/datum/intent/simple/werewolf)
	parrysound = list('sound/combat/parry/parrygen.ogg')
	embedding = list("embedded_pain_multiplier" = 0, "embed_chance" = 0, "embedded_fall_chance" = 0)
	item_flags = DROPDEL

/obj/item/rogueweapon/werewolf_claw/right
	icon_state = "claw_r"

/obj/item/rogueweapon/werewolf_claw/left
	icon_state = "claw_l"

/obj/item/rogueweapon/werewolf_claw/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_NOEMBED, TRAIT_GENERIC)


