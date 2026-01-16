// Martial/warrior archetypes

/datum/statpack/physical/trained
	name = "Trained"
	desc = "Years honing your physique has left you with a physical edge, but your faculties have been neglected somewhat."
	stat_array = list(STATKEY_STR = 1, STATKEY_CON = 1, STATKEY_END = 1, STATKEY_PER = -1, STATKEY_INT = -1)

/datum/statpack/physical/muscular
	name = "Muscular"
	desc = "Hard labor has honed you into a mass of sinew - a valuable trait in a world where might makes right."
	stat_array = list(STATKEY_STR = 2, STATKEY_CON = 1, STATKEY_INT = 1, STATKEY_SPD = -2)

/datum/statpack/physical/tactician
	name = "Alert"
	desc = "You sharpened both your body and your mind as best you were able, and vigilance has been your reward."
	stat_array = list(STATKEY_STR = 1, STATKEY_PER = 1, STATKEY_INT = 1, STATKEY_CON = -1, STATKEY_END = -1)

/datum/statpack/physical/taut
	name = "Taut"
	desc = "Wound tight like the limbs of a time-teller, your physicality is poised to strike - or flee - at a moment's notice."
	stat_array = list(STATKEY_STR = 1, STATKEY_END = 1, STATKEY_SPD = 1, STATKEY_PER = -2, STATKEY_CON = -1)

/datum/statpack/physical/toil
	name = "Toil-hardened"
	desc = "Your life, hard-lived, has imparted one solitary adage: carry on above all else. And so you endure."
	stat_array = list(STATKEY_END = 2, STATKEY_CON = 1, STATKEY_PER = -1, STATKEY_INT = -1)

/datum/statpack/physical/struggler
	name = "Struggler"
	desc = "Lyfe's dealt you a poor hand, so you've opted to simply flip the table instead."
	stat_array = list(STATKEY_STR = 2, STATKEY_CON = 2, STATKEY_END = 2, STATKEY_INT = -3, STATKEY_PER = -3, STATKEY_LCK = -2)
