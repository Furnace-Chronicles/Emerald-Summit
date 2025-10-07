#ifndef QUEST_REWARD_FAVOR
#define QUEST_REWARD_FAVOR 250
#endif
#ifndef TRAIT_CLERGY
#define TRAIT_CLERGY "clergy"
#endif
#ifndef TRAIT_OUTLANDER
#define TRAIT_OUTLANDER "outlander"
#endif

/proc/_is_digit_string(t)
	if(!istext(t)) return FALSE
	if(length(t) != 4) return FALSE
	for(var/i=1, i<=4, i++)
		var/c = copytext(t, i, i+1)
		if(c < "0" || c > "9") return FALSE
	return TRUE

/proc/_digit_count(txt, dc)
	var/n = 0
	for(var/i=1, i<=length(txt), i++)
		if(copytext(txt, i, i+1) == dc) n++
	return n

/proc/_has_quest_lock(H)
	if(!istype(H, /mob/living/carbon/human)) return FALSE
	var/mob/living/carbon/human/HH = H
	return HH.has_status_effect(/datum/status_effect/debuff/quest_lock)

/proc/_apply_quest_lock(H)
	if(!istype(H, /mob/living/carbon/human)) return
	var/mob/living/carbon/human/HH = H
	if(!HH.has_status_effect(/datum/status_effect/debuff/quest_lock))
		HH.apply_status_effect(/datum/status_effect/debuff/quest_lock)

/proc/_is_antagonist(H)
	if(!istype(H, /mob/living/carbon/human)) return FALSE
	var/mob/living/carbon/human/HH = H
	if(!HH.mind) return FALSE
	if("antag_datums" in HH.mind.vars)
		var/list/L = HH.mind.vars["antag_datums"]
		if(islist(L) && L.len) return TRUE
	if("special_role" in HH.mind.vars)
		var/sr = HH.mind.vars["special_role"]
		if(istext(sr) && length(sr)) return TRUE
	return FALSE

/proc/_race_satisfies(H, key)
	if(!istype(H, /mob/living/carbon/human)) return FALSE
	var/mob/living/carbon/human/HH = H
	var/k = lowertext("[key]")
	if(k == "northern_human") return ishumannorthern(HH)
	if(k == "dwarf") return isdwarf(HH)
	if(k == "dark_elf") return isdarkelf(HH)
	if(k == "wood_elf") return iswoodelf(HH)
	if(k == "half_elf") return ishalfelf(HH)
	if(k == "half_orc") return ishalforc(HH)
	if(k == "goblin") return isgoblinp(HH)
	if(k == "kobold") return iskobold(HH)
	if(k == "lizard") return islizard(HH)
	if(k == "aasimar") return isaasimar(HH)
	if(k == "tiefling") return istiefling(HH)
	if(k == "halfkin") return ishalfkin(HH)
	if(k == "wildkin") return iswildkin(HH)
	if(k == "golem") return isgolemp(HH)
	if(k == "doll") return isdoll(HH)
	if(k == "vermin") return isvermin(HH)
	if(k == "dracon") return isdracon(HH)
	if(k == "axian") return isaxian(HH)
	if(k == "tabaxi") return istabaxi(HH)
	if(k == "vulp") return isvulp(HH)
	if(k == "lupian") return islupian(HH)
	if(k == "moth") return ismoth(HH)
	if(k == "lamia") return islamia(HH)
	return FALSE

/obj/item/quest_token
	name = "quest token"
	desc = "A token tied to a task."
	w_class = WEIGHT_CLASS_TINY
	var/owner_ckey = ""
	var/delete_at = 0

/obj/item/quest_token/Initialize()
	. = ..()
	if(ismob(loc))
		var/mob/M = loc
		if(M && M.client) owner_ckey = M.client.ckey
		else if(istext(M?.key)) owner_ckey = ckey(M.key)
	delete_at = world.time + (3 * 60 * 10)
	addtimer(CALLBACK(src, PROC_REF(_maybe_qdel_self)), 10, TIMER_LOOP)

/obj/item/quest_token/proc/_maybe_qdel_self()
	if(QDELETED(src)) return
	if(world.time >= delete_at)
		qdel(src)

/obj/item/quest_token/proc/_reward_owner(amount)
	if(!amount || !owner_ckey) return
	var/mob/living/carbon/human/receiver = null
	for(var/mob/living/carbon/human/H in world)
		if(H.client && H.client.ckey == owner_ckey) { receiver = H; break }
	if(receiver)
		receiver.church_favor += amount
		to_chat(receiver, span_notice("+[amount] Favor for completing a miracle quest."))

/obj/item/quest_token/proc/_ensure_attacker(user)
	if(!user || !ismob(user)) return FALSE
	var/mob/M = user
	var/u_ckey = ""
	if(M.client) u_ckey = M.client.ckey
	else if(istext(M.key)) u_ckey = ckey(M.key)
	if(u_ckey != owner_ckey)
		to_chat(user, span_warning("It does not heed your hand."))
		return FALSE
	if(!HAS_TRAIT(M, TRAIT_CLERGY))
		to_chat(user, span_warning("Only clergy may invoke this."))
		return FALSE
	return TRUE

/obj/item/quest_token/proc/_ensure_target_player(H, user)
	if(!istype(H, /mob/living/carbon/human)) { to_chat(user, span_warning("Target must be a person.")); return FALSE }
	var/mob/living/carbon/human/HH = H
	if(!HH.client) { to_chat(user, span_warning("Target must be a player.")); return FALSE }
	if(HAS_TRAIT(HH, TRAIT_CLERGY)) { to_chat(user, span_warning("Clergy cannot be targeted.")); return FALSE }
	return TRUE

/datum/status_effect/debuff/quest_lock
	id = "quest_lock"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/dazed
	effectedstats = list("perception" = -1)
	duration = 20 MINUTES

/atom/movable/screen/alert/status_effect/debuff/quest_lock
	name = "sacred cooldown"
	desc = "You recently received a sacred effect and cannot receive another yet."
	icon_state = "debuff"

/datum/status_effect/debuff/bled_quest
	id = "bled_quest"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/dazed
	effectedstats = list("endurance" = -1)
	duration = 10 MINUTES

/atom/movable/screen/alert/status_effect/debuff/bled_quest
	name = "bloodletting"
	desc = "You recently gave blood and feel a bit faint."
	icon_state = "debuff"

/datum/status_effect/buff/pilgrim_mark
	id = "pilgrim_mark"
	alert_type = /atom/movable/screen/alert/status_effect/buff/sermon
	effectedstats = list("fortune" = 1)
	duration = 10 MINUTES

/atom/movable/screen/alert/status_effect/buff/pilgrim_mark
	name = "pilgrim’s grace"
	desc = "Anointed for a short journey."
	icon_state = "buff"

/datum/status_effect/buff/sermon_minor
	id = "sermon_minor"
	alert_type = /atom/movable/screen/alert/status_effect/buff/sermon
	effectedstats = list("fortune" = 1, "constitution" = 1)
	duration = 10 MINUTES

/atom/movable/screen/alert/status_effect/buff/sermon_minor
	name = "minor sermon"
	desc = "A brief spark of inspiration."
	icon_state = "buff"

/datum/status_effect/buff/blessed_skill
	id = "blessed_skill"
	alert_type = /atom/movable/screen/alert/status_effect/buff/sermon
	effectedstats = list("intelligence" = 1, "endurance" = 1)
	duration = 10 MINUTES

/atom/movable/screen/alert/status_effect/buff/blessed_skill
	name = "blessed craft"
	desc = "You feel your craft guided."
	icon_state = "buff"

/datum/status_effect/buff/solace
	id = "solace"
	alert_type = /atom/movable/screen/alert/status_effect/buff/sermon
	effectedstats = list("fortune" = 1)
	duration = 10 MINUTES

/atom/movable/screen/alert/status_effect/buff/solace
	name = "solace"
	desc = "A gentle calm settles in."
	icon_state = "buff"

/obj/item/quest_token/outlander_ration
	name = "charity ration"
	desc = "Feed an outlander by hand."

/obj/item/quest_token/outlander_ration/attack(target, user)
	if(!istype(target, /mob/living/carbon/human)) return ..()
	if(!_ensure_attacker(user)) return
	var/mob/living/carbon/human/H = target
	if(!_ensure_target_player(H, user)) return
	if(!_has_quest_lock(H))
		if(!HAS_TRAIT(H, TRAIT_OUTLANDER)) { to_chat(user, span_warning("They are not an outlander.")); return }
		if(!do_after(user, 15 SECONDS, H)) return
		H.apply_status_effect(/datum/status_effect/buff/pilgrim_mark)
		_apply_quest_lock(H)
		_reward_owner(QUEST_REWARD_FAVOR)
		qdel(src)
	else
		to_chat(user, span_warning("Target recently received a sacred effect."))

/obj/item/quest_token/sermon_minor
	name = "minor sermon token"
	desc = "Deliver a minor sermon to a follower of the specified patron."
	var/required_patron_name = ""

/obj/item/quest_token/sermon_minor/attack(target, user)
	if(!istype(target, /mob/living/carbon/human)) return ..()
	if(!_ensure_attacker(user)) return
	var/mob/living/carbon/human/H = target
	if(!_ensure_target_player(H, user)) return
	if(_has_quest_lock(H)) { to_chat(user, span_warning("Target recently received a sacred effect.")); return }
	if(!(H?.devotion?.patron) || "[H.devotion.patron.name]" != "[required_patron_name]") { to_chat(user, span_warning("They do not follow [required_patron_name].")); return }
	if(!do_after(user, 15 SECONDS, H)) return
	H.apply_status_effect(/datum/status_effect/buff/sermon_minor)
	_apply_quest_lock(H)
	_reward_owner(QUEST_REWARD_FAVOR)
	qdel(src)

/obj/item/quest_token/sermon_witness
	name = "sermon witness"
	desc = "Confirm the target bears the 'sermon' blessing."

/obj/item/quest_token/sermon_witness/attack(target, user)
	if(!istype(target, /mob/living/carbon/human)) return ..()
	if(!_ensure_attacker(user)) return
	var/mob/living/carbon/human/H = target
	if(!_ensure_target_player(H, user)) return
	if(!H.has_status_effect(/datum/status_effect/buff/sermon)) { to_chat(user, span_warning("They are not inspired by a sermon.")); return }
	if(!do_after(user, 10 SECONDS, H)) return
	_reward_owner(QUEST_REWARD_FAVOR)
	qdel(src)

/proc/_safe_has_skill_expert(H, skill_type)
	if(!istype(H, /mob/living/carbon/human)) return FALSE
	if(!ispath(skill_type, /datum/skill)) return FALSE
	var/mob/living/carbon/human/HH = H
	if(hascall(HH, "get_skill_level"))
		var/level = call(HH, "get_skill_level")(skill_type)
		return isnum(level) && level >= 4
	if("skill_levels" in HH.vars)
		var/list/L = HH.vars["skill_levels"]
		if(islist(L) && (skill_type in L))
			var/val = L[skill_type]
			if(isnum(val) && val >= 4) return TRUE
	return FALSE

/obj/item/quest_token/skill_bless
	name = "mark of craft"
	desc = "Bless an expert of a specified skill."
	var/required_skill_type = null

/obj/item/quest_token/skill_bless/attack(target, user)
	if(!istype(target, /mob/living/carbon/human)) return ..()
	if(!_ensure_attacker(user)) return
	var/mob/living/carbon/human/H = target
	if(!_ensure_target_player(H, user)) return
	if(_has_quest_lock(H)) { to_chat(user, span_warning("Target recently received a sacred effect.")); return }
	if(!required_skill_type || !_safe_has_skill_expert(H, required_skill_type)) { to_chat(user, span_warning("They are not an EXPERT of the required skill.")); return }
	if(!do_after(user, 15 SECONDS, H)) return
	H.apply_status_effect(/datum/status_effect/buff/blessed_skill)
	_apply_quest_lock(H)
	_reward_owner(QUEST_REWARD_FAVOR)
	qdel(src)

/proc/_target_has_flaw(H, flaw_type)
	if(!istype(H, /mob/living/carbon/human)) return FALSE
	var/mob/living/carbon/human/HH = H
	if(!ispath(flaw_type, /datum/charflaw)) return FALSE
	if(hascall(HH, "has_flaw"))
		return !!call(HH, "has_flaw")(flaw_type)
	if("charflaws" in HH.vars)
		var/list/L = HH.vars["charflaws"]
		if(islist(L))
			for(var/datum/charflaw/F in L)
				if(istype(F, flaw_type)) return TRUE
	return FALSE

/obj/item/quest_token/flaw_aid
	name = "mercy charm"
	desc = "Soothe a player bearing a specific flaw."
	var/required_flaw_type = null

/obj/item/quest_token/flaw_aid/attack(target, user)
	if(!istype(target, /mob/living/carbon/human)) return ..()
	if(!_ensure_attacker(user)) return
	var/mob/living/carbon/human/H = target
	if(!_ensure_target_player(H, user)) return
	if(_has_quest_lock(H)) { to_chat(user, span_warning("Target recently received a sacred effect.")); return }
	if(!required_flaw_type || !_target_has_flaw(H, required_flaw_type)) { to_chat(user, span_warning("Target does not bear the required flaw.")); return }
	if(!do_after(user, 15 SECONDS, H)) return
	H.apply_status_effect(/datum/status_effect/buff/solace)
	_apply_quest_lock(H)
	_reward_owner(QUEST_REWARD_FAVOR)
	qdel(src)

/obj/item/quest_token/donation_box
	name = "offering coffer"
	desc = "Accepts one designated offering."
	var/list/need_types = list()
	var/collected = FALSE

/obj/item/quest_token/donation_box/attackby(I, user, params)
	if(collected || !I) return
	if(!_ensure_attacker(user)) return
	for(var/T in need_types)
		if(istype(I, T))
			qdel(I)
			collected = TRUE
			to_chat(user, span_notice("The offering is accepted."))
			_reward_owner(QUEST_REWARD_FAVOR)
			qdel(src)
			return
	to_chat(user, span_warning("This is not an acceptable offering."))

/obj/item/quest_token/coin_chest
	name = "tithe chest"
	desc = "Feed it with mammon. At 500 or more, the chest vanishes."
	var/sum = 0

/obj/item/quest_token/coin_chest/attackby(I, user, params)
	if(!I) return
	if(!_ensure_attacker(user)) return
	if(istype(I, /obj/item/roguecoin/aalloy)) return
	if(istype(I, /obj/item/roguecoin/inqcoin)) return
	if(istype(I, /obj/item/roguecoin))
		var/obj/item/roguecoin/C = I
		sum += C.get_real_price()
		qdel(C)
		to_chat(user, span_notice("Deposited. Current tithe: [sum]."))
		if(sum >= 500)
			to_chat(user, span_notice("The chest accepts the tithe."))
			_reward_owner(QUEST_REWARD_FAVOR)
			qdel(src)
		return
	..()

/obj/item/quest_token/reliquary
	name = "sealed reliquary"
	desc = "A sealed box with a hidden 4-digit code."
	var/code = ""
	var/bonus_patron_name = ""
	var/next_attempt_ds = 0

/obj/item/quest_token/reliquary/Initialize()
	. = ..()
	code = "[rand(0,9)][rand(0,9)][rand(0,9)][rand(0,9)]"
	if(isnull(bonus_patron_name) || !length(bonus_patron_name))
		var/list/fallback = list("Astrata","Noc","Dendor","Abyssor","Ravox","Necra","Xylix","Pestra","Malum","Eora")
		bonus_patron_name = pick(fallback)
	next_attempt_ds = world.time

/obj/item/quest_token/reliquary/examine(user)
	. = ..()
	if(istype(user, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		if(H?.devotion?.patron && "[H.devotion.patron.name]" == "[bonus_patron_name]")
			. += "<br><span class='notice'>Divine insight: <b>[code]</b></span>"
		else
			. += "<br><span class='info'>Followers of [bonus_patron_name] see the code clearly.</span>"

/obj/item/quest_token/reliquary/attack_hand(user)
	if(!..()) return
	if(!_ensure_attacker(user)) return
	var/left = max(0, next_attempt_ds - world.time)
	var/left_s = round(left/10)
	var/m = left_s / 60
	var/s = left_s % 60
	var/s2 = "[s]"; if(s < 10) s2 = "0[s]"
	var/locked = (world.time < next_attempt_ds)
	var/html = "<center><b>Sealed Reliquary</b></center><hr>"
	html += "Enter the 4-digit code to open the box.<br>"
	html += "<b>Attempts:</b> once every 5 minutes.<br>"
	html += "<b>Hint:</b> green = correct place, yellow = correct digit wrong place.<br><br>"
	if(locked)
		html += "<span style='color:#7f8c8d'>Next attempt in [m]:[s2]</span>"
	else
		html += "<a href='?src=[REF(src)];trycode=1'>Try code</a>"
	var/datum/browser/B = new(user, "RELIQUARY_UI", "", 360, 220)
	B.set_content(html)
	B.open()

/obj/item/quest_token/reliquary/Topic(href, href_list)
	. = ..()
	if(!usr) return
	if(!_ensure_attacker(usr)) return
	if(href_list["trycode"])
		if(world.time < next_attempt_ds) { attack_hand(usr); return }
		var/guess = input(usr, "Enter 4 digits (0-9).", "Reliquary") as null|text
		if(!guess) { attack_hand(usr); return }
		guess = copytext(guess, 1, 5)
		if(!_is_digit_string(guess)) { to_chat(usr, span_warning("Needs exactly four digits 0-9.")); attack_hand(usr); return }
		var/correct_pos = 0
		for(var/i=1 to 4)
			if(copytext(code, i, i+1) == copytext(guess, i, i+1))
				correct_pos++
		var/correct_digit = 0
		for(var/d=0 to 9)
			var/ds = "[d]"
			var/nc = _digit_count(code, ds)
			var/ng = _digit_count(guess, ds)
			correct_digit += min(nc, ng)
		correct_digit -= correct_pos
		next_attempt_ds = world.time + (5*60*10)
		if(guess == code)
			to_chat(usr, span_notice("The reliquary opens."))
			_reward_owner(QUEST_REWARD_FAVOR)
			qdel(src)
			return
		else
			to_chat(usr, "<span class='notice'>Feedback — <span style='color:#2ecc71'>green</span>: [correct_pos], <span style='color:#f1c40f'>yellow</span>: [correct_digit]</span>")
		attack_hand(usr)

/obj/item/quest_token/antag_find
	name = "insight sigil"
	desc = "Discern a hidden foe."

/obj/item/quest_token/antag_find/attack(target, user)
	if(!istype(target, /mob/living/carbon/human)) return ..()
	if(!_ensure_attacker(user)) return
	var/mob/living/carbon/human/H = target
	if(!_ensure_target_player(H, user)) return
	if(!_is_antagonist(H)) { to_chat(user, span_warning("No hidden malice reveals itself.")); return }
	if(!do_after(user, 15 SECONDS, H)) return
	_reward_owner(QUEST_REWARD_FAVOR)
	qdel(src)

/obj/item/quest_token/blood_draw
	name = "sanctified lancet"
	desc = "Draw blood from a specific race."
	var/required_race_key = ""

/obj/item/quest_token/blood_draw/attack(target, user)
	if(!istype(target, /mob/living/carbon/human)) return ..()
	if(!_ensure_attacker(user)) return
	var/mob/living/carbon/human/H = target
	if(!_ensure_target_player(H, user)) return
	if(H.has_status_effect(/datum/status_effect/debuff/bled_quest)) { to_chat(user, span_warning("They have recently given blood.")); return }
	if(!_race_satisfies(H, required_race_key)) { to_chat(user, span_warning("Wrong race for this task.")); return }
	if(!do_after(user, 15 SECONDS, H)) return
	H.apply_status_effect(/datum/status_effect/debuff/bled_quest)
	_reward_owner(QUEST_REWARD_FAVOR)
	qdel(src)
