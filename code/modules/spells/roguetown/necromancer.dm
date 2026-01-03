/obj/effect/proc_holder/spell/invoked/bonechill
	name = "Bone Chill"
	desc = "Unleashes a deathly cold that harms the living from within, yet restores undead flesh and bone."
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
		target.visible_message(span_danger("[target]'s [affecting.name] reforms under the vile energy!"), span_notice("My [affecting.name] is remade by dark magic!"))
		var/obj/effect/temp_visual/heal/E = new /obj/effect/temp_visual/heal_rogue(get_turf(target))
		E.color = "#4E6651"
		return TRUE

	target.visible_message(span_info("Necrotic energy floods over [target]!"), span_userdanger("I feel colder as the dark energy floods into me!"))
	if(iscarbon(target))
		target.apply_status_effect(/datum/status_effect/debuff/chilled)
	else
		target.adjustBruteLoss(20)

	return TRUE

/obj/effect/proc_holder/spell/invoked/eyebite
	name = "Eyebite"
	desc = "Conjures arcyne teeth that snap shut upon the target's eyes, inflicting pain and temporarily shattering their vision."
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
	target.visible_message(span_info("A loud crunching sound has come from [target]!"), span_userdanger("I feel arcyne teeth biting into my eyes!"))
	target.adjustBruteLoss(30)
	target.blind_eyes(2)
	target.blur_eyes(10)
	return TRUE


/obj/effect/proc_holder/spell/invoked/raise_lesser_undead
	name = "Summon Lesser Undead"
	desc = "Summons a mindless skeleton at the targeted location."
	clothes_req = FALSE
	overlay_state = "animate"
	range = 7
	sound = list('sound/magic/magnet.ogg')
	releasedrain = 40
	chargetime = 5 SECONDS
	warnie = "spellwarning"
	no_early_release = TRUE
	charging_slowdown = 1
	chargedloop = /datum/looping_sound/invokegen
	gesture_required = TRUE // Summon spell
	associated_skill = /datum/skill/magic/arcane
	recharge_time = 30 SECONDS
	var/cabal_affine = TRUE
	var/is_summoned = TRUE
	hide_charge_effect = TRUE
	var/list/summonlist = list(/mob/living/carbon/human/species/skeleton/npc/ambush)
/obj/effect/proc_holder/spell/invoked/raise_lesser_undead/cast(list/targets, mob/living/user)
	. = ..()
	var/turf/T = get_turf(targets[1])
	if(!isopenturf(T))
		to_chat(user, span_warning("The targeted location is blocked. My summon fails to come forth."))
		revert_cast()
		return FALSE
	var/mob/living/summon = pick(summonlist)
	var/mob/living/carbon/human/skeleton = new summon(T, user, cabal_affine)
	skeleton.faction += "[user.mind.current.real_name]_faction"
	if(cabal_affine)
		skeleton.faction += "cabal"

	return TRUE


/obj/effect/proc_holder/spell/invoked/raise_lesser_undead/minor
	name = "Raise Minor Undead"
	desc = "Summons a weak skeleton at the targeted location."
	clothes_req = FALSE
	overlay_state = "animate"
	range = 7
	sound = list('sound/magic/magnet.ogg')
	releasedrain = 40
	chargetime = 5 SECONDS
	recharge_time = 20 SECONDS
	releasedrain = 10 //MEANINGLESS CHAFF.
	summonlist = list(\
	/mob/living/simple_animal/hostile/rogue/skeleton/axe, \
	/mob/living/simple_animal/hostile/rogue/skeleton/spear, \
	/mob/living/simple_animal/hostile/rogue/skeleton/guard, \
	/mob/living/simple_animal/hostile/rogue/skeleton/bow, \
	/mob/living/simple_animal/hostile/rogue/skeleton)


/obj/effect/proc_holder/spell/invoked/raise_lesser_undead/necromancer
	cabal_affine = TRUE
	is_summoned = TRUE
	recharge_time = 45 SECONDS

/obj/effect/proc_holder/spell/invoked/projectile/sickness
	name = "Ray of Sickening"
	desc = "Fires a ray of negative energy that fools the body to believe it is poisoned. Extended use of this spell can make the victim spill their guts."
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


/obj/effect/proc_holder/spell/invoked/gravemark
	name = "Gravemark"
	desc = "Adds or removes a target from the list of allies exempt from your undead's aggression."
	overlay_state = "raiseskele"
	range = 7
	warnie = "sydwarning"
	movement_interrupt = FALSE
	chargedloop = null
	antimagic_allowed = TRUE
	recharge_time = 1 SECONDS
	hide_charge_effect = TRUE

/obj/effect/proc_holder/spell/invoked/gravemark/cast(list/targets, mob/living/user)
	. = ..()
	if(isliving(targets[1]))
		var/mob/living/target = targets[1]
		var/faction_tag = "[user.mind.current.real_name]_faction"
		if (target == user)
			to_chat(user, span_warning("It would be unwise to make an enemy of your own skeletons."))
			return FALSE
		if(target.mind && target.mind.current) // No using gravemark to pacify highwaymen npcs lmfao
			if (faction_tag in target.mind.current.faction)
				target.mind.current.faction -= faction_tag
				user.say("Hostis declaratus es.")
			else
				target.mind.current.faction += faction_tag
				user.say("Amicus declaratus es.")
			target.notify_faction_change()

		if(target.mob_biotypes & MOB_UNDEAD)
			if (faction_tag in target.faction)
				target.faction -= faction_tag
				user.say("Hostis declaratus es.")			
			else
				target.faction += faction_tag
				user.say("Amicus declaratus es.")
				var/mob/living/simple_animal/hostile/hostile_target = target
				hostile_target.revalidate_target_on_faction_change()
/*
		else if(istype(target, /mob/living/simple_animal))
			if (faction_tag in target.faction)
				target.faction -= faction_tag
				user.say("Hostis declaratus es.")
			else
				if(target.mob_biotypes & MOB_UNDEAD) //If there was a better undead check, I'd use that. But I don't.
					target.faction += faction_tag
					user.say("Amicus declaratus es.")
					var/mob/living/simple_animal/hostile/hostile_target = target
					hostile_target.revalidate_target_on_faction_change()
		else if(istype(target, /mob/living/carbon/human/species/skeleton/npc))//I wish I had a better way to do this....
			if (faction_tag in target.faction)
				target.faction -= faction_tag
				user.say("Hostis declaratus es.")
			else
				target.faction += faction_tag
				user.say("Amicus declaratus es.")
*/
		return TRUE
	return FALSE

/obj/effect/proc_holder/spell/invoked/animate_dead
	name = "Animate Dead and Dying"
	desc = "Allows you to forcefully raise a corpse in critical condition or animals that Zizo may infest naturally."
	overlay_state = "raiseskele"
	range = 7
	warnie = "sydwarning"
	movement_interrupt = FALSE
	chargedloop = null
	antimagic_allowed = TRUE
	recharge_time = 1 SECONDS
	hide_charge_effect = TRUE
	releasedrain = 30
	chargetime = 5 SECONDS
	recharge_time = 30 SECONDS

//raise crit targets and animals that can raise naturally.
/obj/effect/proc_holder/spell/invoked/animate_dead/cast(list/targets, mob/living/user)
	. = ..()
	var/success
	var/faction_tag = "[user.mind.current.real_name]_faction"
	if(ishuman(targets[1]))
		var/mob/living/carbon/human/target = targets[1]
		if(target.InCritical())
			if(!target.mind)
				target.mind_initialize()
			if(target.zombie_check_can_convert(target) || target.mind.has_antag_datum(/datum/antagonist/zombie))
				if(target.client)
					to_chat(user, span_warning("ZIZO's rot sinks into [target]'s mind..."))
					INVOKE_ASYNC(src, PROC_REF(giveup), target)
			else
				revert_cast()
				to_chat(user, span_warning("ZIZO denies this corpse her gift!"))
				return
			sleep(10 SECONDS)
			wake_zombie(target, infected_wake = TRUE, converted = FALSE)
			target.faction += faction_tag
			target.notify_faction_change() //Stop hitting me!!!!
			success++
		else
			to_chat(user, span_warning("This one hasn't slipped out quite yet..."))
	if(isanimal(targets[1]))
		var/mob/living/simple_animal/animal = targets[1]
		var/datum/component/deadite_animal_reanimation/deadite = animal.GetComponent(/datum/component/deadite_animal_reanimation)
		if(deadite)
			to_chat(user, span_warning("ZIZO's gift takes root."))
			animal = deadite.reanimate(forced=TRUE)
			animal.faction += faction_tag
			success++
	if(!success)
		revert_cast(user)

/obj/effect/proc_holder/spell/invoked/animate_dead/proc/giveup(mob/living/carbon/human/M) //Need to remove the faction datum during zombie cures.
	if(alert(M, "Do you accept ZIZO and soar, or will you wriggle like the filth you are?", "CHOICE OF SUBMISSION", "BIRD", "WORM") == "WORM")
		message_admins("[M.real_name] chose to respawn instead of becoming a zombie.")
		log_admin("[M.real_name] chose to respawn instead of becoming a zombie.")
		M.ghostize(can_reenter_corpse = TRUE, pissbaby_override = TRUE)
