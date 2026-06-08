/datum/crafting_recipe/roguetown/structure/composter
	name = "composter"
	result = /obj/structure/composter
	reqs = list(/obj/item/grown/log/tree/small = 1)
	verbage_simple = "build"
	verbage = "builds"
	craftdiff = 0
	time = 2 SECONDS

/datum/crafting_recipe/roguetown/structure/plough
	name = "plough"
	result = /obj/structure/plough
	reqs = list(/obj/item/grown/log/tree/small = 2, /obj/item/ingot/iron = 1)
	verbage_simple = "construct"
	verbage = "constructs"
	skillcraft = /datum/skill/craft/carpentry
	time = 4 SECONDS

/datum/crafting_recipe/roguetown/survival/dryleaf
	name = "dry swampweed"
	result = /obj/item/reagent_containers/food/snacks/grown/rogue/swampweeddry
	reqs = list(/obj/item/reagent_containers/food/snacks/grown/rogue/swampweed = 1)
	structurecraft = /obj/machinery/tanningrack
	time = 2 SECONDS
	verbage_simple = "dry"
	verbage = "dries"
	craftsound = null
	skillcraft = null

/datum/crafting_recipe/roguetown/survival/drytea
	name = "dry tea leaves"
	result = /obj/item/reagent_containers/food/snacks/grown/rogue/tealeaves_dry
	reqs = list(/obj/item/reagent_containers/food/snacks/grown/tea = 1)
	structurecraft = /obj/machinery/tanningrack
	time = 2 SECONDS
	verbage_simple = "dry"
	verbage = "dries"
	craftsound = null
	skillcraft = null

/datum/crafting_recipe/roguetown/survival/dryweed
	name = "dry westleach leaf"
	result = /obj/item/reagent_containers/food/snacks/grown/rogue/pipeweeddry
	reqs = list(/obj/item/reagent_containers/food/snacks/grown/rogue/pipeweed = 1)
	structurecraft = /obj/machinery/tanningrack
	time = 2 SECONDS
	verbage_simple = "dry"
	verbage = "dries"
	craftsound = null
	skillcraft = null

/datum/crafting_recipe/roguetown/survival/dryrosa
	name = "dry rosa petals"
	result = /obj/item/reagent_containers/food/snacks/grown/rogue/rosa_petals_dried
	reqs = list(/obj/item/reagent_containers/food/snacks/grown/rogue/rosa_petals = 1)
	structurecraft = /obj/machinery/tanningrack
	time = 2 SECONDS
	verbage_simple = "dry"
	verbage = "dries"
	craftsound = null
	skillcraft = null

/datum/crafting_recipe/roguetown/survival/sigsweet
	name = "swampweed zig"
	result = /obj/item/clothing/mask/cigarette/rollie/cannabis
	reqs = list(
		/obj/item/reagent_containers/food/snacks/grown/rogue/swampweeddry = 1,
		/obj/item/paper = 1,
		)
	time = 10 SECONDS
	verbage_simple = "roll"
	verbage = "rolls"
	craftdiff = 0

/datum/crafting_recipe/roguetown/survival/sigsweet/cheroot
	name = "swampweed cheroot"
	result = /obj/item/clothing/mask/cigarette/rollie/cannabis/cheroot
	reqs = list(
		/obj/item/reagent_containers/food/snacks/grown/rogue/swampweeddry = 1,
		/obj/item/reagent_containers/food/snacks/grown/rogue/pipeweeddry = 1,
		)
	time = 10 SECONDS
	verbage_simple = "roll"
	verbage = "rolls"
	craftdiff = 0

/datum/crafting_recipe/roguetown/survival/sigdry
	name = "westleach zig"
	result = /obj/item/clothing/mask/cigarette/rollie/nicotine
	reqs = list(
		/obj/item/reagent_containers/food/snacks/grown/rogue/pipeweeddry = 1,
		/obj/item/paper = 1,
		)
	time = 10 SECONDS
	verbage_simple = "roll"
	verbage = "rolls"
	craftdiff = 0

/datum/crafting_recipe/roguetown/survival/sigdry/cheroot
	name = "westleach cheroot"
	result = /obj/item/clothing/mask/cigarette/rollie/nicotine/cheroot
	reqs = list(
		/obj/item/reagent_containers/food/snacks/grown/rogue/pipeweeddry = 1,
		/obj/item/reagent_containers/food/snacks/grown/rogue/pipeweed = 1,
		)
	time = 10 SECONDS
	verbage_simple = "roll"
	verbage = "rolls"
	craftdiff = 0

/datum/crafting_recipe/roguetown/survival/rocknutdry
	name = "rocknut zig"
	result = /obj/item/clothing/mask/cigarette/rollie/nicotine
	reqs = list(
		/obj/item/reagent_containers/powder/rocknut = 1,
		/obj/item/paper = 1,
		)
	time = 10 SECONDS
	verbage_simple = "roll"
	verbage = "rolls"
	craftdiff = 0

// ---- Flavored zigs: 1 paper + dried westleach leaf + flavor ingredient, crafting skill ----

/datum/crafting_recipe/roguetown/survival/menthazig
	name = "mentha zig"
	result = /obj/item/clothing/mask/cigarette/rollie/mentha
	reqs = list(
		/obj/item/paper = 1,
		/obj/item/reagent_containers/food/snacks/grown/rogue/pipeweeddry = 1,
		/obj/item/alch/mentha = 1,
		)
	time = 10 SECONDS
	verbage_simple = "roll"
	verbage = "rolls"
	craftdiff = 0
	skillcraft = /datum/skill/craft/crafting

/datum/crafting_recipe/roguetown/survival/blackberryzig
	name = "blackberry zig"
	result = /obj/item/clothing/mask/cigarette/rollie/blackberry
	reqs = list(
		/obj/item/paper = 1,
		/obj/item/reagent_containers/food/snacks/grown/rogue/pipeweeddry = 1,
		/obj/item/reagent_containers/food/snacks/grown/fruit/blackberry = 1,
		)
	time = 10 SECONDS
	verbage_simple = "roll"
	verbage = "rolls"
	craftdiff = 0
	skillcraft = /datum/skill/craft/crafting

/datum/crafting_recipe/roguetown/survival/applezig
	name = "apple zig"
	result = /obj/item/clothing/mask/cigarette/rollie/apple
	reqs = list(
		/obj/item/paper = 1,
		/obj/item/reagent_containers/food/snacks/grown/rogue/pipeweeddry = 1,
		/obj/item/reagent_containers/food/snacks/grown/apple = 1,
		)
	time = 10 SECONDS
	verbage_simple = "roll"
	verbage = "rolls"
	craftdiff = 0
	skillcraft = /datum/skill/craft/crafting

/datum/crafting_recipe/roguetown/survival/menthaapplezig
	name = "mentha-apple zig"
	result = /obj/item/clothing/mask/cigarette/rollie/menthaapple
	reqs = list(
		/obj/item/paper = 1,
		/obj/item/reagent_containers/food/snacks/grown/rogue/pipeweeddry = 1,
		/obj/item/alch/mentha = 1,
		/obj/item/reagent_containers/food/snacks/grown/apple = 1,
		)
	time = 10 SECONDS
	verbage_simple = "roll"
	verbage = "rolls"
	craftdiff = 0
	skillcraft = /datum/skill/craft/crafting

/datum/crafting_recipe/roguetown/survival/strawberryzig
	name = "strawberry zig"
	result = /obj/item/clothing/mask/cigarette/rollie/strawberry
	reqs = list(
		/obj/item/paper = 1,
		/obj/item/reagent_containers/food/snacks/grown/rogue/pipeweeddry = 1,
		/obj/item/reagent_containers/food/snacks/grown/fruit/strawberry = 1,
		)
	time = 10 SECONDS
	verbage_simple = "roll"
	verbage = "rolls"
	craftdiff = 0
	skillcraft = /datum/skill/craft/crafting

/datum/crafting_recipe/roguetown/survival/carrotzig
	name = "carrot zig"
	result = /obj/item/clothing/mask/cigarette/rollie/carrot
	reqs = list(
		/obj/item/paper = 1,
		/obj/item/reagent_containers/food/snacks/grown/rogue/pipeweeddry = 1,
		/obj/item/reagent_containers/food/snacks/grown/carrot = 1,
		)
	time = 10 SECONDS
	verbage_simple = "roll"
	verbage = "rolls"
	craftdiff = 0
	skillcraft = /datum/skill/craft/crafting

/datum/crafting_recipe/roguetown/survival/limezig
	name = "lime zig"
	result = /obj/item/clothing/mask/cigarette/rollie/lime
	reqs = list(
		/obj/item/paper = 1,
		/obj/item/reagent_containers/food/snacks/grown/rogue/pipeweeddry = 1,
		/obj/item/reagent_containers/food/snacks/grown/fruit/lime = 1,
		)
	time = 10 SECONDS
	verbage_simple = "roll"
	verbage = "rolls"
	craftdiff = 0
	skillcraft = /datum/skill/craft/crafting

/datum/crafting_recipe/roguetown/survival/salviazig
	name = "salvia zig"
	result = /obj/item/clothing/mask/cigarette/rollie/salvia
	reqs = list(
		/obj/item/paper = 1,
		/obj/item/reagent_containers/food/snacks/grown/rogue/pipeweeddry = 1,
		/obj/item/alch/salvia = 1,
		)
	time = 10 SECONDS
	verbage_simple = "roll"
	verbage = "rolls"
	craftdiff = 0
	skillcraft = /datum/skill/craft/crafting

/datum/crafting_recipe/roguetown/survival/salviavalerianazig
	name = "salvia-valeriana zig"
	result = /obj/item/clothing/mask/cigarette/rollie/salviavaleriana
	reqs = list(
		/obj/item/paper = 1,
		/obj/item/reagent_containers/food/snacks/grown/rogue/pipeweeddry = 1,
		/obj/item/alch/salvia = 1,
		/obj/item/alch/valeriana = 1,
		)
	time = 10 SECONDS
	verbage_simple = "roll"
	verbage = "rolls"
	craftdiff = 0
	skillcraft = /datum/skill/craft/crafting

/datum/crafting_recipe/roguetown/survival/calendulazig
	name = "calendula zig"
	result = /obj/item/clothing/mask/cigarette/rollie/calendula
	reqs = list(
		/obj/item/paper = 1,
		/obj/item/reagent_containers/food/snacks/grown/rogue/pipeweeddry = 1,
		/obj/item/alch/calendula = 1,
		)
	time = 10 SECONDS
	verbage_simple = "roll"
	verbage = "rolls"
	craftdiff = 0
	skillcraft = /datum/skill/craft/crafting

/datum/crafting_recipe/roguetown/survival/jacksberrieszig
	name = "jacksberries zig"
	result = /obj/item/clothing/mask/cigarette/rollie/jacksberries
	reqs = list(
		/obj/item/paper = 1,
		/obj/item/reagent_containers/food/snacks/grown/rogue/pipeweeddry = 1,
		/obj/item/reagent_containers/food/snacks/grown/berries/rogue = 1,
		)
	time = 10 SECONDS
	verbage_simple = "roll"
	verbage = "rolls"
	craftdiff = 0
	skillcraft = /datum/skill/craft/crafting

/datum/crafting_recipe/roguetown/survival/jacksberriespoisonzig
	name = "poison jacksberries zig"
	result = /obj/item/clothing/mask/cigarette/rollie/jacksberriespoison
	reqs = list(
		/obj/item/paper = 1,
		/obj/item/reagent_containers/food/snacks/grown/rogue/pipeweeddry = 1,
		/obj/item/reagent_containers/food/snacks/grown/berries/rogue/poison = 1,
		)
	time = 10 SECONDS
	verbage_simple = "roll"
	verbage = "rolls"
	craftdiff = 0
	skillcraft = /datum/skill/craft/crafting

/datum/crafting_recipe/roguetown/survival/abysszig
	name = "jacksberries zig (poison)"
	result = /obj/item/clothing/mask/cigarette/rollie/abyss
	reqs = list(
		/obj/item/paper = 1,
		/obj/item/reagent_containers/food/snacks/grown/rogue/pipeweeddry = 1,
		/obj/item/reagent_containers/food/snacks/grown/berries/rogue/poison = 1,
		)
	time = 10 SECONDS
	verbage_simple = "roll"
	verbage = "rolls"
	craftdiff = 0
	skillcraft = /datum/skill/craft/crafting

/datum/crafting_recipe/roguetown/survival/zigarzig
	name = "zigar"
	result = /obj/item/clothing/mask/cigarette/rollie/zigar
	reqs = list(
		/obj/item/paper = 1,
		/obj/item/reagent_containers/food/snacks/grown/rogue/pipeweeddry = 1,
		/obj/item/alch/hypericum = 1,
		)
	time = 10 SECONDS
	verbage_simple = "roll"
	verbage = "rolls"
	craftdiff = 0
	skillcraft = /datum/skill/craft/crafting
