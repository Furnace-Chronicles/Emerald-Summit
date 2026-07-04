/datum/flesh_concept
	var/name = "base concept"
	var/list/tier_questions = list() // Questions for each tier (1-4)
	var/list/answer_keywords = list() // Keywords accepted in answers across all tiers

/datum/flesh_concept/pain
	name = "pain"
	tier_questions = list(
		list("Hurt? Oww?", "Bad feel?", "Ouch?"),
		list("What is pain?", "Why we hurt?", "Pain good?"),
		list("Does suffering have purpose?", "Is pain a teacher?", "How does pain change us?"),
		list("What truths does agony reveal?", "Is suffering necessary for growth?", "How does pain shape consciousness?")
	)
	answer_keywords = list("hurt", "pain", "suffering", "agony", "ache", "torment", "anguish")

/datum/flesh_concept/blood
	name = "blood"
	tier_questions = list(
		list("Red wet?", "Life juice?", "Bleed?"),
		list("What is blood?", "Why blood red?", "Blood life?"),
		list("Does blood carry memory?", "Is blood sacred?", "What flows in veins?"),
		list("What ancestral knowledge flows in blood?", "Is blood the river of lineage?", "Does blood remember what the mind forgets?")
	)
	answer_keywords = list("blood", "bleed", "veins", "life", "red", "flow", "sacrifice")

/datum/flesh_concept/fear
	name = "fear"
	tier_questions = list(
		list("Scary?", "Run hide?", "Bad thing?"),
		list("What is fear?", "Fear good?", "Why afraid?"),
		list("Does fear protect or imprison?", "What lies beneath terror?", "Is fear a warning?"),
		list("What truths does dread unveil?", "Is fear the shadow of survival?", "Does terror reveal hidden realities?")
	)
	answer_keywords = list("fear", "scared", "afraid", "terror", "dread", "panic", "anxiety")

/datum/flesh_concept/hunger
	name = "hunger"
	tier_questions = list(
		list("Want food?", "Empty tummy?", "Eat now?"),
		list("What is hunger?", "Why we need food?", "Hunger pain?"),
		list("Is hunger more than physical?", "What do we truly crave?", "Does hunger drive creation?"),
		list("What existential void does hunger represent?", "Is craving flesh the engine of being?", "What hungers drive us?")
	)
	answer_keywords = list("hunger", "food", "eat", "crave", "starve", "appetite", "desire")

/datum/flesh_concept/love
	name = "love"
	tier_questions = list(
		list("Good feel?", "Warm inside?", "Like person?"),
		list("What is love?", "Why love hurt?", "Love good?"),
		list("Is love a binding force?", "Does love transform?", "What sacrifices does love demand?"),
		list("Do we truly require love, or is it inner deceit?", "Is love the fabric binding souls?", "What divine madness is love?")
	)
	answer_keywords = list("love", "care", "affection", "devotion", "passion", "connection", "bond")

/datum/flesh_concept/death
	name = "death"
	tier_questions = list(
		list("No more?", "Gone away?", "Sleep forever?"),
		list("What is death?", "After death?", "Why die?"),
		list("Is death an ending or transformation?", "What awaits beyond the veil?", "Does death give life meaning?"),
		list("What mysteries lie in the great silence?", "Is death the final teacher?", "What rebirth follows dissolution?")
	)
	answer_keywords = list("death", "die", "dead", "end", "afterlife", "mortality", "rebirth")

/datum/flesh_concept/time
	name = "time"
	tier_questions = list(
		list("Now when?", "Before after?", "Day night?"),
		list("What is time?", "Time flow?", "Can stop time?"),
		list("Does time heal or erode?", "Is the past alive in us?", "What is the weight of moments?"),
		list("What eternal now contains all of time?", "Is memory time's anchor?", "What dances in the spaces between moments?")
	)
	answer_keywords = list("time", "past", "future", "now", "moment", "memory", "eternity")

/datum/flesh_concept/dreams
	name = "dreams"
	tier_questions = list(
		list("Sleep pictures?", "Night stories?", "Not real?"),
		list("What are dreams?", "Dreams real?", "Why dream?"),
		list("Do dreams show hidden truths?", "What world exists behind closed eyes?", "Are we different in dreams?"),
		list("What realms do sleeping minds wander?", "Do dreams connect collective unconscious?", "What prophecies sleep in dreamscapes?")
	)
	answer_keywords = list("dream", "sleep", "vision", "nightmare", "unconscious", "fantasy", "prophecy")

/datum/flesh_concept/memory
	name = "memory"
	tier_questions = list(
		list("Remember thing?", "Before now?", "Old picture?"),
		list("What is memory?", "Why forget?", "Memory true?"),
		list("Do memories shape reality?", "What is forgotten but still felt?", "Are we our memories?"),
		list("What echoes linger in ancestral memory?", "Do memories exist outside time?", "What truths do forgotten things hold?")
	)
	answer_keywords = list("memory", "remember", "forget", "past", "recall", "nostalgia", "echo")

/datum/flesh_concept/truth
	name = "truth"
	tier_questions = list(
		list("Real thing?", "Not lie?", "True true?"),
		list("What is truth?", "Truth hurt?", "Always truth?"),
		list("Are there multiple truths?", "What lies hide behind facts?", "Does truth change?"),
		list("What absolute reality underlies apparent truth?", "Is truth subjective experience?", "What remains when all lies are stripped away?")
	)
	answer_keywords = list("truth", "real", "true", "fact", "honest", "reality", "authentic")

/datum/flesh_concept/lies
	name = "lies"
	tier_questions = list(
		list("Not true?", "Make believe?", "False story?"),
		list("What are lies?", "Why lie?", "Lies bad?"),
		list("Do lies protect or harm?", "What truth hides in deception?", "Are some lies necessary?"),
		list("What fundamental deceptions shape reality?", "Do lies create new truths?", "What hides behind the veil of falsehood?")
	)
	answer_keywords = list("lie", "false", "deceive", "illusion", "trick", "untrue", "fiction")

/datum/flesh_concept/power
	name = "power"
	tier_questions = list(
		list("Strong?", "Make do?", "Boss?"),
		list("What is power?", "Get power how?", "Power good?"),
		list("Does power corrupt or reveal?", "What is true strength?", "Can power be shared?"),
		list("What cosmic forces manifest as power?", "Is power responsibility or freedom?", "What ultimate authority governs existence?")
	)
	answer_keywords = list("power", "strong", "control", "authority", "dominance", "influence", "might")

/datum/flesh_concept/weakness
	name = "weakness"
	tier_questions = list(
		list("Not strong?", "Can't do?", "Small?"),
		list("What is weakness?", "Weakness bad?", "Help weak?"),
		list("Is vulnerability strength?", "What grows from limitation?", "Does weakness teach compassion?"),
		list("What profound truths emerge from fragility?", "Is surrender sometimes victory?", "What power resides in acceptance?")
	)
	answer_keywords = list("weak", "vulnerable", "fragile", "helpless", "limited", "frail", "dependent")

/datum/flesh_concept/creation
	name = "creation"
	tier_questions = list(
		list("Make new?", "Build thing?", "From nothing?"),
		list("What is creation?", "Why create?", "Create how?"),
		list("Does creation require destruction?", "What spark begins making?", "Is all art born of pain?"),
		list("What divine impulse drives creation?", "Does the universe dream through makers?", "What emerges from the void of potential?")
	)
	answer_keywords = list("create", "make", "build", "form", "art", "invent", "generate")

/datum/flesh_concept/destruction
	name = "destruction"
	tier_questions = list(
		list("Break thing?", "No more?", "Smash?"),
		list("What is destruction?", "Why destroy?", "Destroy good?"),
		list("Does destruction make space for creation?", "What beauty exists in ruin?", "Is ending necessary?"),
		list("What cosmic cycle requires dissolution?", "Does destruction reveal essential forms?", "Must all be ended for us to begin anew?")
	)
	answer_keywords = list("destroy", "break", "ruin", "end", "demolish", "shatter", "obliterate")

/datum/flesh_concept/order
	name = "order"
	tier_questions = list(
		list("Things neat?", "Place for thing?", "Not messy?"),
		list("What is order?", "Why order good?", "Make order?"),
		list("Does order limit or protect?", "What patterns govern reality?", "Is chaos the enemy of order?"),
		list("What cosmic structures maintain existence?", "Does order emerge from chaos?", "What divine mathematics govern all thing?")
	)
	answer_keywords = list("order", "pattern", "system", "structure", "arrange", "organize", "method")

/datum/flesh_concept/chaos
	name = "chaos"
	tier_questions = list(
		list("All messy?", "No pattern?", "Things random?"),
		list("What is chaos?", "Chaos bad?", "Why chaos?"),
		list("Does chaos create freedom?", "What order emerges from randomness?", "Is chaos the source of novelty?"),
		list("What infinite possibilities dwell in disorder?", "Does chaos birth new realities?", "What dances in the space between laws?")
	)
	answer_keywords = list("chaos", "random", "disorder", "confusion", "unpredictable", "entropy", "anarchy")

/datum/flesh_concept/beauty
	name = "beauty"
	tier_questions = list(
		list("Pretty thing?", "Nice see?", "Good look?"),
		list("What is beauty?", "Why beautiful?", "Beauty where?"),
		list("Is beauty subjective or universal?", "What makes something beautiful?", "Does beauty require imperfection?"),
		list("What divine harmony manifests as beauty?", "Does beauty reveal truths?", "What eternal forms underlie apparent beauty?")
	)
	answer_keywords = list("beauty", "beautiful", "pretty", "lovely", "aesthetic", "harmony", "grace")

/datum/flesh_concept/ugliness
	name = "ugliness"
	tier_questions = list(
		list("Not pretty?", "Bad look?", "Wrong shape?"),
		list("What is ugly?", "Why ugly?", "Ugly bad?"),
		list("Does ugliness have its own beauty?", "What truths hide in unpleasant forms?", "Is ugliness necessary?"),
		list("What profound realities manifest as ugliness?", "Does horror contain its own awe?", "What sacred truths wear masks of disgust?")
	)
	answer_keywords = list("ugly", "unpleasant", "grotesque", "hideous", "repulsive", "disfigured", "monstrous")

/datum/flesh_concept/sacrifice
	name = "sacrifice"
	tier_questions = list(
		list("Give up?", "Lose for other?", "Hurt for good?"),
		list("What is sacrifice?", "Why sacrifice?", "Sacrifice worth?"),
		list("Does sacrifice create meaning?", "What transformations require offering?", "Is loss necessary for gain?"),
		list("What exchanges demand sacrifice?", "Does giving away create abundance?", "What divine economy governs offering?")
	)
	answer_keywords = list("sacrifice", "offer", "give", "lose", "surrender", "offerings", "devotion")

/datum/flesh_concept/greed
	name = "greed"
	tier_questions = list(
		list("Want more?", "Not share?", "All mine?"),
		list("What is greed?", "Why greedy?", "Greed good?"),
		list("Does greed drive progress?", "What emptiness creates wanting?", "Is accumulation a form of poverty?"),
		list("What existential lack manifests as greed?", "Does infinite desire create finite beings?", "What void do possessions attempt to fill?")
	)
	answer_keywords = list("greed", "want", "desire", "possess", "accumulate", "hoard", "covet")

/datum/flesh_concept/justice
	name = "justice"
	tier_questions = list(
		list("Fair thing?", "Good get good?", "Bad get bad?"),
		list("What is justice?", "Justice fair?", "Make justice?"),
		list("Is justice absolute or relative?", "Does vengeance serve justice?", "Can mercy be just?"),
		list("What balance manifests as justice?", "Does universal law require equilibrium?", "What scales measure deeds?")
	)
	answer_keywords = list("justice", "fair", "right", "law", "balance", "equity", "retribution")

/datum/flesh_concept/mercy
	name = "mercy"
	tier_questions = list(
		list("Not punish?", "Forgive?", "Be kind?"),
		list("What is mercy?", "Why mercy?", "Mercy weak?"),
		list("Is mercy strength or weakness?", "What healing comes from forgiveness?", "Does mercy transform both given and receiver?"),
		list("What grace manifests as mercy?", "Does compassion transcend justice?", "What kindness flows through existence?")
	)
	answer_keywords = list("mercy", "forgive", "compassion", "kindness", "pity", "clemency", "grace")

/datum/flesh_concept/loneliness
	name = "loneliness"
	tier_questions = list(
		list("All alone?", "No friend?", "Empty inside?"),
		list("What is loneliness?", "Why lonely?", "Loneliness hurt?"),
		list("Is solitude different from loneliness?", "What connections alleviate isolation?", "Does loneliness reveal our need for others?"),
		list("What existential separation creates loneliness?", "Does the soul yearn for connection?", "What divine unity do we remember in isolation?")
	)
	answer_keywords = list("lonely", "alone", "isolated", "solitude", "abandoned", "empty", "separation")

/datum/flesh_concept/companionship
	name = "companionship"
	tier_questions = list(
		list("With other?", "Not alone?", "Friend?"),
		list("What is companionship?", "Why together?", "Alone bad?"),
		list("Does connection define identity?", "What bonds transform individuals?", "Is companionship necessary for growth?"),
		list("If nothing is alive, can one still achieve companionship?", "Do souls recognize each other?", "What communion exists between beings?")
	)
	answer_keywords = list("companion", "friend", "together", "bond", "connection", "relationship", "unity")

/datum/flesh_concept/hope
	name = "hope"
	tier_questions = list(
		list("Maybe good?", "Think better?", "Not give up?"),
		list("What is hope?", "Why hope?", "Hope help?"),
		list("Does hope create reality?", "What sustains hope in darkness?", "Is hope a choice or feeling?"),
		list("What potential manifests as hope?", "Does hope glimpse future possibilities?", "What promise fuels expectation?")
	)
	answer_keywords = list("hope", "optimism", "expect", "faith", "belief", "anticipation", "possibility")

/datum/flesh_concept/despair
	name = "despair"
	tier_questions = list(
		list("No hope?", "All bad?", "Give up?"),
		list("What is despair?", "Why despair?", "Despair end?"),
		list("Does despair reveal truth?", "What growth comes from hopelessness?", "Is despair a necessary depth?"),
		list("What existential truths manifest as despair?", "Does the abyss gaze back?", "What revelations come from absolute surrender?")
	)
	answer_keywords = list("despair", "hopeless", "desperate", "defeat", "sorrow", "anguish", "misery")

/datum/flesh_concept/courage
	name = "courage"
	tier_questions = list(
		list("Not scared?", "Do anyway?", "Be brave?"),
		list("What is courage?", "Why brave?", "Courage good?"),
		list("Does courage require fear?", "What actions define bravery?", "Is courage a choice or quality?"),
		list("What strength manifests as courage?", "Does valor transcend self-preservation?", "What overcomes terror?")
	)
	answer_keywords = list("courage", "brave", "fearless", "bold", "valor", "heroism", "fortitude")

/datum/flesh_concept/cowardice
	name = "cowardice"
	tier_questions = list(
		list("Too scared?", "Run away?", "Not do?"),
		list("What is cowardice?", "Why coward?", "Coward bad?"),
		list("Does cowardice preserve life?", "What wisdom hides in caution?", "Is fear sometimes wise?"),
		list("What survival instinct manifests as cowardice?", "Does prudence disguise as fear?", "What feeling guides retreat?")
	)
	answer_keywords = list("coward", "fearful", "timid", "afraid", "hesitant", "retreat", "caution")

/datum/flesh_concept/wisdom
	name = "wisdom"
	tier_questions = list(
		list("Know things?", "Smart?", "Understand?"),
		list("What is wisdom?", "Get wisdom?", "Wise good?"),
		list("Does wisdom come from experience?", "Can wisdom be taught?", "Is wisdom different from knowledge?"),
		list("What understanding manifests as wisdom?", "Does truth resonate through ages?", "What eternal patterns do sages perceive?")
	)
	answer_keywords = list("wisdom", "wise", "knowledge", "understanding", "insight", "enlightenment", "sagacity")

/datum/flesh_concept/ignorance
	name = "ignorance"
	tier_questions = list(
		list("Not know?", "Dumb?", "No understand?"),
		list("What is ignorance?", "Why ignorant?", "Ignorance bad?"),
		list("Does ignorance protect or limit?", "What freedoms come from not knowing?", "Is some ignorance bliss?"),
		list("What necessary veils manifest as ignorance?", "Does unknowing create space for wonder?", "What mysteries require not knowing?")
	)
	answer_keywords = list("ignorance", "ignore", "unknowing", "unaware", "naive", "innocent", "uninformed")

/datum/flesh_concept/freedom
	name = "freedom"
	tier_questions = list(
		list("Do anything?", "No rules?", "Free?"),
		list("What is freedom?", "Why free?", "Freedom good?"),
		list("Does freedom require responsibility?", "Can one be free alone?", "Is absolute freedom possible?"),
		list("What liberation manifests as freedom?", "Does the soul yearn for unbounded existence?", "What divine autonomy underlies being?")
	)
	answer_keywords = list("freedom", "free", "liberty", "autonomy", "independence", "unbound", "release")

/datum/flesh_concept/bondage
	name = "bondage"
	tier_questions = list(
		list("Not free?", "Trapped?", "Can't move?"),
		list("What is bondage?", "Why trapped?", "Bondage bad?"),
		list("Do limitations create meaning?", "What freedoms exist within constraints?", "Are all beings bound in some way?"),
		list("What necessary structures manifest as bondage?", "Does form require limitation?", "What divine laws bind existence?")
	)
	answer_keywords = list("bondage", "bound", "trapped", "restricted", "prison", "captive", "constrained")

/datum/flesh_concept/growth
	name = "growth"
	tier_questions = list(
		list("Get bigger?", "Change good?", "Learn more?"),
		list("What is growth?", "Why grow?", "Grow how?"),
		list("Does growth require discomfort?", "What transformations are necessary?", "Can growth be forced?"),
		list("What evolution manifests as growth?", "Does being unfold through becoming?", "What divine potential seeks expression?")
	)
	answer_keywords = list("growth", "grow", "develop", "evolve", "mature", "progress", "transform")

/datum/flesh_concept/decay
	name = "decay"
	tier_questions = list(
		list("Get old?", "Break down?", "Not work?"),
		list("What is Pestra?", "Why Pestra?", "Pestra bad?"),
		list("Does Pestra's decay make space for new life?", "What beauty exists in deterioration?", "Is ending part of cycles?"),
		list("What is Pestra's greatest gift?", "Does Pestra's dissolution serve renewal?", "What ancient patterns does Pestra require return to source?")
	)
	answer_keywords = list("decay", "rot", "decompose", "deteriorate", "wither", "fade", "corrupt", "pestra")

/datum/flesh_concept/transformation
	name = "transformation"
	tier_questions = list(
		list("Change thing?", "Become different?", "Not same?"),
		list("What is transformation?", "Why change?", "Transform how?"),
		list("Does transformation require destruction?", "What remains constant through change?", "Are we the same after transformation?"),
		list("What metamorphosis manifests as change?", "Does being dance between forms?", "What eternal essence wears temporary shapes?")
	)
	answer_keywords = list("transform", "change", "become", "metamorphosis", "evolve", "shift", "alter")

/datum/flesh_concept/identity
	name = "identity"
	tier_questions = list(
		list("Who me?", "I am?", "Self?"),
		list("What is identity?", "Why self?", "Identity change?"),
		list("Are we our memories or actions?", "What defines personhood?", "Does identity exist independently?"),
		list("What eternal self manifests as identity?", "Does consciousness wear temporary masks?", "What divine spark animates being?")
	)
	answer_keywords = list("identity", "self", "who", "person", "individual", "essence", "soul")

/datum/flesh_concept/unity
	name = "unity"
	tier_questions = list(
		list("All one?", "Together same?", "Not separate?"),
		list("What is unity?", "Why together?", "Unity good?"),
		list("Does unity require diversity?", "What connects all things?", "Can individuality exist in unity?"),
		list("What oneness manifests as unity?", "Can seperation be kept from bringing destruction?", "What divine whole contains all parts?")
	)
	answer_keywords = list("unity", "one", "together", "whole", "united", "connected", "harmony")
