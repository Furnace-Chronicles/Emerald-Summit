// BOUQUETS & FLOWER CROWNS

/obj/item/bouquet
	name = ""
	desc = ""
	icon = 'icons/roguetown/items/misc.dmi' 
	icon_state = ""
	item_state = ""

	grid_width = 32
	grid_height = 64

/obj/item/bouquet/rosa
	name = "rosa bouquet"
	desc = "Affections bundled together in string."
	item_state = "bouquet_rosa"
	icon_state = "bouquet_rosa"

/obj/item/bouquet/salvia
	name = "salvia bouquet"
	desc = ""
	item_state = "bouquet_salvia"
	icon_state = "bouquet_salvia"

/obj/item/bouquet/matricaria
	name = "matricaria bouquet"
	desc = ""
	item_state = "bouquet_matricaria"
	icon_state = "bouquet_matricaria"

/obj/item/bouquet/calendula
	name = "calendula bouquet"
	desc = ""
	item_state = "bouquet_calendula"
	icon_state = "bouquet_calendula"

/obj/item/flowercrown
	name = ""
	desc = ""
	icon = 'icons/roguetown/clothing/head.dmi' 
	mob_overlay_icon = 'icons/roguetown/clothing/onmob/head_items.dmi'
	alternate_worn_layer  = 8.9 //On top of helmet
	slot_flags = ITEM_SLOT_HEAD|ITEM_SLOT_MASK
	body_parts_covered = null
	icon_state = ""
	item_state = ""
	experimental_inhand = FALSE

	grid_width = 64
	grid_height = 32

/obj/item/flowercrown/rosa
	name = "crown of rosa"
	desc = "A crown of roses weaved together. Commonly associated with couples in love and hopeless romantics. In the forgotten past these were worn by Eorans protesting against \
	what they perceived to be the nascent Holy See's cruelty and totalitarian tendencies."
	item_state = "rosa_crown"
	icon_state = "rosa_crown"

/obj/item/flowercrown/salvia
	name = "crown of salvia"
	desc = "A crown of salvias weaved together. Thought to symbolise wisdom and intellectual pursuits, these are often worn by scholars, philosophers and Noccian extremists alike."
	item_state = "salvia_crown"
	icon_state = "salvia_crown"

/obj/item/flowercrown/matricaria
	name = "crown of matricaria"
	desc = "A crown of matricarias weaved together. A long-standing symbol of health, peace and motherhood, used by Pestran sects and frequently gifted to first-time mothers."
	item_state = "matricaria_crown"
	icon_state = "matricaria_crown"

/obj/item/flowercrown/calendula
	name = "crown of calendula"
	desc = "A crown of calendulas weaved together. Although initially it was used by Astratan cults in their rituals, nowadays it's more commonly associated with \
	loyalty, physical and spiritual healing, irrespective of faith."
	item_state = "calendula_crown"
	icon_state = "calendula_crown"

/obj/item/flowercrown/manabloom
	name = "crown of manabloom"
	desc = "A crown of manabloom flowers weaved together. Its effectiveness in aiding spellcasting has been long debunked, but it's still worn by \
	aspiring and experienced magicians alike as a fashion statement."
	item_state = "manabloom_crown"
	icon_state = "manabloom_crown"

/obj/item/flowercrown/thorny
	name = "crown of thorns"
	item_state = "thorny_crown"
	icon_state = "thorny_crown"
