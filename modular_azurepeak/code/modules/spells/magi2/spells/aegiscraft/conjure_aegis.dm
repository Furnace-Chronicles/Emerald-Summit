// Conjure Aegis — Aegiscraft conjuration. Summons an arcyne shield into the
// caster's hand: 200 integrity, 9 wdef, 70 coverage. Tuned against projectiles,
// poor against melee. Channeling locks out parry/dodge.
// Port of Azure-Peak conjure/conjure_aegis.dm.

/datum/action/cooldown/spell/conjure_aegis_magi2
	name = "Conjure Aegis"
	desc = "Conjure an Arcyne Aegis — a projected shield of arcyne energy designed to counter projectiles. \
		Less effective against deliberate melee strikes, but excellent against ranged attacks. \
		The shield vanishes when broken or when a new one is conjured. \
		While channeling this spell, I cannot parry or dodge — my focus is entirely on the conjuration."
	button_icon = 'icons/mob/actions/mage_conjure.dmi'
	button_icon_state = "conjure_aegis"
	sound = 'sound/magic/whiteflame.ogg'
	spell_color = GLOW_COLOR_ARCANE
	glow_intensity = GLOW_INTENSITY_MEDIUM

	click_to_activate = TRUE
	self_cast_possible = TRUE

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_CONJURE

	invocations = list("Clipeum Arcanum!")
	invocation_type = INVOCATION_SHOUT

	charge_required = TRUE
	charge_time = 3 SECONDS
	charge_drain = 1
	charge_slowdown = CHARGING_SLOWDOWN_HEAVY
	charge_sound = 'sound/magic/charging.ogg'
	cooldown_time = 90 SECONDS
	blocks_defense_while_channeling = TRUE

	associated_skill = /datum/skill/combat/shields
	spell_tier = 2
	spell_impact_intensity = SPELL_IMPACT_NONE
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_SAME_Z

	var/obj/item/rogueweapon/shield/arcyne_aegis_magi2/conjured_shield

/datum/action/cooldown/spell/conjure_aegis_magi2/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE
	if(H.get_num_arms() <= 0)
		to_chat(H, span_warning("I don't have any usable hands!"))
		return FALSE

	if(conjured_shield && !QDELETED(conjured_shield))
		conjured_shield.visible_message(span_warning("[conjured_shield] flickers and fades away!"))
		qdel(conjured_shield)

	var/obj/item/rogueweapon/shield/arcyne_aegis_magi2/S = new(H.drop_location())
	S.linked_spell = src
	S.caster_ref = WEAKREF(H)
	H.put_in_hands(S)
	conjured_shield = S
	H.visible_message(span_warning("[H] conjures a shimmering shield of arcyne energy!"))
	return TRUE

/datum/action/cooldown/spell/conjure_aegis_magi2/Destroy()
	if(conjured_shield && !QDELETED(conjured_shield))
		conjured_shield.visible_message(span_warning("[conjured_shield] flickers and fades away!"))
		qdel(conjured_shield)
	conjured_shield = null
	return ..()

// ============================================================================
// The conjured shield. Upstream uses /datum/component/conjured_item for the
// outline + craft-blocking; we inline that minimal behavior here so we don't
// drag in the upstream component (Magi 2 is the only consumer in ES today).
// ============================================================================

/obj/item/rogueweapon/shield/arcyne_aegis_magi2
	name = "arcyne aegis"
	desc = "A rare hunk of arcyne energy projected in front of the caster. Slower and more deliberate \
		movement by blades and melee weapons easily pierce through to the squishy Magi behind."
	icon = 'icons/roguetown/weapons/shields32.dmi'
	icon_state = "psyshield"
	wdefense = 9
	coverage = 70
	max_integrity = 200
	force = 5
	anvilrepair = /datum/skill/magic/arcane
	parrysound = list(
		'sound/combat/parry/shield/magicshield (1).ogg',
		'sound/combat/parry/shield/magicshield (2).ogg',
		'sound/combat/parry/shield/magicshield (3).ogg',
	)
	associated_skill = /datum/skill/combat/shields
	smeltresult = null
	salvage_result = null
	fiber_salvage = FALSE
	craft_blocked = TRUE

	var/datum/action/cooldown/spell/conjure_aegis_magi2/linked_spell
	var/datum/weakref/caster_ref

/obj/item/rogueweapon/shield/arcyne_aegis_magi2/Initialize()
	. = ..()
	filters += filter(type = "drop_shadow", x = 0, y = 0, size = 1, offset = 2, color = GLOW_COLOR_ARCANE)

/obj/item/rogueweapon/shield/arcyne_aegis_magi2/examine(mob/user)
	. = ..()
	. += span_info("This item crackles with faint arcyne energy. It seems to be conjured.")

/obj/item/rogueweapon/shield/arcyne_aegis_magi2/obj_break(damage_flag)
	. = ..()
	if(!QDELETED(src))
		dispel()

/obj/item/rogueweapon/shield/arcyne_aegis_magi2/attack_hand(mob/living/user)
	. = ..()
	if(!QDELETED(src) && !(user.get_active_held_item() == src || user.get_inactive_held_item() == src))
		dispel()

/obj/item/rogueweapon/shield/arcyne_aegis_magi2/dropped(mob/living/user)
	. = ..()
	if(QDELETED(src))
		return
	var/mob/caster = caster_ref?.resolve()
	if(!caster || loc != caster)
		dispel()

/obj/item/rogueweapon/shield/arcyne_aegis_magi2/proc/dispel()
	if(QDELETED(src))
		return
	visible_message(span_warning("[src] shatters into motes of arcyne light!"))
	playsound(get_turf(src), 'sound/magic/magic_nulled.ogg', 80)
	if(linked_spell)
		linked_spell.conjured_shield = null
	qdel(src)
