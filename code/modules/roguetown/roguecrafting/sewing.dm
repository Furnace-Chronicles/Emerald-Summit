/datum/crafting_recipe/roguetown/sewing
	abstract_type = /datum/crafting_recipe/roguetown/sewing
	tools = list(/obj/item/needle)
	skillcraft = /datum/skill/misc/sewing
	subtype_reqs = TRUE		//For subtypes of fur

/* craftdif of 0 */

/datum/crafting_recipe/roguetown/sewing/headband
	name = "headband"
	result = list(/obj/item/clothing/head/roguetown/headband)
	reqs = list(/obj/item/natural/cloth = 1)
	craftdiff = 0

/datum/crafting_recipe/roguetown/sewing/peasantcap
	name = "cap"
	result = list(/obj/item/clothing/head/roguetown/armingcap)
	reqs = list(/obj/item/natural/cloth = 1)
	craftdiff = 0

/datum/crafting_recipe/roguetown/sewing/apron_waist
	name = "apron"
	result = list(/obj/item/clothing/cloak/apron/waist)
	reqs = list(/obj/item/natural/cloth = 3) // 3 because it thas a storage, but it really just a apron.
	craftdiff = 0

/datum/crafting_recipe/roguetown/sewing/apron/blacksmith
	name = "leather apron"
	result = list(/obj/item/clothing/cloak/apron/blacksmith)
	reqs = list(/obj/item/natural/cloth = 2,
				/obj/item/natural/hide/cured = 1)
	craftdiff = 0

/datum/crafting_recipe/roguetown/sewing/rags
	name = "rags"
	result = list(/obj/item/clothing/suit/roguetown/shirt/rags)
	reqs = list(/obj/item/natural/cloth = 2)
	craftdiff = 0

/datum/crafting_recipe/roguetown/sewing/burial_shroud
	name = "winding sheet"
	result = list(/obj/item/burial_shroud)
	reqs = list(/obj/item/natural/cloth = 2)
	craftdiff = 1

/datum/crafting_recipe/roguetown/sewing/loincloth
	name = "loincloth"
	result = list(/obj/item/clothing/under/roguetown/loincloth)
	reqs = list(/obj/item/natural/cloth = 1)
	craftdiff = 0

/datum/crafting_recipe/roguetown/sewing/brownloincloth
	name = "brown loincloth"
	result = list(/obj/item/clothing/under/roguetown/loincloth/brown)
	reqs = list(/obj/item/natural/cloth = 1)
	craftdiff = 0


/datum/crafting_recipe/roguetown/sewing/linedanklet
	name = "cloth lined anklet"
	result = list(/obj/item/clothing/shoes/roguetown/boots/clothlinedanklets)
	reqs = list(/obj/item/natural/cloth = 2,
				/obj/item/natural/fibers = 2)
	craftdiff = 0

/* craftdif of 1 */

/datum/crafting_recipe/roguetown/sewing/clothgloves
	name = "fingerless gloves"
	result = list(/obj/item/clothing/gloves/roguetown/fingerless)
	reqs = list(/obj/item/natural/cloth = 1,
				/obj/item/natural/fibers = 1)
	craftdiff = 1

/datum/crafting_recipe/roguetown/sewing/clothbedsheet
	name = "bedsheet, cloth"
	result = list(/obj/item/bedsheet/rogue/cloth)
	reqs = list(/obj/item/natural/cloth = 2,
				/obj/item/natural/fibers = 1)
	craftdiff = 1

/datum/crafting_recipe/roguetown/sewing/fabricbedsheet // cloth bedsheet's fancier looking cousin
	name = "bedsheet, fabric"
	result = list(/obj/item/bedsheet/rogue/fabric)
	reqs = list(/obj/item/natural/cloth = 2,
				/obj/item/natural/fibers = 1,
				/obj/item/natural/silk = 1)
	craftdiff = 1

/datum/crafting_recipe/roguetown/sewing/doublefabricbedsheet
	name = "bedsheet, double fabric"
	result = list(/obj/item/bedsheet/rogue/fabric_double)
	reqs = list(/obj/item/natural/cloth = 4,
				/obj/item/natural/fibers = 2,
				/obj/item/natural/silk = 2)
	craftdiff = 1

/datum/crafting_recipe/roguetown/sewing/brimmed
	name = "brimmed hat"
	result = list(/obj/item/clothing/head/roguetown/brimmed)
	reqs = list(/obj/item/natural/cloth = 1,
				/obj/item/natural/fibers = 2)
	craftdiff = 1

/datum/crafting_recipe/roguetown/sewing/tunic
	name = "tunic"
	result = list(/obj/item/clothing/suit/roguetown/shirt/tunic/white)
	reqs = list(/obj/item/natural/cloth = 2)
	craftdiff = 1

/datum/crafting_recipe/roguetown/sewing/lowcut_shirt
	name = "low cut tunic"
	reqs = list(
		/obj/item/natural/cloth = 2,
		/obj/item/natural/fibers = 1,
	)
	result = /obj/item/clothing/suit/roguetown/shirt/undershirt/lowcut

/datum/crafting_recipe/roguetown/sewing/noblecoat
	name = "fancy coat"
	result = /obj/item/clothing/suit/roguetown/shirt/tunic/noblecoat
	reqs = list(/obj/item/natural/cloth = 3,
			/obj/item/natural/silk = 1)
	craftdiff = 3

/datum/crafting_recipe/roguetown/sewing/shadowshirt
	name = "silk shirt"
	result = /obj/item/clothing/suit/roguetown/shirt/shadowshirt
	reqs = list(/obj/item/natural/cloth = 2,
				/obj/item/natural/silk = 3)
	craftdiff = 4

/datum/crafting_recipe/roguetown/sewing/clothshirt
	name = "shirt"
	result = list(/obj/item/clothing/suit/roguetown/shirt/undershirt)
	reqs = list(/obj/item/natural/cloth = 2,
				/obj/item/natural/fibers = 1)
	craftdiff = 1

/datum/crafting_recipe/roguetown/sewing/clothtrou
	name = "work trousers"
	result = list(/obj/item/clothing/under/roguetown/trou)
	reqs = list(/obj/item/natural/cloth = 2,
				/obj/item/natural/fibers = 1)
	craftdiff = 1

/datum/crafting_recipe/roguetown/sewing/longcoat
	name = "longcoat"
	result = list(/obj/item/clothing/suit/roguetown/armor/longcoat)
	reqs = list(/obj/item/natural/cloth = 2,
				/obj/item/natural/fibers = 2)
	craftdiff = 1

/datum/crafting_recipe/roguetown/sewing/workervest
	name = "striped tunic"
	result = list(/obj/item/clothing/suit/roguetown/armor/workervest)
	reqs = list(/obj/item/natural/cloth = 2,
				/obj/item/natural/fibers = 2)
	craftdiff = 1

/datum/crafting_recipe/roguetown/sewing/tights
	name = "tights"
	result = list(/obj/item/clothing/under/roguetown/tights/random)
	reqs = list(/obj/item/natural/cloth = 2,
				/obj/item/natural/fibers = 1)
	craftdiff = 1

/datum/crafting_recipe/roguetown/sewing/Reyepatch
	name = "right eye patch"
	result = list(/obj/item/clothing/mask/rogue/eyepatch)
	reqs = list(/obj/item/natural/cloth = 1,
				/obj/item/natural/fibers = 1)
	craftdiff = 1

/datum/crafting_recipe/roguetown/sewing/Leyepatch
	name = "left eye patch"
	result = list(/obj/item/clothing/mask/rogue/eyepatch/left)
	reqs = list(/obj/item/natural/cloth = 1,
				/obj/item/natural/fibers = 1)
	craftdiff = 1

/datum/crafting_recipe/roguetown/sewing/knitcap
	name = "knit cap"
	result = list(/obj/item/clothing/head/roguetown/knitcap)
	reqs = list(/obj/item/natural/cloth = 2,
				/obj/item/natural/fibers = 1)
	craftdiff = 1

/datum/crafting_recipe/roguetown/sewing/strawhat
	name = "straw hat"
	result = list(/obj/item/clothing/head/roguetown/strawhat)
	reqs = list(/obj/item/natural/fibers = 3)
	craftdiff = 1

/datum/crafting_recipe/roguetown/sewing/gasa
	name = "gasa (4 fibers)"
	result = list(/obj/item/clothing/head/roguetown/gasa)
	reqs = list(/obj/item/natural/fibers = 4)
	craftdiff = 1

/datum/crafting_recipe/roguetown/sewing/sack
	name = "sack hood"
	result = list(/obj/item/clothing/head/roguetown/menacing)
	reqs = list(/obj/item/natural/cloth = 3,)
	craftdiff = 1

/datum/crafting_recipe/roguetown/sewing/basichood
	name = "hood"
	result = list(/obj/item/clothing/head/roguetown/roguehood)
	reqs = list(/obj/item/natural/cloth = 2,
				/obj/item/natural/fibers = 1)
	craftdiff = 1

/datum/crafting_recipe/roguetown/sewing/lgambeson
    name = "light gambeson"
    result = list(/obj/item/clothing/suit/roguetown/armor/gambeson/light)
    reqs = list(/obj/item/natural/cloth = 2,
                /obj/item/natural/fibers = 1)
    craftdiff = 1

/datum/crafting_recipe/roguetown/sewing/clothblindfold
	name = "blindfold"
	result = list(/obj/item/clothing/mask/rogue/blindfold)
	reqs = list(/obj/item/natural/cloth = 2,
				/obj/item/natural/fibers = 1)
	craftdiff = 1

/datum/crafting_recipe/roguetown/sewing/duelmask
	name = "duelist's mask"
	result = list(/obj/item/clothing/mask/rogue/duelmask)
	reqs = list(/obj/item/natural/cloth = 2,
				/obj/item/natural/fibers = 1)
	craftdiff = 1

/* craftdif of 2+ */

/datum/crafting_recipe/roguetown/sewing/clothsash
	name = "cloth sash (4 cloth)"
	result = list(/obj/item/storage/belt/rogue/leather/sash)
	reqs = list(/obj/item/natural/cloth = 4)
	craftdiff = 2

/datum/crafting_recipe/roguetown/sewing/wrappings
	name = "solar wrappings"
	result = list(/obj/item/clothing/wrists/roguetown/wrappings)
	reqs = list(/obj/item/natural/cloth = 2)
	craftdiff = 2

/datum/crafting_recipe/roguetown/sewing/nocwrappings
	name = "moon wrappings"
	result = list(/obj/item/clothing/wrists/roguetown/nocwrappings)
	reqs = list(/obj/item/natural/cloth = 2)
	craftdiff = 2

/datum/crafting_recipe/roguetown/sewing/nunveil
	name = "nun veil"
	result = list(/obj/item/clothing/head/roguetown/nun)
	reqs = list(/obj/item/natural/cloth = 1)
	craftdiff = 2

/datum/crafting_recipe/roguetown/sewing/nunhabit
	name = "nun habit"
	result = list(/obj/item/clothing/suit/roguetown/shirt/robe/nun)
	reqs = list(/obj/item/natural/cloth = 2)
	craftdiff = 2

/datum/crafting_recipe/roguetown/sewing/necramask
	name = "death mask"
	result = list(/obj/item/clothing/head/roguetown/necramask)
	reqs = list(/obj/item/natural/cloth = 2,
				/obj/item/natural/fibers = 1,
				/obj/item/natural/bone = 1)
	craftdiff = 2

/datum/crafting_recipe/roguetown/sewing/mentorhat
	name = "worn bamboo hat"
	result = list(/obj/item/clothing/head/roguetown/mentorhat)
	reqs = list(/obj/item/natural/fibers = 4,
				/obj/item/grown/log/tree/stick = 4,
				/obj/item/ingot/iron = 1,)
	craftdiff = 3

/datum/crafting_recipe/roguetown/sewing/coif
	name = "coif"
	result = list(/obj/item/clothing/neck/roguetown/coif/clothcoif)
	reqs = list(/obj/item/natural/cloth = 2,
				/obj/item/natural/fibers = 1)
	craftdiff = 3

/datum/crafting_recipe/roguetown/sewing/tabard
	name = "tabard"
	result = list(/obj/item/clothing/cloak/tabard)
	reqs = list(/obj/item/natural/cloth = 3,
				/obj/item/natural/fibers = 1)
	craftdiff = 3

/datum/crafting_recipe/roguetown/sewing/stabard
	name = "surcoat"
	result = list(/obj/item/clothing/cloak/stabard)
	reqs = list(/obj/item/natural/cloth = 3,
				/obj/item/natural/fibers = 1)
	craftdiff = 3

/datum/crafting_recipe/roguetown/sewing/psydon
	name = "tabard, psydon"
	result = list(/obj/item/clothing/cloak/templar/psydon)
	reqs = list(/obj/item/natural/cloth = 3,
				/obj/item/natural/fibers = 1)
	craftdiff = 3

/datum/crafting_recipe/roguetown/sewing/ravoxgorget
	name = "ravox gorget"
	result = list(/obj/item/clothing/head/roguetown/roguehood/ravoxgorget)
	reqs = list(/obj/item/natural/cloth = 2,
				/obj/item/natural/fibers = 1)
	craftdiff = 3

/datum/crafting_recipe/roguetown/sewing/stabard/guard
	name = "surcoat, guard"
	result = list(/obj/item/clothing/cloak/stabard/guard)

/datum/crafting_recipe/roguetown/sewing/stabard/bog
	name = "surcoat, bog"
	result = list(/obj/item/clothing/cloak/stabard/bog)

/datum/crafting_recipe/roguetown/sewing/stabard/guardhood
	name = "guard hood"
	result = list(/obj/item/clothing/cloak/stabard/guardhood)

/datum/crafting_recipe/roguetown/sewing/poncho
	name = "cloth poncho (1 fiber, 2 cloth)"
	result = /obj/item/clothing/cloak/poncho
	reqs = list(/obj/item/natural/cloth = 2,
				/obj/item/natural/fibers = 1,)
	craftdiff = 2

/datum/crafting_recipe/roguetown/sewing/geta
	name = "geta (4 fibers, 1 cloth)"
	result = /obj/item/clothing/shoes/roguetown/armor/geta
	reqs = list(/obj/item/natural/cloth = 1,
				/obj/item/natural/fibers = 4,)
	craftdiff = 2

/datum/crafting_recipe/roguetown/sewing/rumaclan
	name = "raised sandals (1 log, 1 fiber)"
	result = /obj/item/clothing/shoes/roguetown/armor/rumaclan
	reqs = list(/obj/item/grown/log/tree/small = 1,
				/obj/item/natural/fibers = 1,)
	craftdiff = 2

/datum/crafting_recipe/roguetown/sewing/robe
	name = "robe"
	result = list(/obj/item/clothing/suit/roguetown/shirt/robe)
	reqs = list(/obj/item/natural/cloth = 3,
				/obj/item/natural/fibers = 1)
	craftdiff = 3

/datum/crafting_recipe/roguetown/sewing/haori
	name = "haori (1 fibers, 3 silk)"
	result = list(/obj/item/clothing/suit/roguetown/shirt/robe)
	reqs = list(/obj/item/natural/silk = 3,
				/obj/item/natural/fibers = 1)
	craftdiff = 4

/datum/crafting_recipe/roguetown/sewing/kimono
	name = "kimono (2 fibers, 4 silk)"
	result = list(/obj/item/clothing/suit/roguetown/shirt/undershirt/kimono)
	reqs = list(/obj/item/natural/silk = 4,
				/obj/item/natural/fibers = 2)
	craftdiff = 4

/datum/crafting_recipe/roguetown/sewing/jesterchest
	name = "jester's tunick"
	result = list(/obj/item/clothing/suit/roguetown/shirt/jester)
	reqs = list(/obj/item/natural/cloth = 3,
				/obj/item/natural/fibers = 1)
	craftdiff = 3

/datum/crafting_recipe/roguetown/sewing/jesterhead
	name = "jester's hat"
	result = list(/obj/item/clothing/head/roguetown/jester)
	reqs = list(/obj/item/natural/cloth = 2,
				/obj/item/natural/fibers = 1,
				/obj/item/jingle_bells = 1)
	craftdiff = 3

/datum/crafting_recipe/roguetown/sewing/jestershoes
	name = "jester's shoes"
	result = list(/obj/item/clothing/shoes/roguetown/jester)
	reqs = list(/obj/item/natural/cloth = 2,
				/obj/item/natural/fibers = 1,
				/obj/item/jingle_bells = 1)
	craftdiff = 3

/datum/crafting_recipe/roguetown/sewing/bardress
	name = "bar dress"
	result = list(/obj/item/clothing/suit/roguetown/shirt/dress)
	reqs = list(/obj/item/natural/cloth = 3,
				/obj/item/natural/fibers = 1)
	craftdiff = 4

/datum/crafting_recipe/roguetown/sewing/stockdress
	name = "dress"
	result = list(/obj/item/clothing/suit/roguetown/shirt/dress/gen)
	reqs = list(/obj/item/natural/cloth = 3,
				/obj/item/natural/fibers = 1)
	craftdiff = 4

/* // Best guess why this was marked out, is due to the dye bin being a thing.
datum/crafting_recipe/roguetown/sewing/Bladress
	name = "black dress"
	result = list(/obj/item/clothing/suit/roguetown/shirt/dress/gen/black)
	reqs = list(/obj/item/natural/cloth = 3,
				/obj/item/natural/fibers = 1)
	craftdiff = 4

datum/crafting_recipe/roguetown/sewing/Bludress
	name = "blue dress"
	result = list(/obj/item/clothing/suit/roguetown/shirt/dress/gen/blue)
	reqs = list(/obj/item/natural/cloth = 3,
				/obj/item/natural/fibers = 1)
	craftdiff = 4

datum/crafting_recipe/roguetown/sewing/Purdress
	name = "purple dress"
	result = list(/obj/item/clothing/suit/roguetown/shirt/dress/gen/purple)
	reqs = list(/obj/item/natural/cloth = 3,
				/obj/item/natural/fibers = 1)
	craftdiff = 4
*/
/datum/crafting_recipe/roguetown/sewing/fancyhat
	name = "fancy hat"
	result = list(/obj/item/clothing/head/roguetown/fancyhat)
	reqs = list(/obj/item/natural/cloth = 2,
				/obj/item/natural/fibers = 1)
	craftdiff = 4
	sellprice = 14

/datum/crafting_recipe/roguetown/sewing/gambeson
	name = "gambeson"
	result = /obj/item/clothing/suit/roguetown/armor/gambeson
	reqs = list(/obj/item/natural/cloth = 4,
				/obj/item/natural/fibers = 1)
	tools = list(/obj/item/needle)
	craftdiff = 3
	sellprice = 20

/datum/crafting_recipe/roguetown/sewing/armingjacket
	name = "arming jacket"
	result = /obj/item/clothing/suit/roguetown/armor/gambeson/lord
	reqs = list(/obj/item/natural/cloth = 4,
				/obj/item/natural/fibers = 1)
	tools = list(/obj/item/needle)
	craftdiff = 3

/datum/crafting_recipe/roguetown/sewing/paddedcap
	name = "padded cap"
	result = /obj/item/clothing/head/roguetown/paddedcap
	reqs = list(/obj/item/natural/fibers = 5)
	tools = list(/obj/item/needle)
	craftdiff = 3

/datum/crafting_recipe/roguetown/sewing/bardhat
	name = "bard hat"
	result = list(/obj/item/clothing/head/roguetown/bardhat)
	reqs = list(/obj/item/natural/cloth = 2,
				/obj/item/natural/fibers = 1)
	craftdiff = 4
	sellprice = 14

/datum/crafting_recipe/roguetown/sewing/bucklehat
	name = "folded hat"
	result = list(/obj/item/clothing/head/roguetown/bucklehat)
	reqs = list(/obj/item/natural/cloth = 2,
				/obj/item/natural/fibers = 1)
	craftdiff = 4
	sellprice = 14

/datum/crafting_recipe/roguetown/sewing/archer
	name = "archer cap"
	result = list(/obj/item/clothing/head/roguetown/archercap)
	reqs = list(/obj/item/natural/cloth = 2,
				/obj/item/natural/fibers = 1)
	craftdiff = 4
	sellprice = 14

/datum/crafting_recipe/roguetown/sewing/duelist
	name = "duelist hat"
	result = list(/obj/item/clothing/head/roguetown/duelhat)
	reqs = list(/obj/item/natural/cloth = 2,
				/obj/item/natural/fibers = 1)
	craftdiff = 4
	sellprice = 14

/datum/crafting_recipe/roguetown/sewing/witchhat
	name = "witch hat"
	result = list(/obj/item/clothing/head/roguetown/witchhat)
	reqs = list(/obj/item/natural/cloth = 2,
				/obj/item/natural/fibers = 1)
	craftdiff = 4
	sellprice = 14

/datum/crafting_recipe/roguetown/sewing/hgambeson
    name = "padded gambeson"
    result = list(/obj/item/clothing/suit/roguetown/armor/gambeson/heavy)
    reqs = list(/obj/item/natural/cloth = 6,
                /obj/item/natural/fibers = 4)
    craftdiff = 3

/datum/crafting_recipe/roguetown/sewing/hgambeson/fencer
	name = "fencing shirt"
	result = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/freifechter
	reqs = list(/obj/item/natural/cloth = 5,
				/obj/item/natural/fibers = 2)
	craftdiff = 4

/datum/crafting_recipe/roguetown/sewing/chaperon
	name = "chaperon hat"
	result = list(/obj/item/clothing/head/roguetown/chaperon)
	reqs = list(/obj/item/natural/cloth = 2,
				/obj/item/natural/fibers = 1)
	craftdiff = 3
	sellprice = 14

/datum/crafting_recipe/roguetown/sewing/chaperon/noble
    name = "noble's chaperon"
    result = list(/obj/item/clothing/head/roguetown/chaperon/noble)
    reqs = list(/obj/item/natural/cloth = 4,
                /obj/item/natural/fibers = 2)
    craftdiff = 4

/datum/crafting_recipe/roguetown/sewing/jupon
	name = "jupon"
	result = list(/obj/item/clothing/cloak/stabard/surcoat)
	reqs = list(/obj/item/natural/cloth = 3,
				/obj/item/natural/fibers = 1)
	craftdiff = 4

/datum/crafting_recipe/roguetown/sewing/armordress
	name = "padded dress"
	result = list(/obj/item/clothing/suit/roguetown/armor/armordress)
	reqs = list(/obj/item/natural/cloth = 2,
				/obj/item/natural/fibers = 1,
				/obj/item/natural/hide/cured = 1)
	craftdiff = 3
	sellprice = 30

/datum/crafting_recipe/roguetown/sewing/ragmask
	name = "rag mask"
	result = list(/obj/item/clothing/mask/rogue/ragmask)
	reqs = list(/obj/item/natural/cloth = 1)
	craftdiff = 0
	sellprice = 3

/datum/crafting_recipe/roguetown/sewing/cape
	name = "cape"
	result = list(/obj/item/clothing/cloak/cape)
	reqs = list(/obj/item/natural/cloth = 2,
				/obj/item/natural/fibers = 1)
	craftdiff = 3
	sellprice = 12

/datum/crafting_recipe/roguetown/sewing/sexydress
	name = "sheer dress"
	result = list(/obj/item/clothing/suit/roguetown/shirt/dress/gen/sexy)
	reqs = list(/obj/item/natural/cloth = 6,
				/obj/item/natural/fibers = 3)
	craftdiff = 5
	sellprice = 20

/datum/crafting_recipe/roguetown/sewing/wizhatblue
	name = "blue wizard hat"
	result = list(/obj/item/clothing/head/roguetown/wizhat)
	reqs = list(/obj/item/natural/cloth = 2,
				/obj/item/natural/fibers = 1)
	craftdiff = 3
	sellprice = 12

/datum/crafting_recipe/roguetown/sewing/wizhatred
	name = "red wizard hat"
	result = list(/obj/item/clothing/head/roguetown/wizhat/red)
	reqs = list(/obj/item/natural/cloth = 2,
				/obj/item/natural/fibers = 1)
	craftdiff = 3
	sellprice = 12

/datum/crafting_recipe/roguetown/sewing/wizhatyellow
	name = "yellow wizard hat"
	result = list(/obj/item/clothing/head/roguetown/wizhat/yellow)
	reqs = list(/obj/item/natural/cloth = 2,
				/obj/item/natural/fibers = 1)
	craftdiff = 3
	sellprice = 12

/datum/crafting_recipe/roguetown/sewing/wizhatgreen
	name = "green wizard hat"
	result = list(/obj/item/clothing/head/roguetown/wizhat/green)
	reqs = list(/obj/item/natural/cloth = 2,
				/obj/item/natural/fibers = 1)
	craftdiff = 3
	sellprice = 12

/datum/crafting_recipe/roguetown/sewing/wizhatblack
	name = "black wizard hat"
	result = list(/obj/item/clothing/head/roguetown/wizhat/black)
	reqs = list(/obj/item/natural/cloth = 2,
				/obj/item/natural/fibers = 1)
	craftdiff = 3
	sellprice = 12

/datum/crafting_recipe/roguetown/sewing/cape/desert
	name = "desert cape"
	result = list(/obj/item/clothing/cloak/cape/crusader)
	reqs = list(/obj/item/natural/cloth = 4,
				/obj/item/natural/fibers = 2)
	craftdiff = 3

/datum/crafting_recipe/roguetown/sewing/cape/rider
	name = "rider cloak"
	result = list(/obj/item/clothing/cloak/half/rider)
	reqs = list(/obj/item/natural/cloth = 3,
				/obj/item/natural/fibers = 1)
	craftdiff = 3

/datum/crafting_recipe/roguetown/sewing/cape/half
	name = "half cloak"
	result = list(/obj/item/clothing/cloak/half)
	reqs = list(/obj/item/natural/cloth = 3,
				/obj/item/natural/fibers = 1)
	craftdiff = 3

/datum/crafting_recipe/roguetown/sewing/undervestments
	name = "undervestments"
	result = list(/obj/item/clothing/suit/roguetown/shirt/undershirt/priest)
	reqs = list(/obj/item/natural/cloth = 3,
				/obj/item/natural/fibers = 1)
	craftdiff = 3

/datum/crafting_recipe/roguetown/sewing/keffiyeh
	name = "keffiyeh"
	result = list(/obj/item/clothing/head/roguetown/roguehood/shalal)
	reqs = list(/obj/item/natural/cloth = 2,
				/obj/item/natural/fibers = 1)
	craftdiff = 3

/datum/crafting_recipe/roguetown/sewing/hijab
	name = "hijab"
	result = list(/obj/item/clothing/head/roguetown/roguehood/shalal/hijab)
	reqs = list(/obj/item/natural/cloth = 2,
				/obj/item/natural/fibers = 1)
	craftdiff = 3

/datum/crafting_recipe/roguetown/sewing/heavyhood
	name = "heavy hood"
	result = list(/obj/item/clothing/head/roguetown/roguehood/shalal/heavyhood)
	reqs = list(/obj/item/natural/cloth = 2,
				/obj/item/natural/fibers = 1)
	craftdiff = 3

/datum/crafting_recipe/roguetown/sewing/scarf
	name = "scarf (1 fibers, 1 cloth)"
	result = list(/obj/item/clothing/head/roguetown/scarf)
	reqs = list(/obj/item/natural/cloth = 1,
				/obj/item/natural/fibers = 1)
	craftdiff = 2

/datum/crafting_recipe/roguetown/sewing/hijabkazengunese
	name = "kazengunese headwrap (2 silk, 2 fibers, 3 cloth)"
	result = list(/obj/item/clothing/head/roguetown/roguehood/shalal/hijab/kazengunese)
	reqs = list(/obj/item/natural/cloth = 3,
				/obj/item/natural/fibers = 2,
				/obj/item/natural/silk = 2)
	craftdiff = 3

/datum/crafting_recipe/roguetown/sewing/hijabyoroku
	name = "shadowed hood (2 silk, 1 fiber, 2 cloth)"
	result = list(/obj/item/clothing/head/roguetown/roguehood/shalal/hijab/yoruku)
	reqs = list(/obj/item/natural/cloth = 2,
				/obj/item/natural/fibers = 1,
				/obj/item/natural/silk = 2)
	craftdiff = 3

/datum/crafting_recipe/roguetown/sewing/royalgown
	name = "royal gown"
	result = list(/obj/item/clothing/suit/roguetown/shirt/dress/royal)
	reqs = list(/obj/item/natural/cloth = 3,
				/obj/item/natural/fibers = 2,
				/obj/item/natural/silk = 3)
	tools = list(/obj/item/needle)
	craftdiff = 6
	sellprice = 45

/datum/crafting_recipe/roguetown/sewing/royaldress
	name = "pristine dress"
	result = list(/obj/item/clothing/suit/roguetown/shirt/dress/royal/princess)
	reqs = list(/obj/item/natural/cloth = 3,
				/obj/item/natural/fibers = 2,
				/obj/item/natural/silk = 2)
	tools = list(/obj/item/needle)
	craftdiff = 5
	sellprice = 30

/datum/crafting_recipe/roguetown/sewing/royalshirt
	name = "gilded dress shirt"
	result = list(/obj/item/clothing/suit/roguetown/shirt/dress/royal/prince)
	reqs = list(/obj/item/natural/cloth = 3,
				/obj/item/natural/fibers = 2,
				/obj/item/natural/silk = 2)
	tools = list(/obj/item/needle)
	craftdiff = 5
	sellprice = 30

/datum/crafting_recipe/roguetown/sewing/nobledress
	name = "noble dress"
	result = list(/obj/item/clothing/suit/roguetown/shirt/dress/noble)
	reqs = list(/obj/item/natural/cloth = 4,
				/obj/item/natural/fibers = 3,
				/obj/item/natural/silk = 3)
	tools = list(/obj/item/needle)
	craftdiff = 6
	sellprice = 55

/datum/crafting_recipe/roguetown/sewing/velvetdress
	name = "velvet dress"
	result = list(/obj/item/clothing/suit/roguetown/shirt/dress/velvet)
	reqs = list(/obj/item/natural/cloth = 5,
				/obj/item/natural/fibers = 4,
				/obj/item/natural/silk = 4)
	tools = list(/obj/item/needle)
	craftdiff = 7
	sellprice = 65

/datum/crafting_recipe/roguetown/sewing/regalrobes
	name = "regal silks"
	result = list(/obj/item/clothing/suit/roguetown/shirt/vampire)
	reqs = list(/obj/item/natural/cloth = 2,
				/obj/item/natural/fibers = 2,
				/obj/item/natural/silk = 2)
	tools = list(/obj/item/needle)
	craftdiff = 5
	sellprice = 30

/datum/crafting_recipe/roguetown/sewing/grenzelshirt
	name = "grenzelhoftian hip-shirt"
	result = list(/obj/item/clothing/suit/roguetown/armor/gambeson/heavy/grenzelhoft)
	reqs = list(/obj/item/natural/cloth = 6,
				/obj/item/natural/fibers = 4,
				/obj/item/natural/silk = 1)
	tools = list(/obj/item/needle)
	craftdiff = 5

/datum/crafting_recipe/roguetown/sewing/silktunic
	name = "ornate silk tunic"
	result = list(/obj/item/clothing/suit/roguetown/shirt/tunic/silktunic)
	reqs = list(/obj/item/natural/cloth = 2,
				/obj/item/natural/fibers = 2,
				/obj/item/natural/silk = 2)
	tools = list(/obj/item/needle)
	craftdiff = 5
	sellprice = 25

/datum/crafting_recipe/roguetown/sewing/silkdress
	name = "ornate silk dress"
	result = list(/obj/item/clothing/suit/roguetown/shirt/dress/silkdress/steward)
	reqs = list(/obj/item/natural/cloth = 2,
				/obj/item/natural/fibers = 2,
				/obj/item/natural/silk = 2)
	tools = list(/obj/item/needle)
	craftdiff = 5
	sellprice = 30

/datum/crafting_recipe/roguetown/sewing/archivist
	name = "archivist's robes"
	result = list(/obj/item/clothing/suit/roguetown/shirt/robe/archivist)
	reqs = list(/obj/item/natural/cloth = 2,
				/obj/item/natural/fibers = 2,
				/obj/item/natural/silk = 1)
	tools = list(/obj/item/needle)
	craftdiff = 5
	sellprice = 25

/datum/crafting_recipe/roguetown/sewing/apothshirt
	name = "apothecary shirt"
	result = list(/obj/item/clothing/suit/roguetown/shirt/apothshirt)
	reqs = list(/obj/item/natural/cloth = 2,
				/obj/item/natural/fibers = 2)
	tools = list(/obj/item/needle)
	craftdiff = 4
	sellprice = 15

/datum/crafting_recipe/roguetown/sewing/artificer
	name = "tinker doublet"
	result = list(/obj/item/clothing/suit/roguetown/shirt/undershirt/artificer)
	reqs = list(/obj/item/natural/cloth = 2,
				/obj/item/natural/fibers = 2,
				/obj/item/natural/hide/cured = 1)
	tools = list(/obj/item/needle)
	craftdiff = 4
	sellprice = 20

/datum/crafting_recipe/roguetown/sewing/winterdress
	name = "winter dress"
	result = list(/obj/item/clothing/suit/roguetown/armor/armordress/winterdress)
	reqs = list(/obj/item/natural/cloth = 4,
				/obj/item/natural/fibers = 2,
				/obj/item/natural/silk = 2)
	tools = list(/obj/item/needle)
	craftdiff = 5
	sellprice = 25

/datum/crafting_recipe/roguetown/sewing/winterdress_light
	name = "cold dress"
	result = list(/obj/item/clothing/suit/roguetown/shirt/dress/winterdress_light)
	reqs = list(/obj/item/natural/cloth = 2,
				/obj/item/natural/fibers = 2,
				/obj/item/natural/silk = 1)
	tools = list(/obj/item/needle)
	craftdiff = 3
	sellprice = 10

/datum/crafting_recipe/roguetown/sewing/skirt
	name = "skirt"
	result = list(/obj/item/clothing/under/roguetown/skirt)
	reqs = list(/obj/item/natural/cloth = 1,
				/obj/item/natural/fibers = 2)
	tools = list(/obj/item/needle)
	craftdiff = 4
	sellprice = 10

/datum/crafting_recipe/roguetown/sewing/sailorspants
	name = "sailor's pants"
	result = list(/obj/item/clothing/under/roguetown/tights/sailor)
	reqs = list(/obj/item/natural/cloth = 1,
				/obj/item/natural/fibers = 1)
	tools = list(/obj/item/needle)
	craftdiff = 3
	sellprice = 5

/datum/crafting_recipe/roguetown/sewing/grenzelpants
	name = "grenzelhoftian paumpers"
	result = list(/obj/item/clothing/under/roguetown/heavy_leather_pants/grenzelpants)
	reqs = list(/obj/item/natural/cloth = 4,
				/obj/item/natural/fibers = 2,
				/obj/item/natural/hide/cured = 1)
	tools = list(/obj/item/needle)
	craftdiff = 4
	sellprice = 25

/datum/crafting_recipe/roguetown/sewing/shadowpants
	name = "silk tights"
	result = list(/obj/item/clothing/under/roguetown/trou/shadowpants)
	reqs = list(/obj/item/natural/cloth = 2,
	            /obj/item/natural/silk = 2)
	tools = list(/obj/item/needle)
	craftdiff = 4
	sellprice = 18

/datum/crafting_recipe/roguetown/sewing/apothpants
	name = "apothecary trousers"
	result = list(/obj/item/clothing/under/roguetown/trou/apothecary)
	reqs = list(/obj/item/natural/cloth = 2,
	            /obj/item/natural/fibers = 2)
	tools = list(/obj/item/needle)
	craftdiff = 4
	sellprice = 14

/datum/crafting_recipe/roguetown/sewing/royalsleeves
	name = "royal sleeves"
	result = list(/obj/item/clothing/wrists/roguetown/royalsleeves)
	reqs = list(/obj/item/natural/cloth = 1,
	            /obj/item/natural/fibers = 2,
				/obj/item/natural/silk = 1)
	tools = list(/obj/item/needle)
	craftdiff = 5
	sellprice = 19

/datum/crafting_recipe/roguetown/sewing/nemes
	name = "nemes"
	result = list(/obj/item/clothing/head/roguetown/headdress)
	reqs = list(/obj/item/natural/cloth = 2,
	            /obj/item/natural/fibers = 2)
	tools = list(/obj/item/needle)
	craftdiff = 4
	sellprice = 10

/datum/crafting_recipe/roguetown/sewing/hatfur
	name = "fur hat"
	result = list(/obj/item/clothing/head/roguetown/hatfur)
	reqs = list(/obj/item/natural/cloth = 1,
	            /obj/item/natural/fibers = 1,
				/obj/item/natural/fur = 1)
	tools = list(/obj/item/needle)
	craftdiff = 3
	sellprice = 14

/datum/crafting_recipe/roguetown/sewing/shawl
	name = "shawl"
	result = list(/obj/item/clothing/head/roguetown/shawl)
	reqs = list(/obj/item/natural/cloth = 1)
	tools = list(/obj/item/needle)
	craftdiff = 2
	sellprice = 5

/datum/crafting_recipe/roguetown/sewing/grenzelhat
	name = "grenzelhoftian hat"
	result = list(/obj/item/clothing/head/roguetown/grenzelhofthat)
	reqs = list(/obj/item/natural/cloth = 1,
	            /obj/item/natural/fibers = 1,
				/obj/item/natural/silk = 2)
	tools = list(/obj/item/needle)
	craftdiff = 5
	sellprice = 15

/datum/crafting_recipe/roguetown/sewing/articap
	name = "artificer's cap"
	result = list(/obj/item/clothing/head/roguetown/articap)
	reqs = list(/obj/item/natural/cloth = 1,
	            /obj/item/natural/fibers = 1,
				/obj/item/natural/hide/cured = 1)
	tools = list(/obj/item/needle)
	craftdiff = 4
	sellprice = 14

/datum/crafting_recipe/roguetown/sewing/lordlycloak
	name = "lordly cloak"
	result = list(/obj/item/clothing/cloak/lordcloak)
	reqs = list(/obj/item/natural/cloth = 3,
	            /obj/item/natural/fibers = 2,
				/obj/item/natural/fur = 2,
				/obj/item/natural/silk = 2)
	tools = list(/obj/item/needle)
	craftdiff = 6
	sellprice = 35

/datum/crafting_recipe/roguetown/sewing/naledisash
	name = "hierophant's sash"
	result = list(/obj/item/clothing/cloak/hierophant)
	reqs = list(/obj/item/natural/cloth = 2,
	            /obj/item/natural/fibers = 2)
	tools = list(/obj/item/needle)
	craftdiff = 4
	sellprice = 15

/datum/crafting_recipe/roguetown/sewing/ladycloak
	name = "ladylike shortcloak"
	result = list(/obj/item/clothing/cloak/lordcloak/ladycloak)
	reqs = list(/obj/item/natural/cloth = 2,
	            /obj/item/natural/fibers = 2,
			    /obj/item/natural/silk = 2,
				/obj/item/natural/fur = 1)
	tools = list(/obj/item/needle)
	craftdiff = 6
	sellprice = 30

/datum/crafting_recipe/roguetown/sewing/furovercoat
	name = "fur overcoat"
	result = list(/obj/item/clothing/cloak/black_cloak)
	reqs = list(/obj/item/natural/cloth = 3,
	            /obj/item/natural/fibers = 1,
				/obj/item/natural/silk = 1,
				/obj/item/natural/fur = 1)
	tools = list(/obj/item/needle)
	craftdiff = 5
	sellprice = 22

/datum/crafting_recipe/roguetown/sewing/guildedjacket
	name = "guilder jacket"
	result = list(/obj/item/clothing/suit/roguetown/shirt/robe/merchant)
	reqs = list(/obj/item/natural/cloth = 3,
	            /obj/item/natural/fibers = 2)
	tools = list(/obj/item/needle)
	craftdiff = 5
	sellprice = 19

/datum/crafting_recipe/roguetown/sewing/buttonedlongcoat
	name = "plague coat"
	result = list(/obj/item/clothing/suit/roguetown/shirt/robe/physician)
	reqs = list(/obj/item/natural/cloth = 3,
	            /obj/item/natural/fibers = 2)
	tools = list(/obj/item/needle)
	craftdiff = 5
	sellprice = 20

/datum/crafting_recipe/roguetown/sewing/desertgown
	name = "hierophant's kandys"
	result = list(/obj/item/clothing/suit/roguetown/shirt/robe/hierophant)
	reqs = list(/obj/item/natural/cloth = 6,
	            /obj/item/natural/fibers = 4)
	tools = list(/obj/item/needle)
	craftdiff = 4
	sellprice = 17

/datum/crafting_recipe/roguetown/sewing/halfrobe
	name = "hierophant's shawl"
	result = list(/obj/item/clothing/suit/roguetown/armor/gambeson/heavy/hierophant)
	reqs = list(/obj/item/natural/cloth = 6,
	            /obj/item/natural/fibers = 5)
	tools = list(/obj/item/needle)
	craftdiff = 4
	sellprice = 15

/datum/crafting_recipe/roguetown/sewing/monkrobe
	name = "pontifex's qaba"
	result = list(/obj/item/clothing/suit/roguetown/shirt/robe/pointfex)
	reqs = list(/obj/item/natural/cloth = 6,
	            /obj/item/natural/fibers = 5)
	tools = list(/obj/item/needle)
	craftdiff = 4
	sellprice = 15

/datum/crafting_recipe/roguetown/sewing/otavangambeson
	name = "otavan gambeson"
	result = list(/obj/item/clothing/suit/roguetown/armor/gambeson/heavy/otavan)
	reqs = list(/obj/item/natural/cloth = 6,
	            /obj/item/natural/fibers = 5)
	tools = list(/obj/item/needle)
	craftdiff = 6

/datum/crafting_recipe/roguetown/sewing/sleevelessrobe
	name = "feldsher's robe"
	result = list(/obj/item/clothing/suit/roguetown/shirt/robe/phys)
	reqs = list(/obj/item/natural/cloth = 3,
	            /obj/item/natural/fibers = 2)
	tools = list(/obj/item/needle)
	craftdiff = 4
	sellprice = 13

/datum/crafting_recipe/roguetown/sewing/weddingdress
	name = "wedding silk dress"
	result = list(/obj/item/clothing/suit/roguetown/shirt/dress/silkdress/weddingdress)
	reqs = list(/obj/item/natural/cloth = 2,
				/obj/item/natural/fibers = 2,
				/obj/item/natural/silk = 2,
				/obj/item/alch/golddust = 1)
	tools = list(/obj/item/needle)
	craftdiff = 5
	sellprice = 40

/datum/crafting_recipe/roguetown/sewing/silkydress
	name = "silky dress"
	result = /obj/item/clothing/suit/roguetown/shirt/dress/silkydress
	reqs = list(/obj/item/natural/cloth = 6,
				/obj/item/natural/fibers = 3)
	tools = list(/obj/item/needle)
	craftdiff = 6
	sellprice = 50

/datum/crafting_recipe/roguetown/sewing/weaving/springgown
	name = "gown (spring)"
	result = /obj/item/clothing/suit/roguetown/shirt/dress/gown
	reqs = list(/obj/item/natural/cloth = 3,
				/obj/item/natural/silk = 4)
	craftdiff = 6
	sellprice = 85

/datum/crafting_recipe/roguetown/sewing/weaving/summergown
	name = "gown (summer)"
	result = /obj/item/clothing/suit/roguetown/shirt/dress/gown/summergown
	reqs = list(/obj/item/natural/fibers = 2,
				/obj/item/natural/cloth = 1,
				/obj/item/natural/silk = 3)
	craftdiff = 6
	sellprice = 70

/datum/crafting_recipe/roguetown/sewing/weaving/fallgown
	name = "gown (fall, silk)"
	result = /obj/item/clothing/suit/roguetown/shirt/dress/gown/fallgown
	reqs = list(/obj/item/natural/fibers = 3,
				/obj/item/natural/silk = 2,
				/obj/item/natural/cloth = 2)
	craftdiff = 6
	sellprice = 75

/datum/crafting_recipe/roguetown/sewing/weaving/wintergown
	name = "gown (winter)"
	result = /obj/item/clothing/suit/roguetown/shirt/dress/gown/wintergown
	reqs = list(/obj/item/natural/fibers = 3,
				/obj/item/natural/silk = 2,
				/obj/item/natural/fur = 1)
	craftdiff = 6
	sellprice = 90

/datum/crafting_recipe/roguetown/sewing/exoticsilkbra
	name = "exotic silk bra"
	result = list (/obj/item/clothing/suit/roguetown/shirt/exoticsilkbra)
	reqs = list(/obj/item/natural/silk = 5)
	craftdiff = 6

/datum/crafting_recipe/roguetown/sewing/anklets
	name = "exotic silk anklets"
	result = list (/obj/item/clothing/shoes/roguetown/anklets)
	reqs = list(/obj/item/natural/silk = 5)
	craftdiff = 6

/datum/crafting_recipe/roguetown/sewing/exoticsilkbelt
	name = "exotic silk belt"
	result = list (/obj/item/storage/belt/rogue/leather/exoticsilkbelt)
	reqs = list(/obj/item/natural/silk = 5)
	craftdiff = 6

/datum/crafting_recipe/roguetown/sewing/exoticsilkmask
	name = "exotic silk mask"
	result = list (/obj/item/clothing/mask/rogue/exoticsilkmask)
	reqs = list(/obj/item/natural/silk = 5)
	craftdiff = 6

/datum/crafting_recipe/roguetown/sewing/strapless_dress
	name = "strapless dress"
	result = list(/obj/item/clothing/suit/roguetown/shirt/dress/gen/strapless)
	reqs = list(/obj/item/natural/cloth = 2,
				/obj/item/natural/fibers = 1)
	craftdiff = 3

/datum/crafting_recipe/roguetown/sewing/strapless_dress_alt
	name = "strapless dress alt"
	result = list(/obj/item/clothing/suit/roguetown/shirt/dress/gen/strapless/alt)
	reqs = list(/obj/item/natural/cloth = 1,
				/obj/item/natural/fibers = 1)
	craftdiff = 3

/datum/crafting_recipe/roguetown/sewing/spellsingerrobes
	name = "spellsinger robes"
	result = list(/obj/item/clothing/suit/roguetown/shirt/robe/spellcasterrobe)
	reqs = list(/obj/item/natural/cloth = 6,
	            /obj/item/natural/fibers = 4,
				/obj/item/natural/silk = 1)
	tools = list(/obj/item/needle)
	craftdiff = 6
	sellprice = 30

/datum/crafting_recipe/roguetown/sewing/spellsingerhat
	name = "spellsinger hat"
	result = list(/obj/item/clothing/head/roguetown/spellcasterhat)
	reqs = list(/obj/item/natural/cloth = 1,
	            /obj/item/natural/fibers = 1,
				/obj/item/natural/silk = 2)
	tools = list(/obj/item/needle)
	craftdiff = 6
	sellprice = 20

/datum/crafting_recipe/roguetown/sewing/beekeeper
	name = "beekeeper's hood"
	result = list(/obj/item/clothing/head/roguetown/beekeeper)
	reqs = list(/obj/item/natural/cloth = 3,
				/obj/item/natural/fibers = 4)
	craftdiff = 2

/datum/crafting_recipe/roguetown/sewing/battleskirt
	name = "cloth military skirt"
	result = list(/obj/item/storage/belt/rogue/leather/battleskirt)
	reqs = list(
		/obj/item/natural/cloth = 3,
		/obj/item/natural/hide/cured = 1
	)
	craftdiff = 2

/datum/crafting_recipe/roguetown/sewing/fauldedbelt
	name = "belt with faulds"
	result = list(/obj/item/storage/belt/rogue/leather/battleskirt/faulds)
	reqs = list(
		/obj/item/natural/cloth = 3,
		/obj/item/natural/hide/cured = 1
	)
	craftdiff = 2

/datum/crafting_recipe/roguetown/sewing/surgicalbag
	name = "surgeon's bag"
	result = list(/obj/item/storage/belt/rogue/surgery_bag/empty)
	reqs = list(/obj/item/natural/cloth = 3,
				/obj/item/natural/fibers = 1)
	craftdiff = 4

/datum/crafting_recipe/roguetown/sewing/surgcollar
	name = "surgeon's collar"
	result = list(/obj/item/clothing/neck/roguetown/collar/surgcollar)
	reqs = list(/obj/item/natural/cloth = 1, /obj/item/natural/fibers = 1)
	craftdiff = 1

/datum/crafting_recipe/roguetown/sewing/feldcollar
	name = "feldsher's collar"
	result = list(/obj/item/clothing/neck/roguetown/collar/feldcollar)
	reqs = list(/obj/item/natural/cloth = 1, /obj/item/natural/fibers = 1)
	craftdiff = 1

/datum/crafting_recipe/roguetown/sewing/inquisitori
	name = "inquisitori tabard"
	result = list(/obj/item/clothing/cloak/psydontabard)
	reqs = list(/obj/item/natural/cloth = 2, /obj/item/natural/fibers = 1)
	tools = list(/obj/item/needle)
	craftdiff = 3

// tennite templar tabards

/datum/crafting_recipe/roguetown/sewing/templar_astrata
	name = "tabard templar, astrata"
	result = list(/obj/item/clothing/cloak/templar/astratan)
	reqs = list(/obj/item/natural/cloth = 2, /obj/item/natural/fibers = 1)
	tools = list(/obj/item/needle)
	craftdiff = 3

/datum/crafting_recipe/roguetown/sewing/templar_malum
	name = "tabard templar, malum"
	result = list(/obj/item/clothing/cloak/templar/malumite)
	reqs = list(/obj/item/natural/cloth = 2, /obj/item/natural/fibers = 1)
	tools = list(/obj/item/needle)
	craftdiff = 3

/datum/crafting_recipe/roguetown/sewing/templar_necra
	name = "tabard templar, necra"
	result = list(/obj/item/clothing/cloak/templar/necran)
	reqs = list(/obj/item/natural/cloth = 2, /obj/item/natural/fibers = 1)
	tools = list(/obj/item/needle)
	craftdiff = 3

/datum/crafting_recipe/roguetown/sewing/templar_pestra
	name = "tabard templar, pestra"
	result = list(/obj/item/clothing/cloak/templar/pestran)
	reqs = list(/obj/item/natural/cloth = 2, /obj/item/natural/fibers = 1)
	tools = list(/obj/item/needle)
	craftdiff = 3

/datum/crafting_recipe/roguetown/sewing/templar_eora
	name = "tabard templar, eora"
	result = list(/obj/item/clothing/cloak/templar/eoran)
	reqs = list(/obj/item/natural/cloth = 2, /obj/item/natural/fibers = 1)
	tools = list(/obj/item/needle)
	craftdiff = 3

/datum/crafting_recipe/roguetown/sewing/templar_xylix
	name = "tabard templar, xylix"
	result = list(/obj/item/clothing/cloak/templar/xylixian)
	reqs = list(/obj/item/natural/cloth = 2, /obj/item/natural/fibers = 1)
	tools = list(/obj/item/needle)
	craftdiff = 3

/datum/crafting_recipe/roguetown/sewing/templar_abyssor
	name = "tabard templar, abyssor"
	result = list(/obj/item/clothing/cloak/abyssortabard)
	reqs = list(/obj/item/natural/cloth = 2, /obj/item/natural/fibers = 1)
	tools = list(/obj/item/needle)
	craftdiff = 3

/datum/crafting_recipe/roguetown/sewing/templar_dendor
	name = "tabard templar, dendor"
	result = list(/obj/item/clothing/cloak/tabard/crusader/dendor)
	reqs = list(/obj/item/natural/cloth = 2, /obj/item/natural/fibers = 1)
	tools = list(/obj/item/needle)
	craftdiff = 3

/datum/crafting_recipe/roguetown/sewing/templar_noc
	name = "tabard templar, noc"
	result = list(/obj/item/clothing/cloak/tabard/crusader/noc)
	reqs = list(/obj/item/natural/cloth = 2, /obj/item/natural/fibers = 1)
	tools = list(/obj/item/needle)
	craftdiff = 3

/datum/crafting_recipe/roguetown/sewing/templar_ravox
	name = "tabard templar, ravox"
	result = list(/obj/item/clothing/cloak/templar/ravox)
	reqs = list(/obj/item/natural/cloth = 2, /obj/item/natural/fibers = 1)
	tools = list(/obj/item/needle)
	craftdiff = 3

// tennite soldier tabards

/datum/crafting_recipe/roguetown/sewing/soldier_astrata
	name = "tabard soldier, astrata"
	result = list(/obj/item/clothing/cloak/templar/astrata)
	reqs = list(/obj/item/natural/cloth = 1, /obj/item/natural/fibers = 1)
	tools = list(/obj/item/needle)
	craftdiff = 2

/datum/crafting_recipe/roguetown/sewing/soldier_malum
	name = "tabard soldier, malum"
	result = list(/obj/item/clothing/cloak/templar/malum)
	reqs = list(/obj/item/natural/cloth = 1, /obj/item/natural/fibers = 1)
	tools = list(/obj/item/needle)
	craftdiff = 2

/datum/crafting_recipe/roguetown/sewing/soldier_necra
	name = "tabard soldier, necra"
	result = list(/obj/item/clothing/cloak/templar/necra)
	reqs = list(/obj/item/natural/cloth = 1, /obj/item/natural/fibers = 1)
	tools = list(/obj/item/needle)
	craftdiff = 2

/datum/crafting_recipe/roguetown/sewing/soldier_pestra
	name = "tabard soldier, pestra"
	result = list(/obj/item/clothing/cloak/templar/pestra)
	reqs = list(/obj/item/natural/cloth = 1, /obj/item/natural/fibers = 1)
	tools = list(/obj/item/needle)
	craftdiff = 2

/datum/crafting_recipe/roguetown/sewing/soldier_eora
	name = "tabard soldier, eora"
	result = list(/obj/item/clothing/cloak/templar/eora)
	reqs = list(/obj/item/natural/cloth = 1, /obj/item/natural/fibers = 1)
	tools = list(/obj/item/needle)
	craftdiff = 2

/datum/crafting_recipe/roguetown/sewing/soldier_xylix
	name = "tabard soldier, xylix"
	result = list(/obj/item/clothing/cloak/templar/xylix)
	reqs = list(/obj/item/natural/cloth = 1, /obj/item/natural/fibers = 1)
	tools = list(/obj/item/needle)
	craftdiff = 2

/datum/crafting_recipe/roguetown/sewing/soldier_abyssor
	name = "tabard soldier, abyssor"
	result = list(/obj/item/clothing/cloak/templar/abyssor)
	reqs = list(/obj/item/natural/cloth = 1, /obj/item/natural/fibers = 1)
	tools = list(/obj/item/needle)
	craftdiff = 2

/datum/crafting_recipe/roguetown/sewing/soldier_dendor
	name = "tabard soldier, dendor"
	result = list(/obj/item/clothing/cloak/templar/dendor)
	reqs = list(/obj/item/natural/cloth = 1, /obj/item/natural/fibers = 1)
	tools = list(/obj/item/needle)
	craftdiff = 2

/datum/crafting_recipe/roguetown/sewing/soldier_noc
	name = "tabard soldier, noc"
	result = list(/obj/item/clothing/cloak/templar/noc)
	reqs = list(/obj/item/natural/cloth = 1, /obj/item/natural/fibers = 1)
	tools = list(/obj/item/needle)
	craftdiff = 2

/datum/crafting_recipe/roguetown/sewing/soldier_ravox
	name = "tabard soldier, ravox"
	result = list(/obj/item/clothing/cloak/cleric/ravox)
	reqs = list(/obj/item/natural/cloth = 1, /obj/item/natural/fibers = 1)
	tools = list(/obj/item/needle)
	craftdiff = 2

/datum/crafting_recipe/roguetown/sewing/sackmask
	name = "sackmask (3 leather, 2 cloth)"
	result = list(/obj/item/clothing/mask/rogue/sack)
	reqs = list(/obj/item/natural/cloth = 2, /obj/item/natural/hide/cured = 3)
	tools = list(/obj/item/needle)
	craftdiff = 3

/datum/crafting_recipe/roguetown/sewing/sackmask/psy
	name = "psydonian sack mask (chalk)"
	result = list(/obj/item/clothing/mask/rogue/sack/psy)
	reqs = list(/obj/item/clothing/mask/rogue/sack = 1)
	tools = list(/obj/item/ritechalk)
	craftdiff = 0

////// OGRE - GIANT CLOTHES ///////
/datum/crafting_recipe/roguetown/sewing/giant_shirt
	name = "giant shirt"
	reqs = list(
		/obj/item/natural/cloth = 4,
		/obj/item/natural/fibers = 2,
	)
	result = /obj/item/clothing/suit/roguetown/shirt/ogre

/datum/crafting_recipe/roguetown/sewing/giant_pants
	name = "giant pants"
	reqs = list(
		/obj/item/natural/cloth = 4,
		/obj/item/natural/fibers = 2,
	)
	result = /obj/item/clothing/under/roguetown/tights/ogre
