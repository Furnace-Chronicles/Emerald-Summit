//=========================================================================
// research.dm
//=========================================================================

#undef  MIRACLE_RADIAL_DMI
#define MIRACLE_RADIAL_DMI 'icons/mob/actions/roguespells.dmi'

#ifndef QUEST_COOLDOWN_DS
#define QUEST_COOLDOWN_DS (30*60*10)
#endif

#ifndef QUEST_REWARD_FAVOR
#define QUEST_REWARD_FAVOR 250
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
#define ORG_PRICE_T1 500
#endif
#ifndef ORG_PRICE_T2
#define ORG_PRICE_T2 1000
#endif
#ifndef ORG_PRICE_T3
#define ORG_PRICE_T3 1500
#endif

// --------------------------------------------
// MOBS
// -----------------------

/mob/living/carbon/human
	var/miracle_points = 0
	var/church_favor = 0
	var/personal_research_points = 0

	var/unlocked_research_artefacts = FALSE
	var/unlocked_research_org_t1   = FALSE
	var/unlocked_research_org_t2   = FALSE
	var/unlocked_research_org_t3   = FALSE
	var/unlocked_research_unity    = FALSE
	var/unlocked_research_ten      = FALSE
	var/unlocked_research_shunned  = FALSE

	var/list/quest_ui_entries = null

	var/quest_reroll_ready_at = 0


var/global/list/divine_miracles_cache  = list()
var/global/list/inhumen_miracles_cache = list()
var/global/miracle_caches_built = FALSE

var/global/list/unity_miracles_list = list(
	/obj/effect/proc_holder/spell/invoked/mending,
	/obj/effect/proc_holder/spell/invoked/guidance,
	/obj/effect/proc_holder/spell/invoked/healingtouch,
	/obj/effect/proc_holder/spell/targeted/shapeshift/crow,
	/obj/effect/proc_holder/spell/invoked/projectile/divineblast
)

var/global/list/divine_patrons_index = list()
var/global/divine_patrons_built = FALSE

var/global/list/PATRON_ARTIFACTS = list(
	"Astrata" = list(/obj/item/artifact/astrata_star),
	"Noc"     = list(/obj/item/artefact/noc_phylactery),
	"Dendor"  = list(/obj/item/artefact/dendor_hose),
	"Abyssor" = list(/obj/item/fishingrod/abyssoid),
	"Ravox"   = list(/obj/item/artifact/ravox_lens),
	"Necra"   = list(/obj/item/artefact/necra_censer),
	"Xylix"   = list(/obj/item/clothing/gloves/xylix),
	"Pestra"  = list(/obj/item/rogueweapon/surgery/multitool),
	"Malum"   = list(/obj/item/rogueweapon/hammer/artefact/malum),
	"Eora"    = list(/obj/item/artefact/eora_heart),
)


/proc/build_miracle_caches()
	if(miracle_caches_built)
		return
	build_cache_for_root(/datum/patron/divine,  divine_miracles_cache)
	build_cache_for_root(/datum/patron/inhumen, inhumen_miracles_cache)
	miracle_caches_built = TRUE

/proc/build_cache_for_root(root_type, list/cache)
	for(var/p_type in typesof(root_type))
		if(p_type == root_type) continue
		var/datum/patron/P = new p_type
		if(P && length(P.miracles))
			for(var/st in P.miracles)
				cache[st] = TRUE
		qdel(P)

/proc/is_patron_spell(datum/devotion/D, obj/effect/proc_holder/spell/S)
	if(!D || !D.patron || !length(D.patron.miracles))
		return FALSE
	return (S.type in D.patron.miracles)

/proc/is_divine_spell(obj/effect/proc_holder/spell/S)
	if(!miracle_caches_built)
		build_miracle_caches()
	return !!divine_miracles_cache[S.type]

/proc/is_inhumen_spell(obj/effect/proc_holder/spell/S)
	if(!miracle_caches_built)
		build_miracle_caches()
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
		if(P && P.name)
			var/domain = ""
			if("domain" in P.vars)
				domain = "[P.vars["domain"]]"
			var/desc = ""
			if("desc" in P.vars)
				desc = "[P.vars["desc"]]"

			divine_patrons_index["[P.name]"] = list(
				"path"   = p_type,
				"domain" = domain,
				"desc"   = desc
			)
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

	if(!miracle_caches_built)
		build_miracle_caches()

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
			if(K.type == st)
				already = TRUE
				break
		if(already) continue

		var/obj/effect/proc_holder/spell/S = new st

		var/own      = is_patron_spell(D, S)
		var/divine   = is_divine_spell(S)
		var/inhumen  = is_inhumen_spell(S)
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
					if(own)        { allow = TRUE; cost = CLERIC_PRICE_PATRON }
					else if(divine){ allow = TRUE; cost = CLERIC_PRICE_DIVINE }
				if(2)
					if(own)         { allow = TRUE; cost = CLERIC_PRICE_PATRON }
					else if(divine) { allow = TRUE; cost = CLERIC_PRICE_DIVINE }
					else if(inhumen){ allow = TRUE; cost = CLERIC_PRICE_SHUNNED }

		if(!allow)
			qdel(S)
			continue

		choices["[S.name] ([cost])"] = list(
			"type" = st,
			"cost" = cost,
			"desc" = S.desc,
			"name" = S.name
		)

		qdel(S)

	if(!choices.len)
		to_chat(user, span_warning("No miracles available to learn right now."))
		return

	var/left = max(0, H.miracle_points)
	var/pick = input(user, "Choose a miracle to learn. Miracle points left: [left]", "Learn a Miracle") as null|anything in choices
	if(!pick) return

	var/sel = choices[pick]
	var/typepath  = sel["type"]
	var/calc_cost = sel["cost"]
	var/sname     = sel["name"]
	var/sdesc     = sel["desc"]

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


// -----------------------------------------------------
// ОКНО RESEARCH UI 
// ---------------------------------------------------------

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

	// Artefacts
	html += "<tr><td>Artefacts</td><td>[status_yn(H.unlocked_research_artefacts)]</td><td align='center'>"
	if(!H.unlocked_research_artefacts)
		if(rp >= ca)	html += "<a href='?src=[REF(src)];unlock=artefacts'>Unlock ([ca] RP)</a>"
		else			html += "<span style='color:#7f8c8d'>Unlock ([ca] RP)</span>"
	else
		html += "<span style='color:#7f8c8d'>—</span>"
	html += "</td></tr>"

	// T1
	html += "<tr><td>Organs T1</td><td>[status_yn(H.unlocked_research_org_t1)]</td><td align='center'>"
	if(!H.unlocked_research_org_t1)
		if(rp >= c1)	html += "<a href='?src=[REF(src)];unlock=org_t1'>Unlock ([c1] RP)</a>"
		else			html += "<span style='color:#7f8c8d'>Unlock ([c1] RP)</span>"
	else
		html += "<span style='color:#7f8c8d'>—</span>"
	html += "</td></tr>"

	// T2
	html += "<tr><td>Organs T2</td><td>[status_yn(H.unlocked_research_org_t2)]</td><td align='center'>"
	if(!H.unlocked_research_org_t2)
		if(rp >= c2)	html += "<a href='?src=[REF(src)];unlock=org_t2'>Unlock ([c2] RP)</a>"
		else			html += "<span style='color:#7f8c8d'>Unlock ([c2] RP)</span>"
	else
		html += "<span style='color:#7f8c8d'>—</span>"
	html += "</td></tr>"

	// T3
	html += "<tr><td>Organs T3</td><td>[status_yn(H.unlocked_research_org_t3)]</td><td align='center'>"
	if(!H.unlocked_research_org_t3)
		if(rp >= c3)	html += "<a href='?src=[REF(src)];unlock=org_t3'>Unlock ([c3] RP)</a>"
		else			html += "<span style='color:#7f8c8d'>Unlock ([c3] RP)</span>"
	else
		html += "<span style='color:#7f8c8d'>—</span>"
	html += "</td></tr>"

	// Unity / Ten / Shunned
	html += "<tr><td>Unity Miracles</td><td>[status_yn(H.unlocked_research_unity)]</td><td align='center'>"
	if(!H.unlocked_research_unity)
		if(rp >= cu)	html += "<a href='?src=[REF(src)];unlock=unity'>Unlock ([cu] RP)</a>"
		else			html += "<span style='color:#7f8c8d'>Unlock ([cu] RP)</span>"
	else
		html += "<span style='color:#7f8c8d'>—</span>"
	html += "</td></tr>"

	html += "<tr><td>Ten Miracles</td><td>[status_yn(H.unlocked_research_ten)]</td><td align='center'>"
	if(!H.unlocked_research_ten)
		if(rp >= ct)	html += "<a href='?src=[REF(src)];unlock=ten'>Unlock ([ct] RP)</a>"
		else			html += "<span style='color:#7f8c8d'>Unlock ([ct] RP)</span>"
	else
		html += "<span style='color:#7f8c8d'>—</span>"
	html += "</td></tr>"

	html += "<tr><td>Shunned Miracles</td><td>[status_yn(H.unlocked_research_shunned)]</td><td align='center'>"
	if(!H.unlocked_research_shunned)
		if(rp >= cs)	html += "<a href='?src=[REF(src)];unlock=shunned'>Unlock ([cs] RP)</a>"
		else			html += "<span style='color:#7f8c8d'>Unlock ([cs] RP)</span>"
	else
		html += "<span style='color:#7f8c8d'>—</span>"
	html += "</td></tr>"

	html += "</table>"

	// -- ---- Artefactss---
	if(H.unlocked_research_artefacts)
		build_divine_patrons_index()
		if(divine_patrons_index && length(divine_patrons_index))
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

			html += jointext(nav, " | ") + "<br><br>"

			if(src.current_art_tab == "none")
				html += "<i>Artefacts list hidden (None).</i>"
			else
				var/rec2 = divine_patrons_index[src.current_art_tab]
				if(rec2)
					var/domain2 = "[rec2["domain"]]"
					var/desc2   = "[rec2["desc"]]"

					html += "<b>[src.current_art_tab]</b><br>"
					if(length(domain2))
						html += "<i>[domain2]</i><br>"
					if(length(desc2))
						html += "<div style='color:#7f8c8d'>[desc2]</div>"
					html += "<br>"

					var/list/art_list = PATRON_ARTIFACTS ? PATRON_ARTIFACTS[src.current_art_tab] : null
					if(islist(art_list) && art_list.len)
						html += "<table width='100%' cellspacing='2' cellpadding='2'>"
						html += "<tr><th align='left'>Artefact</th><th width='160'>Action</th></tr>"
						for(var/T in art_list)
							var/name_txt = "[T]"
							var/tmp/obj/O = new T
							if(O && length(O.name))
								name_txt = O.name
							if(O) qdel(O)

							html += "<tr><td>[html_attr(name_txt)]</td><td align='center'>"
							if(HAS_TRAIT(H, TRAIT_CLERGY))
								if(H.church_favor >= ARTEFACT_PRICE_FAVOR)
									html += "<a href='?src=[REF(src)];buyart=[src.current_art_tab];item=[T]'>Buy ([ARTEFACT_PRICE_FAVOR] Favor)</a>"
								else
									html += "<span style='color:#7f8c8d'>Buy ([ARTEFACT_PRICE_FAVOR] Favor)</span>"
							else
								html += "<span style='color:#7f8c8d'>Only clergy may buy artefacts.</span>"
							html += "</td></tr>"

						html += "</table>"
					else
						html += "<i>No artefacts listed for this patron.</i>"

	// ----- Miracles tabs -----
	if(H.unlocked_research_unity || H.unlocked_research_ten || H.unlocked_research_shunned)
		html += "<hr><b>Miracle Lists</b><br>"

		var/list/nav_bits = list()
		if(src.current_miracle_tab == "none")
			nav_bits += "<b>None</b>"
		else
			nav_bits += "<a href='?src=[REF(src)];mirtab=none'>None</a>"

		if(H.unlocked_research_unity)
			nav_bits += (src.current_miracle_tab == "unity") ? "<b>Unity</b>" : "<a href='?src=[REF(src)];mirtab=unity'>Unity</a>"
		else
			nav_bits += "<span style='color:#7f8c8d'>Unity</span>"

		if(H.unlocked_research_ten)
			nav_bits += (src.current_miracle_tab == "ten") ? "<b>Ten</b>" : "<a href='?src=[REF(src)];mirtab=ten'>Ten</a>"
		else
			nav_bits += "<span style='color:#7f8c8d'>Ten</span>"

		if(H.unlocked_research_shunned)
			nav_bits += (src.current_miracle_tab == "shunned") ? "<b>Shunned</b>" : "<a href='?src=[REF(src)];mirtab=shunned'>Shunned</a>"
		else
			nav_bits += "<span style='color:#7f8c8d'>Shunned</span>"

		html += jointext(nav_bits, " | ") + "<br><br>"

		if(src.current_miracle_tab != "none")
			if(!miracle_caches_built)
				build_miracle_caches()

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
				html += "<b>[tab_title]</b><br><table width='100%' cellspacing='2' cellpadding='2'>"
				html += "<tr><th align='left'>Miracle</th><th width='120'>Status</th></tr>"
				for(var/st in to_show)
					var/name_txt = "[st]"
					var/known = FALSE
					var/obj/effect/proc_holder/spell/T = new st
					if(T)
						name_txt = T.name
						for(var/obj/effect/proc_holder/spell/K in H.mind.spell_list)
							if(K.type == st)
								known = TRUE
								break
						qdel(T)

					html += "<tr><td>[name_txt]</td><td>" + (known ? "<span style='color:#2ecc71'>Known</span>" : "<span style='color:#7f8c8d'>Unknown</span>") + "</td></tr>"
				html += "</table>"
			else
				html += "<i>No miracles found for this tab.</i>"
		else
			html += "<i>Miracle list hidden (None).</i>"

	if(H.unlocked_research_org_t1 || H.unlocked_research_org_t2 || H.unlocked_research_org_t3)
		html += "<hr><b>Organs</b><br>"

		var/list/org_tabs = list()
		org_tabs += (src.current_org_tab == "none") ? "<b>None</b>" : "<a href='?src=[REF(src)];orgtab=none'>None</a>"
		org_tabs += (src.current_org_tab == "t1") ? "<b>T1</b>" : (H.unlocked_research_org_t1 ? "<a href='?src=[REF(src)];orgtab=t1'>T1</a>" : "<span style='color:#7f8c8d'>T1</span>")
		org_tabs += (src.current_org_tab == "t2") ? "<b>T2</b>" : (H.unlocked_research_org_t2 ? "<a href='?src=[REF(src)];orgtab=t2'>T2</a>" : "<span style='color:#7f8c8d'>T2</span>")
		org_tabs += (src.current_org_tab == "t3") ? "<b>T3</b>" : (H.unlocked_research_org_t3 ? "<a href='?src=[REF(src)];orgtab=t3'>T3</a>" : "<span style='color:#7f8c8d'>T3</span>")

		html += jointext(org_tabs, " | ")
		html += "<br><br>"
// organ tabs done
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


// -----------------------------------------------------

// QUESTS BUT NOT TOKENS FLUFF TOP ШАПКА 

// -------------------------------------------------------------

/obj/effect/proc_holder/spell/self/learnmiracle/proc/open_quests_ui(mob/user)
	var/mob/living/carbon/human/H = istype(user, /mob/living/carbon/human) ? user : null
	if(!H) return

	var/init_needed = TRUE
	if(islist(H.quest_ui_entries))
		if(H.quest_ui_entries.len >= 1)
			init_needed = FALSE

	if(init_needed)
		H.quest_ui_entries = _rt_build_player_quest_set(H)
		if(!H.quest_reroll_ready_at)
			H.quest_reroll_ready_at = world.time + QUEST_COOLDOWN_DS

	var/can_reroll = (world.time >= H.quest_reroll_ready_at)
	var/left_ds = can_reroll ? 0 : max(0, H.quest_reroll_ready_at - world.time)
	var/left_s  = round(left_ds / 10)
	var/mins    = left_s / 60
	var/secs    = left_s % 60
	var/secs_str = (secs < 10) ? "0[secs]" : "[secs]"

	var/html = "<center><h3 style='color:#3498db;margin:6px 0;'>Miracle Quests</h3>"

	if(can_reroll)
		html += "<div style='margin-top:6px;'><a href='?src=[REF(src)];q_reroll=1' style='background:#8e44ad;color:#fff;padding:3px 8px;border-radius:6px;text-decoration:none;'><b>Reroll</b></a></div>"
	else
		html += "<div style='margin-top:6px;color:#9b59b6;'>Reroll available in: <b>[mins]:[secs_str]</b></div>"

	html += "<div style='color:#e74c3c; text-align:center; margin:6px 0;'>"
	html += "<b>How it works:</b><br>"
	html += "You get three different quest themes.<br>"
	html += "Each quest can have <u>Easy / Medium / Hard</u> variants, or just one special task.<br>"
	html += "When you click <b>Get special item</b> on one row, you lock that quest to that difficulty and receive a quest item.<br>"
	html += "Other rows for that quest lock until reroll.<br>"
	html += "Use the item under listed conditions to gain Favor. The item self-destructs in ~3 minutes."
	html += "</div></center><hr>"

	for(var/i = 1, i <= (H.quest_ui_entries?.len || 0), i++)
		var/list/slot = H.quest_ui_entries[i]
		if(!islist(slot)) continue

		var/quest_title = "[slot["title"]]"
		var/accepted_diff = slot["accepted_diff"]
		if(!istext(accepted_diff))
			accepted_diff = ""

		html += "<div style='padding:10px;'>"
		html += "<center><b style='font-size:14px; color:#ecf0f1; background:#34495e; padding:2px 8px; border-radius:6px;'>[quest_title]</b></center>"
		html += "<br>"

		html += "<table width='100%' cellspacing='2' cellpadding='2' style='text-align:center;'>"
		html += "<tr style='background:#2c3e50;color:#ecf0f1;'><th>Difficulty</th><th>Task</th><th>Reward</th><th>Action</th></tr>"

		var/list/diffs = slot["difficulties"]
		if(islist(diffs))
			var/list/diff_order = list()
			if("easy" in diffs)   diff_order += "easy"
			if("medium" in diffs) diff_order += "medium"
			if("hard" in diffs)   diff_order += "hard"
			for(var/other in diffs)
				if(!(other in diff_order))
					diff_order += other

			for(var/diff_key in diff_order)
				if(!(diff_key in diffs)) continue
				var/list/D = diffs[diff_key]
				if(!islist(D)) continue

				var/diff_label = uppertext("[diff_key]")
				var/desc_txt   = "[D["desc"]]"
				var/reward_txt = "[D["reward"]]"
				var/spawned    = D["spawned"]

				var/locked = (length(accepted_diff) && (accepted_diff != diff_key))

				html += "<tr>"
				html += "<td><b>[diff_label]</b></td>"
				html += "<td>[desc_txt]</td>"
				html += "<td style='color:#2ecc71'><b>[reward_txt]</b> Favor</td>"
				html += "<td>"

				if(locked)
					html += "<span style='display:inline-block; padding:4px 10px; border-radius:6px; background:#7f8c8d; color:#ecf0f1;'>Locked</span>"
				else
					if(spawned)
						html += "<span style='display:inline-block; padding:4px 10px; border-radius:6px; background:#7f8c8d; color:#ecf0f1;'>Item spawned</span>"
					else
						html += "<a href='?src=[REF(src)];q_spawn=[i];diff=[diff_key]' style='display:inline-block; padding:4px 10px; border-radius:6px; background:#1abc9c; color:#ffffff; text-decoration:none;'>Get special item</a>"

				html += "</td>"
				html += "</tr>"

		html += "</table>"
		html += "</div>"

		if(i < (H.quest_ui_entries?.len || 0))
			html += "<hr style='border-color:#2c3e50;'>"

	var/datum/browser/B = new(user, "MIRACLE_QUESTS", "", 560, 760)
	B.set_content(html)
	B.open()

/obj/effect/proc_holder/spell/self/learnmiracle/proc/open_upgrade_ui(mob/user)
	if(!istype(user, /mob/living/carbon/human)) return
	var/mob/living/carbon/human/H = user

	var/has_diag = FALSE
	var/has_diag_g = FALSE

	if(H?.mind)
		for(var/obj/effect/proc_holder/spell/S in H.mind.spell_list)
			if(istype(S, /obj/effect/proc_holder/spell/invoked/diagnose))
				has_diag = TRUE
			if(istype(S, /obj/effect/proc_holder/spell/invoked/diagnose/greater))
				has_diag_g = TRUE

	var/html = "<center><h3>Upgrades</h3></center><hr>"
	html += "<b>Diagnose → Greater Diagnose</b><br>"

	if(has_diag_g)
		html += "<span style='color:#2ecc71'>Already upgraded.</span>"
	else if(has_diag)
		html += "<a href='?src=[REF(src)];upgrade_diag=1'>Upgrade now (free)</a>"
	else
		html += "<span style='color:#7f8c8d'>You must learn \"Diagnose\" first.</span>"

	var/datum/browser/B = new(user, "MIRACLE_UPGRADES", "", 420, 200)
	B.set_content(html)
	B.open()


// -------------------------------------------
// TOPIC()

//  UI (Research, Quests, Upgrade)
// --------------------------------------------------------

/obj/effect/proc_holder/spell/self/learnmiracle/Topic(href, href_list)
	. = ..()
	if(!usr || !istype(usr, /mob/living/carbon/human)) return

	var/mob/living/carbon/human/H = usr

	// ---------- GIVE QUEST ----------

	if(href_list["q_reroll"])
		if(world.time < H.quest_reroll_ready_at)
			var/left_ds2 = max(0, H.quest_reroll_ready_at - world.time)
			var/left_s2 = round(left_ds2 / 10)
			var/m2 = left_s2 / 60
			var/s2 = left_s2 % 60
			var/s2s = (s2 < 10) ? "0[s2]" : "[s2]"
			to_chat(H, span_warning("Reroll will be available in [m2]:[s2s]."))
			open_quests_ui(H)
			return

		H.quest_ui_entries = _rt_build_player_quest_set(H)
		H.quest_reroll_ready_at = world.time + QUEST_COOLDOWN_DS

		to_chat(H, span_notice("Quests rerolled."))
		open_quests_ui(H)
		return

	if(href_list["q_spawn"])
		var/q_index = text2num(href_list["q_spawn"])
		var/diff_key = lowertext(href_list["diff"])

		if(!isnum(q_index) || q_index < 1 || q_index > (H.quest_ui_entries?.len || 0))
			open_quests_ui(H)
			return

		var/list/slot = H.quest_ui_entries[q_index]
		if(!islist(slot))
			open_quests_ui(H)
			return

		var/list/diffs = slot["difficulties"]
		if(!islist(diffs) || !(diff_key in diffs))
			open_quests_ui(H)
			return

		var/accepted_diff = slot["accepted_diff"]
		if(!istext(accepted_diff))
			accepted_diff = ""

		if(length(accepted_diff) && accepted_diff != diff_key)
			to_chat(H, span_warning("This quest is already locked to [uppertext(accepted_diff)]."))
			open_quests_ui(H)
			return

		var/list/D = diffs[diff_key]
		if(!islist(D))
			open_quests_ui(H)
			return

		if(D["spawned"])
			to_chat(H, span_warning("The quest item has already been granted."))
			open_quests_ui(H)
			return

		var/typepath = D["token_path"]
		if(!typepath)
			to_chat(H, span_warning("Token type not found."))
			open_quests_ui(H)
			return

		// quest.dm token shit below
		var/obj/item/quest_token/QI = new typepath(H)
		if(!QI)
			to_chat(H, span_warning("Failed to spawn the quest item."))
			open_quests_ui(H)
			return

		var/success = FALSE
		if(ismob(H) && hascall(H, "put_in_hands"))
			success = call(H, "put_in_hands")(QI)
		if(!success)
			var/turf/TT = get_turf(H)
			if(TT) QI.forceMove(TT)

		if(istype(QI, /obj/item/quest_token))
			var/obj/item/quest_token/QBASE = QI
			if(D["reward"])
				QBASE.reward_amount = D["reward"]

		var/list/P = D["params"]
		if(islist(P))
			// Enemy of the Faith (antag_find)
			if(istype(QI, /obj/item/quest_token/antag_find))
				var/obj/item/quest_token/antag_find/AF = QI
				if(P["allowed_tiers"])
					AF.allowed_tiers = P["allowed_tiers"]

			// Tithe (coin_chest)
			if(istype(QI, /obj/item/quest_token/coin_chest))
				var/obj/item/quest_token/coin_chest/CC = QI
				if(P["required_sum"])
					CC.required_sum = P["required_sum"]

			// Find Expertise (skill_bless)
			if(istype(QI, /obj/item/quest_token/skill_bless))
				var/obj/item/quest_token/skill_bless/SK = QI
				if(P["required_skills"])
					SK.required_skills = P["required_skills"]

			// Blood Research (blood_draw)
			if(istype(QI, /obj/item/quest_token/blood_draw))
				var/obj/item/quest_token/blood_draw/BD = QI
				if(P["required_race_keys"])
					BD.required_race_keys = P["required_race_keys"]

			// Deliver Ration (ration_delivery)
			if(istype(QI, /obj/item/quest_token/ration_delivery))
				var/obj/item/quest_token/ration_delivery/RD = QI
				if(P["required_job_types"])
					RD.required_job_types = P["required_job_types"]

			// Offering of Supplies (donation_box)
			if(istype(QI, /obj/item/quest_token/donation_box))
				var/obj/item/quest_token/donation_box/DB = QI
				if(P["need_types"])
					DB.need_types = P["need_types"]

			// Minor Sermon (sermon_minor)
			if(istype(QI, /obj/item/quest_token/sermon_minor))
				var/obj/item/quest_token/sermon_minor/SM = QI
				if(P["required_patron_names"])
					SM.required_patron_names = P["required_patron_names"]

			// Reliquary (reliquary)
			if(istype(QI, /obj/item/quest_token/reliquary))
				var/obj/item/quest_token/reliquary/RL = QI
				if(P["bonus_patron_names"])
					RL.bonus_patron_names = P["bonus_patron_names"]

			// Researchment of Addiction / Mercy (flaw_aid)
			if(istype(QI, /obj/item/quest_token/flaw_aid))
				var/obj/item/quest_token/flaw_aid/FA = QI
				if(P["required_flaw_types"])
					FA.required_flaw_types = P["required_flaw_types"]

		D["spawned"] = TRUE
		diffs[diff_key] = D
		slot["accepted_diff"] = diff_key
		slot["difficulties"]  = diffs
		H.quest_ui_entries[q_index] = slot

		to_chat(H, span_notice("A special quest item has been granted: [QI.name]."))
		open_quests_ui(H)
		return


	// ----------tab RESEARCH UI ----------

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
		open_research_ui(H)
		return

	if(href_list["mirtab"])
		var/tb = lowertext(href_list["mirtab"])
		if     (tb == "unity"   && H.unlocked_research_unity)   src.current_miracle_tab = "unity"
		else if(tb == "ten"     && H.unlocked_research_ten)     src.current_miracle_tab = "ten"
		else if(tb == "shunned" && H.unlocked_research_shunned) src.current_miracle_tab = "shunned"
		else if(tb == "none")                                    src.current_miracle_tab = "none"
		else                                                      src.current_miracle_tab = "none"
		open_research_ui(H)
		return

	if(href_list["orgtab"])
		var/tb2 = lowertext(href_list["orgtab"])
		if(tb2 == "t1" || tb2 == "t2" || tb2 == "t3")
			src.current_org_tab = tb2
		else if(tb2 == "none")
			src.current_org_tab = "none"
		else
			src.current_org_tab = "none"
		open_research_ui(H)
		return


	// ---------- buy RESEARCH UI ----------

	if(href_list["buyart"])
		if(!HAS_TRAIT(H, TRAIT_CLERGY)) { open_research_ui(H); return }

		var/god = href_list["buyart"]
		var/item_txt = href_list["item"]

		build_divine_patrons_index()
		if(!(god in divine_patrons_index)) { open_research_ui(H); return }

		if(item_txt)
			var/item_path = text2path(item_txt)
			if(!ispath(item_path, /obj/item))
				to_chat(H, span_warning("Invalid artefact type."))
				open_research_ui(H)
				return

			var/list/art_list = PATRON_ARTIFACTS ? PATRON_ARTIFACTS[god] : null
			if(!islist(art_list) || !art_list.Find(item_path))
				to_chat(H, span_warning("This artefact does not belong to [god]."))
				open_research_ui(H)
				return

			if(H.church_favor < ARTEFACT_PRICE_FAVOR) { open_research_ui(H); return }

			if(alert(H, "Buy [item_txt] of [god] for [ARTEFACT_PRICE_FAVOR] Favor?", "Confirm", "Buy", "Cancel") != "Buy")
				open_research_ui(H); return

			var/turf/T1 = get_step(H, H.dir); if(!T1) T1 = get_turf(H)
			new item_path(T1)
			H.church_favor = max(0, H.church_favor - ARTEFACT_PRICE_FAVOR)
			to_chat(H, span_notice("You acquired an artefact of [god]."))
			open_research_ui(H)
			return

		open_research_ui(H)
		return

	if(href_list["buyorg"])
		if(!HAS_TRAIT(H, TRAIT_CLERGY)) { open_research_ui(H); return }

		var/tier = lowertext(href_list["buyorg"])
		var/label = lowertext(href_list["item"])
		if(!(label in list("eyes","stomach","liver","heart","lungs"))) { open_research_ui(H); return }

		var/unlocked = FALSE
		var/price = 0
		if     (tier == "t1") { unlocked = H.unlocked_research_org_t1; price = ORG_PRICE_T1 }
		else if(tier == "t2") { unlocked = H.unlocked_research_org_t2; price = ORG_PRICE_T2 }
		else if(tier == "t3") { unlocked = H.unlocked_research_org_t3; price = ORG_PRICE_T3 }
		else { open_research_ui(H); return }

		if(!unlocked) { open_research_ui(H); return }
		if(H.church_favor < price) { open_research_ui(H); return }

		var/path_text = "/obj/item/organ/[label]/[tier]"
		var/typepath2 = text2path(path_text)
		if(!typepath2)
			to_chat(H, span_warning("Organ type not found: [path_text]"))
			open_research_ui(H)
			return

		var/turf/T2 = get_step(H, H.dir); if(!T2) T2 = get_turf(H)
		new typepath2(T2)
		H.church_favor = max(0, H.church_favor - price)
		to_chat(H, span_notice("[capitalize(label)] [uppertext(tier)] spawned for [price] Favor."))
		open_research_ui(H)
		return

	if(href_list["buyrp"])
		if(!HAS_TRAIT(H, TRAIT_CLERGY)) { open_research_ui(H); return }
		if(H.church_favor < RESEARCH_RP_PRICE_FLAVOR) { open_research_ui(H); return }

		H.church_favor = max(0, H.church_favor - RESEARCH_RP_PRICE_FLAVOR)
		H.personal_research_points++
		to_chat(H, span_notice("You gained +1 Research Point."))
		open_research_ui(H)
		return

	if(href_list["buymp"])
		if(!HAS_TRAIT(H, TRAIT_CLERGY)) { open_research_ui(H); return }
		if(H.church_favor < MIRACLE_MP_PRICE_FLAVOR) { open_research_ui(H); return }

		H.church_favor = max(0, H.church_favor - MIRACLE_MP_PRICE_FLAVOR)
		H.miracle_points++
		to_chat(H, span_notice("You gained +1 Miracle Point."))
		open_research_ui(H)
		return

	if(href_list["unlock"])
		var/key = lowertext(href_list["unlock"])
		var/need = 0
		if     (key == "artefacts") need = COST_ARTEFACTS
		else if(key == "org_t1")    need = COST_ORG_T1
		else if(key == "org_t2")    need = COST_ORG_T2
		else if(key == "org_t3")    need = COST_ORG_T3
		else if(key == "unity")     need = COST_UNITY
		else if(key == "ten")       need = COST_TEN
		else if(key == "shunned")   need = COST_SHUNNED
		else { open_research_ui(H); return }

		if(H.personal_research_points < need) { open_research_ui(H); return }

		H.personal_research_points = max(0, H.personal_research_points - need)

		if     (key == "artefacts") H.unlocked_research_artefacts = TRUE
		else if(key == "org_t1")    H.unlocked_research_org_t1   = TRUE
		else if(key == "org_t2")    H.unlocked_research_org_t2   = TRUE
		else if(key == "org_t3")    H.unlocked_research_org_t3   = TRUE
		else if(key == "unity")     H.unlocked_research_unity    = TRUE
		else if(key == "ten")       H.unlocked_research_ten      = TRUE
		else if(key == "shunned")   H.unlocked_research_shunned  = TRUE

		to_chat(H, span_notice("Study unlocked: [key]."))
		open_research_ui(H)
		return


	// ---------- DIAGNOSE +++++++++++++----------

	if(href_list["upgrade_diag"])
		if(!istype(H)) return
		if(!H?.mind) { open_upgrade_ui(H); return }

		var/obj/effect/proc_holder/spell/baseS = null
		var/obj/effect/proc_holder/spell/greaterS = null

		for(var/obj/effect/proc_holder/spell/S in H.mind.spell_list)
			if(istype(S, /obj/effect/proc_holder/spell/invoked/diagnose))
				baseS = S
			if(istype(S, /obj/effect/proc_holder/spell/invoked/diagnose/greater))
				greaterS = S

		if(greaterS)
			to_chat(H, span_info("You already know Greater Diagnose."))
			open_upgrade_ui(H)
			return

		if(!baseS)
			to_chat(H, span_warning("You must learn Diagnose first."))
			open_upgrade_ui(H)
			return

		if(hascall(H.mind, "RemoveSpell"))
			call(H.mind, "RemoveSpell")(baseS)
		else
			qdel(baseS)

		var/obj/effect/proc_holder/spell/invoked/diagnose/greater/N = new
		H.mind.AddSpell(N)

		to_chat(H, span_notice("Your Diagnose has been upgraded to Greater Diagnose."))
		open_upgrade_ui(H)
		return


// ---------------------------------------------------------------------
// ALWAYS KEEP IT BOTTOM
// ---------------------------------------------------------------------

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
	else if(choice == "Quests")
		open_quests_ui(user)
	else if(choice == "Upgrade")
		open_upgrade_ui(user)

	return
