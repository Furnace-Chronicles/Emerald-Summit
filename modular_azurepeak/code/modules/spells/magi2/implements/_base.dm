// Spell Implement system — staves and wands grant a fraction of the spell's
// resource cost back as energy over 20s (via /datum/status_effect/buff/residual_focus),
// and pick up an elemental glow when their school's spell is cast.
//
// Adds vars and helpers to /obj/item/rogueweapon since the upstream pattern is to mark
// ANY weapon as an implement via implement_tier > 0. Most weapons keep the defaults
// (tier 0, no refund) and behave unchanged.

#define IMPLEMENT_GLOW_FILTER "implement_attunement"
#define IMPLEMENT_ATTUNE_COOLDOWN (1 MINUTES)

/obj/item/rogueweapon
	/// Current elemental glow color picked up from the last attuning spell, if any.
	var/attuned_color = null
	/// Used to rename "<base> of <school>" when attuned. Null means no rename.
	var/base_implement_name = null
	/// 0 = not an implement. 1/2/3 = lesser/greater/grand.
	var/implement_tier = 0
	// implement_refund (0..1) is declared in _compat_stubs.dm because spell_cooldown.dm
	// reads it from any rogueweapon to compute residual-focus pool size.
	COOLDOWN_DECLARE(attunement_cd)

/// Stamp an implement with a spell's color. No-op on non-implements (tier 0) and during
/// the 1-minute cooldown so the glow doesn't flicker mid-fight.
/obj/item/rogueweapon/proc/attune_implement(spell_color, spell_name)
	if(!implement_tier)
		return
	apply_attunement_glow(src, spell_color, implement_tier, spell_name)

/proc/apply_attunement_glow(obj/item/rogueweapon/implement, spell_color, implement_tier, spell_name)
	if(implement.attuned_color == spell_color)
		return
	if(!COOLDOWN_FINISHED(implement, attunement_cd))
		return
	COOLDOWN_START(implement, attunement_cd, IMPLEMENT_ATTUNE_COOLDOWN)
	implement.attuned_color = spell_color
	if(spell_name && implement.base_implement_name)
		implement.name = "[implement.base_implement_name] of [spell_name]"
	var/glow_alpha
	switch(implement_tier)
		if(IMPLEMENT_TIER_LESSER)
			glow_alpha = 80
		if(IMPLEMENT_TIER_GREATER)
			glow_alpha = 120
		if(IMPLEMENT_TIER_GRAND)
			glow_alpha = 155
		else
			glow_alpha = 80
	implement.remove_filter(IMPLEMENT_GLOW_FILTER)
	implement.add_filter(IMPLEMENT_GLOW_FILTER, 2, list("type" = "outline", "color" = spell_color, "alpha" = glow_alpha, "size" = 1))

#undef IMPLEMENT_GLOW_FILTER
#undef IMPLEMENT_ATTUNE_COOLDOWN
