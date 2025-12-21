// Unique class drip or something that might fit into another category
/datum/crafting_recipe/roguetown/leather/unique
	abstract_type = /datum/crafting_recipe/roguetown/leather/unique

/datum/crafting_recipe/roguetown/leather/unique/artipants
	name = "tinker trousers"
	result = list(/obj/item/clothing/under/roguetown/trou/artipants)
	reqs = list(/obj/item/natural/cloth = 1,
	            /obj/item/natural/hide/cured = 2)
	tools = list(/obj/item/needle)
	craftdiff = 3
	sellprice = 11

/datum/crafting_recipe/roguetown/leather/unique/baggyleatherpants
	name = "pontifex's chaqchur"
	result = list(/obj/item/clothing/under/roguetown/trou/leather/pontifex)
	reqs = list(/obj/item/natural/cloth = 1,
	            /obj/item/natural/fibers = 1,
	            /obj/item/natural/hide/cured = 2)
	tools = list(/obj/item/needle)
	craftdiff = 5
	sellprice = 20
		
/datum/crafting_recipe/roguetown/leatherunique/gladsandals
	name = "gladiator sandals"
	result = list(/obj/item/clothing/shoes/roguetown/gladiator)
	reqs = list(/obj/item/natural/hide/cured = 2,
	            /obj/item/natural/fibers = 1)
	tools = list(/obj/item/needle)
	craftdiff = 3
	sellprice = 12

/datum/crafting_recipe/roguetown/leather/unique/grenzelboots
	name = "grenzelhoftian boots"
	result = list(/obj/item/clothing/shoes/roguetown/boots/grenzelhoft)
	reqs = list(/obj/item/natural/hide/cured = 1,
	            /obj/item/reagent_containers/food/snacks/tallow = 1,
				/obj/item/natural/fur = 1,
	            /obj/item/natural/fibers = 1)
	tools = list(/obj/item/needle)
	craftdiff = 6
	sellprice = 15
	
/datum/crafting_recipe/roguetown/leather/unique/otavanleatherpants
	name = "otavan leather trousers"
	result = list(/obj/item/clothing/under/roguetown/heavy_leather_pants/otavan)
	reqs = list(/obj/item/reagent_containers/food/snacks/tallow = 1,
	            /obj/item/natural/fibers = 1,
	            /obj/item/natural/hide/cured = 2,
				/obj/item/natural/fur = 1)
	tools = list(/obj/item/needle)
	craftdiff = 6
	sellprice = 30

/datum/crafting_recipe/roguetown/leather/unique/otavanleathergloves
	name = "otavan leather gloves"
	result = list(/obj/item/clothing/gloves/roguetown/otavan)
	reqs = list(/obj/item/reagent_containers/food/snacks/tallow = 1,
	            /obj/item/natural/fibers = 1,
	            /obj/item/natural/hide/cured = 1,
				/obj/item/natural/fur = 1)
	tools = list(/obj/item/needle)
	craftdiff = 6
	sellprice = 30

/datum/crafting_recipe/roguetown/leather/unique/otavanleathersatchel
	name = "otavan leather satchel"
	result = list(/obj/item/storage/backpack/rogue/satchel/otavan)
	reqs = list(/obj/item/reagent_containers/food/snacks/tallow = 1,
	            /obj/item/natural/fibers = 2,
	            /obj/item/natural/hide/cured = 2,
				/obj/item/natural/fur = 1)
	tools = list(/obj/item/needle)
	craftdiff = 6
	sellprice = 30

/datum/crafting_recipe/roguetown/leather/unique/fencingbreeches
	name = "frencing breeches"
	result = list(/obj/item/clothing/under/roguetown/heavy_leather_pants/otavan/generic)
	reqs = list(/obj/item/natural/fibers = 1,
				/obj/item/natural/hide/cured = 2,
				/obj/item/natural/cloth = 4)
	tools = list(/obj/item/needle)
	craftdiff = 6
	sellprice = 20

/datum/crafting_recipe/roguetown/leather/unique/otavanboots
	name = "otavan leather boots"
	result = list(/obj/item/clothing/shoes/roguetown/boots/otavan)
	reqs = list(/obj/item/natural/hide/cured = 1,
	            /obj/item/reagent_containers/food/snacks/tallow = 1,
				/obj/item/natural/fur = 1,
	            /obj/item/natural/fibers = 1)
	tools = list(/obj/item/needle)
	craftdiff = 6
	sellprice = 25

/datum/crafting_recipe/roguetown/leather/unique/buckleshoes
	name = "buckled shoes"
	result = list(/obj/item/clothing/shoes/roguetown/simpleshoes/buckle)
	reqs = list(/obj/item/natural/hide/cured = 1,
	            /obj/item/natural/fibers = 2)
	tools = list(/obj/item/needle)
	craftdiff = 6
	sellprice = 25

/datum/crafting_recipe/roguetown/leather/unique/monkleather
	name = "pontifex's kaftan"
	result = list(/obj/item/clothing/suit/roguetown/armor/gambeson/heavy/pontifex)
	reqs = list(/obj/item/natural/hide/cured = 4,
	            /obj/item/natural/cloth = 1,
				/obj/item/reagent_containers/food/snacks/tallow = 1)
	tools = list(/obj/item/needle)
	craftdiff = 5
	sellprice = 23

/datum/crafting_recipe/roguetown/leather/unique/furlinedjacket
	name = "artificer jacket"
	result = list(/obj/item/clothing/suit/roguetown/armor/leather/jacket/artijacket)
	reqs = list(/obj/item/natural/hide/cured = 2,
				/obj/item/natural/fur = 1,
	            /obj/item/natural/cloth = 1)
	tools = list(/obj/item/needle)
	craftdiff = 5
	sellprice = 21

/datum/crafting_recipe/roguetown/leather/unique/winterjacket
	name = "winter jacket"
	result = list(/obj/item/clothing/suit/roguetown/armor/leather/vest/winterjacket)
	reqs = list(/obj/item/natural/hide/cured = 2,
				/obj/item/natural/fur = 2,
	            /obj/item/natural/cloth = 1)
	tools = list(/obj/item/needle)
	craftdiff = 5
	sellprice = 24

/datum/crafting_recipe/roguetown/leather/unique/openrobes
	name = "shamanic coat"
	result = list(/obj/item/clothing/suit/roguetown/armor/leather/heavy/atgervi)
	reqs = list(/obj/item/natural/hide/cured = 2,
	            /obj/item/natural/fibers = 1,
	            /obj/item/natural/cloth = 1)
	tools = list(/obj/item/needle)
	craftdiff = 5
	sellprice = 20

/datum/crafting_recipe/roguetown/leather/unique/monkrobes
	name = "monk vestments"
	result = list(/obj/item/clothing/suit/roguetown/shirt/robe/monk)
	reqs = list(/obj/item/natural/hide/cured = 2,
				/obj/item/reagent_containers/food/snacks/tallow = 1,
				/obj/item/natural/fibers = 2)
	tools = list(/obj/item/needle)
	craftdiff = 6	//Can be a bit strong, reduce to 5 if too high.

/datum/crafting_recipe/roguetown/leather/unique/basiceast/light
	name = "fragile dobo robe (1 silk, 1 leather, 2 fiber)"
	result = list(/obj/item/clothing/suit/roguetown/armor/basiceast/light)
	reqs = list(
		/obj/item/natural/hide/cured = 1,
		/obj/item/natural/fibers = 2,
		/obj/item/natural/silk = 1
		)
	tools = list(/obj/item/needle)
	craftdiff = 2

/datum/crafting_recipe/roguetown/leather/unique/basiceast/mentorsuit/light
	name = "worn dobo robe (1 silk, 1 leather, 2 fiber)"
	result = list(/obj/item/clothing/suit/roguetown/armor/basiceast/mentorsuit/light)
	reqs = list(
		/obj/item/natural/hide/cured = 1,
		/obj/item/natural/fibers = 2,
		/obj/item/natural/silk = 1
		)
	tools = list(/obj/item/needle)
	craftdiff = 2

/datum/crafting_recipe/roguetown/leather/unique/basiceast/crafteast/light
	name = "formal dobo robe (1 silk, 1 leather, 2 fiber)"
	result = list(/obj/item/clothing/suit/roguetown/armor/basiceast/crafteast/light)
	reqs = list(
		/obj/item/natural/hide/cured = 1,
		/obj/item/natural/fibers = 2,
		/obj/item/natural/silk = 1
		)
	tools = list(/obj/item/needle)
	craftdiff = 2

/datum/crafting_recipe/roguetown/leather/unique/captainrobe/light
	name = "floral robes (1 silk, 1 leather, 2 fiber)"
	result = list(/obj/item/clothing/suit/roguetown/armor/basiceast/captainrobe/light)
	reqs = list(
		/obj/item/natural/hide/cured = 1,
		/obj/item/natural/fibers = 2,
		/obj/item/natural/silk = 1
		)
	tools = list(/obj/item/needle)
	craftdiff = 2
	
/datum/crafting_recipe/roguetown/leather/unique/crafteast
	name = "decorated dobo robe"
	result = list(/obj/item/clothing/suit/roguetown/armor/basiceast/crafteast)
	reqs = list(
		/obj/item/natural/hide/cured = 2,
		/obj/item/reagent_containers/food/snacks/tallow = 1,
		/obj/item/natural/fibers = 2,
		/obj/item/clothing/suit/roguetown/armor/basiceast = 1,
		)
	tools = list(/obj/item/needle)
	craftdiff = 5

/datum/crafting_recipe/roguetown/leather/unique/basiceast
	name = "simple dobo robe (2 silk, 2 leather, 2 fiber, 1 tallow)"
	result = list(/obj/item/clothing/suit/roguetown/armor/basiceast)
	reqs = list(
		/obj/item/natural/hide/cured = 2,
		/obj/item/reagent_containers/food/snacks/tallow = 1,
		/obj/item/natural/fibers = 2,
		/obj/item/natural/silk = 2
		)
	tools = list(/obj/item/needle)
	craftdiff = 4

/datum/crafting_recipe/roguetown/leather/unique/mentorsuit
	name = "old dobo robe (4 silk, 4 leather, 2 fiber, 2 tallow)"
	result = list(/obj/item/clothing/suit/roguetown/armor/basiceast/mentorsuit)
	reqs = list(
		/obj/item/natural/hide/cured = 4,
		/obj/item/reagent_containers/food/snacks/tallow = 2,
		/obj/item/natural/fibers = 2,
		/obj/item/natural/silk = 4
		)
	tools = list(/obj/item/needle)
	craftdiff = 5

/datum/crafting_recipe/roguetown/leather/unique/shrinekeeper
	name = "eastern ceremonial robe (6 silk, 4 leather, 2 fiber, 2 tallow)"
	result = list(/obj/item/clothing/suit/roguetown/armor/basiceast/crafteast/shrinekeeper)
	reqs = list(
		/obj/item/natural/hide/cured = 4,
		/obj/item/reagent_containers/food/snacks/tallow = 2,
		/obj/item/natural/fibers = 2,
		/obj/item/natural/silk = 6
		)
	tools = list(/obj/item/needle)
	craftdiff = 6

/datum/crafting_recipe/roguetown/leather/unique/captainrobe
	name = "foreign robe (6 silk, 4 leather, 2 fiber, 2 tallow)"
	result = list(/obj/item/clothing/suit/roguetown/armor/basiceast/captainrobe)
	reqs = list(
		/obj/item/natural/hide/cured = 4,
		/obj/item/reagent_containers/food/snacks/tallow = 2,
		/obj/item/natural/fibers = 2,
		/obj/item/natural/silk = 6
		)
	tools = list(/obj/item/needle)
	craftdiff = 6

/datum/crafting_recipe/roguetown/leather/unique/eastpants1
	name = "cut-throat's pants (2 silk, 2 fibers, 2 leather, 1 tallow)"
	result = list(/obj/item/clothing/under/roguetown/heavy_leather_pants/eastpants1)
	reqs = list(
		/obj/item/natural/hide/cured = 2,
		/obj/item/reagent_containers/food/snacks/tallow = 1,
		/obj/item/natural/fibers = 2,
		/obj/item/natural/silk = 2
		)
	tools = list(/obj/item/needle)
	craftdiff = 4

/datum/crafting_recipe/roguetown/leather/unique/eastpants2
	name = "strange ripped pants (2 silk, 2 fibers, 2 leather, 1 tallow)"
	result = list(/obj/item/clothing/under/roguetown/heavy_leather_pants/eastpants2)
	reqs = list(
		/obj/item/natural/hide/cured = 2,
		/obj/item/reagent_containers/food/snacks/tallow = 1,
		/obj/item/natural/fibers = 2,
		/obj/item/natural/silk = 2
		)
	tools = list(/obj/item/needle)
	craftdiff = 4

/datum/crafting_recipe/roguetown/leather/unique/eastgloves1
	name = "black gloves (2 silk, 2 fibers, 1 leather)"
	result = list(/obj/item/clothing/gloves/roguetown/eastgloves1)
	reqs = list(
		/obj/item/natural/hide/cured = 1,
		/obj/item/natural/fibers = 2,
		/obj/item/natural/silk = 2
		)
	tools = list(/obj/item/needle)
	craftdiff = 3

/datum/crafting_recipe/roguetown/leather/unique/eastgloves2
	name = "stylish gloves (2 silk, 2 fibers, 1 leather)"
	result = list(/obj/item/clothing/gloves/roguetown/eastgloves2)
	reqs = list(
		/obj/item/natural/hide/cured = 1,
		/obj/item/natural/fibers = 2,
		/obj/item/natural/silk = 2
		)
	tools = list(/obj/item/needle)
	craftdiff = 3

/datum/crafting_recipe/roguetown/leather/unique/daisho
	name = "daisho (1 fiber, 1 leather)"
	result = list(/obj/item/storage/belt/rogue/leather/daisho)
	reqs = list(
		/obj/item/natural/hide/cured = 1,
		/obj/item/natural/fibers = 1
		)
	tools = list(/obj/item/needle)
	craftdiff = 1
	
