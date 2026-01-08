GLOBAL_LIST_INIT(species_pair_fertility, list(

    // GREEN – same species (best)
    "northern_human|northern_human" = 1.5,
    "lizardfolk|lizardfolk" = 1.2,
    "elf|elf" = 0.9,

    // YELLOW – acceptable crossbreeds
    "northern_human|lizardfolk" = 0.5,
    "lizardfolk|northern_human" = 0.5,

    "northern_human|drakian" = 0.6,
    "drakian|northern_human" = 0.6,

    "northern_human|kobold" = 0.4,
    "kobold|northern_human" = 0.4,

    // Half-breeds
    "northern_human|half_orc" = 0.8,
    "half_orc|northern_human" = 0.8
))
