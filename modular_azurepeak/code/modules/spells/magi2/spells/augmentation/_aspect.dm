// Augmentation major aspect — body & object enhancement. Shares forcewall with
// Battlewardry and the Exowardry minor aspect. soulshot/greater_arcyne_bolt are upstream
// choice spells (one OR the other), but the Grimoire MVP has no choice picker so both
// land in fixed_spells alongside mending.

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
		/datum/action/cooldown/spell/forcewall_magi2,
		/datum/action/cooldown/spell/mending_magi2,
		/datum/action/cooldown/spell/projectile/soulshot_magi2,
		/datum/action/cooldown/spell/projectile/greater_arcyne_bolt_magi2,
	)
