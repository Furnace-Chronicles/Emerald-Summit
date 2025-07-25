// Sundmark Areas

/area/rogue/indoors/sund
	name = "sundmark"
	location_name = "the distance"	// Should only occur as a fail condition if child objects lack more specific locations names, or areas are meant to be secret.
	icon = 'modular_helmsguard/icons/turf/sund_areas.dmi'	// Redirect to the modular icons.
	icon_state = "rogue"

/area/rogue/outdoors/sund
	name = "sundmark"
	location_name = "the distance"	// Should only occur as a fail condition if child objects lack more specific locations names, or areas are meant to be secret.
	icon = 'modular_helmsguard/icons/turf/sund_areas.dmi'	// Redirect to the modular icons.
	icon_state = "rogue"

/*	These are all inherited  from the parent /rogue. Leaving in comments as a reference.

	has_gravity = STANDARD_GRAVITY
	ambientsounds = null
	always_unpowered = TRUE
	poweralm = FALSE
	power_environ = TRUE
	power_equip = TRUE
	power_light = TRUE
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	requires_power = FALSE
//	var/previous_ambient = ""
	var/town_area = FALSE
	var/keep_area = FALSE
	var/warden_area = FALSE
	var/ceiling_protected = FALSE //Prevents tunneling into these from above
*/

// Keep
/area/rogue/outdoors/sund/keep // Setting exterior defaults.
	droning_sound = 'sound/music/area/sargoth.ogg'
	droning_sound_dusk = 'sound/music/area/septimus.ogg'
	droning_sound_night = 'sound/music/area/sleeping.ogg'
	keep_area = TRUE
	town_area = TRUE

/area/rogue/outdoors/sund/keep/keep_exterior	
	name = "Keep Exterior"
	location_name = "above the keep"
	icon_state = "keep_exterior"
	converted_type = /area/rogue/indoors/sund/keep
	soundenv = 16

/area/rogue/indoors/sund/keep	// Setting interior defaults.
	location_name = "the keep"
	keep_area = TRUE
	town_area = TRUE
	first_time_text = "Helmsguard Keep"
	icon_state = "keep"
	droning_sound = 'sound/music/area/sargoth.ogg'
	droning_sound_dusk = 'sound/music/area/septimus.ogg'
	droning_sound_night = 'sound/music/area/sleeping.ogg'
	converted_type = /area/rogue/outdoors/sund/keep

/area/rogue/indoors/sund/keep/keep_interior // General purpose area.
	name = "Keep Interior"
	location_name = "the keep's interior"
	icon_state = "keep"

/area/rogue/indoors/sund/keep/markgrafs_chambers	// Specific subtypes for notable areas.
	name = "Castellan's Chambers"
	location_name = "the keep's bedchambers"

/area/rogue/indoors/sund/keep/throne_room
	name = "Throne Room"
	location_name = "the throne room"

/area/rogue/indoors/sund/keep/keep_commons
	name = "Keep Commons"
	location_name = "the keep's interior"

/area/rogue/indoors/sund/keep/servants_chambers
	name = "Servant's Interior"
	location_name = "the servant's chambers of the keep"

/area/rogue/indoors/sund/keep/keep_cellars
	name = "Keep Cellars"
	location_name = "underneath the keep"

/area/rogue/indoors/sund/keep/keep_gatehouse
	name = "Keep Gatehouse"
	location_name = "the keep's gatehouse"

/area/rogue/indoors/sund/keep/knights_tower
	name = "Knight's Tower"
	location_name = "the knight's tower"

/area/rogue/indoors/sund/keep/stewards_tower
	name = "Steward's Tower"
	location_name = "the steward's tower"

// Castle

/area/rogue/outdoors/sund/castle
	location_name = "Helmsguard"
	keep_area = TRUE
	town_area = TRUE
	ambientsounds = AMB_TOWNDAY
	ambientnight = AMB_TOWNNIGHT
	spookysounds = SPOOKY_CROWS
	spookynight = SPOOKY_CROWS
	droning_sound = 'sound/music/area/siege.ogg'
	droning_sound_dusk = 'sound/music/area/siege.ogg'
	droning_sound_night = 'sound/music/area/manor2.ogg'
	icon_state = "castle_exterior"
	converted_type = /area/rogue/indoors/sund/castle

/area/rogue/outdoors/sund/castle/castle_exterior
	name = "Castle Exterior"
	location_name = "above the castle"
	icon_state = "castle_exterior"

/area/rogue/outdoors/sund/castle/courtyard
	name = "Castle Courtyard"
	location_name = "the castle courtyard"
	icon_state = "castle_courtyard"
	droning_sound = 'sound/music/area/sargoth.ogg'
	droning_sound_dusk = 'sound/music/area/septimus.ogg'
	droning_sound_night = 'sound/music/area/manor2.ogg'

/area/rogue/indoors/sund/castle
	converted_type = /area/rogue/outdoors/sund/castle
	keep_area = TRUE
	town_area = TRUE

/area/rogue/indoors/sund/castle/castle_interior
	name = "Castle Interior"
	location_name = "the castle's interior"
	converted_type = /area/rogue/outdoors/sund/castle/castle_exterior

/area/rogue/indoors/sund/castle/castle_nobles
	name = "Tower of Nobles"
	location_name = "the Tower of Nobles"
	droning_sound = 'sound/music/area/manor2.ogg'
	droning_sound_dusk = 'sound/music/area/septimus.ogg'
	droning_sound_night = 'sound/music/area/sleepingold.ogg'

// Town Walls
/area/rogue/outdoors/sund/walls
	name = "Sundburg Walls"
	location_name = "the walls"
	icon_state = "walls_exterior"
	town_area = TRUE
	converted_type = /area/rogue/indoors/sund/walls

/area/rogue/outdoors/sund/walls/walls_exterior
	name = "Sundburg Walls"
	location_name = "the walls"

/area/rogue/outdoors/sund/walls/gatehouse
	name = "Sundburg Gatehouse"
	location_name = "the city gates"

/area/rogue/indoors/sund/walls
	name = "Sundburg Walls"
	location_name = "the walls"
	town_area = TRUE
	icon_state = "walls"
	converted_type = /area/rogue/outdoors/sund/walls

/area/rogue/indoors/sund/walls/walls_interior
	name = "Sundburg Walls"
	location_name = "the walls"

/area/rogue/indoors/sund/walls/gatehouse
	name = "Sundburg Gatehouse"
	location_name = "the city gates"

// Sundmark Streets

/area/rogue/outdoors/sund/streets
	name = "Sundburg Streets"
	location_name = "the streets of Sundburg"
	first_time_text = "Sundburg"
	icon_state = "streets"
	town_area = TRUE
	ambientrain = RAIN_OUT
	ambientsounds = AMB_TOWNDAY
	ambientnight = AMB_TOWNNIGHT
	spookysounds = SPOOKY_CROWS
	spookynight = SPOOKY_RATS
	droning_sound = 'sound/music/area/townstreets.ogg'
	droning_sound_dusk = 'sound/music/area/septimus.ogg'
	droning_sound_night = 'sound/music/area/townstreetsold.ogg'
	soundenv = 16
	converted_type = /area/rogue/outdoors/sund/streets/backways

/area/rogue/outdoors/sund/streets/backways
	name = "the Backways"
	location_name = "the Backways"
	town_area = FALSE
	droning_sound = 'sound/music/area/towngenold.ogg'
	droning_sound_dusk = 'sound/music/area/septimus.ogg'
	droning_sound_night = 'sound/music/area/townstreetsold.ogg'
	converted_type = /area/rogue/outdoors/sund/streets


// Guild House

/area/rogue/outdoors/sund/guild
	name = "Guild House"
	location_name = "the guildhouse"
	icon_state = "guild_exterior"
	town_area = TRUE
	converted_type = /area/rogue/indoors/sund/guild

/area/rogue/outdoors/sund/guild/guild_exterior
	name = "Guild House Exterior"
	location_name = "above the guildhouse"
	outdoors = TRUE
	ambientrain = RAIN_OUT
	ambientsounds = AMB_TOWNDAY
	ambientnight = AMB_TOWNNIGHT
	spookysounds = SPOOKY_CROWS
	spookynight = SPOOKY_GEN
	droning_sound = 'sound/music/area/townstreets.ogg'
	droning_sound_dusk = 'sound/music/area/septimus.ogg'
	droning_sound_night = 'sound/music/area/sleeping.ogg'

/area/rogue/indoors/sund/guild
	name = "Guild House"
	location_name = "the guildhouse"
	icon_state = "guild"
	town_area = TRUE
	converted_type = /area/rogue/outdoors/sund/guild

/area/rogue/indoors/sund/guild/interior
	name = "Guild House"
	location_name = "within the guildhouse"
	icon_state = "guild"

/area/rogue/indoors/sund/guild/interior/merchant
	name = "Merchant Shop"

/area/rogue/indoors/sund/guild/interior/smith
	name = "Smith Shop"
	location_name = "within the smithy"

/area/rogue/indoors/sund/guild/interior/tailor
	name = "Tailor Shop"
	location_name = "within the tailor's shop"

// Public House - Watch-house Complex

/area/rogue/outdoors/sund/public
	name = "Public House"
	location_name = "the public house"
	icon_state = "inn"
	town_area = TRUE
	ambientsounds = AMB_TOWNDAY
	ambientnight = AMB_TOWNNIGHT
	spookysounds = SPOOKY_CROWS
	spookynight = SPOOKY_GEN
	droning_sound = 'sound/music/area/townstreets.ogg'
	droning_sound_dusk = 'sound/music/area/septimus.ogg'
	droning_sound_night = 'sound/music/area/sleeping.ogg'
	converted_type = /area/rogue/indoors/sund/public

/area/rogue/outdoors/sund/public/exterior
	name = "Public House Exterior"
	location_name = "above the public house"
	outdoors = TRUE

/area/rogue/outdoors/sund/public/exterior/inn
	name = "Inn Exterior"
	location_name = "above the inn"
	icon_state = "inn_exterior"

/area/rogue/outdoors/sund/public/exterior/watch
	name = "Watch-house Exterior"
	location_name = "above the watch-house"
	icon_state = "watch_exterior"

/area/rogue/indoors/sund/public
	name = "Public House"
	location_name = "the public house"
	converted_type = /area/rogue/outdoors/sund/public

/area/rogue/indoors/sund/public/interior
	name = "Public House"
	location_name = "the public house"

/area/rogue/indoors/sund/public/inn
	name = "The Golden Goblet"
	location_name = "the inn"
	first_time_text = "The Golden Goblet"
	icon_state = "inn"

/area/rogue/indoors/sund/public/watch
	name = "The Watch-House"
	location_name = "the watch-house"
	icon_state = "watch"
	droning_sound = 'sound/music/area/manorgarri.ogg'

/area/rogue/indoors/sund/public/gaol
	name = "The Gaol"
	location_name = "the gaol"
	icon_state = "watch_gaol"
	droning_sound = 'sound/music/area/dungeon2.ogg'

// Church

/area/rogue/outdoors/sund/church
	name = "The Church"
	location_name = "the Church"
	icon_state = "church"
	town_area = TRUE
	droning_sound = 'sound/music/area/church.ogg'
	droning_sound_dusk = 'sound/music/area/churchdawn.ogg'
	droning_sound_night = 'sound/music/area/towngen.ogg'

/area/rogue/outdoors/sund/church/exterior
	name = "Church Exterior"
	location_name = "above the church"
	icon_state = "church_exterior"
	spookysounds = SPOOKY_CROWS
	droning_sound = 'sound/music/area/townstreets.ogg'
	droning_sound_dusk = 'sound/music/area/septimus.ogg'
	droning_sound_night = 'sound/music/area/sleeping.ogg'
	soundenv = 16

/area/rogue/outdoors/sund/church/covered	// The 'breezeways' under elevated walkways.
	name = "Church Walkways"
	location_name = "inside the church"
	ambientrain = RAIN_OUT
	ambientsounds = AMB_INGEN
	ambientnight = AMB_INGEN
	spookysounds = SPOOKY_GEN
	spookynight = SPOOKY_GEN

	soundenv = 16
	plane = INDOOR_PLANE					// Although outside, its not rained on.

/area/rogue/indoors/sund/church
	name = "Church Interior"
	location_name = "inside the church"
	droning_sound = 'sound/music/area/church.ogg'
	droning_sound_dusk = 'sound/music/area/churchdawn.ogg'
	droning_sound_night = 'sound/music/area/towngen.ogg'

/area/rogue/indoors/sund/church/interior/cathedral
	name = "Cathedral"
	location_name = "inside the cathendral"

/area/rogue/indoors/sund/church/interior/chapterhouse
	name = "Chapter House"
	location_name = "inside the chapter house"

/area/rogue/indoors/sund/church/interior/monastery
	name = "Monastery"
	location_name = "inside the monastery"

// Town Houses

/area/rogue/outdoors/sund/houses
	name = "Sundburg Houses"
	location_name = "a house in Sundmark"
	icon_state = "houses"
	town_area = TRUE

/area/rogue/outdoors/sund/houses/exterior
	name = "Sundburg House Rooftops"
	location_name = "above the houses of Sundburg"
	icon_state = "houses_exterior"
	spookysounds = SPOOKY_CROWS
	spookynight = SPOOKY_GEN
	droning_sound = 'sound/music/area/townstreets.ogg'
	droning_sound_dusk = 'sound/music/area/septimus.ogg'
	droning_sound_night = 'sound/music/area/sleeping.ogg'
	soundenv = 16

/area/rogue/indoors/sund/houses
	name = "Sundburg Houses"
	location_name = "a house in Sundmark"
	icon_state = "houses"
	town_area = TRUE

/area/rogue/indoors/sund/houses/interior
	name = "Sundburg House Interior"
	location_name = "within the houses of Sundburg"
	ambientrain = RAIN_IN
	ambientsounds = AMB_INGEN
	ambientnight = AMB_INGEN
	spookysounds = SPOOKY_GEN
	spookynight = SPOOKY_GEN
	droning_sound = 'sound/music/area/sleeping.ogg'
	soundenv = 2
	plane = INDOOR_PLANE

// Bath and Bawdy Werks		I will not apologize.

/area/rogue/outdoors/sund/bawdy
	name = "Bawdyhouse"
	location_name = "the bawdyhouse"
	icon_state = "bawdy"

/area/rogue/outdoors/sund/bawdy/exterior
	name = "Sundburg House Rooftops"
	location_name = "above the houses of Sundburg"	// Deliberate obfuscation with other town houses.
	icon_state = "bawdy_exterior"
	outdoors = TRUE
	ambientrain = RAIN_OUT
	ambientsounds = AMB_TOWNDAY
	ambientnight = AMB_TOWNNIGHT
	spookysounds = SPOOKY_CROWS
	spookynight = SPOOKY_GEN
	droning_sound = 'sound/music/area/townstreets.ogg'
	droning_sound_dusk = 'sound/music/area/septimus.ogg'
	droning_sound_night = 'sound/music/area/sleeping.ogg'
	soundenv = 16

/area/rogue/indoors/sund/bawdy/interior
	name = "Sundburg Bawdyhouse"
	location_name = "within the bawdyhouse"
	ambientrain = RAIN_IN
	ambientsounds = AMB_INGEN
	ambientnight = AMB_INGEN
	spookysounds = SPOOKY_GEN
	spookynight = SPOOKY_GEN
	droning_sound = 'sound/music/area/bath.ogg'
	droning_sound_dusk = null
	droning_sound_night = null
	soundenv = 2
	plane = INDOOR_PLANE

/area/rogue/indoors/sund/bath/interior/baths
	name = "Sundburg Baths"
	location_name = "within the bawdyhouse"	// Deliberate obfuscation with the upstairs.
	icon_state = "baths"
	ambientsounds = AMB_CAVEWATER
	ambientnight = AMB_CAVEWATER
	spookysounds = SPOOKY_RATS
	spookynight = SPOOKY_RATS
	droning_sound_dusk = null
	droning_sound_night = null
	ambientrain = RAIN_SEWER
	soundenv = 21

// Sundburg Outskirts		No-ambush, safe areas around Sundburg's walls.

/area/rogue/outdoors/sund/outskirts
	name = "Sundburg Outskirts"
	icon_state = "outskirts"
	location_name = "the outskirts of Sundburg"
	outdoors = TRUE
	ambientrain = RAIN_OUT
	spookysounds = SPOOKY_CROWS
	spookynight = SPOOKY_GEN
	droning_sound = 'sound/music/area/towngen.ogg'
	droning_sound_night = 'sound/music/area/field.ogg'

/area/rogue/outdoors/sund/outskirts/farmlands
	name = "Sundburg Farmlands"
	location_name = "the farms of Sundburg"
	icon_state = "outskirts_road"

/area/rogue/outdoors/sund/outskirts/gateroad
	name = "Sundburg Gate Road"
	location_name = "outside the gates of Sundburg"
	icon_state = "outskirts_road"

/area/rogue/outdoors/sund/outskirts/wallroad
	name = "Sundburg Wall Road"
	location_name = "outside the walls of Sundburg"
	icon_state = "outskirts_road"

/area/rogue/outdoors/sund/outskirts/bridge
	name = "Sundburg Bridge"
	location_name = "outside the walls of Sundburg"
	icon_state = "outskirts_road"
	first_time_text = "The Bridge of Sundburg"
	ambientsounds = AMB_RIVERDAY
	ambientnight = AMB_RIVERNIGHT
	spookysounds = SPOOKY_GEN
	spookynight = SPOOKY_GEN
	droning_sound = 'sound/music/area/bog.ogg'
	droning_sound_dusk = 'sound/music/area/bog.ogg'
	droning_sound_night = 'sound/music/area/bog.ogg'

/area/rogue/indoors/sund/outskirts/interior
	name = "Sundburg Farmhouses"
	location_name = "the farmhouses around Sundburg"
	icon_state = "outskirts_interior"
	ambientrain = RAIN_IN
	ambientsounds = AMB_INGEN
	ambientnight = AMB_INGEN
	spookysounds = SPOOKY_GEN
	spookynight = SPOOKY_GEN
	droning_sound_night = 'sound/music/area/sleeping.ogg'
	soundenv = 2
	plane = INDOOR_PLANE

/area/rogue/indoors/sund/outskirts/interior/barge
	name = "Sundburg Outbuildings"
	icon_state = "outskirts_interior"
	ambientrain = RAIN_IN
	ambientsounds = AMB_RIVERDAY
	ambientnight = AMB_RIVERNIGHT
	spookysounds = SPOOKY_GEN
	spookynight = SPOOKY_GEN
	droning_sound = 'sound/music/area/bog.ogg'
	droning_sound_dusk = 'sound/music/area/bog.ogg'
	droning_sound_night = 'sound/music/area/bog.ogg'

/area/rogue/indoors/town/warehouse		// Unless or until we touch import code, use this path.
	name = "dock warehouse import"
	icon_state = "warehouse"
	ambientrain = RAIN_IN
	ambientsounds = AMB_RIVERDAY
	ambientnight = AMB_RIVERNIGHT
	droning_sound = 'sound/music/area/bog.ogg'
	droning_sound_dusk = 'sound/music/area/bog.ogg'
	droning_sound_night = 'sound/music/area/bog.ogg'

// Ambush Wilderness (All Ambush Zones Within, Please!!!)

/area/rogue/outdoors/sund/wilderness
	name = "Sundmark Wildnerness"
	location_name = "the wilds of Sundmark"
	icon_state = "wilderness"
	soundenv = 19

/area/rogue/outdoors/sund/wilderness/field
	name = "Sundmark Field"
	location_name = "the fields of Sundmark"
	icon_state = "wilderness_field"
	ambush_times = list("night")
	ambush_types = list(
				/turf/open/floor/rogue/dirt,
				/turf/open/floor/rogue/grass)
	ambush_mobs = list(
				/mob/living/simple_animal/hostile/retaliate/rogue/wolf = 10,
				/mob/living/simple_animal/hostile/retaliate/rogue/bigrat = 30)

	droning_sound = 'sound/music/area/field.ogg'
	droning_sound_night = 'sound/music/area/bog.ogg'

/area/rogue/outdoors/sund/wilderness/river
	name = "The Asen River"	// The deepest of lore. Actual Pre-Tacitus cut.
	location_name = "the river Asen"
	icon_state = "river"
	warden_area = TRUE
	ambientsounds = AMB_RIVERDAY
	ambientnight = AMB_RIVERNIGHT
	spookysounds = SPOOKY_FROG
	spookynight = SPOOKY_FOREST
	droning_sound = 'sound/music/area/forest.ogg'
	droning_sound_dusk = 'sound/music/area/septimus.ogg'
	droning_sound_night = 'sound/music/area/bog.ogg'
	converted_type = /area/rogue/indoors/shelter/woods

/area/rogue/outdoors/sund/wilderness/woods
	name = "Asenwald Forest"
	location_name = "the forests of Sundmark"
	first_time_text = "The Asenwald Forest"
	icon_state = "wilderness_woods"
	ambientsounds = AMB_FORESTDAY
	ambientnight = AMB_FORESTNIGHT
	spookysounds = SPOOKY_CROWS
	spookynight = SPOOKY_FOREST
	droning_sound = 'sound/music/area/forest.ogg'
	droning_sound_dusk = 'sound/music/area/septimus.ogg'
	droning_sound_night = 'sound/music/area/forestnight.ogg'
	soundenv = 15
	warden_area = TRUE
	ambush_times = list("night","dawn","dusk","day")
	ambush_types = list(
				/turf/open/floor/rogue/dirt,
				/turf/open/floor/rogue/grass)
	ambush_mobs = list(
				/mob/living/simple_animal/hostile/retaliate/rogue/saiga = 40,
				/mob/living/simple_animal/hostile/retaliate/rogue/spider = 10,
				/mob/living/simple_animal/hostile/retaliate/rogue/wolf = 30)

/area/rogue/outdoors/sund/wilderness/mountain
	name = "Sundmark Mountains"
	location_name = "the mountains of Sundmark"
	first_time_text = "Mountains of Sundmark"
	icon_state = "wilderness_mountain"
	ambush_types = list(
				/turf/open/floor/rogue/dirt)
	ambush_mobs = list(
				/mob/living/simple_animal/hostile/retaliate/rogue/wolf = 30,
				/mob/living/carbon/human/species/goblin/npc/ambush = 20,
				/mob/living/carbon/human/species/goblin/npc/ambush/cave = 10)
	ambientsounds = AMB_MOUNTAIN
	ambientnight = AMB_MOUNTAIN
	spookysounds = SPOOKY_GEN
	spookynight = SPOOKY_GEN
	droning_sound = 'sound/music/area/dwarf.ogg'
	droning_sound_dusk = null
	droning_sound_night = 'sound/music/area/forestnight.ogg'
	warden_area = TRUE
	soundenv = 17

/area/rogue/outdoors/sund/wilderness/mountain/danger
	name = "Sundmark Peaks"
	icon_state = "wilderness_mountains"
	ambush_types = list(
				/turf/open/floor/rogue/dirt)
	ambush_mobs = list(
				/mob/living/simple_animal/hostile/retaliate/rogue/wolf = 30,
				/mob/living/simple_animal/hostile/retaliate/rogue/orc = 10,
				/mob/living/carbon/human/species/goblin/npc/ambush/cave = 20)
	droning_sound = 'sound/music/area/decap.ogg'
	droning_sound_dusk = null
	droning_sound_night = 'sound/music/area/caves.ogg'
	ambush_times = list("night","dawn","dusk","day")

// The Author was here, but now he is dead.
