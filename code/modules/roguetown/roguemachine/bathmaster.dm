#define UPGRADE_NOTAX		(1<<0)

// Emerald addition: an item only contributes to BRASSFACE vault income after the Nightmaster casts
// "Bathhouse Appraisal" on the tile it sits on. Prevents non-Nightmasters from abusing the brothel as
// a passive-income generator.
/obj/item
	var/bathhouse_appraised = FALSE

/obj/item/examine(mob/user)
	. = ..()
	if(bathhouse_appraised)
		. += span_notice("It bears the Nightmaster's appraisal mark.")

/obj/structure/roguemachine/bathvend
	name = "BRASSFACE"
	desc = "Sweet, sweet, addiction. Love in the veins, comfort in my heart."
	icon = 'icons/roguetown/misc/machines.dmi'
	icon_state = "brassface"
	density = TRUE
	blade_dulling = DULLING_BASH
	max_integrity = 0
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	var/list/held_items = list()
	var/locked = FALSE
	var/upgrade_flags
	var/current_cat = "1"
	var/lockid = "nightman"
	var/list/categories = list(
		"Alcohols",
		"Drugs",
		"Exotic Apparel",
		"Instruments",
		"Perfumes",
		"Roguery",
		)

/obj/structure/roguemachine/bathvend/Initialize()
	. = ..()
	SSBMtreasury.brassface = src
	// Emerald addition: seed the income-tick timer at brassface init so the TGUI countdown is meaningful
	// from the start. Without this, next_treasury_check stays 0 until the subsystem's first fire and the
	// "Next tick in" display sticks at 0s.
	if(!SSBMtreasury.next_treasury_check)
		SSBMtreasury.next_treasury_check = world.time + rand(5 MINUTES, 8 MINUTES)
	update_icon()

/obj/structure/roguemachine/bathvend/update_icon()
	cut_overlays()
	if(obj_broken)
		set_light(0)
		return
	set_light(1, 1, 1, l_color = "#1b7bf1")
	add_overlay(mutable_appearance(icon, "vendor-merch"))


/obj/structure/roguemachine/bathvend/attackby(obj/item/P, mob/user, params)
	if(istype(P, /obj/item/roguekey))
		var/obj/item/roguekey/K = P
		if(K.lockid == lockid)
			locked = !locked
			playsound(loc, 'sound/misc/gold_misc.ogg', 100, FALSE, -1)
			update_icon()
			return attack_hand(user)
		else
			to_chat(user, span_warning("Wrong key."))
			return
	if(istype(P, /obj/item/storage/keyring))
		var/obj/item/storage/keyring/K = P
		for(var/obj/item/roguekey/KE in K.keys)
			if(KE.lockid == lockid)
				locked = !locked
				playsound(loc, 'sound/misc/gold_misc.ogg', 100, FALSE, -1)
				update_icon()
				return attack_hand(user)
	if(istype(P, /obj/item/roguecoin))
		budget += P.get_real_price()
		qdel(P)
		update_icon()
		playsound(loc, 'sound/misc/machinevomit.ogg', 100, TRUE, -1)
		return attack_hand(user)
	..()

/obj/structure/roguemachine/bathvend/Topic(href, href_list)
	. = ..()
	if(!ishuman(usr))
		return
	var/mob/living/carbon/human/human_mob = usr
	if(!usr.canUseTopic(src, BE_CLOSE) || locked)
		return
	if(href_list["buy"])
		var/mob/M = usr
		var/path = text2path(href_list["buy"])
		if(!ispath(path, /datum/supply_pack))
			message_admins("silly MOTHERFUCKER [usr.key] IS TRYING TO BUY A [path] WITH THE BRASSFACE")
			return
		var/datum/supply_pack/PA = SSmerchant.supply_packs[path]
		var/cost = PA.cost
		var/tax_amt=round(SStreasury.tax_value * cost)
		cost=cost+tax_amt
		if(upgrade_flags & UPGRADE_NOTAX)
			cost = PA.cost
		if(budget >= cost)
			budget -= cost
			if(!(upgrade_flags & UPGRADE_NOTAX))
				SStreasury.give_money_treasury(tax_amt, "brassface import tax")
				record_featured_stat(FEATURED_STATS_TAX_PAYERS, human_mob, tax_amt)
				record_round_statistic(STATS_TAXES_COLLECTED, tax_amt)
		else
			say("Not enough!")
			return
		var/shoplength = PA.contains.len
		var/l
		for(l=1,l<=shoplength,l++)
			var/pathi = pick(PA.contains)
			new pathi(get_turf(M))
	if(href_list["change"])
		if(budget > 0)
			withdrawbudget(usr)
	if(href_list["changecat"])
		current_cat = href_list["changecat"]
	if(href_list["secrets"])
		var/list/options = list()
		if(upgrade_flags & UPGRADE_NOTAX)
			options += "Enable Paying Taxes"
		else
			options += "Stop Paying Taxes"
		var/select = input(usr, "Please select an option.", "", null) as null|anything in options
		if(!select)
			return
		if(!usr.canUseTopic(src, BE_CLOSE) || locked)
			return
		switch(select)
			if("Enable Paying Taxes")
				upgrade_flags &= ~UPGRADE_NOTAX
				playsound(loc, 'sound/misc/gold_misc.ogg', 100, FALSE, -1)
			if("Stop Paying Taxes")
				upgrade_flags |= UPGRADE_NOTAX
				playsound(loc, 'sound/misc/gold_misc.ogg', 100, FALSE, -1)
				playsound(loc, 'sound/misc/gold_license.ogg', 100, FALSE, -1)
	if(href_list["openvault"])
		// Nightmaster/Nightswain only — same gate as the Secrets button above.
		if(!(human_mob.job in list("Nightmaster","Nightswain")))
			return
		// Route classic-pref users to the HTML vault display, TGUI-pref users to the TGUI window.
		// Close the other variant first so we don't show both at once.
		if(usr.client?.prefs?.tgui_pref)
			usr << browse(null, "window=BrassfaceVault")
			ui_interact(usr)
		else
			SStgui.close_uis(src)
			show_classic_vault(usr)
		return
	return attack_hand(usr)

// ===== Emerald addition: classic HTML vault display (fallback when tgui_pref is FALSE) =====

/obj/structure/roguemachine/bathvend/proc/show_classic_vault(mob/user)
	if(!user)
		return
	// Reuse the exact same scan the TGUI / income tick uses so the displayed numbers match the payout.
	var/list/seen_types = list()
	var/list/rows = list()
	var/total_income = 0
	var/total_value = 0
	for(var/turf/open/floor/rogue/churchbrick/bathbrick in RANGE_TURFS(5, src))
		for(var/obj/item/I in bathbrick.contents)
			if(!isturf(I.loc))
				continue
			var/contribution = _vault_entry(I, seen_types)
			if(contribution)
				rows += list(contribution)
				total_income += contribution["income"]
				total_value += contribution["value"]
		for(var/obj/structure/closet/closet in bathbrick.contents)
			for(var/obj/item/I in closet)
				var/contribution = _vault_entry(I, seen_types)
				if(contribution)
					rows += list(contribution)
					total_income += contribution["income"]
					total_value += contribution["value"]

	var/next_tick_s = max(0, round((SSBMtreasury.next_treasury_check - world.time) / 10))

	var/contents = "<center><b>BRASSFACE Vault</b></center><BR>"
	contents += "<b>Vault balance:</b> [budget]<BR>"
	contents += "<b>Items in vault:</b> [rows.len]<BR>"
	contents += "<b>Total value:</b> [total_value] mammons<BR>"
	contents += "<b>Estimated income:</b> +[total_income] mammons/tick<BR>"
	contents += "<b>Next tick in:</b> [next_tick_s]s<BR>"
	contents += "<HR>"
	if(!rows.len)
		contents += "<i>The vault is bare. Appraise items to mark valuables for profit.</i>"
	else
		contents += "<table width='100%' cellpadding='2' cellspacing='0'>"
		contents += "<tr><th align='left'>Item</th><th align='right'>Value</th><th align='right'>Income</th></tr>"
		for(var/list/row in rows)
			contents += "<tr><td>[row["name"]]</td><td align='right'>[row["value"]]</td><td align='right'>+[row["income"]]</td></tr>"
		contents += "</table>"

	var/datum/browser/popup = new(user, "BrassfaceVault", "BRASSFACE Vault", 420, 480)
	popup.set_content(contents)
	popup.open()

// ===== Emerald addition: unified TGUI Brassface interface (Brassface.tsx) =====

/obj/structure/roguemachine/bathvend/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Brassface", "BRASSFACE")
		ui.open()

// Hard-close the UI for the dead and for observers. The default state returns UI_DISABLED (not
// UI_CLOSE) for a corpse, so a Nightmaster who dies with the vault open would keep the secret
// contents lingering greyed-out on their (now ghost) screen. Living-but-unconscious users still
// fall through to the default UI_DISABLED behavior.
/obj/structure/roguemachine/bathvend/ui_status(mob/user, datum/ui_state/state)
	if(!isliving(user) || user.stat == DEAD)
		return UI_CLOSE
	return ..()

/obj/structure/roguemachine/bathvend/ui_static_data(mob/user)
	// Computed once per UI open instead of every poll — these don't change at runtime.
	var/list/data = list()
	data["categories"] = categories.Copy()
	data["interest_rate"] = SSBMtreasury.interest_rate
	data["multiple_item_penalty"] = SSBMtreasury.multiple_item_penalty

	// Shop packs are also effectively static (cost/group/contains don't change). Tax adjustment is dynamic,
	// but we ship base_cost here and recompute the post-tax `cost` client-side. Tiny perf win, big when
	// multiplied by 100+ packs * 1Hz poll * N players.
	var/list/packs_data = list()
	for(var/pack in SSmerchant.supply_packs)
		var/datum/supply_pack/PA = SSmerchant.supply_packs[pack]
		if(!(PA.group in categories))
			continue
		packs_data += list(list(
			"name" = PA.name,
			"category" = PA.group,
			"base_cost" = PA.cost,
			"count" = PA.contains.len,
			"type" = "[PA.type]",
		))
	data["packs"] = packs_data
	return data

/obj/structure/roguemachine/bathvend/ui_data(mob/user)
	var/list/data = list()
	data["budget"] = budget
	data["locked"] = locked
	data["next_tick_in"] = max(0, round((SSBMtreasury.next_treasury_check - world.time) / 10))
	data["tax_enabled"] = !(upgrade_flags & UPGRADE_NOTAX)
	data["tax_rate"] = SStreasury.tax_value

	var/mob/living/carbon/human/H = user
	data["is_nightmaster"] = istype(H) && (H.job in list("Nightmaster","Nightswain"))

	// Mirror the BMtreasury collection scope exactly — same range, same closet recursion, same filters —
	// so the displayed "estimated income per tick" matches what the next fire would actually pay out.
	var/list/seen_types = list()
	var/list/items_data = list()
	var/total_income = 0
	var/total_value = 0

	for(var/turf/open/floor/rogue/churchbrick/bathbrick in RANGE_TURFS(5, src))
		for(var/obj/item/I in bathbrick.contents)
			if(!isturf(I.loc))
				continue
			var/contribution = _vault_entry(I, seen_types)
			if(contribution)
				items_data += list(contribution)
				total_income += contribution["income"]
				total_value += contribution["value"]
		for(var/obj/structure/closet/closet in bathbrick.contents)
			for(var/obj/item/I in closet)
				var/contribution = _vault_entry(I, seen_types)
				if(contribution)
					items_data += list(contribution)
					total_income += contribution["income"]
					total_value += contribution["value"]

	data["appraised_items"] = items_data
	data["total_income"] = total_income
	data["total_value"] = total_value
	return data

/obj/structure/roguemachine/bathvend/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	if(locked)
		return
	switch(action)
		if("buy")
			var/path = text2path(params["type"])
			if(!ispath(path, /datum/supply_pack))
				message_admins("[usr.key] tried to buy a [path] via the Brassface TGUI")
				return TRUE
			var/datum/supply_pack/PA = SSmerchant.supply_packs[path]
			if(!PA)
				return TRUE
			var/cost = PA.cost
			var/tax_amt = round(SStreasury.tax_value * cost)
			cost += tax_amt
			if(upgrade_flags & UPGRADE_NOTAX)
				cost = PA.cost
			if(budget < cost)
				say("Not enough!")
				return TRUE
			budget -= cost
			if(!(upgrade_flags & UPGRADE_NOTAX))
				SStreasury.give_money_treasury(tax_amt, "brassface import tax")
				var/mob/living/carbon/human/HM = usr
				if(istype(HM))
					record_featured_stat(FEATURED_STATS_TAX_PAYERS, HM, tax_amt)
				record_round_statistic(STATS_TAXES_COLLECTED, tax_amt)
			for(var/i = 1 to PA.contains.len)
				var/pathi = pick(PA.contains)
				new pathi(get_turf(usr))
			return TRUE
		if("withdraw")
			if(budget > 0)
				withdrawbudget(usr)
			return TRUE
		if("toggle_tax")
			var/mob/living/carbon/human/HU = usr
			if(!istype(HU) || !(HU.job in list("Nightmaster","Nightswain")))
				return TRUE
			upgrade_flags ^= UPGRADE_NOTAX
			playsound(loc, 'sound/misc/gold_misc.ogg', 100, FALSE, -1)
			if(upgrade_flags & UPGRADE_NOTAX)
				playsound(loc, 'sound/misc/gold_license.ogg', 100, FALSE, -1)
			return TRUE

// Helper: returns an assoc-list entry for a single appraised item or null if it doesn't qualify.
// Mutates `seen_types` so duplicate-of-same-type rows show the diminishing-returns penalty.
/obj/structure/roguemachine/bathvend/proc/_vault_entry(obj/item/I, list/seen_types)
	if(!I || !I.bathhouse_appraised)
		return null
	var/price = I.get_real_price()
	if(price <= 0 || istype(I, /obj/item/roguecoin))
		return null
	var/income_factor = SSBMtreasury.interest_rate
	var/duplicate_steps = seen_types[I.type]
	if(isnull(duplicate_steps))
		seen_types[I.type] = 0
	else
		duplicate_steps += 1
		seen_types[I.type] = duplicate_steps
		for(var/i = 1 to duplicate_steps)
			income_factor *= SSBMtreasury.multiple_item_penalty
	return list(
		"name" = I.name,
		"value" = price,
		"income" = round(price * income_factor, 1),
		"icon_file" = "[I.icon]",
		"icon_state" = I.icon_state,
		"ref" = REF(I),
	)

/obj/structure/roguemachine/bathvend/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!ishuman(user))
		return
	if(locked)
		to_chat(user, span_warning("It's locked. Of course."))
		return
	user.changeNext_move(CLICK_CD_FAST)
	playsound(loc, 'sound/misc/gold_menu.ogg', 100, FALSE, -1)
	// Emerald addition: route TGUI-pref users to the unified Brassface interface; classic-pref users
	// keep the legacy HTML below. Close any leftover window from the other variant so we never show both.
	if(user.client?.prefs?.tgui_pref)
		user << browse(null, "window=VENDORTHING")
		user << browse(null, "window=BrassfaceVault")
		ui_interact(user)
		return
	SStgui.close_uis(src)
	var/canread = user.can_read(src, TRUE)
	var/contents
	contents = "<center>BRASSFACE - Sweet Dreams for Cheap<BR>"
	contents += "<a href='?src=[REF(src)];change=1'>MAMMON LOADED:</a> [budget]<BR>"

	var/mob/living/carbon/human/H = user
	if(H.job in list("Nightmaster","Nightswain"))
		if(canread)
			contents += "<a href='?src=[REF(src)];secrets=1'>Secrets</a> | "
			contents += "<a href='?src=[REF(src)];openvault=1'>View Vault</a>"
		else
			contents += "<a href='?src=[REF(src)];secrets=1'>[stars("Secrets")]</a> | "
			contents += "<a href='?src=[REF(src)];openvault=1'>[stars("View Vault")]</a>"

	contents += "</center><BR>"

	if(current_cat == "1")
		contents += "<center>"
		for(var/X in categories)
			contents += "<a href='?src=[REF(src)];changecat=[X]'>[X]</a><BR>"
		contents += "</center>"
	else
		contents += "<center>[current_cat]<BR></center>"
		contents += "<center><a href='?src=[REF(src)];changecat=1'>\[RETURN\]</a><BR><BR></center>"
		var/list/pax = list()
		for(var/pack in SSmerchant.supply_packs)
			var/datum/supply_pack/PA = SSmerchant.supply_packs[pack]
			if(PA.group == current_cat)
				pax += PA
		for(var/datum/supply_pack/PA in sortNames(pax))
			var/costy = PA.cost
			if(!(upgrade_flags & UPGRADE_NOTAX))
				costy=round(costy+(SStreasury.tax_value * costy))
			contents += "[PA.name] [PA.contains.len > 1?"x[PA.contains.len]":""] - ([costy])<a href='?src=[REF(src)];buy=[PA.type]'>BUY</a><BR>"

	if(!canread)
		contents = stars(contents)

	var/datum/browser/popup = new(user, "VENDORTHING", "", 370, 600)
	popup.set_content(contents)
	popup.open()

/obj/structure/roguemachine/bathvend/obj_break(damage_flag)
	..()
	budget2change(budget)
	set_light(0)
	update_icon()
	icon_state = "goldvendor0"

/obj/structure/roguemachine/bathvend/Destroy()
	set_light(0)
	SSBMtreasury.brassface = null // Clear our reference from the bath treasury subsystem.
	return ..()

/obj/structure/roguemachine/bathvend/Initialize()
	. = ..()
	update_icon()
//	held_items[/obj/item/reagent_containers/glass/bottle/rogue/wine] = list("PRICE" = rand(23,33),"NAME" = "vino")
//	held_items[/obj/item/dmusicbox] = list("PRICE" = rand(444,777),"NAME" = "Music Box")

#undef UPGRADE_NOTAX

SUBSYSTEM_DEF(BMtreasury)
	name = "BMtreasury"
	wait = 60 SECONDS // this should not need to run very often.
	priority = FIRE_PRIORITY_WATER_LEVEL
	var/treasury_value = 0
	var/multiple_item_penalty = 0.7
	var/interest_rate = 0.15 // Bit more interest, since it's gonna be much harder for the BMaster to get valuables.
	var/next_treasury_check = 0
	var/list/vault_accounting = list()
	/// The reference to the map's brassface, populated when it initializes.
	var/obj/structure/roguemachine/bathvend/brassface


/datum/controller/subsystem/BMtreasury/proc/add_to_vault(var/obj/item/I)
	if(I.get_real_price() <= 0 || istype(I, /obj/item/roguecoin))
		return
	// Emerald addition: only items the Nightmaster has personally appraised generate vault income.
	if(!I.bathhouse_appraised)
		return
	if(I.type in vault_accounting)
		vault_accounting[I.type] *= multiple_item_penalty
	else
		vault_accounting[I.type] = I.get_real_price()
	return (vault_accounting[I.type]*interest_rate)


/datum/controller/subsystem/BMtreasury/fire()
	if(!brassface) // If there's no brassface there's no point in calculating the money it would be collecting.
		return

	if(!(world.time > next_treasury_check)) // Skip this fire if it's not time for another check.
		return

	next_treasury_check = world.time + rand(5 MINUTES, 8 MINUTES) // If we are going through with our check, set the time for the next one 5-8 minutes in the future.

	vault_accounting = list()
	var/amt_to_generate = 0

	// Still absolutely sucks; Effectively looking through absolutely everything in range to find a couple floors; then again on things on bricks to calculate their value.
	// Alternatively could check the brassface's area and iterate through the things within; in area == in world; so that'd be probably worse.
	// Best way I think would be to add things to a list on area Entered and remove it on area Exit for the purposes of collection-- right now I'm just working on the world loops.
	for(var/turf/open/floor/rogue/churchbrick/bathbrick in RANGE_TURFS(5, brassface))
		for(var/obj/item/item in bathbrick.contents)
			if(!isturf(item.loc)) // This shouldn't pick up things that aren't on the turf anyway-- should always be false.
				continue
			amt_to_generate += add_to_vault(item)

		for(var/obj/structure/closet/closet in bathbrick.contents)
			for(var/obj/item/item in closet)
				amt_to_generate += add_to_vault(item)

	var/rounded_income = round(amt_to_generate, 1)
	brassface.budget += rounded_income // goes directly into BRASSFACE rather than into any account.
	send_ooc_note("Income from smuggling hoard to the BRASSFACE: +[rounded_income]; [brassface.budget] total", job = "Nightmaster")


/datum/controller/subsystem/BMtreasury/Destroy()
	brassface = null // If this somehow gets deleted, clean up the reference.
	return ..()
