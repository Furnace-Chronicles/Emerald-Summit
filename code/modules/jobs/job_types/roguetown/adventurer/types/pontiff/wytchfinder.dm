/*
Immune to magic and armed with counterpspell, Wytchfinders are medium-armoured knife fighters built around speed.
A really odd combination, but one that should be entertaining.
I want to give them the ability to 'purify' objects and buff them as a result. Like placing purity seals on something, and having it act like polishing.
Something for the future, I suppose.
*/
/datum/advclass/pontiff/wytchfinder
	name = "Wytchfinder"
	tutorial = "The Sanctifier's attack dog, entirely dedicated to the destruction of any wytch or inhumen hound to be found in their path. \
	It's said that induction into the order of the Wytchfinders has the divine spark torn from their soul, making them a void where the arcyne might find purchase. \
	It has been centuries since you last explained such, however, given the order died as the crusade had. About as long as you've been standing vigil, \
	with your companions. Obey the Sanctifier and keep an eye on the Wytch."
	outfit = /datum/outfit/job/roguetown/pontiff/wytchfinder
	category_tags = list(CTAG_PONTIFF)
	traits_applied = list(TRAIT_ANTIMAGIC, TRAIT_MEDIUMARMOR)

	maximum_possible_slots = 1
	cmode_music = 'sound/music/combat_maniac2.ogg'

/datum/outfit/job/roguetown/pontiff/wytchfinder/pre_equip(mob/living/carbon/human/H)
	cloak = /obj/item/clothing/cloak/psydontabard
	head = /obj/item/clothing/head/roguetown/roguehood/psydon
	mask = /obj/item/clothing/mask/rogue/facemask/steel/paalloy
	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk/paalloy
	pants = /obj/item/clothing/under/roguetown/chainlegs/kilt/paalloy
	neck = /obj/item/clothing/neck/roguetown/chaincoif/paalloy
	gloves = /obj/item/clothing/gloves/roguetown/chain/paalloy
	wrists = /obj/item/clothing/neck/roguetown/psicross/aalloy
	shoes = /obj/item/clothing/shoes/roguetown/boots/aalloy
	belt = /obj/item/storage/belt/rogue/leather/steel
	beltl = /obj/item/flashlight/flare/torch/lantern/prelit
	beltr = /obj/item/rogueweapon/huntingknife/idagger/steel/padagger
	backl = /obj/item/storage/backpack/rogue/satchel
	backpack_contents = list(/obj/item/rope/chain = 2)
	H.adjust_skillrank(/datum/skill/combat/knives, 5, TRUE)//Your singular weapon skill.
	H.adjust_skillrank(/datum/skill/combat/wrestling, 4, TRUE)
	H.adjust_skillrank(/datum/skill/combat/unarmed, 4, TRUE)
	H.adjust_skillrank(/datum/skill/misc/athletics, 5, TRUE)
	H.adjust_skillrank(/datum/skill/misc/tracking, 5, TRUE)
	H.adjust_skillrank(/datum/skill/misc/swimming, 4, TRUE)
	H.adjust_skillrank(/datum/skill/misc/climbing, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/reading, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/medicine, 2, TRUE)
	H.dna.species.soundpack_m = new /datum/voicepack/male/evil()
	H.change_stat("speed", 3)
	H.change_stat("endurance", 3)
	H.change_stat("constitution", 1)
	if(H.mind)
//Unique counterspell that lets them shut down mages, and allowing said mages to be hit at the same time by magic afterwards.
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/counterspell_pontiff)
//Warscholar blade alt spell. Uses knives instead of unarmed.
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/touch/summonrogueweapon/bladeofpsydon/pontiff)
	H.ambushable = FALSE
