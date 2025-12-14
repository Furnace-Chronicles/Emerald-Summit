// T1: (fires a bone splinter at a target for brute and bleeding if you're not holding bones in your other hand, fires a significantly stronger bone lance if you are)

/obj/effect/proc_holder/spell/invoked/projectile/profane
	name = "Profane"
	desc = "Fire forth a splinter of unholy bone, tearing flesh and causing bleeding. If you hold pieces of bone in your other hand, you will coax a much stronger lance of bone into being."
	clothes_req = FALSE
	overlay_state = "profane"
	range = 8
	associated_skill = /datum/skill/magic/arcane
	projectile_type = /obj/projectile/magic/profane
	chargedloop = /datum/looping_sound/invokeholy
	invocation = "Oblino!"
	invocation_type = "whisper"
	releasedrain = 30
	chargedrain = 0
	chargetime = 15
	recharge_time = 10 SECONDS
	hide_charge_effect = TRUE // Left handed magick babe

/obj/effect/proc_holder/spell/invoked/projectile/profane/miracle
	miracle = TRUE
	devotion_cost = 15
	associated_skill = /datum/skill/magic/holy

/obj/effect/proc_holder/spell/invoked/projectile/profane/fire_projectile(mob/living/user, atom/target)
	current_amount--

	var/obj/item/held_item = user.get_active_held_item()
	var/big_cast = FALSE
	if (istype(held_item, /obj/item/natural/bundle/bone))
		var/obj/item/natural/bundle/bone/bonez = held_item
		if (bonez.use(1))
			projectile_type = /obj/projectile/magic/profane/major
			big_cast = TRUE
	else if (istype(held_item, /obj/item/natural/bone))
		qdel(held_item)
		projectile_type = /obj/projectile/magic/profane/major
		big_cast = TRUE
	else if (istype(held_item, /obj/item/natural/bundle/bone))
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
	damage = 20
	damage_type = BRUTE
	nodamage = FALSE
	var/embed_prob = 10

/obj/projectile/magic/profane/major
	name = "profaned bone lance"
	damage = 35
	embed_prob = 30

/obj/projectile/magic/profane/on_hit(atom/target, blocked)
	. = ..()
	if (iscarbon(target) && prob(embed_prob))
		var/mob/living/carbon/carbon_target = target
		var/obj/item/bodypart/victim_limb = pick(carbon_target.bodyparts)
		var/obj/item/bone/splinter/our_splinter = new
		victim_limb.add_embedded_object(our_splinter, FALSE, TRUE)

/obj/item/bone/splinter
	name = "bone splinter"
	embedding = list(
		"embed_chance" = 100,
		"embedded_pain_chance" = 25,
		"embedded_fall_chance" = 5,
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

// T3: Rituos (usable once per sleep cycle, allows you to choose any 1 arcane spell to use for the duration w/ an associated devotion cost. each time you change it, 1 of your limbs is skeletonized, if all of your limbs are skeletonized, you gain access to arcane magic. continuing to use rituos after being fully skeletonized gives you additional spellpoints). Gives you the MOB_UNDEAD flag (needed for skeletonize to work) on first use.

/obj/effect/proc_holder/spell/invoked/rituos
	name = "Rituos"
	desc = "Draw upon the Lesser Work of She Who Is Z to gain arcyne knowledge for a dae..."
	clothes_req = FALSE
	overlay_state = "rituos"
	associated_skill = /datum/skill/magic/arcane
	chargedloop = /datum/looping_sound/invokeholy
	chargedrain = 0
	chargetime = 50
	releasedrain = 90
	no_early_release = TRUE
	movement_interrupt = TRUE
	recharge_time = 1 MINUTES
	hide_charge_effect = TRUE

/obj/effect/proc_holder/spell/invoked/rituos/miracle
	miracle = TRUE
	devotion_cost = 120
	associated_skill = /datum/skill/magic/holy

/obj/effect/proc_holder/spell/invoked/rituos/proc/check_ritual_progress(mob/living/carbon/user)

/obj/effect/proc_holder/spell/invoked/rituos/cast(list/targets, mob/living/carbon/user)
	//check to see if we're all skeletonized first
	var/pre_rituos = check_ritual_progress(user)
	if (pre_rituos)
		to_chat(user, span_notice("I have completed Her Lesser Work..."))
		return FALSE

	if (user.mind?.has_rituos)
		to_chat(user, span_warning("I have not the mental fortitude to enact the Lesser Work again. I must rest first..."))
		return FALSE

	var/list/choices = list()
	var/list/spell_choices = GLOB.learnable_spells
	for(var/i = 1, i <= spell_choices.len, i++)
		var/obj/effect/proc_holder/spell/spell_item = spell_choices[i]
		if(spell_item.spell_tier > 3) // Hardcap Rituos choice to T3 to avoid Court Mage spells access
			continue
		choices["[spell_item.name]"] = spell_item

	choices = sortList(choices)

	var/choice = input("Choose an arcyne expression of the Lesser Work") as null|anything in choices
	var/obj/effect/proc_holder/spell/item = choices[choice]

	if (!choice || !item)
		return FALSE

	user.visible_message(span_notice("I feel arcyne power surge throughout my frail mortal form."))

	if (user.mind?.rituos_spell)
		to_chat(user, span_warning("My knowledge of [user.mind.rituos_spell.name] flees..."))
		user.mind.RemoveSpell(user.mind.rituos_spell)
		user.mind.rituos_spell = null

	user.mind.has_rituos = TRUE

	var/post_rituos = check_ritual_progress(user) // need someone else to rewrite ritous with how it functions now im too inexperienced and drained to do this now (doing this not fun too)
	if (post_rituos)
	else
		to_chat(user, span_notice("The Lesser Work of Rituos floods my mind with stolen arcyne knowledge: I can now cast [item.name] until I next rest..."))
		user.mind.rituos_spell = item
		user.mind.AddSpell(new item)
		return TRUE


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

/obj/effect/proc_holder/spell/invoked/zizo_silence

	name = "Silence of Progress"
	desc = "An unholy hush that stifles prayer and mercy alike. The stillness clicks with Zizo's design."
	overlay_state = "zizosilence"
	clothes_req = FALSE
	releasedrain = 30
	chargedrain = 0
	chargetime = 0
	range = 7
	warnie = "sydwarning"
	movement_interrupt = FALSE
	sound = 'sound/magic/churn.ogg'
	invocation = "This is the sound of progress!"
	invocation_type = "shout"
	associated_skill = /datum/skill/magic/holy
	devotion_cost = 20
	recharge_time = 20 SECONDS
	miracle = TRUE

/obj/effect/proc_holder/spell/invoked/sacred_silence/cast(list/targets, mob/user = usr)
	if(!isliving(targets[1]))
		revert_cast()
		return FALSE

	var/mob/living/target = targets[1]
	if(target.anti_magic_check(TRUE, TRUE))
		return FALSE

	target.visible_message(
		span_warning("[user] sketches a crooked sigil in the air - the sound around [target] stutters and dies!" ),
		span_warning("A cold, clockwork hush clamps my throat - prayers turn to static!")
	)

	var/skill = max(1, user.get_skill_level(associated_skill))
	var/dur_s  = clamp(skill * 4, 4, 20)
	var/dur_ds = dur_s SECONDS

	if(istype(target, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = target
		if(H.devotion && istype(H.devotion.patron, /datum/patron/divine))
			dur_ds *= 2

			var/tier = max(1, H.devotion.level)
			var/drain = 50 * tier
			H.devotion.update_devotion(-drain, 0, silent = TRUE)

			to_chat(H, span_warning("My patron's blessing wanes! (-[drain] devotion)"))

	target.set_silence(dur_ds)

	addtimer(
		CALLBACK(target, TYPE_PROC_REF(/atom/movable, visible_message),
			span_notice("My voice returns… thin, like it has been filed down.")
		),
		dur_ds
	)

	return TRUE

// BAD MEDICINE 

/obj/effect/proc_holder/spell/invoked/bad_medicine
	name = "Bad Medicine"
	desc = "A heretical hush of Zizo: while mercy mends, it also bites back."
	overlay_state = "badmedicine"
	clothes_req = FALSE
	range = 7
	movement_interrupt = FALSE
	sound = 'sound/magic/churn.ogg'
	invocation = "Iterate."
	invocation_type = "shout"
	associated_skill = /datum/skill/magic/holy
	devotion_cost = 30
	recharge_time = 30 SECONDS
	miracle = TRUE

/obj/effect/proc_holder/spell/invoked/zizo_feedback/cast(list/targets, mob/user = usr)
	if(!isliving(targets[1]))
		revert_cast()
		return FALSE

	var/mob/living/target = targets[1]
	if(target.anti_magic_check(TRUE, TRUE))
		return FALSE

	user.visible_message(
		span_warning("[user] sketches a crooked Ascendant sigil toward [target]!"),
		span_warning("I invoke the Lady of Progress - let healing betray you.")
	)

	var/holy_lvl = max(0, user.get_skill_level(/datum/skill/magic/holy))
	var/dur = (5 + (5 * holy_lvl)) SECONDS

	var/stripped = FALSE
	if(istype(target, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = target

		// 1) remove healing status effect =>>> /datum/status_effect/buff/healing
		var/datum/status_effect/healSE = H.has_status_effect(/datum/status_effect/buff/healing)
		if(healSE)
			qdel(healSE)
			stripped = TRUE
		if(H.reagents && H.reagents.reagent_list)
			var/list/to_remove = list() // type -> amount
			for(var/datum/reagent/R in H.reagents.reagent_list)
				if(istype(R, /datum/reagent/medicine))
					to_remove[R.type] = (to_remove[R.type] || 0) + R.volume

			for(var/T in to_remove)
				H.reagents.remove_reagent(T, to_remove[T])
				stripped = TRUE

	if(stripped)
		target.visible_message(
			span_warning("[target]'s mercy stutters—then grinds to a halt!"),
			span_danger("My healing is torn away—then threatens to turn against me!")
		)

	// Накладываем статус-эффект на dur
	target.apply_status_effect(/datum/status_effect/zizo_healing_feedback, dur)

	return TRUE

/datum/status_effect/zizo_healing_feedback
	var/end_time = 0
	var/next_tick = 0
	var/tick_delay = 1 SECONDS

	var/damage_per_tick = 7.5
	var/damage_type = BURN  

	var/knockdown_done = FALSE

/datum/status_effect/zizo_healing_feedback/New(mob/living/new_owner, dur)
	. = ..()
	if(new_owner)
		owner = new_owner

	if(isnum(dur))
		end_time = world.time + dur
	else
		end_time = world.time + 10 SECONDS

	next_tick = world.time
	START_PROCESSING(SSobj, src)

		owner.visible_message(
			span_warning("[owner] jerks as comfort becomes consequence!"),
			span_danger("Healing inside me screams—turning into pain!")
		)

/datum/status_effect/zizo_healing_feedback/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/datum/status_effect/zizo_healing_feedback/process()
	if(!owner || !isliving(owner))
		qdel(src)
		return PROCESS_KILL

	if(world.time >= end_time)
		qdel(src)
		return PROCESS_KILL

	if(world.time < next_tick)
		return

	next_tick = world.time + tick_delay

	if(!src.is_being_healed(owner))
		return

	if(hascall(owner, "apply_damage"))
		call(owner, "apply_damage")(damage_per_tick, damage_type)
	else
		if(damage_type == BURN)
			if(hascall(owner, "adjustFireLoss"))
				call(owner, "adjustFireLoss")(damage_per_tick)
		else
			if(hascall(owner, "adjustBruteLoss"))
				call(owner, "adjustBruteLoss")(damage_per_tick)

/datum/status_effect/zizo_healing_feedback/proc/is_being_healed(mob/living/L)
	if(L.has_status_effect(/datum/status_effect/buff/healing))
		return TRUE

	if(istype(L, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = L
		if(H.reagents && H.reagents.reagent_list)
			for(var/datum/reagent/R in H.reagents.reagent_list)
				if(istype(R, /datum/reagent/medicine))
					return TRUE

	return FALSE
