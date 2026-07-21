#define ARMORID "armor-[blunt]-[slash]-[stab]-[piercing]-[fire]-[acid]-[magic]"

/proc/getArmor(blunt = 0, slash = 0, stab = 0, piercing = 0, fire = 0, acid = 0, magic = 0)
	. = locate(ARMORID)
	if (!.)
		. = new /datum/armor(blunt, slash, stab, piercing, fire, acid, magic)

/datum/armor
	datum_flags = DF_USE_TAG
	/// better defined as area pressure melee
	var/blunt
	/// better defined as line pressure melee
	var/slash
	/// better defined as point pressure melee
	var/stab
	/// basically projectiles
	var/piercing
	/// protection against burning
	var/fire
	/// protection against pools of acid
	var/acid
	/// protection against magical attacks (make this adjustable via rune enchantments or something)
	var/magic

/datum/armor/New(blunt = 0, slash = 0, stab = 0, piercing = 0, fire = 0, acid = 0, magic = 0)
	src.blunt = blunt
	src.slash = slash
	src.stab = stab
	src.piercing = piercing
	src.fire = fire
	src.acid = acid
	src.magic = magic
	tag = ARMORID

/datum/armor/proc/modifyRating(blunt = 0, slash = 0, stab = 0, piercing = 0, fire = 0, acid = 0, magic = 0)
	return getArmor(src.blunt+blunt, src.slash+slash, src.stab+stab, src.piercing+piercing,src.fire+fire, src.acid+acid, src.magic+magic)

/datum/armor/proc/modifyAllRatings(modifier = 0)
	return getArmor(blunt+modifier, slash+modifier, stab+modifier, piercing+modifier,fire+modifier, acid+modifier, magic+modifier)

//TODO! PORT BLACKSTONE BLUNT/SLASH/STAB ARMOR DEFINES!!!!!!
/datum/armor/proc/multiplymodifyAllRatings(modifier = 0)
	return getArmor(blunt*modifier, slash*modifier, stab*modifier, piercing*modifier, fire*modifier, acid*modifier, magic*modifier)

/datum/armor/proc/setRating(blunt, slash, stab, piercing, fire, acid, magic)
	return getArmor((isnull(blunt) ? src.blunt : blunt),\
					(isnull(slash) ? src.slash : slash),\
					(isnull(stab) ? src.stab : stab),\
					(isnull(piercing) ? src.piercing : piercing),\
					(isnull(fire) ? src.fire : fire),\
					(isnull(acid) ? src.acid : acid),\
					(isnull(magic) ? src.magic : magic))

/datum/armor/proc/getRating(rating)
	return vars[rating]

/datum/armor/proc/getList()
	return list("blunt" = blunt, "slash" = slash, "stab" = stab, "piercing" = piercing, "fire" = fire, "acid" = acid, "magic" = magic)

/datum/armor/proc/attachArmor(datum/armor/AA)
	return getArmor(blunt+AA.blunt, slash+AA.slash, stab+AA.stab, piercing+AA.piercing, fire+AA.fire, acid+AA.acid, magic+AA.magic)

/datum/armor/proc/detachArmor(datum/armor/AA)
	return getArmor(blunt-AA.blunt, slash-AA.slash, stab-AA.stab, piercing-AA.piercing, fire-AA.fire, acid-AA.acid, magic-AA.magic)

/datum/armor/vv_edit_var(var_name, var_value)
	if (var_name == NAMEOF(src, tag))
		return FALSE
	. = ..()
	tag = ARMORID // update tag in case armor values were edited

#undef ARMORID

/*------------------------\
|     TIER READOUTS       |
\------------------------*/
// The two armor families use different scales, so a bare number can't be named without
// knowing its damage type. slash/stab/piercing are DBLOCK (0-4); blunt/fire/acid are DR (0-5).

/proc/armor_tier_name(tier, d_type)
	if(isnull(tier))
		tier = 0
	if(d_type in ARMOR_DBLOCK_TYPES)
		switch(tier)
			if(-INFINITY to DBLOCK_NONE)
				return "None"
			if(DBLOCK_LIGHT)
				return "Light"
			if(DBLOCK_MEDIUM)
				return "Medium"
			if(DBLOCK_HEAVY)
				return "Heavy"
			if(DBLOCK_BSTEEL to INFINITY)
				return "Bsteel"
	switch(tier)
		if(-INFINITY to DR_NONE)
			return "None"
		if(DR_LIGHT)
			return "Light"
		if(DR_MEDIUM)
			return "Medium"
		if(DR_HEAVY)
			return "Heavy"
		if(DR_SUPER)
			return "Super"
		if(DR_ULTRA to INFINITY)
			return "Ultra"

// Weapon penetration shares the DBLOCK scale (0-4) so the two can be compared directly.
// Clamps rather than erroring: BLUNT_DEFAULT_PENFACTOR is -100, which reads as None (correctly -
// it can never meet any tier).
/proc/pen_tier_name(tier)
	return armor_tier_name(tier, "stab")
