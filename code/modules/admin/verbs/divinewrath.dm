/client/proc/divine_wrath(mob/M in GLOB.mob_list)
	if(!holder || !check_rights(R_FUN))
		return

	var/mob/living/carbon/human/target = M

	var/list/curse_choices = list(
		"Curse of Astrata" = /datum/curse/astrata,
		"Curse of Noc" = /datum/curse/noc,
		"Curse of Dendor" = /datum/curse/dendor,
		"Curse of Abyssor" = /datum/curse/abyssor,
		"Curse of Ravox" = /datum/curse/ravox,
		"Curse of Necra" = /datum/curse/necra,
		"Curse of Xylix" = /datum/curse/xylix,
		"Curse of Pestra" = /datum/curse/pestra,
		"Curse of Malum" = /datum/curse/malum,
		"Curse of Eora" = /datum/curse/eora,
		"Curse of Zizo" = /datum/curse/zizo,
		"Curse of Graggar" = /datum/curse/graggar,
		"Curse of Matthios" = /datum/curse/matthios,
		"Curse of Baotha" = /datum/curse/baotha,
		)

	if(!isliving(target))
		to_chat(usr, "This can only be used on instances of type /mob/living")
		return

	var/curse_pick = input("Choose a curse to apply or lift.", "Select Curse") as null|anything in curse_choices
	if (!curse_pick)
		return

	var/curse_type = curse_choices[curse_pick]

	var/datum/curse/temp = new curse_type()
	if (target.is_cursed(temp))
		target.remove_curse(temp)
		priority_announce("Gods have lifted [curse_pick] from [target.real_name]!", title = "DIVINE MERCY", sound = 'sound/misc/bell.ogg')
		message_admins("ADMIN DIVINE WRATH: ([ckey]) has lifted [curse_pick] from [target.real_name]) ") //[ADMIN_LOOKUPFLW(user)] Maybe add this here if desirable but dunno.
		log_game("ADMIN DIVINE WRATH: ([ckey]) has lifted [curse_pick] from [target.real_name])")
	else
		if (length(target.curses) >= 1)
			to_chat(src, span_syndradio("[target.real_name] is already afflicted by another curse."))
			message_admins("ADMIN DIVINE WRATH: ([ckey]) has attempted to strike [target.real_name] ([target.ckey] with [curse_pick])")
			log_game("ADMIN DIVINE WRATH: ([ckey]) has attempted to strike [target.real_name] ([target.ckey] with [curse_pick])")					
			return
		target.add_curse(curse_type)
		priority_announce("Gods have stricken [target.real_name] with [curse_pick]!", title = "DIVINE PUNISHMENT", sound = 'sound/misc/excomm.ogg')
		message_admins("ADMIN DIVINE WRATH: ([ckey]) has stricken [target.real_name] ([target.ckey] with [curse_pick])")
		log_game("ADMIN DIVINE WRATH: ([ckey]) has stricken [target.real_name] ([target.ckey] with [curse_pick])")
