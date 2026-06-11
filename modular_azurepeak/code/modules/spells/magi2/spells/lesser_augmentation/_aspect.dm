// Lesser Augmentation — minor aspect, port of Azure-Peak's `/datum/magic_aspect/lesser_augmentation`.
//
// 4-point pointbuy over personal buffs (upstream-faithful) — the staged picker's
// GrimoirePointBuySection lets the player spend the budget. No fixed_spells: binding it
// outside the picker (e.g. the debug verb) grants nothing; the points are spent in the UI.
// EXCLUDES Fortitude (per spec — that buff is exclusive to the major Augmentation aspect).
// Buffs route to ES proc_holder spells; the 1-cost fillers (Light/Mending/Campfire) are the
// already-ported Magi 2 datum versions.

/datum/magic_aspect/lesser_augmentation
	name = "Lesser Augmentation"
	latin_name = "Minor Aspectus Augmenti"
	desc = "The art of accessing the potent within. A bound Lesser Augmentation Magi has at their \
		fingertips a wide pool of personal-buff utilities — speed, sight, strength, weight, leaps \
		and skin. Less ambitious than a full Augmentation aspect, but a versatile addition to any kit."
	aspect_type = ASPECT_MINOR
	school_color = GLOW_COLOR_BUFF
	binding_chants = list(
		"Let me access the potent within.",
		"Augmentum, mihi adesse!",
	)
	unbinding_chants = list(
		"I calm the potent within.",
		"Augmentum, me relinquere!",
	)
	pointbuy_budget = 4
	pointbuy_spells = list(
		// 2- and 3-cost personal buffs — pick within the 4-point budget. EXCLUDES Fortitude (per spec).
		/obj/effect/proc_holder/spell/invoked/haste,
		/obj/effect/proc_holder/spell/targeted/touch/darkvision,
		/obj/effect/proc_holder/spell/invoked/stoneskin,
		/obj/effect/proc_holder/spell/invoked/hawks_eyes,
		/obj/effect/proc_holder/spell/invoked/giants_strength,
		/obj/effect/proc_holder/spell/invoked/guidance,
		/obj/effect/proc_holder/spell/invoked/featherfall,
		/obj/effect/proc_holder/spell/invoked/enlarge,
		/obj/effect/proc_holder/spell/invoked/leap,
		/obj/effect/proc_holder/spell/targeted/touch/nondetection,
		// 1-cost utility fillers (Magi 2 ports already present in our codebase)
		/datum/action/cooldown/spell/light_magi2,
		/datum/action/cooldown/spell/mending_magi2,
		/datum/action/cooldown/spell/create_campfire_magi2,
	)
