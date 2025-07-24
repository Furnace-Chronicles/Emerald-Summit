#ifdef TESTSERVER
/mob/living/carbon/human/verb/become_vampire()
	set category = "DEBUGTEST"
	set name = "VAMPIRETEST"
	if(mind)
		var/datum/antagonist/vampire/new_antag = new /datum/antagonist/vampire()
		mind.add_antag_datum(new_antag)
#endif

/datum/antagonist/vampire
	name = "Vampire"
	roundend_category = "Vampires"
	antagpanel_category = "Vampire"
	job_rank = ROLE_VAMPIRE
	antag_hud_type = ANTAG_HUD_TRAITOR
	antag_hud_name = "vampire"
	confess_lines = list(
		"I WANT YOUR BLOOD!",
		"DRINK THE BLOOD!",
		"CHILD OF KAIN!",
	)
	rogue_enabled = TRUE
	var/disguised = TRUE
	var/vitae = 1000
	var/last_transform
	var/is_lesser = FALSE
	var/cache_skin
	var/cache_eyes
	var/cache_hair
	var/obj/effect/proc_holder/spell/targeted/shapeshift/bat/batform //attached to the datum itself to avoid cloning memes, and other duplicates
	var/wretch_antag = FALSE
	var/vitae_tick_counter = 0
	var/list/original_organ_icons = list()
	var/list/original_organ_icon_states = list()
	var/list/original_organ_colors = list()
	var/list/original_organ_accessory_colors = list()
	var/list/original_organ_overlays = list()
	var/list/original_organ_underlays = list()
	var/original_mutant_color
	var/original_mutant_color2
	var/original_mutant_color3

/datum/antagonist/vampire/examine_friendorfoe(datum/antagonist/examined_datum,mob/examiner,mob/examined)
	if(istype(examined_datum, /datum/antagonist/vampire/lesser))
		return span_boldnotice("A child of Kain.")
	if(istype(examined_datum, /datum/antagonist/vampire))
		return span_boldnotice("An elder Kin.")
	if(examiner.Adjacent(examined))
		if(istype(examined_datum, /datum/antagonist/werewolf/lesser))
			if(!disguised)
				return span_boldwarning("I sense a lesser Werewolf.")
		if(istype(examined_datum, /datum/antagonist/werewolf))
			if(!disguised)
				return span_boldwarning("THIS IS AN ELDER WEREWOLF! MY ENEMY!")
	if(istype(examined_datum, /datum/antagonist/zombie))
		return span_boldnotice("Another deadite.")
	if(istype(examined_datum, /datum/antagonist/skeleton))
		return span_boldnotice("Another deadite.")

/datum/antagonist/vampire/lesser //le shitcode faec
	name = "Lesser Vampire"
	is_lesser = TRUE
	increase_votepwr = FALSE

/datum/antagonist/vampire/lesser/roundend_report()
	return

/datum/antagonist/vampire/on_gain()
	if(!is_lesser)
		owner.current.adjust_skillrank(/datum/skill/combat/wrestling, 6, TRUE)
		owner.current.adjust_skillrank(/datum/skill/combat/unarmed, 6, TRUE)
		ADD_TRAIT(owner.current, TRAIT_NOBLE, TRAIT_GENERIC)
	owner.special_role = name
	ADD_TRAIT(owner.current, TRAIT_STRONGBITE, TRAIT_GENERIC)
	ADD_TRAIT(owner.current, TRAIT_NOHUNGER, TRAIT_GENERIC)
	ADD_TRAIT(owner.current, TRAIT_NOBREATH, TRAIT_GENERIC)
	ADD_TRAIT(owner.current, TRAIT_NOPAIN, TRAIT_GENERIC)
	ADD_TRAIT(owner.current, TRAIT_TOXIMMUNE, TRAIT_GENERIC)
	ADD_TRAIT(owner.current, TRAIT_STEELHEARTED, TRAIT_GENERIC)
	ADD_TRAIT(owner.current, TRAIT_NASTY_EATER, TRAIT_GENERIC)
	ADD_TRAIT(owner.current, TRAIT_BLOODLOSS_IMMUNE, TRAIT_GENERIC)
	ADD_TRAIT(owner.current, TRAIT_NOSLEEP, TRAIT_GENERIC)
	ADD_TRAIT(owner.current, TRAIT_ZOMBIE_IMMUNE, TRAIT_GENERIC)
	owner.current.cmode_music = 'sound/music/combat_vamp2.ogg'
	var/obj/item/organ/eyes/eyes = owner.current.getorganslot(ORGAN_SLOT_EYES)
	if(eyes)
		eyes.Remove(owner.current,1)
		QDEL_NULL(eyes)
		eyes = new /obj/item/organ/eyes/night_vision/zombie
		eyes.Insert(owner.current)
	if(increase_votepwr)
		forge_vampire_objectives()
	finalize_vampire()
	var/mob/living/carbon/human/H = owner.current
	if(wretch_antag && istype(H))
		cache_skin = H.skin_tone
		cache_eyes = H.eye_color
		cache_hair = H.hair_color
		vitae = 5000 // Always set vitae for wretch vampires
		H.verbs |= /mob/living/carbon/human/proc/disguise_button
		H.verbs |= /mob/living/carbon/human/proc/vamp_regenerate
		// Give wretch vampires their vampiric appearance
		wretch_vamp_look()
	if(!is_lesser)
		owner.current.verbs |= /mob/living/carbon/human/proc/blood_strength
		owner.current.verbs |= /mob/living/carbon/human/proc/blood_celerity
		owner.current.verbs |= /mob/living/carbon/human/proc/blood_fortitude
	return ..()

/datum/antagonist/vampire/on_removal()
	if(!silent && owner.current)
		to_chat(owner.current,span_danger("I am no longer a [job_rank]!"))
	owner.special_role = null
	if(!isnull(batform))
		owner.current.RemoveSpell(batform)
		QDEL_NULL(batform)
	return ..()

/datum/antagonist/vampire/proc/add_objective(datum/objective/O)
	objectives += O

/datum/antagonist/vampire/proc/remove_objective(datum/objective/O)
	objectives -= O

/datum/antagonist/vampire/proc/forge_vampire_objectives()
	if(!(locate(/datum/objective/escape) in objectives))
		var/datum/objective/vampire/escape_objective = new
		escape_objective.owner = owner
		add_objective(escape_objective)
		return

/datum/antagonist/vampire/greet()
	to_chat(owner.current, span_userdanger("Ever since that bite, I have been a VAMPIRE."))
	owner.announce_objectives()
	..()

/datum/antagonist/vampire/proc/finalize_vampire()
	owner.current.playsound_local(get_turf(owner.current), 'sound/music/vampintro.ogg', 80, FALSE, pressure_affected = FALSE)

/datum/antagonist/vampire/on_life(mob/user)
	if(!user)
		return
	var/mob/living/carbon/human/H = user
	if(H.stat == DEAD)
		return
	if(H.advsetup)
		return

	if(world.time % 5)
		if(GLOB.tod != "night")
			if(isturf(H.loc))
				var/turf/T = H.loc
				if(T.can_see_sky())
					if(T.get_lumcount() > 0.15)
						// Cache antagonist lookup to avoid repeated lookups
						var/datum/antagonist/vampire/wretch_vamp = H.mind?.has_antag_datum(/datum/antagonist/vampire)
						var/is_wretch = wretch_vamp && wretch_vamp.wretch_antag
						
						if(!disguised)
							H.fire_act(1,2)
						// Only apply additional fire damage if wretch vampire and not already handled
						if(is_wretch && !disguised)
							H.fire_act(1,5)
							wretch_vamp.vitae = max(wretch_vamp.vitae - 10, 0)

	if(H.on_fire)
		if(disguised)
			last_transform = world.time
			H.vampire_undisguise(src)
		H.freak_out()

	if(H.stat)
		if(istype(H.loc, /obj/structure/closet/crate/coffin))
			H.fully_heal()

	// Optimized vitae management for wretch vampires
	if(wretch_antag)
		// Only check blood volume when it might exceed the cap
		if(H.blood_volume > 5000)
			H.blood_volume = 5000
		// Only check vitae cap when it might exceed
		if(vitae > 5000)
			vitae = 5000
		// Only update vitae every minute instead of every tick
		vitae_tick_counter++
		if(vitae_tick_counter >= 120)  // Every 120 ticks = 1 minute
			vitae = max(vitae - 60, 0)  // Lose 60 vitae per minute instead of 1 per tick
			vitae_tick_counter = 0  // Reset counter
	else
		vitae = CLAMP(vitae, 0, 1666)
		// Non-wretch vampire vitae management
		if(vitae > 0)
			H.blood_volume = BLOOD_VOLUME_MAXIMUM
			if(vitae < 200)
				if(disguised)
					to_chat(H, "<span class='warning'>My disguise fails!</span>")
					H.vampire_undisguise(src)
			// Only decrement vitae every 5 ticks
			if(world.time % 50 == 0)
				vitae -= 1
		else
			to_chat(H, "<span class='userdanger'>I RAN OUT OF VITAE!</span>")
			var/obj/shapeshift_holder/SS = locate() in H
			if(SS)
				SS.shape.dust()
			H.dust()
			return

/mob/living/carbon/human/proc/disguise_button()
	set name = "Disguise"
	set category = "VAMPIRE"

	var/datum/antagonist/vampirelord/VDL = mind.has_antag_datum(/datum/antagonist/vampirelord)
	var/datum/antagonist/vampire/Vamp = mind.has_antag_datum(/datum/antagonist/vampire)
	
	if(!VDL && !Vamp)
		return
	
	var/is_wretch = FALSE
	
	if(!VDL && Vamp && Vamp.wretch_antag)
		is_wretch = TRUE
	else if(!VDL)
		return
	
	if(is_wretch)
		if(world.time < Vamp.last_transform + 30 SECONDS)
			var/timet2 = (Vamp.last_transform + 30 SECONDS) - world.time
			to_chat(src, span_warning("No.. not yet. [round(timet2/10)]s"))
			return
		if(Vamp.disguised)
			Vamp.last_transform = world.time
			vampire_undisguise_wretch(Vamp)
			to_chat(src, span_notice("I drop my disguise, revealing my true nature."))
		else
			var/vitae_cost = 100
			if(Vamp.vitae < vitae_cost)
				to_chat(src, span_warning("I don't have enough Vitae!"))
				return
			Vamp.last_transform = world.time
			vampire_disguise_wretch(Vamp)
			to_chat(src, span_notice("I assume a human guise to hide my vampiric nature."))
	else
		if(world.time < VDL.last_transform + 30 SECONDS)
			var/timet2 = (VDL.last_transform + 30 SECONDS) - world.time
			to_chat(src, span_warning("No.. not yet. [round(timet2/10)]s"))
			return
		if(VDL.disguised)
			VDL.last_transform = world.time
			vampire_undisguise(VDL)
			to_chat(src, span_notice("I drop my disguise, revealing my true nature."))
		else
			var/vitae_cost = 100
			if(VDL.vitae < vitae_cost)
				to_chat(src, span_warning("I don't have enough Vitae!"))
				return
			VDL.last_transform = world.time
			vampire_disguise(VDL)
			to_chat(src, span_notice("I assume a human guise to hide my vampiric nature."))

/mob/living/carbon/human/proc/vampire_undisguise_wretch(datum/antagonist/vampire/VD)
	if(!VD)
		return
	VD.disguised = FALSE
	// Set vampiric appearance: skin/mutant/organs = c9d3de, hair = 181a1d, eyes = ff0000
	skin_tone = "c9d3de"
	hair_color = "181a1d"
	facial_hair_color = "181a1d"
	eye_color = "ff0000"
	// Store and set mutant color(s) to c9d3de
	if(src.dna && islist(src.dna.features)) {
		if("mcolor" in src.dna.features) {
			if(!VD.original_mutant_color) VD.original_mutant_color = src.dna.features["mcolor"]
			src.dna.features["mcolor"] = "c9d3de"
		}
		if("mcolor2" in src.dna.features) {
			if(!VD.original_mutant_color2) VD.original_mutant_color2 = src.dna.features["mcolor2"]
			src.dna.features["mcolor2"] = "c9d3de"
		}
		if("mcolor3" in src.dna.features) {
			if(!VD.original_mutant_color3) VD.original_mutant_color3 = src.dna.features["mcolor3"]
			src.dna.features["mcolor3"] = "c9d3de"
		}
	}
	// Store and apply vampire appearance to visible organs
	if(!islist(VD.original_organ_icons)) VD.original_organ_icons = list()
	if(!islist(VD.original_organ_icon_states)) VD.original_organ_icon_states = list()
	if(!islist(VD.original_organ_colors)) VD.original_organ_colors = list()
	if(!islist(VD.original_organ_accessory_colors)) VD.original_organ_accessory_colors = list()
	if(!islist(VD.original_organ_overlays)) VD.original_organ_overlays = list()
	if(!islist(VD.original_organ_underlays)) VD.original_organ_underlays = list()
	for(var/obj/item/organ/O in internal_organs)
		if(istype(O, /obj/item/organ/tail) || istype(O, /obj/item/organ/wings) || istype(O, /obj/item/organ/ears) || istype(O, /obj/item/organ/snout) || istype(O, /obj/item/organ/horns) || istype(O, /obj/item/organ/frills) || istype(O, /obj/item/organ/penis) || istype(O, /obj/item/organ/breasts)) {
			if(!(O in VD.original_organ_icons)) VD.original_organ_icons[O] = O.icon
			if(!(O in VD.original_organ_icon_states)) VD.original_organ_icon_states[O] = O.icon_state
			if(!(O in VD.original_organ_colors)) VD.original_organ_colors[O] = O.color
			if(!(O in VD.original_organ_accessory_colors)) VD.original_organ_accessory_colors[O] = O.accessory_colors
			if(!(O in VD.original_organ_overlays)) VD.original_organ_overlays[O] = O.overlays
			if(!(O in VD.original_organ_underlays)) VD.original_organ_underlays[O] = O.underlays
			O.icon = 'icons/mob/mob.dmi'
			O.icon_state = "blank"
			O.color = "c9d3de"
			O.accessory_colors = "c9d3de"
			O.overlays = list("c9d3de")
			O.underlays = list("c9d3de")
			if(hascall(O, "update_icon")) call(O, "update_icon")()
		}
	update_body()
	update_hair()
	update_body_parts(redraw = TRUE)

/mob/living/carbon/human/proc/vampire_disguise_wretch(datum/antagonist/vampire/VD)
	if(!VD)
		return
	VD.disguised = TRUE
	// Restore original human appearance
	skin_tone = VD.cache_skin
	hair_color = VD.cache_hair
	facial_hair_color = VD.cache_hair
	eye_color = VD.cache_eyes
	// Restore original mutant color(s)
	if(src.dna && islist(src.dna.features)) {
		if("mcolor" in src.dna.features && VD.original_mutant_color)
			src.dna.features["mcolor"] = VD.original_mutant_color
		if("mcolor2" in src.dna.features && VD.original_mutant_color2)
			src.dna.features["mcolor2"] = VD.original_mutant_color2
		if("mcolor3" in src.dna.features && VD.original_mutant_color3)
			src.dna.features["mcolor3"] = VD.original_mutant_color3
	}
	// Restore original appearance to visible organs
	for(var/obj/item/organ/O in internal_organs)
		if(istype(O, /obj/item/organ/tail) || istype(O, /obj/item/organ/wings) || istype(O, /obj/item/organ/ears) || istype(O, /obj/item/organ/snout) || istype(O, /obj/item/organ/horns) || istype(O, /obj/item/organ/frills) || istype(O, /obj/item/organ/penis) || istype(O, /obj/item/organ/breasts)) {
			if(islist(VD.original_organ_icons) && (O in VD.original_organ_icons)) O.icon = VD.original_organ_icons[O]
			if(islist(VD.original_organ_icon_states) && (O in VD.original_organ_icon_states)) O.icon_state = VD.original_organ_icon_states[O]
			if(islist(VD.original_organ_colors) && (O in VD.original_organ_colors)) O.color = VD.original_organ_colors[O]
			if(islist(VD.original_organ_accessory_colors) && (O in VD.original_organ_accessory_colors)) O.accessory_colors = VD.original_organ_accessory_colors[O]
			if(islist(VD.original_organ_overlays) && (O in VD.original_organ_overlays)) O.overlays = VD.original_organ_overlays[O]
			if(islist(VD.original_organ_underlays) && (O in VD.original_organ_underlays)) O.underlays = VD.original_organ_underlays[O]
			if(hascall(O, "update_icon")) call(O, "update_icon")()
		}
	update_body()
	update_hair()
	update_body_parts(redraw = TRUE)

/mob/living/carbon/human/proc/vampire_disguise(datum/antagonist/vampirelord/VD)
	if(!VD)
		return
	VD.disguised = TRUE
	skin_tone = VD.cache_skin
	hair_color = VD.cache_hair
	eye_color = VD.cache_eyes
	facial_hair_color = VD.cache_hair
	update_body()
	update_hair()
	update_body_parts(redraw = TRUE)

/mob/living/carbon/human/proc/vampire_undisguise(datum/antagonist/vampirelord/VD)
	if(!VD)
		return
	VD.disguised = FALSE
	skin_tone = VD.cache_skin
	hair_color = VD.cache_hair
	eye_color = VD.cache_eyes
	facial_hair_color = VD.cache_hair
	update_body()
	update_hair()
	update_body_parts(redraw = TRUE)

/mob/living/carbon/human/proc/blood_strength()
	set name = "Night Muscles"
	set category = "VAMPIRE"

	var/datum/antagonist/vampirelord/VD = mind.has_antag_datum(/datum/antagonist/vampirelord)
	if(!VD)
		return
	if(VD.disguised)
		to_chat(src, span_warning("My curse is hidden."))
		return
	if(VD.vitae < 100)
		to_chat(src, span_warning("Not enough vitae."))
		return
	if(has_status_effect(/datum/status_effect/buff/bloodstrength))
		to_chat(src, span_warning("Already active."))
		return
	VD.handle_vitae(-100)
	apply_status_effect(/datum/status_effect/buff/bloodstrength)
	to_chat(src, span_greentext("! NIGHT MUSCLES !"))
	src.playsound_local(get_turf(src), 'sound/misc/vampirespell.ogg', 100, FALSE, pressure_affected = FALSE)

/datum/status_effect/buff/bloodstrength
	id = "bloodstrength"
	alert_type = /atom/movable/screen/alert/status_effect/buff/bloodstrength
	effectedstats = list("strength" = 6)
	duration = 1 MINUTES

/atom/movable/screen/alert/status_effect/buff/bloodstrength
	name = "Night Muscles"
	desc = ""
	icon_state = "bleed1"

/mob/living/carbon/human/proc/blood_celerity()
	set name = "Quickening"
	set category = "VAMPIRE"

	var/datum/antagonist/vampirelord/VD = mind.has_antag_datum(/datum/antagonist/vampirelord)
	if(!VD)
		return
	if(VD.disguised)
		to_chat(src, span_warning("My curse is hidden."))
		return
	if(VD.vitae < 100)
		to_chat(src, span_warning("Not enough vitae."))
		return
	if(has_status_effect(/datum/status_effect/buff/celerity))
		to_chat(src, span_warning("Already active."))
		return
	VD.handle_vitae(-100)
	energy_add(2000)
	apply_status_effect(/datum/status_effect/buff/celerity)
	to_chat(src, span_greentext("! QUICKENING !"))
	src.playsound_local(get_turf(src), 'sound/misc/vampirespell.ogg', 100, FALSE, pressure_affected = FALSE)

/datum/status_effect/buff/celerity
	id = "celerity"
	alert_type = /atom/movable/screen/alert/status_effect/buff/celerity
	effectedstats = list("speed" = 15,"perception" = 10)
	duration = 30 SECONDS

/datum/status_effect/buff/celerity/nextmove_modifier()
	return 0.60

/atom/movable/screen/alert/status_effect/buff/celerity
	name = "Quickening"
	desc = ""
	icon_state = "bleed1"

/mob/living/carbon/human/proc/blood_fortitude()
	set name = "Armor of Darkness"
	set category = "VAMPIRE"

	var/datum/antagonist/vampire/VD = mind.has_antag_datum(/datum/antagonist/vampire)
	if(!VD)
		return
	if(VD.disguised)
		to_chat(src, span_warning("My curse is hidden."))
		return
	if(VD.vitae < 100)
		to_chat(src, span_warning("Not enough vitae blood."))
		return
	if(has_status_effect(/datum/status_effect/buff/blood_fortitude))
		to_chat(src, span_warning("Already active."))
		return
	VD.vitae -= 100
	energy_add(2000)
	apply_status_effect(/datum/status_effect/buff/blood_fortitude)
	to_chat(src, span_greentext("! ARMOR OF DARKNESS !"))
	src.playsound_local(get_turf(src), 'sound/misc/vampirespell.ogg', 100, FALSE, pressure_affected = FALSE)

/datum/status_effect/buff/blood_fortitude
	id = "blood_fortitude"
	alert_type = /atom/movable/screen/alert/status_effect/buff/blood_fortitude
	effectedstats = list("endurance" = 20,"constitution" = 20)
	duration = 30 SECONDS

/atom/movable/screen/alert/status_effect/buff/blood_fortitude
	name = "Armor of Darkness"
	desc = ""
	icon_state = "bleed1"

/datum/status_effect/buff/fortitude/on_apply()
	. = ..()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		QDEL_NULL(H.skin_armor)
		H.skin_armor = new /obj/item/clothing/suit/roguetown/armor/skin_armor/vampire_fortitude(H)
	owner.add_stress(/datum/stressevent/weed)

/datum/status_effect/buff/fortitude/on_remove()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		if(istype(H.skin_armor, /obj/item/clothing/suit/roguetown/armor/skin_armor/vampire_fortitude))
			QDEL_NULL(H.skin_armor)
	. = ..()

/obj/item/clothing/suit/roguetown/armor/skin_armor/vampire_fortitude
	slot_flags = null
	name = "vampire's skin"
	desc = ""
	icon_state = null
	body_parts_covered = FULL_BODY
	armor = ARMOR_VAMP
	prevent_crits = list(BCLASS_CUT, BCLASS_STAB, BCLASS_BLUNT, BCLASS_TWIST)
	blocksound = SOFTHIT
	blade_dulling = DULLING_BASHCHOP
	sewrepair = TRUE
	max_integrity = 0

/mob/living/carbon/human/proc/vamp_regenerate()
	set name = "Regenerate"
	set category = "VAMPIRE"
	var/silver_curse_status = FALSE
	for(var/datum/status_effect/debuff/silver_curse/silver_curse in status_effects)
		silver_curse_status = TRUE
		break
	
	var/datum/antagonist/vampirelord/VDL = mind.has_antag_datum(/datum/antagonist/vampirelord)
	var/datum/antagonist/vampire/Vamp = mind.has_antag_datum(/datum/antagonist/vampire)
	
	if(!VDL && !Vamp)
		return
	
	var/is_wretch = FALSE
	
	if(!VDL && Vamp && Vamp.wretch_antag)
		is_wretch = TRUE
	else if(!VDL)
		return
	
	if(is_wretch)
		if(Vamp.disguised)
			to_chat(src, span_warning("My curse is hidden."))
			return
	else
		if(VDL.disguised)
			to_chat(src, span_warning("My curse is hidden."))
			return
	
	if(silver_curse_status)
		to_chat(src, span_warning("My BANE is not letting me REGEN!."))
		return
	
	var/vitae_cost = 500
	if(is_wretch)
		if(Vamp.vitae < vitae_cost)
			to_chat(src, span_warning("Not enough vitae."))
			return
	else
		if(VDL.vitae < vitae_cost)
			to_chat(src, span_warning("Not enough vitae."))
			return
	
	to_chat(src, span_greentext("! REGENERATE !"))
	src.playsound_local(get_turf(src), 'sound/misc/vampirespell.ogg', 100, FALSE, pressure_affected = FALSE)
	
	if(is_wretch)
		Vamp.vitae -= vitae_cost
		// Wound healing
		var/list/wCount = get_wounds()
		if(wCount.len > 0)
			heal_wounds(30)
			update_damage_overlays()
			if(prob(10))
				to_chat(src, span_nicegreen("I feel my wounds mending."))
		// Stop all bleeding (health potion logic: expire bandages, remove status effects)
		for(var/obj/item/bodypart/BP as anything in bodyparts)
			if(BP.bandage)
				BP.try_bandage_expire()
		// Remove bleeding status effects
		remove_status_effect(/datum/status_effect/debuff/bleeding)
		remove_status_effect(/datum/status_effect/debuff/bleedingworse)
		remove_status_effect(/datum/status_effect/debuff/bleedingworst)
		// Damage healing - FLAT 50 HEALING
		adjustBruteLoss(-50, 0)
		adjustFireLoss(-50, 0)
		adjustOxyLoss(-50, 0)
		adjustCloneLoss(-50, 0)
		for(var/obj/item/organ/organny in internal_organs)
			adjustOrganLoss(organny.slot, -50)
		// Heal bodypart damage (including "battered" limbs) - FLAT 50 HEALING
		var/healed_bodyparts = FALSE
		for(var/obj/item/bodypart/BP as anything in bodyparts)
			if(BP.brute_dam > 0 || BP.burn_dam > 0)
				BP.heal_damage(50, 50, 0)
				healed_bodyparts = TRUE
		if(healed_bodyparts)
			update_damage_overlays()
	else
		VDL.handle_vitae(-vitae_cost)
		fully_heal()
		regenerate_limbs()

/mob/living/carbon/human/proc/vampire_infect()
	if(!mind)
		return
	if(mind.has_antag_datum(/datum/antagonist/vampire))
		return
	if(mind.has_antag_datum(/datum/antagonist/werewolf))
		return
	if(mind.has_antag_datum(/datum/antagonist/zombie))
		return
	if(mob_timers["becoming_vampire"])
		return
	mob_timers["becoming_vampire"] = world.time
	addtimer(CALLBACK(src, TYPE_PROC_REF(/mob/living/carbon/human, vampire_finalize)), 2 MINUTES)
	to_chat(src, span_danger("I feel sick..."))
	src.playsound_local(get_turf(src), 'sound/music/horror.ogg', 80, FALSE, pressure_affected = FALSE)
	flash_fullscreen("redflash3")

/mob/living/carbon/human/proc/vampire_finalize()
	if(!mind)
		mob_timers["becoming_vampire"] = null
		return
	if(mind.has_antag_datum(/datum/antagonist/vampire))
		mob_timers["becoming_vampire"] = null
		return
	if(mind.has_antag_datum(/datum/antagonist/werewolf))
		mob_timers["becoming_vampire"] = null
		return
	if(mind.has_antag_datum(/datum/antagonist/zombie))
		mob_timers["becoming_vampire"] = null
		return
	var/datum/antagonist/vampire/new_antag = new /datum/antagonist/vampire/lesser()
	mind.add_antag_datum(new_antag)
	Sleeping(100)
//	stop_all_loops()
	src.playsound_local(src, 'sound/misc/deth.ogg', 100)
	if(client)
		SSdroning.kill_rain(client)
		SSdroning.kill_loop(client)
		SSdroning.kill_droning(client)
		client.move_delay = initial(client.move_delay)
		var/atom/movable/screen/gameover/hog/H = new()
		H.layer = SPLASHSCREEN_LAYER+0.1
		client.screen += H
		H.Fade()
		addtimer(CALLBACK(H, TYPE_PROC_REF(/atom/movable/screen/gameover, Fade), TRUE), 100)

/datum/antagonist/vampire/proc/wretch_vamp_look()
	var/mob/living/carbon/human/V = owner.current
	// Set vampiric appearance only
	V.skin_tone = "c9d3de"
	V.hair_color = "181a1d"
	V.facial_hair_color = "181a1d"
	V.eye_color = "ff0000"
	V.update_body()
	V.update_hair()
	V.update_body_parts(redraw = TRUE)
	V.mob_biotypes = MOB_UNDEAD

/mob/living/carbon/human/proc/on_hit_by_silver_weapon()
	var/datum/antagonist/vampire/Vamp = mind?.has_antag_datum(/datum/antagonist/vampire)
	if(Vamp && Vamp.wretch_antag && !Vamp.disguised)
		to_chat(src, span_userdanger("The silver weapon burns my flesh! My curse is revealed!"))
		apply_status_effect(/datum/status_effect/debuff/silver_curse)
