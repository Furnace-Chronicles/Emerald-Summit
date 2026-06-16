// Drop-to-dismiss for legacy touch-spell hands (Darkvision, Nondetection, etc.).
// /obj/item/melee/touch_attack is granted TRAIT_NODROP by its core Initialize; we
// strip it on equip so drop is allowed, and route drop through the spell's own
// re-click dismiss path (touch_attacks.dm:28-32).

/obj/item/melee/touch_attack/equipped(mob/user, slot, initial)
	. = ..()
	REMOVE_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)

/obj/item/melee/touch_attack/dropped(mob/user, silent)
	if(attached_spell)
		attached_spell.remove_hand(TRUE)
		if(user)
			to_chat(user, span_notice("[attached_spell.dropmessage]"))
	return ..()
