/*
	Combat Mode Music Track Datums
	---
	Currently only used for overriding the default combat music that comes with your job or antagonist.
	As of writing they are never directly applied to mobs themselves, only the name and musicpath are.
	Deleting these datums or renaming subtypes will not break preferences; invalid saves get redirected to /default.
	When adding new songs, add a shortname around ~12 characters for the game preferences menu.
	
	IMPORTANT! Be careful about adding songs to this list that aren't used anywhere else, lest you needlessly inflate the RSC.
*/

// Admins: please don't molest my lists. You can't add new types at runtime anyways. Kisses! - Zoktiik
GLOBAL_LIST_EMPTY(cmode_tracks_by_type)
GLOBAL_LIST_EMPTY(cmode_tracks_by_name)

// People make mistakes. This should help catch when that happens.
/proc/cmode_track_to_namelist(var/datum/combat_music/track)
	if(!track)
		return
	if(!track.name)
		LAZYREMOVE(GLOB.cmode_tracks_by_type, track.type)
		CRASH("CMODE MUSIC: type [track.type] has no name!") 
	if(GLOB.cmode_tracks_by_name[track.name])
		LAZYREMOVE(GLOB.cmode_tracks_by_type, track.type)
		CRASH("CMODE MUSIC: type [track.type] has duplicate name \"[track.name]\"!")
	GLOB.cmode_tracks_by_name[track.name] = track
	return

/datum/combat_music
	var/name
	var/desc
	var/shortname
	var/credits
	var/musicpath = list()

// Shit WILL break if you change /default's typepath. Don't do it.
/datum/combat_music/default
	name = "Default"
	desc = "I let my current status sing for itself; its song will change dynamically."
	shortname = "Default"
	musicpath = list()

/datum/combat_music/adjudicator
	name = "Adjudicator"
	desc = "Now, there is nothing more cruel, than a fair judge."
	shortname = "Adjudicator"
	credits = "Chivalry 2 OST: Duty and Honor II (with Ryan Patrick Buckley)"
	musicpath = list('sound/music/templarofpsydonia.ogg')

/datum/combat_music/ascended
	name = "Ascended"
	desc = "No mortal could ever comprehend the heights to which I've risen."
	shortname = "Ascended"
	credits = "TO PIERCE THE BLACK SKY /// ENVY INTERLUDE - UNFORTUNATE DEVELOPMENT"
	musicpath = list('sound/music/combat_ascended.ogg')

/datum/combat_music/astratan_zeal
	name = "Astratan Zeal"
	desc = "You will never bloody your hand, striking with Her guidance."
	shortname = "Astratan"
	credits = "Jesper Kyd - Light of the Imperium"
	musicpath = list('sound/music/combat_holy.ogg')

/datum/combat_music/bandit_soldier
	name = "Bandit - Soldier"
	desc = "Noble swine, they've found us! Dispatch them!"
	shortname = "Bandit Sold."
	credits = "Deus Ex - Battery Park Combat"
	musicpath = list('sound/music/combat_bandit.ogg')

/datum/combat_music/bandit_rogue
	name = "Bandit - Rogue"
	desc = "Your visors and plates are no match for the tip of my blade. Approach me!"
	shortname = "Bandit Rogue"
	credits = "Evanora Unlimited - Mithlond (Instrumental)"
	musicpath = list('sound/music/combat_bandit2.ogg')

/datum/combat_music/bandit_brigand
	name = "Bandit - Brute"
	desc = "I don't care if I'm one against five. They're not breaking through."
	shortname = "Bandit Brut."
	credits = "Silent Scream - Lateralis"
	musicpath = list('sound/music/combat_bandit_brigand.ogg')

// Bandit Rogue Mage track can be found down at /mage since it's generic.

/datum/combat_music/barbarian
	name = "Barbarian"
	desc = "Grit as if you had teeth to grit with left."
	shortname = "Barbarian"
	musicpath = list('sound/music/combat_gronn.ogg')

/datum/combat_music/bard
	name = "Bard"
	desc = "At least you will make for a good tale."
	shortname = "Bard"
	musicpath = list('sound/music/combat_bard.ogg')

/datum/combat_music/berserker
	name = "Berserker"
	desc = "All of it broke you, bit by bit until you became strong."
	shortname = "Berserker"
	credits = "Mikolai Stroinski - Eyes of the Wolf"
	musicpath = list('sound/music/combat_berserker.ogg')

/datum/combat_music/blackoak
	name = "Black Oak's Guardian"
	desc = "Trees were made for hanging."
	shortname = "Black Oak"
	musicpath = list('sound/music/combat_blackoak.ogg')

/datum/combat_music/beggar
	name = "Beggar"
	desc = "Kick, scratch, bite."
	shortname = "Beggar"
	credits = "Pathologic (Classic) - Most Combat Theme"
	musicpath = list('sound/music/combat_bum.ogg')

/datum/combat_music/conddottiero
	name = "Condottiero Guildsman"
	desc = "Rue the dae, of the smiling profiteer."
	shortname = "Condottiero"
	musicpath = list('sound/music/combat_condottiero.ogg')

/datum/combat_music/cultic
	name = "Cultic Witchcraft"
	desc = "I'm worked to the bone, but I cannot be laid to rest. What am I?"
	shortname = "Cultic"
	credits = "Igor Kornelyuk - Воланд (\"Voland\")"
	musicpath = list('sound/music/combat_cult.ogg')

/datum/combat_music/combat
	name = "Combat Classic (Adventurer)"
	desc = "Try and perish somewhere easy to loot."
	shortname = "Combt Classic"
	musicpath = list('sound/music/combat.ogg')

/datum/combat_music/combat_old
	name = "Combat Old (Town Elder)"
	desc = "Making mistakes is lyfe, watching them being made, is torture."
	shortname = "Combt Old"
	musicpath = list('sound/music/combat_old.ogg')

/* Unused
/datum/combat_music/combat_old_2
	name = "Combat Old 2"
	desc = ""
	shortname = "Combat Old 2"
	musicpath = list('sound/music/combat2.ogg')
*/

/datum/combat_music/deadite
	name = "Deadite"
	desc = "KICK! SCRATCH! BITE!"
	shortname = "Deadite"
	musicpath = list('sound/music/combat_weird.ogg')

/datum/combat_music/desertrider
	name = "Desert Rider Mercenary"
	desc = "A toast to the highest bidder."
	shortname = "Desert Rider"
	credits = "Two Fingers - You Ain't Down"
	musicpath = list('sound/music/combat_desertrider.ogg')

/datum/combat_music/druid
	name = "Druid (Verewolf)"
	desc = "Dead ends, countless trails, suffocating mud. More dangerous than any blade."
	shortname = "Druid"
	credits = "The Witcher 3: Wild Hunt - Hunt or Be Hunted"
	musicpath = list('sound/music/combat_druid.ogg')

/datum/combat_music/duelist
	name = "Duelist"
	desc = "Battlefields and arenas. Even this is art."
	shortname = "Duelist"
	credits = "Medieval Total War 2 OST: Spanish Battle Theme"
	musicpath = list('sound/music/combat_duelist.ogg')

/datum/combat_music/dungeoneer
	name = "Dungeoneer"
	desc = "Oh, but the things I would do upon this town if I wasn't employed."
	shortname = "Dungeoneer"
	credits = "T87-Sulfurhead - RATEATER (https://www.youtube.com/@T87-Sulfurhead)"
	musicpath = list('sound/music/combat_dungeoneer.ogg')

/datum/combat_music/dwarf
	name = "Dwarven Grudgebearer"
	desc = "See this? It's some sort of guestbook."
	shortname = "Dwarf"
	musicpath = list('sound/music/combat_dwarf.ogg')

/datum/combat_music/forlorn
	name = "Forlorn Hope Mercenary"
	desc = "Do you feel like you escaped death, vanguard?"
	shortname = "Forlorn Hope"
	musicpath = list('sound/music/combat_blackstar.ogg')

/datum/combat_music/fullplate
	name = "Full Plate"
	desc = "Knight in waning armour."
	shortname = "Full Plate"
	credits = "Stoneshard OST - Track 9 (https://youtu.be/duI4N5MTyKY?si=aHEUbkUzEHSDsIRh)"
	musicpath = list('sound/music/combat_fullplate.ogg')

/datum/combat_music/grenzelhoft
	name = "Grenzelhoft Mercenary"
	desc = "Your attitude is intolerable and your smile is disgusting. You're hired."
	shortname = "Grenzelhoft"
	credits = "Helbrede - Sons of Tyr"
	musicpath = list('sound/music/combat_grenzelhoft.ogg')

/* Unused
/datum/combat_music/guard_song_1
	name = "Guard Song 1"
	desc = ""
	shortname = "Guard Song 1"
	musicpath = list('sound/music/combat_bog.ogg')
*/

/* Unused
/datum/combat_music/guard_song_2
	name = "Guard Song 2"
	desc = ""
	shortname = "Guard Song 2"
	credits = "Deus Ex The Conspiracy (PS2) / Deus Ex Revision - UNATCO HQ Combat Theme"
	musicpath = list('sound/music/combat_guard_bog.ogg')
*/

/* Unused
/datum/combat_music/guard_song_3
	name = "Guard Song 3"
	desc = ""
	shortname = "Guard 3"
	credits = "Deus Ex The Conspiracy (PS2) / Deus Ex Revision - UNATCO Combat Theme"
	musicpath = list('sound/music/combat_guard3.ogg')
*/

/* Unused
/datum/combat_music/guard_song_4
	name = "Guard Song 4"
	desc = ""
	shortname = "Guard 4"
	credits = "Deus Ex The Conspiracy (PS2) / Deus Ex Revision - NYC Combat Theme"
	musicpath = list('sound/music/combat_guard4.ogg')
*/

/datum/combat_music/heretic_zizo
	name = "Heretic - Zizo (Lich)"
	desc = "Trust nobody, after all the power has always been within you."
	shortname = "Zizo"
	credits = "T87-Sulfurhead - DEMESNE (https://www.youtube.com/@T87-Sulfurhead)"
	musicpath = list('sound/music/combat_heretic.ogg')

/datum/combat_music/heretic_matthios
	name = "Heretic - Matthios"
	desc = "A rush of vigour. You've forgotten the last time you were told what's right or what to do."
	shortname = "Matthios"
	credits = "T87-Sulfurhead - Amontillado (https://www.youtube.com/@T87-Sulfurhead)"
	musicpath = list('sound/music/combat_matthios.ogg')

/datum/combat_music/heretic_graggar
	name = "Heretic - Graggar"
	desc = "Perhaps this time, you will finally feel powerful."
	shortname = "Graggar"
	credits = "T87-Sulfurhead - Black Powder (https://www.youtube.com/@T87-Sulfurhead)"
	musicpath = list('sound/music/combat_graggar.ogg')

/datum/combat_music/heretic_baotha
	name = "Heretic - Baotha"
	desc = "Fuck tomorrow."
	shortname = "Baotha"
	credits = "T87-Sulfurhead - Love Within You (Rough Mix) (https://www.youtube.com/@T87-Sulfurhead)"
	musicpath = list('sound/music/combat_baotha.ogg')

/datum/combat_music/highgrain
	name = "High Grain"
	desc = "I had him dead before he hit the ground."
	shortname = "High Grain"
	credits = "Half-Lyfe: Alyx - APC Cannon - Extended (https://youtu.be/LsGts7dAqTQ?si=wAMHGtrMKzHxyIon)"
	musicpath = list('sound/music/combat_highgrain.ogg')

/datum/combat_music/iconoclast
	name = "Iconoclast"
	desc = ""
	shortname = "Iconoclast"
	credits = "Valley of Judgement- Lateralis"
	musicpath = list('sound/music/Iconoclast.ogg')

/datum/combat_music/inquisitor
	name = "Inquisitor (Monster Hunter/Spellbreaker)"
	desc = ""
	shortname = "Inquisitor"
	credits = "Hellsing OST RAID Track 15: Survival on the Street of Insincerity"
	musicpath = list('sound/music/inquisitorcombat.ogg')

/datum/combat_music/inquis_ordinator
	name = "Inquisitor - Ordinator"
	desc = ""
	shortname = "Ordinator"
	musicpath = list('sound/music/combat_inqordinator.ogg')

/datum/combat_music/jester
	name = "Jester"
	desc = ""
	shortname = "Jester"
	credits = "Alias Conrad Coldwood - Pepper Steak (OFF OST)"
	musicpath = list('sound/music/combat_jester.ogg')

/datum/combat_music/kazengite
	name = "Kazengite"
	desc = ""
	shortname = "Kazengite"
	musicpath = list('sound/music/combat_kazengite.ogg')

/datum/combat_music/knight
	name = "Knight (Noble)"
	desc = ""
	shortname = "Knight"
	credits = "T87-Sulfurhead - Durandal (https://www.youtube.com/@T87-Sulfurhead)"
	musicpath = list('sound/music/combat_knight.ogg')

/datum/combat_music/man_at_arms
	name = "Man at Arms (Sergeant)"
	desc = ""
	shortname = ""
	credits = "T87-Sulfurhead - Ready or Not (https://www.youtube.com/@T87-Sulfurhead)"
	musicpath = list('sound/music/combat_ManAtArms.ogg')

/datum/combat_music/mage
	name = "Magician (Rogue Mage)"
	desc = ""
	shortname = "Magician"
	credits = "Timestopper Tactics - corru.works"
	musicpath = list('sound/music/combat_bandit_mage.ogg')

/datum/combat_music/malpractice
	name = "Malpractice"
	desc = "What kills you, makes you weaker."
	shortname = "Malpractice"
	credits = "Pathologic - Utroba Aggression"
	musicpath = list('sound/music/combat_malpractice.ogg')

// Maniac code has this track uncommented so this is free. And tbh it should remain here. Banger.
/datum/combat_music/maniac
	name = "Maniac"
	desc = "TNC is the fairest company I know."
	shortname = "Maniac"
	credits = "Thomas Bangalter - Stress"
	musicpath = list('sound/music/combat_maniac2.ogg')

/* Unused
/datum/combat_music/maniac_old
	name = "Maniac (Old)"
	desc = ""
	shortname = "Maniac Old"
	musicpath = list('sound/music/combat_maniac.ogg')
*/

/datum/combat_music/martyr
	name = "Martyr"
	desc = ""
	shortname = "Martyr"
	musicpath = list('sound/music/combat_martyrsafe.ogg')

// The two Martyr Vengeance combat tracks are intentionally left out of this. Look how they're used.

/datum/combat_music/mastermind
	name = "Mastermind (!!Evil!!)"
	desc = "Every pally in the kingdom on my trail..."
	shortname = "Mastermind"
	credits = "burialgoods - APAB (All Paladins Are Bastards)"
	musicpath = list('sound/music/combat_mastermind.ogg')
	
/datum/combat_music/nitecreecher
	name = "Nite Creecher"
	desc = "Now they will know why they are afraid of the dark. Now they will learn why they fear the night."
	shortname = "Nite Creecher"
	credits = "Half-Lyfe - Diabolical Adrenaline Horror (https://youtu.be/xZad5J1I-OQ?si=dwlYDOJ8t8A2bdpB)"
	musicpath = list('sound/music/combat_nitecreecher.ogg')

/datum/combat_music/noble
	name = "Noble (Merchant/Freifechter)"
	desc = ""
	shortname = "Noble"
	musicpath = list('sound/music/combat_noble.ogg')

/datum/combat_music/ozium
	name = "Ozium Abuse"
	desc = "Alas, I must acquire a fast hold."
	shortname = "Ozium"
	credits = "Light Club - FAHKEET"
	musicpath = list('sound/music/combat_ozium.ogg')

/datum/combat_music/physician
	name = "Physician (Sawbones)"
	desc = ""
	shortname = "Physician"
	credits = "Michael Anthony - Klaus Schwab Rap (Instrumental)"
	musicpath = list('sound/music/combat_physician.ogg')

/datum/combat_music/poacher
	name = "Poacher Wretch"
	desc = ""
	shortname = "Poacher"
	musicpath = list('sound/music/combat_poacher.ogg')

/datum/combat_music/rogue
	name = "Rogue (Veteran Scout)"
	desc = ""
	shortname = "Rogue"
	musicpath = list('sound/music/combat_rogue.ogg')

/datum/combat_music/routier
	name = "Routier, Otavan"
	desc = ""
	shortname = "Rogue"
	musicpath = list('sound/music/combat_routier.ogg')

/datum/combat_music/shaman
	name = "Shaman, Atgervi"
	desc = ""
	shortname = "Shaman"
	credits = "Heilung - Elddansurin"
	musicpath = list('sound/music/combat_shaman2.ogg')

/* Unused
/datum/combat_music/shaman_old
	name = "Shaman, Atgervi (Old)"
	desc = ""
	shortname = "Shaman Old"
	musicpath = list('sound/music/combat_shaman.ogg')
*/

/datum/combat_music/soilson
	name = "Soilson"
	desc = ""
	shortname = "Soilson"
	credits = "Jeremy Soule - TESIV Oblivion - Death Knell"
	musicpath = list('sound/music/combat_soilson.ogg')

/datum/combat_music/squire
	name = "Squire"
	desc = ""
	shortname = "Squire"
	credits = "Dragon's Dogma OST: Tense Combat"
	musicpath = list('sound/music/combat_squire.ogg')

/datum/combat_music/starsugar
	name = "Starsugar Abuse (loud!)"
	desc = ""
	shortname = "Starsugar"
	credits = "FEMTANYL - DOGMATICA"
	musicpath = list('sound/music/combat_starsugar.ogg')

/datum/combat_music/steppe
	name = "Steppesman"
	desc = ""
	shortname = "Steppe"
	credits = "Tatar Theme (Hellish Quart OST)"
	musicpath = list('sound/music/combat_steppe.ogg')

/datum/combat_music/towner
	name = "Towner"
	desc = ""
	shortname = "Towner"
	credits = "Jeremy Soule - TESIV Oblivion - Daedra in Flight"
	musicpath = list('sound/music/combat_towner.ogg')

/datum/combat_music/treasure_hunter
	name = "Treasure Hunter"
	desc = ""
	shortname = "Treasure"
	credits = "Henry Jackman - Cut To The Chase"
	musicpath = list('sound/music/combat_treasurehunter.ogg')

/datum/combat_music/varangian
	name = "Varangian"
	desc = ""
	shortname = "Varangian"
	musicpath = list('sound/music/combat_vagarian.ogg')

/datum/combat_music/vampire
	name = "Vampire"
	desc = ""
	shortname = "Vampire"
	credits = "Filmmaker - Mystic Circles"
	musicpath = list('sound/music/combat_vamp2.ogg')

/* Unused
/datum/combat_music/vampire_old
	name = "Vampire (Old)"
	desc = ""
	shortname = "Vampire Old"
	musicpath = list('sound/music/combat_vamp.ogg')
*/

/datum/combat_music/vaquero
	name = "Vaquero (Cutpurse)"
	desc = ""
	shortname = "Vaquero"
	musicpath = list('sound/music/combat_vaquero.ogg')

/datum/combat_music/veteran
	name = "Veteran"
	desc = ""
	shortname = "Veteran"
	credits = "T87-Sulfurhead - Good Men Die Young (https://www.youtube.com/@T87-Sulfurhead)"
	musicpath = list('sound/music/combat_veteran.ogg')

/datum/combat_music/vigilante
	name = "Vigilante"
	desc = "One ear to the road saves two steps to the grave."
	shortname = "Vigilante"
	credits = "Stoneshard - Track 5 (https://youtu.be/duI4N5MTyKY?si=aHEUbkUzEHSDsIRh)"
	musicpath = list('sound/music/combat_vigilante.ogg')

/datum/combat_music/watchman
	name = "Watchman (Bailiff)"
	desc = ""
	shortname = "Watchman"
	credits = "Deus Ex The Conspiracy (PS2) / Deus Ex Revision - Hong Kong Canal Combat Theme"
	musicpath = list('sound/music/combat_guard.ogg')

/datum/combat_music/warden
	name = "Warden"
	desc = "At the end of the road, we meet again."
	shortname = "Warden"
	credits = "T87-Sulfurhead - Metamorphosis (https://www.youtube.com/@T87-Sulfurhead)"
	musicpath = list('sound/music/combat_warden.ogg')

/datum/combat_music/warscholar
	name = "Warscholar, Naledi"
	desc = ""
	shortname = "Warscholar"
	credits = "Butcher's Boulevard - Kristjan Thomas Haaristo"
	musicpath = list('sound/music/warscholar.ogg')

/* Unused. I love Filmmaker but this one ain't worth it.
/datum/combat_music/werewolf_old
	name = "Werewolf (Old)"
	desc = ""
	shortname = "Werewolf Old"
	credits = "Filmmaker - Federal Bestiary"
	musicpath = list('sound/music/combat_werewolf.ogg')
*/

/datum/combat_music/zybantine
	name = "Zybantine Slavers"
	desc = "The right to own slaves is the greatest freedom a man could ask for."
	shortname = "Zybantine"
	credits = "Hakan Glante - Crusader Kings 3 Fate of Iberia OST - War \"Short\""
	musicpath = list('sound/music/combat_zybantine.ogg')

/datum/combat_music/sohei
	name = "Sohei"
	desc = "Blades cross, sparks fly."
	shortname = "Sohei"
	credits = "Rapid As Wildfires - Yu-peng Chen"
	musicpath = list('sound/music/combat_sohei.ogg')

/datum/combat_music/swordhunter
	name = "Sword Hunter"
	desc = "Violence and greed, feeding into one another. Perpetuate the cycle."
	shortname = "Sword Hunter"
	credits = "Metal Gear Rising Revengeance - The Only Thing I Know For Real (Acoustic + Demo)"
	musicpath = list('sound/music/combat_swordhunter.ogg')
