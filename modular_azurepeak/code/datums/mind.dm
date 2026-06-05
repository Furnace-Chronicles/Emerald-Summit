/datum/mind
	var/has_changed_spell = FALSE // If the person has changed their spells for theday
	/// If you have a spell granted by Rituos, resets when you sleep
	var/has_rituos = FALSE
	var/obj/effect/proc_holder/spell/rituos_spell
	/// Set once Rituos' Lesser Work is completed - permanent one-time gate (does not reset on sleep)
	var/rituos_completed = FALSE
