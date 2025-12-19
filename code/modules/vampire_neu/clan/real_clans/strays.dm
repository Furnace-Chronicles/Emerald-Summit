/// Toreador from Temu.
/datum/clan_leader/strays
	lord_spells = list(
	)
	lord_verbs = list(
	)
	lord_traits = list()
	lord_title = "Elder"
	vitae_bonus = 500

/datum/clan/strays
	name = "Strays"
	desc = "Strays can hardly be called vampires in the traditional sense. They are individuals who have been cursed with a mild form of vampirism, often through dark rituals or exposure to malevolent forces. Unlike true vampires, Strays lack the ability to convert others or commit Diablerie, making them outcasts among their kind. They struggle to control their thirst for blood and are often shunned by both humans and vampires alike."
	curse = "Aimlessness"
	blood_preference = BLOOD_PREFERENCE_ALL
	clane_traits = list(
		TRAIT_STRONGBITE,
		TRAIT_NOHUNGER,
		TRAIT_NOBREATH,
		TRAIT_NOPAIN,
		TRAIT_TOXIMMUNE,
		TRAIT_NOSLEEP,
		TRAIT_VAMP_DREAMS,
		TRAIT_DARKVISION,
		TRAIT_SILVER_WEAK,
		TRAIT_CRIMSON_CURSE
		)

	clane_covens = list(
	)
	leader = /datum/clan_leader/strays
	covens_to_select = 0

/datum/clan/strays/on_vampire_life(mob/living/carbon/human/H)
	..()
	if(H.bloodpool >= 500)
		ADD_TRAIT(H, TRAIT_NOPAIN, "clan")
