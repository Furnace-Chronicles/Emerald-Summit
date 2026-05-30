// Augmentation major aspect — body & object enhancement. Shares forcewall with
// Battlewardry and the Exowardry minor aspect. soulshot/greater_arcyne_bolt are upstream
// choice spells (one OR the other), but the Grimoire MVP has no choice picker so both
// land in fixed_spells alongside mending.
//
// Buff-bag: upstream gives Augmentation a 12-point pointbuy over its stat/utility buffs
// (`pointbuy_budget = 12` + `pointbuy_spells`). Our adapter has no pointbuy UI and
// grant_spells() only grants fixed_spells, so — same pragmatic call as Lesser
// Augmentation — the whole bag is flattened into fixed_spells and granted wholesale.
// Difference vs. Lesser Augmentation: the major aspect DOES include Fortitude and Message
// (Lesser excludes Fortitude). These route through the existing ES proc_holder buff spells
// via the aspect helpers' type dispatch; the magi2 fillers (light/mending/campfire) are
// the already-ported action versions.

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
		// choice pokes (flattened — no picker yet) + core support
		/datum/action/cooldown/spell/projectile/soulshot_magi2,
		/datum/action/cooldown/spell/projectile/greater_arcyne_bolt_magi2,
		/datum/action/cooldown/spell/forcewall_magi2,
		// 12-point buff bag (flattened pointbuy) — stat & utility enhancements
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
		// 1-cost utility filler
		/datum/action/cooldown/spell/light_magi2,
		/datum/action/cooldown/spell/mending_magi2,
		/datum/action/cooldown/spell/create_campfire_magi2,
		/obj/effect/proc_holder/spell/self/message,
	)
	variants = list(
		"mastery" = list(
			VARIANT_ADDITIVE = /datum/action/cooldown/spell/ascension_magi2,
		),
	)
