/obj/effect/proc_holder/spell/invoked/bonechill
	name = "Bone Chill"
	overlay_state = "raiseskele"
	releasedrain = 30
	chargetime = 5
	range = 7
	warnie = "sydwarning"
	movement_interrupt = FALSE
	chargedloop = null
	sound = 'sound/magic/whiteflame.ogg'
	associated_skill = /datum/skill/magic/arcane
	gesture_required = TRUE // Potential offensive use, need a target
	antimagic_allowed = TRUE
	recharge_time = 15 SECONDS
	miracle = FALSE

/obj/effect/proc_holder/spell/invoked/bonechill/cast(list/targets, mob/living/user)
	..()
	if(!isliving(targets[1]))
		return FALSE

	var/mob/living/target = targets[1]
	if(target.mob_biotypes & MOB_UNDEAD) //positive energy harms the undead
		var/obj/item/bodypart/affecting = target.get_bodypart(check_zone(user.zone_selected))
		if(affecting && (affecting.heal_damage(50, 50) || affecting.heal_wounds(50)))
			target.update_damage_overlays()
		target.visible_message(span_danger("[target] reforms under the vile energy!"), span_notice("I'm remade by dark magic!"))
		return TRUE

	target.visible_message(span_info("Necrotic energy floods over [target]!"), span_userdanger("I feel colder as the dark energy floods into me!"))
	if(iscarbon(target))
		target.apply_status_effect(/datum/status_effect/debuff/chilled)
	else
		target.adjustBruteLoss(20)

	return TRUE

/obj/effect/proc_holder/spell/invoked/eyebite
	name = "Eyebite"
	overlay_state = "raiseskele"
	releasedrain = 30
	chargetime = 15
	range = 7
	warnie = "sydwarning"
	movement_interrupt = FALSE
	chargedloop = null
	sound = 'sound/items/beartrap.ogg'
	associated_skill = /datum/skill/magic/arcane
	gesture_required = TRUE // Offensive spell
	antimagic_allowed = TRUE
	recharge_time = 15 SECONDS
	miracle = FALSE
	hide_charge_effect = TRUE

/obj/effect/proc_holder/spell/invoked/eyebite/cast(list/targets, mob/living/user)
	..()
	if(!isliving(targets[1]))
		return FALSE
	var/mob/living/carbon/target = targets[1]
	target.visible_message(span_info("A loud crunching sound has come from [target]!"), span_userdanger("I feel arcane teeth biting into my eyes!"))
	target.adjustBruteLoss(30)
	target.blind_eyes(2)
	target.blur_eyes(10)
	return TRUE
	

/obj/effect/proc_holder/spell/invoked/raise_lesser_undead
	name = "Raise Lesser Undead"
	desc = ""
	clothes_req = FALSE
	overlay_state = "animate"
	range = 7
	sound = list('sound/magic/magnet.ogg')
	releasedrain = 40
	chargetime = 60
	warnie = "spellwarning"
	no_early_release = TRUE
	charging_slowdown = 1
	chargedloop = /datum/looping_sound/invokegen
	gesture_required = TRUE // Summon spell
	associated_skill = /datum/skill/magic/arcane
	recharge_time = 30 SECONDS
	var/cabal_affine = FALSE
	var/is_summoned = FALSE
	hide_charge_effect = TRUE

/obj/effect/proc_holder/spell/invoked/raise_lesser_undead/cast(list/targets, mob/living/user)
	. = ..()
	var/turf/T = get_turf(targets[1])
	var/skeleton_roll = rand(1,100)
	if(!isopenturf(T))
		to_chat(user, span_warning("The targeted location is blocked. My summon fails to come forth."))
		return FALSE
	switch(skeleton_roll)
		if(1 to 20)
			new /mob/living/simple_animal/hostile/rogue/skeleton/axe(T, user, cabal_affine)
		if(21 to 40)
			new /mob/living/simple_animal/hostile/rogue/skeleton/spear(T, user, cabal_affine)
		if(41 to 60)
			new /mob/living/simple_animal/hostile/rogue/skeleton/guard(T, user, cabal_affine)
		if(61 to 80)
			new /mob/living/simple_animal/hostile/rogue/skeleton/bow(T, user, cabal_affine)
		if(81 to 100)
			new /mob/living/simple_animal/hostile/rogue/skeleton(T, user, cabal_affine)
	return TRUE

/obj/effect/proc_holder/spell/invoked/raise_lesser_undead/necromancer
	cabal_affine = TRUE
	is_summoned = TRUE
	// Buffed for necromancer cleric: shorter cooldown, faster cast
	recharge_time = 15 SECONDS // Shorter cooldown than miracle
	chargetime = 15 // Faster cast time

/obj/effect/proc_holder/spell/invoked/raise_lesser_undead/necromancer/cast(list/targets, mob/living/user)
	. = ..()
	var/turf/T = get_turf(targets[1])
	if(!isopenturf(T))
		to_chat(user, span_warning("The targeted location is blocked. My summon fails to come forth."))
		return FALSE
	var/skeleton_roll = rand(1,100)
	switch(skeleton_roll)
		if(1 to 25)
			new /mob/living/simple_animal/hostile/rogue/skeleton/axe(T, user, cabal_affine)
		if(26 to 50)
			new /mob/living/simple_animal/hostile/rogue/skeleton/spear(T, user, cabal_affine)
		if(51 to 75)
			new /mob/living/simple_animal/hostile/rogue/skeleton/guard(T, user, cabal_affine)
		if(76 to 100)
			new /mob/living/simple_animal/hostile/rogue/skeleton/bow(T, user, cabal_affine)
	return TRUE

/obj/effect/proc_holder/spell/invoked/projectile/sickness
	name = "Ray of Sickness"
	desc = ""
	clothes_req = FALSE
	range = 15
	projectile_type = /obj/projectile/magic/sickness
	overlay_state = "raiseskele"
	sound = list('sound/misc/portal_enter.ogg')
	active = FALSE
	releasedrain = 30
	chargetime = 10
	warnie = "spellwarning"
	no_early_release = TRUE
	charging_slowdown = 1
	chargedloop = /datum/looping_sound/invokegen
	associated_skill = /datum/skill/magic/arcane
	recharge_time = 15 SECONDS

/obj/effect/proc_holder/spell/invoked/gravemark
	name = "Gravemark"
	desc = "Adds or removes a target from the list of allies exempt from your undead's aggression."
	overlay_state = "raiseskele"
	range = 7
	warnie = "sydwarning"
	movement_interrupt = FALSE
	chargedloop = null
	antimagic_allowed = TRUE
	recharge_time = 15 SECONDS
	hide_charge_effect = TRUE

/obj/effect/proc_holder/spell/invoked/gravemark/cast(list/targets, mob/living/user)
	. = ..()
	if(isliving(targets[1]))
		var/mob/living/target = targets[1]
		var/faction_tag = "[user.mind.current.real_name]_faction"
		if (target == user)
			to_chat(user, span_warning("It would be unwise to make an enemy of your own skeletons."))
			return FALSE
		if(target.mind && target.mind.current)
			if (faction_tag in target.mind.current.faction)
				target.mind.current.faction -= faction_tag
				user.say("Hostis declaratus es.")
			else
				target.mind.current.faction += faction_tag
				user.say("Amicus declaratus es.")
		else if(istype(target, /mob/living/simple_animal))
			if (faction_tag in target.faction)
				target.faction -= faction_tag
				user.say("Hostis declaratus es.")
			else
				target.faction |= faction_tag
				user.say("Amicus declaratus es.")
		return TRUE
	return FALSE

/obj/effect/proc_holder/spell/invoked/greater_undead_revive
	name = "Reanimate"
	desc = "Reanimate a fallen greater undead, or offer undeath to the slain."
	clothes_req = FALSE
	releasedrain = 60
	chargetime = 1
	range = 7
	warnie = "sydwarning"
	movement_interrupt = FALSE
	chargedloop = null
	sound = 'sound/magic/revive.ogg'
	associated_skill = /datum/skill/magic/arcane
	gesture_required = TRUE
	antimagic_allowed = TRUE
	recharge_time = 10 MINUTES
	miracle = FALSE

/obj/effect/proc_holder/spell/invoked/greater_undead_revive/cast(list/targets, mob/living/user)
	..()
	var/target = targets[1]
	var/mob/living/carbon/human/H = istype(target, /mob/living/carbon/human) ? target : null
	if(!H || (H.stat != DEAD))
		to_chat(user, span_warning("That target is not dead."))
		return FALSE
	if(issimple(target) || !istype(target, /mob/living/carbon/human))
		to_chat(user, span_warning("They are unworthy."))
		return FALSE
	// Require head to be attached
	var/obj/item/bodypart/head/head = null
	if(islist(H.bodyparts))
		for(var/obj/item/bodypart/B in H.bodyparts)
			if(istype(B, /obj/item/bodypart/head))
				head = B; break
	if(!head)
		to_chat(user, span_warning("The head must be attached to reanimate this body!"))
		return FALSE
	if(H.mind && H.mind.has_antag_datum(/datum/antagonist/skeleton))
		// Already a greater undead, just revive
		if(H.stat == DEAD)
			if(H.revive(full_heal = TRUE))
				to_chat(user, span_notice("The dark miracle restores [H] to unlife!"))
				H.visible_message(span_notice("[H] is restored as a greater undead!"))
				return TRUE
			else
				to_chat(user, span_warning("The ritual fails to restore [H]."))
				return FALSE
		else
			to_chat(user, span_warning("[H] is already alive."))
			return FALSE
	// Not a greater undead, offer transformation if player
	if(H.client && H.mind && !H.mind.has_antag_datum(/datum/antagonist/skeleton))
		var/choice = alert(H, "The necromancer offers you the chance to return as a Greater Undead. Accept?", "Unlife Beckons", "Yes", "No")
		if(choice == "Yes")
			var/turf/T = get_turf(H)
			var/mob/living/carbon/human/species/skeleton/no_equipment/new_skeleton = new /mob/living/carbon/human/species/skeleton/no_equipment(T)
			new_skeleton.key = H.key
			SSjob.EquipRank(new_skeleton, "Greater Skeleton", TRUE)
			new_skeleton.visible_message(span_warning("[new_skeleton]'s eyes light up with an eerie glow!"))
			new_skeleton.mind.AddSpell(new /obj/effect/proc_holder/spell/self/suicidebomb/lesser)
			addtimer(CALLBACK(new_skeleton, TYPE_PROC_REF(/mob/living/carbon/human, choose_name_popup), "GREATER SKELETON"), 3 SECONDS)
			addtimer(CALLBACK(new_skeleton, TYPE_PROC_REF(/mob/living/carbon/human, choose_pronouns_and_body)), 7 SECONDS)
			// Gib the old body
			H.gib()
			to_chat(user, span_notice("[new_skeleton] rises as a Greater Undead!"))
			qdel(H)
			return TRUE
		else
			to_chat(user, span_warning("[H] refuses the call of undeath."))
			return FALSE
	to_chat(user, span_warning("They are unworthy."))
	return FALSE
