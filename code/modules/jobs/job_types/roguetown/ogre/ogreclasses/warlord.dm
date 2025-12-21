/datum/advclass/ogre/warlord
	name = "Warlord" 
	tutorial = "A great war horn sounds from the bog land, the call of war from a monster of noble blood."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = /datum/species/ogre
	outfit = /datum/outfit/job/roguetown/ogre/warlord
	category_tags = list(CTAG_OGRE)
	cmode_music = 'sound/music/combat_highgrain.ogg'

	traits_applied = list(TRAIT_BASHDOORS, TRAIT_STEELHEARTED, TRAIT_CRITICAL_RESISTANCE, TRAIT_NOPAINSTUN, TRAIT_CALTROPIMMUNE, TRAIT_STRONGBITE, TRAIT_MEDIUMARMOR) //strongbite might be funny
	subclass_stats = list( 
		STATKEY_STR = 3, 
		STATKEY_CON = 4,
		STATKEY_END = 3,
	)

	subclass_skills = list(
		/datum/skill/combat/maces = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/polearms = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/swords = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/axes = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/wrestling = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/knives = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/unarmed = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/athletics = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/climbing = SKILL_LEVEL_APPRENTICE,
	) 

/datum/outfit/job/roguetown/ogre/warlord/pre_equip(mob/living/carbon/human/H)
	..()
	if(H.mind)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/self/convertrole/warlord)
		to_chat(H, span_warning("A great war horn sounds from the bog land, the call of war from a monster of noble blood."))
		shoes = /obj/item/clothing/shoes/roguetown/armor/ogre
		shirt = /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk/ogre
		neck = /obj/item/clothing/neck/roguetown/gorget/ogre
		pants = /obj/item/clothing/under/roguetown/chainlegs/ogre
		head = /obj/item/clothing/head/roguetown/helmet/heavy/ogre
		gloves = /obj/item/clothing/gloves/roguetown/plate/ogre
		wrists = /obj/item/clothing/wrists/roguetown/bracers/ogre
		belt = /obj/item/storage/belt/rogue/leather/ogre
		armor = /obj/item/clothing/suit/roguetown/armor/plate/half/ogre
		beltr = /obj/item/rogueweapon/huntingknife/cleaver/ogre
		backr = /obj/item/storage/backpack/rogue/satchel
		backpack_contents = list(
			/obj/item/rogueweapon/mace/cudgel/ogre = 1,
			/obj/item/rope/chain = 1,
			/obj/item/flashlight/flare/torch/lantern = 1
		)
		var/weapons = list(
			"Big Stick"	= /obj/item/rogueweapon/mace/goden/steel/ogre,
			"Choppa" 	= /obj/item/rogueweapon/greatsword/zwei/ogre,
			"None"
		)
		var/weaponchoice = input(H,"Choose your weapon.", "WEAPON SELECTION") as anything in weapons
		if(weaponchoice != "None")
			backl = weapons[weaponchoice] // doing it this way cuz the normal way runtimes for some fucking reason, despite it being a 1 to 1 copy/paste of trollslayer

/obj/effect/proc_holder/spell/self/convertrole/warlord
	name = "Recruit Follower"
	new_role = "Warlord's Recruit"
	overlay_state = "recruit_templar"
	recruitment_faction = "War Party"
	recruitment_message = "Join my warband, %RECRUIT! For blood and gold!"
	accept_message = "Blood and gold!"
	refuse_message = "I serve no monsters!"

/obj/effect/proc_holder/spell/self/convertrole/warlord/cast(list/targets,mob/user = usr)
	. = ..()
	var/list/recruitment = list()
	for(var/mob/living/carbon/human/recruit in (get_hearers_in_view(recruitment_range, user) - user))
		//not allowed
		if(!can_convert(recruit))
			continue
		recruitment[recruit.name] = recruit
	if(!length(recruitment))
		to_chat(user, span_warning("There are no potential recruits in range."))
		return
	var/inputty = input(user, "Select a potential recruit!", "[name]") as anything in recruitment
	if(inputty)
		var/mob/living/carbon/human/recruit = recruitment[inputty]
		if(!QDELETED(recruit) && (recruit in get_hearers_in_view(recruitment_range, user)))
			INVOKE_ASYNC(src, PROC_REF(convert), recruit, user)
		else
			to_chat(user, span_warning("Recruitment failed!"))
	else
		to_chat(user, span_warning("Recruitment cancelled."))
