/datum/objective/mock
	name = "Xylixian Mockery"
	triumph_count = 0

/datum/objective/mock/on_creation()
	. = ..()
	if(owner?.current)
		RegisterSignal(owner.current, COMSIG_VICIOUSLY_MOCKED, PROC_REF(on_mock_used))
	update_explanation_text()

/datum/objective/mock/Destroy()
	if(owner?.current)
		UnregisterSignal(owner.current, COMSIG_VICIOUSLY_MOCKED)
	return ..()

/datum/objective/mock/proc/on_mock_used(datum/source, mob/living/target, mob/living/user)
	SIGNAL_HANDLER
	return

/// Monarch variant
/datum/objective/mock/monarch
	name = "Ducal Mockery"
	triumph_count = 0

/datum/objective/mock/monarch/on_mock_used(datum/source, mob/living/victim)
	. = ..()
	if((istype(victim.mind?.assigned_role, /datum/job/roguetown/lord) || victim.job == "Duke") && (source == owner.current))
		to_chat(owner.current, span_greentext("You have mocked the Duke and completed the objective!"))
		owner.current.adjust_triumphs(1)
		completed = TRUE
		adjust_storyteller_influence("Xylix", 15)
		escalate_objective()
		UnregisterSignal(owner.current, COMSIG_VICIOUSLY_MOCKED)

/datum/objective/mock/monarch/update_explanation_text()
	. = ..()
	explanation_text = "Viciously mock the Duke for Xylix!"

/// Noble variant
/datum/objective/mock/noble
	name = "Noble Mockery"
	var/mocked_targets = 0
	var/required_count = 2

/datum/objective/mock/noble/update_explanation_text()
	. = ..()
	explanation_text = "Viciously mock [required_count] nobles for Xylix!"

/datum/objective/mock/noble/on_mock_used(datum/source, mob/living/victim)
	. = ..()
	var/mob/living/carbon/human/human_victim = victim
	if(!istype(human_victim) || human_victim.stat == DEAD || human_victim == source)
		return

	if(human_victim.is_noble() && (source == owner.current))
		mocked_targets++
		if(mocked_targets >= required_count)
			to_chat(owner.current, span_greentext("You have mocked enough nobles and completed the objective!"))
			owner.current.adjust_triumphs(1)
			completed = TRUE
			adjust_storyteller_influence("Xylix", 10)
			escalate_objective()
			UnregisterSignal(owner.current, COMSIG_VICIOUSLY_MOCKED)
		else
			to_chat(owner.current, span_notice("Noble mocked! Viciously mock [required_count - mocked_targets] more nobles to complete the objective!"))
