// Lesser Augmentation — minor aspect, port of Azure-Peak's `/datum/magic_aspect/lesser_augmentation`.
//
// Pilot deviation from upstream: upstream uses a 4-point pointbuy across 13 utility
// spells (player picks 1-3 depending on cost). We don't have a pointbuy UI yet — and
// the Grimoire's bind action only grants fixed_spells. So Lesser Augmentation here
// grants ALL 13 utility spells when bound. Yes, that crowds the action bar; the
// player can unbind the aspect to remove them, or unbind specific spells if a future
// session adds that UI. Same pragmatic approach we took for Autowardry.
//
// 10 of the 13 spells route to ES's existing proc_holder buff spells (`mind.AddSpell`
// path via the aspect helpers' type dispatch). The remaining 3 (Light, Mending,
// Create Campfire) are the Magi 2 versions already ported elsewhere — shared with
// Fulgurmancy/Augmentation/Pyromancy/Hearthcraft.

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
	fixed_spells = list(
		// 2- and 3-cost personal buffs (upstream pointbuy core)
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
