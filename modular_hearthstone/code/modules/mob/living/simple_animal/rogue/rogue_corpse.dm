/obj/effect/mob_spawn/human/orc

	mob_name = "Orc"
	mob_type = /mob/living/carbon/human/species/halforc
	mob_species = /datum/species/halforc
	brute_damage = 80

/obj/effect/mob_spawn/human/orc/corpse/savageorc
	mob_name = "Savage Orc"
	name = "Savage Orc"
	skin_tone = SKIN_COLOR_GROONN
	hairstyle = "Bald"
	facial_hairstyle = "Shaved"
	outfit = /datum/outfit/savageorc

/obj/effect/mob_spawn/human/orc/corpse/savageorc2
	mob_name = "Savage Orc"
	name = "Savage Orc"
	skin_tone = SKIN_COLOR_GROONN
	hairstyle = "Bald"
	facial_hairstyle = "Shaved"
	outfit = /datum/outfit/savageorc2

/datum/outfit/savageorc
	shirt = /obj/item/clothing/suit/roguetown/shirt/tribalrag
	pants =	/obj/item/clothing/under/roguetown/loincloth/brown
	shoes = /obj/item/clothing/shoes/roguetown/boots/furlinedanklets

/datum/outfit/savageorc2
	shirt = /obj/item/clothing/suit/roguetown/shirt/tribalrag
	pants =	/obj/item/clothing/under/roguetown/loincloth/brown
	shoes = /obj/item/clothing/shoes/roguetown/boots/furlinedanklets
	head = /obj/item/clothing/head/roguetown/helmet/leather

/obj/effect/mob_spawn/human/orc/corpse/orcmarauder
	mob_name = "Orc Marauder"
	name = "Orc Marauder"
	skin_tone = SKIN_COLOR_GROONN
	hairstyle = "Bald"
	facial_hairstyle = "Shaved"
	outfit = /datum/outfit/orcmarauder

/datum/outfit/orcmarauder
	armor = /obj/item/clothing/suit/roguetown/armor/chainmail/orcish
	pants =	/obj/item/clothing/under/roguetown/chainlegs/orcish
	shoes = /obj/item/clothing/shoes/roguetown/boots/furlinedboots
	head = /obj/item/clothing/head/roguetown/helmet/leather

/obj/effect/mob_spawn/human/orc/corpse/orcravager
	mob_name = "Orc Ravager"
	name = "Orc Ravager"
	skin_tone = SKIN_COLOR_GROONN
	hairstyle = "Bald"
	facial_hairstyle = "Shaved"
	outfit = /datum/outfit/orcravager

/datum/outfit/orcravager
	armor = /obj/item/clothing/suit/roguetown/armor/chainmail/orcish
	pants =	/obj/item/clothing/under/roguetown/chainlegs/orcish
	shoes = /obj/item/clothing/shoes/roguetown/boots/furlinedboots
	head = /obj/item/clothing/head/roguetown/helmet/leather
	gloves = /obj/item/clothing/gloves/roguetown/chain/orcish
	neck = /obj/item/clothing/neck/roguetown/chaincoif/orcish
	mask = /obj/item/clothing/mask/rogue/skullmask

// Orcish armor variants - crude, unsalvageable scrap
/obj/item/clothing/suit/roguetown/armor/chainmail/orcish
	name = "crude orcish chainmail"
	desc = "Poorly maintained chainmail worn by orcs. The rings are corroded and worthless for smelting."
	smeltresult = null
	max_integrity = 150
	sellprice = 5

/obj/item/clothing/under/roguetown/chainlegs/orcish
	name = "crude orcish chausses"
	desc = "Corroded chain leggings scavenged from orc equipment. Too damaged to salvage."
	icon_state = "ichain_legs"
	smeltresult = null
	max_integrity = 150
	sellprice = 3

/obj/item/clothing/gloves/roguetown/chain/orcish
	name = "crude orcish chain gauntlets"
	desc = "Rusted chain gloves from orc armor. Worthless scrap."
	smeltresult = null
	max_integrity = 100
	sellprice = 2

/obj/item/clothing/neck/roguetown/chaincoif/orcish
	name = "crude orcish coif"
	desc = "A damaged chain coif from orc armor. Too corroded to smelt."
	smeltresult = null
	max_integrity = 100
	sellprice = 2







