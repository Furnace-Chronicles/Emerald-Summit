/datum/virtue/background/none //for having no background
	name = "None"
	desc = "You have aspired to (or been given) little in the way of trade or upbringing."

/datum/virtue/background/artificer
	name = "Artificer's Apprentice"
	desc = "In my youth, I worked under a skilled artificer, studying construction and engineering."
	custom_text = "Tinkerer comes with cogs and bronze ingots. Mason comes with a blowrod and bricks."
	added_stashed_items = list(	
		"Hammer" = /obj/item/rogueweapon/hammer/wood,
		"Chisel" = /obj/item/rogueweapon/chisel,
		"Hand Saw" = /obj/item/rogueweapon/handsaw
	)
	added_skills = list(list(/datum/skill/craft/crafting, 2, 2),
						list(/datum/skill/craft/carpentry, 2, 2),
						list(/datum/skill/craft/masonry, 2, 2),
						list(/datum/skill/craft/engineering, 2, 2),
						list(/datum/skill/craft/smelting, 2, 2),
						list(/datum/skill/misc/ceramics, 2, 2)
	)
/datum/virtue/background/artificer/apply_to_human(mob/living/carbon/human/H)
	var/equipment = list("Tinkerer","Mason")
	var/equip_choice = input(H,"My lyfe before, STASHed away ...", "TREES and STATUES hold my things.") as anything in equipment
	switch(equip_choice)
		if("Tinkerer")
			if(H.mind)
				H.mind.special_items = list(
					"Equipment Bag" = /obj/item/storage/roguebag/artificertinker
				)
		if("Mason")
			if(H.mind)
				H.mind.special_items = list(
					"Equipment Bag" = /obj/item/storage/roguebag/artificermason
				)

/datum/virtue/background/blacksmith //scrapper subclass; mobile smelter and ... stuff
	name = "Blacksmith's Apprentice"
	desc = "In my youth, I worked under a skilled blacksmith, honing my skills with an anvil."
	custom_text = "Smith loadout comes with ingots and equipment to start smithing. Scrapper is focused on finding refuse to recycle with handheld smelter (& has smithing tools)."
	added_skills = list(list(/datum/skill/craft/crafting, 2, 2),
						list(/datum/skill/craft/weaponsmithing, 2, 2),
						list(/datum/skill/craft/armorsmithing, 2, 2),
						list(/datum/skill/craft/blacksmithing, 2, 2),
						list(/datum/skill/craft/smelting, 2, 2))

/datum/virtue/background/blacksmith/apply_to_human(mob/living/carbon/human/H)
	var/equipment = list("Smith","Scrapper")
	var/equip_choice = input(H,"My lyfe before, STASHed away ...", "TREES and STATUES hold my things.") as anything in equipment
	switch(equip_choice)
		if("Smith")
			if(H.mind)
				H.mind.special_items = list(
					"Equipment Bag" = /obj/item/storage/roguebag/smithapp
				)
		if("Scrapper")
			if(H.mind)
				H.mind.special_items = list(
					"Equipment Bag" = /obj/item/storage/roguebag/smithscrap,
					"Portable Smelter" = /obj/item/contraption/smelter
				)

/datum/virtue/background/brawler
	name = "Brawler's Apprentice"
	desc = "I have trained under a skilled brawler, and have some experience fighting with my fists."
	custom_text = "+2 to Unarmed and Wrestling (Max Journeyman), with choice of Katar or Knuckles."
	
/datum/virtue/background/brawler/apply_to_human(mob/living/carbon/human/H)
	var/equipment = list("Katar","Knuckles")
	var/equip_choice = input(H,"My lyfe before, STASHed away ...", "TREES and STATUES hold my things.") as anything in equipment
	switch(equip_choice)
		if("Katar")
			if(H.mind)
				H.mind.special_items = list(
					"Equipment Bag" = /obj/item/storage/roguebag/brawlkatar
					
				)
			H.adjust_skillrank_up_to(/datum/skill/combat/unarmed, 2, 3)
			H.adjust_skillrank_up_to(/datum/skill/combat/wrestling, 2, 3)
		if("Knuckles")
			if(H.mind)
				H.mind.special_items = list(
					"Equipment Bag" = /obj/item/storage/roguebag/brawlknuck 
					
				)
			H.adjust_skillrank_up_to(/datum/skill/combat/unarmed, 2, 3)
			H.adjust_skillrank_up_to(/datum/skill/combat/wrestling, 2, 3)

/datum/virtue/background/granary
	name = "Cunning Provisioner"
	desc = "You've worked in or around the docks enough to steal away a sack of supplies that no one would surely miss, just in case. You've picked up on some cooking and fishing tips in your spare time, as well."
	custom_text = "Both come with a cooling backpack. Chef is equipped with a variety of foods + pan for cooking (and a chef's knife). Fisher has a fishing rod, bait, pan, and supplies for making fishing traps."
	added_skills = list(list(/datum/skill/craft/cooking, 3, 6),
						list(/datum/skill/labor/fishing, 2, 6))

/datum/virtue/background/granary/apply_to_human(mob/living/carbon/human/H)
	var/equipment = list("Chef","Fisher")
	var/equip_choice = input(H,"My lyfe before, STASHed away ...", "TREES and STATUES hold my things.") as anything in equipment
	switch(equip_choice)
		if("Chef")
			if(H.mind)
				H.mind.special_items = list(
					"Equipment Bag" = /obj/item/storage/backpack/rogue/artibackpack/cunningchef 
					
				)
		if("Fisher")
			if(H.mind)
				H.mind.special_items = list(
					"Equipment Bag" = /obj/item/storage/backpack/rogue/artibackpack/cunningfish 
					
				)

/datum/virtue/background/duelist
	name = "Duelist's Apprentice"
	desc = "I have trained under a duelist of considerable skill, and have taken up their arms of choice."
	custom_text = "+2 to Swords or Knives (max Journeyman) depending on equipment choice (Rapier, Arming Sword, or Two Daggers)."

/datum/virtue/background/duelist/apply_to_human(mob/living/carbon/human/H)
	var/equipment = list("Dueler (Rapier)","Swordsman (Arming)","Scoundrel (+2 St. Dagger)")
	var/equip_choice = input(H,"My lyfe before, STASHed away ...", "TREES and STATUES hold my things.") as anything in equipment
	switch(equip_choice)
		if("Dueler (Rapier)")
			if(H.mind)
				H.mind.special_items = list(
					"Equipment Bag" = /obj/item/storage/roguebag/duelistnoble, 
					"Rapier" = /obj/item/rogueweapon/sword/rapier
					
				)
			H.adjust_skillrank_up_to(/datum/skill/combat/swords, 2, 3)
		if("Swordsman (Arming)")
			if(H.mind)
				H.mind.special_items = list(
					"Equipment Bag" = /obj/item/storage/roguebag/duelistsword, 
					
				)
			H.adjust_skillrank_up_to(/datum/skill/combat/swords, 2, 3)
		if("Scoundrel (+2 St. Dagger)")
			if(H.mind)
				H.mind.special_items = list(
					"Equipment Bag" = /obj/item/storage/roguebag/duelistscoundrel
					
				)
			give_special_items(H)
			H.adjust_skillrank_up_to(/datum/skill/combat/knives, 2, 3)

/datum/virtue/background/executioner
	name = "Dungeoneer's Apprentice"
	desc = "I was set to be a dungeoneer some time ago, and I was taught by one. I managed to bring my gear with me."
	custom_text = "+2 to Axes or Whips/Flails (Max Journeyman) depending on equipment choice (Whip or Axe)."
	///obj/item/rogueweapon/stoneaxe/woodcut
	//set each class to receive their skill specifically

/datum/virtue/background/executioner/apply_to_human(mob/living/carbon/human/H)
	var/equipment = list("Dungeon Guard","Executioner")
	var/equip_choice = input(H,"My lyfe before, STASHed away ...", "TREES and STATUES hold my things.") as anything in equipment
	switch(equip_choice)
		if("Dungeon Guard")
			if(H.mind)
				H.mind.special_items = list(
					"Equipment Bag" = /obj/item/storage/roguebag/dungeonguard 

				)
			H.adjust_skillrank_up_to(/datum/skill/combat/whipsflails, 2, 3)
		if("Executioner")
			if(H.mind)
				H.mind.special_items = list(
					"Equipment Bag" = /obj/item/storage/roguebag/dungeonexecute,
					"Axe" = /obj/item/rogueweapon/stoneaxe/woodcut
					
				)
			H.adjust_skillrank_up_to(/datum/skill/combat/axes, 2, 3)

/datum/virtue/background/forester
	name = "Forester"
	desc = "The forest is your home, or at least, it used to be. You always long to return and roam free once again, and you have not forgotten your knowledge on how to be self sufficient."
	custom_text = "Lumberer comes with an axe, fishing rod, and whetstone. Farmer has an assortment of seeds, crops, and a hoe."
	added_skills = list(list(/datum/skill/craft/cooking, 2, 2),
						list(/datum/skill/misc/athletics, 2, 2),
						list(/datum/skill/labor/farming, 2, 2),
						list(/datum/skill/labor/fishing, 2, 2),
						list(/datum/skill/labor/lumberjacking, 2, 2)
	)

/datum/virtue/background/forester/apply_to_human(mob/living/carbon/human/H)
	var/equipment = list("Lumberer","Farmer")
	var/equip_choice = input(H,"My lyfe before, STASHed away ...", "TREES and STATUES hold my things.") as anything in equipment
	switch(equip_choice)
		if("Lumberer")
			if(H.mind)
				H.mind.special_items = list(
					"Equipment Bag" = /obj/item/storage/roguebag/forestlumber,
					"Axe" = /obj/item/rogueweapon/stoneaxe/woodcut
					
				)
		if("Farmer")
			if(H.mind)
				H.mind.special_items = list(
					"Equipment Bag" = /obj/item/storage/roguebag/forestfarm,
					"Hoe" = /obj/item/rogueweapon/hoe
					
				)

/datum/virtue/background/hunter
	name = "Hunter's Apprentice"
	desc = "In my youth, I trained under a skilled hunter, learning how to butcher animals and work with leather/hide."
	custom_text = "Trapper comes with bait and ingredients for a mantrap. Tanner comes with bait, fat."
	added_skills = list(list(/datum/skill/craft/crafting, 2, 2),
						list(/datum/skill/craft/traps, 2, 2),
						list(/datum/skill/labor/butchering, 2, 2),
						list(/datum/skill/misc/sewing, 2, 2),
						list(/datum/skill/craft/tanning, 2, 2),
						list(/datum/skill/misc/tracking, 2, 2)
	)
/datum/virtue/background/hunter/apply_to_human(mob/living/carbon/human/H)
	var/equipment = list("Trapper","Tanner")
	var/equip_choice = input(H,"My lyfe before, STASHed away ...", "TREES and STATUES hold my things.") as anything in equipment
	switch(equip_choice)
		if("Trapper")
			if(H.mind)
				H.mind.special_items = list(
					"Equipment Bag" = /obj/item/storage/roguebag/huntertrap 
					
				)
			H.adjust_skillrank_up_to(/datum/skill/craft/traps, 3, 3)
		if("Tanner")
			if(H.mind)
				H.mind.special_items = list(
					"Equipment Bag" = /obj/item/storage/roguebag/huntertan, 
			
				)

/datum/virtue/background/linguist
	name = "Intellectual"
	desc = "I've spent my life surrounded by various books or sophisticated foreigners, be it through travel or other fortunes beset on my life. I've picked up several tongues and wits, and keep a journal closeby. I can tell people's exact prowess."
	custom_text = "Maximizes Assess benefits with a bonus of the target's Stats. Allows the choice of 3 languages to learn upon joining. +1 INT."
	added_traits = list(TRAIT_INTELLECTUAL)
	added_skills = list(list(/datum/skill/misc/reading, 3, 6))
	added_stashed_items = list(
		"Quill" = /obj/item/natural/feather,
		"Scroll" = /obj/item/paper/scroll,
		"Unfinished Skillbook" = /obj/item/skillbook/unfinished,
		"Unfinished Skillbook" = /obj/item/skillbook/unfinished,
		"Unfinished Skillbook" = /obj/item/skillbook/unfinished,
		"Unfinished Skillbook" = /obj/item/skillbook/unfinished
	)

/datum/virtue/background/linguist/apply_to_human(mob/living/carbon/human/recipient)
	recipient.change_stat("intelligence", 1)
	addtimer(CALLBACK(src, .proc/linguist_apply, recipient), 50)

/datum/virtue/background/linguist/proc/linguist_apply(mob/living/carbon/human/recipient)
	var/static/list/selectable_languages = list(
		/datum/language/elvish,
		/datum/language/dwarvish,
		/datum/language/orcish,
		/datum/language/hellspeak,
		/datum/language/draconic,
		/datum/language/celestial,
		/datum/language/grenzelhoftian,
		/datum/language/kazengunese,
		/datum/language/otavan,
		/datum/language/etruscan,
		/datum/language/gronnic,
		/datum/language/aavnic,
		/datum/language/abyssal
	)

	var/list/choices = list()
	for(var/language_type in selectable_languages)
		if(recipient.has_language(language_type))
			continue
		var/datum/language/a_language = new language_type()
		choices[a_language.name] = language_type

	if(length(choices))	//If this isn't true then we have no new languages learn -- we probably picked archivist
		var/lang_count = 3
		var/count = lang_count
		for(var/i in 1 to lang_count)
			var/chosen_language = input(recipient, "Choose your extra spoken language.", "VIRTUE: [count] LEFT") as null|anything in choices
			if(chosen_language)
				var/language_type = choices[chosen_language]
				recipient.grant_language(language_type)
				choices -= chosen_language
				to_chat(recipient, span_info("I recall my knowledge of [chosen_language]..."))
				count--


/datum/virtue/background/light_steps //remember to drag dustrunner over
	name = "Light Steps"
	desc = "Years of skulking about have left my steps quiet, and my hunched gait quicker."
	added_traits = list(TRAIT_LIGHT_STEP)
	added_skills = list(list(/datum/skill/misc/sneaking, 3, 6))

/datum/virtue/background/light_steps/apply_to_human(mob/living/carbon/human/H)
	var/equipment = list("Skulker","Larcenous")
	var/equip_choice = input(H,"My lyfe before, STASHed away ...", "TREES and STATUES hold my things.") as anything in equipment
	switch(equip_choice)
		if("Skulker")
			if(H.mind)
				H.mind.special_items = list(
					"Equipment Bag" = /obj/item/storage/roguebag/lightstep 
					
				)
			H.adjust_skillrank_up_to(/datum/skill/misc/lockpicking, 1, 3)
			H.adjust_skillrank_up_to(/datum/skill/misc/stealing, 1, 3)
			H.adjust_skillrank_up_to(/datum/skill/misc/sneaking, 3, 4)

		if("Larcenous")
			if(H.mind)
				H.mind.special_items = list(
					"Equipment Bag" = /obj/item/storage/roguebag/larcscoundrel 
					
				)
			H.adjust_skillrank_up_to(/datum/skill/misc/lockpicking, 3, 4)
			H.adjust_skillrank_up_to(/datum/skill/misc/stealing, 3, 4)
			H.adjust_skillrank_up_to(/datum/skill/misc/sneaking, 1, 3)

/datum/virtue/background/militia
	name = "Militiaman"
	desc = "I have trained with the local garrison in case I'm ever to be levied to fight for my lord. My gear is stashed away, in case I am ever levied."
	custom_text = "+2 to Maces, Polearms, & Slings (Max Journeyman) depending on equipment choice (Cudgel, Quarterstaff, Spear+Sling)."
/datum/virtue/background/militia/apply_to_human(mob/living/carbon/human/H)
	var/equipment = list("Guard (Cudgel, Buckler)","Watchman (Quarterstaff)","Conscript (Spear, Sling)")
	var/equip_choice = input(H,"My lyfe before, STASHed away ...", "What I was and am. TREES and STATUES hold my precious things.") as anything in equipment
	switch(equip_choice)
		if("Guard (Cudgel, Buckler)")
			if(H.mind)
				H.mind.special_items = list(
					"Equipment Bag" = /obj/item/storage/roguebag/militiaguard, 
					"Cudgel" = /obj/item/rogueweapon/mace/cudgel,
					"Buckler" = /obj/item/rogueweapon/shield/buckler,
				)
			H.adjust_skillrank_up_to(/datum/skill/combat/maces, 2, 3)
		if("Watchman (Quarterstaff)")
			if(H.mind)
				H.mind.special_items = list(
					"Equipment Bag" = /obj/item/storage/roguebag/militiawatch, 
					"Quarterstaff" = /obj/item/rogueweapon/woodstaff/quarterstaff/steel
				)
			H.adjust_skillrank_up_to(/datum/skill/combat/polearms, 2, 3)
		if("Conscript (Spear, Sling)")
			if(H.mind)
				H.mind.special_items = list(
					"Equipment Bag" = /obj/item/storage/roguebag/militiaconscript, 
					"Militia Spear" = /obj/item/rogueweapon/spear/militia,
				)
			give_special_items(H)
			H.adjust_skillrank_up_to(/datum/skill/combat/polearms, 2, 3)
			H.adjust_skillrank_up_to(/datum/skill/combat/slings, 2, 3)

/datum/virtue/background/mining
	name = "Miner's Apprentice"
	desc = "The dark shafts, the damp smells of ichor and the laboring hours are no stranger to me. I keep my pickaxe and lamptern close, and have been taught how to mine well."
	added_stashed_items = list(
		"Steel Pickaxe" = /obj/item/rogueweapon/pick/steel,
		"Lamptern" = /obj/item/flashlight/flare/torch/lantern)
	added_skills = list(list(/datum/skill/labor/mining, 3, 6))

/datum/virtue/utility/performer // add two instrument selection? & ... outfit?
	name = "Performer"
	desc = "Music, artistry and the act of showmanship carried me through life. I've hidden a favorite instrument of mine, know how to please anyone I touch, and how to crack the eggs of hecklers."
	custom_text = "Comes with a stashed instrument of your choice. You choose the instrument after spawning in."
	added_traits = list(TRAIT_NUTCRACKER, TRAIT_GOODLOVER)
	added_skills = list(list(/datum/skill/misc/music, 4, 6))

/datum/virtue/utility/performer/apply_to_human(mob/living/carbon/human/recipient)
    addtimer(CALLBACK(src, .proc/performer_apply, recipient), 50)

/datum/virtue/utility/performer/proc/performer_apply(mob/living/carbon/human/recipient)
	var/list/instruments = list()
	for(var/instrument_type in subtypesof(/obj/item/rogue/instrument))
		if(instrument_type == /obj/item/rogue/instrument/harp/handcarved)
			continue //Skip the donator personal item harp.
		var/obj/item/rogue/instrument/instr = new instrument_type()
		instruments[instr.name] = instrument_type
		qdel(instr)  // Clean up the temporary instance

	var/chosen_name = input(recipient, "What instrument did I stash?", "STASH") as null|anything in instruments
	if(chosen_name)
		var/instrument_type = instruments[chosen_name]
		recipient.mind?.special_items[chosen_name] = instrument_type

/datum/virtue/background/physician
	name = "Physician's Apprentice"
	desc = "In my youth, I worked under a skilled physician, studying medicine and alchemy."
	custom_text = "Alchemist comes with a bedroll, healing vials, and basic medical supplies. Surgeon is equipped with improvised surgical tools, a bedroll, and a needle."
	added_skills = list(list(/datum/skill/craft/crafting, 2, 2),
						list(/datum/skill/craft/alchemy, 2, 2),
						list(/datum/skill/misc/medicine, 2, 2)
	)
/datum/virtue/background/physician/apply_to_human(mob/living/carbon/human/H)
	var/equipment = list("Alchemist","Surgeon")
	var/equip_choice = input(H,"My lyfe before, STASHed away ...", "TREES and STATUES hold my things.") as anything in equipment
	switch(equip_choice)
		if("Alchemist")
			if(H.mind)
				H.mind.special_items = list(
					"Equipment Bag" = /obj/item/storage/roguebag/physalc, 
				)
		if("Surgeon")
			if(H.mind)
				H.mind.special_items = list(
					"Equipment Bag" = /obj/item/storage/roguebag/physurg, 
				)

/datum/virtue/background/roguealchemist
	name = "Rogue Alchemist"
	desc = "I like to watch the world burn, and I've stowed away bombs and materials to help me achieve that fact."
	custom_text = "+2 Alchemy (Maximum Expert), Firebombs, Familiar Scroll, & Bomb Materials."
	added_skills = list(list(/datum/skill/craft/alchemy, 2, 4))

/datum/virtue/background/arsonist/apply_to_human(mob/living/carbon/human/H)
	var/equipment = list("Bomber")
	var/equip_choice = input(H,"My lyfe before, STASHed away ...", "TREES and STATUES hold my things.") as anything in equipment
	switch(equip_choice)
		if("Bomber")
			if(H.mind)
				H.mind.special_items = list(
					"Equipment Bag" = /obj/item/storage/roguebag/arsonbomb, 
					
				)

/datum/virtue/background/sailor
	name = "Sailor"
	desc = "You spent your daes on the sea, learning to brace ships against storms and swim against Abyssor's tides."
	custom_text = "Comes with carpentry tools, fishing rod + bait, and an axe."
	added_skills = list(list(/datum/skill/misc/swimming, 2, 3),
						list(/datum/skill/misc/athletics, 2, 3),
						list(/datum/skill/craft/crafting, 2, 2),
						list(/datum/skill/craft/carpentry, 2, 2),
						list(/datum/skill/labor/fishing, 2, 6))

/datum/virtue/background/sailor/apply_to_human(mob/living/carbon/human/H)
	var/equipment = list("Sailor")
	var/equip_choice = input(H,"My lyfe before, STASHed away ...", "TREES and STATUES hold my things.") as anything in equipment
	switch(equip_choice)
		if("Sailor")
			if(H.mind)
				H.mind.special_items = list(
					"Equipment Bag" = /obj/item/storage/roguebag/sailfix 
					
				)

/datum/virtue/utility/tracker
	name = "Sleuth"
	desc = "You realised long ago that the ability to find a man is as helpful to aid the law as it is to evade it."
	added_skills = list(list(/datum/skill/misc/tracking, 3, 6))
	added_traits = list(TRAIT_SLEUTH)
	custom_text = "- Upon right clicking a track, you will Mark the person who made them <i>(Expert skill required, not exclusive to this Virtue)</i>.\n- Further tracks found will be automatically highlighted as theirs, along with the person themselves, if they are not sneaking or invisible at the time.\n- Reduces the cooldown for tracking, allows track examining right away, and movement no longer cancels tracking. Comes with a net and rope."
	added_stashed_items = list(
		"Equipment Bag" = /obj/item/storage/roguebag/sleuth)

/datum/virtue/background/bowman
	name = "Toxophilite"
	desc = "I've had an interest in archery from a young age, and I always keep a spare bow and quiver around."
	custom_text = "+2 to Bows and Crossbows (Max Journeyman), depending on equipment choice (Receuve Bow or Crossbow)."

/datum/virtue/background/bowman/apply_to_human(mob/living/carbon/human/H)
	var/equipment = list("Archer","Crossbowman")
	var/equip_choice = input(H,"My lyfe before, STASHed away ...", "TREES and STATUES hold my things.") as anything in equipment
	switch(equip_choice)
		if("Archer")
			if(H.mind)
				H.mind.special_items = list(
					"Equipment Bag" = /obj/item/storage/roguebag/toxarcher,
					"Recurve Bow" =  /obj/item/gun/ballistic/revolver/grenadelauncher/bow/recurve,
					"Quiver" = /obj/item/quiver/arrows
					
				)
			H.adjust_skillrank_up_to(/datum/skill/combat/bows, 2, 3)
		if("Crossbowman")
			if(H.mind)
				H.mind.special_items = list(
					"Equipment Bag" = /obj/item/storage/roguebag/toxcross,
					"Crossbow" = /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow,
					"Quiver" = /obj/item/quiver/bolts
					
				)
			H.adjust_skillrank_up_to(/datum/skill/combat/crossbows, 2, 3)





// ALL OBJ HERE!

///obj/item/storage/roguebag/template
//	populate_contents = list(
//	)

//Rogue Alchemist
/obj/item/storage/roguebag/arsonbomb
	populate_contents = list(
		/obj/item/book/granter/spell/blackstone/familiar,
		/obj/item/bomb,
		/obj/item/bomb,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/ash, 
		/obj/item/ash, 
		/obj/item/ash, 
		/obj/item/ash, 
		/obj/item/rogueore/coal,
		/obj/item/rogueore/coal,
		/obj/item/natural/cloth,
		/obj/item/natural/cloth
	)

/obj/item/storage/roguebag/arsonenhance //do this dumby
	populate_contents = list(,
		/obj/item/flashlight/flare/torch,
		/obj/item/flashlight/flare/torch
		//return to this
			
	)

//Artificer
/obj/item/storage/roguebag/artificertinker
	populate_contents = list(
		/obj/item/contraption,
		/obj/item/contraption,
		/obj/item/contraption,
		/obj/item/ingot/bronze,
		/obj/item/ingot/bronze,
		/obj/item/ingot/bronze,
		/obj/item/natural/bundle/stick,
		/obj/item/natural/bundle/stick,
		/obj/item/natural/bundle/stick,
		/obj/item/natural/bundle/stick

	)
/obj/item/storage/roguebag/artificermason
	populate_contents = list(
		/obj/item/rogueweapon/blowrod,
		/obj/item/natural/bundle/brick,
		/obj/item/natural/bundle/brick,
		/obj/item/natural/bundle/brick,
		/obj/item/natural/bundle/brick,
		/obj/item/natural/bundle/brick,
		/obj/item/natural/bundle/brick,
		/obj/item/natural/bundle/brick
		//add more here

	)

//Blacksmith
/obj/item/storage/roguebag/smithapp
	populate_contents = list(
		/obj/item/rogueweapon/tongs,
		/obj/item/rogueweapon/hammer/iron,
		/obj/item/ingot/iron,
		/obj/item/ingot/iron,
		/obj/item/ingot/iron,
		/obj/item/ingot/steel,
		/obj/item/ingot/steel,
		/obj/item/rogueore/coal,
		/obj/item/rogueore/coal,
		/obj/item/rogueore/coal,
		/obj/item/rogueore/coal
	)

/obj/item/storage/roguebag/smithscrap
	populate_contents = list(
		/obj/item/rogueweapon/tongs,
		/obj/item/rogueweapon/hammer/iron,
		/obj/item/ingot/iron,
		/obj/item/rogueore/coal,
		/obj/item/rogueore/coal,
		/obj/item/rogueore/coal,
		/obj/item/rogueore/coal,
		/obj/item/rogueore/coal,

	)


//Brawler
/obj/item/storage/roguebag/brawlkatar
	populate_contents = list(
		/obj/item/clothing/wrists/roguetown/bracers/leather,
		/obj/item/rogueweapon/katar,
		/obj/item/needle/thorn

	)

/obj/item/storage/roguebag/brawlknuck
	populate_contents = list(
		/obj/item/clothing/wrists/roguetown/bracers/leather,
		/obj/item/rogueweapon/knuckles,
		/obj/item/needle/thorn
	)

//Cunning Provisioner
/obj/item/storage/backpack/rogue/artibackpack/cunningchef
	populate_contents = list(
		/obj/item/reagent_containers/food/snacks/rogue/dough,
		/obj/item/reagent_containers/food/snacks/rogue/dough,
		/obj/item/reagent_containers/food/snacks/rogue/dough, 
		/obj/item/reagent_containers/food/snacks/butter,
		/obj/item/rogueweapon/huntingknife/chefknife,
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/cooking/pan,
		/obj/item/reagent_containers/food/snacks/rogue/meat/steak,
		/obj/item/reagent_containers/food/snacks/rogue/meat/steak,
		/obj/item/reagent_containers/food/snacks/rogue/meat/steak,
		/obj/item/reagent_containers/food/snacks/rogue/cheese
	)

/obj/item/storage/backpack/rogue/artibackpack/cunningfish
	populate_contents = list(
		/obj/item/natural/worms,
		/obj/item/natural/worms,
		/obj/item/natural/worms,
		/obj/item/natural/worms,
		/obj/item/natural/worms,
		/obj/item/natural/worms,
		/obj/item/natural/worms,
		/obj/item/natural/worms,
		/obj/item/natural/worms,
		/obj/item/grown/log/tree/small,
		/obj/item/grown/log/tree/small,
		/obj/item/natural/bundle/stick,
		/obj/item/natural/bundle/stick,
		/obj/item/fishingrod

	)

//Duelist
/obj/item/storage/roguebag/duelistnoble
	populate_contents = list(
		/obj/item/clothing/ring/duelist,
		/obj/item/clothing/ring/duelist,
		/obj/item/rogueweapon/huntingknife/idagger/steel/parrying,
		/obj/item/clothing/head/roguetown/duelhat,
		/obj/item/clothing/suit/roguetown/armor/gambeson/light
		
	)

/obj/item/storage/roguebag/duelistsword
	populate_contents = list(
		/obj/item/clothing/suit/roguetown/armor/gambeson/lord,
		/obj/item/rogueweapon/sword/iron,
		/obj/item/rogueweapon/shield/buckler/palloy,
		/obj/item/clothing/neck/roguetown/chaincoif/iron
	)

/obj/item/storage/roguebag/duelistscoundrel
	populate_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/steel,
		/obj/item/rogueweapon/huntingknife/idagger/steel,
		/obj/item/clothing/under/roguetown/trou/leather,
		/obj/item/clothing/suit/roguetown/armor/leather/jacket
	)

//Dungeoneer
/obj/item/storage/roguebag/dungeonguard
	populate_contents = list(
		/obj/item/clothing/suit/roguetown/armor/leather,
		/obj/item/clothing/under/roguetown/trou/leather,
		/obj/item/clothing/head/roguetown/helmet/leather,
		/obj/item/rogueweapon/whip,
		/obj/item/rope/chain,
		/obj/item/rope/chain,
		/obj/item/rope,
		/obj/item/rope,
		/obj/item/needle/thorn

	)

/obj/item/storage/roguebag/dungeonexecute
	populate_contents = list(
		/obj/item/clothing/suit/roguetown/armor/leather,
		/obj/item/clothing/under/roguetown/trou/leather,
		/obj/item/clothing/head/roguetown/helmet/leather,
		/obj/item/natural/whetstone,
		/obj/item/needle/thorn

	)

//Forester
/obj/item/storage/roguebag/forestlumber
	populate_contents = list(
		/obj/item/natural/whetstone,
		/obj/item/natural/worms,
		/obj/item/natural/worms,
		/obj/item/natural/worms,
		/obj/item/natural/worms,
		/obj/item/natural/worms,
		/obj/item/natural/worms,
		/obj/item/fishingrod
	)

/obj/item/storage/roguebag/forestfarm
	populate_contents = list(
		/obj/item/reagent_containers/glass/bucket,
		/obj/item/rogueweapon/huntingknife,
		/obj/item/reagent_containers/food/snacks/grown/wheat,
		/obj/item/reagent_containers/food/snacks/grown/wheat,
		/obj/item/reagent_containers/food/snacks/grown/wheat,
		/obj/item/reagent_containers/food/snacks/grown/wheat,
		/obj/item/reagent_containers/food/snacks/grown/wheat,
		/obj/item/seeds/wheat,
		/obj/item/seeds/wheat,
		/obj/item/seeds/onion,
		/obj/item/seeds/onion,
		/obj/item/seeds/apple,
		/obj/item/seeds/apple,
		/obj/item/millstone
	)

//Hunter
/obj/item/storage/roguebag/huntertrap
	populate_contents = list(
		/obj/item/rogueweapon/huntingknife,
		/obj/item/bait,
		/obj/item/bait/sweet,
		/obj/item/bait/sweet,
		/obj/item/grown/log/tree/small,
		/obj/item/natural/bundle/fibers,
		/obj/item/natural/bundle/fibers,
		/obj/item/ingot/iron

	)

/obj/item/storage/roguebag/huntertan
	populate_contents = list(
		/obj/item/rogueweapon/huntingknife,
		/obj/item/natural/bundle/stick,
		/obj/item/natural/bundle/stick,
		/obj/item/natural/bundle/stick,
		/obj/item/needle/thorn,
		/obj/item/bait,
		/obj/item/bait/sweet,
		/obj/item/bait/sweet,
		/obj/item/reagent_containers/food/snacks/fat,
		/obj/item/reagent_containers/food/snacks/fat,
		/obj/item/reagent_containers/food/snacks/fat,
		/obj/item/cooking/pan/aalloy

	)

//Intellectual
/obj/item/storage/roguebag/intarchive
	populate_contents = list(
		/obj/item/skillbook/unfinished,
		/obj/item/paper,
		/obj/item/paper,
		/obj/item/paper,
		/obj/item/natural/feather //same backpack load as archivist - more parchment's easy to acquire

	)

//Lightstep
/obj/item/storage/roguebag/lightstep
	populate_contents = list(
		/obj/item/lockpick,
		/obj/item/lockpick,
		/obj/item/lockpick,
		/obj/item/bomb/smoke,
		/obj/item/bomb/smoke,
		/obj/item/bomb/smoke
	)

//Larcenous
/obj/item/storage/roguebag/larcscoundrel
	populate_contents = list(
		/obj/item/lockpickring/mundane,
		/obj/item/lockpick,
		/obj/item/lockpick,
		/obj/item/lockpick,
		/obj/item/rogueweapon/huntingknife/idagger
	)

//Militia
/obj/item/storage/roguebag/militiaguard
	populate_contents = list(
		/obj/item/clothing/head/roguetown/helmet/kettle,
		/obj/item/clothing/suit/roguetown/armor/gambeson/light,
		/obj/item/rope/chain,
		/obj/item/needle/thorn
	)

/obj/item/storage/roguebag/militiawatch
	populate_contents = list(
		/obj/item/clothing/head/roguetown/helmet/kettle,
		/obj/item/clothing/suit/roguetown/armor/gambeson/light,
		/obj/item/reagent_containers/glass/bottle/alchemical/endpot
	)

/obj/item/storage/roguebag/militiaconscript
	populate_contents = list(
		/obj/item/clothing/head/roguetown/helmet/kettle,
		/obj/item/clothing/suit/roguetown/armor/gambeson/light,
		/obj/item/gun/ballistic/revolver/grenadelauncher/sling,
		/obj/item/quiver/sling
	)

//Miner
/obj/item/storage/backpack/minerbag
	populate_contents = list(
		/obj/item/rogueweapon/pick/steel,
		/obj/item/flashlight/flare/torch/lantern

	)

//Physician
/obj/item/storage/roguebag/physurg
	populate_contents = list(
		/obj/item/rogueweapon/surgery/saw/improv,
		/obj/item/rogueweapon/surgery/hemostat/improv,
		/obj/item/rogueweapon/surgery/hemostat/improv,
		/obj/item/rogueweapon/surgery/retractor/improv,
		/obj/item/rogueweapon/surgery/scalpel/improv,
		/obj/item/rogueweapon/surgery/hammer,
		/obj/item/needle,
		/obj/item/bedroll
	)

/obj/item/storage/roguebag/physalc
	populate_contents = list(
		/obj/item/needle,
		/obj/item/natural/bundle/cloth,
		/obj/item/natural/bundle/cloth,
		/obj/item/rogueweapon/surgery/hammer,
		/obj/item/reagent_containers/glass/bottle/alchemical/healthpot,
		/obj/item/reagent_containers/glass/bottle/alchemical/healthpot,
		/obj/item/alch/urtica,
		/obj/item/alch/valeriana,
		/obj/item/alch/urtica,
		/obj/item/alch/valeriana,

	)

//Sailor
/obj/item/storage/roguebag/sailfix
	populate_contents = list(
		/obj/item/rogueweapon/stoneaxe/woodcut,
		/obj/item/natural/bundle/stick,
		/obj/item/natural/bundle/stick,
		/obj/item/natural/bundle/stick,
		/obj/item/grown/log/tree/small,
		/obj/item/rogueweapon/handsaw,
		/obj/item/rogueweapon/hammer/wood,
		/obj/item/fishingrod
	)

//Sleuth
/obj/item/storage/roguebag/sleuth
	populate_contents = list(
		/obj/item/net,
		/obj/item/rope,
		/obj/item/rope
	)

//Toxophilite
/obj/item/storage/roguebag/toxarcher
	populate_contents = list(
		/obj/item/clothing/head/roguetown/helmet/leather,
		/obj/item/clothing/gloves/roguetown/fingerless_leather,
		/obj/item/clothing/under/roguetown/trou/leather
	)

/obj/item/storage/roguebag/toxcross
	populate_contents = list(
		/obj/item/clothing/head/roguetown/helmet/kettle,
		/obj/item/clothing/suit/roguetown/armor/gambeson/light
	)
