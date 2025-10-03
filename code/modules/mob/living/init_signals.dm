///Called on /mob/living/Initialize(), for the mob to register to relevant signals.
/mob/living/proc/register_init_signals()

	RegisterSignal(src, COMSIG_MOVETYPE_FLAG_ENABLED, PROC_REF(on_movement_type_flag_enabled))
	RegisterSignal(src, COMSIG_MOVETYPE_FLAG_DISABLED, PROC_REF(on_movement_type_flag_disabled))

/* ROGUE */

///From [element/movetype_handler/on_movement_type_trait_gain()]
/mob/living/proc/on_movement_type_flag_enabled(datum/source, trait)
	SIGNAL_HANDLER
	update_movespeed(FALSE)

///From [element/movetype_handler/on_movement_type_trait_loss()]
/mob/living/proc/on_movement_type_flag_disabled(datum/source, trait)
	SIGNAL_HANDLER
	update_movespeed(FALSE)
