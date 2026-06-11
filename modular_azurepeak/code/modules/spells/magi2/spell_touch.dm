// Magi 2 touch-spell base — port of Azure-Peak code/modules/spells/spell_touch.dm (PR #6406)
//
// Adapter notes:
//  - Inherits the Magi 2 action-spell base (resource costs, charge mechanics, button icons,
//    sneak/weapon penalty checks). The touch toggle replaces the normal click-to-target flow:
//    pressing the action button creates a hand object directly; pressing it again removes it
//    and refunds the cooldown.
//  - Hand item lives at /obj/item/melee/touch_attack_magi2. Distinct from the existing ES
//    /obj/item/melee/touch_attack (old proc_holder system) and from upstream's
//    /obj/item/melee/new_touch_attack — Magi 2 spells own this hand type exclusively.
//  - Subclasses implement cast_on_hand_hit(target, caster, proximity) for the actual effect.
//    Rune Ward dispatches on caster.used_intent.type inside that proc.

/datum/action/cooldown/spell/touch
	name = "Touch Spell"
	desc = "A spell that channels through a touch."
	sound = null

	click_to_activate = FALSE

	/// Item type used as the touch hand. Subclasses can override (e.g. Rune Ward's hand
	/// has bespoke intents and possible_item_intents).
	var/hand_path = /obj/item/melee/touch_attack_magi2
	/// The currently-equipped touch hand. NULL when the spell is not "active".
	var/obj/item/melee/touch_attack_magi2/attached_hand
	/// Message shown when the hand is created.
	var/draw_message = "I focus arcyne energy into my hand."
	/// Message shown when the hand is dismissed or expended.
	var/drop_message = "The arcyne energy drains out of my hand."
	/// If FALSE, casting on the spell's owner (self) prints a refusal.
	var/can_cast_on_self = FALSE
	/// If TRUE, the hand persists indefinitely and never decrements charges.
	var/infinite_use = FALSE
	/// Number of hand-hits the spell allows before the hand qdels. Ignored if infinite_use.
	var/charges = 1
	/// Set during a successful hand hit so cast() doesn't treat the after-hit cleanup as a toggle.
	var/expending_charge = FALSE

/datum/action/cooldown/spell/touch/Destroy()
	remove_hand(refund = FALSE, message = FALSE)
	return ..()

/datum/action/cooldown/spell/touch/Remove(mob/living/remove_from)
	if(remove_from && attached_hand?.loc == remove_from)
		remove_hand(refund = FALSE, message = TRUE)
	return ..()

/datum/action/cooldown/spell/touch/is_valid_target(atom/cast_on)
	// Touch spells are toggled on self — bypass the click-self refusal in the parent.
	return TRUE

/datum/action/cooldown/spell/touch/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return
	// Don't burn cooldown / play feedback for the toggle — the hand hit will do that.
	. |= SPELL_NO_FEEDBACK | SPELL_NO_IMMEDIATE_COOLDOWN | SPELL_NO_IMMEDIATE_COST

/datum/action/cooldown/spell/touch/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/caster = owner
	if(!iscarbon(caster))
		return FALSE
	if(!QDELETED(attached_hand))
		remove_hand(refund = TRUE, message = TRUE)
		return TRUE
	return create_hand(caster)

/datum/action/cooldown/spell/touch/proc/create_hand(mob/living/carbon/caster)
	if(!istype(caster))
		return FALSE
	var/obj/item/melee/touch_attack_magi2/hand = new hand_path(caster)
	hand.attached_spell = WEAKREF(src)
	if(!caster.put_in_hands(hand))
		qdel(hand)
		if(caster.get_num_arms() <= 0)
			to_chat(caster, span_warning("I don't have any usable hands!"))
		else
			to_chat(caster, span_warning("My hands are full!"))
		return FALSE
	attached_hand = hand
	to_chat(caster, span_notice("[draw_message]"))
	UpdateButtonIcon()
	return TRUE

/datum/action/cooldown/spell/touch/proc/remove_hand(refund = TRUE, message = TRUE)
	if(QDELETED(attached_hand))
		attached_hand = null
		return
	if(message && owner)
		to_chat(owner, span_notice("[drop_message]"))
	QDEL_NULL(attached_hand)
	if(refund && !expending_charge)
		// The toggle didn't fire a hit — refund any cooldown that was applied.
		reset_spell_cooldown()
	UpdateButtonIcon()

/// Called by the hand's afterattack when it successfully connects with a target.
/// Returns TRUE if the hit was "consumed" (charge spent / cooldown started).
/datum/action/cooldown/spell/touch/proc/on_hand_hit(atom/target, mob/living/carbon/caster, proximity_flag)
	if(!proximity_flag)
		return FALSE
	if(!caster || caster != owner)
		return FALSE
	if(target == caster && !can_cast_on_self)
		to_chat(caster, span_warning("I can't cast [name] on myself!"))
		return FALSE

	var/cast_result = cast_on_hand_hit(target, caster, proximity_flag)
	if(!cast_result)
		return FALSE

	expending_charge = TRUE
	if(!infinite_use)
		charges--
	StartCooldown(get_adjusted_cooldown())
	invoke_cost()
	spell_feedback(caster)
	if(!infinite_use && charges <= 0)
		remove_hand(refund = FALSE, message = TRUE)
	expending_charge = FALSE
	UpdateButtonIcon()
	return TRUE

/// Subclasses override this with the actual on-hit effect.
/// Return TRUE to consume a charge / start cooldown, FALSE to do nothing.
/datum/action/cooldown/spell/touch/proc/cast_on_hand_hit(atom/target, mob/living/carbon/caster, proximity_flag)
	return TRUE

// ============================================================================
// Hand item base — the in-hand object created when a touch spell is "active".
// ============================================================================

/obj/item/melee/touch_attack_magi2
	name = "outstretched hand"
	desc = "A hand crackling with arcyne energy."
	icon = 'icons/obj/balloons.dmi'
	lefthand_file = 'icons/mob/inhands/misc/touchspell_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/touchspell_righthand.dmi'
	icon_state = "syndballoon"
	item_state = null
	item_flags = NEEDS_PERMIT | ABSTRACT | DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	force = 0
	throwforce = 0
	throw_range = 0
	throw_speed = 0
	/// Weakref to the /datum/action/cooldown/spell/touch that created us.
	var/datum/weakref/attached_spell

/obj/item/melee/touch_attack_magi2/Destroy()
	var/datum/action/cooldown/spell/touch/parent = attached_spell?.resolve()
	if(parent && parent.attached_hand == src)
		parent.attached_hand = null
		parent.UpdateButtonIcon()
	attached_spell = null
	return ..()

/obj/item/melee/touch_attack_magi2/attack(mob/target, mob/living/carbon/user)
	if(!iscarbon(user))
		return
	if(!(user.mobility_flags & MOBILITY_USE))
		to_chat(user, span_warning("I can't reach out!"))
		return
	..()

/obj/item/melee/touch_attack_magi2/attack_self(mob/user)
	var/datum/action/cooldown/spell/touch/parent = attached_spell?.resolve()
	if(parent)
		parent.remove_hand(refund = TRUE, message = TRUE)

// Dropping the hand to the floor is a UX shortcut for deselecting the touch spell —
// equivalent to attack_self / clicking the action button a second time. We refund
// the cooldown and let DROPDEL handle the actual qdel via the parent dropped() chain.
/obj/item/melee/touch_attack_magi2/dropped(mob/user, silent)
	var/datum/action/cooldown/spell/touch/parent = attached_spell?.resolve()
	if(parent && !QDELETED(parent))
		parent.remove_hand(refund = TRUE, message = TRUE)
	return ..()

/obj/item/melee/touch_attack_magi2/afterattack(atom/target, mob/user, proximity_flag, params)
	. = ..()
	if(!proximity_flag)
		return
	var/datum/action/cooldown/spell/touch/parent = attached_spell?.resolve()
	if(!parent)
		return
	parent.on_hand_hit(target, user, proximity_flag)
