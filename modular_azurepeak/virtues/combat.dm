// Arcyne Potential now gives 3 Spellpoints instead of 6 spellpoints so it is less of a "must take" for caster.
/datum/virtue/combat/magical_potential
	name = "Arcyne Potential"
	desc = "I am talented in the Arcyne arts, expanding my capacity for magic. I have become more intelligent from its studies. Other effects depends on what training I chose to focus on at a later age."
	custom_text = "Classes that has a combat trait (Medium / Heavy Armor Training, Dodge Expert or Critical Resistance) get only prestidigitation. Everyone else get +3 spellpoints and T1 Arcyne Potential if they don't have any Arcyne."
	added_skills = list(list(/datum/skill/magic/arcane, 1, 6))

/datum/virtue/combat/magical_potential/apply_to_human(mob/living/carbon/human/recipient)
	// Always grant prestidigitation if they don't have it, don't care about the skill level
	if (!recipient.mind?.has_spell(/obj/effect/proc_holder/spell/targeted/touch/prestidigitation))
		recipient.mind?.AddSpell(new /obj/effect/proc_holder/spell/targeted/touch/prestidigitation)
	
	// Check for combat traits
	if (!HAS_TRAIT(recipient, TRAIT_MEDIUMARMOR) && !HAS_TRAIT(recipient, TRAIT_HEAVYARMOR) && !HAS_TRAIT(recipient, TRAIT_DODGEEXPERT) && !HAS_TRAIT(recipient, TRAIT_CRITICAL_RESISTANCE))
		// No combat traits: grant spellpoints and arcane tier
		recipient.mind?.adjust_spellpoints(3)
		ADD_TRAIT(recipient, TRAIT_ARCYNE_T1, TRAIT_GENERIC)
	
/datum/virtue/combat/devotee
	name = "Devotee"
	desc = "Though not officially of the Church, my relationship with my chosen Patron is strong enough to grant me the most minor of their blessings. I've also kept a psycross of my deity."
	custom_text = "Combat classes receive a weaker version of this virtue -- they do not get the first tier of miracles."
	added_skills = list(list(/datum/skill/magic/holy, 1, 6))

/datum/virtue/combat/devotee/apply_to_human(mob/living/carbon/human/recipient)
	if (!recipient.mind)
		return
	if (!recipient.devotion)
		// Only give non-devotionists orison... and T0 for some reason (Bad ideas are fun!)
		var/datum/devotion/new_faith = new /datum/devotion(recipient, recipient.patron)
		new_faith.grant_miracles(recipient, cleric_tier = CLERIC_T0, passive_gain = FALSE, devotion_limit = (CLERIC_REQ_1 - 20))	//Capped to T0 miracles.
	else
		// for devotionists, give them an amount of passive devo gain.
		var/datum/devotion/our_faith = recipient.devotion
		our_faith.passive_devotion_gain += CLERIC_REGEN_DEVOTEE
		START_PROCESSING(SSobj, our_faith)
	switch(recipient.patron?.type)
		if(/datum/patron/divine/astrata)
			recipient.mind?.special_items["Astrata Psycross"] = /obj/item/clothing/neck/roguetown/psicross/astrata
		if(/datum/patron/divine/abyssor)
			recipient.mind?.special_items["Abyssor Psycross"] = /obj/item/clothing/neck/roguetown/psicross/abyssor
		if(/datum/patron/divine/dendor)
			recipient.mind?.special_items["Dendor Psycross"] = /obj/item/clothing/neck/roguetown/psicross/dendor
		if(/datum/patron/divine/necra)
			recipient.mind?.special_items["Necra Psycross"] = /obj/item/clothing/neck/roguetown/psicross/necra
		if(/datum/patron/divine/pestra)
			recipient.mind?.special_items["Pestra Psycross"] = /obj/item/clothing/neck/roguetown/psicross/pestra
		if(/datum/patron/divine/eora) 
			recipient.mind?.special_items["Eora Psycross"] = /obj/item/clothing/neck/roguetown/psicross/eora
		if(/datum/patron/divine/xylix) 
			recipient.mind?.special_items["Xylix Psycross"] = /obj/item/clothing/neck/roguetown/psicross/xylix
		if(/datum/patron/divine/noc)
			recipient.mind?.special_items["Noc Psycross"] = /obj/item/clothing/neck/roguetown/psicross/noc
		if(/datum/patron/divine/ravox)
			recipient.mind?.special_items["Ravox Psycross"] =/obj/item/clothing/neck/roguetown/psicross/ravox
		if(/datum/patron/divine/malum)
			recipient.mind?.special_items["Malum Psycross"] = /obj/item/clothing/neck/roguetown/psicross/malum
		if(/datum/patron/old_god)
			ADD_TRAIT(recipient, TRAIT_PSYDONITE, TRAIT_GENERIC)
			recipient.mind?.special_items["Psydon Psycross"] = /obj/item/clothing/neck/roguetown/psicross

/datum/virtue/combat/duelist
	name = "Duelist's Apprentice"
	desc = "I have trained under a duelist of considerable skill, and always have my swift rapier close at hand."
	custom_text = "+1 to Swords and Knives, Up to Journeyman, Minimum Apprentice."
	added_stashed_items = list("Duelist's Rapier" = /obj/item/rogueweapon/sword/rapier)

/datum/virtue/combat/duelist/apply_to_human(mob/living/carbon/human/recipient)
	if(recipient.get_skill_level(/datum/skill/combat/swords) < SKILL_LEVEL_APPRENTICE)
		recipient.adjust_skillrank_up_to(/datum/skill/combat/swords, SKILL_LEVEL_APPRENTICE, silent = TRUE)
	else
		recipient.adjust_skillrank_up_to(/datum/skill/combat/swords, SKILL_LEVEL_JOURNEYMAN, silent = TRUE)
	if(recipient.get_skill_level(/datum/skill/combat/knives) < SKILL_LEVEL_APPRENTICE)
		recipient.adjust_skillrank_up_to(/datum/skill/combat/knives, SKILL_LEVEL_APPRENTICE, silent = TRUE)
	else	
		recipient.adjust_skillrank_up_to(/datum/skill/combat/knives, SKILL_LEVEL_JOURNEYMAN, silent = TRUE)

/datum/virtue/combat/executioner
	name = "Dungeoneer's Apprentice"
	desc = "I was set to be a dungeoneer some time ago, and I was taught by one. I have an axe stashed away if the need arises."
	custom_text = "+1 to Axes and Whips/Flails, Up to Journeyman, Minimum Apprentice."
	added_stashed_items = list("Iron Axe" = /obj/item/rogueweapon/stoneaxe/woodcut)

/datum/virtue/combat/executioner/apply_to_human(mob/living/carbon/human/recipient)
	if(recipient.get_skill_level(/datum/skill/combat/whipsflails) < SKILL_LEVEL_APPRENTICE)
		recipient.adjust_skillrank_up_to(/datum/skill/combat/whipsflails, SKILL_LEVEL_APPRENTICE, silent = TRUE)
	else
		recipient.adjust_skillrank_up_to(/datum/skill/combat/whipsflails, SKILL_LEVEL_JOURNEYMAN, silent = TRUE)
	if(recipient.get_skill_level(/datum/skill/combat/axes) < SKILL_LEVEL_APPRENTICE)
		recipient.adjust_skillrank_up_to(/datum/skill/combat/axes, SKILL_LEVEL_APPRENTICE, silent = TRUE)
	else
		recipient.adjust_skillrank_up_to(/datum/skill/combat/axes, SKILL_LEVEL_JOURNEYMAN, silent = TRUE)

/datum/virtue/combat/militia
	name = "Militiaman"
	desc = "I have trained with the local garrison in case I'm ever to be levied to fight for my lord. I have a spear  and sling stashed away in the event I'm called to arms."
	custom_text = "+1 to Maces, Slings and Polearms, Up to Journeyman, Minimum Apprentice."
	added_stashed_items = list("Spear" = /obj/item/rogueweapon/spear, "Sling" = /obj/item/gun/ballistic/revolver/grenadelauncher/sling, "Bullet Pouch" = /obj/item/quiver/sling)

/datum/virtue/combat/militia/apply_to_human(mob/living/carbon/human/recipient)
	if(recipient.get_skill_level(/datum/skill/combat/polearms) < SKILL_LEVEL_APPRENTICE)
		recipient.adjust_skillrank_up_to(/datum/skill/combat/polearms, SKILL_LEVEL_APPRENTICE, silent = TRUE)
	else
		recipient.adjust_skillrank_up_to(/datum/skill/combat/polearms, SKILL_LEVEL_JOURNEYMAN, silent = TRUE)
	if(recipient.get_skill_level(/datum/skill/combat/maces) < SKILL_LEVEL_APPRENTICE)
		recipient.adjust_skillrank_up_to(/datum/skill/combat/maces, SKILL_LEVEL_APPRENTICE, silent = TRUE)
	else
		recipient.adjust_skillrank_up_to(/datum/skill/combat/maces, SKILL_LEVEL_JOURNEYMAN, silent = TRUE)
	if(recipient.get_skill_level(/datum/skill/combat/slings) < SKILL_LEVEL_APPRENTICE)
		recipient.adjust_skillrank_up_to(/datum/skill/combat/slings, SKILL_LEVEL_APPRENTICE, silent = TRUE)
	else
		recipient.adjust_skillrank_up_to(/datum/skill/combat/slings, SKILL_LEVEL_JOURNEYMAN, silent = TRUE)

/datum/virtue/combat/brawler
	name = "Brawler's Apprentice"
	desc = "I have trained under a skilled brawler, and have some experience fighting with my fists."
	custom_text = "+1 to Unarmed and Wrestling, Up to Journeyman, Minimum Apprentice."
	added_stashed_items = list("Katar" = /obj/item/rogueweapon/katar)
	
/datum/virtue/combat/brawler/apply_to_human(mob/living/carbon/human/recipient)
	if(recipient.get_skill_level(/datum/skill/combat/unarmed) < SKILL_LEVEL_APPRENTICE)
		recipient.adjust_skillrank_up_to(/datum/skill/combat/unarmed, SKILL_LEVEL_APPRENTICE, silent = TRUE)
	else
		recipient.adjust_skillrank_up_to(/datum/skill/combat/unarmed, SKILL_LEVEL_JOURNEYMAN, silent = TRUE)
	if(recipient.get_skill_level(/datum/skill/combat/wrestling) < SKILL_LEVEL_APPRENTICE)
		recipient.adjust_skillrank_up_to(/datum/skill/combat/wrestling, SKILL_LEVEL_APPRENTICE, silent = TRUE)
	else
		recipient.adjust_skillrank_up_to(/datum/skill/combat/wrestling, SKILL_LEVEL_JOURNEYMAN, silent = TRUE)


/datum/virtue/combat/bowman
	name = "Toxophilite"
	desc = "I've had an interest in archery from a young age, and I always keep a spare bow and quiver around."
	custom_text = "+1 to Bows, Up to Journeyman, Minimum Apprentice"
	added_stashed_items = list("Recurve Bow" = /obj/item/gun/ballistic/revolver/grenadelauncher/bow/recurve,
								"Quiver (Arrows)" = /obj/item/quiver/arrows
	)

/datum/virtue/combat/bowman/apply_to_human(mob/living/carbon/human/recipient)
	if(recipient.get_skill_level(/datum/skill/combat/bows) < SKILL_LEVEL_APPRENTICE)
		recipient.adjust_skillrank_up_to(/datum/skill/combat/bows, SKILL_LEVEL_APPRENTICE, silent = TRUE)
	else
		added_skills = list(list(/datum/skill/combat/bows, 1, 3))
/*/datum/virtue/combat/tavern_brawler
	name = "Tavern Brawler"
	desc = "I've never met a problem my fists couldn't solve."
	added_traits = list(TRAIT_CIVILIZEDBARBARIAN)*/

/datum/virtue/combat/guarded
	name = "Guarded"
	desc = "I have long kept my true capabilities and vices a secret. Sometimes being deceptively weak can save one's lyfe."
	added_traits = list(TRAIT_DECEIVING_MEEKNESS)

/*/datum/virtue/combat/impervious
	name = "Impervious"
	desc = "I've spent years shoring up my weakspots, and have become difficult to wound with critical blows."
	added_traits = list(TRAIT_CRITICAL_RESISTANCE)*/

/datum/virtue/combat/rotcured
	name = "Rotcured"
	desc = "I was once afflicted with the accursed rot, and was cured. It has left me changed: my limbs are weaker, but I feel no pain and have no need to breathe..."
	custom_text = "Colors your body a distinct, sickly green."
	// below is functionally equivalent to dying and being resurrected via astrata T4 - yep, this is what it gives you.
	added_traits = list(TRAIT_EASYDISMEMBER, TRAIT_NOPAIN, TRAIT_NOPAINSTUN, TRAIT_NOBREATH, TRAIT_TOXIMMUNE, TRAIT_ZOMBIE_IMMUNE, TRAIT_ROTMAN, TRAIT_SILVER_WEAK)

/datum/virtue/combat/rotcured/apply_to_human(mob/living/carbon/human/recipient)
	recipient.update_body() // applies the rot skin tone stuff
	recipient.dna.species.soundpack_m = new /datum/voicepack/male/rotman()
	recipient.dna.species.soundpack_f = new /datum/voicepack/female/rotman()

/datum/virtue/combat/dualwielder
	name = "Dual Wielder"
	desc = "Whether it was by the Naledi scholars, Etruscan privateers or even the Kazengan senseis. I've been graced with the knowledge of how to wield two weapons at once."
	added_traits = list(TRAIT_DUALWIELDER)

/datum/virtue/combat/sharp
	name = "Sentinel of Wits"
	desc = "Whether it's by having an annoying sibling that kept prodding me with a stick, or years of study and observation, I've become adept at both parrying and dodging stronger opponents, by learning their moves and studying them."
	added_traits = list(TRAIT_SENTINELOFWITS)

/datum/virtue/combat/combat_aware
	name = "Combat Aware"
	desc = "The opponent's flick of their wrist. The sound of maille snapping. The desperate breath as the opponent's stamina wanes. All of this is made more clear to you through intuition or experience."
	custom_text = "Shows a lot more combat information via floating text. Has a toggle."
	added_traits = list(TRAIT_COMBAT_AWARE)

/datum/virtue/combat/combat_aware/apply_to_human(mob/living/carbon/human/recipient)
	recipient.verbs += /mob/living/carbon/human/proc/togglecombatawareness

/datum/virtue/combat/hollow_life
	name = "Hollow Lyfe"
	desc = "Due to the events of the past, I have been rendered hollow, practically bereft of any lyfe. My heart doth not beat, neither do I draw any breath. As it stands, I am closer to the deadite than to the living."
	added_traits = list(TRAIT_HOLLOW_LIFE, TRAIT_NOPAIN, TRAIT_NOPAINSTUN, TRAIT_NOBREATH, TRAIT_TOXIMMUNE, TRAIT_ZOMBIE_IMMUNE, TRAIT_NOHUNGER)
	custom_text = span_bloody("CON IS ADJUSTED BY -2, SILVER WEAKNESS AND TENNITE MIRACLES SET YOU ON FIRE")

/datum/virtue/combat/hollow_life/apply_to_human(mob/living/carbon/human/recipient)
	recipient.change_stat(STATKEY_CON, -2)
	recipient.dna.species.soundpack_m = new /datum/voicepack/hollow()
	recipient.dna.species.soundpack_f = new /datum/voicepack/hollow_fem()
	if(recipient.charflaw)
		if(recipient.charflaw.type == /datum/charflaw/damned)
			to_chat(recipient, "Your body is plagued by curses!")
			ADD_TRAIT(recipient, TRAIT_NORUN, TRAIT_GENERIC)
		else
			recipient.mob_biotypes |= MOB_UNDEAD //Undead biotype is already applied by damned vice.

/datum/virtue/combat/crimson_curse
	name = "Crimson Curse"
	desc = "You suffer from the Crimson Curse, a weak form of Vampirism acquired from dark rites or a particularly cruel hex. Unlike a 'true' Vampire, you are incapable of converting others or commiting Diablerie."
	custom_text = span_bloody("CON IS ADJUSTED BY -1!")

/datum/virtue/combat/crimson_curse/apply_to_human(mob/living/carbon/human/recipient)
	//Hacky but we need to do this, otherwise the CC trait isn't applied before vampire checks for the trait and stops us from being Clan Leader
	ADD_TRAIT(recipient, TRAIT_CRIMSON_CURSE, TRAIT_GENERIC)
	addtimer(CALLBACK(src, .proc/crimson_apply, recipient), 30)

/datum/virtue/combat/crimson_curse/proc/crimson_apply(mob/living/carbon/human/recipient)
	var/datum/antagonist/vampire/stray/new_antag = new /datum/antagonist/vampire/stray(incoming_clan = /datum/clan/strays, forced_clan = FALSE, generation = GENERATION_FAILVAMP)
	recipient.mind.add_antag_datum(new_antag)
	recipient.change_stat(STATKEY_CON, -1)
