// Examine panel — TGUI character flyout, ported from Azure-Peak PR #6325.
// Adaptations for Emerald Summit:
//  - Examine THEMES omitted per port scope (no examine_theme var/handling).
//  - ES has no /datum/antagonist/vampire or /lich, so the disguise-gated vampire/lich
//    headshot selection is dropped; we just use the character's headshot_link.
//  - Cached flavor/ooc fields map to ES's rendered "_display" vars.

/datum/examine_panel
	/// Mob that the examine panel belongs to.
	var/mob/living/carbon/human/holder
	/// Set when previewing from the preferences menu instead of a live mob.
	var/datum/preferences/pref = null
	var/is_playing = FALSE
	/// The mob viewing the panel.
	var/mob/viewing

/datum/examine_panel/New(mob/holder_mob)
	if(holder_mob)
		holder = holder_mob

/datum/examine_panel/Destroy(force)
	holder = null
	viewing = null
	pref = null
	return ..()

/datum/examine_panel/ui_state(mob/user)
	return GLOB.always_state

/datum/examine_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ExaminePanel")
		ui.open()

// Familiar/pet variant — pulls from the owner's familiar_prefs. No NSFW fields, gallery, or music.
/datum/examine_panel/familiar

/datum/examine_panel/familiar/ui_static_data(mob/user)
	var/datum/familiar_prefs/fam_pref = holder?.client?.prefs?.familiar_prefs
	var/char_name = "[holder]"
	var/headshot = "headshot_red.png"
	var/flavor_text
	var/ooc_notes = ""
	if(fam_pref)
		if(fam_pref.familiar_name)
			char_name = fam_pref.familiar_name
		flavor_text = fam_pref.familiar_flavortext_display
		ooc_notes = fam_pref.familiar_ooc_notes_display
		if(fam_pref.familiar_headshot_link)
			headshot = fam_pref.familiar_headshot_link

	var/list/data = list(
		"character_name" = char_name,
		"headshot" = headshot,
		"obscured" = FALSE,
		"flavor_text" = flavor_text,
		"ooc_notes" = ooc_notes,
		"flavor_text_nsfw" = null,
		"ooc_notes_nsfw" = null,
		"img_gallery" = list(),
		"img_gallery_nsfw" = list(),
		"has_song" = FALSE,
		"is_vet" = holder?.check_agevet(), // crown — whether the examined familiar's owner is age-verified
		"is_naked" = FALSE,
	)
	return data

// Most examine data lives here because it does not update mid-view.
/datum/examine_panel/ui_static_data(mob/user)
	var/flavor_text
	var/flavor_text_nsfw
	var/obscured = FALSE
	var/ooc_notes = ""
	var/ooc_notes_nsfw
	var/headshot = ""
	var/list/img_gallery = list()
	var/list/img_gallery_nsfw = list()
	var/char_name
	var/song_url
	var/has_song = FALSE
	var/is_vet = FALSE
	var/is_naked = FALSE
	var/nsfw_examine_always = FALSE // examined character's opt-in to show NSFW even when clothed
	// NSFW is only revealed to age-verified viewers (or admins); enforced by the strip below.
	var/can_see_nsfw = user && (user.check_agevet() || (user.client && check_rights_for(user.client, R_ADMIN)))

	if(ishuman(holder))
		var/mob/living/carbon/human/holder_human = holder
		if(!(holder.wear_armor && holder.wear_armor.flags_inv) && !(holder.wear_shirt && holder.wear_shirt.flags_inv))
			is_naked = TRUE
		nsfw_examine_always = holder.client?.prefs?.nsfw_examine_always // opt-in: show NSFW even when clothed
		obscured = ((!isobserver(user)) && !holder_human.client?.prefs?.masked_examine) && ((holder_human.wear_mask && (holder_human.wear_mask.flags_inv & HIDEFACE)) || (holder_human.head && (holder_human.head.flags_inv & HIDEFACE)))
		flavor_text = obscured ? "Obscured" : holder.flavortext_display
		flavor_text_nsfw = obscured ? "Obscured" : holder.nsfwflavortext_display
		ooc_notes += holder.ooc_notes_display
		ooc_notes_nsfw += holder.erpprefs_display
		char_name = holder.name
		song_url = holder.song_url
		is_vet = holder.check_agevet() // crown indicator — whether the EXAMINED character's player is age-verified
		if(!obscured)
			if(holder.ooc_extra)
				flavor_text = "[flavor_text][holder.ooc_extra]" // SFW OOC extra media embed
			if(holder.nsfw_ooc_extra)
				flavor_text_nsfw = "[flavor_text_nsfw][holder.nsfw_ooc_extra]" // NSFW extra (stripped below for non-vetted viewers)
			headshot = holder.headshot_link
			img_gallery = holder.img_gallery
			img_gallery_nsfw = holder.nsfw_img_gallery
		if(!headshot)
			headshot = "headshot_red.png"

	else if(pref)
		is_naked = TRUE
		obscured = FALSE
		flavor_text = pref.flavortext_display
		flavor_text_nsfw = pref.nsfwflavortext_display
		ooc_notes = pref.ooc_notes_display
		ooc_notes_nsfw = pref.erpprefs_display
		headshot = pref.headshot_link
		img_gallery = pref.img_gallery
		img_gallery_nsfw = pref.nsfw_img_gallery
		char_name = pref.real_name
		song_url = pref.song_url
		is_vet = user.check_agevet() // preview shows your own character — crown reflects you, the owner
		if(pref.ooc_extra)
			flavor_text = "[flavor_text][pref.ooc_extra]"
		if(pref.nsfw_ooc_extra)
			flavor_text_nsfw = "[flavor_text_nsfw][pref.nsfw_ooc_extra]" // stripped below for non-vetted viewers
		if(!headshot)
			headshot = "headshot_red.png"

	// NSFW is for age-verified viewers (or admins) only — strip it so it never reaches anyone else's client.
	if(!can_see_nsfw)
		flavor_text_nsfw = null
		ooc_notes_nsfw = null
		img_gallery_nsfw = list()

	if(song_url)
		has_song = TRUE

	var/list/data = list(
		// Identity
		"character_name" = obscured ? "Unknown" : char_name,
		"headshot" = headshot,
		"obscured" = obscured ? TRUE : FALSE,
		// Descriptions
		"flavor_text" = flavor_text,
		"ooc_notes" = ooc_notes,
		// Descriptions requiring manual input to reveal
		"flavor_text_nsfw" = flavor_text_nsfw,
		"ooc_notes_nsfw" = ooc_notes_nsfw,
		"img_gallery" = img_gallery,
		"img_gallery_nsfw" = img_gallery_nsfw,
		"has_song" = has_song,
		"is_vet" = is_vet,
		"is_naked" = is_naked,
		"nsfw_examine_always" = nsfw_examine_always,
	)
	return data

/datum/examine_panel/ui_data(mob/user)
	var/list/data = list(
		"is_playing" = is_playing,
	)
	return data

/datum/examine_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(!viewing)
		return

	var/client/C = viewing.client
	var/web_sound_url
	var/artist_name = "Song Artist Hidden"
	var/song_name
	var/list/music_extra_data = list()

	if(ishuman(holder))
		web_sound_url = holder.song_url
		if(holder.song_artist)
			artist_name = holder.song_artist
		song_name = holder.song_title
	else if(pref)
		web_sound_url = pref.song_url
		if(pref.song_artist)
			artist_name = pref.song_artist
		song_name = pref.song_title

	switch(action)
		if("toggle")
			if(!C || !web_sound_url)
				return
			if(!is_playing)
				is_playing = TRUE
				music_extra_data["link"] = web_sound_url
				music_extra_data["title"] = song_name
				music_extra_data["duration"] = "Song Duration Hidden"
				music_extra_data["artist"] = artist_name
				C.tgui_panel?.play_music(web_sound_url, music_extra_data)
			else
				is_playing = FALSE
				C.tgui_panel?.stop_music()
			return TRUE
		if("vet_chat")
			to_chat(viewing, span_boldgreen("This player is age-verified!"))
			return TRUE

/datum/examine_panel/ui_close()
	QDEL_NULL(src)

/datum/examine_panel/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/headshot_imgs),
	)

/datum/asset/simple/headshot_imgs
	assets = list(
		"headshot_background.png" = 'icons/tgui/headshot_background.png',
		"headshot_red.png" = 'icons/tgui/headshot_red.png',
	)
