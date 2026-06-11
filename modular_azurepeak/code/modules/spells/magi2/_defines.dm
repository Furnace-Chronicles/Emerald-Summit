// Magi 2 "The Awakening" defines — ported from Azure-Peak PR #6406
// Adapter-layer port: lives parallel to the existing /obj/effect/proc_holder/spell system.
// Defines that already exist in Emerald Summit (GLOW_INTENSITY_*, GLOW_COLOR_FIRE/ICE/BUFF/VAMPIRIC/DISPLACEMENT/ARCANE,
// SPELL_SCALING_THRESHOLD, FATIGUE_REDUCTION_PER_INT, COOLDOWN_REDUCTION_PER_INT, ACTION_BUTTON_DEFAULT_BACKGROUND,
// MAGIC_RESISTANCE) are intentionally NOT duplicated here.

// ---- Additional glow colors used by Magi 2 aspects ----
#define GLOW_COLOR_EARTHEN "#8B6914"
#define GLOW_COLOR_KINESIS "#7B68EE"
#define GLOW_COLOR_HEX "#b884f8"
#define GLOW_COLOR_ILLUSION "#CE93D8"
#define GLOW_COLOR_HEARTH "#FF8A65"
#define GLOW_COLOR_LIGHT "#FFFDE7"
#define GLOW_COLOR_WARD "#D4A844"
#define GLOW_COLOR_BARDIC "#E8837C"

// ---- Spell scaling thresholds ----
// SPELL_SCALING_THRESHOLD / FATIGUE_REDUCTION_PER_INT / COOLDOWN_REDUCTION_PER_INT
// are also defined inline in code/modules/spells/spell.dm but BYOND treats those as
// file-scoped. We redeclare them here for the Magi 2 adapter file scope.
#define SPELL_SCALING_THRESHOLD 10
#define FATIGUE_REDUCTION_PER_INT 0.05
#define COOLDOWN_REDUCTION_PER_INT 0.05
#define SPELL_POSITIVE_SCALING_THRESHOLD 15

// ---- Statkey not present in Emerald Summit ----
// Emerald Summit uses STATKEY_END (Endurance) instead of STATKEY_WIL.
// Magi 2 references WIL in get_stat_label() — added here as a never-hit alias so
// the switch arm compiles. No mob actually has "willpower" in get_stat_level().
#define STATKEY_WIL "willpower"

// ---- Armor cooldown penalties ----
#define MEDIUM_ARMOR_CD_PENALTY 0.15
#define HEAVY_ARMOR_CD_PENALTY 0.3
#define UNTRAINED_ARMOR_CD_PENALTY 0.8

// ---- Weapon-in-hand casting penalty ----
#define WEAPON_CAST_PENALTY 0.3

// ---- Standardized stamina costs ----
#define SPELLCOST_CANTRIP            5
#define SPELLCOST_MINOR_PROJECTILE   10
#define SPELLCOST_MAJOR_PROJECTILE   20
#define SPELLCOST_SUPER_PROJECTILE   45
#define SPELLCOST_ULTIMATE           70
#define SPELLCOST_MINOR_AOE          15
#define SPELLCOST_MAJOR_AOE          30
#define SPELLCOST_SINGLE_CC          30
#define SPELLCOST_UTILITY_BUFF       20
#define SPELLCOST_STAT_BUFF          40
#define SPELLCOST_CONJURE            20
#define SPELLCOST_TELEPORT           15
#define SPELLCOST_MINOR_SUMMON       30
#define SPELLCOST_MAJOR_SUMMON       50

// ---- Buff durations ----
#define STAT_BUFF_SELF_DURATION      (1 MINUTES)
#define STAT_BUFF_ALLY_DURATION      (2.5 MINUTES)
#define UTILITY_AOE_BUFF_DURATION    (15 MINUTES)

// ---- Miracle (devotion) costs ----
#define SPELLCOST_MIRACLE_ORISON      5
#define SPELLCOST_MIRACLE_MINOR       15
#define SPELLCOST_MIRACLE             30
#define SPELLCOST_MIRACLE_MAJOR       60
#define SPELLCOST_MIRACLE_LEGENDARY  100

#define SPELLCOST_MINOR_SKILL  30
#define SPELLCOST_MAJOR_SKILL  50

// ---- Spellblade ----
#define SPELLCOST_SB_POKE      12
#define SPELLCOST_SB_MOBILITY  12
#define SPELLCOST_SB_ULT       50

// ---- Standardized charge times ----
#define CHARGETIME_POKE   (1 SECONDS)
#define CHARGETIME_MINOR  (2 SECONDS)
#define CHARGETIME_MAJOR  (3 SECONDS)
#define CHARGETIME_HEAVY  (4 SECONDS)
/// Fraction of a spell's charge_time removed per arcane skill level (mirrors legacy CHARGE_REDUCTION_PER_SKILL).
#define MAGI2_CHARGE_REDUCTION_PER_SKILL 0.05

// ---- Standardized mage projectile speeds (lower = faster) ----
#define MAGE_PROJ_FAST       1.25
#define MAGE_PROJ_MEDIUM     1.75
#define MAGE_PROJ_SLOW       2
#define MAGE_PROJ_VERY_SLOW  2.5

// ---- Standardized cast ranges ----
#define SPELL_RANGE_PROJECTILE 10
#define SPELL_RANGE_GROUND     7
#define SPELL_RANGE_AURA       4
#define SPELL_RANGE_ADJACENT   1

// ---- Charging slowdown tiers ----
#define CHARGING_SLOWDOWN_NONE   0
#define CHARGING_SLOWDOWN_SMALL  1
#define CHARGING_SLOWDOWN_MEDIUM 2
#define CHARGING_SLOWDOWN_HEAVY  3

// ---- Spell impact visual intensity tiers ----
#define SPELL_IMPACT_NONE   0
#define SPELL_IMPACT_LOW    1
#define SPELL_IMPACT_MEDIUM 2
#define SPELL_IMPACT_HIGH   3

// ---- Aspect system ----
#define MAX_MAJOR_ASPECTS 1
#define MAX_MINOR_ASPECTS 2
#define ASPECT_MAJOR "major"
#define ASPECT_MINOR "minor"

#define ASPECT_NAME_PYROMANCY    "Fire"
#define ASPECT_NAME_CRYOMANCY    "Frost"
#define ASPECT_NAME_FULGURMANCY  "Storms"
#define ASPECT_NAME_GEOMANCY     "Stone"
#define ASPECT_NAME_KINESIS      "Force"
#define ASPECT_NAME_FERRAMANCY   "Metal"
#define ASPECT_NAME_AUGMENTATION "Enhancement"
#define ASPECT_NAME_BATTLEWARDRY "Wards"
#define ASPECT_NAME_TELOMANCY    "Trajectory"

#define ASPECT_RESET_BUDGET       4
#define ASPECT_RESET_COST_MAJOR   4
#define ASPECT_RESET_COST_MINOR   2
#define ASPECT_RESET_COST_UTILITY 1

#define VARIANT_ADDITIVE "__additive__"

// ---- Implement tiers and refund fractions ----
#define IMPLEMENT_TIER_LESSER  1
#define IMPLEMENT_TIER_GREATER 2
#define IMPLEMENT_TIER_GRAND   3
#define IMPLEMENT_REFUND_LESSER  0.20
#define IMPLEMENT_REFUND_GREATER 0.275
#define IMPLEMENT_REFUND_GRAND   0.35

// ---- Arcyne ward tiers ----
#define ARCYNE_WARD_TIER_OTHER   1
#define ARCYNE_WARD_TIER_BASE    4
#define ARCYNE_WARD_TIER_GREATER 5

// ---- Spell cost types (resource pools) ----
#define SPELL_COST_NONE     0
#define SPELL_COST_STAMINA  1
#define SPELL_COST_ENERGY   2
#define SPELL_COST_DEVOTION 3
#define SPELL_COST_BLOOD    4 // not implemented
#define SPELL_COST_VITAE    5 // not implemented

// ---- Invocation types ----
// Match the string literals already used by /obj/effect/proc_holder/spell.invocation_type
#define INVOCATION_NONE    "none"
#define INVOCATION_SHOUT   "shout"
#define INVOCATION_WHISPER "whisper"
#define INVOCATION_EMOTE   "emote"

// Indices into invocation lists used by COMSIG_MOB_PRE_INVOCATION
#define INVOCATION_MESSAGE 1
#define INVOCATION_TYPE    2

// ---- Generic spell bitflags ----
#define SPELL_IGNORE_SPELLBLOCK (1 << 0)
#define SPELL_RITUOS            (1 << 1)
#define SPELL_PSYDON            (1 << 2)

// ---- Spell requirements bitflags ----
#define SPELL_REQUIRES_WIZARD_GARB         (1 << 0)
#define SPELL_REQUIRES_HUMAN               (1 << 1)
#define SPELL_CASTABLE_WHILE_PHASED        (1 << 2)
#define SPELL_REQUIRES_NO_ANTIMAGIC        (1 << 3)
#define SPELL_REQUIRES_STATION             (1 << 4)
#define SPELL_REQUIRES_MIND                (1 << 5)
#define SPELL_CASTABLE_WITHOUT_INVOCATION  (1 << 6)
#define SPELL_REQUIRES_NO_MOVE             (1 << 7)
#define SPELL_REQUIRES_SAME_Z              (1 << 8)

// ---- Action-button check flags absent in Emerald Summit's action.dm ----
// AB_CHECK_CONSCIOUS / AB_CHECK_STUN / AB_CHECK_LYING / AB_CHECK_RESTRAINED already exist
#define AB_CHECK_PHASED        (1 << 4)
#define AB_CHECK_HANDS_BLOCKED (1 << 5)
#define AB_CHECK_IMMOBILE      (1 << 6)

// ---- Telegraph delay tiers (ticks) ----
#define TELEGRAPH_SKILLSHOT    4
#define TELEGRAPH_DODGEABLE    8
#define TELEGRAPH_HIGH_IMPACT  12
#define TELEGRAPH_AREA_DENIAL  16
#define TELEGRAPH_ULTIMATE     20

// ---- Rune Ward types ----
#define RUNE_WARD_STUN        "stun"
#define RUNE_WARD_FIRE        "fire"
#define RUNE_WARD_CHILL       "chill"
#define RUNE_WARD_DAMAGE      "damage"
#define RUNE_WARD_ALARM       "alarm"
#define RUNE_WARD_ICON_STUN   "rune_stun"
#define RUNE_WARD_ICON_FIRE   "rune_fire"
#define RUNE_WARD_ICON_CHILL  "rune_chill"
#define RUNE_WARD_ICON_DAMAGE "rune_damage"
#define RUNE_WARD_ICON_ALARM  "rune_alarm"

// ---- Leyline teleport limits ----
#define TELEPORT_MAX_PASSENGERS 6
#define TELEPORT_MAX_NONMAGES   2

// ---- Armor types used by Magi 2 ward upgrades ----
// AP defines these via its DR_/DBLOCK_ severity constants; we hand-pick values for the
// pilot in the same style as Emerald Summit's existing ARMOR_LEATHER/ARMOR_PLATE defines.
// Dragonhide trades a bit of physical protection for meaningful fire resistance.
// Brigandine is a tough mid-tier alternative — better than leather, worse than plate.
#define ARMOR_DRAGONHIDE list("blunt" = 50, "slash" = 50, "stab" = 40, "piercing" = 20, "fire" = 70, "acid" = 0)
#define ARMOR_BRIGANDINE list("blunt" = 70, "slash" = 80, "stab" = 60, "piercing" = 50, "fire" = 0, "acid" = 0)

// ---- Lightning adaptation (Fulgurmancy Bolt of Lightning) ----
// Gates the immobilize/clickcd/lightningstruck CC stack so a target can't be perma-locked
// by repeated casts. Stored on the target as a world.time stamp in mob_timers.
#define MT_LIGHTNING_ADAPTATION "lightning_adaptation"
#define LIGHTNING_ADAPTATION_COOLDOWN (15 SECONDS)

// ---- Gravity adaptation (Kinesis Gravity / Mass Gravity) ----
// Same pattern as lightning: after being knocked down once, the target adapts for 15s.
// Damage still applies during adaptation, but Knockdown/OffBalance does not.
#define MT_GRAVITY_ADAPTATION "gravity_adaptation"
#define GRAVITY_ADAPTATION_COOLDOWN (15 SECONDS)

// ---- Full-body coverage bitmask used by Arcyne Ward ----
// Bitwise OR of every covered body zone — the ward starts covering everything,
// then masks off zones where real armor / clothing exists.
#define COVERAGE_FULL_BODY_ACTUAL (HEAD | HAIR | EARS | EYES | NOSE | MOUTH | NECK | CHEST | GROIN | VITALS | LEGS | ARMS | HANDS | FEET)

// ---- Magic resistance bitflags (Magi 2 antimagic_flags) ----
// Adapter notes: Emerald Summit's mob.anti_magic_check() takes booleans (magic, holy, tinfoil),
// not bitflags. These constants exist only so spell `antimagic_flags = MAGIC_RESISTANCE_HOLY`
// compiles; the actual check goes through owner.anti_magic_check() which the adapter calls.
#define MAGIC_RESISTANCE_MIND   (1 << 1)
#define MAGIC_RESISTANCE_HOLY   (1 << 2)
#define MAGIC_RESISTANCE_UNHOLY (1 << 3)

// ---- Magi 2 trait names (string traits, not present in code/__DEFINES/traits.dm) ----
// Nothing in Emerald Summit applies these traits yet, so HAS_TRAIT() checks always return FALSE.
// Defining them gates the spell base behind a no-op rather than a compile error.
#define TRAIT_SPELLBLOCK     "spellblock"
#define TRAIT_NOC_CURSE      "noc_curse"
#define TRAIT_ATHEISM_CURSE  "atheism_curse"
#define TRAIT_PSYDONITE      "psydonite"
// Dragonhide ward grants TRAIT_FIRE_RESIST. Nothing in ES currently checks this trait
// (upstream's fire damage reduction lives in Azure-Peak's burn-handling code we haven't
// ported), so the trait is functionally inert until that wiring lands.
#define TRAIT_FIRE_RESIST    "fire_resist"

// ---- Movespeed modifier id used while channeling ----
#define MOVESPEED_ID_SPELL_CASTING "spell_casting"

// ---- Client mouse signals used by Magi 2 charge input handlers ----
// Emerald Summit does not proxy mouse events through client signals; the spell base
// registers/unregisters these defensively for cleanup but the signal handlers never
// fire under the do_after() fallback flow. Defining the names makes the calls compile.
#define COMSIG_CLIENT_MOUSEDOWN "client_mousedown"
#define COMSIG_CLIENT_MOUSEUP   "client_mouseup"
