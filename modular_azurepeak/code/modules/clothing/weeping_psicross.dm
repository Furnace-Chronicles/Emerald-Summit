// Weeping Psicross + Weeping (Enduring) Ingot — Azure-Peak port.
// Berserker neck-piece that locks the wearer into a damage-trade glass-cannon
// loadout while equipped. Cannot be revived if you die wearing it (TRAIT_DNR).
//
// Provenance per the porting checklist:
//   - prevent_crits: dropped (AP behavior — no crit immunity)
//   - equip / unequip / storage delays: AP values
//   - Initialize visual: AP add_filter outline (GLOW_COLOR_VAMPIRIC)
//   - Equipped / Dropped chat: AP multi-line formatting
//   - Stat changes: AP swap-style, but END substituted for WIL since ES has
//     no willpower stat. Don: +STR +CON +END -INT.  Doff: inverse.
//   - Indentation: Ratwood tabs (AP source mixes 2-space inside Initialize)
//   - TRAIT_PSYCHOSIS dropped (not defined in ES); the four mechanical
//     traits (NOCSHADES / DNR / STRONGKICK / STRENGTH_UNCAPPED) keep the
//     berserker identity intact.

#define WEEPING_PSICROSS_GLOW "weeping_psicross_glow"
#define WEEPING_INGOT_GLOW "weeping_ingot_glow"

/obj/item/clothing/neck/roguetown/psicross/weeping
	name = "weeping psycross"
	desc = "'Let His name be naught but forgot'n.' </br>The alloy is familiar, but unmentionable. Blood oozes from cracks within the psycross; ensnared in a perpetual state of half-coagulation. A deathly chill tugs your neck, and your cheeks feel wet - are those tears?"
	slot_flags = ITEM_SLOT_NECK|ITEM_SLOT_WRISTS
	icon_state = "psicrossblood"
	max_integrity = 666
	edelay_type = 1
	equip_delay_self = 3 SECONDS
	unequip_delay_self = 7 SECONDS
	inv_storage_delay = 3 SECONDS
	smeltresult = /obj/item/ingot/weeping
	sellprice = 666
	var/active_item
	/// Flag set while a self-triggered slow-unequip is in progress. The signal
	/// handler returns COMPONENT_ITEM_BLOCK_UNEQUIP on the first attempt, kicks
	/// off do_after async, then lets the next unequip attempt (or the forced
	/// drop after do_after completes) pass through cleanly.
	var/unequipping_in_progress = FALSE
	/// Flag set while a slow-unequip do_after is waiting to complete. Stops a
	/// second click from spawning a phantom do_after that immediately fails on
	/// the do_after `user.doing` guard, which was misleading users into thinking
	/// the second click was the one that "worked" when in fact the first one
	/// was already running silently.
	var/slow_unequip_pending = FALSE

/obj/item/clothing/neck/roguetown/psicross/weeping/Initialize()
	. = ..()
	add_filter(WEEPING_PSICROSS_GLOW, 2, list("type" = "outline", "color" = GLOW_COLOR_VAMPIRIC, "alpha" = 200, "size" = 1))
	// Hallucination strings live in strings/maniac.json — loader is idempotent
	// so re-loading per-instance is cheap (just hits the global cache).
	load_strings_file("maniac.json")

/obj/item/clothing/neck/roguetown/psicross/weeping/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

// Hallucination loop. Ported from /datum/antagonist/maniac/process and its
// handlers in maniac_life.dm — the maniac antag's process() never actually
// calls handle_hallucinations (it's orphaned upstream), so we drive it here.
// Runs once per SSobj tick (~1s) while the necklace sits on a living mob's
// neck. Each handler internally rolls prob() so the actual hallucinations
// stay sparse and unpredictable rather than constant.
/obj/item/clothing/neck/roguetown/psicross/weeping/process()
	if(!active_item)
		STOP_PROCESSING(SSobj, src)
		return
	if(!ishuman(loc))
		STOP_PROCESSING(SSobj, src)
		return
	var/mob/living/carbon/human/wearer = loc
	if(wearer.stat == DEAD || wearer.wear_neck != src)
		STOP_PROCESSING(SSobj, src)
		return
	weeping_handle_visions(wearer)
	weeping_handle_hallucinations(wearer)

// Random laughter / atmosphere sounds. ~once every 40 seconds on average.
// Original maniac uses prob(1) here, but the maniac wears the effect for the
// whole round; the necklace is more transient, so the rates are tuned up.
/obj/item/clothing/neck/roguetown/psicross/weeping/proc/weeping_handle_visions(mob/living/dreamer)
	if(prob(5))
		var/static/list/funnies = list(
			'sound/villain/comic1.ogg',
			'sound/villain/comic2.ogg',
			'sound/villain/comic3.ogg',
			'sound/villain/comic4.ogg',
		)
		dreamer.playsound_local(dreamer, pick(funnies), vol = 100, vary = FALSE)

// Mob chase ~every 70s, talking object ~every 13s. Both fire async so the
// chase loop doesn't block the SSobj tick. Original maniac uses prob(1) and
// prob(4) — tuned higher here so the necklace effect is actually noticeable
// within a normal wear session.
/obj/item/clothing/neck/roguetown/psicross/weeping/proc/weeping_handle_hallucinations(mob/living/dreamer)
	if(prob(3))
		INVOKE_ASYNC(src, PROC_REF(weeping_handle_mob_hallucination), dreamer)
	else if(prob(15))
		INVOKE_ASYNC(src, PROC_REF(weeping_handle_object_hallucination), dreamer)

// Talking object — pick a nearby weight-biased object and make it whisper a
// haunting phrase pulled from strings/maniac.json. Plays a speech SFX local
// to the wearer only; other players don't hear or see anything.
/obj/item/clothing/neck/roguetown/psicross/weeping/proc/weeping_handle_object_hallucination(mob/living/dreamer)
	if(!dreamer?.client)
		return
	var/list/objects = list()
	for(var/obj/object in view(dreamer))
		if((object.invisibility > dreamer.see_invisible) || !object.loc || !object.name)
			continue
		var/weight = 1
		if(isitem(object))
			weight = 3
		else if(isstructure(object))
			weight = 2
		else if(ismachinery(object))
			weight = 2
		objects[object] = weight
	objects -= dreamer.contents
	if(!length(objects))
		return
	var/static/list/speech_sounds = list(
		'sound/villain/female_talk1.ogg',
		'sound/villain/female_talk2.ogg',
		'sound/villain/female_talk3.ogg',
		'sound/villain/female_talk4.ogg',
		'sound/villain/female_talk5.ogg',
		'sound/villain/male_talk1.ogg',
		'sound/villain/male_talk2.ogg',
		'sound/villain/male_talk3.ogg',
		'sound/villain/male_talk4.ogg',
		'sound/villain/male_talk5.ogg',
		'sound/villain/male_talk6.ogg',
	)
	var/obj/speaker = pickweight(objects)
	var/speech
	if(prob(1))
		speech = "[rand(0,9)][rand(0,9)][rand(0,9)][rand(0,9)]"
	else
		speech = pick_list_replacements("maniac.json", "dreamer_object")
		speech = replacetext(speech, "%OWNER", "[dreamer.real_name]")
	var/language = dreamer.get_random_understood_language()
	var/message = dreamer.compose_message(speaker, language, speech)
	dreamer.playsound_local(dreamer, pick(speech_sounds), vol = 60, vary = FALSE)
	if(dreamer.client.prefs?.chat_on_map)
		dreamer.create_chat_message(speaker, language, speech, spans = list(dreamer.speech_span))
	to_chat(dreamer, message)

// Chasing-mob hallucination — spawns a client-side image of mom / shadow /
// deepone on a random nearby turf and walks it toward the wearer over 7
// tiles. Catches them on contact for a brief stun. Image is removed at the
// end so it doesn't leak across the round.
/obj/item/clothing/neck/roguetown/psicross/weeping/proc/weeping_handle_mob_hallucination(mob/living/dreamer)
	if(!dreamer.client)
		return
	var/mob_message = pick("It's mom!", "I have to HURRY UP!", "They are CLOSE!", "They are NEAR!")
	var/turf/spawning_turf
	var/list/turf/spawning_turfs = list()
	for(var/turf/turf in view(dreamer))
		spawning_turfs += turf
	if(length(spawning_turfs))
		spawning_turf = pick(spawning_turfs)
	if(!spawning_turf)
		return
	var/mob_state = pick("mom", "shadow", "deepone")
	if(mob_message == "It's mom!")
		mob_state = "mom"
	var/image/mob_image = image('icons/roguetown/maniac/dreamer_mobs.dmi', spawning_turf, mob_state, FLOAT_LAYER, get_dir(spawning_turf, dreamer))
	mob_image.plane = GAME_PLANE_UPPER
	dreamer.client.images += mob_image
	to_chat(dreamer, span_userdanger("<span class='big'>[mob_message]</span>"))
	sleep(5)
	if(!dreamer?.client)
		return
	var/static/list/spookies = list(
		'sound/villain/hall_attack1.ogg',
		'sound/villain/hall_attack2.ogg',
		'sound/villain/hall_attack3.ogg',
		'sound/villain/hall_attack4.ogg',
	)
	dreamer.playsound_local(dreamer, pick(spookies), 100)
	var/chase_tiles = 7
	var/chase_wait = rand(4, 6)
	var/caught_dreamer = FALSE
	var/turf/current_turf = spawning_turf
	while(chase_tiles > 0)
		if(!dreamer?.client)
			return
		var/face_direction = get_dir(current_turf, dreamer)
		current_turf = get_step(current_turf, face_direction)
		if(!current_turf)
			break
		mob_image.dir = face_direction
		mob_image.loc = current_turf
		if(current_turf == get_turf(dreamer))
			caught_dreamer = TRUE
			break
		chase_tiles--
		sleep(chase_wait)
	if(!dreamer?.client)
		return
	if(caught_dreamer)
		dreamer.Stun(rand(2, 4) SECONDS)
		var/pain_message = pick("NO!", "THEY GOT ME!", "AGH!")
		to_chat(dreamer, span_userdanger("[pain_message]"))
	sleep(chase_wait)
	if(!dreamer?.client)
		return
	dreamer.client.images -= mob_image

// Slow-on: ES's species.can_equip skips equip_delay_self_check for SLOT_NECK
// (every other necklace in the game is instant-equip), but we want this one
// to feel like a deliberate commitment given the DNR + berserk effect. Run
// the same delay check the species runs for back/head slots.
/obj/item/clothing/neck/roguetown/psicross/weeping/mob_can_equip(mob/living/M, mob/living/equipper, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE)
	. = ..()
	if(!. || slot != SLOT_NECK || bypass_equip_delay_self)
		return .
	if(!ishuman(M))
		return .
	var/mob/living/carbon/human/H = M
	if(!H.dna.species.equip_delay_self_check(src, H, bypass_equip_delay_self))
		return FALSE
	return .

// Slow-off: ES's base doUnEquip ignores unequip_delay_self entirely, so we
// drive the wait from attack_hand instead. attack_hand is the proc the click
// pipeline lands on when the wearer clicks the necklace's inventory slot —
// it runs fully synchronously, so we can gate the entire flow on a single
// boolean without worrying about INVOKE_ASYNC race conditions on a duplicate
// click. unequipping_in_progress is still kept as a force-bypass so the
// internal temporarilyRemoveItemFromInventory call after the do_after can
// flow through any future COMSIG_ITEM_PRE_UNEQUIP listener cleanly.
/obj/item/clothing/neck/roguetown/psicross/weeping/attack_hand(mob/user)
	// Only intercept when the wearer clicks the item already on their own
	// neck. Any other path (clicking it on the floor, taking it from a bag,
	// stripping it off another mob, etc.) falls through to the standard
	// attack_hand pickup flow.
	if(loc != user || !ishuman(user) || !unequip_delay_self)
		return ..()
	var/mob/living/carbon/human/L = user
	if(L.wear_neck != src)
		return ..()
	if(slow_unequip_pending)
		to_chat(L, span_smallnotice("I am already taking off [src]..."))
		return
	slow_unequip_pending = TRUE
	L.visible_message(
		span_smallnotice("[L] starts taking off [src]..."),
		span_smallnotice("I start taking off [src]..."),
	)
	// needhand = FALSE so drawing/sheathing or picking something else up
	// during the 7-second wait doesn't silently invalidate the unequip.
	if(!do_after(L, unequip_delay_self, needhand = FALSE, target = L))
		slow_unequip_pending = FALSE
		return
	slow_unequip_pending = FALSE
	if(QDELETED(src) || src.loc != L)
		return
	// Hand-off rather than drop — mirrors the standard "click your worn item
	// to grab it" flow in /obj/item/attack_hand:710-717. unequipping_in_progress
	// is still set so any future code that watches COMSIG_ITEM_PRE_UNEQUIP on
	// this item knows the unequip is sanctioned and shouldn't be intercepted.
	unequipping_in_progress = TRUE
	if(L.temporarilyRemoveItemFromInventory(src))
		L.put_in_hands(src)
	unequipping_in_progress = FALSE

/obj/item/clothing/neck/roguetown/psicross/weeping/equipped(mob/user, slot)
	. = ..()
	if(slot != SLOT_NECK)
		return
	if(!isliving(user))
		return
	var/mob/living/L = user
	active_item = TRUE
	to_chat(L, span_red("As you don the psycross, the chains tighten like a vice around your neck!  </br>  </br>You're overcome with a sense of terrible anguish - all of humenity's suffering, thrust upon your very spirit!  </br>  </br>Your chest grows cold, yet your blood boils hotter than magma! Psydonia's villains may be brutal and merciless, but you will be WORSE!  </br>  </br>You've gone BERSERK!"))
	L.change_stat(STATKEY_STR, 3)
	L.change_stat(STATKEY_CON, 3)
	L.change_stat(STATKEY_END, 3)
	L.change_stat(STATKEY_INT, -3)
	ADD_TRAIT(L, TRAIT_NOCSHADES, TRAIT_GENERIC) //Roughly ~30% reduced vision with a sharp red overlay. Provides night vision in the visible tiles.
	ADD_TRAIT(L, TRAIT_DNR, TRAIT_GENERIC) //If you die while the necklace's on, that's it. Technically saveable if someone knows to remove the necklace, before attempting resurrection.
	ADD_TRAIT(L, TRAIT_STRONGKICK, TRAIT_GENERIC)
	ADD_TRAIT(L, TRAIT_STRENGTH_UNCAPPED, TRAIT_GENERIC)
	L.apply_status_effect(/datum/status_effect/buff/weeping_berserker)
	// Paint the red inq overlay + nocshade lighting on the same tick the necklace
	// lands rather than waiting for the player's next movement to flush BYOND's
	// render pipeline. update_sight() reads HAS_TRAIT(TRAIT_NOCSHADES) and pushes
	// add_client_colour + overlay_fullscreen, which apply to the client immediately.
	if(iscarbon(L))
		var/mob/living/carbon/C = L
		C.update_sight()
	// Start the hallucination loop — laughter SFX, talking objects, and chasing
	// mom/shadow/deepone images. Ported wholesale from the maniac antag's
	// process() chain (maniac_life.dm). Stops on doff via STOP_PROCESSING.
	START_PROCESSING(SSobj, src)

/obj/item/clothing/neck/roguetown/psicross/weeping/dropped(mob/user)
	..()
	if(!active_item)
		return
	if(!isliving(user))
		active_item = FALSE
		return
	var/mob/living/L = user
	if(L.stat != DEAD)
		to_chat(L, span_monkeyhive("..and at once, the mania subsides. A familiar warmth creeps back into your chest. Though your mind is clear, the thought lingers; was it truly just a malaise, or something more? </br>  </br>..perhaps, this would better fit in the smoldering heat of a forge.."))
	L.change_stat(STATKEY_STR, -3)
	L.change_stat(STATKEY_CON, -3)
	L.change_stat(STATKEY_END, -3)
	L.change_stat(STATKEY_INT, 3)
	REMOVE_TRAIT(L, TRAIT_NOCSHADES, TRAIT_GENERIC)
	REMOVE_TRAIT(L, TRAIT_DNR, TRAIT_GENERIC)
	REMOVE_TRAIT(L, TRAIT_STRONGKICK, TRAIT_GENERIC)
	REMOVE_TRAIT(L, TRAIT_STRENGTH_UNCAPPED, TRAIT_GENERIC)
	L.remove_status_effect(/datum/status_effect/buff/weeping_berserker)
	// Mirror the equipped() call — drop the red overlay/tint on the same tick
	// the necklace comes off instead of waiting for the next move.
	if(iscarbon(L))
		var/mob/living/carbon/C = L
		C.update_sight()
	STOP_PROCESSING(SSobj, src)
	active_item = FALSE

// Enduring Ingot — smelt output of a weeping psicross. Glows the same vampire
// outline as the necklace so its origin is recognizable on the floor / belt.

/obj/item/ingot/weeping
	name = "enduring ingot"
	desc = "A slab of metal, aged and bare. You finally know what it is, yet no word can be sired to describe it. </br>'..none will ever know the greatest truths; of Aeon's grasp, of Adonai's presence, of Psydon's fate..' </br>'..but, perhaps, that's for the better. The malaise is gone, but the evils of this world are still very real..' </br>'..find a way to give the remains a new lyfe; a new vessel that may yet make the Archdevil weep..'"
	icon_state = "ingotsilv"
	smeltresult = /obj/item/ingot/weeping
	color = "#CECA9C"
	sellprice = 222

/obj/item/ingot/weeping/Initialize()
	. = ..()
	add_filter(WEEPING_INGOT_GLOW, 2, list("type" = "outline", "color" = GLOW_COLOR_VAMPIRIC, "alpha" = 100, "size" = 1))

// Indefinite-duration screen alert + buff datum that surfaces what the necklace
// is doing to the wearer. Stats are applied / reverted in equipped() / dropped()
// directly rather than via effectedstats so the base /datum/status_effect/on_apply
// is a no-op (just returns TRUE). on_apply override below skips the base's
// stat-handling loop so we can't hit an issue with the get_stat / change_stat
// string-key mismatch that broke an earlier version of this code. Clicking the
// alert still prints the name + desc + the effectedstats readout — we set
// effectedstats just for the readout, NOT for application.

/datum/status_effect/buff/weeping_berserker
	id = "weeping_berserker"
	alert_type = /atom/movable/screen/alert/status_effect/buff/weeping_berserker
	duration = -1
	examine_text = "SUBJECTPRONOUN is locked in a wide-eyed, blood-soaked rage."
	effectedstats = list("strength" = 3, "constitution" = 3, "endurance" = 3, "intelligence" = -3)

// Skip the base's automatic stat application — equipped() already did it.
/datum/status_effect/buff/weeping_berserker/on_apply()
	return TRUE

// Skip the base's automatic stat reversal — dropped() already did it.
/datum/status_effect/buff/weeping_berserker/on_remove()
	return

/atom/movable/screen/alert/status_effect/buff/weeping_berserker
	name = "Weeping Berserker"
	desc = "The weeping psycross has me in its grip. Cannot be revived if I die wearing it."
	icon_state = "buff"

#undef WEEPING_PSICROSS_GLOW
#undef WEEPING_INGOT_GLOW
