// Magi 2 action-spell base — port of Azure-Peak code/modules/spells/spell_cooldown.dm (PR #6406)
// Adapter notes:
//  - Emerald Summit's /datum/action.UpdateButtonIcon(status_only, force) replaces Azure-Peak's
//    build_all_button_icons(flags) / build_button_icon / apply_button_background/icon/overlay.
//    Anywhere upstream calls build_all_button_icons() we call UpdateButtonIcon().
//  - Single .button member (not viewers[hud] list) — Emerald Summit doesn't have multi-HUD viewer support.
//  - click_to_activate / charge mechanics live in this subtype; the parent /datum/action/cooldown
//    in Emerald Summit doesn't implement them. This is intentional — we don't want to touch the
//    parent and risk regressions for the 22 existing /datum/action/cooldown subtypes.
//  - References to /datum/status_effect/buff/clash etc. resolve against existing
//    code/datums/status_effects/rogue/roguebuff.dm. Missing types (residual_focus, parry_buffer,
//    arcyne_momentum, recent_weapon) are stubbed in _compat_stubs.dm.
//
// NEXT SESSION TODO:
//  - Flesh out the charging input handlers (start_casting / try_casting / cast_after_charge)
//  - Test cast chain end-to-end with a Spitfire port
//  - Implement set_click_ability / unset_click_ability on /datum/action/cooldown/spell
//  - Wire signal cancel handlers (signal_cancel / signal_cancel_full) into actual movement / death signals

/datum/action/cooldown/spell
	name = "Spell"
	desc = "A wizard spell."
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_PHASED
	panel = "Spells"

	// Use Emerald Summit's existing spell button background ("bg_spell" in roguespells.dmi),
	// not Azure-Peak's "spell0". The two repos' roguespells.dmi files have diverged.
	// Backplate uses roguespells.dmi/"spell" (idle) and swaps to "spell1" (glowing)
	// when this spell is the active click intercept — see on_activation/on_deactivation
	// below. Matches the legacy proc_holder spell backplate set in
	// modular_azurepeak/code/modules/spells/spell_scroll_background.dm, giving every
	// spell in the game a consistent select-state cue.
	background_icon_state = "spell"
	button_icon = 'icons/mob/actions/roguespells.dmi'
	button_icon_state = "shieldsparkles"

	/// If TRUE, this spell uses click-to-activate (set as click intercept on click).
	/// If FALSE, Trigger fires immediately on the action.
	var/click_to_activate = TRUE
	/// If TRUE, the spell is automatically unset from the click intercept after a successful cast.
	var/unset_after_click = FALSE
	/// If FALSE (default), InterceptClickOn lets clicks on /obj/item targets pass through to
	/// normal item handling — picking up loose items, interacting with equipped/held items,
	/// etc. won't fire the spell at them. Set TRUE on spells that specifically target items
	/// (e.g. Fridigitation, which freezes food).
	var/targets_items = FALSE

	// ---- Resource costs ----
	/// Primary resource pool: SPELL_COST_*
	var/primary_resource_type = SPELL_COST_STAMINA
	var/primary_resource_cost = 0
	var/secondary_resource_type = SPELL_COST_NONE
	var/secondary_resource_cost = 0
	/// Cost to learn this spell when picked via Grimoire.
	var/point_cost = 0
	/// Whether this spell was chosen as a utility (counts against utility budget).
	var/utility_learned = FALSE
	/// Spell tier — 1/2/3/4. Major aspect mastery spells are usually tier 4.
	var/spell_tier = 1
	/// True for utility spells that require T2+ mage (have minor aspect access).
	var/requires_aspect_access = FALSE
	/// Visual intensity for on-hit impact, see SPELL_IMPACT_*.
	var/spell_impact_intensity = SPELL_IMPACT_NONE
	/// Whether this spell can be refunded out of the player's budget.
	var/refundable = FALSE
	/// The aspect type path that granted this spell. Used by the Grimoire for budget accounting.
	var/source_aspect
	/// Heretic-only spell (Zizo-aligned).
	var/zizo_spell = FALSE
	/// Damage shown in examine for non-projectile spells. Projectiles auto-display from projectile_type.
	var/displayed_damage = 0
	/// Parent-level devotion cost reference — only used by spells that drain devotion.
	var/devotion_cost = null

	// ---- Audio / VFX ----
	var/sound = 'sound/magic/whiteflame.ogg'
	var/list/invocations
	var/invocation_self_message
	var/invocation_type = INVOCATION_NONE
	var/ignore_can_speak = FALSE

	// ---- Flags ----
	var/spell_flags = NONE
	var/spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_SAME_Z
	var/antimagic_flags = MAGIC_RESISTANCE_HOLY

	// ---- Sparks / smoke ----
	var/sparks_amt = 0
	var/smoke_type
	var/smoke_amt = 0

	// ---- Required gear ----
	var/list/required_items

	// ---- Skill / stat scaling ----
	var/associated_skill = /datum/skill/magic/arcane
	var/associated_stat = STATKEY_INT

	// ---- Pointed-spell vars ----
	var/self_cast_possible = TRUE
	var/cast_range = 7
	var/aim_assist = TRUE

	// ---- Charge vars ----
	var/charge_required = TRUE
	var/currently_charging = FALSE
	var/charge_drain = 0
	var/charge_time = 0
	var/charge_slowdown = 0
	var/charge_message
	var/charge_sound = 'sound/magic/charging.ogg'
	var/sound/charge_sound_instance
	var/charge_started_at = 0
	/// Caster's turf at charge start; SPELL_REQUIRES_NO_MOVE spells cancel if they leave it.
	var/turf/charge_start_turf
	var/charge_target_time = 0
	var/charged = FALSE
	/// Set by charge_release() when a middle-mouse hold completed; tells before_cast to skip
	/// the do_after channel (the charge already happened on hold) and just clean up.
	var/hold_charged = FALSE
	/// Guards the one-shot "charge complete" cursor swap + sound in process().
	var/charge_ready_signaled = FALSE
	var/attunement_school
	var/weapon_cast_penalized = FALSE
	/// Transient flag set during Activate() when a weapon penalty is active for this cast.
	var/weapon_penalty_active = FALSE
	var/ignore_armor_penalty = FALSE
	var/charge_then_click = FALSE
	var/blocks_defense_while_channeling = FALSE

	// ---- Misc display ----
	var/fluff_desc = ""
	var/has_visual_effects = TRUE
	var/spell_color = "#FFFFFF"
	var/glow_intensity = 0
	var/obj/effect/mob_charge_effect
	var/obj/effect/dummy/lighting_obj/moblight/spell_glow_light
	var/auto_cancel_timer = null

/datum/action/cooldown/spell/New(Target)
	// Icon var-name remap: Azure-Peak uses `button_icon` for the FOREGROUND dmi file
	// (Spitfire sets it to mage_pyromancy.dmi). Emerald Summit's /datum/action uses
	// `button_icon` for the BACKGROUND and `icon_icon` for the foreground. We swap
	// them unconditionally — the parent's icon_icon default ('icons/mob/actions.dmi')
	// is not what Magi 2 spells want.
	icon_icon = button_icon
	button_icon = 'icons/mob/actions/roguespells.dmi'

	. = ..()
	// Reposition the cooldown maptext so it sits along the base of the icon
	// instead of the default bottom-left corner (set by /datum/action/cooldown/New()).
	button.maptext_x = 0
	button.maptext_y = 0
	button.maptext_width = 32
	button.maptext_height = 12
	// Widen the button's clickable hitbox without changing its visual size.
	// MOUSE_OPACITY_OPAQUE makes the full 32x32 icon area register clicks even on
	// transparent pixels. (We tried bound_width/bound_height for a bigger-than-32px
	// hitbox but those vars interfere with movement/click pathing on screen objects.)
	button.mouse_opacity = MOUSE_OPACITY_OPAQUE
	if(button_icon_state)
		var/obj/effect/R = new /obj/effect/spell_rune
		R.icon = icon_icon
		R.icon_state = button_icon_state
		mob_charge_effect = R
	if(!charge_required)
		return
	if(charge_time <= 0)
		stack_trace("Charging spell [src] ([type]) has no charge time")
		charge_required = FALSE
		return
	if(charge_sound)
		charge_sound_instance = sound(charge_sound)

/datum/action/cooldown/spell/Remove(mob/living/remove_from)
	if(remove_from?.click_intercept == src)
		remove_from.click_intercept = null
	return ..()

/datum/action/cooldown/spell/Destroy()
	QDEL_NULL(mob_charge_effect)
	QDEL_NULL(spell_glow_light)
	if(auto_cancel_timer)
		deltimer(auto_cancel_timer)
		auto_cancel_timer = null
	if(owner)
		if(currently_charging || charged)
			cancel_casting()
		if(owner.client)
			UnregisterSignal(owner.client, list(COMSIG_CLIENT_MOUSEDOWN, COMSIG_CLIENT_MOUSEUP))
	STOP_PROCESSING(SSfastprocess, src)
	charge_sound_instance = null
	return ..()

/datum/action/cooldown/spell/Grant(mob/grant_to)
	// Spell base assumes a living owner. Bail to a clean qdel on anything else.
	if(!isliving(grant_to))
		qdel(src)
		return

	if(istype(target, /datum/mind))
		var/datum/mind/mind_target = target
		if(mind_target.current != grant_to)
			return

	. = ..()

/datum/action/cooldown/spell/IsAvailable()
	. = ..()
	if(!.)
		return FALSE
	if(!can_cast_spell(feedback = FALSE))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/Trigger(trigger_flags, atom/target)
	if(!can_cast_spell())
		return FALSE
	// click_to_activate path: pressing the action button sets the spell as the mob's
	// click intercept; the player's next valid click routes through InterceptClickOn()
	// and triggers the actual cast at that target. Pressing the button again while the
	// spell is selected deselects it.
	if(click_to_activate)
		if(owner.click_intercept == src)
			to_chat(owner, span_notice("Cancelled [name]."))
			on_deactivation()
		else
			on_activation()
		return TRUE
	return ..(trigger_flags, target)

/// Routed by mob.ClickOn() → mob.check_click_intercept() when click_intercept == src.
/// Return semantics (per mob.check_click_intercept):
///   TRUE  — click is consumed, normal ClickOn handling is skipped
///   FALSE — click falls through to normal handling (move/attack/etc)
/// Declared as /proc/ (not an override) because /datum/action/cooldown's parent chain
/// has no InterceptClickOn — that proc lives on /obj/effect/proc_holder upstream.
/datum/action/cooldown/spell/proc/InterceptClickOn(mob/living/caller, params, atom/target)
	if(caller != owner)
		on_deactivation()
		return TRUE
	// Cast on MIDDLE-click only — matches the legacy /datum/intent/spell middle-mouse
	// convention. Left (and other) clicks fall through to normal handling so the player
	// can examine, pick up items, move, and attack while a spell stays armed.
	// ClickOn() runs check_click_intercept() for every button before its middle dispatch,
	// so the "middle" modifier is present here on middle-clicks.
	var/list/modifiers = params2list(params)
	if(!modifiers["middle"])
		return FALSE
	// Throw mode bypasses spells entirely — let the click route to normal throw
	// handling so the player can throw items while a spell is selected.
	if(caller.in_throw_mode)
		return FALSE
	// UI clicks (action buttons, intent panel, etc) fall through so the user can
	// re-click the action button to deselect, or operate other HUD elements.
	if(istype(target, /atom/movable/screen) && !istype(target, /atom/movable/screen/click_catcher))
		return FALSE
	// Item clicks (equipped, in-hand, or on the ground) fall through so the player
	// can pick up / interact with items without firing the selected spell at them.
	// Spells that legitimately target items (Fridigitation) set targets_items = TRUE.
	if(istype(target, /obj/item) && !targets_items)
		return FALSE
	// On cooldown — fall through so movement / attack / interact still work during
	// the cooldown window. Spell selection stays active for the next ready click.
	if(!IsAvailable())
		return FALSE
	// Charge-required spells are driven by the middle-mouse hold flow (charge_press/charge_release
	// in drag_drop.dm); the click itself must never instant-cast them.
	if(charge_required)
		return TRUE
	PreActivate(target)
	// Stay selected regardless of cast outcome so the user can chain-cast on multiple
	// targets without re-clicking the action button. Failed casts (out-of-range,
	// invalid target, etc.) also keep the selection for immediate retry.
	return TRUE

// Select-state cue: backplate swaps from "spell" (idle scroll) to "spell1"
// (glowing scroll) while this spell is the active click intercept. Replaces the
// earlier 5px button-lift cue — the scroll glow is more legible and matches the
// legacy proc_holder spell behavior set in spell_scroll_background.dm.

/datum/action/cooldown/spell/proc/on_activation()
	if(!owner)
		return
	// Bump any active proc_holder spell or other Magi 2 spell off the click intercept.
	if(owner.ranged_ability && owner.ranged_ability != src)
		owner.ranged_ability.deactivate(owner)
	// Selecting a spell also clears any mmb intent (kick/jump/bite/steal/give) and refreshes its HUD button.
	if(owner.mmb_intent)
		QDEL_NULL(owner.mmb_intent)
		if(owner.hud_used)
			owner.hud_used.quad_intents?.switch_intent(null)
			owner.hud_used.give_intent?.switch_intent(null)
	if(owner.click_intercept && owner.click_intercept != src)
		var/datum/old = owner.click_intercept
		if(istype(old, /datum/action/cooldown/spell))
			var/datum/action/cooldown/spell/old_spell = old
			old_spell.on_deactivation()
	owner.click_intercept = src
	background_icon_state = "spell1"
	UpdateButtonIcon()
	to_chat(owner, span_notice("Middle-click a target to cast [name]. Click [name] again to cancel."))

/datum/action/cooldown/spell/proc/on_deactivation()
	if(!owner)
		return
	if(currently_charging)
		cancel_casting()
	if(owner.click_intercept == src)
		owner.click_intercept = null
	background_icon_state = initial(background_icon_state)
	UpdateButtonIcon()

/// Required-state checks (consciousness, antimagic, spellblock, garb, weapon).
/// Returns FALSE and balloon-feedbacks the owner if blocked.
/datum/action/cooldown/spell/proc/can_cast_spell(feedback = TRUE)
	if(!owner)
		CRASH("[type] - can_cast_spell called on a spell without an owner!")

	if(!(spell_flags & SPELL_IGNORE_SPELLBLOCK) && HAS_TRAIT(owner, TRAIT_SPELLBLOCK))
		if(feedback)
			owner.balloon_alert(owner, "Can't focus on casting...")
		return FALSE

	if(HAS_TRAIT(owner, TRAIT_NOC_CURSE))
		if(feedback)
			owner.balloon_alert(owner, "My magicka has left me...")
		return FALSE

	// Already channeling another spell?
	for(var/datum/action/cooldown/spell/spell in owner.actions)
		if(spell == src)
			continue
		if(spell.currently_charging)
			if(feedback)
				owner.balloon_alert(owner, "Already channeling!")
			return FALSE

	if(!check_cost(feedback = feedback))
		return FALSE

	if((spell_requirements & SPELL_REQUIRES_MIND) && !owner.mind)
		return FALSE

	if((spell_requirements & SPELL_REQUIRES_NO_ANTIMAGIC) && owner.anti_magic_check())
		if(feedback)
			owner.balloon_alert(owner, "Antimagic is preventing casting!")
		return FALSE

	if(!can_invoke(feedback = feedback))
		return FALSE

	if((spell_requirements & SPELL_REQUIRES_HUMAN) && !ishuman(owner))
		if(feedback)
			owner.balloon_alert(owner, "Can only be cast by humans!")
		return FALSE

	if(LAZYLEN(required_items))
		var/found = FALSE
		for(var/obj/item/I in owner.contents)
			if(is_type_in_list(I, required_items))
				found = TRUE
				break
		if(!found)
			if(feedback)
				owner.balloon_alert(owner, "Missing something to cast!")
			return FALSE

	return TRUE

/datum/action/cooldown/spell/proc/can_invoke(feedback = TRUE)
	if(spell_requirements & SPELL_CASTABLE_WITHOUT_INVOCATION)
		return TRUE
	if(invocation_type == INVOCATION_NONE)
		return TRUE

	var/mob/living/living_owner = owner
	if(invocation_type == INVOCATION_EMOTE && HAS_TRAIT(living_owner, TRAIT_EMOTEMUTE))
		if(feedback)
			owner.balloon_alert(owner, "Can't position your hands correctly to invoke!")
		return FALSE
	if((invocation_type == INVOCATION_WHISPER || invocation_type == INVOCATION_SHOUT) && !ignore_can_speak && !living_owner.can_speak_vocal())
		if(feedback)
			owner.balloon_alert(owner, "Can't get the words out to invoke!")
		return FALSE
	return TRUE

/datum/action/cooldown/spell/proc/is_valid_target(atom/cast_on)
	if(click_to_activate && !self_cast_possible)
		if(cast_on == owner)
			owner.balloon_alert(owner, "Can't self cast!")
			return FALSE
	return TRUE

// ---- Cost / scaling ----

/datum/action/cooldown/spell/proc/get_caster_stat(mob/living/caster)
	if(!associated_stat)
		return SPELL_SCALING_THRESHOLD
	return caster.get_stat_level(associated_stat)

/datum/action/cooldown/spell/proc/get_stat_label()
	switch(associated_stat)
		if(STATKEY_STR)
			return "Strength"
		if(STATKEY_PER)
			return "Perception"
		if(STATKEY_INT)
			return "Intelligence"
		if(STATKEY_CON)
			return "Constitution"
		if(STATKEY_WIL)
			return "Willpower"
		if(STATKEY_SPD)
			return "Speed"
		if(STATKEY_LCK)
			return "Fortune"
	return "Intelligence"

/datum/action/cooldown/spell/proc/get_adjusted_cooldown()
	var/mob/living/living_owner = owner
	var/base = initial(cooldown_time)
	var/newcd = base

	var/stat_value = get_caster_stat(living_owner)
	if(stat_value > SPELL_SCALING_THRESHOLD)
		var/diff = min(stat_value, SPELL_POSITIVE_SCALING_THRESHOLD) - SPELL_SCALING_THRESHOLD
		newcd -= base * diff * COOLDOWN_REDUCTION_PER_INT
	else if(stat_value < SPELL_SCALING_THRESHOLD)
		var/diff = SPELL_SCALING_THRESHOLD - stat_value
		newcd += base * diff * COOLDOWN_REDUCTION_PER_INT

	newcd += base * get_armor_cd_multiplier(living_owner)

	if(weapon_penalty_active)
		newcd += base * WEAPON_CAST_PENALTY

	return newcd

/datum/action/cooldown/spell/proc/get_armor_cd_multiplier(mob/living/user)
	if(ignore_armor_penalty)
		return 0
	if(!user.check_armor_skill())
		return UNTRAINED_ARMOR_CD_PENALTY
	if(!ishuman(user))
		return 0
	var/mob/living/carbon/human/H = user
	var/ac = H.highest_ac_worn()
	if(ac == ARMOR_CLASS_HEAVY)
		return HEAVY_ARMOR_CD_PENALTY
	if(ac == ARMOR_CLASS_MEDIUM)
		return MEDIUM_ARMOR_CD_PENALTY
	return 0

/datum/action/cooldown/spell/proc/get_adjusted_cost(base_cost)
	if(base_cost <= 0)
		return 0
	var/mob/living/living_owner = owner
	var/new_cost = base_cost

	var/stat_value = get_caster_stat(living_owner)
	if(stat_value > SPELL_SCALING_THRESHOLD)
		var/diff = min(stat_value, SPELL_POSITIVE_SCALING_THRESHOLD) - SPELL_SCALING_THRESHOLD
		new_cost -= base_cost * diff * FATIGUE_REDUCTION_PER_INT
	else if(stat_value < SPELL_SCALING_THRESHOLD)
		var/diff = SPELL_SCALING_THRESHOLD - stat_value
		new_cost += base_cost * diff * FATIGUE_REDUCTION_PER_INT

	if(weapon_penalty_active)
		new_cost += base_cost * WEAPON_CAST_PENALTY

	return max(new_cost, 0.1)

/datum/action/cooldown/spell/proc/check_cost(feedback = TRUE)
	if(!check_resource_available(primary_resource_type, primary_resource_cost, feedback))
		return FALSE
	if(!check_resource_available(secondary_resource_type, secondary_resource_cost, feedback))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/proc/check_resource_available(resource_type, base_cost, feedback = TRUE)
	var/mob/living/caster = owner
	switch(resource_type)
		if(SPELL_COST_NONE)
			return TRUE
		if(SPELL_COST_STAMINA)
			var/used_cost = get_adjusted_cost(base_cost)
			if(used_cost <= 0)
				return TRUE
			if(caster.stamina + used_cost > caster.max_stamina)
				if(feedback)
					owner.balloon_alert(owner, "Too exhausted to cast!")
				return FALSE
			return TRUE
		if(SPELL_COST_ENERGY)
			var/used_cost = get_adjusted_cost(base_cost)
			if(used_cost <= 0)
				return TRUE
			if(caster.energy < used_cost)
				if(feedback)
					owner.balloon_alert(owner, "Not enough energy to cast!")
				return FALSE
			return TRUE
		if(SPELL_COST_DEVOTION)
			if(base_cost <= 0)
				return TRUE
			var/mob/living/carbon/human/H = caster
			if(!istype(H) || !H.devotion || H.devotion.devotion < base_cost)
				if(feedback)
					owner.balloon_alert(owner, "Devotion too weak!")
				return FALSE
			return TRUE
	return TRUE

/datum/action/cooldown/spell/proc/invoke_cost()
	if(!owner)
		return
	var/primary_spent = invoke_resource_cost(primary_resource_type, primary_resource_cost)
	var/secondary_spent = invoke_resource_cost(secondary_resource_type, secondary_resource_cost)
	var/refundable_total = 0
	if(primary_resource_type == SPELL_COST_STAMINA || primary_resource_type == SPELL_COST_ENERGY)
		refundable_total += (primary_spent || 0)
	if(secondary_resource_type == SPELL_COST_STAMINA || secondary_resource_type == SPELL_COST_ENERGY)
		refundable_total += (secondary_spent || 0)
	return refundable_total

/datum/action/cooldown/spell/proc/invoke_resource_cost(resource_type, base_cost)
	if(resource_type == SPELL_COST_NONE)
		return
	switch(resource_type)
		if(SPELL_COST_STAMINA)
			var/used_cost = get_adjusted_cost(base_cost)
			if(used_cost <= 0)
				return
			var/mob/living/caster = owner
			caster.stamina_add(used_cost)
			return used_cost
		if(SPELL_COST_ENERGY)
			var/used_cost = get_adjusted_cost(base_cost)
			if(used_cost <= 0)
				return
			var/mob/living/caster = owner
			caster.energy_add(-used_cost)
			return used_cost
		if(SPELL_COST_DEVOTION)
			if(base_cost <= 0)
				return
			var/mob/living/carbon/human/H = owner
			if(!istype(H))
				return
			H.devotion?.update_devotion(-base_cost)
			return base_cost

// ---- Invocation ----

/datum/action/cooldown/spell/proc/invocation(mob/living/invoker)
	if(!invocations)
		return
	if(istext(invocations))
		invocations = list(invocations)
	if(!islist(invocations) || !length(invocations))
		return

	var/chosen_invocation = pick(invocations)
	var/list/invocation_list = list(chosen_invocation, invocation_type)
	SEND_SIGNAL(invoker, COMSIG_MOB_PRE_INVOCATION, src, invocation_list)
	var/used_invocation_message = invocation_list[INVOCATION_MESSAGE]
	var/used_invocation_type = invocation_list[INVOCATION_TYPE]

	switch(used_invocation_type)
		if(INVOCATION_SHOUT)
			invoker.say(used_invocation_message, forced = "spell ([src])", language = /datum/language/common)
		if(INVOCATION_WHISPER)
			invoker.whisper(used_invocation_message, forced = "spell ([src])", language = /datum/language/common)
		if(INVOCATION_EMOTE)
			invoker.visible_message(
				capitalize(replacetext(used_invocation_message, "%CASTER", invoker.name)),
				capitalize(replacetext(invocation_self_message, "%CASTER", invoker.name)),
			)

/datum/action/cooldown/spell/proc/spell_feedback(mob/living/invoker)
	if(!invoker)
		return
	invocation(invoker)
	if(sound)
		playsound(owner, sound, 60, TRUE)

// ---- Weapon penalty check ----

/datum/action/cooldown/spell/proc/check_weapon_in_hand()
	if(!weapon_cast_penalized)
		return FALSE
	if(!ishuman(owner))
		return FALSE
	var/mob/living/carbon/human/H = owner
	for(var/obj/item/held in list(H.get_active_held_item(), H.get_inactive_held_item()))
		if(istype(held, /obj/item/gun))
			return TRUE
		if(!istype(held, /obj/item/rogueweapon))
			continue
		if(istype(held, /obj/item/rogueweapon/shield))
			continue
		var/obj/item/rogueweapon/W = held
		if(W.implement_refund)
			continue
		return TRUE
	if(H.has_status_effect(/datum/status_effect/recent_weapon))
		return TRUE
	return FALSE

// ---- Cast chain ----
//
// TODO[next session]: charge input (start_casting/try_casting/cast_after_charge mouse-signal flow)
// is the largest piece of unported logic. It depends on COMSIG_CLIENT_MOUSEDOWN/UP plumbing
// which Emerald Summit's old action system doesn't proxy through the action class.
// For the pilot, charge_required spells fall back to do_after() (handled in before_cast).

/datum/action/cooldown/spell/PreActivate(atom/target)
	charged = FALSE
	if(owner?.channeling_spell == src)
		owner.channeling_spell = null
	if(!is_valid_target(target))
		if(charge_required && click_to_activate)
			to_chat(owner, span_warning("I can't cast [src] on [target]!"))
		return FALSE
	return Activate(target)

/datum/action/cooldown/spell/Activate(atom/target)
	SHOULD_NOT_OVERRIDE(TRUE)

	var/precast_result = before_cast(target)
	if(precast_result & SPELL_CANCEL_CAST)
		if(charge_required)
			cancel_casting()
		return FALSE

	if(!check_cost())
		return FALSE

	weapon_penalty_active = check_weapon_in_hand()
	if(weapon_penalty_active)
		if(ishuman(owner))
			var/mob/living/carbon/human/wpn_check = owner
			var/has_weapon_now = FALSE
			for(var/obj/item/held in list(wpn_check.get_active_held_item(), wpn_check.get_inactive_held_item()))
				if(istype(held, /obj/item/gun) || (istype(held, /obj/item/rogueweapon) && !istype(held, /obj/item/rogueweapon/shield)))
					has_weapon_now = TRUE
					break
			if(has_weapon_now)
				to_chat(owner, span_warning("Holding a weapon interferes with my arcyne conduits! This spell is more exhausting than usual."))
			else
				to_chat(owner, span_warning("My hands still tingle from holding a weapon - my arcyne conduits are disrupted! This spell is more exhausting than usual."))

	if(owner.mob_timers[MT_INVISIBILITY] > world.time)
		owner.mob_timers[MT_INVISIBILITY] = world.time
		owner.update_sneak_invis(reset = TRUE)
	if(isliving(owner))
		var/mob/living/L = owner
		if(L.rogue_sneaking)
			L.mob_timers[MT_FOUNDSNEAK] = world.time
			L.update_sneak_invis(reset = TRUE)

	var/cast_result = cast(target)

	if(cast_result == FALSE)
		weapon_penalty_active = FALSE
		UpdateButtonIcon()
		return FALSE

	if(!(precast_result & SPELL_NO_FEEDBACK))
		spell_feedback(owner)

	if(!(precast_result & SPELL_NO_IMMEDIATE_COOLDOWN))
		StartCooldown(get_adjusted_cooldown())

	var/spent = 0
	if(!(precast_result & SPELL_NO_IMMEDIATE_COST))
		spent = invoke_cost()

	apply_residual_focus(spent)

	weapon_penalty_active = FALSE
	after_cast(target)
	UpdateButtonIcon()
	return TRUE

/datum/action/cooldown/spell/proc/before_cast(atom/cast_on)
	SHOULD_CALL_PARENT(TRUE)

	var/sig_return = SEND_SIGNAL(src, COMSIG_SPELL_BEFORE_CAST, cast_on)
	if(owner)
		sig_return |= SEND_SIGNAL(owner, COMSIG_MOB_BEFORE_SPELL_CAST, src, cast_on)

	if(click_to_activate)
		if(sig_return & SPELL_CANCEL_CAST)
			return sig_return

		if(spell_requirements & SPELL_REQUIRES_SAME_Z)
			var/turf/caster_t = get_turf(owner)
			var/turf/target_t = get_turf(cast_on)
			if(caster_t && target_t && caster_t.z != target_t.z)
				to_chat(owner, span_warning("I can't reach that from here!"))
				return sig_return | SPELL_CANCEL_CAST

		if(get_dist(owner, cast_on) > cast_range)
			owner.balloon_alert(owner, "Too far away!")
			return sig_return | SPELL_CANCEL_CAST

		if((primary_resource_type == SPELL_COST_DEVOTION) && HAS_TRAIT(cast_on, TRAIT_ATHEISM_CURSE))
			if(isliving(cast_on))
				var/mob/living/L = cast_on
				L.visible_message(
					span_danger("[L] recoils in disgust!"),
					span_userdanger("These fools are trying to cure me with religion!!")
				)
			return sig_return | SPELL_CANCEL_CAST

		if((primary_resource_type == SPELL_COST_DEVOTION) && HAS_TRAIT(cast_on, TRAIT_PSYDONITE) && !(spell_flags & SPELL_PSYDON))
			cast_on.visible_message(span_info("[cast_on] stirs for a moment, the miracle dissipates."), span_notice("A dull warmth swells in your heart, only to fade as quickly as it arrived."))
			playsound(cast_on, 'sound/magic/PSY.ogg', 100, FALSE, -1)
			owner.playsound_local(owner, 'sound/magic/PSY.ogg', 100, FALSE, -1)
			return sig_return | SPELL_CANCEL_CAST

	// Charge phase runs for both click-to-target and facing-direction spells. Upstream
	// has a separate hold-mouse-to-charge path for click_to_activate; we use do_after
	// uniformly because Emerald Summit's older action HUD doesn't proxy mouse events
	// through the action datum the way Azure-Peak's modern HUD does.
	if(charge_required)
		if(hold_charged)
			// Charge already completed via middle-mouse hold (charge_press/charge_release).
			// Tear down the charge state started in charge_press, then fall through to cast.
			hold_charged = FALSE
			end_charging()
		else
			var/require_no_move = (spell_requirements & SPELL_REQUIRES_NO_MOVE)
			on_start_charge()
			var/success = TRUE
			if(!do_after(owner, charge_target_time, needhand = FALSE, extra_checks = CALLBACK(src, PROC_REF(do_after_checks), owner, cast_on), no_interrupt = !require_no_move))
				success = FALSE
				sig_return |= SPELL_CANCEL_CAST
			if(currently_charging)
				on_end_charge(success)

	return sig_return

/datum/action/cooldown/spell/proc/do_after_checks(mob/owner, atom/cast_on)
	if(!currently_charging)
		return FALSE
	if(!can_cast_spell(TRUE))
		return FALSE
	if(!is_valid_target(cast_on))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/proc/cast(atom/cast_on)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_SPELL_CAST, cast_on)
	record_featured_object_stat(FEATURED_STATS_SPELLS, name)
	if(owner)
		SEND_SIGNAL(owner, COMSIG_MOB_CAST_SPELL, src, cast_on)
		if(owner.ckey)
			owner.log_message("cast the spell [name][cast_on != owner ? " on / at [key_name_admin(cast_on)]":""].", LOG_ATTACK)
			if(cast_on != owner)
				cast_on.log_message("affected by spell [name] by [key_name_admin(owner)].", LOG_ATTACK)

/datum/action/cooldown/spell/proc/after_cast(atom/cast_on)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_SPELL_AFTER_CAST, cast_on)
	if(!owner)
		return
	SEND_SIGNAL(owner, COMSIG_MOB_AFTER_SPELL_CAST, src, cast_on)

	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		if(H.has_status_effect(/datum/status_effect/buff/clash))
			H.bad_guard(span_warning("I can't focus while casting spells!"), cheesy = TRUE)

	if(sparks_amt)
		do_sparks(sparks_amt, FALSE, get_turf(owner))

	if(ispath(smoke_type, /datum/effect_system/smoke_spread))
		var/datum/effect_system/smoke_spread/smoke = new smoke_type()
		smoke.set_up(smoke_amt, loca = get_turf(owner))
		smoke.start()

	if(mob_charge_effect)
		owner.vis_contents -= mob_charge_effect

	if(spell_glow_light)
		QDEL_NULL(spell_glow_light)

	if(has_visual_effects)
		var/mob/living/living_owner = owner
		living_owner.finish_spell_visual_effects(spell_color)

	if(owner.client)
		owner.client.mouse_pointer_icon = 'icons/effects/mousemice/human.dmi'

// ---- Charge state ----

/// Effective charge time after arcane-skill reduction (mirrors the legacy spell get_chargetime()).
/datum/action/cooldown/spell/proc/get_charge_time()
	. = charge_time
	if(!isliving(owner) || charge_time <= 0)
		return
	var/mob/living/caster = owner
	. = max(charge_time - (charge_time * (caster.get_skill_level(associated_skill) * MAGI2_CHARGE_REDUCTION_PER_SKILL)), 0)

/datum/action/cooldown/spell/proc/on_start_charge()
	currently_charging = TRUE
	charge_started_at = world.time
	charge_start_turf = get_turf(owner)
	charge_target_time = get_charge_time()
	charge_ready_signaled = FALSE
	if(owner)
		owner.tempfixeye = TRUE
		if(!owner.fixedeye)
			owner.nodirchange = TRUE
		owner.channeling_spell = src
	START_PROCESSING(SSfastprocess, src)
	UpdateButtonIcon(status_only = TRUE)

	if(charge_slowdown)
		owner.add_movespeed_modifier(MOVESPEED_ID_SPELL_CASTING, override = TRUE, multiplicative_slowdown = charge_slowdown)

	if(charge_sound_instance)
		playsound(owner, charge_sound_instance, 50, FALSE, channel = CHANNEL_CHARGED_SPELL)

	if(mob_charge_effect)
		owner.vis_contents += mob_charge_effect

	if(glow_intensity && spell_color && isliving(owner))
		var/mob/living/L = owner
		spell_glow_light = L.mob_light(spell_color, glow_intensity)

	if(has_visual_effects)
		var/mob/living/caster = owner
		caster.start_spell_visual_effects(spell_color)

	if(owner.client)
		owner.client.mouse_pointer_icon = SSmousecharge.access(0)

	if(charge_message)
		owner.balloon_alert(owner, charge_message)

	if(spell_requirements & SPELL_REQUIRES_NO_MOVE)
		owner.balloon_alert(owner, "Be still while channelling...")

/datum/action/cooldown/spell/proc/on_end_charge(success)
	if(owner)
		owner.tempfixeye = FALSE
		if(!owner.fixedeye)
			owner.nodirchange = FALSE
	end_charging()
	. = success
	if(success)
		charged = TRUE
		return
	if(owner)
		owner.balloon_alert(owner, "Channeling was interrupted!")

/datum/action/cooldown/spell/proc/end_charging()
	currently_charging = FALSE
	charge_started_at = null
	charge_start_turf = null
	charge_target_time = null
	charge_ready_signaled = FALSE
	if(owner?.channeling_spell == src && !charged)
		owner.channeling_spell = null
	STOP_PROCESSING(SSfastprocess, src)
	UpdateButtonIcon(status_only = TRUE)

	if(!owner)
		return

	if(charge_slowdown)
		owner.remove_movespeed_modifier(MOVESPEED_ID_SPELL_CASTING)

	// Kill the charge loop sound. playsound() above broadcast it positionally on CHANNEL_CHARGED_SPELL,
	// so stop it for the caster (stop_sound_channel) AND for nearby listeners (null sound on the channel).
	// Without this the audio plays for its full file length even after the (often shorter) charge ends.
	if(charge_sound_instance)
		owner.stop_sound_channel(CHANNEL_CHARGED_SPELL)
		playsound(owner, sound(null, repeat = 0), 50, FALSE, channel = CHANNEL_CHARGED_SPELL)

	if(mob_charge_effect)
		owner.vis_contents -= mob_charge_effect

	if(spell_glow_light)
		QDEL_NULL(spell_glow_light)

	if(has_visual_effects)
		var/mob/living/caster = owner
		caster.cancel_spell_visual_effects()

	if(owner.client)
		owner.client.mouse_pointer_icon = 'icons/effects/mousemice/human.dmi'

/datum/action/cooldown/spell/proc/cancel_casting()
	if(QDELETED(src))
		return
	if(auto_cancel_timer)
		deltimer(auto_cancel_timer)
		auto_cancel_timer = null
	charged = FALSE
	hold_charged = FALSE
	end_charging()

// ---- Hold-to-charge (middle-mouse down/up) ----
// Combat spells charge while middle-mouse is held and fire on release. Driven by the client
// MouseDown/MouseUp handlers (handle_middle_click / MouseUp in drag_drop.dm). This is the real
// hold-mouse path; the do_after channel in before_cast remains the fallback for facing-direction
// (non-click) casts that never route through here.

/// Middle-mouse pressed while this spell is the armed click intercept: begin charging.
/datum/action/cooldown/spell/proc/charge_press()
	if(currently_charging || charged || hold_charged)
		return
	if(!IsAvailable())
		return
	on_start_charge()

/// Middle-mouse released: cast if held the full charge_time on a valid target, else cancel.
/datum/action/cooldown/spell/proc/charge_release(atom/target)
	if(!currently_charging)
		return
	if(!isatom(target) || istype(target, /atom/movable/screen))
		cancel_casting()
		return
	if((world.time - charge_started_at) < charge_target_time)
		cancel_casting()
		if(owner)
			owner.balloon_alert(owner, "Released too soon!")
		return
	hold_charged = TRUE
	PreActivate(target)

/datum/action/cooldown/spell/proc/reset_spell_cooldown()
	SEND_SIGNAL(src, COMSIG_SPELL_CAST_RESET)
	next_use_time -= cooldown_time
	UpdateButtonIcon()

// ---- Residual focus / implement refund — STUBBED ----
// Implement_refund on rogueweapons defaults to 0, so apply_residual_focus is a no-op
// for all existing weapons. Real handling lands when Magi 2 wand/staff items port.

/datum/action/cooldown/spell/proc/get_held_implement(mob/user)
	if(!ishuman(user))
		return null
	var/mob/living/carbon/human/H = user
	var/obj/item/rogueweapon/best
	for(var/obj/item/held in list(H.get_active_held_item(), H.get_inactive_held_item()))
		if(!istype(held, /obj/item/rogueweapon))
			continue
		var/obj/item/rogueweapon/W = held
		if(W.implement_refund > (best ? best.implement_refund : 0))
			best = W
	return best

/datum/action/cooldown/spell/proc/apply_residual_focus(refundable_spent)
	if(refundable_spent <= 0)
		return
	var/obj/item/rogueweapon/implement = get_held_implement(owner)
	if(!implement?.implement_refund)
		return
	if(!isliving(owner))
		return
	var/pool = refundable_spent * implement.implement_refund
	if(pool <= 0)
		return
	var/mob/living/L = owner
	L.apply_status_effect(/datum/status_effect/buff/residual_focus, pool)

// ---- Optional alt-mode hook (Ctrl+G) ----
/datum/action/cooldown/spell/proc/toggle_alt_mode(mob/user)
	return FALSE

/// Override of /datum/action/cooldown.StartCooldown that:
///  - accepts an optional override_time (parent ignores it, so passing get_adjusted_cooldown()
///    upstream silently dropped INT/armor scaling)
///  - routes the countdown text through button.update_maptext(), which lives on a
///    separate maptext_holder at ABOVE_HUD_LAYER (in front of the spell overlay icon)
///    and animates the per-decisecond countdown itself — no need for per-tick updates.
/datum/action/cooldown/spell/StartCooldown(override_time)
	var/real_time = isnum(override_time) ? override_time : cooldown_time
	next_use_time = world.time + real_time
	button.maptext = "" // clear any stale baseline text
	button.update_maptext(real_time)
	START_PROCESSING(SSfastprocess, src)

/datum/action/cooldown/spell/process()
	if(!currently_charging)
		// The cooldown text animates itself through maptext_holder. We only need to
		// clear the red "unavailable" tint once the spell is castable again.
		if(!owner)
			STOP_PROCESSING(SSfastprocess, src)
			return
		if(next_use_time <= world.time)
			// Cooldown elapsed — refresh the button's status colour (cheap, no overlay rebuild).
			// IsAvailable() also gates on can_cast_spell()/check_cost(), so stamina-cost spells
			// frequently aren't castable the instant the cooldown ends. Keep ticking until the
			// spell is genuinely available so the red clears on its own; stopping unconditionally
			// here left the icon stuck red (off-cooldown but still tinted) until some unrelated
			// action re-rendered it.
			UpdateButtonIcon(status_only = TRUE)
			if(IsAvailable())
				STOP_PROCESSING(SSfastprocess, src)
		return
	if(!owner)
		return PROCESS_KILL
	if(!can_cast_spell(TRUE))
		cancel_casting()
		return PROCESS_KILL
	// No-move spells (e.g. Mending) cancel the charge if the caster steps off their starting tile.
	if((spell_requirements & SPELL_REQUIRES_NO_MOVE) && get_turf(owner) != charge_start_turf)
		owner.balloon_alert(owner, "I moved!")
		cancel_casting()
		return PROCESS_KILL
	// Charging cursor: fill toward the goal each tick, then swap to the "charged" cursor and
	// play the completion cue once charge_time is reached (mirrors the legacy SSmousecharge spell cursor).
	if(owner.client && charge_target_time > 0)
		var/charge_pct = min(((world.time - charge_started_at) / charge_target_time) * 100, 100)
		if(charge_pct >= 100)
			owner.client.mouse_pointer_icon = 'icons/effects/mousemice/swang/acharged.dmi'
			if(!charge_ready_signaled)
				charge_ready_signaled = TRUE
				playsound(owner, 'sound/magic/charged.ogg', 100, TRUE)
		else
			owner.client.mouse_pointer_icon = SSmousecharge.access(charge_pct)
	if(charge_drain)
		if(primary_resource_type == SPELL_COST_STAMINA && iscarbon(owner))
			var/mob/living/carbon/C = owner
			if(C.stamina >= C.max_stamina)
				owner.balloon_alert(owner, "Too exhausted to channel!")
				cancel_casting()
				return PROCESS_KILL
		if(!check_resource_available(primary_resource_type, charge_drain))
			owner.balloon_alert(owner, "I cannot uphold the channeling!")
			cancel_casting()
			return PROCESS_KILL
		invoke_resource_cost(primary_resource_type, charge_drain)
