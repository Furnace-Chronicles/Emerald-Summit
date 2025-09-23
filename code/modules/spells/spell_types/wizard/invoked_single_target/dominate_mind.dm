/obj/effect/proc_holder/spell/invoked/dominate_mind
	name = "Dominate Mind"
	desc = "Make a risky attempt to subvert another's will, forcing them to obey your commands."
	cost = 5
	recharge_time = 30 SECONDS
	chargetime = 0.8 SECONDS
	invocation = ""
	invocation_type = "none"
	overlay_state = "null"
	releasedrain = 50
	warnie = "spellwarning"
	movement_interrupt = FALSE
	no_early_release = FALSE
	chargedloop = null
	sound = 'sound/magic/whiteflame.ogg'
	chargedloop = /datum/looping_sound/invokegen
	gesture_required = FALSE
	associated_skill = /datum/skill/magic/arcane
	spell_tier = 2
	glow_color = GLOW_COLOR_VAMPIRIC
	glow_intensity = GLOW_INTENSITY_LOW

/obj/effect/proc_holder/spell/invoked/dominate_mind/cast(list/targets, mob/living/user)
	. = ..()

	var/mob/living/target = targets[1]

	var/caster_skill = user.get_skill_level(/datum/skill/magic/arcane)
	var/target_willpower = round(target.STAINT / 2)

	var/diceroll = roll(1, 20)
	var/caster_roll = diceroll + (caster_skill)
	var/target_dc = target_willpower

	var/success_margin = caster_roll - target_dc

	// Determine Outcome
	if(success_margin >= 10 || diceroll == 20) // Critical Success
		handle_critical_success(target, user)
	else if(success_margin >= 0) // Standard Success
		handle_success(target, user)
	else if(success_margin > -10 && diceroll > 1) // Failure
		handle_failure(target, user)
	else // Critical Failure
		handle_critical_failure(target, user)

/obj/effect/proc_holder/spell/invoked/dominate_mind/proc/handle_critical_success(mob/living/target, mob/living/caster)
	var/datum/component/dominated_mind/existing_bond = target.GetComponent(/datum/component/dominated_mind)
	if(existing_bond && existing_bond.master == caster)
		to_chat(caster, span_userdanger("You firmly reinforce your hold over [target.real_name] for a while!"))
		existing_bond.reinforce_domination(60 SECONDS)
	else
		to_chat(caster, span_userdanger("You smash through the mental defenses of [target.real_name]. [target.p_their(TRUE)] mind is yours to command for a while."))
		target.AddComponent(/datum/component/dominated_mind, caster, 60 SECONDS)

/obj/effect/proc_holder/spell/invoked/dominate_mind/proc/handle_success(mob/living/target, mob/living/caster)
	var/datum/component/dominated_mind/existing_bond = target.GetComponent(/datum/component/dominated_mind)
	if(existing_bond && existing_bond.master == caster)
		to_chat(caster, span_notice("You extend your hold over [target.real_name] for a short time."))
		existing_bond.reinforce_domination(20 SECONDS)
	else
		to_chat(caster, span_warning("You create a hole in [target.real_name]'s mind. You can issue commands for a short time."))
		target.AddComponent(/datum/component/dominated_mind, caster, 20 SECONDS)

/obj/effect/proc_holder/spell/invoked/dominate_mind/proc/handle_failure(mob/living/target, mob/living/caster)
	to_chat(caster, span_warning("You are deflected and your presence has been detected."))
	to_chat(target, span_warning("You feel a mental intrusion, but are able to fight it off."))

/obj/effect/proc_holder/spell/invoked/dominate_mind/proc/handle_critical_failure(mob/living/target, mob/living/caster)
	var/datum/component/dominated_mind/existing_bond = target.GetComponent(/datum/component/dominated_mind)
	if(existing_bond && existing_bond.master == caster)
		to_chat(caster, span_userdanger("Your clumsy attempt shatters the bond completely! Your own mind is exposed!"))
		existing_bond.end_domination()
	to_chat(caster, span_userdanger("Your attack collapses! Your own mind is exposed!"))
	to_chat(target, span_danger("You repel a mental intrusion! You get a crystal-clear image of your assailant: [caster.real_name]!"))
	caster.Stun(5 SECONDS)
	caster.blur_eyes(5 SECONDS)

/datum/component/dominated_mind
	dupe_mode = COMPONENT_DUPE_HIGHLANDER
	/// The mob in control
	var/mob/living/master
	/// If TRUE, the effect is permanent until the master or puppet dies.
	var/permanent_submission = FALSE
	/// The ID of the timer that will end the effect.
	var/timer_id
	/// If the target knows they are being dominated.
	var/is_overt = FALSE
	/// The current cooldown until a new command can be said.
	var/command_cooldown
	/// The current power of this enthrallment which detemines the available commands.
	var/enthrallment_level = 1
	/// Time this entrhallment will end.
	var/domination_end_time

/datum/component/dominated_mind/Initialize(mob/living/new_master, duration)
	if(!istype(new_master))
		return COMPONENT_INCOMPATIBLE
	master = new_master
	// Listens for commands from the master.
	RegisterSignal(master, COMSIG_MOB_SAY, PROC_REF(on_master_speak))
	// Listens to everything the puppet hears to format the master's voice.
	RegisterSignal(parent, COMSIG_MOVABLE_HEAR, PROC_REF(handle_hearing))
	// Store the timer ID so it can be cancelled if the puppet submits.
	domination_end_time = world.time + duration
	timer_id = addtimer(CALLBACK(src, PROC_REF(end_domination)), duration, TIMER_STOPPABLE)

/datum/component/dominated_mind/proc/end_domination()
	qdel(src)

/datum/component/dominated_mind/Destroy()
	if(master)
		UnregisterSignal(master, COMSIG_MOB_SAY)
		if(!permanent_submission)
			var/mob/living/slave = parent
			to_chat(master, span_warning("Your psychic link with [slave.real_name] has faded."))
	if(parent)
		UnregisterSignal(parent, COMSIG_MOVABLE_HEAR)
		if(!permanent_submission && is_overt)
			to_chat(parent, span_notice("The controlling presence in your mind recedes."))
		var/mob/living/carbon/human/slave = parent
		if(slave)
			slave.verbs -= /mob/living/proc/submit_to_master
	master = null
	return ..()

/datum/component/dominated_mind/proc/reinforce_domination(duration_bonus)
	// Increase the entrrallment level by 1
	enthrallment_level += 1
	// If the bond isn't permanent yet, refresh its duration
	if(!permanent_submission && timer_id)
		var/time_remaining = max(0, domination_end_time - world.time)
		var/new_duration = time_remaining + duration_bonus

		deltimer(timer_id)

		timer_id = addtimer(CALLBACK(src, PROC_REF(end_domination)), new_duration, TIMER_STOPPABLE)

/datum/component/dominated_mind/proc/make_permanent()
	if(permanent_submission)
		return

	var/mob/living/puppet = parent
	if(!puppet || !master)
		return

	permanent_submission = TRUE
	if(timer_id)
		deltimer(timer_id)
		timer_id = null
	to_chat(master, span_userdanger("[puppet.real_name] has fully submitted to your will. The psychic link is now unbreakable."))
	to_chat(puppet, span_mind_control("I must obey [master.real_name]. It is my compulsion; to follow their every command. I am bound to their will utterly and totally..."))

/datum/component/dominated_mind/proc/confirm_submission()
	var/mob/living/puppet = parent
	if(!puppet || !master)
		return

	var/confirmation = alert(puppet, "Are you sure you want to permanently submit your will to [master.real_name]? This is irreversible and will last until death.", "Confirm Submission", "Yes", "No")

	if(QDELETED(src) || QDELETED(puppet) || QDELETED(master))
		return

	if(confirmation == "Yes")
		make_permanent()

/datum/component/dominated_mind/proc/on_master_speak(mob/living/speaker, list/speech_args)
	SIGNAL_HANDLER
	var/mob/living/puppet = parent

	var/message = speech_args[SPEECH_MESSAGE]
	if(!message)
		return
	message = lowertext(message)

	if(!master || QDELETED(puppet) || puppet.stat != CONSCIOUS)
		qdel(src)
		return

	var/is_yell = (say_test(message) >= "2")
	// Find a command that matches the message and invocation type
	if(command_cooldown && world.time < command_cooldown)
		to_chat(master, span_warning("You need more time to focus your will before issuing another command."))
		return
	for(var/datum/voice_of_god_command/command as anything in GLOB.voice_of_god_commands)
		if(findtext(message, command.trigger))
			if(command.tier == 3)
				if(!is_yell)
					to_chat(master, span_warning("You must exert your will more forcefully to make them obey that command!"))
					return 
			if(command.tier >= 2 && !is_overt)
				to_chat(puppet, span_mind_control("You are overwhelmed by a controlling presence throughout your mind!"))
				// Add the submission verb to the puppet
				var/mob/living/carbon/human/slave = parent
				if(slave)
					slave.verbs += /mob/living/proc/submit_to_master

			// Execute the command on the puppet
			command.execute(list(puppet), master, 1, message)

			// Set the cooldown for this command type
			if(command.cooldown > 0)
				to_chat(master, span_warning("You must recover for [DisplayTimeText(command.cooldown)] seconds before issuing another command."))
				command_cooldown = world.time + command.cooldown
			return

/datum/component/dominated_mind/proc/handle_hearing(datum/source, list/hearing_args)
	SIGNAL_HANDLER

	var/mob/living/puppet = parent
	var/mob/living/speaker = hearing_args[HEARING_SPEAKER]

	// If the speaker isn't our master, or if the speaker is invalid, we do nothing.
	if(!speaker || speaker != master)
		return

	// Don't reformat the puppet's own speech
	if(puppet == speaker)
		return

	// Reformat the raw message text.
	hearing_args[HEARING_RAW_MESSAGE] = span_phobia(hearing_args[HEARING_RAW_MESSAGE])

/// This verb allows a player under the effect of Dominate Mind to permanently submit to their master.
/mob/living/proc/submit_to_master()
	set name = "Submit to Master"
	set category = "SUBMIT"

	var/datum/component/dominated_mind/dom_comp = GetComponent(/datum/component/dominated_mind)

	if(!dom_comp)
		to_chat(src, span_warning("Your mind is your own."))
		return

	if(dom_comp.permanent_submission)
		to_chat(src, span_warning("You have already sworn your will to your master."))
		return

	dom_comp.confirm_submission()
