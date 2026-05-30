// Augmentation major aspect — body & object enhancement. soulshot/greater_arcyne_bolt
// are upstream choice spells; with the staged picker live they could be choice_spells,
// but are kept flattened in fixed_spells for now (choice restoration is a separate pass).
//
// Buff-bag: a 12-point pointbuy over the stat/utility buffs (upstream-faithful). The picker's
// GrimoirePointBuySection lets the player spend 12 points; costs read from each spell's `cost`
// (proc_holder) / `point_cost` (datum). Includes Fortitude + Message (Lesser Augmentation
// excludes Fortitude). forcewall + mending are always-granted fixed support.

/datum/magic_aspect/augmentation
	name = "Augmentation"
	latin_name = "Maior Aspectus Auctus"
	desc = "A second-order school focused on improving the body and the world around the mage. \
		Augmentation magi shore up walls, repair tools, and amplify the strength of their allies — \
		quiet work compared to the bombast of pyromancers, but every army needs them."
	aspect_type = ASPECT_MAJOR
	attuned_name = ASPECT_NAME_AUGMENTATION
	school_color = GLOW_COLOR_BUFF
	binding_chants = list(
		"Invoco auxilium arcanum!",
		"I call upon the threads that weave the world, lift!",
		"Auctus, in me ligare!",
	)
	unbinding_chants = list(
		"Solvo auxilium arcanum!",
		"I release the threads that I have woven, unspool.",
		"Auctus, a me discedere!",
	)
	fixed_spells = list(
		// choice pokes (flattened) + always-on support
		/datum/action/cooldown/spell/projectile/soulshot_magi2,
		/datum/action/cooldown/spell/projectile/greater_arcyne_bolt_magi2,
		/datum/action/cooldown/spell/forcewall_magi2,
		/datum/action/cooldown/spell/mending_magi2,
	)
	variants = list(
		"mastery" = list(
			VARIANT_ADDITIVE = /datum/action/cooldown/spell/ascension_magi2,
		),
	)
	pointbuy_budget = 12
	pointbuy_spells = list(
		/obj/effect/proc_holder/spell/invoked/haste,
		/obj/effect/proc_holder/spell/targeted/touch/darkvision,
		/obj/effect/proc_holder/spell/invoked/stoneskin,
		/obj/effect/proc_holder/spell/invoked/hawks_eyes,
		/obj/effect/proc_holder/spell/invoked/giants_strength,
		/obj/effect/proc_holder/spell/invoked/fortitude,
		/obj/effect/proc_holder/spell/invoked/guidance,
		/obj/effect/proc_holder/spell/invoked/featherfall,
		/obj/effect/proc_holder/spell/invoked/enlarge,
		/obj/effect/proc_holder/spell/invoked/leap,
		/obj/effect/proc_holder/spell/targeted/touch/nondetection,
		// 1-cost utility fillers
		/datum/action/cooldown/spell/light_magi2,
		/datum/action/cooldown/spell/create_campfire_magi2,
		/obj/effect/proc_holder/spell/self/message,
	)
