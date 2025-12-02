/datum/job/roguetown/ogre
	title = "Ogre"
	flag = OGRE
	department_flag = PEASANTS
	faction = "Station"
	total_positions = 5
	spawn_positions = 5
	allowed_races = OGRE_RACE_TYPES
	allowed_sexes = list(MALE, FEMALE)
	tutorial = "You are a travelling Ogre, who once originated from Gronn. You're so, so very hungry."
	outfit = null
	outfit_female = null
	display_order = JDO_OGRE
	show_in_credits = TRUE
	min_pq = 10
	max_pq = null
	round_contrib_points = 2
	advclass_cat_rolls = list(CTAG_OGRE = 20)
	PQ_boost_divider = 10
	advjob_examine = TRUE
	always_show_on_latechoices = TRUE
	cmode_music = 'sound/music/combat.ogg'

	job_traits = list(TRAIT_OUTLANDER, TRAIT_STEELHEARTED)
