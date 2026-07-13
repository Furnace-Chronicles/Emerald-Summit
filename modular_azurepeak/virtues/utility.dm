/datum/virtue/utility/noble
	name = "Nobility"
	desc = "By birth, blade or brain, I am noble known to the royalty of these lands, and have all the benefits associated with it."
	triumph_cost = 10 //You wanna be an untouchable (in rp) noble? You gotta lower your infinite pool of triumphs a little
	restricted = TRUE
	races = list(/datum/species/golem/metal, /datum/species/golem/porcelain, /datum/species/goblinp, /datum/species/kobold)
	added_traits = list(TRAIT_NOBLE)
	added_skills = list(list(/datum/skill/misc/reading, 1, 6))
	added_stashed_items = list("Heirloom Amulet" = /obj/item/clothing/neck/roguetown/ornateamulet/noble)

/datum/virtue/utility/noble/apply_to_human(mob/living/carbon/human/recipient)
	SStreasury.noble_incomes[recipient] += 15
	var/obj/item/pouch = new /obj/item/storage/belt/rogue/pouch/coins/virtuepouch(get_turf(recipient))
	recipient.put_in_hands(pouch, forced = TRUE)

/datum/virtue/utility/noble/handle_traits(mob/living/carbon/human/recipient)
	..()
	if(HAS_TRAIT(recipient, TRAIT_PEASANTMILITIA))
		to_chat(recipient, "Your noble upbringing left you without the experience to truly wield a common man's tools.")
		REMOVE_TRAIT(recipient, TRAIT_PEASANTMILITIA, JOB_TRAIT)
		REMOVE_TRAIT(recipient, TRAIT_PEASANTMILITIA, ADVENTURER_TRAIT)


/datum/virtue/utility/blueblooded
	name = "Blueblooded"
	desc = "I have been raised since birth in the throes of a noble lineage, and bear exceptional beauty and the social standing to show for it - though none of the material benefits."
	restricted = TRUE
	races = list(/datum/species/golem/metal, /datum/species/golem/porcelain, /datum/species/goblinp, /datum/species/kobold)
	added_traits = list(TRAIT_NOBLE, TRAIT_BEAUTIFUL, TRAIT_GOODLOVER)
	added_skills = list(list(/datum/skill/misc/reading, 1, 6))
	added_stashed_items = list("Heirloom Amulet" = /obj/item/clothing/neck/roguetown/ornateamulet/noble, "Hand Mirror" = /obj/item/handmirror)

/datum/virtue/utility/blueblooded/handle_traits(mob/living/carbon/human/recipient)
	..()
	if(HAS_TRAIT(recipient, TRAIT_UNSEEMLY))
		to_chat(recipient, "Your social grace is cancelled out! You become normal.")
		REMOVE_TRAIT(recipient, TRAIT_BEAUTIFUL, TRAIT_VIRTUE)
		REMOVE_TRAIT(recipient, TRAIT_UNSEEMLY, TRAIT_VIRTUE)
	if(HAS_TRAIT(recipient, TRAIT_PEASANTMILITIA))
		to_chat(recipient, "Your noble upbringing left you without the experience to truly wield a common man's tools.")
		REMOVE_TRAIT(recipient, TRAIT_PEASANTMILITIA, JOB_TRAIT)
		REMOVE_TRAIT(recipient, TRAIT_PEASANTMILITIA, ADVENTURER_TRAIT)

/datum/virtue/utility/socialite
	name = "Socialite"
	desc = "I thrive in social settings, easily reading the emotions of others and charming those around me. My presence is always felt at any gathering."
	custom_text = "Grants empathic insight."
	added_traits = list(TRAIT_GOODLOVER, TRAIT_EMPATH)

/datum/virtue/utility/beautiful
	name = "Beautiful"
	desc = "Wherever I go, I turn heads, such is my natural beauty. I am also rather good in bed, though they always say that."
	custom_text = "Incompatible with Ugly virtue."
	added_traits = list(TRAIT_BEAUTIFUL, TRAIT_GOODLOVER)
	added_stashed_items = list(
		"Hand Mirror" = /obj/item/handmirror)

/datum/virtue/utility/beautiful/handle_traits(mob/living/carbon/human/recipient)
	..()
	if(HAS_TRAIT(recipient, TRAIT_UNSEEMLY))
		to_chat(recipient, "Your social grace is cancelled out! You become normal.")
		REMOVE_TRAIT(recipient, TRAIT_BEAUTIFUL, TRAIT_VIRTUE)
		REMOVE_TRAIT(recipient, TRAIT_UNSEEMLY, TRAIT_VIRTUE)

/datum/virtue/utility/deadened
	name = "Deadened"
	desc = "Some terrible incident colours my past, and now, I feel nothing."
	added_traits = list(TRAIT_NOMOOD)


/datum/virtue/utility/resident
	name = "Resident"
	desc = "I'm a resident of Emerald Summit. I have an account in the city's treasury and a home in the city."
	added_traits = list(TRAIT_RESIDENT)

/datum/virtue/utility/resident/apply_to_human(mob/living/carbon/human/recipient)
	var/mapswitch = 0
	if(SSmapping.config.map_name == "Dun Manor")
		mapswitch = 1
	else if(SSmapping.config.map_name == "Dun World")
		mapswitch = 2

	if(mapswitch == 0)
		return
	if(HAS_TRAIT(recipient, TRAIT_OUTLANDER))
		to_chat(recipient, "You may have originated from another land, but you have lived here long enough and become a true citizen.")
		REMOVE_TRAIT(recipient, TRAIT_OUTLANDER, JOB_TRAIT)
	if(recipient.mind?.assigned_role == "Adventurer" || recipient.mind?.assigned_role == "Mercenary" || recipient.mind?.assigned_role == "Court Agent")
		// Find tavern area for spawning
		var/area/spawn_area
		for(var/area/A in world)
			if(istype(A, /area/rogue/indoors/town/tavern))
				spawn_area = A
				break

		if(spawn_area)
			var/target_z = 3 //ground floor of tavern for dun manor / world
			var/target_y = 70 //dun manor
			var/list/possible_chairs = list()

			if(mapswitch == 2)
				target_y = 234 //dun world huge

			for(var/obj/structure/chair/C in spawn_area)
				//z-level 3, wooden chair, and Y > north of tavern backrooms
				var/turf/T = get_turf(C)
				if(T && T.z == target_z && T.y > target_y && istype(C, /obj/structure/chair/wood/rogue) && !T.density && !T.is_blocked_turf(FALSE))
					possible_chairs += C

			if(length(possible_chairs))
				var/obj/structure/chair/chosen_chair = pick(possible_chairs)
				recipient.forceMove(get_turf(chosen_chair))
				chosen_chair.buckle_mob(recipient)
				to_chat(recipient, span_notice("As a resident of Emerald Summit, you find yourself seated at a chair in the local tavern."))
			else
				var/list/possible_spawns = list()
				for(var/turf/T in spawn_area)
					if(T.z == target_z && T.y > (target_y + 4) && !T.density && !T.is_blocked_turf(FALSE))
						possible_spawns += T

				if(length(possible_spawns))
					var/turf/spawn_loc = pick(possible_spawns)
					recipient.forceMove(spawn_loc)
					to_chat(recipient, span_notice("As a resident of Emerald Summit, you find yourself in the local tavern."))

/*/datum/virtue/utility/failed_squire
	name = "Failed Squire"
	desc = "I was once a squire in training, but failed to achieve knighthood. Though my dreams of glory were dashed, I retained my knowledge of equipment maintenance and repair, including how to polish arms and armor."
	added_traits = list(TRAIT_SQUIRE_REPAIR)
	added_stashed_items = list(
		"Hammer" = /obj/item/rogueweapon/hammer/iron,
		"Polishing Cream" = /obj/item/polishing_cream,
		"Fine Brush" = /obj/item/armor_brush
	)

/datum/virtue/utility/failed_squire/apply_to_human(mob/living/carbon/human/recipient)
	to_chat(recipient, span_notice("Though you failed to become a knight, your training in equipment maintenance and repair remains useful."))
	to_chat(recipient, span_notice("You can retrieve your hammer and polishing tools from a tree, statue, or clock."))*/


/datum/virtue/utility/deathless
	name = "Deathless"
	desc = "Some fell magick has rendered me inwardly unliving - I do not hunger, and I do not breathe."
	added_traits = list(TRAIT_NOHUNGER, TRAIT_NOBREATH)
/*
/datum/virtue/utility/deathless/apply_to_human(mob/living/carbon/human/recipient)
	recipient.mob_biotypes |= MOB_UNDEAD
*/


/datum/virtue/utility/feral_appetite
	name = "Feral Appetite"
	desc = "Raw, toxic or spoiled food doesn't bother my superior digestive system."
	added_traits = list(TRAIT_NASTY_EATER)

/datum/virtue/utility/night_vision
	name = "Night-eyed"
	desc = "I have eyes able to see through cloying darkness. Incompatible with the vice Colorblind."
	added_traits = list(TRAIT_DARKVISION)
	custom_text = "Adds a button to toggle colorblindness to aid seeing in the dark. Taking this with the Colorblind vice will permanently colorblind you."

/datum/virtue/utility/night_vision/apply_to_human(mob/living/carbon/human/recipient)
	if(recipient.charflaw)
		if(recipient.charflaw.type == /datum/charflaw/colorblind)
			to_chat(recipient, "Your eyes have become permanently colorblind.")
		else
			recipient.verbs += /mob/living/carbon/human/proc/toggleblindness

/datum/virtue/utility/ugly
	name = "Ugly"
	desc = "Be it your family's habits in and out of womb, your own choices or Xylix's cruel roll of fate, you have been left unbearable to look at. Stuck to the unseen pits and crevices of the town, you've grown used to the foul odours of lyfe that often follow you. Corpses do not stink for you, and that is all the company you might find."
	custom_text = "Incompatible with Beautiful virtue."
	added_traits = list(TRAIT_UNSEEMLY, TRAIT_NOSTINK)

/datum/virtue/utility/ugly/handle_traits(mob/living/carbon/human/recipient)
	..()
	if(HAS_TRAIT(recipient, TRAIT_BEAUTIFUL))
		to_chat(recipient, "Your repulsiveness is cancelled out! You become normal.")
		REMOVE_TRAIT(recipient, TRAIT_BEAUTIFUL, TRAIT_VIRTUE)
		REMOVE_TRAIT(recipient, TRAIT_UNSEEMLY, TRAIT_VIRTUE)

/datum/virtue/utility/secondvoice
	name = "Second Voice"
	desc = "From performance, deception, or by a need to change yourself in uncanny ways, you've acquired a second, perfect voice. You may switch between them at any point."
	custom_text = "Grants access to a new 'Virtue' tab. It will have the options for setting and changing your voice."

/datum/virtue/utility/secondvoice/apply_to_human(mob/living/carbon/human/recipient)
	recipient.verbs += /mob/living/carbon/human/proc/changevoice
	recipient.verbs += /mob/living/carbon/human/proc/swapvoice
	recipient.verbs += /mob/living/carbon/human/proc/changeaccent

/datum/virtue/utility/keenears
	name = "Keen Ears"
	desc = "Cowering from authorities, loved ones or by a generous gift of the gods, you've adapted a keen sense of hearing, and can identify the speakers even when they are out of sight, their whispers ringing louder."
	added_traits = list(TRAIT_KEENEARS)
	custom_text = "You can identify known people who speak even when they are out of sight. You can hear people speaking normally above and below you, regardless of obstacles in the way. You can hear whispers from one tile further."

/datum/virtue/utility/bronzearm_r
	name = "Bronze Arm (R)"
	desc = "Through connections or wealth, my arm had been replaced by one of bronze and gears, that can grip and hold onto things. I've learned just a bit of Engineering as a result."
	custom_text = "Replaces your Right arm with a prosthetic Bronze one. Incompatible with Wood Arm (R) vice"
	added_skills = list(list(/datum/skill/craft/engineering, 1, 6))

/datum/virtue/utility/bronzearm_r/apply_to_human(mob/living/carbon/human/recipient)
	. = ..()
	var/obj/item/bodypart/O = recipient.get_bodypart(BODY_ZONE_R_ARM)
	if(O)
		O.drop_limb()
		qdel(O)
	if(recipient.charflaw)
		if(recipient.charflaw.type == /datum/charflaw/limbloss/arm_r)
			to_chat(recipient, span_info("In my foolishness I believed a sharlatan who wished to trade in my wooden arm for one of bronze. It fell apart. Now I've no arm at all."))
		else
			var/obj/item/bodypart/r_arm/prosthetic/bronzeright/L = new()
			L.attach_limb(recipient)

/datum/virtue/utility/bronzearm_l
	name = "Bronze Arm (L)"
	desc = "Through connections or wealth, my arm had been replaced by one of bronze and gears, that can grip and hold onto things. I've learned just a bit of Engineering as a result."
	custom_text = "Replaces your Left arm with a prosthetic Bronze one. Incompatible with Wood Arm (L) vice"
	added_skills = list(list(/datum/skill/craft/engineering, 1, 6))

/datum/virtue/utility/bronzearm_l/apply_to_human(mob/living/carbon/human/recipient)
	. = ..()
	var/obj/item/bodypart/O = recipient.get_bodypart(BODY_ZONE_L_ARM)
	if(O)
		O.drop_limb()
		qdel(O)
	if(recipient.charflaw)
		if(recipient.charflaw.type == /datum/charflaw/limbloss/arm_l)
			to_chat(recipient, span_info("In my foolishness I believed a sharlatan who wished to trade in my wooden arm for one of bronze. It fell apart. Now I've no arm at all."))
		else
			var/obj/item/bodypart/l_arm/prosthetic/bronzeleft/L = new()
			L.attach_limb(recipient)

/datum/virtue/utility/woodwalker
	name = "Woodwalker"
	desc = "After years of training in the wilds, I've learned to traverse the woods confidently, without breaking any twigs. I can even step lightly on leaves without falling, and I can gather twice as many things from bushes."
	added_traits = list(TRAIT_WOODWALKER, TRAIT_OUTDOORSMAN)

/datum/virtue/heretic/zchurch_keyholder
	name = "Heresiarch"
	desc = "The 'Holy' See has their blood-stained grounds, and so do we. Underneath their noses, we pray to the true gods - I know the location of the local heretic conclave. Secrecy is paramount. If found out, I will surely be killed."
	added_traits = list(TRAIT_HERESIARCH)

/datum/virtue/racial/moth/mercuriam
	name = "(Fluvian) Mercuriam Initiate"
	desc = "Through great intellectual rigor, I passed the trials of the Intolerabi and was granted leave to study in the city of Mercuriam. In their bronze halls, I learned intimately of Pestra's art; poison will no longer harm me."
	races = list(/datum/species/moth)
	custom_text = "Only available to fluvians."
	added_traits = list(TRAIT_TOXIMMUNE)
	added_skills = list(list(/datum/skill/craft/alchemy, 1, 5),
						list(/datum/skill/misc/reading, 1, 5)
)
	added_stashed_items = list(
		"Bronze Lamptern" = /obj/item/flashlight/flare/torch/lantern/bronzelamptern
)

/datum/virtue/racial/elfd/spider
	name = "(Dark Elf) Spider Speaker"
	desc = "In the darkest depths of the underdark, I was taught the secrets of the Driderii. The methods of potion and poison were shown to me, as well as the art of traversing through webs. Spiders see me as one of their own."
	races = list(/datum/species/elf/dark)
	custom_text = "Only available to dark elves."
	added_traits = list(TRAIT_WEBWALK)
	added_skills = list(list(/datum/skill/craft/alchemy, 2, 4),
						list(/datum/skill/labor/butchering, 2, 2)
	)
	added_stashed_items = list(
		"Spider Honey" = /obj/item/reagent_containers/food/snacks/rogue/honey/spider,
		"Spider Gland" = /obj/item/reagent_containers/spidervenom_inert
)

/datum/virtue/racial/elfd/spider/apply_to_human(mob/living/carbon/human/recipient)
	recipient.faction += "spiders"

/datum/virtue/racial/dwarf/dvergr
	name = "(Dwarf) Dvergr"
	desc = "My lineage descends from the Dvergr, a clan of dwarves under Graggar’s tyrannical patronage, exiled to the Underdark. They are renowned slavers; many lords covet a servant broken by Dvergr technique. I know a little of the clan's magics, rendering me invisible to the scrying arts."
	races = list(/datum/species/dwarf/mountain)
	custom_text = "Grants enlarge spell.<br>Colors your body grey.<br>Only available to dwarves."
	added_traits = list(TRAIT_ANTISCRYING, TRAIT_DVERGR)
	added_skills = list(list(/datum/skill/magic/arcane, 1, 3))

/datum/virtue/racial/dwarf/dvergr/apply_to_human(mob/living/carbon/human/recipient)
	recipient.update_body()
	recipient.mind?.AddSpell(new /obj/effect/proc_holder/spell/invoked/enlarge)
	recipient.dna.species.stress_examine = TRUE
	recipient.dna.species.stress_desc = span_red("A Dvergr! I should watch my back.")
	recipient.dna.species.name = "Dvergr"
	var/client/player = recipient?.client
	if(player?.prefs)
		var/origin_memory = player.prefs.virtue_origin
		player.prefs.virtue_origin = new /datum/virtue/origin/racial/underdark
		player.prefs.virtue_origin.job_origin = TRUE
		player.prefs.virtue_origin.last_origin = origin_memory
