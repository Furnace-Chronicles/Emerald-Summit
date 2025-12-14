#define STAT_STRENGTH "strength"
#define STAT_PERCEPTION "perception"
#define STAT_INTELLIGENCE "intelligence"
#define STAT_CONSTITUTION "constitution"
#define STAT_ENDURANCE "endurance"
#define STAT_SPEED "speed"
#define STAT_FORTUNE "fortune"

/mob/living
	var/STASTR = 10
	var/STAPER = 10
	var/STAINT = 10
	var/STACON = 10
	var/STAEND = 10
	var/STASPD = 10
	var/STALUC = 10
	//buffers, the 'true' amount of each stat
	var/BUFSTR = 0
	var/BUFPER = 0
	var/BUFINT = 0
	var/BUFCON = 0
	var/BUFEND = 0
	var/BUFSPE = 0
	var/BUFLUC = 0
	var/statbuf = FALSE
	var/list/statindex = list()
	var/datum/patron/patron = /datum/patron/godless

/mob/living/proc/init_faith()
	set_patron(/datum/patron/godless)

/mob/living/proc/set_patron(datum/patron/new_patron)
	if(!new_patron)
		return TRUE
	if(ispath(new_patron))
		new_patron = GLOB.patronlist[new_patron]
	if(!istype(new_patron))
		return TRUE
	if(istype(patron))
		patron.on_loss(src)
	patron = new_patron
	new_patron.on_gain(src)
	return TRUE

/datum/species
	// Associative list of stat (STAT_STRENGTH, etc) bonuses used to differentiate each race. They should ALWAYS be positive.
	var/list/race_bonus = list()
	var/construct = 0

/mob/living/proc/roll_stats()
	STASTR = 10
	STAPER = 10
	STAINT = 10
	STACON = 10
	STAEND = 10
	STASPD = 10
	STALUC = 10
	if(ishuman(src))
		var/mob/living/carbon/human/H = src

		if (H.statpack)
			H.statpack.apply_to_human(H)
		if (H.dna?.species) // LETHALSTONE EDIT: apply our race bonus, if we have one
			var/datum/species/species = H.dna.species
			if (species.race_bonus)
				for (var/stat in species.race_bonus)
					var/amt = species.race_bonus[stat]
					H.change_stat(stat, amt)
		switch(H.age)
			if(AGE_MIDDLEAGED)
				change_stat("speed", -1)
				change_stat("constitution", 1)
				change_stat("fortune", 1)
			if(AGE_OLD)
				change_stat("strength", -1)
				change_stat("speed", -2)
				change_stat("perception", -1)
				change_stat("constitution", -2)
				change_stat("intelligence", 2)
				change_stat("fortune", 1)
		if(key)
			if(check_blacklist(ckey(key)))
				change_stat("strength", -5)
				change_stat("speed", -20)
				change_stat("endurance", -2)
				change_stat("constitution", -2)
				change_stat("intelligence", -20)
				change_stat("fortune", -20)
			if(check_psychokiller(ckey(key)))
				testing("foundpsych")
				H.eye_color = "ff0000"
				H.voice_color = "ff0000"

/mob/living/proc/get_stat(stat)
	if(!stat)
		return
	switch(stat)
		if(STAT_STRENGTH)
			return STASTR
		if(STAT_PERCEPTION)
			return STAPER
		if(STAT_INTELLIGENCE)
			return STAINT
		if(STAT_CONSTITUTION)
			return STACON
		if(STAT_ENDURANCE)
			return STAEND
		if(STAT_SPEED)
			return STASPD
		if(STAT_FORTUNE)
			return STALUC
		else
			CRASH("get_stat called on [src] with an erroneous stat flag: [stat]")

/mob/living/proc/change_stat(stat, amt, index)
	if(!stat)
		return
	if(amt == 0 && index)
		if(statindex[index])
			change_stat(statindex[index]["stat"], -1*statindex[index]["amt"])
			statindex[index] = null
			return
	if(!amt)
		return
	if(index)
		if(statindex[index])
			return //we cannot make a new index
		else
			statindex[index] = list("stat" = stat, "amt" = amt)
//			statindex[index]["stat"] = stat
//			statindex[index]["amt"] = amt
	var/newamt = 0
	switch(stat)
		if("strength")
			newamt = STASTR + amt
			if(BUFSTR < 0)
				BUFSTR = BUFSTR + amt
				if(BUFSTR > 0)
					newamt = STASTR + BUFSTR
					BUFSTR = 0
			if(BUFSTR > 0)
				BUFSTR = BUFSTR + amt
				if(BUFSTR < 0)
					newamt = STASTR + BUFSTR
					BUFSTR = 0
			while(newamt < 1)
				newamt++
				BUFSTR--
			while(newamt > 20)
				newamt--
				BUFSTR++
			STASTR = newamt

		if("perception")
			newamt = STAPER + amt
			if(BUFPER < 0)
				BUFPER = BUFPER + amt
				if(BUFPER > 0)
					newamt = STAPER + BUFPER
					BUFPER = 0
			if(BUFPER > 0)
				BUFPER = BUFPER + amt
				if(BUFPER < 0)
					newamt = STAPER + BUFPER
					BUFPER = 0
			while(newamt < 1)
				newamt++
				BUFPER--
			while(newamt > 20)
				newamt--
				BUFPER++
			STAPER = newamt

			update_fov_angles()

		if("intelligence")
			newamt = STAINT + amt
			if(BUFINT < 0)
				BUFINT = BUFINT + amt
				if(BUFINT > 0)
					newamt = STAINT + BUFINT
					BUFINT = 0
			if(BUFINT > 0)
				BUFINT = BUFINT + amt
				if(BUFINT < 0)
					newamt = STAINT + BUFINT
					BUFINT = 0
			while(newamt < 1)
				newamt++
				BUFINT--
			while(newamt > 20)
				newamt--
				BUFINT++
			STAINT = newamt

		if("constitution")
			newamt = STACON + amt
			if(BUFCON < 0)
				BUFCON = BUFCON + amt
				if(BUFCON > 0)
					newamt = STACON + BUFCON
					BUFCON = 0
			if(BUFCON > 0)
				BUFCON = BUFCON + amt
				if(BUFCON < 0)
					newamt = STACON + BUFCON
					BUFCON = 0
			while(newamt < 1)
				newamt++
				BUFCON--
			while(newamt > 20)
				newamt--
				BUFCON++
			STACON = newamt

		if("endurance")
			newamt = STAEND + amt
			if(BUFEND < 0)
				BUFEND = BUFEND + amt
				if(BUFEND > 0)
					newamt = STAEND + BUFEND
					BUFEND = 0
			if(BUFEND > 0)
				BUFEND = BUFEND + amt
				if(BUFEND < 0)
					newamt = STAEND + BUFEND
					BUFEND = 0
			while(newamt < 1)
				newamt++
				BUFEND--
			while(newamt > 20)
				newamt--
				BUFEND++
			STAEND = newamt

		if("speed")
			newamt = STASPD + amt
			if(BUFSPE < 0)
				BUFSPE = BUFSPE + amt
				if(BUFSPE > 0)
					newamt = STASPD + BUFSPE
					BUFSPE = 0
			if(BUFSPE > 0)
				BUFSPE = BUFSPE + amt
				if(BUFSPE < 0)
					newamt = STASPD + BUFSPE
					BUFSPE = 0
			while(newamt < 1)
				newamt++
				BUFSPE--
			while(newamt > 20)
				newamt--
				BUFSPE++
			STASPD = newamt
			update_move_intent_slowdown()

		if("fortune")
			newamt = STALUC + amt
			if(BUFLUC < 0)
				BUFLUC = BUFLUC + amt
				if(BUFLUC > 0)
					newamt = STALUC + BUFLUC
					BUFLUC = 0
			if(BUFLUC > 0)
				BUFLUC = BUFLUC + amt
				if(BUFLUC < 0)
					newamt = STALUC + BUFLUC
					BUFLUC = 0
			while(newamt < 1)
				newamt++
				BUFLUC--
			while(newamt > 20)
				newamt--
				BUFLUC++
			STALUC = newamt

/proc/generic_stat_comparison(userstat as num, targetstat as num)
	var/difference = userstat - targetstat
	if(difference > 1 || difference < -1)
		return difference * 10
	else
		return 0

/mob/living/proc/badluck(multi = 3)
	if(STALUC < 10)
		return prob((10 - STALUC) * multi)

/mob/living/proc/goodluck(multi = 3)
	if(STALUC > 10)
		return prob((STALUC - 10) * multi)

/mob/living/proc/get_stat_level(stat_keys)
	switch(stat_keys)
		if(STATKEY_STR)
			return STASTR
		if(STATKEY_PER)
			return STAPER
		if(STATKEY_END)
			return STAEND
		if(STATKEY_CON)
			return STACON
		if(STATKEY_INT)
			return STAINT
		if(STATKEY_SPD)
			return STASPD
		if(STATKEY_LCK)
			return STALUC

///Effectively rolls a d20, with each point in the stat being a chance_per_point% chance to succeed per point in the stat. If no stat is provided, just returns 0.
///dee_cee is a difficulty mod, a positive value makes the check harder, a negative value makes it easier.
///invert_dc changes it from stat - dc to dc - stat, for inverted checks.
///EG: A person with 10 luck and a dc of -10 effectively has a 100% chance of success. Or an inverted DC with 10 means 0% chance of success.
/mob/living/proc/stat_roll(stat_key,chance_per_point = 5, dee_cee = null, invert_dc = FALSE)
	if(!stat_key)
		return FALSE
	var/tocheck
	switch(stat_key)
		if(STATKEY_STR)
			tocheck = STASTR
		if(STATKEY_PER)
			tocheck = STAPER
		if(STATKEY_END)
			tocheck = STAEND
		if(STATKEY_CON)
			tocheck = STACON
		if(STATKEY_INT)
			tocheck = STAINT
		if(STATKEY_SPD)
			tocheck = STASPD
		if(STATKEY_LCK)
			tocheck = STALUC
	if(invert_dc)
		return isnull(dee_cee) ? prob(tocheck * chance_per_point) : prob(clamp((dee_cee - tocheck) * chance_per_point,0,100))
	else
		return isnull(dee_cee) ? prob(tocheck * chance_per_point) : prob(clamp((tocheck - dee_cee) * chance_per_point,0,100))

/mob/living/proc/clamp_stat(stat, min_amt, max_amt) // i am such a genius
	var/new_amt
	var/result_amt
	switch(stat)
		if("strength")
			get_stat_level(STATKEY_STR)
			if(STASTR < min_amt)
				result_amt = min_amt - STASTR
				new_amt = STASTR + result_amt
				STASTR = new_amt
			if(STASTR > max_amt)
				result_amt = STASTR - max_amt
				new_amt = STASTR - result_amt
				STASTR = new_amt

		if("perception")
			get_stat_level(STATKEY_PER)
			if(STAPER < min_amt)
				result_amt = min_amt - STAPER
				new_amt = STAPER + result_amt
				STAPER = new_amt
			if(STAPER > max_amt)
				result_amt = STAPER - max_amt
				new_amt = STAPER - result_amt
				STAPER = new_amt
			update_fov_angles()

		if("intelligence")
			get_stat_level(STATKEY_INT)
			if(STAINT < min_amt)
				result_amt = min_amt - STAINT
				new_amt = STAINT + result_amt
			if(STAINT > max_amt)
				result_amt = STAINT - max_amt
				new_amt = STAINT - result_amt
			STAINT = new_amt

		if("constitution")
			get_stat_level(STATKEY_CON)
			if(STACON < min_amt)
				result_amt = min_amt - STACON
				new_amt = STACON + result_amt
			if(STACON > max_amt)
				result_amt = STACON - max_amt
				new_amt = STACON - result_amt
			STACON = new_amt

		if("endurance")
			get_stat_level(STATKEY_END)
			if(STAEND < min_amt)
				result_amt = min_amt - STAEND
				new_amt = STAEND + result_amt
			if(STAEND > max_amt)
				result_amt = STAEND - max_amt
				new_amt = STAEND - result_amt
			STAEND = new_amt

		if("speed")
			get_stat_level(STATKEY_SPD)
			if(STASPD < min_amt)
				result_amt = min_amt - STASPD
				new_amt = STASPD + result_amt
			if(STASPD > max_amt)
				result_amt = STASPD - max_amt
				new_amt = STASPD - result_amt
			STASPD = new_amt
			update_move_intent_slowdown()

		if("fortune")
			get_stat_level(STATKEY_LCK)
			if(STALUC < min_amt)
				result_amt = min_amt - STALUC
				new_amt = STALUC + result_amt
			if(STALUC > max_amt)
				result_amt = STALUC - max_amt
				new_amt = STALUC - result_amt
			STALUC = new_amt
