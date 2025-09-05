/obj/effect/proc_holder/spell/invoked/mending
	name = "Mending"
	desc = "Uses arcyne energy to mend an item, or inorganic beings such as Golems."
	overlay_state = "mending"
	releasedrain = 50
	chargetime = 5
	recharge_time = 20 SECONDS
	warnie = "spellwarning"
	movement_interrupt = FALSE
	no_early_release = FALSE
	chargedloop = null
	sound = 'sound/magic/whiteflame.ogg'
	cost = 2
	spell_tier = 1 // Utility. For repair
	glow_color = GLOW_COLOR_ARCANE
	glow_intensity = GLOW_INTENSITY_LOW

	miracle = FALSE

	invocation = "Reficio"
	invocation_type = "shout" //can be none, whisper, emote and shout

/obj/effect/proc_holder/spell/invoked/mending/cast(list/targets, mob/living/user)
	if(istype(targets[1], /obj/item))
		var/obj/item/I = targets[1]
		if(I.obj_integrity < I.max_integrity)
			var/repair_percent = 0.25
			repair_percent *= I.max_integrity
			I.obj_integrity = min(I.obj_integrity + repair_percent, I.max_integrity)
			user.visible_message(span_info("[I] glows in a faint mending light."))
			playsound(I, 'sound/foley/sewflesh.ogg', 50, TRUE, -2)
			if(I.obj_broken && I.obj_integrity >= I.max_integrity)
				I.obj_integrity = I.max_integrity
				I.obj_fix()
		else
			to_chat(user, span_info("[I] appears to be in perfect condition."))
			revert_cast()
	else if(ishuman(targets[1]))
		var/mob/living/carbon/human/H = targets[1]
		if(H.construct)
			if(H.getBruteLoss() || H.getFireLoss() || H.getToxLoss() || H.getCloneLoss() || H.getOrganLoss(ORGAN_SLOT_BRAIN) || H.getOxyLoss())
				var/heal_amount = 10
				if(user.mind)
					heal_amount += (user.get_skill_level(/datum/skill/magic/arcane) * 5)//heal becomes significantly more potent the higher level your casting skill is
				var/list/wCount = H.get_wounds()
				if(wCount.len > 0)
					H.heal_wounds(-heal_amount)
				H.adjustBruteLoss(-heal_amount, 0)
				H.adjustFireLoss(-heal_amount, 0)
				H.adjustOxyLoss(-heal_amount, 0)
				H.adjustToxLoss(-heal_amount, 0)
				H.adjustOrganLoss(-ORGAN_SLOT_BRAIN, heal_amount)
				H.adjustCloneLoss(-heal_amount, 0)
				H.visible_message(span_info("[H] glows in a faint mending light."), span_notice("I feel my body being repaired by arcyne energy."))
				playsound(H, 'sound/foley/sewflesh.ogg', 50, TRUE, -2)
				H.update_damage_overlays()
				var/obj/effect/temp_visual/heal/E = new /obj/effect/temp_visual/heal_rogue(get_turf(H))
				E.color = "#C527F5"
			else
				to_chat(user, span_info("[H] appears to be in perfect condition."))
				revert_cast()
		else
			to_chat(user, span_warning("[H] cannot be repaired."))
			revert_cast()
	else if(istype(targets[1], /mob/living/simple_animal/hostile/retaliate/rogue/elemental))
		var/mob/living/simple_animal/hostile/retaliate/rogue/elemental/T = targets[1]
		if(T.health < T.maxHealth)
			var/heal_amount = 20
			if(user.mind)
				heal_amount += (user.get_skill_level(/datum/skill/magic/arcane) * 20)//base 40 (assuming you have novice arcyne) plus 20 per rank after that, meaning you heal 140 at legendary skill
			T.adjustBruteLoss(-heal_amount)
			T.visible_message(span_info("[T] glows in a faint mending light."), span_notice("I feel my body being repaired by arcyne energy."))
		else
			to_chat(user, span_info("[T] appears to be in perfect condition."))
			revert_cast()
	else
		to_chat(user, span_warning("There is no item here!"))
		revert_cast()
