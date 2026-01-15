/*
	Ogres have been disabled because they came in monumentally half-baked and madly overtuned to compensate for it.alist
	They're walking stat bricks that either demolish you in 3 hits or frustrate their players by being trivially easy to kill via bleed out.
	In conjunction with any kind of bleeding resistance, they become unstoppable killing machines. A vampire ogre is a VL class threat in melee.
	They suffer from Teshari disease in needing an entirely new set of equipment sprites for practically every equippable item in the game.

	This feature is essentially a testament to why maintainers need to sign off on code bounties BEFORE they're developed, because this shit sucked ass from the get go,
	and now that there is no money in it, it has been abandoned.
*/

/*/datum/job/roguetown/ogre
	title = "Ogre"
	flag = OGRE
	department_flag = PEASANTS
	faction = "Station"
	total_positions = 0
	spawn_positions = 0 // do not re-enable ogre until somebody actually fully finished them and they're not just monstrous 
	allowed_races = list()
	allowed_sexes = list(MALE, FEMALE)
	tutorial = "You are a migrating ogre from Gronn or another province of the world. Only recently have ogres begun to find their way into this region, and it smells of opportunity and a good meal. From Grenzelhoft to Naledi, all know the value of an ogre, and to fear a hungry one even more"
	display_order = JDO_OGRE
	selection_color = JCOLOR_PEASANT
	announce_latejoin = FALSE
	outfit = null
	outfit_female = null
	always_show_on_latechoices = TRUE
	min_pq = 35
	max_pq = null
	round_contrib_points = 2
	advclass_cat_rolls = list(CTAG_OGRE = 20)
	PQ_boost_divider = 10
	advjob_examine = TRUE
	job_reopens_slots_on_death = TRUE
	same_job_respawn_delay = 1 MINUTES
	cmode_music = 'sound/music/combat.ogg'

	job_traits = list(TRAIT_OUTLANDER, TRAIT_STEELHEARTED, TRAIT_OGRE_STRENGTH)
	job_subclasses = list(
		/datum/advclass/ogre/avatar,
		/datum/advclass/ogre/cook,
		/datum/advclass/ogre/dumdum,
		/datum/advclass/ogre/mercenary,
		/datum/advclass/ogre/warlord
	)
*/
