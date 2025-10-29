/datum/advclass/mercenary/monsterhunter
	name = "Monster Hunter"
	tutorial = "You are a monster hunter, you dedicated your lyfe to hunt down night creechurs. You know their ways and carry the adequate arsenal to end or cure them. You travel the lands taking on dangerous contracts where your own existence is at risk of shifting into one of theirs."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = NON_DWARVEN_RACE_TYPES 
	outfit = /datum/outfit/job/roguetown/mercenary/monsterhunter
	category_tags = list(CTAG_MERCENARY)
	class_select_category = CLASS_CAT_OTAVA  //Not much class from otava, and lorewise i find it fitting. Not a reason to dogtail the inquisition, you mostly hunt alone, duo or trio.
	maximum_possible_slots = 3 //To not fill too much the others merc slot since this one is more focused on one specific job, and since there is rarely job for all the merc slot, having 5 others merc should be enought.

	subclass_languages = list(
		/datum/language/otavan,
	)

	traits_applied = list(TRAIT_CRITICAL_RESISTANCE, TRAIT_NOPAINSTUN, TRAIT_HARDDISMEMBER, TRAIT_ARCYNE_T1) //remove medium armor trait for nopainstun and crit res, more fitting for the job
	subclass_stats = list(  // Weighted at 10, same as others similar merc class
		STATKEY_CON = 4, //Resilient body,must have for the task
		STATKEY_END = 3, //Need some endurance to track down the beast and perform in the hunt
		STATKEY_STR = 2, 
		STATKEY_PER = 1,
		STATKEY_SPD = -1 //Strong and heavy body.. It can track down the night creechur but won't be faster than them. Tactics and planning will be important for a succesfull hunt
	)

	subclass_spellpoints = 6 //Allow for a few non-combat spell, i prefer to let some liberty to the player instead of forced choice since the gameplay impact will be low.

	subclass_skills = list(
		/datum/skill/misc/swimming = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/sneaking = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/wrestling = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/unarmed = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/swords = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/knives = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/reading = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/craft/alchemy = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/athletics = SKILL_LEVEL_EXPERT,
		/datum/skill/magic/arcane = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/tracking = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/sewing = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/medicine = SKILL_LEVEL_NOVICE,
	)

/datum/outfit/job/roguetown/mercenary/monsterhunter/pre_equip(mob/living/carbon/human/H)
	..()
	to_chat(H, span_warning("You specialize in hunting down monsters and the undead, carrying two blades - one of silver, one of steel."))

	var/steel = list("Parrying Dagger","Sword","Dagger","Longsword")
	var/steel_choice = input("Choose your steel.", "PURGE THE LIVING") as anything in steel
	switch(steel_choice)
		if ("Parrying Dagger")
			l_hand = /obj/item/rogueweapon/huntingknife/idagger/steel/parrying
			beltr = /obj/item/rogueweapon/scabbard/sheath
		if("Sword")
			l_hand = /obj/item/rogueweapon/sword
			beltr = /obj/item/rogueweapon/scabbard/sword
		if ("Dagger")
			l_hand = /obj/item/rogueweapon/huntingknife/idagger/steel
			beltr = /obj/item/rogueweapon/scabbard/sheath
		if ("Longsword")
			l_hand = /obj/item/rogueweapon/sword/long
			beltr = /obj/item/rogueweapon/scabbard/sword

	var/silver = list("Silver Sword","Silver Dagger")
	var/silver_choice = input("Choose your silver.", "PURGE THE CURSED") as anything in silver
	switch(silver_choice)
		if("Silver Sword")
			r_hand = /obj/item/rogueweapon/sword/silver
			backr = /obj/item/rogueweapon/scabbard/sword
		if ("Silver Dagger")
			r_hand = /obj/item/rogueweapon/huntingknife/idagger/silver
			backr = /obj/item/rogueweapon/scabbard/sheath

	backl = /obj/item/storage/backpack/rogue/satchel/black
	wrists = /obj/item/clothing/neck/roguetown/psicross/silver
	armor = /obj/item/clothing/suit/roguetown/armor/plate/scale/mhjacket
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	belt = /obj/item/storage/belt/rogue/leather/knifebelt/black/steel
	shoes = /obj/item/clothing/shoes/roguetown/boots/psydonboots //Only for the style, doenst change anything
	pants = /obj/item/clothing/under/roguetown/chainlegs/skirt
	cloak = /obj/item/clothing/cloak/cape/puritan
	neck = /obj/item/storage/belt/rogue/pouch/coins/poor
	head = /obj/item/clothing/head/roguetown/bucklehat //You will probably seek out contract to the duchy to clear their lands from atrocities, having nice outfit is important! + player will have few items slot to fill up( heads neck,mask, arms)+ make potion before going for bigger target( like WW or vampire)
	gloves = /obj/item/clothing/gloves/roguetown/angle
	backpack_contents = list(
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/rogueweapon/huntingknife = 1,
		/obj/item/recipe_book/survival = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/rope/inqarticles/inquirycord = 1,
		/obj/item/roguekey/mercenary = 1
		)
	beltl = pick(	
		/obj/item/reagent_containers/glass/bottle/alchemical/strpot,
		/obj/item/reagent_containers/glass/bottle/alchemical/conpot,
		/obj/item/reagent_containers/glass/bottle/alchemical/endpot,
		/obj/item/reagent_containers/glass/bottle/alchemical/spdpot,
		/obj/item/reagent_containers/glass/bottle/alchemical/perpot,
		/obj/item/reagent_containers/glass/bottle/alchemical/intpot,
		/obj/item/reagent_containers/glass/bottle/alchemical/lucpot,
		)

	if(H.mind)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/enchant_weapon)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/repulse)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/forcewall)
