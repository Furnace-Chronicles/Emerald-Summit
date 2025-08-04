/*
The Sanctifier is a knight class that is about as martial as it comes.
Entirely designed around heavy armour, two-handed blunt and maintaining discipline.
Intended to get a sergeant like ability, but those are so poorly done that I can't be bothered.
Someone else can do it. Doubles as a healer, too, as the description would imply.
*/
/datum/advclass/pontiff/sanctifier
	name = "Sanctifier"
	tutorial = "A member of a knightly-priest caste. Wholly dedicated to maintaining order and discipline within the ranks of Psydon's crusading forces. \
	Charged with maintaining vigil over this lost shrine for centuries, perhaps it's time once more that you set your eyes to the surface. \
	For He calls to you, from the shrine itself. A new purpose. Venture forth with your two companions. Your most trusted. \
	Keep them alive, just as you do with the TRUE faith."
	outfit = /datum/outfit/job/roguetown/pontiff/sanctifier
	category_tags = list(CTAG_PONTIFF)
	traits_applied = list(TRAIT_GOODTRAINER, TRAIT_HEAVYARMOR)

	maximum_possible_slots = 1
	cmode_music = 'sound/music/combat_ascended.ogg'

/datum/outfit/job/roguetown/pontiff/sanctifier/pre_equip(mob/living/carbon/human/H)
	cloak = /obj/item/clothing/cloak/psydontabard
	head = /obj/item/clothing/head/roguetown/helmet/heavy/guard/paalloy
	armor = /obj/item/clothing/suit/roguetown/armor/plate/paalloy
	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk/paalloy
	pants = /obj/item/clothing/under/roguetown/platelegs/paalloy
	neck = /obj/item/clothing/neck/roguetown/chaincoif/paalloy
	gloves = /obj/item/clothing/gloves/roguetown/plate/paalloy
	wrists = /obj/item/clothing/wrists/roguetown/bracers/paalloy
	shoes = /obj/item/clothing/shoes/roguetown/boots/aalloy
	belt = /obj/item/storage/belt/rogue/leather/steel
	beltl = /obj/item/flashlight/flare/torch/lantern/prelit
	beltr = /obj/item/rogueweapon/mace/steel/palloy
	backl = /obj/item/storage/backpack/rogue/satchel
	backr = /obj/item/rogueweapon/mace/goden/steel/paalloy
	backpack_contents = list(/obj/item/rope/chain = 2, /obj/item/clothing/neck/roguetown/psicross/aalloy = 1)
	H.adjust_skillrank(/datum/skill/combat/maces, 5, TRUE)
	H.adjust_skillrank(/datum/skill/combat/polearms, 4, TRUE)//For picking up one of the underdark weapons, given you'll probably upgrade.
	H.adjust_skillrank(/datum/skill/combat/wrestling, 4, TRUE)
	H.adjust_skillrank(/datum/skill/combat/unarmed, 4, TRUE)
	H.adjust_skillrank(/datum/skill/misc/athletics, 5, TRUE)//Oh, yes...
	H.adjust_skillrank(/datum/skill/misc/climbing, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/medicine, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/reading, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/tracking, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/swimming, 2, TRUE)
	H.adjust_skillrank(/datum/skill/magic/holy, 3, TRUE)//It's bleak, brothers. Hold true to the faith.
	H.dna.species.soundpack_m = new /datum/voicepack/male/evil()
	H.change_stat("strength", 3)
	H.change_stat("endurance", 3)
	H.change_stat("constitution", 1)
	var/datum/devotion/C = new /datum/devotion(H, H.patron)
	C.grant_miracles(H, cleric_tier = CLERIC_T4, passive_gain = CLERIC_REGEN_MAJOR, start_maxed = TRUE)
	if(H.mind)//Unique to the Sanctifier, for now. Not sure why it's not used elsewhere. Exchanges wounds, as long as it's not a head crit, more-or-less.
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/psydonlux_tamper)
	H.ambushable = FALSE
