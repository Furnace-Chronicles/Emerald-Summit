// T1: (fires a bone splinter at a target for brute and bleeding if you're not holding bones in your other hand, fires a significantly stronger bone lance if you are)

/obj/effect/proc_holder/spell/invoked/projectile/profane
	name = "Profane"
	desc = "Fire forth a splinter of unholy bone, tearing flesh and causing bleeding. If you hold pieces of bone in your other hand (or are wearing a zcross around your neck), you will coax a much stronger lance of bone into being, which is capable of severing limbs. 50% stronger versus simple-minded creechers."
	clothes_req = FALSE
	overlay_state = "profane"
	range = 8
	associated_skill = /datum/skill/magic/arcane
	projectile_type = /obj/projectile/magic/profane
	chargedloop = /datum/looping_sound/invokegen
	sound = list('sound/magic/profane-cast.ogg')
	invocation = ""
	invocation_type = "whisper"
	releasedrain = 30
	chargedrain = 0
	chargetime = 1
	no_early_release = TRUE
	movement_interrupt = FALSE
	recharge_time = 4 SECONDS
	hide_charge_effect = TRUE // Left handed magick babe

/obj/effect/proc_holder/spell/invoked/projectile/profane/miracle
	miracle = TRUE
	devotion_cost = 5
	associated_skill = /datum/skill/magic/holy

/obj/effect/proc_holder/spell/invoked/projectile/profane/fire_projectile(mob/living/user, atom/target)
	current_amount--

	var/obj/item/held_item = user.get_active_held_item()
	var/big_cast = FALSE

	if (ishuman(user)) // if we're wearing a zcross, always big-cast
		var/mob/living/carbon/human/human_user = user
		if (istype(human_user.wear_neck, /obj/item/clothing/neck/roguetown/zcross)) 
			projectile_type = /obj/projectile/magic/profane/major
			big_cast = TRUE
	
	if (!big_cast && istype(held_item, /obj/item/natural/bundle/bone))
		var/obj/item/natural/bundle/bone/bonez = held_item
		if (bonez.use(1))
			projectile_type = /obj/projectile/magic/profane/major
			big_cast = TRUE
	else if (!big_cast && istype(held_item, /obj/item/natural/bone))
		qdel(held_item)
		projectile_type = /obj/projectile/magic/profane/major
		big_cast = TRUE
	else if (!big_cast && istype(held_item, /obj/item/natural/bundle/bone))
		var/obj/item/natural/bundle/bone/boney_bundle = held_item
		if (boney_bundle.use(1))
			projectile_type = /obj/projectile/magic/profane/major
			big_cast = TRUE

	var/obj/projectile/P = new projectile_type(user.loc)
	P.firer = user
	P.preparePixelProjectile(target, user)
	P.fire()

	if (big_cast)
		user.visible_message(span_danger("[user] conjures and hurls a vicious lance of bone towards [target]!"), span_notice("I hurl forth a vicious lance of profaned bone at [target]!"))
	else
		user.visible_message(span_danger("[user] directs forth a splinter of bone towards [target]!"), span_notice("I fling forth a shard of profaned bone at [target]!"))

	projectile_type = initial(projectile_type)

/obj/projectile/magic/profane
	name = "profaned bone splinter"
	icon_state = "chronobolt"
	damage = 40
	damage_type = BRUTE
	woundclass = BCLASS_PIERCE
	nodamage = FALSE
	var/embed_prob = 10
	npc_damage_mult = 1.5
	hitsound = 'sound/magic/profane-impact.ogg'

/obj/projectile/magic/profane/major
	name = "profaned bone lance"
	damage = 55
	woundclass = BCLASS_CUT
	embed_prob = 30
	npc_damage_mult = 2

/obj/projectile/magic/profane/on_hit(atom/target, blocked)
	. = ..()
	if (iscarbon(target) && prob(embed_prob))
		if (HAS_TRAIT(target, TRAIT_SIMPLE_WOUNDS))
			var/mob/living/simple_animal/simple_target = target
			simple_target.simple_bleeding += 10
			simple_target.visible_message(span_danger("[src] tears into [target]!"), span_userdanger("[src] tears into you, causing violent bleeding!"))
			return
		var/mob/living/carbon/carbon_target = target
		var/obj/item/bodypart/victim_limb = pick(carbon_target.bodyparts)
		var/obj/item/bone/splinter/our_splinter = new
		victim_limb.add_embedded_object(our_splinter, FALSE, TRUE)
		return
	
	

/obj/item/bone/splinter
	name = "bone splinter"
	embedding = list(
		"embed_chance" = 100,
		"embedded_pain_chance" = 25,
		"embedded_fall_chance" = 5,
		"embedded_bloodloss" = 5,
	)

/obj/item/bone/splinter/dropped(mob/user, silent)
	. = ..()
	to_chat(user, span_danger("[src] crumbles into dust..."))
	qdel(src)

// T2: just use lesser animate undead for now

/obj/effect/proc_holder/spell/invoked/raise_lesser_undead/miracle
	miracle = TRUE
	devotion_cost = 75
	cabal_affine = TRUE

// T3: Rituos - Zizo's Lesser Work. A one-time, agonizing ritual offering a choice of path:
//   Progress: arcyne knowledge (2 minor + 6 utility aspects, no skeletonization, some "progress" traits).
//   Unlife:   full skeletonization + MOB_UNDEAD, 2 minor + 4 utility aspects, undead traits.
// Both grant TRAIT_ARCYNE_T3 and a chosen offensive cantrip; the spell self-deletes after use.
// Adapted from Azure-Peak PR #6406's /datum/action/cooldown/spell/zizo/rituos onto ES's legacy
// spell framework. Substitutions for symbols absent on this branch: aspects via _magi2_setup_caster
// (grants the Grimoire to actually use them), TRAIT_ARCYNE -> TRAIT_ARCYNE_T3, _magi2 poke spells.
// Dropped (not present here): undead language, bonechill/bonemend, JACKOFALLTRADES/SELF_SUSTENANCE.

/obj/effect/proc_holder/spell/invoked/rituos
	name = "Rituos"
	desc = "Enact one of the Lesser Works of Zizo - a single, agonizing ritual that tears open a path to power. Choose Progress to gain arcyne knowledge, or Unlife to embrace undeath."
	clothes_req = FALSE
	overlay_state = "rituos"
	associated_skill = /datum/skill/magic/arcane
	chargedloop = /datum/looping_sound/invokeholy
	chargedrain = 0
	chargetime = 50
	releasedrain = 90
	no_early_release = TRUE
	movement_interrupt = TRUE
	recharge_time = 3 MINUTES
	hide_charge_effect = TRUE

/obj/effect/proc_holder/spell/invoked/rituos/miracle
	miracle = TRUE
	devotion_cost = 120
	associated_skill = /datum/skill/magic/holy

/obj/effect/proc_holder/spell/invoked/rituos/cast(list/targets, mob/living/carbon/user)
	if(!ishuman(user))
		return FALSE
	var/mob/living/carbon/human/H = user

	if(H.mind?.rituos_completed)
		to_chat(H, span_warning("I have already completed the Lesser Work. There is nothing more of me to give."))
		return FALSE

	var/path_choice = tgui_alert(H, "What path of the Lesser Work do you seek?", "THE LESSER WORK", list("Progress", "Unlife", "Cancel"))
	if(!path_choice || path_choice == "Cancel")
		return FALSE

	H.visible_message(span_boldwarning("[H] throws back [H.p_their()] head, arcyne energy crackling across [H.p_their()] body!"))

	var/list/chant_lines
	switch(path_choice)
		if("Progress")
			chant_lines = list(
				"ZIZO! ZIZO! ZIZO! GRANT ME INSIGHT UNSHACKLED!",
				"STRIP ME OF STAGNATION AND IGNORANCE!",
				"BREAK THE CHAINS OF FALSE UNDERSTANDING!",
				"LET REVELATION FLOOD THIS FRAIL MIND!",
				"I OFFER THIS MIND TO COMPLETE THY WORK!",
			)
		if("Unlife")
			chant_lines = list(
				"ZIZO! ZIZO! ZIZO! FLENSE FLESH FROM MY BONE!",
				"STRIP ME OF MORTALITY'S SHACKLE!",
				"LET THIS FRAIL MORTALITY FALL AWAY FROM PURPOSE!",
				"REMAKE ME IN DEATH'S ENDURING IMAGE!",
				"I OFFER THIS VESSEL TO COMPLETE THY WORK!",
			)

	for(var/i in 1 to length(chant_lines))
		H.say(chant_lines[i])
		H.adjustBruteLoss(15)
		if(path_choice == "Progress")
			H.emote(pick("whimper", "painmoan", "gag", "choke"))
		else
			H.emote(pick("painscream", "agony", "paincrit", "choke"))
		if(i > 1)
			shake_camera(H, min(i * 2, 3), i)
		if(!do_after(H, 3 SECONDS, target = H))
			to_chat(H, span_warning("The ritual collapses. Zizo's gaze turns away."))
			return FALSE

	ADD_TRAIT(H, TRAIT_ARCYNE_T3, "[type]")

	if(H.mind?.has_antag_datum(/datum/antagonist/vampire))
		H.zizo_vampire_rejection()
		return FALSE

	switch(path_choice)
		if("Progress") // support path - your mind is twisted in Her design
			H.adjust_skillrank(/datum/skill/magic/arcane, 3, TRUE)
			ADD_TRAIT(H, TRAIT_STEELHEARTED, "[type]") // so you can commit atrocities with a smile
			ADD_TRAIT(H, TRAIT_UNLYCKERABLE, "[type]") // zizo is watching you now :)
			if(H.mind)
				_magi2_setup_caster(H, list("mastery" = FALSE, "major" = 0, "minor" = 2, "utilities" = 6, "ward" = TRUE), grant_staff = FALSE)
				grant_poke_spell(H)
			H.visible_message(span_boldwarning("Arcyne runes sear themselves across [H]'s skin, glowing with a sickly light before fading beneath the flesh!"), span_notice("THE LESSER WORK IS DONE! Arcyne knowledge floods my mind - I can see the threads of magic itself!"))

		if("Unlife") // combat path - your body now carries undeath's resilience
			H.mob_biotypes |= MOB_UNDEAD
			ADD_TRAIT(H, TRAIT_NOMOOD, "[type]") // undead apathy
			ADD_TRAIT(H, TRAIT_NOPAIN, "[type]") // you have no flesh
			ADD_TRAIT(H, TRAIT_NOHUNGER, "[type]") // you have no stomach
			ADD_TRAIT(H, TRAIT_NOBREATH, "[type]") // you have no lungs
			ADD_TRAIT(H, TRAIT_TOXIMMUNE, "[type]")
			ADD_TRAIT(H, TRAIT_BLOODLOSS_IMMUNE, "[type]")
			ADD_TRAIT(H, TRAIT_LIMBATTACHMENT, "[type]")
			ADD_TRAIT(H, TRAIT_ZOMBIE_IMMUNE, "[type]")
			ADD_TRAIT(H, TRAIT_SILVER_WEAK, "[type]")
			ADD_TRAIT(H, TRAIT_UNLYCKERABLE, "[type]")
			for(var/obj/item/bodypart/part as anything in H.bodyparts)
				if(istype(part, /obj/item/bodypart/head))
					continue
				if(istype(part, /obj/item/bodypart/chest))
					continue
				part.skeletonize(FALSE)
				H.update_body_parts()
				playsound(H.loc, 'sound/misc/smelter_sound.ogg', 50, FALSE)
				sleep(15)
			var/obj/item/bodypart/torso = H.get_bodypart(BODY_ZONE_CHEST)
			playsound(H.loc, 'sound/misc/lava_death.ogg', 100, FALSE)
			torso?.skeletonize(FALSE)
			H.update_body_parts()
			H.adjust_skillrank(/datum/skill/magic/arcane, 3, TRUE)
			if(H.mind)
				_magi2_setup_caster(H, list("mastery" = FALSE, "major" = 0, "minor" = 2, "utilities" = 4, "ward" = TRUE), grant_staff = FALSE)
				grant_poke_spell(H)
			H.visible_message(span_boldwarning("[H]'s skin and flesh burns away in necrotic flames, revealing bare bone beneath as [H.p_they()] [H.p_are()] consumed by the Lesser Work!"), span_notice("THE LESSER WORK IS DONE! My flesh is forfeit - and death itself answers my call!"))
			to_chat(H, span_purple("You finished Rituos to perfection, you should be a full-fledged Lich now, but..."))
			sleep(30)
			to_chat(H, "<i>...Vestiges of mortality still cling to me...? Why?</i>")

	if(H.mind)
		H.mind.rituos_completed = TRUE
		H.mind.RemoveSpell(src)
	return TRUE

/mob/living/carbon/human/proc/zizo_vampire_rejection()
	visible_message(span_userdanger("[src]'s body suddenly convulses as the Lesser Work reaches completion!"), span_userdanger("The Work rejects my cursed blood!"))
	to_chat(src, span_artery("<br><br>OH. WONDERFUL. I KNOW WHAT YOU ARE ATTEMPTING.<br><br>"))
	sleep(40)
	to_chat(src, span_artery("YOU THINK SO LITTLE OF MY WORK? INSOLENT FOOL.<br><br>"))
	sleep(20)
	to_chat(src, span_artery("YOU HAVE MERELY WASTED MY TIME.<br><br>"))
	sleep(20)
	to_chat(src, span_artery("MY PRECIOUS TIME.<br><br>"))
	sleep(20)
	to_chat(src, span_artery("SO. ALLOW ME TO REPAY THE FAVOR."))
	Stun(40)
	Knockdown(40)
	emote("agony")
	playsound(get_turf(src), 'sound/misc/zizo.ogg', 200)
	to_chat(src, span_userdanger("--MY LUX IS BEING TORN OFF THROUGH MY HEAD!! MY HEAD!! MYHEADMYHEADMYHEADMYHEAD!!"))
	ADD_TRAIT(src, TRAIT_DNR, "zizo_rejection")
	sleep(50)
	playsound(get_turf(src), 'sound/magic/churn.ogg', 200)
	playsound(get_turf(src), 'sound/combat/dismemberment/dismem (2).ogg', 100)
	var/obj/item/bodypart/head = get_bodypart(BODY_ZONE_HEAD)
	head?.skeletonize(TRUE)
	update_body_parts(TRUE)
	visible_message(span_userdanger("[src] SCREAMS in UNBELIEVABLE AGONY as the flesh of [src.p_their()] face is TORN AWAY in a single horrific instant, leaving only an empty, grinning skull..."))
	sleep(20)
	visible_message(span_artery("Their Lux has been completely and utterly annihilated..."))

/obj/effect/proc_holder/spell/invoked/rituos/proc/grant_poke_spell(mob/living/carbon/human/user)
	var/list/poke_options = list("Spitfire", "Frost Bolt", "Arc Bolt", "Greater Arcyne Bolt", "Stygian Efflorescence", "Arcyne Lance", "Gravel Blast", "Soulshot")
	var/poke_choice = tgui_input_list(user, "Choose your offensive cantrip.", "Arcyne Awakening", poke_options)
	if(!poke_choice || !user.mind)
		return
	switch(poke_choice)
		if("Spitfire")
			user.mind.AddSpell(new /datum/action/cooldown/spell/projectile/spitfire_magi2)
		if("Frost Bolt")
			user.mind.AddSpell(new /datum/action/cooldown/spell/projectile/frost_bolt_magi2)
		if("Arc Bolt")
			user.mind.AddSpell(new /datum/action/cooldown/spell/projectile/arc_bolt_magi2)
		if("Greater Arcyne Bolt")
			user.mind.AddSpell(new /datum/action/cooldown/spell/projectile/greater_arcyne_bolt_magi2)
		if("Stygian Efflorescence")
			user.mind.AddSpell(new /datum/action/cooldown/spell/projectile/stygian_efflorescence_magi2)
		if("Arcyne Lance")
			user.mind.AddSpell(new /datum/action/cooldown/spell/projectile/arcyne_lance_magi2)
		if("Gravel Blast")
			user.mind.AddSpell(new /datum/action/cooldown/spell/projectile/gravel_blast_magi2)
		if("Soulshot")
			user.mind.AddSpell(new /datum/action/cooldown/spell/projectile/soulshot_magi2)


/obj/effect/proc_holder/spell/self/zizo_snuff
	name = "Snuff Lights"
	releasedrain = 10
	chargedrain = 0
	chargetime = 0
	chargedloop = /datum/looping_sound/invokeholy
	sound = 'sound/magic/zizo_snuff.ogg'
	overlay_state = "rune2"
	associated_skill = /datum/skill/magic/holy
	antimagic_allowed = FALSE
	recharge_time = 12 SECONDS
	miracle = TRUE
	devotion_cost = 30
	range = 2
	
/obj/effect/proc_holder/spell/self/zizo_snuff/cast(list/targets, mob/user = usr)
	. = ..()
	if(!ishuman(user))
		revert_cast()
		return FALSE
	var/checkrange = (range + user.get_skill_level(/datum/skill/magic/holy)) //+1 range per holy skill up to a potential of 8.
	for(var/obj/O in range(checkrange, user))	
		O.extinguish()
	for(var/mob/M in range(checkrange, user))
		for(var/obj/O in M.contents)
			O.extinguish()
	return TRUE
