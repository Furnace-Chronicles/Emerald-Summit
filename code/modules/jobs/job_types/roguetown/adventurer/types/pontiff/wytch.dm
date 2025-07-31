/*
A T4 mage, built around no-armour gameplay with pre-learned spells.
They cannot obtain any new spells roundstart, and must level(if even), but have a decent chunk for the sake of buffing and a singular combat spell.
*/
/datum/advclass/pontiff/wytch
	name = "Wytch"
	tutorial = "At the cost of a shackle around your soul, and the Wytchfinder's ever watching gaze, you've served in vigil over this shrine for centuries. \
	Obey both the Sanctifier and Wytchfinder, for they could, at a moment's notice, determine that your powers are a liability. \
	Despite that, they're your only two friends remaining in this awful, wretched place. Companions who would fall upon their own sword to save you. Wouldn't you?"
	outfit = /datum/outfit/job/roguetown/pontiff/wytch
	category_tags = list(CTAG_PONTIFF)
	traits_applied = list(TRAIT_MAGEARMOR, TRAIT_ARCYNE_T4, TRAIT_INTELLECTUAL)

	maximum_possible_slots = 1
	cmode_music = 'sound/music/combat_maniac.ogg'

/datum/outfit/job/roguetown/pontiff/wytch/pre_equip(mob/living/carbon/human/H)
	cloak = /obj/item/clothing/cloak/psydontabard
	head = /obj/item/clothing/head/roguetown/roguehood/psydon
	mask = /obj/item/clothing/mask/rogue/facemask/steel/paalloy
	neck = /obj/item/clothing/neck/roguetown/gorget/paalloy
	shoes = /obj/item/clothing/shoes/roguetown/sandals/aalloy
	pants = /obj/item/clothing/under/roguetown/heavy_leather_pants
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather/heavy
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/lord
	belt = /obj/item/storage/belt/rogue/leather
	beltr = /obj/item/reagent_containers/glass/bottle/rogue/manapot
	beltl = /obj/item/flashlight/flare/torch/lantern/prelit
	backl = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/woodstaff/diamond//A relic of a better time, perhaps.
	backpack_contents = list(/obj/item/rope/chain = 1, /obj/item/rogueore/gold = 2)//Two perma buffs, effectively, roundstart. For the two companions.
	H.adjust_skillrank(/datum/skill/combat/polearms, 4, TRUE)//Multi-purpose.
	H.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/unarmed, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/reading, 5, TRUE)
	H.adjust_skillrank(/datum/skill/misc/athletics, 4, TRUE)
	H.adjust_skillrank(/datum/skill/misc/climbing, 3, TRUE)
	H.adjust_skillrank(/datum/skill/craft/alchemy, 4, TRUE)
	H.adjust_skillrank(/datum/skill/magic/arcane, 4, TRUE)
	H.dna.species.soundpack_m = new /datum/voicepack/male/wizard()
	H.change_stat("intelligence", 3)
	H.change_stat("endurance", 3)
	H.change_stat("constitution", 1)
	if(H.mind)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/touch/prestidigitation)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/enchant_weapon)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/guidance)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/fortitude)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/haste)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/mending)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/self/recall)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/gravity)
	H.ambushable = FALSE
