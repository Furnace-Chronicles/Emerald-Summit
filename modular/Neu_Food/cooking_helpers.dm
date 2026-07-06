/* 
	Helper(s) for getting cooking speed. 
	Eventually a universal recipe system should be implemented instead of calling this proc everywhere
 	But for now this will do
	+50% Cooking Speed (except -25% for lowest level) is super 
*/

#define SKILL_LEVEL_NONE_DIVISOR 0.75
#define SKILL_LEVEL_NOVICE_DIVISOR 1
#define SKILL_LEVEL_APPRENTICE_DIVISOR 1.5
#define SKILL_LEVEL_JOURNEYMAN_DIVISOR 2
#define SKILL_LEVEL_EXPERT_DIVISOR 2.5
#define SKILL_LEVEL_MASTER_DIVISOR 3
#define SKILL_LEVEL_LEGENDARY_DIVISOR 3.5

// Technically this is also a multiplier depending on what proc you're calling it on lmao
/proc/get_cooktime_divisor(skill_level = SKILL_LEVEL_NONE)
	var/divisor = SKILL_LEVEL_NONE_DIVISOR
	switch(skill_level)
		if(SKILL_LEVEL_NONE)
			divisor = SKILL_LEVEL_NONE_DIVISOR
		if(SKILL_LEVEL_NOVICE)
			divisor = SKILL_LEVEL_NOVICE_DIVISOR
		if(SKILL_LEVEL_APPRENTICE)
			divisor = SKILL_LEVEL_APPRENTICE_DIVISOR
		if(SKILL_LEVEL_JOURNEYMAN)
			divisor = SKILL_LEVEL_JOURNEYMAN_DIVISOR
		if(SKILL_LEVEL_EXPERT)
			divisor = SKILL_LEVEL_EXPERT_DIVISOR
		if(SKILL_LEVEL_MASTER)
			divisor = SKILL_LEVEL_MASTER_DIVISOR
		if(SKILL_LEVEL_LEGENDARY)
			divisor = SKILL_LEVEL_LEGENDARY_DIVISOR

	return divisor

#undef SKILL_LEVEL_NONE_DIVISOR
#undef SKILL_LEVEL_NOVICE_DIVISOR
#undef SKILL_LEVEL_APPRENTICE_DIVISOR
#undef SKILL_LEVEL_JOURNEYMAN_DIVISOR
#undef SKILL_LEVEL_EXPERT_DIVISOR
#undef SKILL_LEVEL_MASTER_DIVISOR
#undef SKILL_LEVEL_LEGENDARY_DIVISOR

/*
	Effort-based cooking timing for the Neu_Food slap-craft recipe system (SScooking).
	Ported from Azure-Peak code/modules/farming/helpers.dm. Distinct from get_cooktime_divisor
	above: scales a do_after time per step by cooking skill (skill 0 = x1.0, legendary = higher).
*/
/proc/get_cooking_effort_multiplier(mob/user, factor = 2)
	return (10 + (user.get_skill_level(/datum/skill/craft/cooking) * factor)) * 0.1

/proc/get_cooking_do_time(mob/user, time)
	return time / get_cooking_effort_multiplier(user, 3)

/*
	Skill-gated cooking-progress readouts for examine(). The EXAMINER's cooking skill decides how much
	detail they see about a food item cooking in an oven or a pan:
	  L0 (None)        - nothing here (the appliance shows a single "something is inside" line itself).
	  L1 (Novice)      - a rough status phrase ("just started" ... "almost there").
	  L2 (Apprentice)+ - the above, plus an approximate percent done.
	  L3 (Journeyman)+ - the above, plus an estimated time remaining.
	`base_increment` is the per-tick cooking gain the appliance applies (oven 10, hearth pan 20) and
	`cook` is the active cook whose skill sets the real cooking rate (used only for the time estimate).
	`active` is whether the appliance is currently lit — when FALSE the time-remaining line is omitted
	(food doesn't progress while the fire is out).
	Returns a list of examine line strings (possibly empty).
*/
/proc/cooking_progress_lines(mob/examiner, obj/item/reagent_containers/food/snacks/food, base_increment, mob/cook, active = TRUE)
	. = list()
	if(!istype(food))
		return
	if(food.eat_effect == /datum/status_effect/debuff/burnedfood)
		. += span_warning("\The [food] is burnt!")
		return
	if(!food.cooktime) // nothing time-based left to cook; don't invent progress
		return
	var/skill = examiner ? examiner.get_skill_level(/datum/skill/craft/cooking) : SKILL_LEVEL_NONE
	if(skill < SKILL_LEVEL_NOVICE)
		return
	var/fraction = clamp(food.cooking / food.cooktime, 0, 1)
	. += "\The [food]: [cooking_status_phrase(fraction)]"
	if(skill >= SKILL_LEVEL_APPRENTICE)
		. += "It is about [round(fraction * 100)]% cooked."
	if(active && skill >= SKILL_LEVEL_JOURNEYMAN && fraction < 1)
		var/divisor = get_cooktime_divisor(cook ? cook.get_skill_level(/datum/skill/craft/cooking) : SKILL_LEVEL_NONE)
		// Ovens/hearths process on SSweather (wait = 1 ds), adding base_increment * divisor each tick,
		// so the deciseconds remaining equal the number of ticks remaining.
		var/ds_left = (food.cooktime - food.cooking) / max(base_increment * divisor, 1)
		. += "It should be ready in about [cooking_time_phrase(ds_left)]."

/// Maps a 0..1 cooking fraction to a flavor status phrase (Novice+ readout).
/proc/cooking_status_phrase(fraction)
	switch(fraction)
		if(0 to 0.1)
			return "it has just started cooking."
		if(0.1 to 0.45)
			return "it is coming along."
		if(0.45 to 0.65)
			return "it seems about half-done."
		if(0.65 to 0.9)
			return "it is almost there."
		else
			return "it looks nearly done!"

/// Renders a deciseconds duration as a rough "Xm Ys"/"Ys" string for the Journeyman+ time readout.
/proc/cooking_time_phrase(deciseconds)
	var/seconds = round(deciseconds / 10)
	if(seconds < 1)
		return "a moment"
	if(seconds < 60)
		return "[seconds] second\s"
	var/minutes = round(seconds / 60)
	var/rem = seconds % 60
	if(!rem)
		return "[minutes] minute\s"
	return "[minutes] minute\s and [rem] second\s"

