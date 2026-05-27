// Magi 2 compatibility stubs
// Provides type declarations and proc stubs for Azure-Peak-specific machinery that
// spell_cooldown.dm references but Emerald Summit does not (yet) have a port of.
//
// These are intentionally MINIMAL — they exist only so the spell base compiles.
// Future ports of the upstream Arcyne combat / implement / featured-stats systems
// will REPLACE these stubs with real implementations.

// ---- Missing status effect types ----
// Referenced by spell_cooldown.dm but not present in Emerald Summit's roguebuff.dm.
// Empty subtype of the buff base so type paths resolve. Application is a no-op
// in the adapter layer; nothing applies these yet.

/datum/status_effect/buff/residual_focus
	id = "residual_focus"
	duration = 20 SECONDS

/datum/status_effect/buff/parry_buffer
	id = "parry_buffer"
	duration = 5 SECONDS

/datum/status_effect/buff/arcyne_momentum
	id = "arcyne_momentum"
	duration = 30 SECONDS
	var/stacks = 0

/datum/status_effect/buff/arcyne_momentum/proc/consume_all_stacks()
	stacks = 0
	qdel(src)

/datum/status_effect/recent_weapon
	id = "recent_weapon"
	duration = 5 SECONDS

// ---- Missing helpers referenced by spell_cooldown.dm ----

/// Returns the implement weapon held by the user, if any. Stub: always null.
/// Real implementation will check rogueweapon.implement_refund once that var is ported.
/proc/arcyne_get_weapon(mob/user)
	return null

// `isarcyne`, `record_featured_object_stat`, and `mouse_angle_from_client` already exist in
// Emerald Summit (code/datums/magic_items/mages_mechanics.dm/mageritualrunes.dm,
// code/__HELPERS/round_statistics.dm, code/__HELPERS/mouse_control.dm respectively).
// We use the existing implementations.

// ---- Defines for residual_focus / parry_buffer / arcyne_momentum integration ----
// Used by spell_cooldown.dm spell_guard_check. Picked to match Azure-Peak values.
#define RIPOSTE_SHARPNESS_FACTOR 0.05
#define RIPOSTE_INTEG_DIVISOR 20
#define INTEG_PARRY_DECAY_NOSHARP 2

// ---- /obj/item/rogueweapon stub var ----
// Implement refund pool. Magi 2 weapons set this to fractional values (0.20 / 0.275 / 0.35).
// Existing Emerald Summit weapons leave this as 0, so spell_guard_check / implement refund
// pathways naturally become no-ops until weapons are flagged.
/obj/item/rogueweapon
	var/implement_refund = 0
