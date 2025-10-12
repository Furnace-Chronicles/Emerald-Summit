#ifndef QUEST_REWARD_FAVOR
#define QUEST_REWARD_FAVOR 250
#endif

/proc/_is_digit_string(t)
	if(!istext(t)) return FALSE
	if(length(t) != 4) return FALSE
	for(var/i = 1, i <= 4, i++)
		var/c = copytext(t, i, i + 1)
		if(c < "0" || c > "9") return FALSE
	return TRUE

/proc/_digit_count(txt, dc)
	var/n = 0
	for(var/i = 1, i <= length(txt), i++)
		if(copytext(txt, i, i + 1) == dc) n++
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

/proc/_apply_parish_boon(H)
	if(!istype(H, /mob/living/carbon/human)) return
	var/mob/living/carbon/human/HH = H
	HH.apply_status_effect(/datum/status_effect/buff/parish_boon)

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

// CORE of QUESTS

/obj/item/quest_token
	name = "quest token"
	desc = "A token tied to a task. Report to local admin if you see this to get ERP token"
	icon = 'icons/roguetown/items/misc.dmi'
	w_class = WEIGHT_CLASS_TINY
	var/owner_ckey = ""
	var/owner_name = ""
	var/delete_at = 0

/obj/item/quest_token/Initialize()
	. = ..()
	if(ismob(loc))
		var/mob/M = loc
		if(M && M.client)
			owner_ckey = M.client.ckey
			if(istype(M, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = M
				owner_name = H.real_name || H.name || owner_ckey
			else
				owner_name = M.name || owner_ckey
		else if(istext(M?.key))
			owner_ckey = ckey(M.key)
			owner_name = M.name || owner_ckey
	if(!length(owner_name)) owner_name = "unknown"

	delete_at = world.time + (3 * 60 * 10) //yes im lazy retard
	addtimer(CALLBACK(src, PROC_REF(_maybe_qdel_self)), 10, TIMER_LOOP)

	if(length(owner_ckey))
		_start_owner_watch()

/obj/item/quest_token/proc/set_owner(mob/living/carbon/human/H)
	if(!H) return
	if(H.client) owner_ckey = H.client.ckey
	else if(istext(H.key)) owner_ckey = ckey(H.key)
	owner_name = H.real_name || H.name || owner_ckey
	_start_owner_watch()

/obj/item/quest_token/proc/_start_owner_watch()
	spawn(0)
		while(src)
			if(!length(owner_ckey)) { qdel(src); return }
			var/found = FALSE
			for(var/mob/living/carbon/human/H in world)
				if(H.client && H.client.ckey == owner_ckey) { found = TRUE; break }
			if(!found) { qdel(src); return }
			sleep(50)

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
		to_chat(user, span_warning("It does not heed your hand. (Owner: [owner_name].)" ))
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

// proc fluff

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

// TOKENS


// 1) make an antag to sign this shit your excuse being railed by werewolves and bandits

/obj/item/quest_token/antag_find
	name = "insight sigil"
	desc = "Discern a hidden foe."
	icon_state = "questflaw"

/obj/item/quest_token/antag_find/attack(target, user)
	if(!istype(target, /mob/living/carbon/human)) return ..()
	if(!_ensure_attacker(user)) return
	var/mob/living/carbon/human/H = target
	if(!_ensure_target_player(H, user)) return
	if(_has_quest_lock(H)) { to_chat(user, span_warning("They’ve already answered the call - stand down and let the clock run.")); return }
	if(!_is_antagonist(H)) { to_chat(user, span_warning("No hidden malice reveals itself.")); return }
	if(!do_after(user, 15 SECONDS, H)) return
	_apply_parish_boon(H)
	_apply_quest_lock(H)
	_reward_owner(QUEST_REWARD_FAVOR)
	qdel(src)

// 2) bless expert of skill
/obj/item/quest_token/skill_bless
	name = "mark of craft"
	desc = "Bless an expert of a specified skill."
	icon_state = "questflaw"
	var/required_skill_type = null

/obj/item/quest_token/skill_bless/attack(target, user)
	if(!istype(target, /mob/living/carbon/human)) return ..()
	if(!_ensure_attacker(user)) return
	var/mob/living/carbon/human/H = target
	if(!_ensure_target_player(H, user)) return
	if(_has_quest_lock(H)) { to_chat(user, span_warning("They’ve already answered the call - stand down and let the clock run.")); return }
	if(!required_skill_type || !_safe_has_skill_expert(H, required_skill_type)) { to_chat(user, span_warning("They are not an EXPERT of the required skill.")); return }
	if(!do_after(user, 15 SECONDS, H)) return
	_apply_parish_boon(H)
	_apply_quest_lock(H)
	_reward_owner(QUEST_REWARD_FAVOR)
	qdel(src)

// 3) take blood of race
/obj/item/quest_token/blood_draw
	name = "sanctified lancet"
	desc = "Draw blood from a specific race."
	icon_state = "questblood"
	var/required_race_key = ""

/obj/item/quest_token/blood_draw/attack(target, user)
	if(!istype(target, /mob/living/carbon/human)) return ..()
	if(!_ensure_attacker(user)) return
	var/mob/living/carbon/human/H = target
	if(!_ensure_target_player(H, user)) return
	if(_has_quest_lock(H)) { to_chat(user, span_warning("They’ve already answered the call - stand down and let the clock run.")); return }
	if(!_race_satisfies(H, required_race_key)) { to_chat(user, span_warning("Wrong race for this task.")); return }
	if(!do_after(user, 15 SECONDS, H)) return
	_apply_parish_boon(H)
	_apply_quest_lock(H)
	_reward_owner(QUEST_REWARD_FAVOR)
	qdel(src)

// 4) donate 500 mammon
/obj/item/quest_token/coin_chest
	name = "tithe chest"
	desc = "Feed it with mammon. At 500 or more, the chest vanishes."
	icon_state = "questbox"
	var/sum = 0

/obj/item/quest_token/coin_chest/attackby(I, user, params)
	if(!I) return
	if(!_ensure_attacker(user)) return
	if(_has_quest_lock(user)) { to_chat(user, span_warning("You are under the Edict and cannot perform another routine.")); return }
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


// 5) sealed reliquary (4-digit code)

/obj/item/quest_token/reliquary
	name = "sealed reliquary"
	desc = "An ancient box sealed by divine sigils."
	icon_state = "questbox"
	w_class = WEIGHT_CLASS_NORMAL

	var/code = "0000"
	var/bonus_patron_name = null
	var/next_attempt_ds = 0

/obj/item/quest_token/reliquary/Initialize()
	. = ..()

	if(!length(code) || code == "0000")
		code = generate_reliquary_code()
	else
		if(!(code in GLOB.generated_reliquary_codes))
			GLOB.generated_reliquary_codes += code

	if(isnull(bonus_patron_name) || !length(bonus_patron_name))
		var/list/fallback = list("Astrata","Noc","Dendor","Abyssor","Ravox","Necra","Xylix","Pestra","Malum","Eora")
		bonus_patron_name = pick(fallback)

	next_attempt_ds = world.time
/obj/item/quest_token/reliquary/examine(mob/user)
	. = ..()
	if(!istext(bonus_patron_name) || !length(bonus_patron_name))
		return
	if(istype(user, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		if(_patron_matches(H, bonus_patron_name))
			. += "<br><span class='notice'>Divine insight: <b>[code]</b></span>"
		else
			. += "<br><span class='info'>Followers of [bonus_patron_name] see the code clearly.</span>"

/obj/item/quest_token/reliquary/proc/_ensure_ui_access(mob/living/user)
	if(!user) return FALSE
	if(!user.canUseTopic(src, TRUE)) return FALSE
	if(get_dist(user, src) > 1) return FALSE
	return TRUE

/obj/item/quest_token/reliquary/attack_hand(mob/living/user)
	. = ..() // ← CHANGED: НЕ выходим по результату родителя
	if(!_ensure_attacker(user)) return
	if(!_ensure_ui_access(user)) return

	user.set_machine(src)

	var/locked = (world.time < next_attempt_ds)
	var/left = max(0, next_attempt_ds - world.time)
	var/left_s = round(left / 10)
	var/m = left_s / 60
	var/s = left_s % 60
	var/s2 = (s < 10) ? "0[s]" : "[s]"

	var/html = "<center><b>Sealed Reliquary</b></center><hr>"
	html += "Enter the 4-digit code to open the box.<br>"
	html += "<b>Attempts:</b> once every <b>20 seconds</b>.<br>"
	html += "<b>Hint:</b> <span style='color:#2ecc71'>green</span> = correct place, "
	html += "<span style='color:#f1c40f'>yellow</span> = correct digit wrong place.<br><br>"

	if(locked)
		html += "<span style='color:#7f8c8d'>Next attempt in [m]:[s2]</span>"
	else
		html += "<a href='?src=[REF(src)];trycode=1'>Try code</a>"

	var/datum/browser/B = new(user, "RELIQUARY_UI", "Sealed Reliquary", 360, 220)
	B.set_content(html)
	B.open()
	return TRUE

/obj/item/quest_token/reliquary/Topic(href, href_list)
	. = ..()
	if(!usr) return
	if(!_ensure_attacker(usr)) return
	if(!_ensure_ui_access(usr)) return

	if(_has_quest_lock(usr)) {
		to_chat(usr, span_warning("You are under the Edict and cannot perform another routine."))
		return
	}

	if(href_list["trycode"]) {
		if(world.time < next_attempt_ds) {
			attack_hand(usr)
			return
		}

		var/guess = input(usr, "Enter 4 digits (0-9).", "Reliquary") as null|text
		if(isnull(guess)) {
			attack_hand(usr)
			return
		}

		guess = copytext(guess, 1, 5)
		if(!_is_digit_string(guess) || length(guess) != 4) {
			to_chat(usr, span_warning("Needs exactly four digits 0-9."))
			attack_hand(usr)
			return
		}

		var/correct_pos = 0
		for(var/i = 1 to 4)
			if(copytext(code, i, i + 1) == copytext(guess, i, i + 1))
				correct_pos++

		var/correct_digit = 0
		for(var/d = 0 to 9)
			var/ds = "[d]"
			var/nc = _digit_count(code, ds)
			var/ng = _digit_count(guess, ds)
			correct_digit += min(nc, ng)
		correct_digit -= correct_pos

		next_attempt_ds = world.time + (20 SECONDS)

		if(guess == code) {
			to_chat(usr, span_notice("The reliquary opens."))
			_reward_owner(QUEST_REWARD_FAVOR)
			qdel(src)
			return
		} else {
			to_chat(usr, "<span class='notice'>Feedback — <span style='color:#2ecc71'>green</span>: [correct_pos], <span style='color:#f1c40f'>yellow</span>: [correct_digit]</span>")
		}

		attack_hand(usr)
	}



// 6) feed outlander
/obj/item/quest_token/outlander_ration
	name = "charity ration"
	desc = "Feed an outlander by hand."
	icon_state = "questration"

/obj/item/quest_token/outlander_ration/attack(target, user)
	if(!istype(target, /mob/living/carbon/human)) return ..()
	if(!_ensure_attacker(user)) return
	var/mob/living/carbon/human/H = target
	if(!_ensure_target_player(H, user)) return
	if(_has_quest_lock(H)) { to_chat(user, span_warning("They’ve already answered the call - stand down and let the clock run.")); return }
	if(!HAS_TRAIT(H, TRAIT_OUTLANDER)) { to_chat(user, span_warning("They are not an outlander.")); return }
	if(!do_after(user, 15 SECONDS, H)) return
	_apply_parish_boon(H)
	_apply_quest_lock(H)
	_reward_owner(QUEST_REWARD_FAVOR)
	qdel(src)

// 7) donation whitelist
/obj/item/quest_token/donation_box
	name = "offering coffer"
	desc = "Accepts one designated offering."
	icon_state = "questbox"
	var/list/need_types = list()
	var/collected = FALSE

/obj/item/quest_token/donation_box/attackby(I, user, params)
	if(collected || !I) return
	if(!_ensure_attacker(user)) return
	if(_has_quest_lock(user)) { to_chat(user, span_warning("They’ve already answered the call - stand down and let the clock run")); return }
	for(var/T in need_types)
		if(istype(I, T))
			qdel(I)
			collected = TRUE
			to_chat(user, span_notice("The offering is accepted."))
			_reward_owner(QUEST_REWARD_FAVOR)
			qdel(src)
			return
	to_chat(user, span_warning("This is not an acceptable offering."))

// 8) minor sermon to follower of patron
/obj/item/quest_token/sermon_minor
	name = "sermon token"
	desc = "Deliver a Minor Sermon to a follower of a specific patron."
	icon_state = "questflaw"
	var/required_patron_name = ""

/obj/item/quest_token/sermon_minor/Initialize()
	. = ..()
	if(!length(required_patron_name))
		var/list/fallback = list("Astrata","Noc","Dendor","Abyssor","Ravox","Necra","Xylix","Pestra","Malum","Eora")
		required_patron_name = pick(fallback)

/obj/item/quest_token/sermon_minor/examine(mob/user)
	. = ..()
	. += "<br><span class='info'>This sermon seeks a follower of <b>[required_patron_name]</b>.</span>"

/proc/_patron_matches(mob/living/carbon/human/H, required_patron_name as text)
	if(!istype(H) || !istext(required_patron_name) || !length(required_patron_name))
		return FALSE
	var/datum/devotion/D = H.devotion
	if(!D || !D.patron || !D.patron.name)
		return FALSE
	var/target_name = lowertext(trim("[D.patron.name]"))
	var/need_name = lowertext(trim("[required_patron_name]"))
	return target_name == need_name

/obj/item/quest_token/sermon_minor/attack(mob/living/target, mob/living/user)
	if(!istype(target, /mob/living/carbon/human))
		return ..()
	if(!_ensure_attacker(user))
		return

	var/mob/living/carbon/human/H = target
	if(!_ensure_target_player(H, user))
		return

	if(_has_quest_lock(H))
		to_chat(user, span_warning("They’ve already answered the call - stand down and let the clock run."))
		return

	if(!_patron_matches(H, required_patron_name))
		to_chat(user, span_warning("They do not follow [required_patron_name]."))
		return

	user.visible_message(
		span_notice("[user] begins a brief sermon to [H]."),
		span_notice("I begin a brief sermon to [H].")
	)

	if(!do_after(user, 15 SECONDS, target = H))
		return

	user.visible_message(
		span_notice("[user] finishes the sermon for [H]."),
		span_notice("I finish the sermon for [H].")
	)

	_apply_parish_boon(H)
	_apply_quest_lock(H)
	_reward_owner(QUEST_REWARD_FAVOR)
	qdel(src)
	return TRUE


// 9) witness sermon buff
/obj/item/quest_token/sermon_witness
	name = "sermon witness"
	desc = "Confirm the target bears the 'sermon' blessing."
	icon_state = "questflaw"

/obj/item/quest_token/sermon_witness/attack(target, user)
	if(!istype(target, /mob/living/carbon/human)) return ..()
	if(!_ensure_attacker(user)) return
	var/mob/living/carbon/human/H = target
	if(!_ensure_target_player(H, user)) return
	if(_has_quest_lock(H)) { to_chat(user, span_warning("They’ve already answered the call - stand down and let the clock run.")); return }
	if(!H.has_status_effect(/datum/status_effect/buff/sermon)) { to_chat(user, span_warning("They are not inspired by a sermon.")); return }
	if(!do_after(user, 10 SECONDS, H)) return
	_apply_parish_boon(H)
	_apply_quest_lock(H)
	_reward_owner(QUEST_REWARD_FAVOR)
	qdel(src)

// 10) help flaw
/obj/item/quest_token/flaw_aid
	name = "mercy charm"
	desc = "Soothe a player bearing a specific flaw."
	icon_state = "questflaw"
	var/required_flaw_type = null

/obj/item/quest_token/flaw_aid/attack(target, user)
	if(!istype(target, /mob/living/carbon/human)) return ..()
	if(!_ensure_attacker(user)) return
	var/mob/living/carbon/human/H = target
	if(!_ensure_target_player(H, user)) return
	if(_has_quest_lock(H)) { to_chat(user, span_warning("They’ve already answered the call - stand down and let the clock run.")); return }
	if(!required_flaw_type || !_target_has_flaw(H, required_flaw_type)) { to_chat(user, span_warning("Target does not bear the required flaw.")); return }
	if(!do_after(user, 15 SECONDS, H)) return
	_apply_parish_boon(H)
	_apply_quest_lock(H)
	_reward_owner(QUEST_REWARD_FAVOR)
	qdel(src)


// UI ANCOR THING


/proc/_rt_build_full_quest_pool(mob/living/carbon/human/H)
	if(!H) return list()

	var/list/pool = list()

	pool += list(list(
		"kind"=1, "title"="Insight Sigil",
		"desc"="Use the sigil on a hidden foe.",
		"reward"=QUEST_REWARD_FAVOR,
		"token_path"=/obj/item/quest_token/antag_find,
		"params"=list()
	))

	var/skill_t = null
	var/list/skill_cands = list()
	for(var/t in typesof(/datum/skill))
		if(t != /datum/skill) skill_cands += t
	if(skill_cands.len) skill_t = pick(skill_cands)

	var/skill_name = "[skill_t]"
	if(skill_t)
		var/datum/skill/SK = new skill_t
		if(SK && istext(SK.name)) skill_name = SK.name
		qdel(SK)

	pool += list(list(
		"kind"=2, "title"="Find Expertise",
		"desc"="Bless an EXPERT of SKILL: [html_attr(skill_name)].",
		"reward"=QUEST_REWARD_FAVOR,
		"token_path"=/obj/item/quest_token/skill_bless,
		"params"=list("required_skill_type"=skill_t)
	))

	var/list/race_keys = list(
		"northern_human","dwarf","dark_elf","wood_elf","half_elf","half_orc",
		"goblin","kobold","lizard","aasimar","tiefling","halfkin","wildkin",
		"golem","doll","vermin","dracon","axian","tabaxi","vulp","lupian",
		"moth","lamia"
	)
	var/race_key = lowertext(pick(race_keys))
	pool += list(list(
		"kind"=3, "title"="Rite of Blood",
		"desc"="Take blood from RACE: [html_attr(uppertext(race_key))].",
		"reward"=QUEST_REWARD_FAVOR,
		"token_path"=/obj/item/quest_token/blood_draw,
		"params"=list("required_race_key"=race_key)
	))

	pool += list(list(
		"kind"=4, "title"="Tithe of 500",
		"desc"="Donate at least 500 mammon into the chest.",
		"reward"=QUEST_REWARD_FAVOR,
		"token_path"=/obj/item/quest_token/coin_chest,
		"params"=list()
	))

	var/pname = null
	build_divine_patrons_index()
	if(divine_patrons_index && divine_patrons_index.len)
		var/list/names = list()
		for(var/n in divine_patrons_index) names += "[n]"
		pname = pick(names)
	if(!pname) pname = pick(list("Astrata","Noc","Dendor","Abyssor","Ravox","Necra","Xylix","Pestra","Malum","Eora"))

	pool += list(list(
		"kind"=5, "title"="Sealed Reliquary",
		"desc"="Solve a 4-digit code (followers of [html_attr(pname)] can see it).",
		"reward"=QUEST_REWARD_FAVOR,
		"token_path"=/obj/item/quest_token/reliquary,
		"params"=list("bonus_patron_name"=pname)
	))

	pool += list(list(
		"kind"=6, "title"="Feed the Outlander",
		"desc"="Hand-feed a player with the OUTLANDER trait.",
		"reward"=QUEST_REWARD_FAVOR,
		"token_path"=/obj/item/quest_token/outlander_ration,
		"params"=list()
	))

	var/list/need_types = list(
		/obj/item/ingot/iron
	)
	pool += list(list(
		"kind"=7, "title"="Relic Tribute",
		"desc"="Offer one accepted item into the cube.",
		"reward"=QUEST_REWARD_FAVOR,
		"token_path"=/obj/item/quest_token/donation_box,
		"params"=list("need_types"=need_types)
	))

	var/pname2 = null
	if(divine_patrons_index && divine_patrons_index.len)
		var/list/names2 = list()
		for(var/m in divine_patrons_index) names2 += "[m]"
		pname2 = pick(names2)
	if(!pname2) pname2 = pick(list("Astrata","Noc","Dendor","Abyssor","Ravox","Necra","Xylix","Pestra","Malum","Eora"))

	pool += list(list(
		"kind"=8, "title"="Minor Sermon",
		"desc"="Deliver a Minor Sermon to a follower of [html_attr(pname2)].",
		"reward"=QUEST_REWARD_FAVOR,
		"token_path"=/obj/item/quest_token/sermon_minor,
		"params"=list("required_patron_name"=pname2)
	))

	pool += list(list(
		"kind"=9, "title"="Anoint the Inspired",
		"desc"="Seal a player who currently has a sermon-style blessing.",
		"reward"=QUEST_REWARD_FAVOR,
		"token_path"=/obj/item/quest_token/sermon_witness,
		"params"=list()
	))

	var/flaw_t = null
	var/list/flaw_cands = list()
	for(var/t2 in typesof(/datum/charflaw))
		if(t2 != /datum/charflaw) flaw_cands += t2
	if(flaw_cands.len) flaw_t = pick(flaw_cands)

	var/flaw_name = "[flaw_t]"
	if(flaw_t)
		var/datum/charflaw/F = new flaw_t
		if(F && istext(F.name)) flaw_name = F.name
		qdel(F)

	pool += list(list(
		"kind"=10, "title"="Mercy for the Afflicted",
		"desc"="Soothe a player bearing flaw: [html_attr(flaw_name)].",
		"reward"=QUEST_REWARD_FAVOR,
		"token_path"=/obj/item/quest_token/flaw_aid,
		"params"=list("required_flaw_type"=flaw_t)
	))

	return pool
