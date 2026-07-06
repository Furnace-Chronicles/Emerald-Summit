// Treasury solvency state machine: NORMAL -> IN_ARREARS -> BANKRUPTCY (and back).
// ES adaptation: no decree system; wage suspension tracked via suspended_wage_mobs list.
// "Azurian Trading Company" renamed to "Emerald Trading Company" throughout.

/datum/controller/subsystem/treasury/proc/is_in_receivership()
	return treasury_state == TREASURY_BANKRUPTCY

/datum/controller/subsystem/treasury/proc/is_in_arrears_or_worse()
	return treasury_state != TREASURY_NORMAL

/datum/controller/subsystem/treasury/proc/enter_arrears(projected_total)
	if(treasury_state != TREASURY_NORMAL)
		return FALSE
	var/shortfall = max(0, projected_total - discretionary_fund.balance)
	var/loan_amount = max(TREASURY_ARREARS_LOAN, shortfall)
	treasury_state = TREASURY_IN_ARREARS
	treasury_debt += loan_amount
	force_set_round_statistic(STATS_TREASURY_DEBT_OUTSTANDING, treasury_debt)
	record_round_statistic(STATS_ARREARS_DECLARED, 1)
	// Direct credit so the loan isn't immediately skimmed against the debt we just registered.
	discretionary_fund.balance += loan_amount
	treasury_value = discretionary_fund.balance
	log_fund_entry(new /datum/treasury_entry("mint", null, discretionary_fund, loan_amount, "Arrears advance from the Emerald Trading Company"))
	priority_announce(
		"The Crown's coffers ran dry at payroll. The Burghers of Emerald Summit, by their standing pledge, advance [loan_amount]m at no interest to cover the day's wages. Should the Crown fail again on the morrow, the realm enters sequestration.",
		"THE BURGHERS LEND",
		'sound/misc/royal_decree2.ogg',
		"Captain",
	)
	return TRUE

/datum/controller/subsystem/treasury/proc/enter_bankruptcy()
	if(treasury_state == TREASURY_BANKRUPTCY)
		return FALSE
	bankruptcy_count += 1
	record_round_statistic(STATS_BANKRUPTCY_DECLARED, 1)

	if(discretionary_fund.balance > BANKRUPTCY_OPERATING_FLOOR)
		var/excess = discretionary_fund.balance - BANKRUPTCY_OPERATING_FLOOR
		discretionary_fund.balance = BANKRUPTCY_OPERATING_FLOOR
		log_fund_entry(new /datum/treasury_entry("burn", discretionary_fund, null, excess, "Sequestration: residual purse forfeit"))
		record_round_statistic(STATS_FORFEITURE_AMOUNT, excess)
		record_round_statistic(STATS_FORFEITURE_COUNT, 1)
	else if(discretionary_fund.balance < BANKRUPTCY_OPERATING_FLOOR)
		var/topup = BANKRUPTCY_OPERATING_FLOOR - discretionary_fund.balance
		discretionary_fund.balance = BANKRUPTCY_OPERATING_FLOOR
		log_fund_entry(new /datum/treasury_entry("mint", null, discretionary_fund, topup, "Sequestration: operating reserve from the Emerald Trading Company"))
	treasury_value = discretionary_fund.balance

	var/new_debt = BANKRUPTCY_DEBT_FLAT
	treasury_debt += new_debt
	force_set_round_statistic(STATS_TREASURY_DEBT_OUTSTANDING, treasury_debt)
	treasury_state = TREASURY_BANKRUPTCY

	suspend_charters_for_bankruptcy()
	override_trade_for_bankruptcy()
	suspend_wages_for_bankruptcy()

	priority_announce(
		"Following seizure of [atc_seizure_blurb()] against the Crown's outstanding obligations, the Emerald Trading Company - most blessed servant of Malum the Worker - has graciously advanced an interest-free reserve of [BANKRUPTCY_OPERATING_FLOOR]m in exchange for a debt of [new_debt]m to the Company. Until the debt is repaid in full, the Company holds the sequestered revenues of the realm; the stockpile and trade-engine pass to its hand. Salaries stand suspended.",
		"SEQUESTRATION DECLARED",
		'sound/misc/royal_decree.ogg',
		"Captain",
	)
	return TRUE

/// ES: bank_accounts stores integer balances. Track suspended mobs in suspended_wage_mobs.
/datum/controller/subsystem/treasury/proc/suspend_wages_for_bankruptcy()
	if(!steward_machine || !steward_machine.daily_payments)
		return
	var/list/payments = steward_machine.daily_payments
	for(var/mob/living/carbon/human/owner as anything in bank_accounts)
		if(!owner || !(payments[owner.job] > 0))
			continue
		if(owner in suspended_wage_mobs)
			continue
		suspended_wage_mobs[owner] = TRUE
		to_chat(owner, span_danger("My wages have been suspended after the Crown's sequestration. They will resume when the realm recovers."))

/datum/controller/subsystem/treasury/proc/resume_wages_after_bankruptcy()
	var/list/payments = steward_machine?.daily_payments
	for(var/mob/living/carbon/human/owner as anything in suspended_wage_mobs)
		if(!owner)
			continue
		suspended_wage_mobs -= owner
		if(payments && payments[owner.job] > 0)
			to_chat(owner, span_notice("My wages have been reinstated as the Crown's sequestration lifts."))

/datum/controller/subsystem/treasury/proc/clear_treasury_debt_state()
	switch(treasury_state)
		if(TREASURY_NORMAL)
			if(atc_loan_arrears_consumed)
				atc_loan_arrears_consumed = FALSE
				priority_announce(
					"The Crown's debt to the Emerald Trading Company is settled. The Burghers' grace stands restored.",
					"ETC LOAN SETTLED",
					'sound/misc/royal_decree2.ogg',
					"Captain",
				)
		if(TREASURY_IN_ARREARS)
			exit_arrears()
		if(TREASURY_BANKRUPTCY)
			exit_bankruptcy()

/datum/controller/subsystem/treasury/proc/exit_arrears()
	if(treasury_state != TREASURY_IN_ARREARS)
		return
	treasury_state = TREASURY_NORMAL
	atc_loan_arrears_consumed = FALSE
	priority_announce(
		"The Crown has settled its arrears with the Burghers. The realm is solvent once more.",
		"THE BURGHERS PAID",
		'sound/misc/royal_decree2.ogg',
		"Captain",
	)

/datum/controller/subsystem/treasury/proc/exit_bankruptcy()
	if(treasury_state != TREASURY_BANKRUPTCY)
		return
	treasury_state = TREASURY_NORMAL

	if(discretionary_fund.balance < BANKRUPTCY_RECOVERY_RESET)
		var/topup = BANKRUPTCY_RECOVERY_RESET - discretionary_fund.balance
		discretionary_fund.balance = BANKRUPTCY_RECOVERY_RESET
		treasury_value = discretionary_fund.balance
		log_fund_entry(new /datum/treasury_entry("mint", null, discretionary_fund, topup, "Sequestration lifted: working capital"))

	resume_wages_after_bankruptcy()
	bankruptcy_concession_picks = BANKRUPTCY_CONCESSION_PICKS
	atc_loan_arrears_consumed = FALSE
	force_set_round_statistic(STATS_TREASURY_DEBT_OUTSTANDING, 0)

	priority_announce(
		"The Emerald Trading Company releases the Crown's commerce. Wages resume on the morrow. The Lord may restore up to [BANKRUPTCY_CONCESSION_PICKS] suspended matters at the Steward's discretion.",
		"SEQUESTRATION LIFTED",
		'sound/misc/royal_decree.ogg',
		"Captain",
	)

// ES: no decree system — stub. Just log that bankruptcy would have suspended charters.
/datum/controller/subsystem/treasury/proc/suspend_charters_for_bankruptcy()
	log_game("BANKRUPTCY: Sequestration declared; charter suspension stubbed (no decree system in ES).")

/datum/controller/subsystem/treasury/proc/override_trade_for_bankruptcy()
	autoexport_percentage = BANKRUPTCY_AUTOEXPORT_PERCENTAGE
	auto_import_disabled.Cut()
	for(var/good_id in GLOB.trade_goods)
		var/datum/trade_good/tg = GLOB.trade_goods[good_id]
		if(tg && tg.importable)
			auto_import_standing[good_id] = TRUE
	dirty_auto_import_view()
	dirty_market_view()

// ES: no decree system — concession restoration is a no-op stub.
/datum/controller/subsystem/treasury/proc/restore_charter_via_concession(decree_id)
	return FALSE

/datum/controller/subsystem/treasury/proc/can_mutate_decree(decree_id, new_active)
	return TRUE

/proc/bankruptcy_state_label(state_value)
	switch(state_value)
		if(TREASURY_NORMAL)
			return "Solvent"
		if(TREASURY_IN_ARREARS)
			return "In Arrears"
		if(TREASURY_BANKRUPTCY)
			return "Sequestered"
	return "Unknown"

/// ATC (Emerald Trading Company) emergency loan — early-round cashflow tool.
/// Adds debt repaid via future inflow; consumes arrears grace (next missed payroll → sequestration).
/// Disabled from ATC_LOAN_CLOSED_DAY onward so it can't free-ride a round-end wipe.
/datum/controller/subsystem/treasury/proc/atc_loan_available()
	if(treasury_state == TREASURY_BANKRUPTCY)
		return FALSE
	if(GLOB.dayspassed >= ATC_LOAN_CLOSED_DAY)
		return FALSE
	return TRUE

/datum/controller/subsystem/treasury/proc/atc_loan_blocker_reason()
	if(treasury_state == TREASURY_BANKRUPTCY)
		return "The Company administers commerce. No further loans until sequestration lifts."
	if(GLOB.dayspassed >= ATC_LOAN_CLOSED_DAY)
		return "The Guilds clerk is out of office. The loan window has closed for the week."
	if(atc_loan_arrears_consumed)
		return "A prior advance stands unpaid. The Company refuses a second loan until the first is settled."
	return null

/datum/controller/subsystem/treasury/proc/take_atc_loan(amount, mob/applicant)
	var/blocker = atc_loan_blocker_reason()
	if(blocker)
		if(applicant)
			to_chat(applicant, span_warning("Loan refused: [blocker]."))
		return FALSE
	amount = clamp(round(amount), ATC_LOAN_MIN_AMOUNT, ATC_LOAN_MAX_AMOUNT)
	var/debt_owed = round(amount * (1 + ATC_LOAN_INTEREST_RATE))
	treasury_debt += debt_owed
	force_set_round_statistic(STATS_TREASURY_DEBT_OUTSTANDING, treasury_debt)
	atc_loans_drawn_this_round += 1
	atc_loan_arrears_consumed = TRUE
	// Direct credit so principal isn't immediately skimmed against the debt we just registered.
	discretionary_fund.balance += amount
	treasury_value = discretionary_fund.balance
	log_fund_entry(new /datum/treasury_entry("mint", null, discretionary_fund, amount, "ETC emergency loan (principal)"))
	priority_announce(
		"The Crown takes an advance of [amount]m from the Emerald Trading Company at the customary one-quarter interest, registering a debt of [debt_owed]m. The arrears grace stands forfeit; should the Crown miss its next payroll, the realm enters sequestration without warning.",
		"THE CROWN BORROWS",
		'sound/misc/royal_decree.ogg',
		"Captain",
	)
	log_game("ATC LOAN: [applicant ? key_name(applicant) : "system"] drew [amount]m principal from the Emerald Trading Company; debt of [debt_owed]m registered")
	return TRUE

GLOBAL_LIST_INIT(atc_seizure_inventory, list(
	"the Lord's gilded bathing-tub",
	"a brace of falcons from the royal mews",
	"an illuminated psyalter bound in shagreen",
	"the great Otavan tapestry depicting the Hunt of the Boar",
	"two gilded saltcellars in the Etruscan fashion",
	"three sealed coffers of the Crown's pearls",
	"the household reliquary (less the relic)",
	"a Naledian astrolabe with three missing pins",
	"the Steward's reserve of saffron and cinnamon",
	"an ivory chess-set, six pieces short",
	"a brocaded canopy bed, taken down with great difficulty",
	"the chapel's spare gilt candelabrum",
	"the last Marshal's silver-mounted hunting-horn",
	"a portrait of a long-forgotten ancestor, slashed by a disgruntled debtor",
	"the Court Cupbearer's pewter inventory and the keys to it",
	"a Lirvanic jewel-encrusted bathtub of indecent proportion",
	"twelve casks of Bleakcoast firewine, marked for the Midwinter feast",
	"a Kazengun lacquered wardrobe of indeterminate vintage",
	"an Etruscan illuminated bestiary, water-damaged",
	"a clutch of Heartfelt clockwork toys, ticking faintly",
	"the menagerie's pet civet, of doubtful temperament",
	"the great clock of the Crown, dismantled in three carts",
	"twelve hundred yards of Naledian silk, the Crown's spare livery",
	"the Crown's reserve of Saltwick anchovies, packed in oil",
	"the Crown's emergency Kingsfield cheese reserve",
	"two white stag heads, taxidermied from the last royal hunt",
	"a crate of unknown white liquid of uncertain provenance, labeled 'CROWN ONLY - Not for Consumption'",
	"a sealed crate marked PROPERTY OF THE LATE STEWARD",
))

/proc/atc_seizure_blurb()
	var/list/picks = list()
	var/count = rand(2, 3)
	var/list/pool = GLOB.atc_seizure_inventory.Copy()
	for(var/i in 1 to count)
		if(!length(pool))
			break
		var/choice = pick(pool)
		picks += choice
		pool -= choice
	if(length(picks) == 1)
		return picks[1]
	if(length(picks) == 2)
		return "[picks[1]]; and [picks[2]]"
	var/last = picks[length(picks)]
	picks.Cut(length(picks), length(picks) + 1)
	return "[jointext(picks, "; ")]; and [last]"
