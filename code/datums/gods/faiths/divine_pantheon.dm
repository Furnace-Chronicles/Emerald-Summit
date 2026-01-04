/datum/faith/divine/standard
	name = "Divine Pantheon"
	desc = "The TEN, children of PSYDON. The most accepted religion in Scarlet Reach. Born from Psydon will for companionship, and survivors of the war in heaven. The TEN freed mortals, gaving them shape and life. \n \n\
		The <b>Holy See</b>, recently rocked by a violent schism, controls diosces across the world.\
		The splinter church, the <b>Holy Ecclesial</b>, recognize the heretical 'Ascendants' - better known as INHUMEN GODS- as True Divinity. \
		But it is only through faith of the TRUE DIVINE that hope can be found in this world."
	worshippers = "Citizens of Scarlet Reach, conservative religious-folk, many commonfolk."
	godhead = /datum/patron/divine/astrata

/datum/faith/divine/kazengun
	name = "Heavenly Court"
	desc = "The TWELVE who hold rightful authority in Heaven. They are the reincarnations of SAIDON, bearers of His image who teach the mortal world how to emulate <b>True Divinity</b>. \
	It is our place to serve the Heavenly Court, so we may be shown mercy upon death and our next Lyfe. Virtuous souls shall reincarnate in greater bodies, yet those who defile \
	shall be reduced to the mindless bodies of animals."
	worshippers = "The people of Kazengun."
	godhead = /datum/patron/divine/noc/kazengun

/datum/faith/divine/kazengun/New()
	uniquelist = GLOB.kazfaith

/datum/faith/divine/lingyue
	name = "Transcendents"
	desc = "The FOURTEEN mighty spirits devoured SAIDON and gained <b>True Mastery</b> over our realm. We strive to emulate them. The mighty dominate the weak. <b>Ambition</b> \
	is our Divine imperative. We show devotion to the <b>Transcendents</b> so that their power may become our own."
	worshippers = "The people of Lingyue."
	godhead = /datum/patron/inhumen/graggar/kazengun/lingyue

/datum/faith/divine/lingyue/New()
	uniquelist = GLOB.linfaith

/datum/faith/divine/effluvia
	name = "Nascent Goddess"
	desc = "The nascent Goddess at the heart of <b>Mercuriam</b>, the ancient bronze city, will one day awaken and bring forth a new golden age of <b>wisdom</b>. Until then, \
	we shall listen closely to the whispers she provides us. Glimpses of a future: <b>green-glowing</b> technologies that boggle the mind.<br>Be steadfast in one's studies, \
	for only the intellectually worthy shall inherit the new world."
	worshippers = "The fluvians of Effluvia."
	godhead = /datum/patron/divine/pestra/effluvia

/datum/faith/divine/effluvia/New()
	uniquelist = GLOB.fluvfaith

/datum/faith/divine/standard/gronn

/datum/faith/divine/standard/gronn/New()
	uniquelist = GLOB.gronnfaith
