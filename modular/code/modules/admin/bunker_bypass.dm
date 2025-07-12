GLOBAL_LIST_INIT(entry_whitelists, load_entry_whitelists())

/client/proc/entry_whitelist_check()
	if (ckey in GLOB.entry_whitelists)
		return TRUE
	return FALSE

/client/proc/bunker_bypass()
	set category = "-Server-"
	set name = "Add Bunker Bypass"

	if(!check_rights())
		return

	var/selection = input("Who would you like to let in?", "CKEY", "") as text|null
	if(selection)
		if(ckey in GLOB.entry_whitelists)
			to_chat(src, span_warning("Player with ckey [ckey] is already on the list."))
			return
		if(alert("Confirm: allow ckey [selection] to connect?", "", "Yes!", "No") == "Yes!")
			add_entry_whitelist(selection, ckey)

/proc/add_entry_whitelist(target_ckey, admin_ckey = "SYSTEM")
	if(!target_ckey)
		return

	if(IsAdminAdvancedProcCall())
		return

	target_ckey = ckey(target_ckey)
	GLOB.entry_whitelists |= target_ckey
	message_admins("BUNKER BYPASS: Added [target_ckey] to the bypass list[admin_ckey? " by [admin_ckey]":""]")
	log_admin("BUNKER BYPASS: Added [target_ckey] to the bypass list[admin_ckey? " by [admin_ckey]":""]")

	var/datum/DBQuery/query_add_entry_whitelist = SSdbcore.NewQuery({"
		INSERT INTO [format_table_name("whitelists")] (ckey, type, added_by, timestamp, round_id)
		VALUES (:ckey, :type, :added_by, :timestamp, :round_id)
	"}, list(
		"ckey" = target_ckey,
		"type" = "entry",
		"added_by" = admin_ckey,
		"timestamp" = SQLtime(),
		"round_id" = GLOB.round_id,
	))
	if(!query_add_entry_whitelist.Execute())
		message_admins("Failed to add entry whitelist for [key_name_admin(target_ckey)] to the database!")
		log_admin("Failed to add entry whitelist for [key_name_admin(target_ckey)] to the database!")
		qdel(query_add_entry_whitelist)
		return

/proc/load_entry_whitelists()
	RETURN_TYPE(/list)

	var/datum/DBQuery/query_load_entry_whitelists = SSdbcore.NewQuery("SELECT ckey FROM [format_table_name("whitelists")] WHERE type = 'entry'")
	if(!query_load_entry_whitelists.Execute())
		qdel(query_load_entry_whitelists)
		return
	var/list/ckeys = list()
	while(query_load_entry_whitelists.NextRow())
		ckeys |= query_load_entry_whitelists.item[1]
	return ckeys
