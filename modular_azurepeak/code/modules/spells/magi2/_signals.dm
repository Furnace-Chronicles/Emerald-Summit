// Magi 2 signals + action-button update flags + cast-chain bitflags
// Adapter-layer port: these are new constants that the existing Emerald Summit
// action system doesn't use. The Magi 2 spell base class is the only consumer.

// ---- Cast-chain bitflags (returned from before_cast / passed through Activate) ----
#define SPELL_CANCEL_CAST            (1 << 0)
#define SPELL_NO_FEEDBACK            (1 << 1)
#define SPELL_NO_IMMEDIATE_COOLDOWN  (1 << 2)
#define SPELL_NO_IMMEDIATE_COST      (1 << 3)

// ---- Spell signals ----
#define COMSIG_SPELL_BEFORE_CAST     "spell_before_cast"
#define COMSIG_SPELL_CAST            "spell_cast"
#define COMSIG_SPELL_AFTER_CAST      "spell_after_cast"
#define COMSIG_SPELL_CAST_RESET      "spell_cast_reset"

// ---- Mob spell signals ----
#define COMSIG_MOB_BEFORE_SPELL_CAST "mob_before_spell_cast"
#define COMSIG_MOB_CAST_SPELL        "mob_cast_spell"
#define COMSIG_MOB_AFTER_SPELL_CAST  "mob_after_spell_cast"
#define COMSIG_MOB_SPELL_ACTIVATED   "mob_spell_activated"
#define COMSIG_MOB_PRE_INVOCATION    "mob_pre_invocation"

// ---- Client mouse intercept (Vanderlin/Azure-Peak helper) ----
// Returned from MOUSEDOWN signal handler to swallow the click before
// default handling fires it as a normal interact.
#define COMSIG_CLIENT_MOUSEDOWN_INTERCEPT (1 << 0)

// ---- Action-button update flag bitmask (used by build_all_button_icons / build_button_icon) ----
// We don't have the full modern HUD, but the spell base passes these flags around;
// our adapter UpdateButtonIcon() ignores them since the old proc updates everything anyway.
#define UPDATE_BUTTON_NAME       (1 << 0)
#define UPDATE_BUTTON_BACKGROUND (1 << 1)
#define UPDATE_BUTTON_ICON       (1 << 2)
#define UPDATE_BUTTON_OVERLAY    (1 << 3)
#define UPDATE_BUTTON_STATUS     (1 << 4)
#ifndef ALL
#define ALL (~0)
#endif

// ---- Featured-stat key used by record_featured_object_stat() in spell cast logging ----
// Adapter layer: stubbed by _compat_stubs.dm — no actual featured-stat backend in Emerald Summit.
#define FEATURED_STATS_SPELLS "spells"
