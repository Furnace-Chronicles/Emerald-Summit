// Magi 2 staged-attune backend — port of Azure-Peak's /datum/mind aspect system.
//
// This is the model the upstream GrimoireAspectPicker is built on: the mind tracks
// live aspect DATUM INSTANCES in major_aspects/minor_aspects (not path strings), and
// attune_aspect()/remove_aspect() are the canonical grant/revoke entry points.
//
// PHASE A: this file is additive and DORMANT — nothing calls attune_aspect() yet. The
// existing magi2_bound_aspects path (magic_aspect.dm) + Magi2Grimoire still drive binding.
// Phase D switches the spellbook + spawn over to this model and retires the old path.
//
// Adapter notes:
//  - attune_aspect() calls aspect.grant_choice_spell/grant_spells/apply_variant, which in
//    our fork already dispatch /datum/action/cooldown/spell vs /obj/effect/proc_holder/spell
//    through the inlined helpers in magic_aspect.dm. So no spell-list widening needed here.
//  - ensure_mage_basics() is trimmed vs upstream: gated on mage_aspect_config (we have no
//    standalone TRAIT_ARCYNE), ward-only (no datum prestidigitation in ES), and drops the
//    regen_action button refresh (our ward spell has no regen_action var).

/datum/mind
	/// Live attuned aspect datum instances (not paths).
	var/list/major_aspects
	var/list/minor_aspects
	/// Per-class config. Keys: "major", "minor", "utilities", "mastery", "ward".
	/// Optional: "variants" (assoc aspect_path = variant_name), "locked_aspects", "post_aspect_spells".
	var/list/mage_aspect_config

	/// Persistent slot/utility bonuses (Arcyne Potential virtue, Hedge Mage archetype, etc.) that must
	/// survive a later setup_mage_aspects, which rebuilds mage_aspect_config wholesale. setup folds these
	/// in every time, so a bonus granted before OR after the class config lands still counts.
	var/magi2_bonus_utilities = 0
	var/magi2_bonus_minor = 0

// The aspect picker reads source_aspect / utility_learned on BOTH spell families to track
// pointbuy ownership and player-learned utilities. Our /datum/action/cooldown/spell base
// already has them; mirror them onto the proc_holder base so the picker compiles and can
// account for proc_holder utility spells (message, darkvision, fetch, ...).
/obj/effect/proc_holder/spell
	var/source_aspect
	var/utility_learned = FALSE

/// Find a live spell instance by type (handles both spell families). FALSE if absent.
/datum/mind/proc/get_spell(spell_type, specific = FALSE)
	var/spell_path = spell_type
	if(istype(spell_type, /obj/effect/proc_holder))
		var/obj/effect/proc_holder/instanced_spell = spell_type
		spell_path = instanced_spell.type
	else if(istype(spell_type, /datum/action/cooldown/spell))
		var/datum/action/cooldown/spell/instanced_spell = spell_type
		spell_path = instanced_spell.type
	for(var/datum/spell as anything in spell_list)
		if(specific && spell.type == spell_path)
			return spell
		else if(!specific && istype(spell, spell_path))
			return spell
	return FALSE

/datum/mind/proc/attune_aspect(datum/magic_aspect/aspect, variant, choice_spell)
	if(!aspect)
		return FALSE
	var/max_majors = LAZYLEN(mage_aspect_config) ? mage_aspect_config["major"] : MAX_MAJOR_ASPECTS
	var/max_minors = LAZYLEN(mage_aspect_config) ? mage_aspect_config["minor"] : MAX_MINOR_ASPECTS
	var/has_mastery = LAZYLEN(mage_aspect_config) ? mage_aspect_config["mastery"] : FALSE
	switch(aspect.aspect_type)
		if(ASPECT_MAJOR)
			if(LAZYLEN(major_aspects) >= max_majors)
				if(current)
					to_chat(current, span_warning("I cannot attune to another major aspect."))
				return FALSE
			LAZYADD(major_aspects, aspect)
		if(ASPECT_MINOR)
			if(LAZYLEN(minor_aspects) >= max_minors)
				if(current)
					to_chat(current, span_warning("I cannot attune to another minor aspect."))
				return FALSE
			LAZYADD(minor_aspects, aspect)
	// Grant choice spell first so it appears first on the action bar. If no explicit choice,
	// auto-resolve: prefer one the player already has, else first in list.
	if(!choice_spell && length(aspect.choice_spells))
		for(var/candidate in aspect.choice_spells)
			if(has_spell(candidate))
				choice_spell = candidate
				break
		if(!choice_spell)
			choice_spell = aspect.choice_spells[1]
	if(choice_spell)
		aspect.grant_choice_spell(src, choice_spell)
	aspect.grant_spells(src)
	// Variant swaps — explicit variant wins, else mastery config grants "mastery".
	if(variant)
		aspect.apply_variant(src, variant)
	else if(has_mastery)
		aspect.apply_variant(src, "mastery")
	ensure_mage_basics()
	return TRUE

/datum/mind/proc/remove_aspect(datum/magic_aspect/aspect, list/skip_spells)
	if(!aspect)
		return FALSE
	aspect.revoke_spells(src, skip_spells)
	switch(aspect.aspect_type)
		if(ASPECT_MAJOR)
			LAZYREMOVE(major_aspects, aspect)
		if(ASPECT_MINOR)
			LAZYREMOVE(minor_aspects, aspect)
	return TRUE

/datum/mind/proc/remove_all_aspects()
	for(var/datum/magic_aspect/aspect in major_aspects)
		remove_aspect(aspect)
	for(var/datum/magic_aspect/aspect in minor_aspects)
		remove_aspect(aspect)

/datum/mind/proc/has_aspect(aspect_type_path)
	for(var/datum/magic_aspect/aspect in major_aspects)
		if(aspect.type == aspect_type_path)
			return TRUE
	for(var/datum/magic_aspect/aspect in minor_aspects)
		if(aspect.type == aspect_type_path)
			return TRUE
	return FALSE

/datum/mind/proc/get_aspect_color()
	if(LAZYLEN(major_aspects))
		var/datum/magic_aspect/first = major_aspects[1]
		return first.school_color
	return GLOW_COLOR_ARCANE

/// Ensure the universal arcyne ward is present (or stripped) per class config.
/// Trimmed from upstream: ward-only, gated on mage_aspect_config, no prestidigitation.
/datum/mind/proc/ensure_mage_basics()
	if(!current)
		return
	var/allow_ward = mage_aspect_config && mage_aspect_config["ward"]
	if(allow_ward)
		var/datum/action/cooldown/spell/conjure_arcyne_ward_magi2/base_ward
		var/has_variant = FALSE
		for(var/datum/action/cooldown/spell/conjure_arcyne_ward_magi2/ward in spell_list)
			if(ward.type == /datum/action/cooldown/spell/conjure_arcyne_ward_magi2)
				base_ward = ward
			else
				has_variant = TRUE // dragonhide/crystalhide upgrade replaces the base ward
		if(has_variant)
			// Upgrade ward(s) present — strip the base ward only. NOTE: RemoveSpell() matches by
			// istype(), and dragonhide/crystalhide are SUBTYPES of the base ward, so
			// RemoveSpell(base_ward) would also delete the Autowardry upgrades. Remove the exact
			// instance instead (matches _mind_revoke_magi2_spell's pattern).
			if(base_ward)
				spell_list -= base_ward
				qdel(base_ward)
		else if(!base_ward)
			AddSpell(new /datum/action/cooldown/spell/conjure_arcyne_ward_magi2)
	else
		// Class doesn't qualify for a ward — strip any base ward present. Same istype caveat as
		// above: remove exact base-ward instances, never via RemoveSpell (it would catch the
		// upgrade subtypes too). Iterate a copy since we mutate spell_list inside the loop.
		for(var/datum/action/cooldown/spell/conjure_arcyne_ward_magi2/ward in spell_list.Copy())
			if(ward.type != /datum/action/cooldown/spell/conjure_arcyne_ward_magi2)
				continue
			if(ward.conjured_ward && !QDELETED(ward.conjured_ward))
				qdel(ward.conjured_ward)
			spell_list -= ward
			qdel(ward)

/datum/mind/proc/setup_mage_aspects(list/config)
	mage_aspect_config = config
	// Fold in any persistent bonuses (see magi2_bonus_* above) so they survive this wholesale replace.
	if(magi2_bonus_utilities)
		mage_aspect_config["utilities"] += magi2_bonus_utilities
	if(magi2_bonus_minor)
		mage_aspect_config["minor"] += magi2_bonus_minor
	ensure_mage_basics()

/// Grant a persistent bonus minor-aspect slot. Stored on magi2_bonus_minor so it survives a later
/// setup_mage_aspects (which folds it in), and applied immediately if the config already exists — so
/// it's order-independent whether the class config lands before or after this call. Used by classes
/// (e.g. the Hedge Mage archetype) whose choice runs in outfit pre_equip; no addtimer race needed.
/datum/mind/proc/magi2_add_bonus_minor(amount = 1)
	magi2_bonus_minor += amount
	if(LAZYLEN(mage_aspect_config))
		mage_aspect_config["minor"] += amount

// ---- Utility-spell registry ----
// Paths offered in the picker's Utilities tab — the spec's utility roster. Mix of Magi 2
// datum spells + existing ES proc_holders. Spells read their budget cost from point_cost
// (datum) / cost (proc_holder); proc_holders carry their cost from the legacy learn system.
GLOBAL_LIST_INIT(utility_spells, list(
	// Magi 2 datum utilities
	/datum/action/cooldown/spell/light_magi2,
	/datum/action/cooldown/spell/mending_magi2,
	/datum/action/cooldown/spell/create_campfire_magi2,
	/datum/action/cooldown/spell/touch/rune_ward_magi2,
	// Existing ES proc_holder utilities
	/obj/effect/proc_holder/spell/self/message,
	/obj/effect/proc_holder/spell/invoked/mindlink,
	/obj/effect/proc_holder/spell/self/findfamiliar,
	/obj/effect/proc_holder/spell/targeted/touch/darkvision,
	/obj/effect/proc_holder/spell/targeted/touch/nondetection,
	/obj/effect/proc_holder/spell/invoked/projectile/fetch,
	/obj/effect/proc_holder/spell/invoked/projectile/repel,
	/obj/effect/proc_holder/spell/targeted/touch/lesserknock,
	/obj/effect/proc_holder/spell/self/magicians_brick,
	/obj/effect/proc_holder/spell/invoked/mirror_transform,
))

/// Turn a freshly-spawned human into a Magi 2 caster. Stores the class aspect config (which
/// grants the universal arcyne ward via ensure_mage_basics when config["ward"]), grants any
/// post-aspect freebie spells, and hands over a Grimoire (to pick/reshape aspects) plus a lesser
/// staff implement. The player chooses their starting loadout via the Grimoire's first-open
/// setup mode. Called from /datum/advclass/equipme() when mage_aspect_config is set.
/// grant_items: TRUE (advclass equipme path) → strip legacy gear and hand out a Grimoire + staff.
/// FALSE → caller's own class loadout already places the Grimoire/staff (e.g. via backpack_contents
/// and backr), so skip all item handling and only do the spell-side setup (config/ward/prestidig/
/// post_spells). Use FALSE whenever this is called deferred (addtimer) from an outfit pre_equip,
/// because the outfit's items aren't in GetAllContents yet when the timer fires — the dedup guards
/// below would miss them and grant duplicates.
/// grant_staff: TRUE → also hand a lesser implement staff (when grant_items is TRUE and no staff is
/// already present). FALSE → no staff, e.g. witches who cast with a magebag and herbs, not a staff.
/proc/_magi2_setup_caster(mob/living/carbon/human/H, list/config, list/post_spells, grant_items = TRUE, grant_staff = TRUE, staff_path = /obj/item/rogueweapon/woodstaff/implement_magi2)
	if(!istype(H) || !H.mind)
		return
	H.mind.setup_mage_aspects(config)
	// Every mage gets the basic Prestidigitation cantrip.
	if(!H.mind.has_spell(/obj/effect/proc_holder/spell/targeted/touch/prestidigitation))
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/touch/prestidigitation)
	for(var/spell_path in post_spells)
		if(!H.mind.has_spell(spell_path))
			H.mind.AddSpell(new spell_path)
	if(!grant_items)
		return
	// Strip legacy mage starting gear — the old spellbooks ("tome of the arcyne" / "tome in
	// waiting") and the amethyst focus are superseded by the aspect Grimoire. Only migrated
	// casters reach here (config set), so non-migrated classes keep their legacy gear.
	for(var/obj/item/legacy in H.GetAllContents())
		if(istype(legacy, /obj/item/book/spellbook) || istype(legacy, /obj/item/spellbook_unfinished) || istype(legacy, /obj/item/roguegem/amethyst))
			qdel(legacy)
	// Grimoire of Aspects — into the satchel (where the old tome lived). Skipped if the class
	// loadout already placed one (e.g. via backpack_contents) — the preferred delivery path.
	_magi2_give_grimoire(H)
	// Lesser staff implement — only for classes that don't already start with a staff. Premade-staff
	// classes (Court Magician's magos staff, Sorcerer's woodstaff) keep theirs, so no second staff.
	// grant_staff = FALSE for classes that shouldn't carry an implement (e.g. witches).
	if(grant_staff && !(locate(/obj/item/rogueweapon/woodstaff) in H.GetAllContents()))
		// Build in nullspace and place via put_in_hands; only drop at their feet as a last resort.
		// (Spawning straight onto get_turf() made an audible thud every spawn, and the old qdel
		// fallback silently destroyed the staff when hands were full.)
		var/obj/item/staff = new staff_path
		if(!H.put_in_hands(staff))
			staff.forceMove(get_turf(H))

/// Hands H a Grimoire of Aspects if they don't already have one, mirroring the outfit storage
/// cascade: back-left -> back-right -> belt -> hip slot -> a hand -> the floor. Used both by initial
/// caster setup and by re-bodying paths (e.g. lich phylactery) where the mind keeps its aspects but
/// the physical Grimoire was left on the old corpse.
/proc/_magi2_give_grimoire(mob/living/carbon/human/H)
	if(!istype(H))
		return
	if(locate(/obj/item/book/magi2_grimoire) in H.GetAllContents())
		return
	var/obj/item/book/magi2_grimoire/grim = new
	for(var/slot in list(SLOT_BACK_L, SLOT_BACK_R, SLOT_BELT))
		var/obj/item/storage = H.get_item_by_slot(slot)
		if(storage && SEND_SIGNAL(storage, COMSIG_TRY_STORAGE_INSERT, grim, null, TRUE, TRUE))
			return
	if(!H.equip_to_slot_if_possible(grim, ITEM_SLOT_HIP, disable_warning = TRUE) && !H.put_in_hands(grim))
		grim.forceMove(get_turf(H))
