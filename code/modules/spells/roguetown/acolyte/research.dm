// dont touch it, it responsable for holy_bureaucracy_xxx
#undef  MIRACLE_RADIAL_DMI
#define MIRACLE_RADIAL_DMI 'icons/mob/actions/roguespells.dmi'

#ifndef TRAIT_CLERGY
#define TRAIT_CLERGY "clergy"
#endif

#ifndef CLERIC_PRICE_PATRON
#define CLERIC_PRICE_PATRON 1
#endif
#ifndef CLERIC_PRICE_DIVINE
#define CLERIC_PRICE_DIVINE 3
#endif
#ifndef CLERIC_PRICE_SHUNNED
#define CLERIC_PRICE_SHUNNED 3
#endif

#ifndef MIRACLE_MP_PRICE_FLAVOR
#define MIRACLE_MP_PRICE_FLAVOR 100
#endif
#ifndef RESEARCH_RP_PRICE_FLAVOR
#define RESEARCH_RP_PRICE_FLAVOR 100
#endif
#ifndef ARTEFACT_PRICE_FAVOR
#define ARTEFACT_PRICE_FAVOR 500
#endif

#ifndef COST_ARTEFACTS
#define COST_ARTEFACTS   5
#endif
#ifndef COST_ORG_T1
#define COST_ORG_T1      5
#endif
#ifndef COST_ORG_T2
#define COST_ORG_T2      5
#endif
#ifndef COST_ORG_T3
#define COST_ORG_T3      5
#endif
#ifndef COST_UNITY
#define COST_UNITY       5
#endif
#ifndef COST_TEN
#define COST_TEN         5
#endif
#ifndef COST_SHUNNED
#define COST_SHUNNED     5
#endif

#ifndef ORG_PRICE_T1
#define ORG_PRICE_T1 1000
#endif
#ifndef ORG_PRICE_T2
#define ORG_PRICE_T2 2000
#endif
#ifndef ORG_PRICE_T3
#define ORG_PRICE_T3 3000
#endif

/mob/living/carbon/human
	var/miracle_points = 0
	var/church_favor = 100000
	var/personal_research_points = 0
	var/unlocked_research_artefacts = FALSE
	var/unlocked_research_org_t1   = FALSE
	var	unlocked_research_org_t2   = FALSE
	var	unlocked_research_org_t3   = FALSE
	var	unlocked_research_unity    = FALSE
	var	unlocked_research_ten      = FALSE
	var	unlocked_research_shunned  = FALSE

var/global/list/divine_miracles_cache  = list()
var/global/list/inhumen_miracles_cache = list()
var/global/miracle_caches_built = FALSE

var/global/list/unity_miracles_list = list(
	/obj/effect/proc_holder/spell/invoked/mending,
	/obj/effect/proc_holder/spell/invoked/guidance,
	/obj/effect/proc_holder/spell/invoked/healingtouch
)

var/global/list/divine_patrons_index = list()
var/global/divine_patrons_built = FALSE

/proc/build_miracle_caches()
	if(miracle_caches_built) return
	build_cache_for_root(/datum/patron/divine,  divine_miracles_cache)
	build_cache_for_root(/datum/patron/inhumen, inhumen_miracles_cache)
	miracle_caches_built = TRUE

/proc/build_cache_for_root(root_type, list/cache)
	for(var/p_type in typesof(root_type))
		if(p_type == root_type) continue
		var/datum/patron/P = new p_type
		if(length(P.miracles))
			for(var/st in P.miracles)
				cache[st] = TRUE
		qdel(P)

/proc/is_patron_spell(datum/devotion/D, obj/effect/proc_holder/spell/S)
	if(!D || !D.patron || !length(D.patron.miracles))
		return FALSE
	return (S.type in D.patron.miracles)

/proc/is_divine_spell(obj/effect/proc_holder/spell/S)
	if(!miracle_caches_built) build_miracle_caches()
	return !!divine_miracles_cache[S.type]

/proc/is_inhumen_spell(obj/effect/proc_holder/spell/S)
	if(!miracle_caches_built) build_miracle_caches()
	return !!inhumen_miracles_cache[S.type]

/proc/status_yn(flag)
	if(flag)
		return "<span style='color:#2ecc71'>Unlocked</span>"
	return "<span style='color:#e67e22'>Locked</span>"

/proc/html_attr(t as text)
	if(!istext(t)) return ""
	var/s = "[t]"
	s = replacetext(s, "&", "&amp;")
	s = replacetext(s, "<", "&lt;")
	s = replacetext(s, ">", "&gt;")
	s = replacetext(s, "\"", "&quot;")
	s = replacetext(s, "'", "&#39;")
	return s

/proc/build_divine_patrons_index()
	if(divine_patrons_built) return
	for(var/p_type in typesof(/datum/patron/divine))
		if(p_type == /datum/patron/divine) continue
		var/datum/patron/P = new p_type
		if(P?.name)
			var/domain = ""
			if("domain" in P.vars) domain = "[P.vars["domain"]]"
			var/desc = ""
			if("desc" in P.vars) desc = "[P.vars["desc"]]"
			divine_patrons_index["[P.name]"] = list("path"=p_type, "domain"=domain, "desc"=desc)
		qdel(P)
	divine_patrons_built = TRUE

/obj/item/church_artefact
	name = "sacred artefact"
	desc = "A token blessed by a patron."
	var/patron_name = ""
	New(loc, p_name)
		..()
		if(istext(p_name))
			patron_name = p_name
			name = "Sacred Artefact of [p_name]"

/obj/effect/proc_holder/spell/self/learnmiracle
	name = "Miracles"
	desc = "Open miracle actions."
	overlay_state = "startmiracle"
	var/current_org_tab = "none"
	var/current_miracle_tab = "none"
	var/current_art_tab = "none"

/obj/effect/proc_holder/spell/self/learnmiracle/proc/do_learn_miracle(mob/user)
	if(!user || !user.mind) return
	var/mob/living/carbon/human/H = istype(user, /mob/living/carbon/human) ? user : null
	if(!H) return
	if(!HAS_TRAIT(user, TRAIT_CLERGY))
		to_chat(user, span_warning("Only clergy may contemplate new miracles."))
		return
	var/datum/devotion/D = H.devotion
	if(!D || !D.patron)
		to_chat(user, span_warning("Your faith has no patron."))
		return
	if(!miracle_caches_built) build_miracle_caches()
	var/tier = 0
	if(("clergy_learn_tier" in D.vars) && isnum(D.vars["clergy_learn_tier"]))
		tier = max(tier, D.vars["clergy_learn_tier"])
	if(H.unlocked_research_ten)
		tier = max(tier, 1)
	if(H.unlocked_research_shunned)
		tier = max(tier, 2)
	var/list/spell_types = list()
	if(length(D.patron.miracles))
		for(var/st in D.patron.miracles)
			spell_types[st] = TRUE
	if(H.unlocked_research_unity)
		for(var/st in unity_miracles_list)
			spell_types[st] = TRUE
	if(tier >= 1)
		for(var/st in divine_miracles_cache)
			spell_types[st] = TRUE
	if(tier >= 2)
		for(var/st in inhumen_miracles_cache)
			spell_types[st] = TRUE
	var/list/choices = list()
	for(var/st in spell_types)
		var/already = FALSE
		for(var/obj/effect/proc_holder/spell/K in user.mind.spell_list)
			if(K.type == st) { already = TRUE; break }
		if(already) continue
		var/obj/effect/proc_holder/spell/S = new st
		var/own     = is_patron_spell(D, S)
		var/divine  = is_divine_spell(S)
		var/inhumen = is_inhumen_spell(S)
		var/is_unity = (unity_miracles_list && unity_miracles_list.Find(st))
		var/allow = FALSE
		var/cost = 0
		if(is_unity && H.unlocked_research_unity)
			allow = TRUE
			cost = CLERIC_PRICE_DIVINE
		else
			switch(tier)
				if(0)
					if(own) { allow = TRUE; cost = CLERIC_PRICE_PATRON }
				if(1)
					if(own) { allow = TRUE; cost = CLERIC_PRICE_PATRON }
					else if(divine) { allow = TRUE; cost = CLERIC_PRICE_DIVINE }
				if(2)
					if(own) { allow = TRUE; cost = CLERIC_PRICE_PATRON }
					else if(divine) { allow = TRUE; cost = CLERIC_PRICE_DIVINE }
					else if(inhumen) { allow = TRUE; cost = CLERIC_PRICE_SHUNNED }
		if(!allow)
			qdel(S)
			continue
		choices["[S.name] ([cost])"] = list("type" = st, "cost" = cost, "desc" = S.desc, "name" = S.name)
		qdel(S)
	if(!choices.len)
		to_chat(user, span_warning("No miracles available to learn right now."))
		return
	var/left = max(0, H.miracle_points)
	var/pick = input(user, "Choose a miracle to learn. Miracle points left: [left]", "Learn a Miracle") as null|anything in choices
	if(!pick) return
	var/sel = choices[pick]
	var/typepath = sel["type"]
	var/calc_cost = sel["cost"]
	var/sname = sel["name"]
	var/sdesc = sel["desc"]
	if(calc_cost > H.miracle_points)
		to_chat(user, span_warning("Not enough miracle points."))
		return
	if(alert(user, "[sdesc]", "[sname]", "Learn", "Cancel") == "Cancel")
		return
	for(var/obj/effect/proc_holder/spell/K2 in user.mind.spell_list)
		if(K2.type == typepath)
			to_chat(user, span_warning("You already know this one!"))
			return
	H.miracle_points = max(0, H.miracle_points - calc_cost)
	var/obj/effect/proc_holder/spell/new_spell = new typepath
	user.mind.AddSpell(new_spell)
	to_chat(user, span_notice("You have learned [new_spell.name]."))
	return

/obj/effect/proc_holder/spell/self/learnmiracle/proc/open_research_ui(mob/user)
	var/mob/living/carbon/human/H = istype(user, /mob/living/carbon/human) ? user : null
	if(!H) return
	var/rp = H.personal_research_points
	var/fv = H.church_favor
	var/mp = H.miracle_points
	var/html = "<center><h3>Miracle Research</h3></center><hr>"
	html += "<b>Research Points:</b> [rp]<br>"
	html += "<b>Favor:</b> [fv]<br>"
	html += "<b>Miracle Points:</b> [mp]<br>"
	html += "<hr>"
	if(HAS_TRAIT(H, TRAIT_CLERGY))
		if(fv >= RESEARCH_RP_PRICE_FLAVOR)
			html += "<a href='?src=[REF(src)];buyrp=1'>Buy 1 RP ([RESEARCH_RP_PRICE_FLAVOR] Favor)</a><br>"
		else
			html += "<span style='color:#7f8c8d'>Buy 1 RP ([RESEARCH_RP_PRICE_FLAVOR] Favor)</span><br>"
		if(fv >= MIRACLE_MP_PRICE_FLAVOR)
			html += "<a href='?src=[REF(src)];buymp=1'>Buy 1 MP ([MIRACLE_MP_PRICE_FLAVOR] Favor)</a><br>"
		else
			html += "<span style='color:#7f8c8d'>Buy 1 MP ([MIRACLE_MP_PRICE_FLAVOR] Favor)</span><br>"
	else
		html += "<span style='color:#7f8c8d'>Only clergy can buy RP/MP.</span><br>"
	html += "<hr><b>Studies</b><br>"
	html += "<table width='100%' cellspacing='2' cellpadding='2'>"
	html += "<tr><th align='left'>Study</th><th width='110'>Status</th><th width='160'>Action</th></tr>"
	var/ca = COST_ARTEFACTS
	var/c1 = COST_ORG_T1
	var/c2 = COST_ORG_T2
	var/c3 = COST_ORG_T3
	var/cu = COST_UNITY
	var/ct = COST_TEN
	var/cs = COST_SHUNNED
	html += "<tr><td>Artefacts</td><td>[status_yn(H.unlocked_research_artefacts)]</td><td align='center'>"
	if(!H.unlocked_research_artefacts)
		if(rp >= ca)
			html += "<a href='?src=[REF(src)];unlock=artefacts'>Unlock ([ca] RP)</a>"
		else
			html += "<span style='color:#7f8c8d'>Unlock ([ca] RP)</span>"
	else
		html += "<span style='color:#7f8c8d'>—</span>"
	html += "</td></tr>"
	html += "<tr><td>Organs T1</td><td>[status_yn(H.unlocked_research_org_t1)]</td><td align='center'>"
	if(!H.unlocked_research_org_t1)
		if(rp >= c1)
			html += "<a href='?src=[REF(src)];unlock=org_t1'>Unlock ([c1] RP)</a>"
		else
			html += "<span style='color:#7f8c8d'>Unlock ([c1] RP)</span>"
	else
		html += "<span style='color:#7f8c8d'>—</span>"
	html += "</td></tr>"
	html += "<tr><td>Organs T2</td><td>[status_yn(H.unlocked_research_org_t2)]</td><td align='center'>"
	if(!H.unlocked_research_org_t2)
		if(rp >= c2)
			html += "<a href='?src=[REF(src)];unlock=org_t2'>Unlock ([c2] RP)</a>"
		else
			html += "<span style='color:#7f8c8d'>Unlock ([c2] RP)</span>"
	else
		html += "<span style='color:#7f8c8d'>—</span>"
	html += "</td></tr>"
	html += "<tr><td>Organs T3</td><td>[status_yn(H.unlocked_research_org_t3)]</td><td align='center'>"
	if(!H.unlocked_research_org_t3)
		if(rp >= c3)
			html += "<a href='?src=[REF(src)];unlock=org_t3'>Unlock ([c3] RP)</a>"
		else
			html += "<span style='color:#7f8c8d'>Unlock ([c3] RP)</span>"
	else
		html += "<span style='color:#7f8c8d'>—</span>"
	html += "</td></tr>"
	html += "<tr><td>Unity Miracles</td><td>[status_yn(H.unlocked_research_unity)]</td><td align='center'>"
	if(!H.unlocked_research_unity)
		if(rp >= cu)
			html += "<a href='?src=[REF(src)];unlock=unity'>Unlock ([cu] RP)</a>"
		else
			html += "<span style='color:#7f8c8d'>Unlock ([cu] RP)</span>"
	else
		html += "<span style='color:#7f8c8d'>—</span>"
	html += "</td></tr>"
	html += "<tr><td>Ten Miracles</td><td>[status_yn(H.unlocked_research_ten)]</td><td align='center'>"
	if(!H.unlocked_research_ten)
		if(rp >= ct)
			html += "<a href='?src=[REF(src)];unlock=ten'>Unlock ([ct] RP)</a>"
		else
			html += "<span style='color:#7f8c8d'>Unlock ([ct] RP)</span>"
	else
		html += "<span style='color:#7f8c8d'>—</span>"
	html += "</td></tr>"
	html += "<tr><td>Shunned Miracles</td><td>[status_yn(H.unlocked_research_shunned)]</td><td align='center'>"
	if(!H.unlocked_research_shunned)
		if(rp >= cs)
			html += "<a href='?src=[REF(src)];unlock=shunned'>Unlock ([cs] RP)</a>"
		else
			html += "<span style='color:#7f8c8d'>Unlock ([cs] RP)</span>"
	else
		html += "<span style='color:#7f8c8d'>—</span>"
	html += "</td></tr>"
	html += "</table>"
	if(H.unlocked_research_artefacts)
		build_divine_patrons_index()
		if(divine_patrons_index && divine_patrons_index.len)
			html += "<hr><b>Artefacts</b><br>"
			var/list/nav = list()
			if(src.current_art_tab == "none")
				nav += "<b>None</b>"
			else
				nav += "<a href='?src=[REF(src)];arttab=none'>None</a>"
			var/list/names = list()
			for(var/n in divine_patrons_index)
				names += "[n]"
			names = sortList(names)
			for(var/n in names)
				if(src.current_art_tab == "[n]")
					nav += "<b>[n]</b>"
				else
					nav += "<a href='?src=[REF(src)];arttab=[n]'>[n]</a>"
			html += jointext(nav, " | ")
			html += "<br><br>"
			if(src.current_art_tab == "none")
				html += "<i>Artefacts list hidden (None).</i>"
			else
				var/rec2 = divine_patrons_index[src.current_art_tab]
				if(rec2)
					var/domain2 = "[rec2["domain"]]"
					var/desc2 = "[rec2["desc"]]"
					html += "<b>[src.current_art_tab]</b><br>"
					if(length(domain2)) html += "<i>[domain2]</i><br>"
					if(length(desc2)) html += "<div style='color:#7f8c8d'>[desc2]</div>"
					html += "<br>"
					if(HAS_TRAIT(H, TRAIT_CLERGY))
						if(H.church_favor >= ARTEFACT_PRICE_FAVOR)
							html += "<a href='?src=[REF(src)];buyart=[src.current_art_tab]'>Buy Artefact ([ARTEFACT_PRICE_FAVOR] Favor)</a>"
						else
							html += "<span style='color:#7f8c8d'>Buy Artefact ([ARTEFACT_PRICE_FAVOR] Favor)</span>"
					else
						html += "<span style='color:#7f8c8d'>Only clergy may buy artefacts.</span>"
				else
					html += "<i>Patron not found.</i>"
	if(H.unlocked_research_unity || H.unlocked_research_ten || H.unlocked_research_shunned)
		html += "<hr><b>Miracle Lists</b><br>"
		var/list/nav_bits = list()
		if(src.current_miracle_tab == "none")
			nav_bits += "<b>None</b>"
		else
			nav_bits += "<a href='?src=[REF(src)];mirtab=none'>None</a>"
		if(H.unlocked_research_unity)
			if(src.current_miracle_tab == "unity")
				nav_bits += "<b>Unity</b>"
			else
				nav_bits += "<a href='?src=[REF(src)];mirtab=unity'>Unity</a>"
		else
			nav_bits += "<span style='color:#7f8c8d'>Unity</span>"
		if(H.unlocked_research_ten)
			if(src.current_miracle_tab == "ten")
				nav_bits += "<b>Ten</b>"
			else
				nav_bits += "<a href='?src=[REF(src)];mirtab=ten'>Ten</a>"
		else
			nav_bits += "<span style='color:#7f8c8d'>Ten</span>"
		if(H.unlocked_research_shunned)
			if(src.current_miracle_tab == "shunned")
				nav_bits += "<b>Shunned</b>"
			else
				nav_bits += "<a href='?src=[REF(src)];mirtab=shunned'>Shunned</a>"
		else
			nav_bits += "<span style='color:#7f8c8d'>Shunned</span>"
		html += jointext(nav_bits, " | ")
		html += "<br><br>"
		if(src.current_miracle_tab != "none")
			if(!miracle_caches_built) build_miracle_caches()
			var/list/to_show = list()
			var/tab_title = ""
			if(src.current_miracle_tab == "unity" && H.unlocked_research_unity)
				tab_title = "Unity Miracles"
				for(var/st in unity_miracles_list)
					to_show += st
			else if(src.current_miracle_tab == "ten" && H.unlocked_research_ten)
				tab_title = "Ten Miracles"
				for(var/st in divine_miracles_cache)
					to_show += st
			else if(src.current_miracle_tab == "shunned" && H.unlocked_research_shunned)
				tab_title = "Shunned Miracles"
				for(var/st in inhumen_miracles_cache)
					to_show += st
			if(to_show.len)
				html += "<b>[tab_title]</b><br>"
				html += "<table width='100%' cellspacing='2' cellpadding='2'>"
				html += "<tr><th align='left'>Miracle</th><th width='120'>Status</th></tr>"
				for(var/st in to_show)
					var/name_txt = "[st]"
					var/known = FALSE
					var/obj/effect/proc_holder/spell/T = new st
					if(T)
						name_txt = T.name
						for(var/obj/effect/proc_holder/spell/K in H.mind.spell_list)
							if(K.type == st) { known = TRUE; break }
						qdel(T)
					html += "<tr><td>[name_txt]</td><td>"
					if(known)
						html += "<span style='color:#2ecc71'>Known</span>"
					else
						html += "<span style='color:#7f8c8d'>Unknown</span>"
					html += "</td></tr>"
				html += "</table>"
			else
				html += "<i>No miracles found for this tab.</i>"
		else
			html += "<i>Miracle list hidden (None).</i>"
	if(H.unlocked_research_org_t1 || H.unlocked_research_org_t2 || H.unlocked_research_org_t3)
		html += "<hr><b>Organs</b><br>"
		var/list/org_tabs = list()
		if(src.current_org_tab == "none")
			org_tabs += "<b>None</b>"
		else
			org_tabs += "<a href='?src=[REF(src)];orgtab=none'>None</a>"
		if(src.current_org_tab == "t1")
			org_tabs += "<b>T1</b>"
		else
			if(H.unlocked_research_org_t1) org_tabs += "<a href='?src=[REF(src)];orgtab=t1'>T1</a>"
			else org_tabs += "<span style='color:#7f8c8d'>T1</span>"
		if(src.current_org_tab == "t2")
			org_tabs += "<b>T2</b>"
		else
			if(H.unlocked_research_org_t2) org_tabs += "<a href='?src=[REF(src)];orgtab=t2'>T2</a>"
			else org_tabs += "<span style='color:#7f8c8d'>T2</span>"
		if(src.current_org_tab == "t3")
			org_tabs += "<b>T3</b>"
		else
			if(H.unlocked_research_org_t3) org_tabs += "<a href='?src=[REF(src)];orgtab=t3'>T3</a>"
			else org_tabs += "<span style='color:#7f8c8d'>T3</span>"
		html += jointext(org_tabs, " | ")
		html += "<br><br>"
		if(src.current_org_tab == "none")
			html += "<i>Organs list hidden (None).</i>"
		else
			var/list/org_labels = list("Eyes","Stomach","Liver","Heart","Lungs")
			html += "<table width='100%' cellspacing='2' cellpadding='2'>"
			html += "<tr><th align='left'>Item</th><th width='160'>Action</th></tr>"
			for(var/label in org_labels)
				var/tier_key = src.current_org_tab
				var/can_buy = FALSE
				var/price = 0
				if(tier_key == "t1")
					can_buy = H.unlocked_research_org_t1
					price = ORG_PRICE_T1
				else if(tier_key == "t2")
					can_buy = H.unlocked_research_org_t2
					price = ORG_PRICE_T2
				else if(tier_key == "t3")
					can_buy = H.unlocked_research_org_t3
					price = ORG_PRICE_T3
				html += "<tr><td>[label] ([uppertext(tier_key)])</td><td align='center'>"
				if(HAS_TRAIT(H, TRAIT_CLERGY) && can_buy)
					if(H.church_favor >= price)
						html += "<a href='?src=[REF(src)];buyorg=[tier_key];item=[lowertext(label)]'>Spawn ([price] Favor)</a>"
					else
						html += "<span style='color:#7f8c8d'>Spawn ([price] Favor)</span>"
				else
					html += "<span style='color:#7f8c8d'>Spawn ([price] Favor)</span>"
				html += "</td></tr>"
			html += "</table>"
	var/datum/browser/B = new(user, "MIRACLE_RESEARCH", "", 560, 760)
	B.set_content(html)
	B.open()

/obj/effect/proc_holder/spell/self/learnmiracle/Topic(href, href_list)
	. = ..()
	if(!usr || !istype(usr, /mob/living/carbon/human)) return
	var/mob/living/carbon/human/H = usr
	if(href_list["arttab"])
		var/tbA = href_list["arttab"]
		if(tbA == "none")
			src.current_art_tab = "none"
		else
			build_divine_patrons_index()
			if(divine_patrons_index && (tbA in divine_patrons_index))
				src.current_art_tab = "[tbA]"
			else
				src.current_art_tab = "none"
		open_research_ui(H); return
	if(href_list["mirtab"])
		var/tb = lowertext(href_list["mirtab"])
		if(tb == "unity" && H.unlocked_research_unity)
			src.current_miracle_tab = "unity"
		else if(tb == "ten" && H.unlocked_research_ten)
			src.current_miracle_tab = "ten"
		else if(tb == "shunned" && H.unlocked_research_shunned)
			src.current_miracle_tab = "shunned"
		else if(tb == "none")
			src.current_miracle_tab = "none"
		else
			src.current_miracle_tab = "none"
		open_research_ui(H); return
	if(href_list["orgtab"])
		var/tb2 = lowertext(href_list["orgtab"])
		if(tb2 == "t1" || tb2 == "t2" || tb2 == "t3")
			src.current_org_tab = tb2
		else if(tb2 == "none")
			src.current_org_tab = "none"
		else
			src.current_org_tab = "none"
		open_research_ui(H); return
	if(href_list["buyart"])
		if(!HAS_TRAIT(H, TRAIT_CLERGY)) { open_research_ui(H); return }
		var/god = href_list["buyart"]
		build_divine_patrons_index()
		if(!(god in divine_patrons_index)) { open_research_ui(H); return }
		if(H.church_favor < ARTEFACT_PRICE_FAVOR) { open_research_ui(H); return }
		if(alert(H, "Buy artefact of [god] for [ARTEFACT_PRICE_FAVOR] Favor?", "Confirm", "Buy", "Cancel") != "Buy")
			open_research_ui(H); return
		var/turf/T1 = get_step(H, H.dir); if(!T1) T1 = get_turf(H)
		new /obj/item/church_artefact(T1, god)
		H.church_favor = max(0, H.church_favor - ARTEFACT_PRICE_FAVOR)
		to_chat(H, span_notice("You acquired a Sacred Artefact of [god]."))
		open_research_ui(H); return
	if(href_list["buyorg"])
		if(!HAS_TRAIT(H, TRAIT_CLERGY)) { open_research_ui(H); return }
		var/tier = lowertext(href_list["buyorg"])
		var/label = lowertext(href_list["item"])
		if(!(label in list("eyes","stomach","liver","heart","lungs"))) { open_research_ui(H); return }
		var/unlocked = FALSE
		var/price = 0
		if(tier == "t1")
			unlocked = H.unlocked_research_org_t1
			price = ORG_PRICE_T1
		else if(tier == "t2")
			unlocked = H.unlocked_research_org_t2
			price = ORG_PRICE_T2
		else if(tier == "t3")
			unlocked = H.unlocked_research_org_t3
			price = ORG_PRICE_T3
		else
			open_research_ui(H); return
		if(!unlocked) { open_research_ui(H); return }
		if(H.church_favor < price) { open_research_ui(H); return }
		var/path_text = "/obj/item/organ/[label]/[tier]"
		var/typepath = text2path(path_text)
		if(!typepath)
			to_chat(H, span_warning("Organ type not found: [path_text]"))
			open_research_ui(H); return
		var/turf/T = get_step(H, H.dir); if(!T) T = get_turf(H)
		new typepath(T)
		H.church_favor = max(0, H.church_favor - price)
		to_chat(H, span_notice("[capitalize(label)] [uppertext(tier)] spawned for [price] Favor."))
		open_research_ui(H); return
	if(href_list["buyrp"])
		if(!HAS_TRAIT(H, TRAIT_CLERGY)) { open_research_ui(H); return }
		if(H.church_favor < RESEARCH_RP_PRICE_FLAVOR) { open_research_ui(H); return }
		H.church_favor = max(0, H.church_favor - RESEARCH_RP_PRICE_FLAVOR)
		H.personal_research_points++
		to_chat(H, span_notice("You gained +1 Research Point."))
		open_research_ui(H); return
	if(href_list["buymp"])
		if(!HAS_TRAIT(H, TRAIT_CLERGY)) { open_research_ui(H); return }
		if(H.church_favor < MIRACLE_MP_PRICE_FLAVOR) { open_research_ui(H); return }
		H.church_favor = max(0, H.church_favor - MIRACLE_MP_PRICE_FLAVOR)
		H.miracle_points++
		to_chat(H, span_notice("You gained +1 Miracle Point."))
		open_research_ui(H); return
	if(href_list["unlock"])
		var/key = lowertext(href_list["unlock"])
		var/need = 0
		if(key == "artefacts") need = COST_ARTEFACTS
		else if(key == "org_t1") need = COST_ORG_T1
		else if(key == "org_t2") need = COST_ORG_T2
		else if(key == "org_t3") need = COST_ORG_T3
		else if(key == "unity")  need = COST_UNITY
		else if(key == "ten")    need = COST_TEN
		else if(key == "shunned") need = COST_SHUNNED
		else { open_research_ui(H); return }
		if(H.personal_research_points < need) { open_research_ui(H); return }
		H.personal_research_points = max(0, H.personal_research_points - need)
		if(key == "artefacts")
			H.unlocked_research_artefacts = TRUE
			if(src.current_art_tab == "none") src.current_art_tab = "none"
		else if(key == "org_t1")
			H.unlocked_research_org_t1 = TRUE
			if(src.current_org_tab == "none") src.current_org_tab = "t1"
		else if(key == "org_t2")
			H.unlocked_research_org_t2 = TRUE
			if(src.current_org_tab == "none") src.current_org_tab = "t2"
		else if(key == "org_t3")
			H.unlocked_research_org_t3 = TRUE
			if(src.current_org_tab == "none") src.current_org_tab = "t3"
		else if(key == "unity")
			H.unlocked_research_unity = TRUE
			if(src.current_miracle_tab == "none") src.current_miracle_tab = "unity"
		else if(key == "ten")
			H.unlocked_research_ten = TRUE
			if(src.current_miracle_tab == "none") src.current_miracle_tab = "ten"
		else if(key == "shunned")
			H.unlocked_research_shunned = TRUE
			if(src.current_miracle_tab == "none") src.current_miracle_tab = "shunned"
		to_chat(H, span_notice("Study unlocked: [key]."))
		open_research_ui(H); return

/obj/effect/proc_holder/spell/self/learnmiracle/cast(list/targets, mob/user)
	if(!..()) return
	if(!user) return
	var/list/rad = list()
	rad["Learn"]    = icon(icon = MIRACLE_RADIAL_DMI, icon_state = "learnmiracle")
	rad["Upgrade"]  = icon(icon = MIRACLE_RADIAL_DMI, icon_state = "upgrademiracle")
	rad["Quests"]   = icon(icon = MIRACLE_RADIAL_DMI, icon_state = "questmiracle")
	rad["Research"] = icon(icon = MIRACLE_RADIAL_DMI, icon_state = "researchmiracle")
	var/choice = show_radial_menu(user, user, rad, require_near = FALSE)
	if(choice == "Learn")
		do_learn_miracle(user)
	else if(choice == "Research")
		open_research_ui(user)
	return
