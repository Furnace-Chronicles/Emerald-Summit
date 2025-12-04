/mob/living/carbon/human/species/wildshape/death(gibbed, nocutscene = FALSE)
	werewolf_untransform(TRUE, gibbed)

/mob/living/carbon/human/proc/wildshape_transformation(shapepath)
	if(!mind)
		log_runtime("NO MIND ON [src.name] WHEN TRANSFORMING")
	Paralyze(1, ignore_canstun = TRUE)
	for(var/obj/item/I in src)
		dropItemToGround(I)
	regenerate_icons()
	icon = null
	var/oldinv = invisibility
	invisibility = INVISIBILITY_MAXIMUM
	cmode = FALSE
	if(client)
		SSdroning.play_area_sound(get_area(src), client)

	stasis = TRUE //If we don't do this, even a single cut will mean the player's real body will die in the void while they run around wildshaped

	var/mob/living/carbon/human/species/wildshape/W = new shapepath(loc) //We crate a new mob for the wildshaping player to inhabit

	W.set_patron(src.patron)
	W.gender = gender
	W.regenerate_icons()
	W.stored_mob = src
	W.cmode_music = 'sound/music/combat_druid.ogg'
	playsound(W.loc, pick('sound/combat/gib (1).ogg','sound/combat/gib (2).ogg'), 200, FALSE, 3)
	W.spawn_gibs(FALSE)
	src.forceMove(W)

	W.after_creation()
	W.stored_language = new
	W.stored_language.copy_known_languages_from(src)
	W.stored_skills = ensure_skills().known_skills.Copy()
	W.stored_experience = ensure_skills().skill_experience.Copy()

	// Store spell list using new system if enabled
	if(mind && mind.can_store_spells)
		mind.stored_transformation_spells = mind.store_spell_list()
	else
		W.stored_spells = mind.spell_list.Copy() // Fallback for non-storage-enabled minds

	W.voice_color = voice_color
	W.cmode_music_override = cmode_music_override
	W.cmode_music_override_name = cmode_music_override_name
	mind.transfer_to(W)
	skills?.known_skills = list()
	skills?.skill_experience = list()
	W.grant_language(/datum/language/beast)
	W.base_intents = list(INTENT_HELP, INTENT_DISARM, INTENT_GRAB)
	W.update_a_intents()

	ADD_TRAIT(src, TRAIT_NOSLEEP, TRAIT_GENERIC) //If we don't do this, the original body will fall asleep and snore on us

	invisibility = oldinv

	W.gain_inherent_skills()

/mob/living/carbon/human/proc/wildshape_untransform(dead,gibbed)
	if(!stored_mob)
		return
	if(!mind)
		log_runtime("NO MIND ON [src.name] WHEN UNTRANSFORMING")
	Paralyze(1, ignore_canstun = TRUE)
	for(var/obj/item/W in src)
		dropItemToGround(W)
	icon = null
	invisibility = INVISIBILITY_MAXIMUM

	var/mob/living/carbon/human/W = stored_mob
	stored_mob = null

	REMOVE_TRAIT(W, TRAIT_NOSLEEP, TRAIT_GENERIC)

	if(dead)
		W.death()

	W.forceMove(get_turf(src))

	mind.transfer_to(W)

	var/mob/living/carbon/human/species/wildshape/WA = src
	W.copy_known_languages_from(WA.stored_language)
	skills?.known_skills = WA.stored_skills.Copy()
	skills?.skill_experience = WA.stored_experience.Copy()

	// Restore spells using new system if storage was enabled
	if(W.mind && W.mind.can_store_spells && W.mind.stored_transformation_spells)
		// Remove T2 miracles granted during wildshape, keep transformation spells
		var/list/always_keep = list(
			/obj/effect/proc_holder/spell/targeted/wildshape
		)
		W.mind.restore_spell_list(W.mind.stored_transformation_spells, always_keep)
		W.mind.stored_transformation_spells = null
	else
		// Fallback: old buggy logic for non-storage-enabled minds
		// Remove spells that weren't in the original list
		for(var/obj/effect/proc_holder/spell/wildspell in W.mind.spell_list)
			var/found = FALSE
			for(var/obj/effect/proc_holder/spell/originspell in WA.stored_spells)
				if(wildspell == originspell)
					found = TRUE
					break
			if(!found)
				W.mind.RemoveSpell(wildspell)

	W.regenerate_icons()

	to_chat(W, span_userdanger("I return to my old form."))

	W.stasis = FALSE

	qdel(src)
