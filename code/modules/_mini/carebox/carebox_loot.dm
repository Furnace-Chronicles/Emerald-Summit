/datum/carebox_loot
	abstract_type = /datum/carebox_loot
	var/name = "LOOT"
	var/list/loot
	var/random_loot_amt = 0
	var/list/random_loot


/datum/carebox_loot/wretch
	abstract_type = /datum/carebox_loot/wretch

/datum/carebox_loot/wretch/potion
	name = "Potion"
	loot = list(
		/obj/item/reagent_containers/glass/bottle/rogue/healthpot
	)

/datum/carebox_loot/wretch/steel_mask
	name = "Steel Mask"
	random_loot_amt = 1
	random_loot = list(
		/obj/item/clothing/mask/rogue/facemask/steel,
		/obj/item/clothing/mask/rogue/facemask/steel/hound,
	)

/datum/carebox_loot/wretch/steel_ingot
	name = "Steel Ingots (2)"
	loot = list(
		/obj/item/ingot/steel,
		/obj/item/ingot/steel,
	)

/datum/carebox_loot/wretch/iron_ingot
	name = "Iron Ingots (3)"
	loot = list(
		/obj/item/ingot/iron,
		/obj/item/ingot/iron,
		/obj/item/ingot/iron,
	)

/datum/carebox_loot/wretch/gambeson
	name = "Gambeson"
	loot = list(
		/obj/item/clothing/suit/roguetown/armor/gambeson/heavy,
	)

/datum/carebox_loot/wretch/leather_clothes
	name = "Leather Clothes"
	loot = list(
		/obj/item/clothing/shoes/roguetown/boots/leather/reinforced,
		/obj/item/clothing/gloves/roguetown/angle,
		/obj/item/clothing/wrists/roguetown/bracers/leather/heavy,
		/obj/item/clothing/under/roguetown/heavy_leather_pants,
	)

/datum/carebox_loot/wretch/leather_armor
	name = "Leather Armor"
	random_loot_amt = 1
	random_loot = list(
		/obj/item/clothing/suit/roguetown/armor/leather/studded,
		/obj/item/clothing/suit/roguetown/armor/leather/heavy,
		/obj/item/clothing/suit/roguetown/armor/leather/heavy/coat,
	)

/datum/carebox_loot/wretch/stampot
	name = "Stamina Potion"
	loot = list(
		/obj/item/reagent_containers/glass/bottle/rogue/stampot,
	)

/datum/carebox_loot/wretch/manapot
	name = "Mana Potion"
	loot = list(
		/obj/item/reagent_containers/glass/bottle/rogue/manapot,
	)

/datum/carebox_loot/wretch/raisin_loaf
	name = "Raisin Loaf"
	loot = list(
		/obj/item/reagent_containers/food/snacks/rogue/raisinbread,
	)

/datum/carebox_loot/wretch/quiver
	name = "Arrows and Bolts"
	loot = list(
		/obj/item/quiver/arrows,
		/obj/item/quiver/bolts,
	)

/datum/carebox_loot/wretch/throwing_knifes
	name = "Iron Throwing Knifes"
	loot = list(
		/obj/item/storage/belt/rogue/leather/knifebelt/black/iron,
	)

/datum/carebox_loot/wretch/pouch_coins_mid
	name = "Pouch (Coins)"
	loot = list(
		/obj/item/storage/belt/rogue/pouch/coins/mid,
	)

/datum/carebox_loot/wretch/chain_rope
	name = "Chains (2), Rope (1)"
	loot = list(
		/obj/item/rope/chain,
		/obj/item/rope/chain,
		/obj/item/rope,
	)

/datum/carebox_loot/wretch/lantern_bedroll
	name = "Lantern and Bedroll"
	loot = list(
		/obj/item/flashlight/flare/torch/lantern,
		/obj/item/bedroll,
	)

/datum/carebox_loot/wretch/pouch_medicine
	name = "Pouch (Medicine)"
	loot = list(
		/obj/item/storage/belt/rogue/pouch/medicine,
	)

/datum/carebox_loot/wretch/bottle_bomb
	name = "Bottle Bomb (2)"
	loot = list(
		/obj/item/bomb,
		/obj/item/bomb,
	)

/datum/carebox_loot/wretch/smithing_tools
	name = "Smithing tools"
	loot = list(
		/obj/item/rogueweapon/hammer/iron,
		/obj/item/rogueweapon/tongs,
	)

/datum/carebox_loot/wretch/farming_tools
	name = "Farming tools"
	loot = list(
		/obj/item/rogueweapon/hoe,
		/obj/item/rogueweapon/pitchfork,
		/obj/item/rogueweapon/sickle,
		/obj/item/seeds/apple,
		/obj/item/seeds/wheat,
		/obj/item/seeds/berryrogue,
	)
/datum/carebox_loot/wretch/chalks
	name = "Chalks"
	loot = list(
		/obj/item/ritechalk,
		/obj/item/ritechalk,
		/obj/item/ritechalk,
	)

/datum/carebox_loot/wretch/surgery_tools
	name = "Surgery tools"
	loot = list(
		/obj/item/storage/belt/rogue/surgery_bag/full/physician,
	)
	
/datum/carebox_loot/wretch/starsugar
	name = "Star Sugar"
	loot = list(
		/obj/item/reagent_containers/powder/starsugar,
		/obj/item/reagent_containers/powder/starsugar,
	)
/datum/carebox_loot/wretch/emberwine
	name = "Emberwine"
	loot = list(
		/obj/item/reagent_containers/glass/bottle/rogue/emberwine,
	)

/datum/carebox_loot/wretch/summonerpouch	
	name = "Beginner's summoner's pouch"
	loot = list(
		 /obj/item/storage/magebag/starter,
	)
