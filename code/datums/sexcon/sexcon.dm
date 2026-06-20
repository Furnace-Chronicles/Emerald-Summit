#define SEX_ZONE_NULL				0
#define SEX_ZONE_GROIN				(1<<0)
#define SEX_ZONE_GROIN_GRAB			(1<<1)
#define SEX_ZONE_L_FOOT				(1<<2)
#define SEX_ZONE_R_FOOT				(1<<3)
#define SEX_ZONE_MOUTH				(1<<4)
#define SEX_ZONE_CHEST				(1<<5)
#define SEX_ZONE_CHEST_GRAB			(1<<6)

/datum/sex_controller
	/// The user and the owner of the controller
	var/mob/living/carbon/human/user
	/// Target of our actions, can be ourself
	var/mob/living/carbon/human/target
	/// Who is targeting us
	// Disabled as it'd require properly stopping actions when the popup is closed.
	// Different behavior which might be invasive.
	//var/receiving = list()
	/// Whether the user desires to stop his current action
	var/desire_stop = FALSE
	/// What is the current performed action
	var/current_action = null
	/// Enum of desired speed
	var/speed = SEX_SPEED_MID
	/// Enum of desired force
	var/force = SEX_FORCE_MID
	/// Our arousal
	var/arousal = 0
	///Makes genital arousal automatic by default
	var/manual_arousal = SEX_MANUAL_AROUSAL_DEFAULT
	/// Our charge gauge
	var/charge = SEX_MAX_CHARGE
	/// Whether we want to screw until finished, or non stop
	var/do_until_finished = TRUE
	/// The bed (if) we're occupying, update on starting an action
	var/obj/structure/bed/rogue/bed = null
	var/target_on_bed = FALSE
	/// The table/pillory (if) target is lying/latching on, update on starting an action
	var/obj/structure/table_or_pillory = null
	/// The bush (if) we're on top of, update on starting an action
	var/obj/structure/flora/roguegrass/grassy_knoll = null
	/// If this person has a collar that rings on
	var/collar_bell_user = FALSE
	var/collar_bell_target = FALSE
	/// Arousal won't change if active.
	var/arousal_frozen = FALSE
	var/last_arousal_increase_time = 0
	var/last_ejaculation_time = 0
	var/last_oral_drip_consume_time = 0
	var/last_moan = 0
	var/last_pain = 0
	var/aphrodisiac = 1 //1 by default, acts as a multiplier on arousal gain. If this is different than 1, set/freeze arousal is disabled.
	/// Which zones we are using in the current action.
	var/using_zones = list()
	/// Cache body parts used for accessibility check
	var/access_zone_bitfield = SEX_ZONE_NULL
	/// Menu based variables
	var/action_category = SEX_CATEGORY_MISC
	/// Show progress bar
	var/show_progress = 1
	/// When TRUE, try_do_moan does nothing (used for actions that can be done subtly)
	var/suppress_moan = FALSE
	/// Allow players to decide if they want to subtly do this action or not (only for actions that can be done subtly)
	var/do_subtle_action = FALSE
	var/bottom_exposed = FALSE
	/// Knot based variables
	var/do_knot_action = FALSE
	var/do_knot_action_as_bottom = FALSE
	var/knotted_status = KNOTTED_NULL // knotted state and used to prevent multiple knottings when we do not handle that case
	var/knotted_part = SEX_PART_NULL // which orifice was knotted (bitflag)
	var/knotted_part_partner = SEX_PART_NULL // which orifice was knotted on partner (bitflag)
	var/knotted_forced_by_bottom = FALSE
	var/tugging_knot = FALSE
	var/tugging_knot_check = 0
	var/tugging_knot_blocked = FALSE
	var/mob/living/carbon/knotted_owner = null // whom has the knot
	var/mob/living/carbon/knotted_recipient = null // whom took the knot

/datum/sex_controller/New(mob/living/carbon/human/owner)
	user = owner
	charge = get_max_charge()

/datum/sex_controller/Destroy()
	//remove_from_target_receiving()
	user = null
	target = null
	bed = null
	table_or_pillory = null
	grassy_knoll = null
	collar_bell_user = FALSE
	collar_bell_target = FALSE
	if(knotted_status)
		knot_exit()
	//receiving = list()
	. = ..()

/datum/sex_controller/proc/do_thrust_animate(atom/movable/target, pixels = 4, time = 2.7)
	var/oldx = user.pixel_x
	var/oldy = user.pixel_y
	var/target_x = oldx
	var/target_y = oldy
	var/dir = get_dir(user, target)
	if(user.loc == target.loc)
		dir = user.dir
	if(speed > SEX_SPEED_MID && time > 1)
		time -= 0.25
	if(force < SEX_FORCE_MID && pixels > 2)
		pixels -= 1
	switch(dir)
		if(NORTH)
			target_y += pixels
		if(SOUTH)
			target_y -= pixels
		if(WEST)
			target_x -= pixels
		if(EAST)
			target_x += pixels

	animate(user, pixel_x = target_x, pixel_y = target_y, time = time)
	animate(pixel_x = oldx, pixel_y = oldy, time = time)
	if(bed && force > SEX_FORCE_MID)
		if(!istype(bed) || QDELETED(bed))
			bed = null
			target_on_bed = FALSE
			return
		oldy = bed.pixel_y
		target_y = oldy-1
		time /= 2
		animate(bed, pixel_y = target_y, time = time)
		animate(pixel_y = oldy, time = time)
		if(target_on_bed && target)
			oldy = target.pixel_y
			target_y = oldy-1
			animate(target, pixel_y = target_y, time = time)
			animate(pixel_y = oldy, time = time)
		bed.damage_bed(force > SEX_FORCE_HIGH ? 0.5 : 0.25)
	else if(table_or_pillory && target && force > SEX_FORCE_MID)
		if(!istype(table_or_pillory) || QDELETED(table_or_pillory))
			table_or_pillory = null
			return
		oldy = table_or_pillory.pixel_y
		target_y = oldy-1
		time /= 2
		animate(table_or_pillory, pixel_y = target_y, time = time)
		animate(pixel_y = oldy, time = time)
		oldy = target.pixel_y
		target_y = oldy-1
		animate(target, pixel_y = target_y, time = time)
		animate(pixel_y = oldy, time = time)
		playsound(table_or_pillory, pick(list('sound/misc/mat/table (1).ogg','sound/misc/mat/table (2).ogg','sound/misc/mat/table (3).ogg','sound/misc/mat/table (4).ogg')), 30, TRUE, ignore_walls = FALSE)
	else if(grassy_knoll)
		if(!istype(grassy_knoll) || QDELETED(grassy_knoll))
			grassy_knoll = null
			return
		SEND_SIGNAL(grassy_knoll, COMSIG_MOVABLE_CROSSED, user)
	
	if((collar_bell_user || collar_bell_target) && (force > SEX_FORCE_MID))
		playsound(collar_bell_target && target ? target : user, SFX_COLLARJINGLE, 50, TRUE, ignore_walls = FALSE)

/obj/structure/bed/rogue
	var/broken_matress = FALSE
	var/broken_percentage = 0

/obj/structure/bed/rogue/proc/damage_bed(dam_value)
	if(sleepy <= 2) // the bed is already pretty awful and broken (i.e: straw bed/bedroll), so don't break it even further
		return
	broken_percentage += dam_value
	if(!broken_matress && (broken_percentage >= 100))
		broken_matress = TRUE
		sleepy = 1 //Worse than a bedroll, better than nothing
		visible_message(span_warning("\The [src] gives an violent snap. It looks broken!"))
		playsound(src, 'sound/misc/mat/bed break.ogg', 50, TRUE, ignore_walls = FALSE)
		desc += " The bed looks stained and has seen better daes."
	else if(broken_percentage >= 100) // clamp
		broken_percentage = 100
	else
		playsound(src, pick(list('sound/misc/mat/bed squeak (1).ogg','sound/misc/mat/bed squeak (2).ogg','sound/misc/mat/bed squeak (3).ogg')), 30, TRUE, ignore_walls = FALSE)
		if(broken_percentage > 10)
			playsound(src, 'sound/misc/mat/bed damage.ogg', broken_percentage>>2, TRUE, ignore_walls = FALSE)

/datum/sex_controller/proc/is_spent()
	if(charge < CHARGE_FOR_CLIMAX)
		return TRUE
	return FALSE

// any new sex commands that target new locations, will need to be added here, and given a unique bitflag define
/datum/sex_controller/proc/update_all_accessible_body_zones()
	access_zone_bitfield = SEX_ZONE_NULL
	if(bottom_exposed || get_location_accessible(user, BODY_ZONE_PRECISE_GROIN, grabs = FALSE, skipundies = TRUE))
		access_zone_bitfield |= SEX_ZONE_GROIN
	if(bottom_exposed || get_location_accessible(user, BODY_ZONE_PRECISE_GROIN, grabs = TRUE, skipundies = TRUE))
		access_zone_bitfield |= SEX_ZONE_GROIN_GRAB
	if(get_location_accessible(user, BODY_ZONE_PRECISE_L_FOOT, grabs = FALSE, skipundies = TRUE))
		access_zone_bitfield |= SEX_ZONE_L_FOOT
	if(get_location_accessible(user, BODY_ZONE_PRECISE_R_FOOT, grabs = FALSE, skipundies = TRUE))
		access_zone_bitfield |= SEX_ZONE_R_FOOT
	if(get_location_accessible(user, BODY_ZONE_PRECISE_MOUTH, grabs = FALSE, skipundies = TRUE))
		access_zone_bitfield |= SEX_ZONE_MOUTH
	if(get_location_accessible(user, BODY_ZONE_CHEST, grabs = FALSE, skipundies = TRUE))
		access_zone_bitfield |= SEX_ZONE_CHEST
	if(get_location_accessible(user, BODY_ZONE_CHEST, grabs = TRUE, skipundies = TRUE))
		access_zone_bitfield |= SEX_ZONE_CHEST_GRAB

// only check active accessible body zones
/datum/sex_controller/proc/update_current_accessible_body_zones(body_zone, grabs)
	switch(body_zone)
		if(BODY_ZONE_PRECISE_GROIN)
			if(grabs)
				if((access_zone_bitfield&SEX_ZONE_GROIN_GRAB) && !bottom_exposed && !get_location_accessible(user, BODY_ZONE_PRECISE_GROIN, grabs = TRUE, skipundies = TRUE))
					access_zone_bitfield &= ~SEX_ZONE_GROIN_GRAB
			else if((access_zone_bitfield&SEX_ZONE_GROIN) && !bottom_exposed && !get_location_accessible(user, BODY_ZONE_PRECISE_GROIN, grabs = FALSE, skipundies = TRUE))
				access_zone_bitfield &= ~SEX_ZONE_GROIN
		if(BODY_ZONE_PRECISE_L_FOOT)
			if((access_zone_bitfield&SEX_ZONE_L_FOOT) && !get_location_accessible(user, BODY_ZONE_PRECISE_L_FOOT, grabs = FALSE, skipundies = TRUE))
				access_zone_bitfield &= ~SEX_ZONE_L_FOOT
		if(BODY_ZONE_PRECISE_R_FOOT)
			if((access_zone_bitfield&SEX_ZONE_R_FOOT) && !get_location_accessible(user, BODY_ZONE_PRECISE_R_FOOT, grabs = FALSE, skipundies = TRUE))
				access_zone_bitfield &= ~SEX_ZONE_R_FOOT
		if(BODY_ZONE_PRECISE_MOUTH)
			if((access_zone_bitfield&SEX_ZONE_MOUTH) && !get_location_accessible(user, BODY_ZONE_PRECISE_MOUTH, grabs = FALSE, skipundies = TRUE))
				access_zone_bitfield &= ~SEX_ZONE_MOUTH
		if(BODY_ZONE_CHEST)
			if(grabs)
				if((access_zone_bitfield&SEX_ZONE_CHEST_GRAB) && !get_location_accessible(user, BODY_ZONE_CHEST, grabs = TRUE, skipundies = TRUE))
					access_zone_bitfield &= ~SEX_ZONE_CHEST_GRAB
			else if((access_zone_bitfield&SEX_ZONE_CHEST) && !get_location_accessible(user, BODY_ZONE_CHEST, grabs = FALSE, skipundies = TRUE))
				access_zone_bitfield &= ~SEX_ZONE_CHEST
		else
		 	// hey YOU, add the new targeted zone to SEX_ZONE bitfield, and update update_all_accessible_body_zones()/get_accessible_body_zone()
			CRASH("sex_action: attempt to access non-existent bitfield for var body_zone_bitfield [body_zone]")

/datum/sex_controller/proc/get_accessible_body_zone(body_zone_bitfield, body_zone, grabs)
	switch(body_zone)
		if(BODY_ZONE_PRECISE_GROIN)
			if(grabs)
				return (body_zone_bitfield&SEX_ZONE_GROIN_GRAB) != SEX_ZONE_NULL
			return (body_zone_bitfield&SEX_ZONE_GROIN) != SEX_ZONE_NULL
		if(BODY_ZONE_PRECISE_L_FOOT)
			return (body_zone_bitfield&SEX_ZONE_L_FOOT) != SEX_ZONE_NULL
		if(BODY_ZONE_PRECISE_R_FOOT)
			return (body_zone_bitfield&SEX_ZONE_R_FOOT) != SEX_ZONE_NULL
		if(BODY_ZONE_PRECISE_MOUTH)
			return (body_zone_bitfield&SEX_ZONE_MOUTH) != SEX_ZONE_NULL
		if(BODY_ZONE_CHEST)
			if(grabs)
				return (body_zone_bitfield&SEX_ZONE_CHEST_GRAB) != SEX_ZONE_NULL
			return (body_zone_bitfield&SEX_ZONE_CHEST) != SEX_ZONE_NULL
	// hey YOU, add the new targeted zone to SEX_ZONE bitfield, and update update_all_accessible_body_zones()/update_current_accessible_body_zones()
	CRASH("sex_action: attempt to access non-existent bitfield for var body_zone_bitfield [body_zone]")

/datum/sex_action/proc/check_location_accessible(mob/living/carbon/human/user, mob/living/carbon/human/target, location = BODY_ZONE_CHEST, grabs = FALSE)
	var/obj/item/bodypart/bodypart = target.get_bodypart(location)

	var/self_target = FALSE
	var/datum/sex_controller/user_controller = user.sexcon
	if(user_controller.target == user)
		self_target = TRUE

	var/signalargs = list(src, bodypart, self_target)
	signalargs += args

	var/sigbitflags = SEND_SIGNAL(target, COMSIG_ERP_LOCATION_ACCESSIBLE, signalargs)
	bodypart = signalargs[ERP_BODYPART]

	if(sigbitflags & SIG_CHECK_FAIL)
		return FALSE

	if(!bodypart)
		return FALSE

	if(!(sigbitflags & SKIP_ADJACENCY_CHECK) && !user.Adjacent(target))
		return FALSE

	if(src.check_same_tile && (user != target || self_target) && !(sigbitflags & SKIP_TILE_CHECK))
		var/same_tile = (get_turf(user) == get_turf(target))
		var/grab_bypass = (src.aggro_grab_instead_same_tile && user.get_highest_grab_state_on(target) == GRAB_AGGRESSIVE)
		if(!same_tile && !grab_bypass)
			return FALSE

	if(src.require_grab && (user != target || self_target) && !(sigbitflags & SKIP_GRAB_CHECK))
		var/grabstate = user.get_highest_grab_state_on(target)
		if((grabstate == null || grabstate < src.required_grab_state))
			return FALSE

	if(!isnull(user_controller.current_action) && user_controller.current_action == src.type) // action is active, update the currently accessible body zones
		target.sexcon.update_current_accessible_body_zones(location, grabs)
	var/result = user_controller.get_accessible_body_zone(target.sexcon.access_zone_bitfield, location, grabs)
	if(result && user == target && !(bodypart in user_controller.using_zones) && user_controller.current_action == SEX_ACTION(src))
		user_controller.using_zones += location
	
	return result

/datum/sex_controller/proc/finished_check()
	if(!do_until_finished)
		return FALSE
	if(!just_ejaculated())
		return FALSE
	return TRUE

/datum/sex_controller/proc/adjust_speed(amt)
	// Cabbits are quick by nature — they reach the top speed without needing the "Bed Breaker" (TRAIT_DEATHBYSNUSNU) build.
	var/is_cabbit = istype(user.dna?.species, /datum/species/shapecabbit)
	var/max_setting = (is_cabbit || HAS_TRAIT(user, TRAIT_DEATHBYSNUSNU) || HAS_TRAIT(user, TRAIT_DEPRAVED) || user.has_status_effect(/datum/status_effect/debuff/emberwine)) ? SEX_SPEED_MAX : SEX_SPEED_MAX - 1
	speed = clamp(speed + amt, SEX_SPEED_MIN, max_setting)

/datum/sex_controller/proc/adjust_force(amt)
	var/max_setting = (HAS_TRAIT(user, TRAIT_DEATHBYSNUSNU) || HAS_TRAIT(user, TRAIT_DEPRAVED) || user.has_status_effect(/datum/status_effect/debuff/emberwine)) ? SEX_FORCE_MAX : SEX_FORCE_MAX - 1
	force = clamp(force + amt, SEX_FORCE_MIN, max_setting)
/datum/sex_controller/proc/adjust_arousal_manual(amt)
	manual_arousal = clamp(manual_arousal + amt, SEX_MANUAL_AROUSAL_MIN, SEX_MANUAL_AROUSAL_MAX)

/datum/sex_controller/proc/update_pink_screen()
	var/severity = 0
	switch(arousal)
		if(1 to 10)
			severity = 1
		if(10 to 20)
			severity = 2
		if(20 to 30)
			severity = 3
		if(30 to 40)
			severity = 4
		if(40 to 50)
			severity = 5
		if(50 to 60)
			severity = 6
		if(60 to 70)
			severity = 7
		if(70 to 80)
			severity = 8
		if(80 to 90)
			severity = 9
		if(90 to INFINITY)
			severity = 10
	if(severity > 0)
		user.overlay_fullscreen("horny", /atom/movable/screen/fullscreen/love, severity)
	else
		user.clear_fullscreen("horny")

/datum/sex_controller/proc/start(mob/living/carbon/human/new_target)
	if(!ishuman(new_target))
		return
	set_target(new_target)
	show_ui()

/datum/sex_controller/proc/cum_onto(mob/living/carbon/human/splashed_user = null, cum_on_face = TRUE)
	var/mob/living/carbon/human/effective_target = splashed_user || target
	log_combat(user, effective_target, "Came onto the target")
	if(effective_target)
		playsound(effective_target, 'sound/misc/mat/endout.ogg', 50, TRUE, ignore_walls = FALSE)
	var/obj/item/organ/testicles/testes = user.getorganslot(ORGAN_SLOT_TESTICLES)
	add_cum_floor(get_turf(effective_target || user), do_big_puddle = testes?.ball_size > DEFAULT_TESTICLES_SIZE)
	if(splashed_user)
		if(cum_on_face)
			var/datum/status_effect/facial/facial = splashed_user.has_status_effect(/datum/status_effect/facial)
			if(!facial)
				splashed_user.apply_status_effect(/datum/status_effect/facial)
				if(splashed_user != user)
					splashed_user.visible_message(span_love("[splashed_user] takes a load on their face!"), span_love("I take a load on my face!"))
			else
				facial.refresh_cum()
		else
			var/datum/status_effect/facial/external/external = splashed_user.has_status_effect(/datum/status_effect/facial/external)
			if(!external)
				splashed_user.apply_status_effect(/datum/status_effect/facial/external)
				if(splashed_user != user)
					splashed_user.visible_message(span_love("[splashed_user] takes a load on their body!"), span_love("I take a load on my body!"))
			else
				external.refresh_cum()
	if(effective_target?.has_flaw(/datum/charflaw/addiction/lovefiend))
		effective_target.sate_addiction(/datum/charflaw/addiction/lovefiend)
	after_ejaculation()

/datum/sex_controller/proc/cum_into(oral = FALSE, mob/living/carbon/human/splashed_user = null, datum/sex_action/knot_action = null, knot_swap_roles = FALSE, mob/living/carbon/human/knot_btm = null, orifice = SEX_PART_NULL, skip_knot_try = FALSE, consume_charge = TRUE)
	var/mob/living/carbon/human/effective_target = splashed_user || target
	log_combat(user, effective_target, "Came inside the target")
	werewolf_sex_infect_attempt(user, effective_target)
	if(oral)
		playsound(user, pick(list('sound/misc/mat/mouthend (1).ogg','sound/misc/mat/mouthend (2).ogg')), 100, FALSE, ignore_walls = FALSE)
	else
		playsound(user, 'sound/misc/mat/endin.ogg', 100, TRUE, ignore_walls = FALSE)
	if(!skip_knot_try && consume_charge && (knot_btm || (user != effective_target && !isnull(effective_target) && istype(effective_target))))
		knot_try(knot_action = knot_action, knot_swap_roles = knot_swap_roles, knot_btm = knot_btm)
	var/datum/sex_controller/receiver_sexcon = splashed_user?.sexcon
	var/is_receiver_actively_knotted_to_user = receiver_sexcon?.knotted_status == KNOTTED_AS_BTM && receiver_sexcon?.knotted_owner == user
	if(receiver_sexcon && (oral || !receiver_sexcon.knotted_status || is_receiver_actively_knotted_to_user))
		var/status_type = !oral ? /datum/status_effect/facial/internal : /datum/status_effect/facial
		var/datum/status_effect/facial/splashed_type = splashed_user.has_status_effect(status_type)
		if(!splashed_type)
			splashed_user.apply_status_effect(status_type)
			if(oral)
				splashed_user.visible_message(span_love("[splashed_user] takes a load down their throat!"), span_love("I take a load down my throat!"))
			else
				splashed_user.visible_message(span_love("[splashed_user] takes a load inside them!"), span_love("I take a load inside me!"))
		else
			splashed_type.refresh_cum()
		if(!oral && user?.dna?.species?.id == "gnoll")
			splashed_user.has_gnoll_scent_this_round = TRUE
		if(oral && splashed_user.reagents)
			if(user.getorganslot(ORGAN_SLOT_PENIS))
				splashed_user.reagents.add_reagent(/datum/reagent/erpjuice/cum, get_semen_volume())
			else
				splashed_user.reagents.add_reagent(/datum/reagent/erpjuice/femcum, 2)
			apply_cum_consumed_buff(splashed_user)
		if(!oral)
			var/obj/item/organ/testicles/testes = user.getorganslot(ORGAN_SLOT_TESTICLES)
			if(!is_receiver_actively_knotted_to_user)
				apply_creampie_drip(splashed_user, orifice, use_long = testes?.ball_size > DEFAULT_TESTICLES_SIZE)
	if(effective_target?.has_flaw(/datum/charflaw/addiction/lovefiend))
		effective_target.sate_addiction(/datum/charflaw/addiction/lovefiend)
	after_ejaculation(consume_charge)

	//EVIL ASS LEVELDRAIN
	if(HAS_TRAIT(user, TRAIT_DEPRAVED) && user.cmode)
		var/datum/status_effect/buff/baothasbanquet/boost_buff = user.has_status_effect(/datum/status_effect/buff/baothasbanquet)
		if(boost_buff)
			boost_buff.tier_up(effective_target)
		else
			boost_buff = user.apply_status_effect(/datum/status_effect/buff/baothasbanquet)
			boost_buff.poor_bastards += effective_target
		var/datum/status_effect/debuff/baothadrained/drain_debuff = effective_target?.has_status_effect(/datum/status_effect/debuff/baothadrained)
		if(drain_debuff)
			drain_debuff.tier_up()
		else if(effective_target)
			effective_target.apply_status_effect(/datum/status_effect/debuff/baothadrained)
		if(effective_target)
			effective_target.playsound_local(user, 'sound/misc/mat/lvldown.ogg', 100)
	if(HAS_TRAIT(target, TRAIT_DEPRAVED) && target?.cmode)
		var/datum/status_effect/buff/baothasbanquet/boost_buff = target.has_status_effect(/datum/status_effect/buff/baothasbanquet)
		if(boost_buff)
			boost_buff.tier_up(user)
		else
			boost_buff = target.apply_status_effect(/datum/status_effect/buff/baothasbanquet)
			boost_buff.poor_bastards += user
		var/datum/status_effect/debuff/baothadrained/drain_debuff = user.has_status_effect(/datum/status_effect/debuff/baothadrained)
		if(drain_debuff)
			drain_debuff.tier_up()
		else
			user.apply_status_effect(/datum/status_effect/debuff/baothadrained)
		user.playsound_local(user, 'sound/misc/mat/lvldown.ogg', 100)

	after_intimate_climax(oral, splashed_user)

/datum/status_effect/facial
	id = "facial"
	alert_type = null // don't show an alert on screen
	tick_interval = 12 MINUTES // use this time as our dry count down
	var/has_dried_up = FALSE // used as our dry status

/datum/status_effect/facial/internal
	id = "creampie"
	alert_type = null // don't show an alert on screen
	tick_interval = 7 MINUTES // use this time as our dry count down

/datum/status_effect/facial/external
	id = "cumshot"
	alert_type = null // don't show an alert on screen
	tick_interval = 10 MINUTES // use this time as our dry count down

/datum/status_effect/creampie_leak
	id = "creampie_leak"
	alert_type = null // don't show an alert on screen
	tick_interval = 12 SECONDS
	duration = 60 SECONDS
	var/contents_to_drip = /datum/reagent/erpjuice/cum
	var/orifice = SEX_PART_NULL

/datum/status_effect/creampie_leak/on_creation(mob/living/new_owner, orifice_in = SEX_PART_NULL)
	orifice = orifice_in
	return ..(new_owner)

/datum/status_effect/creampie_leak/long
	id = "creampie_leak_long"
	alert_type = null // don't show an alert on screen
	tick_interval = 12 SECONDS
	duration = 120 SECONDS

/datum/status_effect/facial/on_apply()
	RegisterSignal(owner, list(COMSIG_COMPONENT_CLEAN_ACT, COMSIG_COMPONENT_CLEAN_FACE_ACT),PROC_REF(clean_up))
	has_dried_up = FALSE
	return ..()

/datum/status_effect/facial/on_remove()
	UnregisterSignal(owner, list(COMSIG_COMPONENT_CLEAN_ACT, COMSIG_COMPONENT_CLEAN_FACE_ACT))
	return ..()

/datum/status_effect/facial/tick()
	has_dried_up = TRUE

/datum/status_effect/facial/proc/refresh_cum()
	has_dried_up = FALSE
	tick_interval = world.time + initial(tick_interval)

///Callback to remove pearl necklace
/datum/status_effect/facial/proc/clean_up(datum/source, strength)
	if(strength >= CLEAN_WEAK && !QDELETED(owner))
		if(!owner.has_stress_event(/datum/stressevent/bathcleaned))
			to_chat(owner, span_notice("I feel much cleaner now!"))
			owner.add_stress(/datum/stressevent/bathcleaned)
		owner.remove_status_effect(src)

/datum/status_effect/creampie_leak/on_apply()
	RegisterSignal(owner, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(clean_up))
	to_chat(owner, span_love("I feel a warmth beginning to leak out of me."))
	return ..()

/datum/status_effect/creampie_leak/on_remove()
	UnregisterSignal(owner, COMSIG_COMPONENT_CLEAN_ACT)
	return ..()

/datum/status_effect/creampie_leak/proc/clean_up(datum/source, strength)
	if(strength >= CLEAN_WEAK && !QDELETED(owner))
		to_chat(owner, span_notice("I feel much cleaner now."))
		owner.remove_status_effect(src)

/datum/status_effect/creampie_leak/tick()
	if(!owner?.sexcon?.bottom_exposed && !get_location_accessible(owner, BODY_ZONE_PRECISE_GROIN, skipundies = TRUE))
		return
	var/cur_loc = get_turf(owner)
	if(!cur_loc || !isturf(cur_loc))
		return
	add_cum_floor(cur_loc)
	playsound(owner, pick('sound/misc/bleed (1).ogg', 'sound/misc/bleed (2).ogg', 'sound/misc/bleed (3).ogg'), 20, TRUE, -2, ignore_walls = FALSE)
	var/obj/item/reagent_containers/glass/cum_chalice = locate() in cur_loc
	if(!cum_chalice?.spillable)
		return
	cum_chalice.reagents.add_reagent(contents_to_drip, 1)

/datum/sex_controller/proc/ejaculate()
	log_combat(user, user, "Ejaculated")
	// If we climax while knotted into someone as the top, deposit into them instead of just making a floor mess.
	if(user.getorganslot(ORGAN_SLOT_PENIS) && knotted_status == KNOTTED_AS_TOP && knotted_owner == user && ishuman(knotted_recipient) && !QDELETED(knotted_recipient) && knotted_recipient?.sexcon)
		var/orifice = knotted_part_partner
		var/is_oral_knot = (orifice & SEX_PART_JAWS) != SEX_PART_NULL
		var/knotted_climax_msg = is_oral_knot ? "[user] climaxes down [knotted_recipient]'s throat!" : "[user] climaxes deep inside [knotted_recipient]!"
		user.visible_message(span_love(knotted_climax_msg))
		cum_into(oral = is_oral_knot, splashed_user = knotted_recipient, orifice = orifice, skip_knot_try = TRUE)
		return
	user.visible_message(span_love("[user] makes a mess!"))
	playsound(user, 'sound/misc/mat/endout.ogg', 50, TRUE, ignore_walls = FALSE)
	var/obj/item/organ/testicles/testes = user.getorganslot(ORGAN_SLOT_TESTICLES)
	add_cum_floor(get_turf(user), do_big_puddle = testes?.ball_size > DEFAULT_TESTICLES_SIZE)
	after_ejaculation()

/datum/sex_controller/proc/after_ejaculation(consume_charge = TRUE)
	set_arousal(40)
	if(consume_charge)
		adjust_charge(-CHARGE_FOR_CLIMAX)
	else
		to_chat(user, span_love("<i>Spurt!</i>"))
	if(user.has_flaw(/datum/charflaw/addiction/lovefiend))
		user.sate_addiction()
	user.add_stress(/datum/stressevent/cumok)
	user.emote("sexmoanhvy", forced = TRUE)
	user.playsound_local(user, 'sound/misc/mat/end.ogg', 100)
	last_ejaculation_time = world.time
	record_round_statistic(STATS_PLEASURES)

/datum/sex_controller/proc/after_intimate_climax(oral, mob/living/carbon/human/climax_target = null)
	var/mob/living/carbon/human/effective_target = climax_target || target
	if(user == effective_target || isnull(effective_target) || !istype(effective_target) || QDELETED(effective_target))
		return
	if(!oral)
		if(HAS_TRAIT(effective_target, TRAIT_GOODLOVER))
			if(!user.mob_timers["cumtri"])
				user.mob_timers["cumtri"] = world.time
				user.adjust_triumphs(1)
				to_chat(user, span_love("Our loving is a true TRIUMPH!"))
		if(HAS_TRAIT(user, TRAIT_GOODLOVER))
			if(!effective_target.mob_timers["cumtri"])
				effective_target.mob_timers["cumtri"] = world.time
				effective_target.adjust_triumphs(1)
				to_chat(effective_target, span_love("Our loving is a true TRIUMPH!"))

	var/user_goodlover = HAS_TRAIT(user, TRAIT_GOODLOVER)
	var/target_goodlover = HAS_TRAIT(effective_target, TRAIT_GOODLOVER)
	var/user_beautiful = HAS_TRAIT(user, TRAIT_BEAUTIFUL)
	var/user_ugly = HAS_TRAIT(user, TRAIT_UNSEEMLY) || HAS_TRAIT(user, TRAIT_DISFIGURED)
	var/target_beautiful = HAS_TRAIT(effective_target, TRAIT_BEAUTIFUL)
	var/target_ugly = HAS_TRAIT(effective_target, TRAIT_UNSEEMLY) || HAS_TRAIT(effective_target, TRAIT_DISFIGURED)
	if((user_ugly && target_ugly) || (user_beautiful && target_beautiful)) // both ugly or both beautiful: mutual made-love buff
		user.add_stress(/datum/stressevent/cummax)
		effective_target.add_stress(/datum/stressevent/cummax)
	else // mismatched looks: debuff the non-ugly partner (good lovers are immune to ugly partners)
		if(target_ugly && !user_ugly && !user_goodlover)
			if(user_beautiful) // beautiful folk take it harder, for longer
				user.add_stress(/datum/stressevent/unseemly_made_love/beautiful)
			else
				user.add_stress(/datum/stressevent/unseemly_made_love)
			effective_target.add_stress(/datum/stressevent/cummax)
		if(user_ugly && !target_ugly && !target_goodlover)
			if(target_beautiful)
				effective_target.add_stress(/datum/stressevent/unseemly_made_love/beautiful)
			else
				effective_target.add_stress(/datum/stressevent/unseemly_made_love)
			user.add_stress(/datum/stressevent/cummax)
	if(!oral && force >= SEX_FORCE_HIGH && user.has_flaw(/datum/charflaw/addiction/sadist)) // sadist top forces a pain emote
		effective_target.emote("paincrit", forced = TRUE)

	if(ishuman(user) && ishuman(effective_target) && user.client && effective_target.client)
		eora_register_consensual_pair(user, effective_target)

/// Applies or accumulates a creampie drip status effect, correctly ORing new orifice flags onto an existing drip rather than silently dropping the second application.
/proc/apply_creampie_drip(mob/living/carbon/human/target, orifice, use_long = FALSE)
	var/datum/status_effect/creampie_leak/existing = target.has_status_effect(/datum/status_effect/creampie_leak/long) || target.has_status_effect(/datum/status_effect/creampie_leak)
	if(existing)
		existing.orifice |= orifice
		to_chat(target, span_love("I feel another warmth beginning to leak out of me."))
		existing.duration = world.time + initial(existing.duration)
		return
	if(use_long)
		target.apply_status_effect(/datum/status_effect/creampie_leak/long, orifice)
	else
		target.apply_status_effect(/datum/status_effect/creampie_leak, orifice)

/datum/sex_controller/proc/apply_cum_consumed_buff(mob/living/carbon/human/consumer)
	if(!consumer)
		return FALSE
	consumer.apply_status_effect(/datum/status_effect/buff/cum_consumed)
	return TRUE

/datum/sex_controller/proc/consume_oral_drips(mob/living/carbon/human/source)
	if(!source || !user || !source.sexcon)
		return FALSE

	var/datum/status_effect/creampie_leak/drip = source.has_status_effect(/datum/status_effect/creampie_leak/long)
	if(!drip)
		drip = source.has_status_effect(/datum/status_effect/creampie_leak)
	if(!drip)
		return FALSE

	if(last_oral_drip_consume_time + 3 SECONDS > world.time)
		return FALSE
	last_oral_drip_consume_time = world.time

	var/datum/status_effect/facial/facial = user.has_status_effect(/datum/status_effect/facial)
	if(!facial)
		user.apply_status_effect(/datum/status_effect/facial)
	else
		facial.refresh_cum()

	if(user.reagents)
		var/drip_type = drip.contents_to_drip || /datum/reagent/erpjuice/cum
		user.reagents.add_reagent(drip_type, 1)
	apply_cum_consumed_buff(user)

	user.visible_message(span_love("[user] laps up the fluids leaking from [source]!"), span_love("I lap up the fluids leaking from [source]!"))

	if(drip.duration <= world.time + 6 SECONDS)
		if(istype(drip, /datum/status_effect/creampie_leak/long))
			source.remove_status_effect(/datum/status_effect/creampie_leak/long)
		else
			source.remove_status_effect(/datum/status_effect/creampie_leak)
	else
		drip.duration -= 6 SECONDS
	return TRUE

/datum/sex_controller/proc/just_ejaculated()
	return (last_ejaculation_time + 2 SECONDS >= world.time)

/// Volume of semen produced per climax, scaled by testicle size, the GOODLOVER trait, and knotted/equine shafts.
/datum/sex_controller/proc/get_semen_volume()
	var/obj/item/organ/testicles/testes = user.getorganslot(ORGAN_SLOT_TESTICLES)
	if(!testes)
		return 0
	var/volume
	switch(testes.ball_size)
		if(MIN_TESTICLES_SIZE)
			volume = 2
		if(MAX_TESTICLES_SIZE)
			volume = 4
		else
			volume = 3
	if(HAS_TRAIT(user, TRAIT_GOODLOVER))
		volume = floor(volume * 1.5)

	var/obj/item/organ/penis/shaft = user.getorganslot(ORGAN_SLOT_PENIS)
	if(shaft?.penis_type in list(PENIS_TYPE_KNOTTED, PENIS_TYPE_EQUINE, PENIS_TYPE_EQUINE_KNOTTED, PENIS_TYPE_TAPERED_KNOTTED, PENIS_TYPE_TAPERED_DOUBLE_KNOTTED, PENIS_TYPE_BARBED_KNOTTED))
		volume += 1

	return volume

/// Number of cum bursts (reagent/visual spurts) per climax, based on semen volume.
/datum/sex_controller/proc/get_load_bursts()
	switch(get_semen_volume())
		if(4)
			return 2
		if(5 to INFINITY)
			return 3
		else
			return 1

/// How many climaxes worth of charge we can hold, scaled by testicle size, CON, the GOODLOVER/BIGGUY traits, and gnoll species.
/datum/sex_controller/proc/get_max_loads()
	var/con = user.STACON
	var/minimum_loads = 3
	var/obj/item/organ/testicles/testes = user.getorganslot(ORGAN_SLOT_TESTICLES)
	if(testes)
		switch(testes.ball_size)
			if(MIN_TESTICLES_SIZE)
				minimum_loads = 2
			if(MAX_TESTICLES_SIZE)
				minimum_loads = 4
	var/loads = minimum_loads + floor(clamp((con - 10) * 2, 0, 99) / 2)
	if(HAS_TRAIT(user, TRAIT_GOODLOVER))
		loads *= 1.5
	if(HAS_TRAIT(user, TRAIT_BIGGUY))
		loads *= 1.5
	if(is_species(user, /datum/species/gnoll))
		loads *= 1.5
	return floor(loads)

/// Returns the max charge based on dynamic load count
/datum/sex_controller/proc/get_max_charge()
	return get_max_loads() * CHARGE_FOR_CLIMAX

/datum/sex_controller/proc/set_charge(amount)
	var/empty = (charge < CHARGE_FOR_CLIMAX)
	charge = clamp(amount, 0, get_max_charge())
	var/after_empty = (charge < CHARGE_FOR_CLIMAX)
	if(empty && !after_empty)
		to_chat(user, span_notice("I feel like I'm not so spent anymore"))
	if(!empty && after_empty)
		to_chat(user, span_notice("I'm spent!"))

/datum/sex_controller/proc/adjust_charge(amount)
	set_charge(charge + amount)

/datum/sex_controller/proc/handle_charge(dt)
	if(user.has_flaw(/datum/charflaw/addiction/lovefiend))
		dt *= 2
	if(HAS_TRAIT(user, TRAIT_DEPRAVED))
		dt *= 2
	adjust_charge(dt * CHARGE_RECHARGE_RATE)
	if(is_spent())
		if(arousal > 60)
			to_chat(user, span_warning("I'm too spent!"))
			adjust_arousal(-20)
		adjust_arousal(-dt * SPENT_AROUSAL_RATE)

/datum/sex_controller/proc/set_arousal(amount)
	if(amount > arousal)
		last_arousal_increase_time = world.time
	arousal = clamp(amount, 0, MAX_AROUSAL)
	update_pink_screen()
	update_blueballs()
	update_erect_state()

/datum/sex_controller/proc/update_erect_state()
	var/obj/item/organ/penis/penis = user.getorganslot(ORGAN_SLOT_PENIS)

	if(user.mind)
		var/datum/antagonist/werewolf/W = user.mind.has_antag_datum(/datum/antagonist/werewolf/)
		if(W && W.transformed == TRUE)
			user.regenerate_icons()

	if(penis && hascall(penis, "update_erect_state"))
		penis.update_erect_state()

/datum/sex_controller/proc/update_exposure()
	user.regenerate_icons()

/datum/sex_controller/proc/adjust_arousal(amount)
	if(aphrodisiac > 1 && amount > 0)
		set_arousal(arousal + (amount * aphrodisiac))
	else set_arousal(arousal + amount)

/datum/sex_controller/proc/perform_deepthroat_oxyloss(mob/living/carbon/human/action_target, oxyloss_amt)
	var/oxyloss_multiplier = 0
	switch(force)
		if(SEX_FORCE_LOW)
			oxyloss_multiplier = 0
		if(SEX_FORCE_MID)
			oxyloss_multiplier = 0
		if(SEX_FORCE_HIGH)
			oxyloss_multiplier = 1.0
		if(SEX_FORCE_EXTREME)
			oxyloss_multiplier = 2.0
		if(SEX_FORCE_LUDICROUS)
			oxyloss_multiplier = 3.0
	oxyloss_amt *= oxyloss_multiplier
	if(oxyloss_amt <= 0)
		return
	action_target.adjustOxyLoss(oxyloss_amt)

/datum/sex_controller/proc/perform_sex_action(mob/living/carbon/human/action_target, arousal_amt, pain_amt, giving)
	action_target.sexcon.receive_sex_action(arousal_amt, pain_amt, giving, force, speed)

/datum/sex_controller/proc/receive_sex_action(arousal_amt, pain_amt, giving, applied_force, applied_speed)
	arousal_amt *= get_force_pleasure_multiplier(applied_force, giving)
	pain_amt *= get_force_pain_multiplier(applied_force)
	pain_amt *= get_speed_pain_multiplier(applied_speed)

	if(user.stat == DEAD)
		arousal_amt = 0
		pain_amt = 0

	if(HAS_TRAIT(user, TRAIT_DEPRAVED))
		pain_amt *= 0.66

	if(!arousal_frozen)
		adjust_arousal(arousal_amt)

	damage_from_pain(pain_amt)
	try_do_moan(arousal_amt, pain_amt, applied_force, giving)
	try_do_pain_effect(pain_amt, giving)

/datum/sex_controller/proc/damage_from_pain(pain_amt)
	if(pain_amt < PAIN_MINIMUM_FOR_DAMAGE)
		return
	var/damage = (pain_amt / PAIN_DAMAGE_DIVISOR)
	var/obj/item/bodypart/part = user.get_bodypart(BODY_ZONE_CHEST)
	if(!part)
		return
	user.apply_damage(damage, BRUTE, part)

/datum/sex_controller/proc/try_do_moan(arousal_amt, pain_amt, applied_force, giving)
	if(arousal_amt < 1.5)
		return
	if(user.stat != CONSCIOUS)
		return
	if(last_moan + MOAN_COOLDOWN >= world.time)
		return
	if(prob(50))
		return
	var/chosen_emote
	switch(arousal_amt)
		if(0 to 5)
			chosen_emote = "sexmoanlight"
		if(5 to INFINITY)
			chosen_emote = "sexmoanhvy"

	if(pain_amt >= PAIN_MILD_EFFECT)
		if(giving)
			if(prob(30))
				chosen_emote = "groan"
		else
			if(prob(40))
				chosen_emote = "painmoan"
	if(pain_amt >= PAIN_MED_EFFECT)
		if(giving)
			if(prob(50))
				chosen_emote = "groan"
		else
			if(prob(60))
				chosen_emote = "painmoan"

	last_moan = world.time
	user.emote(chosen_emote, forced = TRUE)

/datum/sex_controller/proc/try_do_pain_effect(pain_amt, giving)
	if(pain_amt < PAIN_MILD_EFFECT)
		return
	if(last_pain + PAIN_COOLDOWN >= world.time)
		return
	if(prob(50))
		return
	last_pain = world.time
	if(pain_amt >= PAIN_HIGH_EFFECT)
		var/pain_msg = pick(list("IT HURTS!!!", "IT NEEDS TO STOP!!!", "I CAN'T TAKE IT ANYMORE!!!"))
		to_chat(user, span_boldwarning(pain_msg))
		user.flash_fullscreen("redflash2")
		if(prob(70) && user.stat == CONSCIOUS)
			user.visible_message(span_warning("[user] shudders in pain!"))
	else if(pain_amt >= PAIN_MED_EFFECT)
		var/pain_msg = pick(list("It hurts!", "It pains me!"))
		to_chat(user, span_boldwarning(pain_msg))
		user.flash_fullscreen("redflash1")
		if(prob(40) && user.stat == CONSCIOUS)
			user.visible_message(span_warning("[user] shudders in pain!"))
	else
		var/pain_msg = pick(list("It hurts a little...", "It stings...", "I'm aching..."))
		to_chat(user, span_warning(pain_msg))

/datum/sex_controller/proc/update_blueballs()
	if(arousal >= BLUEBALLS_GAIN_THRESHOLD)
		user.add_stress(/datum/stressevent/blueb)
	else if (arousal <= BLUEBALLS_LOOSE_THRESHOLD)
		user.remove_stress(/datum/stressevent/blueb)

/datum/sex_controller/proc/check_active_ejaculation()
	if(arousal < ACTIVE_EJAC_THRESHOLD)
		return FALSE
	if(is_spent())
		return FALSE
	if(!can_ejaculate())
		return FALSE
	return TRUE

/datum/sex_controller/proc/can_ejaculate()
	if(!user.getorganslot(ORGAN_SLOT_TESTICLES) && !user.getorganslot(ORGAN_SLOT_VAGINA))
		return FALSE
	if(HAS_TRAIT(user, TRAIT_LIMPDICK))
		return FALSE
	return TRUE

/datum/sex_controller/proc/handle_passive_ejaculation(var/mob/living/carbon/human/splashed_user = null)
	var/mob/living/carbon/human/M = user
	if(aphrodisiac > 1.5)
		if(M.check_handholding())
			if(prob(5)) //Yeah.
				try_do_moan(3, 0, 1, 0)
			if(arousal < 70)
				adjust_arousal(0.2)
		if(M.handcuffed)
			if(prob(8))
				var/chaffepain = pick(10,10,10,10,20,20,30)
				try_do_moan(3, chaffepain, 1, 0)
				damage_from_pain(chaffepain)
				try_do_pain_effect(chaffepain)
				last_moan = 0
				M.visible_message(("<span class='love_mid'>[M] squirms uncomfortably in [M.p_their()] restraints.</span>"), \
					("<span class='love_extreme'>I feel [M.handcuffed] rub uncomfortably against my skin.</span>"))
			if(arousal < ACTIVE_EJAC_THRESHOLD)
				adjust_arousal(0.25)
			else
				if(prob(3))
					ejaculate()
					if(splashed_user)
						var/datum/status_effect/facial/facial = splashed_user.has_status_effect(/datum/status_effect/facial)
						if(!facial)
							splashed_user.apply_status_effect(/datum/status_effect/facial)
						else
							facial.refresh_cum()
	if(arousal < PASSIVE_EJAC_THRESHOLD)
		return
	if(is_spent())
		return
	if(!can_ejaculate())
		return FALSE
	ejaculate()
	if(splashed_user)
		var/datum/status_effect/facial/facial = splashed_user.has_status_effect(/datum/status_effect/facial)
		if(!facial)
			splashed_user.apply_status_effect(/datum/status_effect/facial)
		else
			facial.refresh_cum()

/datum/sex_controller/proc/ejaculate_container(obj/item/reagent_containers/glass/C)
	if(C && istype(C))
		log_combat(user, user, "Ejaculated into a container")
		user.visible_message(span_love("[user] spills into [C]!"))
		playsound(user, 'sound/misc/mat/endout.ogg', 50, TRUE, ignore_walls = FALSE)
		if(user.getorganslot(ORGAN_SLOT_PENIS))
			C.reagents.add_reagent(/datum/reagent/erpjuice/cum, get_semen_volume())
		else
			C.reagents.add_reagent(/datum/reagent/erpjuice/femcum, 2)
	after_ejaculation()

/datum/sex_controller/proc/handle_cock_milking(mob/living/carbon/human/milker)
	if(arousal < ACTIVE_EJAC_THRESHOLD)
		return
	if(is_spent())
		return
	if(!can_ejaculate())
		return FALSE
	ejaculate_container(milker.get_active_held_item())

/datum/sex_controller/proc/handle_container_ejaculation()
	if(arousal < PASSIVE_EJAC_THRESHOLD)
		return
	if(is_spent())
		return
	if(!can_ejaculate())
		return FALSE
	ejaculate_container(user.get_active_held_item())

/datum/sex_controller/proc/can_use_penis()
	if(HAS_TRAIT(user, TRAIT_LIMPDICK))
		return FALSE
	var/obj/item/organ/penis/penor = user.getorganslot(ORGAN_SLOT_PENIS)
	if(!penor)
		return FALSE
	if(!penor.functional)
		return FALSE
	return TRUE

/datum/sex_controller/proc/considered_limp()
	if(arousal >= AROUSAL_HARD_ON_THRESHOLD)
		return FALSE
	return TRUE

/datum/sex_controller/proc/process_sexcon(dt)
	handle_arousal_unhorny(dt)
	handle_charge(dt)
	handle_passive_ejaculation()

/datum/sex_controller/proc/handle_arousal_unhorny(dt)
	if(arousal_frozen)
		return
	if(!can_ejaculate())
		adjust_arousal(-dt * IMPOTENT_AROUSAL_LOSS_RATE)
	if(last_arousal_increase_time + AROUSAL_TIME_TO_UNHORNY >= world.time)
		return
	var/rate
	switch(arousal)
		if(-INFINITY to 25)
			rate = AROUSAL_LOW_UNHORNY_RATE
		if(25 to 40)
			rate = AROUSAL_MID_UNHORNY_RATE
		if(40 to INFINITY)
			rate = AROUSAL_HIGH_UNHORNY_RATE
	adjust_arousal(-dt * rate)

/datum/sex_controller/proc/show_ui()
	var/list/dat = list()
	var/force_name = get_force_string()
	var/speed_name = get_speed_string()
	var/manual_arousal_name = get_manual_arousal_string()
	var/obj/item/organ/penis/got_cock = user.getorganslot(ORGAN_SLOT_PENIS)
	var/obj/item/organ/vagina/got_pussy = user.getorganslot(ORGAN_SLOT_VAGINA)
	dat += "<center><a href='?src=[REF(src)];task=speed_down'>\<</a> [speed_name] <a href='?src=[REF(src)];task=speed_up'>\></a> ~|~ <a href='?src=[REF(src)];task=force_down'>\<</a> [force_name] <a href='?src=[REF(src)];task=force_up'>\></a>"
	if(user.getorganslot(ORGAN_SLOT_PENIS))
		dat += " ~|~ <a href='?src=[REF(src)];task=manual_arousal_down'>\<</a> [manual_arousal_name] <a href='?src=[REF(src)];task=manual_arousal_up'>\></a>"
	dat += "</center><center><a href='?src=[REF(src)];task=toggle_finished'>[do_until_finished ? "UNTIL IM FINISHED" : "UNTIL I STOP"]</a>"
	if(got_cock && !got_pussy)
		dat += "</center><center><a href='?src=[REF(src)];task=toggle_bottom_exposed'>[bottom_exposed ? "PINTLE EXPOSED" : "PINTLE CONCEALED"]</a>"
	else if(!got_cock && got_pussy)
		dat += "</center><center><a href='?src=[REF(src)];task=toggle_bottom_exposed'>[bottom_exposed ? "PUSSY EXPOSED" : "PUSSY CONCEALED"]</a>"
	else
		dat += "</center><center><a href='?src=[REF(src)];task=toggle_bottom_exposed'>[bottom_exposed ? "CROTCH EXPOSED" : "CROTCH CONCEALED"]</a>"
	if(current_action && !desire_stop)
		var/datum/sex_action/action = SEX_ACTION(current_action)
		if(action.subtle_supported)
			if(do_subtle_action)
				dat += " | <a href='?src=[REF(src)];task=toggle_subtle'>DOING SUBTLY</a>"
			else
				dat += " | <a href='?src=[REF(src)];task=toggle_subtle'>DOING VISIBLY</a>"
		if(action.knot_on_finish)
			if((action.user_sex_part & SEX_PART_COCK) && knot_penis_type())
				if(do_knot_action)
					dat += " | <a href='?src=[REF(src)];task=toggle_knot'><font color='#d146f5'>USING KNOT</font></a>"
				else
					dat += " | <a href='?src=[REF(src)];task=toggle_knot'><font color='#eac8de'>NOT USING KNOT</font></a>"
			else if((action.target_sex_part & SEX_PART_COCK) && target?.sexcon?.knot_penis_type())
				if(do_knot_action_as_bottom)
					dat += " | <a href='?src=[REF(src)];task=toggle_knot_bottom'><font color='#d146f5'>FORCING KNOT</font></a>"
				else
					dat += " | <a href='?src=[REF(src)];task=toggle_knot_bottom'><font color='#eac8de'>NOT FORCING KNOT</font></a>"
	dat += "</center><center><a href='?src=[REF(src)];task=set_arousal'>SET AROUSAL</a> | <a href='?src=[REF(src)];task=freeze_arousal'>[arousal_frozen ? "UNFREEZE AROUSAL" : "FREEZE AROUSAL"]</a></center>"
	if(target == user)
		dat += "<center>Doing unto yourself</center>"
	else
		dat += "<center>Doing unto [target]'s</center>"
	if(current_action && !desire_stop)
		dat += "<center><a href='?src=[REF(src)];task=stop'>Stop</a></center>"
	else
		dat += "<br>"
	dat += "<center><a href='?src=[REF(src)];task=category_misc'>[action_category == SEX_CATEGORY_MISC ? "<font color='#eac8de'>OTHER</font>" : "OTHER"]</a> | "
	dat += "<a href='?src=[REF(src)];task=category_hands'>[action_category == SEX_CATEGORY_HANDS ? "<font color='#eac8de'>HANDS</font>" : "HANDS"]</a> | "
	dat += "<a href='?src=[REF(src)];task=category_penetrate'>[action_category == SEX_CATEGORY_PENETRATE ? "<font color='#eac8de'>PENETRATE</font>" : "PENETRATE"]</a></center>"
	dat += "<table width='100%'><td width='50%'></td><td width='50%'></td><tr>"
	var/i = 0
	var/user_is_incapacitated = user.incapacitated()
	user.sexcon.update_all_accessible_body_zones()
	if(target != user)
		target.sexcon.update_all_accessible_body_zones()
	for(var/action_type in GLOB.sex_actions)
		var/datum/sex_action/action = SEX_ACTION(action_type)
		if(!(action_category&action.category))
			continue
		if(!action.shows_on_menu(user, target))
			continue
		dat += "<td>"
		var/link = ""
		if(!can_perform_action(action_type, user_is_incapacitated))
			link = "linkOff"
		if(current_action == action_type)
			link = "linkOn"
		dat += "<center><a class='[link]' href='?src=[REF(src)];task=action;action_type=[action_type]'>[action.name]</a></center>"
		dat += "</td>"
		i++
		if(i >= 2)
			i = 0
			dat += "</tr><tr>"

	dat += "</tr></table>"
	var/datum/browser/popup = new(user, "sexcon", "<center>Sate Desire</center>", 500, 550)
	popup.set_content(dat.Join())
	popup.open()
	return

/datum/sex_controller/Topic(href, href_list)
	if(usr != user)
		return
	switch(href_list["task"])
		if("action")
			var/action_path = text2path(href_list["action_type"])
			var/datum/sex_action/action = SEX_ACTION(action_path)
			if(!action)
				return
			try_start_action(action_path)
		if("stop")
			try_stop_current_action()
		if("speed_up")
			adjust_speed(1)
		if("speed_down")
			adjust_speed(-1)
		if("force_up")
			adjust_force(1)
		if("force_down")
			adjust_force(-1)
		if("manual_arousal_up")
			adjust_arousal_manual(1)
		if("manual_arousal_down")
			adjust_arousal_manual(-1)
		if("toggle_finished")
			do_until_finished = !do_until_finished
		if("toggle_bottom_exposed")
			if(user.incapacitated(ignore_restraints = TRUE))
				to_chat(user, span_warning("I can't do that right now!"))
			else
				bottom_exposed = !bottom_exposed
				update_exposure()
		if("set_arousal")
			var/amount = input(user, "Value above 120 will immediately cause orgasm!", "Set Arousal", arousal) as num
			if(aphrodisiac > 1 && amount > 0)
				set_arousal(amount * aphrodisiac)
			else
				set_arousal(amount)
		if("freeze_arousal")
			if(aphrodisiac == 1)
				arousal_frozen = !arousal_frozen
		if("category_misc")
			action_category = SEX_CATEGORY_MISC
		if("category_hands")
			action_category = SEX_CATEGORY_HANDS
		if("category_penetrate")
			action_category = SEX_CATEGORY_PENETRATE
		if("toggle_subtle")
			do_subtle_action = !do_subtle_action
		if("toggle_knot")
			do_knot_action = !do_knot_action
		if("toggle_knot_bottom")
			do_knot_action_as_bottom = !do_knot_action_as_bottom
	show_ui()

/datum/sex_controller/proc/try_stop_current_action()
	if(!current_action)
		return
	desire_stop = TRUE
	user.doing = FALSE

/datum/sex_controller/proc/stop_current_action()
	if(!current_action)
		return
	var/datum/sex_action/action = SEX_ACTION(current_action)
	if(!user.sexcon.knotted_status) // never show the remove message, unless unknotted
		action.on_finish(user, target)
	desire_stop = FALSE
	user.doing = FALSE
	current_action = null
	bed = null
	target_on_bed = FALSE
	table_or_pillory = null
	grassy_knoll = null
	collar_bell_user = FALSE
	collar_bell_target = FALSE
	using_zones = list()

/datum/sex_controller/proc/try_start_action(action_type)
	if(action_type == current_action)
		try_stop_current_action()
		return
	if(current_action != null)
		try_stop_current_action()
		return
	if(!action_type)
		return
	if(!can_perform_action(action_type, user.incapacitated()))
		return
	knot_check_remove(action_type)
	// Set vars
	desire_stop = FALSE
	current_action = action_type
	bed = null
	target_on_bed = FALSE
	table_or_pillory = null
	grassy_knoll = null
	collar_bell_user = FALSE
	collar_bell_target = FALSE
	var/datum/sex_action/action = SEX_ACTION(current_action)
	log_combat(user, target, "Started sex action: [action.name]")
	INVOKE_ASYNC(src, PROC_REF(sex_action_loop))

/datum/sex_controller/proc/sex_action_loop()
	// Do action loop
	var/performed_action_type = current_action
	var/datum/sex_action/action = SEX_ACTION(current_action)
	show_progress = 1
	suppress_moan = FALSE
	do_subtle_action = TRUE // always start subtle supported actions with subtle mode on
	action.on_start(user, target)
	find_occupying_furniture()
	find_occupying_grass()
	while(TRUE)
		if(target.ckey && !target.client) // partner has gone SSD (disconnected) - can't consent, stop immediately
			to_chat(user, span_warning("[target] has gone limp and unresponsive. I stop."))
			break
		if(!isnull(target.client) && target.client.prefs.sexable == FALSE) //Vrell - Needs changed to let me test sex mechanics solo
			break
		if(!user.stamina_add(action.stamina_cost * get_stamina_cost_multiplier()))
			break
		if(!do_after(user, (action.do_time / get_speed_multiplier()), target = target, progress = show_progress))
			break
		if(current_action == null || performed_action_type != current_action)
			break
		if(!can_perform_action(current_action, user.incapacitated()))
			break
		if(action.is_finished(user, target))
			break
		if(desire_stop)
			break
		find_ringing_collar()
		action.on_perform(user, target)
		// It could want to finish afterwards the performed action
		if(action.is_finished(user, target))
			break
		if(!action.continous)
			break
	stop_current_action()

/datum/sex_controller/proc/can_perform_action(action_type, incapacitated)
	if(!action_type)
		return FALSE
	var/datum/sex_action/action = SEX_ACTION(action_type)
	if(!inherent_perform_check(action_type, incapacitated))
		return FALSE
	if(!action.can_perform(user, target))
		return FALSE
	return TRUE

/datum/sex_controller/proc/find_occupying_furniture()
	if(bed)
		return
	if(target && isturf(target.loc)) // find target's bed/table
		if(!(target.mobility_flags & MOBILITY_STAND)) // if target is lying down
			bed = locate() in target.loc
			target_on_bed = TRUE
			if(!bed) // bed not found, try finding a table
				var/obj/structure/table/wood/table = locate() in target.loc
				table_or_pillory = table
		else // target standing up, check for pillory
			var/obj/structure/pillory/pillory = locate() in target.loc
			table_or_pillory = pillory
	if(!bed && !(user.mobility_flags & MOBILITY_STAND) && isturf(user.loc)) // find our bed
		bed = locate() in user.loc

/datum/sex_controller/proc/find_occupying_grass()
	if(grassy_knoll)
		return
	if(isturf(user.loc)) // find our grass
		grassy_knoll = locate() in user.loc

/datum/sex_controller/proc/find_ringing_collar()
	var/obj/item/clothing/neck/roguetown/collar/collar
	collar = user.get_item_by_slot(SLOT_NECK)
	collar_bell_user = collar && istype(collar) && collar.bellsound
	if(!target)
		collar_bell_target = FALSE
		return
	collar = target.get_item_by_slot(SLOT_NECK)
	collar_bell_target = collar && istype(collar) && collar.bellsound


/datum/sex_controller/proc/inherent_perform_check(action_type, incapacitated)
	var/datum/sex_action/action = SEX_ACTION(action_type)
	if(!target)
		return FALSE
	if(user.stat != CONSCIOUS)
		return FALSE
	if(target.ckey && !target.client) // partner is a disconnected (SSD) player - no consent, block starting/continuing
		return FALSE
	if(action.check_incapacitated && incapacitated)
		return FALSE
	return TRUE

/*
/datum/sex_controller/proc/remove_from_target_receiving()
	if(!target)
		return
	var/datum/sex_controller/target_con = target.sexcon
	if (user in target_con.receiving)
		target_con.receiving -= user
*/

/datum/sex_controller/proc/set_target(mob/living/carbon/human/new_target)
	//remove_from_target_receiving()
	target = new_target
	//var/datum/sex_controller/target_con = new_target.sexcon
	//target_con.receiving += user

/datum/sex_controller/proc/get_speed_multiplier()
	switch(speed)
		if(SEX_SPEED_LOW)
			return 1.0
		if(SEX_SPEED_MID)
			return 1.5
		if(SEX_SPEED_HIGH)
			return 2.0
		if(SEX_SPEED_EXTREME)
			return 2.5
		if(SEX_SPEED_LUDICROUS)
			return 3

/datum/sex_controller/proc/get_stamina_cost_multiplier()
	switch(force)
		if(SEX_FORCE_LOW)
			return 1.0
		if(SEX_FORCE_MID)
			return 1.5
		if(SEX_FORCE_HIGH)
			return 2.0
		if(SEX_FORCE_EXTREME)
			return 2.5
		if(SEX_FORCE_LUDICROUS)
			return 2.5

/datum/sex_controller/proc/get_force_pleasure_multiplier(passed_force, giving)
	switch(passed_force)
		if(SEX_FORCE_LOW)
			return 0.8
		if(SEX_FORCE_MID)
			return 1.2
		if(SEX_FORCE_HIGH)
			if(giving)
				return 1.6
			else
				return 1.2
		if(SEX_FORCE_EXTREME)
			if(giving)
				return 2.0
			else
				return 0.8
		if(SEX_FORCE_LUDICROUS)
			if(giving)
				return 2.0
			else
				return 0.8

/datum/sex_controller/proc/get_force_pain_multiplier(passed_force)
	switch(passed_force)
		if(SEX_FORCE_LOW)
			return 0.5
		if(SEX_FORCE_MID)
			return 1.0
		if(SEX_FORCE_HIGH)
			return 2.0
		if(SEX_FORCE_EXTREME)
			return 3.0
		if(SEX_FORCE_LUDICROUS)
			return 4.0

/datum/sex_controller/proc/get_speed_pain_multiplier(passed_speed)
	switch(passed_speed)
		if(SEX_SPEED_LOW)
			return 0.8
		if(SEX_SPEED_MID)
			return 1.0
		if(SEX_SPEED_HIGH)
			return 1.2
		if(SEX_SPEED_EXTREME)
			return 1.4
		if(SEX_SPEED_LUDICROUS)
			return 1.6

/datum/sex_controller/proc/get_force_string()
	switch(force)
		if(SEX_FORCE_LOW)
			return "<font color='#eac8de'>GENTLE</font>"
		if(SEX_FORCE_MID)
			return "<font color='#e9a8d1'>FIRM</font>"
		if(SEX_FORCE_HIGH)
			return "<font color='#f05ee1'>ROUGH</font>"
		if(SEX_FORCE_EXTREME)
			return "<font color='#d146f5'>BRUTAL</font>"
		if(SEX_FORCE_LUDICROUS)
			return "<font color='#d61a43'>FERAL</font>"

/datum/sex_controller/proc/get_speed_string()
	switch(speed)
		if(SEX_SPEED_LOW)
			return "<font color='#eac8de'>SLOW</font>"
		if(SEX_SPEED_MID)
			return "<font color='#e9a8d1'>STEADY</font>"
		if(SEX_SPEED_HIGH)
			return "<font color='#f05ee1'>QUICK</font>"
		if(SEX_SPEED_EXTREME)
			return "<font color='#d146f5'>UNRELENTING</font>"
		if(SEX_SPEED_LUDICROUS)
			return "<font color='#d61a43'>FURIOUS</font>"

/datum/sex_controller/proc/get_manual_arousal_string()
	switch(manual_arousal)
		if(SEX_MANUAL_AROUSAL_DEFAULT)
			return "<font color='#eac8de'>NATURAL</font>"
		if(SEX_MANUAL_AROUSAL_UNAROUSED)
			return "<font color='#e9a8d1'>UNAROUSED</font>"
		if(SEX_MANUAL_AROUSAL_PARTIAL)
			return "<font color='#f05ee1'>PARTIALLY ERECT</font>"
		if(SEX_MANUAL_AROUSAL_FULL)
			return "<font color='#d146f5'>FULLY ERECT</font>"
/datum/sex_controller/proc/get_knot_synonym()
	return pick(list("knot", "knot", "bulb", "plug"))

/datum/sex_controller/proc/get_generic_force_adjective(is_stealth = FALSE)
	if(is_stealth)
		return pick(list("subtly","sneakily","covertly","stealthily","quietly"))
	switch(force)
		if(SEX_FORCE_LOW)
			return pick(list("gently", "carefully", "tenderly", "gingerly", "delicately", "lazily"))
		if(SEX_FORCE_MID)
			return pick(list("firmly", "vigorously", "eagerly", "steadily", "intently"))
		if(SEX_FORCE_HIGH)
			return pick(list("roughly", "carelessly", "forcefully", "fervently", "fiercely"))
		if(SEX_FORCE_EXTREME)
			return pick(list("brutally", "violently", "relentlessly", "savagely", "mercilessly"))
		if(SEX_FORCE_LUDICROUS)
			return pick(list("madly", "uncontrollably", "desperately", "deliriously", "freekishly"))

/datum/sex_controller/proc/spanify_force(string)
	switch(force)
		if(SEX_FORCE_LOW)
			return "<span class='love_low'>[string]</span>"
		if(SEX_FORCE_MID)
			return "<span class='love_mid'>[string]</span>"
		if(SEX_FORCE_HIGH)
			return "<span class='love_high'>[string]</span>"
		if(SEX_FORCE_EXTREME)
			return "<span class='love_extreme'>[string]</span>"
		if(SEX_FORCE_LUDICROUS)
			return "<span class='love_ludicrous'>[string]</span>"

/datum/sex_controller/proc/try_pelvis_crush(mob/living/carbon/human/target)
	if(istype(user.rmb_intent, /datum/rmb_intent/strong) && force > SEX_FORCE_MID)
		if(prob(10) && !target.has_status_effect(/datum/status_effect/quivering))
			to_chat(user, "[target.p_they()] won't be walking straight now!")
			to_chat(target, "[user.p_theyre()] crushing me!")
			target.apply_status_effect(/datum/status_effect/quivering)
			target.confused += 25
			target.OffBalance(30 SECONDS)
		if(user.client.prefs.extreme_erp && target.client.prefs.extreme_erp)
			if(!target.has_wound(/datum/wound/fracture/groin))
				if(prob(10))
					var/obj/item/bodypart/groin = target.get_bodypart(check_zone(BODY_ZONE_PRECISE_GROIN))
					groin.add_wound(/datum/wound/fracture)

/datum/sex_controller/proc/try_jaw_crush(mob/living/carbon/human/target)
	if(istype(user.rmb_intent, /datum/rmb_intent/strong) && force > SEX_FORCE_MID)
		if(user.client.prefs.extreme_erp && target.client.prefs.extreme_erp)
			if(!target.has_wound(/datum/wound/fracture/mouth))
				if(prob(10))
					var/obj/item/bodypart/mouth = target.get_bodypart(check_zone(BODY_ZONE_PRECISE_MOUTH))
					mouth.add_wound(/datum/wound/fracture)
		if(prob(10) && !target.has_status_effect(/datum/status_effect/jaw_gaped) && !target.has_wound(/datum/wound/fracture/mouth))
			to_chat(user, "[target.p_they()] won't be talking much now!")
			target.apply_status_effect(/datum/status_effect/jaw_gaped)
			target.apply_status_effect(/datum/status_effect/debuff/dazed)

/datum/status_effect/quivering
	id = "quivering"
	duration = 30 SECONDS
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/quivering
	effectedstats = list("speed" = -2)

/atom/movable/screen/alert/status_effect/quivering
	name = "Quivering"
	desc = "I can barely walk..."
	icon_state = "quivering"

/datum/sex_controller/proc/can_zodomize()
	//Only thing we're currently checking for.
	var/obj/item/organ/vagina/vag = user.getorganslot(ORGAN_SLOT_VAGINA)
	if(vag && vag.monohole)
		return FALSE
	if(user.construct && !user.getorganslot(ORGAN_SLOT_VAGINA) && !user.getorganslot(ORGAN_SLOT_PENIS))
		return FALSE
	return TRUE

/proc/werewolf_sex_infect_attempt(mob/living/carbon/human/top, mob/living/carbon/human/bottom)

	if(!top || !bottom || !top.mind || !bottom.mind)
		return

	var/datum/antagonist/werewolf/WWtop
	var/datum/antagonist/werewolf/WWbottom
	var/infection_probability = 40
	if(top.mind.has_antag_datum(/datum/antagonist/werewolf))
		WWtop = top.mind.has_antag_datum(/datum/antagonist/werewolf/)

	if(bottom.mind.has_antag_datum(/datum/antagonist/werewolf))
		WWbottom = bottom.mind.has_antag_datum(/datum/antagonist/werewolf/)

	if(WWtop && WWbottom)
		return

	if(WWtop && WWtop.transformed && !WWbottom)
		if(prob(infection_probability))
			bottom.werewolf_infect_attempt()
			return

	if(WWbottom && WWbottom.transformed && !WWtop)
		if(prob(infection_probability))
			top.werewolf_infect_attempt()
			return

/datum/status_effect/buff/baothasbanquet
	id = "baothasbanquet"
	alert_type = /atom/movable/screen/alert/status_effect/buff/baothasbanquet
	effectedstats = list("strength" = 1, "intelligence" = 1, "perception" = 1 , "speed" = 1, "endurance" = 1, "constitution" = 1)
	duration = 30 MINUTES
	var/tier = 1
	var/list/poor_bastards = list()

/atom/movable/screen/alert/status_effect/buff/baothasbanquet
	name = "Baotha's Banquet (I)"
	desc = "I feel invigorated after partaking in another's energy."
	icon_state = "baothasbanquet"

/datum/status_effect/buff/baothasbanquet/proc/tier_up(var/mob/living/poor_sod)
	refresh()
	if(poor_sod in poor_bastards)
		return
	poor_bastards += poor_sod
	if(tier < 3)
		on_remove()
		tier++
		switch(tier)
			if(2)
				effectedstats = list("strength" = 2, "intelligence" = 2, "perception" = 2 , "speed" = 2, "endurance" = 2, "constitution" = 2)
				linked_alert.name = "Baotha's Banquet (II)"
				linked_alert.desc = "The strength of others nourishes me!"
			if(3)
				effectedstats = list("strength" = 3, "intelligence" = 3, "perception" = 3 , "speed" = 3, "endurance" = 3, "constitution" = 3)
				linked_alert.name = "Baotha's Banquet (III)"
				linked_alert.desc = "This power is ADDICTING!"
		on_apply()

/datum/status_effect/debuff/baothadrained
	id = "baothadrained"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/baothadrained
	effectedstats = list("strength" = -1, "intelligence" = -1, "perception" = -1 , "speed" = -1, "endurance" = -1, "constitution" = -1)
	duration = 30 MINUTES
	var/tier = 1

/atom/movable/screen/alert/status_effect/debuff/baothadrained
	name = "Vitality Drained (I)"
	desc = "That was exhausting..."
	icon_state = "baothadrained"

/datum/status_effect/debuff/baothadrained/proc/tier_up()
	refresh()
	if(tier < 3)
		on_remove()
		tier++
		switch(tier)
			if(2)
				effectedstats = list("strength" = -2, "intelligence" = -2, "perception" = -2 , "speed" = -2, "endurance" = -2, "constitution" = -2)
				linked_alert.name = "Vitality Drained (II)"
				linked_alert.desc = "That really took it out of me..."
			if(3)
				effectedstats = list("strength" = -3, "intelligence" = -3, "perception" = -3 , "speed" = -3, "endurance" = -3, "constitution" = -3)
				linked_alert.name = "Vitality Drained (III)"
				linked_alert.desc = "I feel like I lost a part of myself..."
		on_apply()

#undef SEX_ZONE_NULL
#undef SEX_ZONE_GROIN
#undef SEX_ZONE_GROIN_GRAB
#undef SEX_ZONE_L_FOOT
#undef SEX_ZONE_R_FOOT
#undef SEX_ZONE_MOUTH
#undef SEX_ZONE_CHEST
#undef SEX_ZONE_CHEST_GRAB
