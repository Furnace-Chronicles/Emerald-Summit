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

	//before we shed our items, save our neck and ring, if we have any, so we can quickly rewear them
	var/obj/item/stored_neck = wear_neck
	var/obj/item/stored_ring = wear_ring

	for(var/obj/item/I in src)
		if (I != underwear && I != cloak && I != legwear_socks && I != backl && I != backr) // keep underwear (+ socks) and our cloak, even if said cloak remains inaccessible.
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
	if (W.dna.species?.gibs_on_shapeshift)
		playsound(W, pick('sound/combat/gib (1).ogg','sound/combat/gib (2).ogg'), 200, FALSE, 3)
		W.spawn_gibs(FALSE)
	
	playsound(W, 'sound/body/shapeshift-start.ogg', 100, FALSE, 3)
	src.forceMove(W)

	// re-equip our stored neck and ring items, if we have them
	if (stored_ring)
		W.equip_to_slot_if_possible(stored_ring, SLOT_RING) // have to do this because we can wear psycrosses as rings even though we shouldn't be able to

	if (stored_neck)
		W.equip_to_slot_if_possible(stored_neck, SLOT_NECK)

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

	//transfer wounds as is across to our wildshape form
	for(var/obj/item/bodypart/human_bodypart as anything in H.bodyparts)	
		var/obj/item/bodypart/wildshape_BP = W.get_bodypart(human_bodypart.body_zone)
		if (wildshape_BP && LAZYLEN(human_bodypart.wounds))
			human_bodypart.transfer_wounds(wildshape_BP)

	//transfer blood volume across as well with a small bonus (20%)
	W.blood_volume = min(BLOOD_VOLUME_NORMAL, H.blood_volume*1.2)

	//transfer damage types (reduce brute and burn by 20%)
	W.adjustBruteLoss(H.getBruteLoss() * 0.8)
	W.adjustFireLoss(H.getFireLoss() * 0.8)
	W.adjustToxLoss(H.getToxLoss()) // toxins remains the dmg type of choice vs druids since it isn't reduced on transfer
	W.adjustOxyLoss(H.getOxyLoss())

	// transfer nutrition and hydration also
	W.set_hydration(H.hydration)
	W.set_nutrition(H.nutrition)

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

	// as before, save our worn stuff and prepare to move it back to the mob
	var/obj/item/stored_neck = wear_neck
	var/obj/item/stored_ring = wear_ring
	for(var/obj/item/W in src)
		dropItemToGround(W)
	icon = null
	invisibility = INVISIBILITY_MAXIMUM

	var/mob/living/carbon/human/W = stored_mob
	stored_mob = null

	REMOVE_TRAIT(W, TRAIT_NOSLEEP, TRAIT_GENERIC)

	// re-equip our stored neck and ring items, if we have them
	if (stored_ring)
		W.equip_to_slot_if_possible(stored_ring, SLOT_RING) // have to do this because we can wear psycrosses as rings even though we shouldn't be able to

	if (stored_neck)
		W.equip_to_slot_if_possible(stored_neck, SLOT_NECK)

	if(dead)
		W.death()

	W.forceMove(get_turf(src))

	mind.transfer_to(W)

	var/mob/living/carbon/human/species/wildshape/WA = src
	W.copy_known_languages_from(WA.stored_language)
	skills?.known_skills = WA.stored_skills.Copy()
	skills?.skill_experience = WA.stored_experience.Copy()
	playsound(W, 'sound/body/shapeshift-end.ogg', 100, FALSE, 3)

	// Druids keep the exact same spells - they're already in spell_list
	// The mind.transfer_to() above already carried all spells back
	// Devotion also transfers automatically with the mind
	// No need to restore or remove anything

	W.regenerate_icons()
	W.stasis = FALSE

	//transfer wounds as is across to our human form
	for(var/obj/item/bodypart/wildshape_bodypart as anything in WA.bodyparts)	
		var/obj/item/bodypart/human_BP = W.get_bodypart(wildshape_bodypart.body_zone)
		if (human_BP && LAZYLEN(wildshape_bodypart.wounds))
			wildshape_bodypart.transfer_wounds(human_BP)

	//transfer blood volume across as well with a small bonus (20%)
	W.blood_volume = min(BLOOD_VOLUME_NORMAL, WA.blood_volume*1.2)

	//transfer damage types (reduce brute and burn by 20%)
	W.adjustBruteLoss(WA.getBruteLoss() * 0.8)
	W.adjustFireLoss(WA.getFireLoss() * 0.8)
	W.adjustToxLoss(WA.getToxLoss()) // toxins remains the dmg type of choice vs druids since it isn't reduced on transfer
	W.adjustOxyLoss(WA.getOxyLoss())

	var/total_whp = 0
	for (var/datum/wound/wound as anything in W.get_wounds())
		total_whp += wound.whp

	// shifting back specifically cures exactly one third of our wounds
	W.heal_wounds(round(total_whp / 3))
	
	W.set_hydration(WA.hydration)
	W.set_nutrition(WA.nutrition)

	to_chat(W, span_userdanger("I return to my old form."))
	if (total_whp > 0)
		to_chat(W, span_notice("Dendor's grace mends some of my wounds as I return to my true flesh."))
	
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
