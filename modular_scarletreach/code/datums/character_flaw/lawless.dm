/datum/charflaw/lawless
	name = "Lawless"
	desc = "I've always felt the rules were a bit more like guidelines than actual rules, and have accrued enough notoriety to have a bounty out on my head. (Taking this vice when on a class that already has a roundstart bounty will randomize your flaw instead.)"

/datum/charflaw/lawless/on_mob_creation(mob/user)
	addtimer(CALLBACK(src, PROC_REF(set_up), user), 30 SECONDS)

/datum/charflaw/lawless/proc/set_up(mob/living/carbon/human/user)
	var/my_crime
	var/bounty_amount
	var/bounty_total
	var/face_known
	var/bounty_poster

	if (has_bounty(user) || (user.job && user.job == "Wretch") || (user.advjob && user.advjob == "Wanted") || (user.job && user.job == "Bandit"))
		// no doubling up on this stuff, you just get a random flaw instead.
		var/list/flaws_without_random = GLOB.character_flaws.Copy()
		flaws_without_random -= "Random or No Flaw"
		var/datum/charflaw/our_new_flaw = GLOB.character_flaws[pick(flaws_without_random)]
		user.charflaw = new our_new_flaw()
		user.charflaw.on_mob_creation(user)
		to_chat(user, span_warning("The thrill of lawlessness is not enough anymore... fate renders my flaw to be: <b>[user.charflaw.name]</b>."))
		return

	if (user && user.mind)
		face_known = alert(user, "Is your face known to the authorities?", "", "Yes", "No")
		if (!face_known)
			face_known = "Yes"
		bounty_poster = input(user, "Who placed a bounty on you?", "Bounty Poster") as anything in list("The Justiciary of Scarlet Reach", "The Grenzelhoftian Holy See", "The Otavan Holy See")
		if (!bounty_poster)
			bounty_poster = "The Justiciary of Scarlet Reach"
		my_crime = input(user, "What is your crime?", "Crime") as text|null
		if (!my_crime)
			my_crime = "crimes against the Crown"
		var/list/bounty_cats = list("Misdeed", "Worrisome", "Atrocious")
		bounty_amount = input(user, "How grave are your crimes?", "Blooded Gold") as anything in bounty_cats
		switch (bounty_amount)
			if ("Misdeed")
				bounty_total = rand(51, 100)
			if ("Worrisome")
				bounty_total = rand(101, 150)
			if ("Atrocious")
				bounty_total = rand(150, 200)

		if (!bounty_amount)
			bounty_total = rand(51, 200)

		if (face_known == "Yes")
			add_bounty(user.real_name, bounty_total, FALSE, my_crime, bounty_poster)
			if (bounty_poster == "The Justiciary of Scarlet Reach")
				GLOB.outlawed_players += user.real_name
			else
				GLOB.excommunicated_players += user.real_name
		else
			var/race = user.dna.species
			var/gender = user.gender
			var/list/d_list = user.get_mob_descriptors()
			var/descriptor_height = build_coalesce_description_nofluff(d_list, user, list(MOB_DESCRIPTOR_SLOT_HEIGHT), "%DESC1%")
			var/descriptor_body = build_coalesce_description_nofluff(d_list, user, list(MOB_DESCRIPTOR_SLOT_BODY), "%DESC1%")
			var/descriptor_voice = build_coalesce_description_nofluff(d_list, user, list(MOB_DESCRIPTOR_SLOT_VOICE), "%DESC1%")
			add_bounty_noface(user.real_name, race, gender, descriptor_height, descriptor_body, descriptor_voice, bounty_total, FALSE, my_crime, bounty_poster)

		to_chat(user, span_notice("I'm on the run from the law, and there's a sum of mammons out on my head... better lay low."))
	else
		addtimer(CALLBACK(src, PROC_REF(set_up), user), 10 SECONDS)
