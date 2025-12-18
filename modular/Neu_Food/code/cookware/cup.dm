/obj/item/reagent_containers/glass/cup
	name = "metal cup"
	desc = "A sturdy cup of metal. Often seen in the hands of warriors, wardens, and other sturdy folk."
	icon = 'modular/Neu_Food/icons/cookware/cup.dmi'
	icon_state = "iron"
	force = 5
	lefthand_file = 'modular/Neu_Food/icons/food_lefthand.dmi'
	righthand_file = 'modular/Neu_Food/icons/food_righthand.dmi'
	experimental_inhand = FALSE
	throwforce = 10
	reagent_flags = OPENCONTAINER
	amount_per_transfer_from_this = 6
	possible_transfer_amounts = list(6)
	dropshrink = 0.85
	w_class = WEIGHT_CLASS_NORMAL
	experimental_inhand = FALSE
	volume = 24
	obj_flags = CAN_BE_HIT
	sellprice = 7
	drinksounds = list('sound/items/drink_cup (1).ogg','sound/items/drink_cup (2).ogg','sound/items/drink_cup (3).ogg','sound/items/drink_cup (4).ogg','sound/items/drink_cup (5).ogg')
	fillsounds = list('sound/items/fillcup.ogg')
	anvilrepair = /datum/skill/craft/blacksmithing

/obj/item/reagent_containers/glass/cup/update_icon(dont_fill=FALSE)
	testing("cupupdate")

	cut_overlays()

	if(reagents.total_volume)
		var/mutable_appearance/filling = mutable_appearance(icon, "[icon_state]filling")

		filling.color = mix_color_from_reagents(reagents.reagent_list)
		filling.alpha = mix_alpha_from_reagents(reagents.reagent_list)
		add_overlay(filling)

/obj/item/reagent_containers/glass/cup/wooden
	name = "wooden cup"
	desc = "This cup whispers tales of drunken battles and feasts."
	resistance_flags = FLAMMABLE
	icon_state = "wooden"
	drop_sound = 'sound/foley/dropsound/wooden_drop.ogg'
	anvilrepair = null
	sellprice = 0

/obj/item/reagent_containers/glass/cup/steel
	name = "goblet"
	desc = "A steel goblet, its surface adorned with studs."
	icon_state = "steel"
	sellprice = 15

/obj/item/reagent_containers/glass/cup/aalloymug
	name = "decrepit mug"
	desc = "A decrepit mug. Aeon's grasp is upon its form."
	icon_state = "amug"
	sellprice = 0

/obj/item/reagent_containers/glass/cup/aalloygob
	name = "decrepit goblet"
	desc = "A decrepit goblet. Aeon's grasp is upon its form."
	icon_state = "agoblet"
	sellprice = 0

/obj/item/reagent_containers/glass/cup/silver
	name = "silver goblet"
	desc = "A silver goblet, its surface carefully polished."
	icon_state = "silver"
	sellprice = 48
	last_used = 0
	is_silver = TRUE

/obj/item/reagent_containers/glass/cup/silver/small
	name = "silver cup"
	desc = "A silver cup, its surface carefully polished."
	icon_state = "scup"
	sellprice = 32
	is_silver = TRUE

/obj/item/reagent_containers/glass/cup/golden
	name = "golden goblet"
	desc = "This goblet radiates opulence and grandeur."
	icon_state = "golden"
	sellprice = 60

/obj/item/reagent_containers/glass/cup/golden/small
	name = "golden cup"
	desc = "This cup radiates opulence and grandeur."
	icon_state = "gcup"
	sellprice = 40

/obj/item/reagent_containers/glass/cup/golden/poison
	list_reagents = list(/datum/reagent/toxin/killersice = 1, /datum/reagent/consumable/ethanol/elfred = 20)

/obj/item/reagent_containers/glass/cup/tin
	name = "tin goblet"
	desc = "A tin goblet, cheaper than silver, but with a similar shine!"
	icon_state = "tgoblet"
	sellprice = 12

/obj/item/reagent_containers/glass/cup/tin/small
	name = "tin cup"
	desc = "A tin cup, cheaper than silver, but with a similar shine!"
	icon_state = "tcup"
	sellprice = 8

/obj/item/reagent_containers/glass/cup/skull
	name = "skull goblet"
	desc = "The hollow eye sockets tell me of forgotten, dark rituals."
	dropshrink = 1
	icon_state = "skull"

/obj/item/reagent_containers/glass/cup/ceramic
	name = "teacup"
	desc = "A tea cup made out of ceramic. Used to serve tea."
	dropshrink = 0.7
	icon_state = "cup"
	sellprice = 10

/obj/item/reagent_containers/glass/cup/ceramic/examine()
	. = ..()
	. += span_info("It can be brushed with a dye brush to glaze it.")

/obj/item/reagent_containers/glass/cup/ceramic/attackby(obj/item/I, mob/living/carbon/human/user)
	. = ..()
	if(istype(I, /obj/item/dye_brush))
		if(reagents.total_volume)
			to_chat(user, span_notice("I can't glaze the cup while it has liquid in it."))
			return
		if(do_after(user, 2 SECONDS, target = src))
			to_chat(user, span_notice("I glaze the cup with the dye brush."))
			new /obj/item/reagent_containers/glass/cup/ceramic/fancy(get_turf(src))
			qdel(src)
		return

/obj/item/reagent_containers/glass/cup/ceramic/fancy
	name = "fancy teacup"
	desc = "A fancy tea cup made out of ceramic. Used to serve tea."
	icon_state = "cup_fancy"
	sellprice = 12

/obj/item/reagent_containers/glass/cup/carved
	name = "carved cup"
	desc = "You shouldn't be seeing this."
	dropshrink = 1
	icon_state = "agoblet"
	sellprice = 0

/obj/item/reagent_containers/glass/cup/carved/jade
	name = "joapstone cup"
	desc = "A simple cup carved out of joapstone."
	dropshrink = 1
	icon_state = "cup_jade"
	sellprice = 55

/obj/item/reagent_containers/glass/cup/carved/turq
	name = "ceruleabaster cup"
	desc = "A simple cup carved out of ceruleabaster."
	dropshrink = 1
	icon_state = "cup_turq"
	sellprice = 80

/obj/item/reagent_containers/glass/cup/carved/amber
	name = "petriamber cup"
	desc = "A simple cup carved out of petriamber."
	dropshrink = 1
	icon_state = "cup_amber"
	sellprice = 55

/obj/item/reagent_containers/glass/cup/carved/coral
	name = "aoetal cup"
	desc = "A simple cup carved out of aoetal."
	dropshrink = 1
	icon_state = "cup_coral"
	sellprice = 65

/obj/item/reagent_containers/glass/cup/carved/onyxa
	name = "onyxa cup"
	desc = "A simple cup carved out of onyxa."
	dropshrink = 1
	icon_state = "cup_onyxa"
	sellprice = 35

/obj/item/reagent_containers/glass/cup/carved/shell
	name = "shell cup"
	desc = "A simple cup carved out of shell."
	dropshrink = 1
	icon_state = "cup_shell"
	sellprice = 15

/obj/item/reagent_containers/glass/cup/carved/opal
	name = "opaloise cup"
	desc = "A simple cup carved out of opaloise."
	dropshrink = 1
	icon_state = "cup_opal"
	sellprice = 85

/obj/item/reagent_containers/glass/cup/carved/rose
	name = "rosellusk cup"
	desc = "A simple cup carved out of rosellusk."
	dropshrink = 1
	icon_state = "cup_rose"
	sellprice = 20

/obj/item/reagent_containers/glass/cup/carved/jadefancy
	name = "fancy joapstone cup"
	desc = "A fancy cup carved out of joapstone."
	dropshrink = 1
	icon_state = "fancycup_jade"
	sellprice = 65

/obj/item/reagent_containers/glass/cup/carved/turqfancy
	name = "fancy ceruleabaster cup"
	desc = "A fancy cup carved out of ceruleabaster."
	dropshrink = 1
	icon_state = "fancycup_turq"
	sellprice = 90

/obj/item/reagent_containers/glass/cup/carved/opalfancy
	name = "fancy opaloise cup"
	desc = "A fancy cup carved out of opaloise."
	dropshrink = 1
	icon_state = "fancycup_opal"
	sellprice = 95

/obj/item/reagent_containers/glass/cup/carved/coralfancy
	name = "fancy aoetal cup"
	desc = "A fancy cup carved out of aoetal."
	dropshrink = 1
	icon_state = "fancycup_coral"
	sellprice = 75

/obj/item/reagent_containers/glass/cup/carved/amberfancy
	name = "fancy petriamber cup"
	desc = "A fancy cup carved out of petriamber."
	dropshrink = 1
	icon_state = "fancycup_amber"
	sellprice = 65

/obj/item/reagent_containers/glass/cup/carved/shellfancy
	name = "fancy shell cup"
	desc = "A fancy cup carved out of shell."
	dropshrink = 1
	icon_state = "fancycup_shell"
	sellprice = 25

/obj/item/reagent_containers/glass/cup/carved/rosefancy
	name = "fancy rosellusk cup"
	desc = "A fancy cup carved out of rosellusk."
	dropshrink = 1
	icon_state = "fancycup_rose"
	sellprice = 30

/obj/item/reagent_containers/glass/cup/carved/onyxafancy
	name = "fancy onyxa cup"
	desc = "A fancy cup carved out of onyxa."
	dropshrink = 1
	icon_state = "fancycup_onyxa"
	sellprice = 45
