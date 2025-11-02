/datum/job/roguetown/orthodoxist
	title = "Orthodoxist"
	flag = ORTHODOXIST
	department_flag = INQUISITION
	faction = "Station"
	total_positions = 3 // THREE GOONS!!
	spawn_positions = 3
	allowed_races = RACES_SECOND_CLASS_NO_GOLEM // As opposed to the Inquisitor or Absolver, Orthodoxists could be "redeemed" "lesser" races and heretics.
	disallowed_races = list(
		/datum/species/lamia,
		/datum/species/harpy,
	)
	allowed_patrons = list(/datum/patron/old_god) //You MUST have a Psydonite character to start. Just so people don't get japed into Oops Suddenly Psydon!
	tutorial = "Whether hand-picked by the Sovereignty of Otava or taken along through mere circumstance, you now serve as a loyal adherent to the Inquisitor's retinue. Descend into the darkness and - be it with a clenched fist or an opened palm - bring the inhumen towards the light: gift them salvation or damnation."
	selection_color = JCOLOR_INQUISITION
	outfit = null
	outfit_female = null
	display_order = JDO_ORTHODOXIST
	min_pq = 10 // We need you to be atleast kinda competent to do this. This is a soft antaggy sorta role. Also needs to know wtf a PSYDON is
	max_pq = null
	round_contrib_points = 2
	advclass_cat_rolls = list(CTAG_INQUISITION = 20)
	wanderer_examine = FALSE
	advjob_examine = TRUE
	give_bank_account = 15

	virtue_restrictions = list(
		/datum/virtue/combat/hollow_life,
	)

	job_subclasses = list(
		/datum/advclass/psydoniantemplar,
		/datum/advclass/disciple,
		/datum/advclass/confessor
	)
