// Staff implements — two-handed mage weapons that grant residual focus when held during a cast.
// Three tiers with increasing refund and durability. Inherits from the existing ES wooden staff,
// so all the normal staff melee mechanics work.

/obj/item/rogueweapon/woodstaff/implement_magi2
	base_implement_name = "lesser staff"
	name = "lesser staff"
	desc = "A mage's staff fitted with a lesser focus-gem. The gem captures excess energy dissipated \
		into the air when a spell is cast, giving a fraction of it back to the wielder."
	icon = 'icons/obj/items/staffs.dmi'
	icon_state = "topazstaff"
	implement_tier = IMPLEMENT_TIER_LESSER
	implement_refund = IMPLEMENT_REFUND_LESSER
	resistance_flags = FIRE_PROOF
	max_integrity = 150
	sellprice = 34

/obj/item/rogueweapon/woodstaff/implement_magi2/greater
	base_implement_name = "greater staff"
	name = "greater staff"
	desc = "A mage's staff crowned with a quality focus-gem. The gem captures excess energy \
		dissipated into the air when a spell is cast, giving a generous share of it back to the wielder."
	icon_state = "emeraldstaff"
	implement_tier = IMPLEMENT_TIER_GREATER
	implement_refund = IMPLEMENT_REFUND_GREATER
	max_integrity = 200
	sellprice = 42

/obj/item/rogueweapon/woodstaff/implement_magi2/grand
	base_implement_name = "grand staff"
	name = "grand staff"
	desc = "A masterwork staff set with a gem of extraordinary quality. The gem captures excess \
		energy dissipated into the air when a spell is cast, giving most of it back to the wielder \
		— arcyne economy refined to an art."
	icon = 'modular_azurepeak/icons/obj/items/staffs.dmi' // Court Magos staff model
	icon_state = "courtstaff"
	implement_tier = IMPLEMENT_TIER_GRAND
	implement_refund = IMPLEMENT_REFUND_GRAND
	max_integrity = 250
	sellprice = 121

// Court Magician's grand staff — keeps its classic name, but as a grand implement it
// attunes to "Staff of the Court Magos of <school>" on cast. Scoped as its own subtype so
// the generic "grand staff" (crafting) is unaffected.
/obj/item/rogueweapon/woodstaff/implement_magi2/grand/court_magos
	base_implement_name = "\improper Staff of the Court Magos"
	name = "\improper Staff of the Court Magos"

// Heartfelt Magos — same grand-staff model, distinct name; attunes to
// "The Staff of the Heartfelt Magos of <school>" on cast.
/obj/item/rogueweapon/woodstaff/implement_magi2/grand/heartfelt_magos
	base_implement_name = "\improper The Staff of the Heartfelt Magos"
	name = "\improper The Staff of the Heartfelt Magos"

// Archmagos of Heartfelt — the lord's grand staff; attunes to
// "The Staff of the Archmagos of <school>" on cast.
/obj/item/rogueweapon/woodstaff/implement_magi2/grand/archmagos
	base_implement_name = "\improper The Staff of the Archmagos"
	name = "\improper The Staff of the Archmagos"

/obj/item/rogueweapon/woodstaff/implement_magi2/examine(mob/user)
	. = ..()
	if(implement_refund)
		. += span_notice("When held while casting, this implement leaves behind Residual Focus, returning [round(implement_refund * 100)]% of the spell's resource cost as energy over 20 seconds.")

// The Warscholar's themed naledian warstaff functions as a greater implement.
// Defined here (not in magic_staffs.dm) so the IMPLEMENT_* macros are in scope.
// base_implement_name lets it attune to "Naledian Warstaff of <school>" on cast, alongside
// the refund + elemental glow. \improper keeps the proper-noun capitalization intact.
/obj/item/rogueweapon/woodstaff/naledi
	name = "\improper Naledian Warstaff"
	base_implement_name = "\improper Naledian Warstaff"
	implement_tier = IMPLEMENT_TIER_GREATER
	implement_refund = IMPLEMENT_REFUND_GREATER

/obj/item/rogueweapon/woodstaff/naledi/examine(mob/user)
	. = ..()
	if(implement_refund)
		. += span_notice("When held while casting, this implement leaves behind Residual Focus, returning [round(implement_refund * 100)]% of the spell's resource cost as energy over 20 seconds.")
