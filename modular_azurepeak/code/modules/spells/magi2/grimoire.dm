// Grimoire of Aspects — Tome item that opens the staged aspect picker
// (/datum/aspect_picker -> GrimoireAspectPicker TGUI) for in-round loadout reshaping.
// Edit mode (setup = FALSE): adding aspects to free slots is free; reshaping (unbinding to
// swap) spends binding points, and aspect swaps require a binding/unbinding chant.

/obj/item/book/magi2_grimoire
	name = "\improper Grimoire of Aspects"
	desc = "A leather-bound grimoire that lets a magi reshape their arcyne aspects. \
		Hold it open to study what flows through the soul; close it to keep the bindings firm."
	// Reuse the existing spellbook art from icons/roguetown/items/books.dmi. Named differently
	// from /obj/item/book/spellbook to avoid two items with the same display name.
	icon = 'icons/roguetown/items/books.dmi'
	icon_state = "spellbookbrown_0"
	slot_flags = ITEM_SLOT_HIP
	dropshrink = 0.6
	drop_sound = 'sound/foley/dropsound/book_drop.ogg'
	throwforce = 0
	throw_speed = 2
	throw_range = 3
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("bashed", "whacked", "educated")

/obj/item/book/magi2_grimoire/attack_self(mob/user)
	if(!user.mind)
		to_chat(user, span_warning("Without a mind to anchor them, these inscriptions mean nothing."))
		return
	var/datum/mind/M = user.mind
	// First-time setup mode (free picks, no chants) while the mage has nothing bound; once they've
	// sealed any aspect, subsequent opens are edit mode where reshaping costs binding points + chants.
	// Filling still-empty slots stays free in either mode. Config gives the slot/utility limits
	// (null -> MAX_*_ASPECTS defaults). The picker manages its own lifecycle (qdels on close / when full).
	var/setup_mode = !LAZYLEN(M.major_aspects) && !LAZYLEN(M.minor_aspects)
	var/datum/aspect_picker/picker = new(user, setup_mode, M.mage_aspect_config)
	picker.ui_interact(user)
