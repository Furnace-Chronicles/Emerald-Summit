/datum/wound/bite
	name = "bite"
	bleed_rate = 0.5
	sewn_bleed_rate = 0
	clotting_threshold = null
	sewn_clotting_threshold = null
	whp = 30
	woundpain = 10
	sew_threshold = 50
	mob_overlay = "cut"
	can_sew = TRUE
	can_cauterize = TRUE
	passive_healing = 0.5

/datum/wound/bite/small
	name = "nip"
	whp = 15

/datum/wound/bite/large
	name = "gnarly bite"
	whp = 40
	sewn_whp = 15
	bleed_rate = 1
	sewn_bleed_rate = 0.2
	clotting_rate = 0.01
	sewn_clotting_rate = 0.01
	clotting_threshold = 0.5
	sewn_clotting_threshold = 0.25
	woundpain = 15
	sewn_woundpain = 5
	can_sew = TRUE
	can_cauterize = TRUE
	passive_healing = 0

/datum/wound/dynamic/bite
	name = "bite"
	bleed_rate = 0.5
	sewn_bleed_rate = 0
	clotting_rate = 0.12
	whp = 30
	woundpain = 10
	sew_threshold = 50
	mob_overlay = "cut"
	can_sew = TRUE
	can_cauterize = TRUE
	passive_healing = 0.5
	severity_names = list(
		"shallow" = 3,
		"deep" = 8,
		"gnarly" = 12,
		"lethal" = 15,
		"impossible" = 20,
	)

//Bite Omniwounds
//Vaguely: Hella painful. Hella bleedy. Armor is very effective. Similar to lashing in this way.

#define BITE_UPG_BLEEDRATE 0.2
#define BITE_UPG_WHPRATE 0.2
#define BITE_UPG_SEWRATE 1
#define BITE_UPG_PAINRATE 1
#define BITE_UPG_CLAMP 1.3

/datum/wound/dynamic/bite/upgrade(dam, armor)
	whp += (dam * BITE_UPG_WHPRATE)
	set_bleed_rate(bleed_rate + clamp((dam * BITE_UPG_BLEEDRATE), 0.1, BITE_UPG_CLAMP))
	sew_threshold += (dam * BITE_UPG_SEWRATE)
	woundpain += (dam * BITE_UPG_PAINRATE)
	update_name()
	..()

#undef BITE_UPG_BLEEDRATE
#undef BITE_UPG_WHPRATE
#undef BITE_UPG_SEWRATE
#undef BITE_UPG_PAINRATE
#undef BITE_UPG_CLAMP
