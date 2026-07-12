// Psydonias first clerical ward. This shall be the Bathoan equivalent of a ''armor rite'' its farely good. By no means darksteel but heavy plate classes can access this.
// By layering this under a full suit of steel you'll pretty much get to that darksteel status of durablity.
// Should likely migrate this all to it's own area in clerical magic. But. It really depends on magi2 stuff under the hood so idk.
// I'd love to make this stronger under the hope that people will use it to fight ''sexy'' but I know powergamers to well. WE have to account for people using this with a full set of steel.
// Perhaps a code solution? Could add a second spell given to anyone with MEDIUM or HEAVY armor traits.
#define BATHYHIDE_FILTER "bathyhide_glow"

/datum/status_effect/buff/bathyhide
	id = "glimmerhide"
	alert_type = /atom/movable/screen/alert/status_effect/buff/bathyhide
	duration = -1
	var/outline_colour = CLOTHING_MAGENTA // of course

/atom/movable/screen/alert/status_effect/buff/bathyhide
	name = "Glimmer Hide"
	desc = "A glimmering dust of temptation hardens my skin when impacted."

/datum/status_effect/buff/bathyhide/on_apply()
	. = ..()
	if(!owner.get_filter(BATHYHIDE_FILTER))
		owner.add_filter(BATHYHIDE_FILTER, 2, list("type" = "outline", "color" = outline_colour, "alpha" = 60, "size" = 2)) //extremely noticeable at a glance. I hope.

/datum/status_effect/buff/bathyhide/on_remove()
	. = ..()
	owner.remove_filter(BATHYHIDE_FILTER)
//we are gonna start farely low with all of this and nothing to overkill or godlike. Do slight buffs if I feel them needed.
/datum/action/cooldown/spell/conjure_arcyne_ward_magi2/bathyhide
	name = "Conjure Glimmerhide Clerical Ward"
	desc = "Conjure a glimmerhide ward - an clerical ward hardened with reactive dust. \
		More protective then the usual arcyne ward \
		350 integrity. A Brigandine with higher piercing protection. Otherwise functions as a standard arcyne ward - yields coverage to real armor when summoned, does not regenerate. \
		Cast again to dismiss. Cooldown begins when dismissed or destroyed."
	button_icon = 'icons/mob/actions/mage_conjure.dmi'
	button_icon_state = "conjure_aegis" //custom sprites are soonTM. (so likely wont happen for awhile or ever)
	spell_color = CLOTHING_MAGENTA
	invocations = list("Purple flame! Protect my form!") //placeholders ngl. Please if you got better phrases change these.
	associated_skill = /datum/skill/magic/holy //should slighly diswayed the waves of randoms seeking this. Be a real cleric or eat your entire stamina bar to use it.
	ward_type = /obj/item/clothing/suit/roguetown/armor/arcyne_ward_magi2/bathyhide
	dismiss_invocation = "Purple flame! Dismiss!"

/obj/item/clothing/suit/roguetown/armor/arcyne_ward_magi2/bathyhide
	name = "glimmerhide ward"
	desc = "An arcyne ward hardened with draconic scales. Resistant to flame."
	armor = ARMOR_BATHYHIDE
	max_integrity = 350
	ward_examine_phrase = "wrapped in a glimmering clerical ward of unholy purple dust. The mark of BAOTHA! Clings to their back" //super vaild on examin. Intended.

/obj/item/clothing/suit/roguetown/armor/arcyne_ward_magi2/bathyhide/setup_ward(mob/living/carbon/human/H)
	..()
	H.apply_status_effect(/datum/status_effect/buff/bathyhide)

/obj/item/clothing/suit/roguetown/armor/arcyne_ward_magi2/bathyhide/cleanup_ward()
	if(ward_owner)
		ward_owner.remove_status_effect(/datum/status_effect/buff/bathyhide)
	..()

#undef BATHYHIDE_FILTER
