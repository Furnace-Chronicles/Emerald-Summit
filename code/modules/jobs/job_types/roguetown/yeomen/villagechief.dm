/datum/job/roguetown/elder
	title = "Town Elder"
	flag = ELDER
	department_flag = YEOMEN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1

	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	disallowed_races = list(
		/datum/species/lamia,
	)
	allowed_ages = list(AGE_OLD)
	job_traits = list(TRAIT_PEASANTMILITIA, TRAIT_SEEPRICES_SHITTY, TRAIT_EMPATH)
	tutorial = "You are as venerable and ancient as the trees themselves, wise even for your years spent with the first Wardens. The people look up to you both as a teacher and a guide to solve lesser issues before violence is involved. Not everything must end in bloodshed, no matter how much the retinue wish it were the case. Lead your fellow townsfolk in these troubling times lest they incur wrath of the nobility with their ignorance."
	whitelist_req = TRUE
	outfit = /datum/outfit/job/roguetown/elder
	display_order = JDO_CHIEF
	min_pq = 2 //mentor role, not a high PQ requirement but not zero
	max_pq = null
	give_bank_account = 16
	round_contrib_points = 3
	social_rank = SOCIAL_RANK_YEOMAN

	cmode_music = 'sound/music/combat_old.ogg'//He is old so he gets old

/datum/outfit/job/roguetown/elder
	name = "Town Elder"
	jobtype = /datum/job/roguetown/elder

/datum/outfit/job/roguetown/elder/pre_equip(mob/living/carbon/human/H)
	..()
	if(H.mind)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/self/convertrole/militia)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/order/militia/retreat)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/order/militia/bolster)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/order/militia/charge)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/order/militia/forthetown)
		H.verbs |= list(/mob/living/carbon/human/proc/elder_announcement, /mob/living/carbon/human/mind/proc/setordersmilitia)
	cloak = /obj/item/clothing/cloak/stabard/guardhood/elder
	armor = /obj/item/clothing/suit/roguetown/armor/leather/vest/white
	pants = /obj/item/clothing/under/roguetown/tights//The idea is sort of that they just pick whichever colours correspond with the lord colours in round.
	shoes = /obj/item/clothing/shoes/roguetown/shortboots
	belt = /obj/item/storage/belt/rogue/leather
	beltr = /obj/item/rogueweapon/mace//Sign of status - he doesn't have the stats to actually use this in any meaningful way.
	beltl = /obj/item/flashlight/flare/torch/lantern
	backl = /obj/item/storage/backpack/rogue/satchel
	id = /obj/item/scomstone/bad//He is meant to be helping people around - hard to do when he can't hear their calls
	backpack_contents = list(/obj/item/storage/keyring/velder  = 1, /obj/item/rogueweapon/huntingknife/idagger/steel/special = 1, /obj/item/storage/belt/rogue/pouch/coins/rich = 1)
	H.adjust_skillrank(/datum/skill/combat/knives, 2, TRUE)
	H.adjust_skillrank(/datum/skill/combat/maces, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/polearms, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/wrestling, 2, TRUE)
	H.adjust_skillrank(/datum/skill/combat/unarmed, 3, TRUE)
	H.adjust_skillrank(/datum/skill/craft/crafting, 5, TRUE)
	H.adjust_skillrank(/datum/skill/craft/carpentry, 3, TRUE)
	H.adjust_skillrank(/datum/skill/craft/masonry, 3, TRUE)
	H.adjust_skillrank(/datum/skill/craft/engineering, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/sewing, 4, TRUE)
	H.adjust_skillrank(/datum/skill/misc/climbing, 3, TRUE)
	H.adjust_skillrank(/datum/skill/craft/alchemy, 2, TRUE)
	H.adjust_skillrank(/datum/skill/craft/tanning, 3, TRUE)
	H.adjust_skillrank(/datum/skill/labor/farming, 1, TRUE)
	H.adjust_skillrank(/datum/skill/misc/athletics, 1, TRUE)
	H.adjust_skillrank(/datum/skill/misc/reading, 4, TRUE)
	H.adjust_skillrank(/datum/skill/misc/swimming, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/medicine, 4, TRUE)
	H.adjust_skillrank(/datum/skill/misc/riding, 1, TRUE)
	H.adjust_skillrank(/datum/skill/misc/tracking, 3, TRUE)
	H.adjust_skillrank(/datum/skill/craft/cooking, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/ceramics, 3, TRUE)
	H.change_stat("perception", 2)
	H.change_stat("endurance", 2)
	H.change_stat("speed", -1)
	H.change_stat("constitution", 1)
	H.change_stat("intelligence", 3)
	if(should_wear_femme_clothes(H))//Village grandma look.
		head = /obj/item/clothing/head/roguetown/chaperon/greyscale/elder
		shirt = /obj/item/clothing/suit/roguetown/shirt/dress/silkdress
		backr = /obj/item/clothing/cloak/raincloak/furcloak
	else if(should_wear_masc_clothes(H))//Bailiff sort of look to it.
		head = /obj/item/clothing/head/roguetown/chaperon/greyscale/elder
		shirt = /obj/item/clothing/suit/roguetown/shirt/tunic
		gloves = /obj/item/clothing/gloves/roguetown/leather



GLOBAL_VAR_INIT(last_elder_announcement, -50000) // Inits variable for later, copied from guildmaster

/mob/living/carbon/human/proc/elder_announcement()
	set name = "Announcement"
	set category = "ELDER"
	if(stat)
		return
	var/announcementinput = input("Bellow to the Peaks", "Make an Announcement") as text|null
	if(announcementinput)
		if(!src.can_speak_vocal())
			to_chat(src,span_warning("I can't speak!"))
			return FALSE
		if(world.time < GLOB.last_elder_announcement + 600 SECONDS)
			to_chat(src, span_warning("You must wait [round((GLOB.last_elder_announcement + 600 SECONDS - world.time)/600, 0.1)] minutes before making another announcement!"))
			return FALSE
		visible_message(span_warning("[src] takes a deep breath, preparing to make an announcement.."))
		if(do_after(src, 15 SECONDS, target = src)) // Reduced to 15 seconds from 30 on the original Herald PR. 15 is well enough time for sm1 to shove you.
			say(announcementinput)
			priority_announce("[announcementinput]", "The Elder Speaks", 'sound/misc/bell.ogg', sender = src)
			GLOB.last_guildmaster_announcement = world.time
		else
			to_chat(src, span_warning("Your announcement was interrupted!"))
			return FALSE





/***************************************************************
 *  Militia Mechanics
 ***************************************************************/


/obj/effect/proc_holder/spell/self/convertrole/militia
	name = "Recruit Militia"
	new_role = "Town Militiaman"
	overlay_state = "recruit_brother"
	recruitment_faction = "Militia"
	recruitment_message = "Let's protect our town, %RECRUIT!"
	accept_message = "For the Reach!"
	refuse_message = "I refuse."

/obj/effect/proc_holder/spell/self/convertrole/militia/convert(mob/living/carbon/human/recruit, mob/living/carbon/human/recruiter)
	if(HAS_TRAIT(recruit, TRAIT_OUTLANDER))
		to_chat(recruiter, span_warning("You can't recruit foreigners to the militia!"))
		return FALSE
	if(HAS_TRAIT(recruit, TRAIT_NOBLE))
		to_chat(recruiter, span_warning("A noble in the militia?! Absurd!"))
		return FALSE
	if(HAS_TRAIT(recruit, TRAIT_GUARDSMAN))
		to_chat(recruiter, span_warning("They're already part of the guard! They can't join the militia!"))
		return FALSE
	if(HAS_TRAIT(recruit, TRAIT_INQUISITION))
		to_chat(recruiter, span_warning("Their loyalty is to Psydon alone! They can't join the militia!"))
		return FALSE
	//If you're reading this, please refactor this once we have TRAIT_CLERGY thanks
	if(recruit.job in list("Priest", "Priestess", "Templar", "Acolyte"))
		to_chat(recruiter, span_warning("Clergy cannot join the militia! Their loyalty is to the Ten!"))
		return FALSE
	..()






/***************************************************************
 *  MILITIA ORDER BOILERPLATE
 * Refactored the heck out of the code for giving orders, should backport to Sergeant and Deserter Knight once any kinks are worked out
 ***************************************************************/
/obj/effect/proc_holder/spell/invoked/order/militia/proc/can_order(mob/living/target, mob/living/user)
	if(target == user)
		to_chat(user, span_alert("I cannot order myself!"))
		return 0
	if(target.job != "Town Militiaman")
		to_chat(user, span_alert("I cannot order one not of the militia!"))
		return 0
	return 1


/obj/effect/proc_holder/spell/invoked/order/militia
    name = "Militia Order"
    var/effect_to_apply
    var/message_varname

/obj/effect/proc_holder/spell/invoked/order/militia/cast(list/targets, mob/living/user)
    . = ..()
    if(!isliving(targets[1]))
        revert_cast()
        return FALSE

    var/mob/living/target = targets[1]
    var/msg = user.mind.vars[message_varname]

    if(!msg)
        to_chat(user, span_alert("I must say something to give an order!"))
        return

    var/allowed = can_order(target, user)
    if(!allowed)
        return

    user.say("[msg]")
    target.apply_status_effect(effect_to_apply)
    on_success(user, target)
    return TRUE

/obj/effect/proc_holder/spell/invoked/order/militia/proc/on_success(mob/living/user, mob/living/target)
    return

/***************************************************************
 *  INDIVIDUAL MILITIA ORDERS
 ***************************************************************/

/obj/effect/proc_holder/spell/invoked/order/militia/retreat
    name = "Run away!"
    overlay_state = "retreat"
    effect_to_apply = /datum/status_effect/buff/order/militia/retreat
    message_varname = "retreattext"

/datum/status_effect/buff/order/militia/retreat
    id = "retreat"
    alert_type = /atom/movable/screen/alert/status_effect/buff/order/militia/retreat
    effectedstats = list(STATKEY_SPD = 3)
    duration = 30 SECONDS

/datum/status_effect/buff/order/militia/retreat/on_apply()
    . = ..()
    to_chat(owner, span_blue("The Elder orders me to run!"))

/atom/movable/screen/alert/status_effect/buff/order/militia/retreat
    name = "Run!!"
    desc = "The Elder has ordered me to retreat!"
    icon_state = "buff"

/***************************************************************/


/obj/effect/proc_holder/spell/invoked/order/militia/bolster
    name = "Hold the Line!"
    overlay_state = "bolster"
    effect_to_apply = /datum/status_effect/buff/order/militia/bolster
    message_varname = "bolstertext"

/datum/status_effect/buff/order/militia/bolster
    id = "bolster"
    alert_type = /atom/movable/screen/alert/status_effect/buff/order/militia/bolster
    effectedstats = list(STATKEY_CON = 3)
    duration = 1 MINUTES

/datum/status_effect/buff/order/militia/bolster/on_apply()
    . = ..()
    to_chat(owner, span_blue("The Elder orders me to hold the line!"))

/atom/movable/screen/alert/status_effect/buff/order/militia/bolster
    name = "Hold the Line!"
    desc = "The Elder inspires me to endure and last a little longer!"
    icon_state = "buff"

/***************************************************************/

/obj/effect/proc_holder/spell/invoked/order/militia/forthetown
    name = "For the Reach!"
    overlay_state = "forthetown"
    effect_to_apply = /datum/status_effect/buff/order/militia/forthetown
    message_varname = "onfeettext"

/obj/effect/proc_holder/spell/invoked/order/militia/forthetown/on_success(mob/living/user, mob/living/target)
    if(!(target.mobility_flags & MOBILITY_STAND))
        target.SetUnconscious(0)
        target.SetSleeping(0)
        target.SetParalyzed(0)
        target.SetImmobilized(0)
        target.SetStun(0)
        target.SetKnockdown(0)
        target.set_resting(FALSE)

/datum/status_effect/buff/order/militia/forthetown
    id = "forthetown"
    alert_type = /atom/movable/screen/alert/status_effect/buff/order/militia/forthetown
    duration = 15 SECONDS

/datum/status_effect/buff/order/militia/forthetown/on_apply()
    . = ..()
    to_chat(owner, span_blue("For the Reach!"))
    ADD_TRAIT(owner, TRAIT_NOPAIN, MAGIC_TRAIT)

/datum/status_effect/buff/order/militia/forthetown/on_remove()
    REMOVE_TRAIT(owner, TRAIT_NOPAIN, MAGIC_TRAIT)
    . = ..()

/atom/movable/screen/alert/status_effect/buff/order/militia/forthetown
    name = "Stand your Ground!"
    desc = "The Elder has ordered me to make a stand!"
    icon_state = "buff"

/***************************************************************/

/obj/effect/proc_holder/spell/invoked/order/militia/charge
    name = "Get 'em!"
    overlay_state = "charge"
    effect_to_apply = /datum/status_effect/buff/order/militia/charge
    message_varname = "chargetext"

/datum/status_effect/buff/order/militia/charge
    id = "charge"
    alert_type = /atom/movable/screen/alert/status_effect/buff/order/militia/charge
    effectedstats = list(STATKEY_STR = 2, STATKEY_LCK = 2)
    duration = 1 MINUTES

/datum/status_effect/buff/order/militia/charge/on_apply()
    . = ..()
    to_chat(owner, span_blue("The Elder orders me to charge! For the Reach!"))

/atom/movable/screen/alert/status_effect/buff/order/militia/charge
    name = "Charge!"
    desc = "Protect our homes!"
    icon_state = "buff"

/***************************************************************
 *  ORDER SETUP PROC
 ***************************************************************/

/mob/living/carbon/human/mind/proc/setordersmilitia()
    set name = "Rehearse Orders"
    set category = "Voice of Command"

    #define ORDER_INPUT(varname, prompt) \
        mind.varname = input("Send a message.", prompt) as text|null; \
        if(!mind.varname) { to_chat(src, "I must rehearse something for this order..."); return }

    ORDER_INPUT(retreattext, "Run away!!")
    ORDER_INPUT(chargetext, "Get 'em!!")
    ORDER_INPUT(bolstertext, "Hold the line!!")
    ORDER_INPUT(onfeettext, "For the Reach!!")

    #undef ORDER_INPUT
