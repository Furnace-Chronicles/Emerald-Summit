/datum/virtue/origin
	var/origin_title
	var/region_title
	var/origin_language

/datum/virtue/origin/racial/reach
	name = "Aemerlond - Readtun"
	desc = "A once-bustling trade center and the capitol of Aemerlond, also colloquially known as the Scarlet Reach. It is now devastated in the wake of the Rosa Wars and the Mad Duke's reign. Considered the armpit of the world."
	custom_text = "Grants free language."
	region_title = "Readtun"
	extra_language = TRUE
	origin_title = "Aemerlond"
	races = list(/datum/species/human/northern,
				/datum/species/demihuman,
				/datum/species/elf/wood,
				/datum/species/human/halfelf,
				/datum/species/anthromorph,
				/datum/species/vulpkanin,
				/datum/species/anthromorphsmall,
				/datum/species/lizardfolk,
				/datum/species/dullahan,
)

/datum/virtue/origin/racial/reach/heartfelt
	name = "Aemerlond - Heartfelt"
	desc = "I originate from the sodden valleys of Heartfelt, a struggling kingdom beset by Ascendant forces. Its court is dominated by scheming, such that coups are an annual occurance in this chaotic land."
	region_title = "Heartfelt"
	origin_desc = "The Barony of Heartfelt is Readtun's closest geographical neighbour and frequent incidental companion in ill-stricken fortunes. Many words have \
	been used to describe the barony's vibrant political domain, with one foremost among them: failing. Crises born of scheming, circumstance and sometimes pure bad luck \
	make Heartfeltian visitors a somewhat common sight in the Reach, ever petitioning for aid or support in ventures spanning from securing noble lineages to reclaiming \
	fiefs overrun by followers of the Ascendant. For all the good and ill between the two states, they share an undeniable (if tenuous) bond, for only do the two together \
	understand just how precarious existence atop a divine graveyard can really be."

/datum/virtue/origin/racial/reach/trethewey
	name = "Aemerlond - Trethewey"
	desc = "A small county perpetually indebted to the rest of the duchy, once known as 'Rockhill.' It is nearly superstitious practice to blame Trethewey for literally anything bad that happens in the duchy."
	region_title = "Trethewey"

/datum/virtue/origin/grenzelhoft
	name = "Grenzelhoft"
	desc = "I originate from the dark boreal woods of Grenzelhoft, the birthplace of humanity. The Empire has a long history of conflict with Otava. Long live emperor Kovel II!"
	origin_title = "Grenzelhoft"
	origin_language = /datum/language/grenzelhoftian
	restricted = TRUE
	races = list(/datum/species/elf/dark,
				/datum/species/elf/sun,
				/datum/species/halforc,
				/datum/species/tabaxi,
				/datum/species/goblinp,
				/datum/species/akula,
				/datum/species/lamia
)
	origin_desc = "Believed to be the birthplace of humanity, the Grenzelhoft region is steeped in tradition and history.<br> Loosely organized under Emperor Kövel II, the \
	Grenzelhoft Empire once spanned all the way from the Hammerhold mountains to the Southern Sea. Its current state is far smaller, reduced to a decentralized body of \
	principalities which vie for control over the Imperial electorate.<br> Grenzelhoft is unique in that it maintains a professional army, funded by contracting its soldiers \
	out as imperial mercenaries during peacetime. The Empire has a long history of conflict with Otava, though recent decades have finally seen a tentative peace between \
	the two powers."

/datum/virtue/origin/etrusca
	name = "Etrusca"
	desc = "I originate from tropical Etrusca, an archipelago of maritime city-states located off the eastern coast of Otava. Skilled traders and sailors, Etruscans have probably rubbed shoulders (or other parts) with more races than most humens know exist."
	origin_title = "Etrusca"
	origin_language = /datum/language/etruscan
	restricted = TRUE
	races = list(/datum/species/elf/dark,
				/datum/species/elf/sun,
				/datum/species/moth,
				/datum/species/halforc,
				/datum/species/goblinp
)
	origin_desc = "An archipelago of maritime city-states located off the eastern coast of the Otavan countryside.<br> Etrusca is not one unified state, existing instead as \
	many different polities, each with their own regional traditions and dialects. Etruscans are known for their seafaring technology and typically make for strong \
	sailors, but many Etruscans are also unafraid to raise the black flag and turn to piracy, resulting in a reputation that is dubious at best."

/datum/virtue/origin/otava
	name = "Otava"
	desc = "I originate from the gently rolling hills of Otava, a religious union of duchies and counties who answer to the Patriarch of the Otavan Archdiocese."
	origin_title = "Otava"
	origin_language = /datum/language/otavan
	restricted = TRUE
	races = list(/datum/species/golem/metal,
				/datum/species/elf/sun,
				/datum/species/halforc,
				/datum/species/goblinp
)
	origin_desc = "A religious union of duchies and counties who answer to the Patriarch of the Otavan Archdiocese.<br> Otava is a deeply devout country and exists as a \
	Psydonian theocracy. It's most famous for its winemaking and textile industries, as well as its rich culture and cuisine. The Otavan countryside is well-known for \
	its idyllic landscape and warm climate. However, Otavan society is deeply feudalistic, with serfdom rigidly enforced among its people. Otava technically abolished \
	slavery centuries ago during the Psydonian Renewal, but lasting effects can still be seen in Otavan society.<br> While Otava is populated by all manner of races, the \
	blue-blooded dark elves enjoy a uniquely privileged position in Otavan society, and were among the first groups of people to adopt Psydonian worship during its \
	revival in the schism.<br> The unsanctioned use of magic is illegal in Otava, punishable by branding and the removal of one's tongue."

/datum/virtue/origin/racial/gronn
	name = "Gronn"
	desc = "I originate from the brisk grasslands of Gronn, a tribal confederation of northmen and half-orcs nestled in the Skol River Valley. Gronnic culture is fierce, martial and vengeful, and blood feuds still split the clans to this day."
	origin_title = "Gronn"
	origin_language = /datum/language/gronnic
	races = list(/datum/species/halforc,
				/datum/species/goblinp,
				/datum/species/human/northern,
				/datum/species/human/halfelf,
				/datum/species/demihuman,
				/datum/species/lupian,
				/datum/species/kobold,
				/datum/species/anthromorph,
				/datum/species/ogre
)
	origin_desc = "A tribal confederation of northmen and half-orcs nestled in the Skol River Valley.<br> Centuries of war between humen and orcs have stained these grassy \
	plains, but a shaky peace was eventually brought when the half-orc warlord Gronn used a clever mix of force and diplomacy to unite the people of the valley into one \
	loose confederation. Many years after the warlord's death, the League still remains, though it is still prone to constant small-scale internal conflict. At the same \
	time, the skirmishes between these loosely-aligned tribes has brought its own form of assimilation.<br> Full-blooded orcs are exceedingly rare in the modern day, and it \
	is not uncommon in Gronn to see half-orcs and humens living in coexistence. The region is a vital source of salt, iron, and timber, and is known for a love of \
	fermented foods and strong, bitter liquor."

/datum/virtue/origin/racial/gronn/New()
	. = ..()
	uniquefaith = GLOB.gronnfaith

/datum/virtue/origin/racial/gronn/wastes
	name = "Gronn - Stygian Wastes"
	region_title = "Stygian Wastes"
	desc = "I originate from the terrifying Stygian Wastes, a region of Gronn heavily scarred by Arcyne warfare. Infernals prowl the burning wasteland, clawing forth from cracks in the broken earth."
	origin_desc = null

/datum/virtue/origin/raneshen
	name = "Raneshi"
	desc = "I originate from the lush valleys and harsh badlands of Raneshen. Home to the zealous sun elves, the region sits at the gateway between the East and West. Recently engulfed in a violent holy war between the followers of the Old God and the divine Justiciars of Astrata."
	origin_title = "Raneshi"
	origin_language = /datum/language/celestial
	restricted = TRUE
	races = list(/datum/species/elf/dark,
				/datum/species/halforc,
				/datum/species/goblinp,
				/datum/species/lupian,
				/datum/species/moth,
				/datum/species/akula,
				/datum/species/kobold,
				/datum/species/vulpkanin,
				/datum/species/dracon,
				/datum/species/harpy
)
	origin_desc = "Home to the zealous Sun Elves, the region of Raneshen sits at the gateway between the East and West. Its lands were once ruled by Dominion of the Sun, \
	a religious Elven ethnostate who worshipped Astrata and Astrata only. Known for its brutal treatment of lesser races, the Dominion met its end at the hands of a \
	Psydonite slave rebellion half a century ago. It was fractured into several Elven successor states, each one claiming the legacy of the ancient Dominion, while human-led kingdoms \
	and rebel groups still vie for control over the region. Raneshen remains a hotbed of religious and ethnic conflict, and many refugees have fled to the West seeking sanctuary \
	— or hoping to bring their holy war along with them. The region itself is known for lush river-valleys, with lethally-hot deserts and harsh, rocky badlands forming natural borders. \
	Most trade from Kazengun and Naledi flows through Raneshen, and Ranesheni merchants are said to be just as vicious as the Solar Justiciars."

/datum/virtue/origin/naledi
	name = "Naledi"
	desc = "I originate from the sandy dunes of Naledi, known for its mages and scholars. Its people keep to the traditions of the Old God, even in the empire's dying age."
	origin_title = "Naledi"
	origin_language = /datum/language/celestial
	restricted = TRUE
	races = list(/datum/species/elf/dark,
				/datum/species/halforc,
				/datum/species/goblinp,
				/datum/species/lupian,
				/datum/species/moth,
				/datum/species/akula,
				/datum/species/lizardfolk,
				/datum/species/kobold,
				/datum/species/vulpkanin,
				/datum/species/dracon,
				/datum/species/harpy,
				/datum/species/tieberian
)
	origin_desc = "When the Tennite faith first swept through the world many centuries ago, the people of Naledi were left entirely untouched.<br> Though knowledge of PSYDON \
	had faded under Astrata's eye, for the Naledi people, the traditions of the Old God have remained alive and well since the dawn of time - a fact that their libraries \
	have carefully recorded. The Naledi are poorly known to the West, and most travelers from the region come as traders or scholars. What is known is that the region is \
	rich in gold, and that its people look to the stars for divine knowledge of our world.<br> It is rumored that the Naledi Emir is over five hundred years old, owing his \
	long lifespan to closely-guarded alchemical secrets."

/datum/virtue/origin/kazengun
	name = "Kazengun"
	desc = "I originate from the temperate forests of Kazengun, a region poorly known to the West. Its people worship a syncretic variation of the Divine Pantheon, often percieved as heretical."
	origin_title = "Kazengun"
	origin_language = /datum/language/kazengunese
	restricted = TRUE
	races = list(/datum/species/elf/dark,
				/datum/species/elf/sun,
				/datum/species/halforc,
				/datum/species/moth,
				/datum/species/dwarf/mountain
)

/datum/virtue/origin/kazengun/New()
	. = ..()
	uniquefaith = GLOB.kazfaith

/datum/virtue/origin/kazengun/lingyue
	name = "Kazengun - Lingyue"
	region_title = "Lingyue"
	desc = "I originate from the isolated isle of Lingyue, known primarily for worshipping Ascendants as part of the Divine Pantheon. It is a land of ruthless individualism where the mighty rule."

/datum/virtue/origin/kazengun/lingyue/New()
	. = ..()
	uniquefaith = GLOB.linfaith

/datum/virtue/origin/hammerhold
	name = "Hammerhold"
	desc = "I originate from mountainous Hammerhold, a frigid archipelago in the far north. It is sparsely populated: only the hardiest peoples can endure its arctic, barren lands."
	origin_title = "Hammerhold"
	origin_language = /datum/language/dwarvish
	restricted = TRUE
	races = list(/datum/species/elf/dark,
				/datum/species/elf/sun,
				/datum/species/tabaxi,
				/datum/species/moth,
				/datum/species/lizardfolk,
				/datum/species/tieberian
)

/datum/virtue/origin/avar
	name = "Avar"
	desc = "I originate from the open plains of Avar, a nomadic people residing the Aavnic steppes. The only settled land consists of small, independent city-states, often engulfed in war with eachother."
	origin_title = "Avar"
	origin_language = /datum/language/aavnic
	restricted = TRUE
	races = list(/datum/species/elf/dark,
				/datum/species/elf/sun,
				/datum/species/moth,
				/datum/species/akula,
				/datum/species/lizardfolk,
				/datum/species/lamia,
				/datum/species/dracon
)

/datum/virtue/origin/racial/underdark
	name = "Underdark"
	desc = "I originate from the treacherous Underdark, a cavernous region beneath Otava and Grenzelhoft. This unforgiving land is dominated by the prosperous and cruel dark elves and their pets. Most surfacedwellers only come here in chains."
	origin_title = "the Underdark"
	origin_language = /datum/language/otavan
	added_traits = list(TRAIT_UNDERDARK)
	races = list(/datum/species/elf/dark,
				/datum/species/moth,
				/datum/species/kobold,
				/datum/species/halforc,
				/datum/species/goblinp,
				/datum/species/anthromorph,
				/datum/species/anthromorphsmall
)

/datum/virtue/origin/racial/underdark/effluvia
	name = "Underdark - Effluvia"
	region_title = "Effluvia"
	desc = "I originate from the rotting caverns of Effluvia, a region of the Underdark teeming with poisonous waters. Infested with giant insects and spiders, this region is largely considered uninhabitable by all but the desperate."

/datum/virtue/origin/racial/underdark/effluvia/New()
	. = ..()
	uniquefaith = GLOB.fluvfaith

/datum/virtue/origin/unusual
	name = "Unusual"
	desc = "I originate from a foreign region in which my race is a minority. The customs of this land have become my own, at the cost of my heritage."
	triumph_cost = 2
	custom_text = "Allows selection of foreign origin upon spawn."

/datum/virtue/origin/apply_to_human(mob/living/carbon/human/recipient)
	recipient.dna.species.origin = origin_title
	recipient.dna.species.region = region_title
	if(!extra_language)
		recipient.grant_language(origin_language)

/datum/virtue/origin/unusual/apply_to_human(mob/living/carbon/human/recipient)
	addtimer(CALLBACK(src, .proc/unusual_apply, recipient), 50)

/datum/virtue/origin/unusual/proc/unusual_apply(mob/living/carbon/human/recipient)
	var/list/virtue_choices = list()
	for(var/path as anything in GLOB.virtues)
		var/datum/virtue/V = GLOB.virtues[path]
		if (!V.name)
			continue
		if (!istype(V, /datum/virtue/origin))
			continue
		if (V.restricted == TRUE)
			if(!(recipient.dna.species.type in V.races))
				continue
		if (istype(V, /datum/virtue/origin/racial))
			if((recipient.dna.species.type in V.races))
				continue
		if (istype(V, /datum/virtue/origin/unusual))
			continue
		virtue_choices[V.name] = V
	if(length(virtue_choices))
		var/result = tgui_input_list(recipient, "From where do you come?", "ORIGINS", virtue_choices)
		if(result)
			recipient.dna.species.skin_tone_wording = "Custom"
			var/datum/virtue/virtue_chosen = virtue_choices[result]
			apply_virtue(recipient, virtue_chosen)
			if(virtue_chosen.extra_language == TRUE)
				recipient.grant_language(recipient.client.prefs.extra_language)
		else
			var/chosen_virtue = new recipient.dna.species.origin_default
			apply_virtue(recipient, chosen_virtue)
			to_chat(recipient, "Denied foreign origin! Resetting to default. Triumph cost refunded!")
			recipient.adjust_triumphs(3)
	else
		var/chosen_virtue = new recipient.dna.species.origin_default
		apply_virtue(recipient, chosen_virtue)
		to_chat(recipient, "No foreign origins available! Resetting to default. Triumph cost refunded!")
		recipient.adjust_triumphs(3)
