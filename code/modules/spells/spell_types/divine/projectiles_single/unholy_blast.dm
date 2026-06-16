/obj/effect/proc_holder/spell/invoked/projectile/unholyblast // this CANNOT be a child of divine_blast bc you have to call parent on cast. 
	name = "Unholy Blast"
	desc = "Channel unholy power and sunder the unbelievers. Deals additional damage to wretched conformists and Psydonites! \n\
	Damage is increased by 100% versus simple-minded creechurs.\n\ "
	clothes_req = FALSE
	range = 12
	overlay_state = "divine_blast"
	projectile_type = /obj/projectile/energy/unholyblast
	sound = list('sound/magic/vlightning.ogg')
	active = FALSE
	releasedrain = 20
	chargedrain = 1
	chargetime = 0
	recharge_time = 5 SECONDS
	warnie = "spellwarning"
	no_early_release = TRUE
	movement_interrupt = FALSE
	invocation = "Fortschritt macht!"
	invocation_type = "shout"
	glow_color = GLOW_COLOR_LIGHTNING
	glow_intensity = GLOW_INTENSITY_LOW
	charging_slowdown = 3
	chargedloop = /datum/looping_sound/invokegen
	associated_skill = /datum/skill/magic/holy
	miracle = TRUE
	devotion_cost = 25


/obj/projectile/energy/unholyblast
	name = "Unholy Blast"
	icon_state = "divine_blast"
	damage = 20 // wont do much to a heretical worshipper
	woundclass = BCLASS_CUT // I REALLY wanted to do cut
	nodamage = FALSE
	npc_damage_mult = 2 // The Simple Skele Gibber
	hitsound = 'sound/magic/churn.ogg' 
	speed = 1



/obj/projectile/energy/unholyblast/on_hit(target)
	if(isliving(target))
		var/mob/living/H = target
		if(H.mind && H.mind.has_antag_datum(/datum/antagonist/werewolf))
			damage += 30 //extremely specific so lets hit like a truck.
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(istype(H.patron, /datum/patron/divine))
			damage += 20
		if(istype(H.patron, /datum/patron/old_god))
			damage += 20
		if(H.mind && H.mind.has_antag_datum(/datum/antagonist/werewolf)) //rather then sunder all silver weak. Lets sunder dendors chosen!
			H.visible_message("<font color='white'>Unholy power sunders [H]!</font>")
			to_chat(H, span_userdanger("Unholy force rebukes my presence! My vitae smolders, and my powers wane!"))
			H.adjust_fire_stacks(4, /datum/status_effect/fire_handler/fire_stacks/sunder) //and do so farely hard.
		var/mob/living/carbon/human/caster
		if (ishuman(firer))
			caster = firer
			switch(caster.patron.type)
				if(/datum/patron/inhumen/baotha)
					H.adjustToxLoss(10)
					H.Dizzy(5)
					H.visible_message(span_warning("[H] looks unwell..."), span_warning("I feel dizzy... and I've been poisoned!"))
				if(/datum/patron/inhumen/matthios)
					if(HAS_TRAIT(H, TRAIT_NOBLE))
						damage += 10 
						H.adjust_fire_stacks(4)
						H.visible_message(span_warning("[H]'s blue blood burns bright!"), span_warning("My body burns-- my blood is being transacted into fire!"))
					H.adjust_fire_stacks(2)
					H.ignite_mob()
				if(/datum/patron/inhumen/graggar)
					H.visible_message(span_warning("A splatter of blood covers [H]'s face!"), span_warning("A glob of blood splatters my vision!"))
					H.Dizzy(5)
					H.blur_eyes(5)
				if(/datum/patron/inhumen/zizo)
					if(istype(H.patron, /datum/patron/divine/necra)) //Hilarious
						H.adjust_fire_stacks(6)
						H.ignite_mob()
					H.Slowdown(3) 
					H.visible_message(span_warning("Seething ambition sears within [H]'s mind!"), span_warning("Visions of progress and ambition sear into my mind!"))
	else
		return




