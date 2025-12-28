/datum/virtue/size
	/// Amount to increase the valid range of sprite sizes 
	var/size_increment
/datum/virtue/size/giant
	name = "Giant"
	desc = "I've always been larger, stronger and hardier than the average person. I tend to lumber around a lot, and my immense size can break down frail, wooden doors."
	added_traits = list(TRAIT_BIGGUY, TRAIT_GIANT_WEAPON_WIELDER)
	custom_text = "<font color='red'>Increases your sprite size maximum and minimum, don't forget to adjust your scale.</font>\n+1 CON"
	restricted = TRUE
	races = list(/datum/species/ogre) //this controls whenever or not it's restricted to a race
	size_increment = BODY_SIZE_GIANT_INCREMENT

/datum/virtue/size/giant/apply_to_human(mob/living/carbon/human/recipient)
	recipient.change_stat("constitution", 1)

/datum/virtue/size/giant_two
	name = "Giant...er"
	desc = "Some say that I am a monstrosity... I revel in it."
	custom_text = "<font color='red'>Increases your sprite size maximum and minimum, don't forget to adjust your scale.</font>\n+1 CON, -2 SPD"
	restricted = TRUE
	races = list(/datum/species/ogre, /datum/species/kobold, /datum/species/dwarf)
	required_virtues = list(/datum/virtue/size/giant)
	size_increment = BODY_SIZE_GIANT_INCREMENT

/datum/virtue/size/giant_two/apply_to_human(mob/living/carbon/human/recipient)
	recipient.change_stat("constitution", 1)
	recipient.change_stat("speed", -2)
