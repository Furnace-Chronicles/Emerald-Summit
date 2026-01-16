/datum/faith/inhumen // Abstract...

/datum/faith/inhumen/standard
	name = "Ascendents"
	desc = "The Holy Ecclesial is a series of sects formed by a violent schism with the Holy See that split the church in twain. \n\
		The Holy Ecclesial accepts the Four Ascendents as True Divinity, proof that Mortals can ascend past their limits.  \
		So close to the seat of the Holy See, worship of the Four is considered heretical, and they are denounced as the INHUMEN. But we laugh, and spit in their face."
	worshippers = "Cultists, those spurned by the Ten."
	godhead = /datum/patron/inhumen/zizo

/datum/faith/inhumen/kazengun
	name = "Transcendents"
	desc = "The TWIN mighty spirits devoured SAIDON and gained <b>True Mastery</b> over our realm. We strive to emulate them. The mighty dominate the weak. <b>Ambition</b> \
	is our Divine imperative. We show devotion to the <b>Transcendents</b> so that their power may become our own."
	worshippers = "The ambitious."
	godhead = /datum/patron/inhumen/graggar/kazengun

/datum/faith/inhumen/kazengun/New()
	uniquelist = GLOB.kazfaith

/datum/faith/inhumen/gronn
	name = "Ecclesical Beasts"
	desc = "The shamans teach truth through the aspects of the FOUR great beasts, who herald destruction and change upon the world. Through violence does one gain <b>power</b>, \
	through devotion do we gain understanding. We are nothing more than animals, our world a hunting grounds where the divine aspects of <b>Hunter</b> and <b>Prey</b> \
	perform their endless ritual. There is no greater sin than to don the falsehoods of civilization."
	worshippers = "The people of Gronn."
	godhead = /datum/patron/inhumen/zizo/gronn

/datum/faith/inhumen/gronn/New()
	uniquelist = GLOB.gronnfaith

/datum/faith/inhumen/standard/effluvia

/datum/faith/inhumen/standard/effluvia/New()
	uniquelist = GLOB.fluvfaith
