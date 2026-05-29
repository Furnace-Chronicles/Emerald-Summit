// Action-button icons for the legacy proc_holder Augmentation utility spells.
// Without these overrides the spells all render as the generic "spell0" scroll
// from the /obj/effect/proc_holder/spell base. Each rebind here points at the
// distinct icon state already present in mage_augmentation.dmi (pulled from
// Azure-Peak during the Magi 2 port).
//
// Background scroll comes from spell_scroll_background.dm (sets the base
// /spell.action_background_icon_state = "spell"), so we only set the foreground
// icon here.
//
// Affects all consumers — Lesser Augmentation aspect, Noc miracle bundle, any
// future spell-granter that hands these out.

#define MAGE_AUGMENTATION_DMI 'icons/mob/actions/mage_augmentation.dmi'

/obj/effect/proc_holder/spell/invoked/haste
	action_icon = MAGE_AUGMENTATION_DMI
	action_icon_state = "haste"

/obj/effect/proc_holder/spell/targeted/touch/darkvision
	action_icon = MAGE_AUGMENTATION_DMI
	action_icon_state = "darkvision"

/obj/effect/proc_holder/spell/invoked/stoneskin
	action_icon = MAGE_AUGMENTATION_DMI
	action_icon_state = "stoneskin"

/obj/effect/proc_holder/spell/invoked/hawks_eyes
	action_icon = MAGE_AUGMENTATION_DMI
	action_icon_state = "hawks_eyes"

/obj/effect/proc_holder/spell/invoked/giants_strength
	action_icon = MAGE_AUGMENTATION_DMI
	action_icon_state = "giants_strength"

/obj/effect/proc_holder/spell/invoked/guidance
	action_icon = MAGE_AUGMENTATION_DMI
	action_icon_state = "guidance"

// Featherfall uses its own existing overlay_state ("jump") in roguespells.dmi.
// mage_augmentation.dmi doesn't have a featherfall state, but "jump" is the same
// rune used in-world for the spell impact — visually associated, guaranteed present.
/obj/effect/proc_holder/spell/invoked/featherfall
	action_icon = 'icons/mob/actions/roguespells.dmi'
	action_icon_state = "jump"

/obj/effect/proc_holder/spell/invoked/enlarge
	action_icon = MAGE_AUGMENTATION_DMI
	action_icon_state = "enlarge"

// Leap uses its own existing overlay_state ("rune5") in roguespells.dmi for the same
// reason as Featherfall above — visually associated, guaranteed present.
/obj/effect/proc_holder/spell/invoked/leap
	action_icon = 'icons/mob/actions/roguespells.dmi'
	action_icon_state = "rune5"

/obj/effect/proc_holder/spell/targeted/touch/nondetection
	action_icon = MAGE_AUGMENTATION_DMI
	action_icon_state = "nondetection"

/obj/effect/proc_holder/spell/invoked/fortitude
	action_icon = MAGE_AUGMENTATION_DMI
	action_icon_state = "fortitude"

#undef MAGE_AUGMENTATION_DMI
