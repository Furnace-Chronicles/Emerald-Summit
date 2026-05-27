// Grimoire MVP — Tome of Arcyne item that opens a TGUI listing every registered
// aspect with bind/unbind buttons. Replaces the admin-only debug verb for in-round play.
// Uses an existing book sprite from the spellbooks icon since Magi 2 doesn't have its
// own Tome art ported yet.

/obj/item/book/magi2_grimoire
	name = "\improper Grimoire of Aspects"
	desc = "A leather-bound grimoire that lets a magi bind and unbind their arcyne aspects. \
		Hold it open to study what flows through the soul; close it to keep the bindings firm."
	// Reuse the existing spellbook art from icons/roguetown/items/books.dmi instead of the
	// stock library placeholder. Named differently from /obj/item/book/spellbook (the
	// "tome of the arcyne" reward item) to avoid two items with the same display name.
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
	ui_interact(user)

/obj/item/book/magi2_grimoire/ui_state(mob/user)
	return GLOB.inventory_state

/obj/item/book/magi2_grimoire/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Magi2Grimoire", "Tome of Arcyne")
		ui.open()

/obj/item/book/magi2_grimoire/ui_data(mob/user)
	var/list/data = list()
	var/datum/mind/M = user.mind
	var/list/aspects_data = list()

	for(var/aspect_path in GLOB.magic_aspects_major + GLOB.magic_aspects_minor)
		var/datum/magic_aspect/A = aspect_path
		var/list/spell_names = list()
		for(var/spell_path in initial(A.fixed_spells))
			var/datum/action/cooldown/spell/S = spell_path
			spell_names += initial(S.name)
		aspects_data += list(list(
			"path" = "[aspect_path]",
			"name" = initial(A.name),
			"latin_name" = initial(A.latin_name),
			"desc" = initial(A.desc),
			"type" = initial(A.aspect_type) == ASPECT_MAJOR ? "Major" : "Minor",
			"color" = initial(A.school_color) || "#FFFFFF",
			"spells" = spell_names,
			"bound" = M ? _magi2_aspect_is_bound(M, aspect_path) : FALSE,
		))

	data["aspects"] = aspects_data
	data["has_mind"] = M ? TRUE : FALSE
	return data

/obj/item/book/magi2_grimoire/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	if(!usr.mind)
		return
	switch(action)
		if("bind")
			var/aspect_path = text2path(params["path"])
			if(!ispath(aspect_path, /datum/magic_aspect))
				return
			if(_magi2_aspect_is_bound(usr.mind, aspect_path))
				return
			_magi2_bind_aspect(usr.mind, aspect_path)
			to_chat(usr, span_notice("You feel [initial(aspect_path:name)] bind itself to your soul."))
			return TRUE
		if("unbind")
			var/aspect_path = text2path(params["path"])
			if(!ispath(aspect_path, /datum/magic_aspect))
				return
			if(!_magi2_aspect_is_bound(usr.mind, aspect_path))
				return
			_magi2_unbind_aspect(usr.mind, aspect_path)
			to_chat(usr, span_notice("You release [initial(aspect_path:name)] from your soul."))
			return TRUE
