/datum/job/roguetown/lady
	title = "Consort"
	flag = LADY
	department_flag = NOBLEMEN
	faction = "Station"
	total_positions = 0
	spawn_positions = 0

	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_NOBILITY_ELIGIBLE_UP
	allowed_patrons = NON_PSYDON_PATRONS
	tutorial = "Picked out of your political value rather than likely any form of love, you have become the Grand Duke's most trusted confidant--and likely friend--throughout your marriage. Your loyalty and perhaps even your love will be tested this day... for the daggers that threaten your beloved are as equally pointed at your own throat."

	spells = list(/obj/effect/proc_holder/spell/self/convertrole/servant,
	/obj/effect/proc_holder/spell/self/grant_nobility)
	outfit = /datum/outfit/job/roguetown/lady

	display_order = JDO_LADY
	give_bank_account = 50
	noble_income = 22
	min_pq = 0 //temporary for testing
	max_pq = null
	round_contrib_points = 3

/datum/job/roguetown/exlady
	title = "Consort Dowager"
	flag = LADY
	department_flag = NOBLEMEN
	faction = "Station"
	total_positions = 0
	spawn_positions = 0
	display_order = JDO_LADY
	give_bank_account = TRUE

/datum/job/roguetown/consort/after_spawn(mob/living/H, mob/M, latejoin)
	. = ..()
	if(ishuman(H))
		var/mob/living/carbon/human/Q = H
		Q.advsetup = 1
		Q.invisibility = INVISIBILITY_MAXIMUM
		Q.become_blind("advsetup")

/datum/outfit/job/roguetown/lady
	job_bitflag = BITFLAG_ROYALTY

/datum/outfit/job/roguetown/lady/pre_equip(mob/living/carbon/human/H) // the pre-equip is gender neutral
	. = ..()
	ADD_TRAIT(H, TRAIT_SEEPRICES, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_NOBLE, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_NUTCRACKER, TRAIT_GENERIC)
	beltl = /obj/item/storage/keyring/royal
	beltr = /obj/item/storage/belt/rogue/pouch/coins/rich
	belt = /obj/item/storage/belt/rogue/leather/plaquegold
	head = /obj/item/clothing/head/roguetown/nyle/consortcrown
	id = /obj/item/scomstone/garrison
	shoes = /obj/item/clothing/shoes/roguetown/boots/nobleboot
	backr = /obj/item/storage/backpack/rogue/satchel
	if(H.wear_mask)
		if(istype(H.wear_mask, /obj/item/clothing/mask/rogue/eyepatch))
			qdel(H.wear_mask)
			mask = /obj/item/clothing/mask/rogue/lordmask
		if(istype(H.wear_mask, /obj/item/clothing/mask/rogue/eyepatch/left))
			qdel(H.wear_mask)
			mask = /obj/item/clothing/mask/rogue/lordmask/l

/datum/advclass/consort/Socialite
	name = "Socialite"
	tutorial = "You were once an envoy of a noble house. Your classy charm and grace have won you the race to the bed of the throne warmer. You now spend your days by your spouse's side, helping their reign whenever possible. "
	outfit = /datum/outfit/job/roguetown/lady/Socialite
	category_tags = list(CTAG_CONSORT)

/datum/outfit/job/roguetown/lady/Socialite/pre_equip(mob/living/carbon/human/H)
	..()
	if(should_wear_femme_clothes(H))
		armor = /obj/item/clothing/suit/roguetown/shirt/dress/royal //no pants, your spouse has to have easy access
		wrists = /obj/item/clothing/wrists/roguetown/royalsleeves
		cloak = /obj/item/clothing/cloak/lordcloak/ladycloak
		backl = /obj/item/rogue/instrument/harp
	if(should_wear_masc_clothes(H))
		armor = /obj/item/clothing/suit/roguetown/shirt/tunic/noblecoat
		shirt = /obj/item/clothing/suit/roguetown/shirt/dress/royal/prince
		pants = /obj/item/clothing/under/roguetown/tights
		backl = /obj/item/rogue/instrument/lute
	H.adjust_skillrank(/datum/skill/misc/music, 5, TRUE) //identical skills to the envoy suitor
	H.adjust_skillrank(/datum/skill/misc/swimming, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/climbing, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/reading, 4, TRUE)
	H.adjust_skillrank(/datum/skill/misc/medicine, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/riding, 2, TRUE)
	H.adjust_skillrank(/datum/skill/craft/crafting, 2, TRUE)
	H.adjust_skillrank(/datum/skill/craft/cooking, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/sewing, 3, TRUE)
	H.change_stat("intelligence", 3) //identical stats to the envoy suitor, except +5 fortune instead of +1
	H.change_stat("perception", 3)
	H.change_stat("endurance", 1)
	H.change_stat("speed", 1)
	H.change_stat("fortune", 5)

/datum/advclass/consort/Plotter
	name = "Plotter"
	tutorial = "You were once a schemer for a noble house. Your cunning and guile have won you the race to the bed of the throne warmer. Your life has only just started getting interesting. You now spend your days plotting to aid the interests of both you and your spouse. You'd never betray your spouse, right? Perhaps your spouse could use a break..."
	outfit = /datum/outfit/job/roguetown/lady/Plotter
	category_tags = list(CTAG_CONSORT)

/datum/outfit/job/roguetown/lady/Plotter/pre_equip(mob/living/carbon/human/H)
	..()
	if(should_wear_femme_clothes(H))
		armor = /obj/item/clothing/suit/roguetown/armor/leather/vest/winterjacket
		shirt = /obj/item/clothing/suit/roguetown/armor/armordress/winterdress/monarch
	if(should_wear_masc_clothes(H))
		armor = /obj/item/clothing/suit/roguetown/armor/longcoat
		shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/lord
		pants = /obj/item/clothing/under/roguetown/tights/black
	backpack_contents = list(/obj/item/reagent_containers/glass/bottle/rogue/poison = 1, /obj/item/lockpick = 1, /obj/item/rogueweapon/huntingknife/idagger/steel = 1)
	H.adjust_skillrank(/datum/skill/combat/knives, 3, TRUE) //identical skills to the schemer suitor
	H.adjust_skillrank(/datum/skill/combat/wrestling, 1, TRUE)
	H.adjust_skillrank(/datum/skill/combat/unarmed, 1, TRUE)
	H.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/climbing, 4, TRUE)
	H.adjust_skillrank(/datum/skill/misc/reading, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/sneaking, 4, TRUE)
	H.adjust_skillrank(/datum/skill/misc/stealing, 4, TRUE)
	H.adjust_skillrank(/datum/skill/misc/lockpicking, 3, TRUE)
	H.adjust_skillrank(/datum/skill/craft/traps, 3, TRUE)
	H.adjust_skillrank(/datum/skill/craft/alchemy, 3, TRUE)
	H.change_stat("intelligence", 1) //identical stats to the schemer suitor except +5 fortune instead of +1
	H.change_stat("perception", 1)
	H.change_stat("endurance", 1)
	H.change_stat("speed", 3)
	H.change_stat("fortune", 5)

/datum/advclass/consort/gallavanter
	name = "Gallavanter"
	tutorial = "You were once a gallant for a noble house. Your bravado and skill with a blade have won you the race to the bed of the throne warmer. You now spend your days by your spouse's side, hoping they're attacked more often so you can heroically save them like in the fairy tales, but there's much less action than you'd prefer."
	outfit = /datum/outfit/job/roguetown/lady/Gallavanter
	category_tags = list(CTAG_CONSORT)
/datum/outfit/job/roguetown/lady/Gallavanter/pre_equip(mob/living/carbon/human/H)
	..()
	pants = /obj/item/clothing/under/roguetown/tights/black
	armor = /obj/item/clothing/suit/roguetown/armor/plate/fluted
	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail
	gloves = /obj/item/clothing/gloves/roguetown/plate
	backl = /obj/item/rogueweapon/sword/long
	H.adjust_skillrank(/datum/skill/combat/wrestling, 2, TRUE)
	H.adjust_skillrank(/datum/skill/combat/unarmed, 2, TRUE)
	H.adjust_skillrank(/datum/skill/combat/swords, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/knives, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/swimming, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/climbing, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/reading, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/riding, 3, TRUE)
	H.change_stat("strength", 1)
	H.change_stat("intelligence", 2)
	H.change_stat("perception", 1)
	H.change_stat("constutition", 1)
	H.change_stat("endurance", 1)
	H.change_stat("speed", 1)
	H.change_stat("fortune", 5)
	ADD_TRAIT(H, TRAIT_MEDIUMARMOR, TRAIT_GENERIC)

/obj/effect/proc_holder/spell/self/convertrole/servant
	name = "Recruit Servant"
	new_role = "Servant"
	overlay_state = "recruit_servant"
	recruitment_faction = "Servants"
	recruitment_message = "Serve the crown, %RECRUIT!"
	accept_message = "FOR THE CROWN!"
	refuse_message = "I refuse."
	recharge_time = 100
