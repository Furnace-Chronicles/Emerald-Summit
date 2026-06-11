// Magi 2 projectile spell base — port of Azure-Peak code/modules/spells/spell_cooldown_projectile.dm
// Adapter notes:
//  - update_arc_maptext() iterates over the modern action HUD's `viewers` list, which Emerald
//    Summit doesn't have. We replace it with a balloon_alert on toggle so the user gets feedback
//    but the action button itself doesn't sprout an ARC overlay.
//  - The COMSIG_PROJECTILE_SELF_ON_HIT signal isn't wired up in Emerald Summit projectiles
//    (existing magic projectiles override on_hit directly), so we skip the signal RegisterSignal.
//    Subtype spells that need a hit callback should override on_hit on their projectile.
//  - attune_implement() lives on rogueweapon in Azure-Peak (gem-attuned implements). Emerald
//    Summit doesn't have implements yet — call is guarded with a typecheck so it no-ops.

/datum/action/cooldown/spell/projectile
	self_cast_possible = FALSE
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC

	/// What projectile we create when we shoot our spell.
	var/obj/projectile/projectile_type = /obj/projectile/magic/teleport
	/// Optional arc mode projectile variant. If set, spell supports arc mode toggle.
	var/obj/projectile/projectile_type_arc
	/// How many projectiles we fire per cast. Each gets ready_projectile() called with an iteration index.
	var/projectiles_per_fire = 1
	/// Whether this spell is currently set to fire in arc mode.
	var/arc_mode = FALSE

/datum/action/cooldown/spell/projectile/cast(atom/cast_on)
	. = ..()
	if(!isturf(owner.loc))
		return FALSE

	var/atom/target = cast_on
	// For non-click spells (click_to_activate = FALSE) resolve target in the caster's facing direction.
	// MVP Spitfire uses this path — no click intercept system yet.
	if(!click_to_activate)
		target = get_ranged_target_turf(owner, owner.dir, cast_range)

	fire_projectile(target)
	return TRUE

/datum/action/cooldown/spell/projectile/proc/fire_projectile(atom/target)
	for(var/i in 1 to projectiles_per_fire)
		var/active_type = (arc_mode && projectile_type_arc) ? projectile_type_arc : projectile_type
		var/obj/projectile/to_fire = new active_type(owner.loc)
		ready_projectile(to_fire, target, owner, i)
		to_fire.fire()
	return TRUE

/// Configure the projectile before firing. Override for spell-specific setup (spread angles, etc).
/datum/action/cooldown/spell/projectile/proc/ready_projectile(obj/projectile/to_fire, atom/target, mob/user, iteration)
	to_fire.firer = user
	to_fire.fired_from = get_turf(user)
	to_fire.def_zone = user.zone_selected

	// Accuracy from INT and skill, matching the old proc_holder system
	if(isliving(user))
		var/mob/living/L = user
		to_fire.accuracy += (L.STAINT - 9) * 4
		to_fire.bonus_accuracy += (L.STAINT - 8) * 3
		if(L.mind)
			to_fire.bonus_accuracy += (L.get_skill_level(associated_skill) * 5)

	// Pick up the elemental glow on any held implement matching this spell's school.
	if(attunement_school && ishuman(user))
		var/obj/item/rogueweapon/best_implement = get_held_implement(user)
		best_implement?.attune_implement(spell_color, attunement_school)

	to_fire.preparePixelProjectile(target, user)

/// Toggle arc mode. Feedback via both a balloon alert AND a chat line — balloon_alert is gated
/// behind the FLOATING_TEXT client pref, so the to_chat is the reliable confirmation (matches the
/// battle_ward toggle). Real ARC indicator on the action button needs the modern HUD viewers
/// system which we don't have here.
/datum/action/cooldown/spell/projectile/toggle_alt_mode(mob/user)
	if(!projectile_type_arc)
		to_chat(user, span_warning("[name] cannot be arced."))
		return FALSE
	arc_mode = !arc_mode
	user.balloon_alert(user, "[name]: arc [arc_mode ? "ON" : "OFF"]")
	to_chat(user, span_notice("[name]: arc mode [arc_mode ? "enabled" : "disabled"]."))
	return TRUE

// Magic-projectile impact visual (ported from Azure-Peak PR #6666). Kept in the magi2 layer rather
// than core code/modules/projectiles/projectile/magic.dm because the SPELL_IMPACT_* defines live in
// magi2/_defines.dm, which compiles after core. Reopening the core type from here is fine in DM and
// gives every magic projectile a scaled on-hit flash; subtypes that override on_hit reach it via ..().
/obj/projectile/magic
	/// Impact visual intensity on hit. SPELL_IMPACT_NONE / LOW / MEDIUM / HIGH.
	var/spell_impact_intensity = SPELL_IMPACT_LOW
	/// Override color for the impact effect. If null, uses light_color, then white.
	var/spell_impact_color

/obj/projectile/magic/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(spell_impact_intensity > SPELL_IMPACT_NONE)
		var/impact_color = spell_impact_color || light_color || "#FFFFFF"
		new /obj/effect/temp_visual/spell_impact(get_turf(target), impact_color, spell_impact_intensity)
