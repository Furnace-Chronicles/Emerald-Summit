/mob/living/carbon/human/species/wildshape
	var/datum/devotion/mind_devotion_transfer  // Temporary storage for devotion transfer

/mob/living/carbon/human/species/wildshape/death(gibbed, nocutscene = FALSE)
	werewolf_untransform(TRUE, gibbed)

/mob/living/carbon/human/proc/wildshape_transformation(shapepath)
	if(!mind)
		log_runtime("NO MIND ON [src.name] WHEN TRANSFORMING")
	
	// Store who is grabbing us before transformation
	var/list/grab_data = list() // List of lists: list(grabber, grab_state, tackle_status, was_lying)
	for(var/obj/item/grabbing/G in src.grabbedby)
		if(G.grabbee)
			var/tackle_status = FALSE
			if(G.grabbee.buckled_mobs && (src in G.grabbee.buckled_mobs))
				tackle_status = TRUE
			grab_data += list(list(G.grabbee, G.grab_state, tackle_status, src.lying))
	
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

	// Transfer all spells to wildshape form - they keep the exact same spells
	// The mind.transfer_to() below will carry the spell_list to the new form
	// We don't need to store/restore anything since they keep the same spells

	W.voice_color = voice_color
	W.cmode_music_override = cmode_music_override
	W.cmode_music_override_name = cmode_music_override_name
	
	// Transfer devotion datum directly to wildshape form so they can transform back
	// Must be done BEFORE mind.transfer_to() to avoid context issues
	var/mob/living/carbon/human/H = src
	W.devotion = H.devotion
	
	mind.transfer_to(W)
	skills?.known_skills = list()
	skills?.skill_experience = list()
	W.grant_language(/datum/language/beast)
	W.base_intents = list(INTENT_HELP, INTENT_DISARM, INTENT_GRAB)
	W.update_a_intents()

	ADD_TRAIT(src, TRAIT_NOSLEEP, TRAIT_GENERIC) //If we don't do this, the original body will fall asleep and snore on us

	invisibility = oldinv

	W.gain_inherent_skills()
	
	// Restore grabs - make grabbers grab the new wildshape form with same state
	for(var/list/grab_info in grab_data)
		var/mob/living/grabber = grab_info[1]
		var/grab_level = grab_info[2]
		var/was_tackled = grab_info[3]
		var/was_lying = grab_info[4]
		
		if(grabber && !grabber.stat)
			grabber.start_pulling(W)
			
			// Restore grab level
			var/obj/item/grabbing/new_grab = grabber.get_active_held_item()
			if(!istype(new_grab))
				new_grab = grabber.get_inactive_held_item()
			if(istype(new_grab) && new_grab.grabbed == W)
				new_grab.grab_state = grab_level
				// Restore tackle if they were tackled
				if(was_tackled && !W.buckled)
					grabber.buckle_mob(W, force = TRUE)
				// Restore lying state if they were prone
				if(was_lying)
					W.Knockdown(10) // Force them to lay down

/mob/living/carbon/human/proc/wildshape_untransform(dead,gibbed)
	if(!stored_mob)
		return
	if(!mind)
		log_runtime("NO MIND ON [src.name] WHEN UNTRANSFORMING")
	
	// Store who is grabbing us before untransformation
	var/list/grab_data = list()
	for(var/obj/item/grabbing/G in src.grabbedby)
		if(G.grabbee)
			var/tackle_status = FALSE
			if(G.grabbee.buckled_mobs && (src in G.grabbee.buckled_mobs))
				tackle_status = TRUE
			grab_data += list(list(G.grabbee, G.grab_state, tackle_status, src.lying))
	
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

	// Druids keep the exact same spells - they're already in spell_list
	// The mind.transfer_to() above already carried all spells back
	// Devotion also transfers automatically with the mind
	// No need to restore or remove anything

	W.regenerate_icons()

	to_chat(W, span_userdanger("I return to my old form."))

	W.stasis = FALSE
	
	// Restore grabs - make grabbers grab the restored human form with same state
	for(var/list/grab_info in grab_data)
		var/mob/living/grabber = grab_info[1]
		var/grab_level = grab_info[2]
		var/was_tackled = grab_info[3]
		var/was_lying = grab_info[4]
		
		if(grabber && !grabber.stat)
			grabber.start_pulling(W)
			
			// Restore grab level
			var/obj/item/grabbing/new_grab = grabber.get_active_held_item()
			if(!istype(new_grab))
				new_grab = grabber.get_inactive_held_item()
			if(istype(new_grab) && new_grab.grabbed == W)
				new_grab.grab_state = grab_level
				// Restore tackle if they were tackled
				if(was_tackled && !W.buckled)
					grabber.buckle_mob(W, force = TRUE)
				// Restore lying state if they were prone
				if(was_lying)
					W.Knockdown(10) // Force them to lay down

	qdel(src)
