/datum/virtue/size/giant
	name = "Giant"
	desc = "I've always been larger, stronger and hardier than the average person. I tend to lumber around a lot, and my immense size can break down frail, wooden doors.\n+1 Constitution"
	added_traits = list(TRAIT_BIGGUY)
	custom_text = "<font color='red'>Increases your sprite size maximum and minimum, don't forget to adjust your scale.</font>"
	restricted = TRUE
	races = list(/datum/species/ogre) //this controls whenever or not it's restricted to a race

/datum/virtue/size/giant/apply_to_human(mob/living/carbon/human/recipient)
	recipient.change_stat("constitution", 1)
