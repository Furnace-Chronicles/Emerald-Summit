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
	icon_state = "diamondstaff"
	implement_tier = IMPLEMENT_TIER_GRAND
	implement_refund = IMPLEMENT_REFUND_GRAND
	max_integrity = 250
	sellprice = 121

/obj/item/rogueweapon/woodstaff/implement_magi2/examine(mob/user)
	. = ..()
	if(implement_refund)
		. += span_notice("When held while casting, this implement leaves behind Residual Focus, returning [round(implement_refund * 100)]% of the spell's resource cost as energy over 20 seconds.")
