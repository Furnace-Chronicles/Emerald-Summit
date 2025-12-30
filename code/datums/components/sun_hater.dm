
/datum/component/sunlight_vulnerability
	/// How much damage per tick in sunlight
	var/burn_damage = 5
	/// How much bloodpool drain per tick
	var/bloodpool_drain = 2.5
	/// Whether this mob is currently in sunlight
	var/in_sunlight = FALSE

/datum/component/sunlight_vulnerability/Initialize(damage = 5, drain = 10)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	burn_damage = damage
	bloodpool_drain = drain

	RegisterSignal(parent, COMSIG_HUMAN_LIFE, PROC_REF(check_sunlight))

/datum/component/sunlight_vulnerability/proc/check_sunlight(mob/living/source)
	var/mob/living/carbon/human/H = source
	if(!H || H.stat == DEAD || H.advsetup)
		return

	// Only check during day
	if(GLOB.tod != "day")
		in_sunlight = FALSE
		return

	// Check if outside and in light
	if(isturf(H.loc))
		var/turf/T = H.loc
		if(T.can_see_sky())
			if(!in_sunlight)
				in_sunlight = TRUE
				if(HAS_TRAIT(H, TRAIT_CRIMSON_CURSE))
					to_chat(H, span_danger("I can barely bear this accursed sun's gaze!"))
				else
					to_chat(H, span_danger("THE SUNLIGHT BURNS AND SEARS MY FLESH!!"))

			apply_sunlight_damage(H)
		else
			if(in_sunlight)
				to_chat(H, span_notice("The scorching gaze of the Sun-Tyrant burns me no more."))
			in_sunlight = FALSE
	else
		in_sunlight = FALSE

/datum/component/sunlight_vulnerability/proc/apply_sunlight_damage(mob/living/carbon/human/H)
	if(HAS_TRAIT(H, TRAIT_CRIMSON_CURSE))
		H.apply_status_effect(/datum/status_effect/debuff/sunspurn)
		return
	H.adjust_bloodpool(-bloodpool_drain)
	var/datum/component/vampire_disguise/disguise_comp = H.GetComponent(/datum/component/vampire_disguise)
	if(disguise_comp && disguise_comp.disguised)
		if(H.bloodpool > disguise_comp.min_bloodpool * 2)
			return
		disguise_comp.force_undisguise(H)
		to_chat(H, span_warning("The sunlight breaks my disguise!"))

	// Apply fire damage
	H.adjustFireLoss(40)
	H.adjust_fire_stacks(6, /datum/status_effect/fire_handler/fire_stacks/sunder)
	H.ignite_mob()

	// Freak out if on fire
	if(H.on_fire)
		H.freak_out()
