// Magi 2 mob var additions
// Vars referenced by /datum/action/cooldown/spell but not present on Emerald Summit's mob.

/mob
	/// The spell currently being channeled by this mob, if any.
	/// Set by /datum/action/cooldown/spell/on_start_charge, cleared by end_charging.
	var/datum/action/cooldown/spell/channeling_spell
	/// Overhead rune effect shown while a Magi 2 spell is charging.
	/// Owned by the mob so cleanup happens on mob Destroy() even if the spell hard-deletes.
	var/obj/effect/spell_rune_under/spell_rune

/client
	/// Soft expiry timestamp for spell click intercepts.
	/// /datum/action/cooldown/spell/start_casting sets this so the input handler can self-time-out.
	var/click_intercept_time = 0
