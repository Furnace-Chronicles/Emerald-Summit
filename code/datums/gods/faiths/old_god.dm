/datum/faith/old_god // Astract

/datum/faith/old_god/standard
	name = "Old God"
	desc = "The Holy See has been taken over by misguided fools who defile Psydon and worship false gods, but we survive.\n\
		<b>PSYDON YET LIVES. PSYDON YET ENDURES.</b>\n\
		PSYDON sent the COMET SYON to destroy the rampaging Godhena and save all Mortals. Though he remains silent now, the fools believe him DEAD - but \
		PSYDON YET LIVES, AND PSYDON YET ENDURES. Unanswered prayers and impotent miracles - they are TESTS."
	worshippers = "People of Naledi, People of Giza, People of Hammerhold, People of Avar, Otavan Dark elves Orthodoxists, religious extremists."
	godhead = /datum/patron/old_god

/datum/faith/old_god/kazengun
	name = "Ancient God"
	desc = "The Holy See has been taken over by misguided fools who defile Saidon and worship false gods, but we survive.\n\
		<b>SAIDON YET LIVES. SAIDON YET ENDURES.</b>\n\
		SAIDON sent the COMET SYON to destroy the rampaging Godhena and save all Mortals. Though he remains silent now, the fools believe him DEAD - but \
		SAIDON YET LIVES, AND SAIDON YET ENDURES. Unanswered prayers and impotent miracles - they are TESTS."
	worshippers = "Religious extremists."
	godhead = /datum/patron/old_god/kazengun

/datum/faith/old_god/kazengun/New()
	uniquelist = GLOB.kazfaith

/datum/faith/old_god/kazengun/lingyue

/datum/faith/old_god/kazengun/lingyue/New()
	uniquelist = GLOB.linfaith

/datum/faith/old_god/standard/gronn

/datum/faith/old_god/standard/gronn/New()
	uniquelist = GLOB.gronnfaith

/datum/faith/old_god/standard/effluvia

/datum/faith/old_god/standard/effluvia/New()
	uniquelist = GLOB.fluvfaith
