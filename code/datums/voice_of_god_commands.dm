#define COOLDOWN_STUN (60 SECONDS)
#define COOLDOWN_DAMAGE (30 SECONDS)
#define COOLDOWN_NONE (0 SECONDS)

/// Used to stop listeners with silly or clown-esque (first) names such as "Honk" or "Flip" from screwing up certain commands.
GLOBAL_DATUM(all_voice_of_god_triggers, /regex)
/// List of all voice of god commands
GLOBAL_LIST_INIT(voice_of_god_commands, init_voice_of_god_commands())

/proc/init_voice_of_god_commands()
	. = list()
	var/all_triggers
	var/separator
	for(var/datum/voice_of_god_command/prototype as anything in subtypesof(/datum/voice_of_god_command))
		var/init_trigger = initial(prototype.trigger)
		if(!init_trigger)
			continue
		. += new prototype
		all_triggers += "[separator][init_trigger]"
		separator = "|" // Shouldn't be at the start or end of the regex, or it won't work.
	GLOB.all_voice_of_god_triggers = regex(all_triggers, "i")

/// Voice of god command datums that are used in [/proc/voice_of_god()]
/datum/voice_of_god_command
	///a text string or regex that triggers the command.
	var/trigger
	/// Is the trigger supposed to be a regex? If so, convert it to such on New()
	var/is_regex = TRUE
	/// cooldown variable which is normally returned to [proc/voice_of_god] and used as its return value.
	var/cooldown = COOLDOWN_NONE
	/// How powerful the command is, ascending according to power. Higher tiers may have restrictions.
	var/tier = 1

/datum/voice_of_god_command/New()
	if(is_regex)
		trigger = regex(trigger)

/*
 * What happens when the command is triggered.
 * If a return value is set, it'll be used in place of the 'cooldown' var.
 * Args:
 * * listeners: the list of living mobs who are affected by the command.
 * * user: the one who casted Voice of God
 * * power_multiplier: multiplies the power of the command, most times.
 */
/datum/voice_of_god_command/proc/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	return

/datum/voice_of_god_command/knockdown
	trigger = "drop|fall|trip|knockdown"
	cooldown = COOLDOWN_STUN
	tier = 3

/datum/voice_of_god_command/knockdown/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/target as anything in listeners)
		target.Knockdown(4 SECONDS * power_multiplier)

/// This command stops the listeners from moving.
/datum/voice_of_god_command/immobilize
	trigger = "stop|wait|stand\\s*still|hold\\s*on|halt"
	cooldown = COOLDOWN_STUN
	tier = 3

/datum/voice_of_god_command/immobilize/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/target as anything in listeners)
		target.Immobilize(4 SECONDS * power_multiplier)

/// This command makes carbon listeners throw up like Mr. Creosote.
/datum/voice_of_god_command/vomit
	trigger = "vomit|throw\\s*up|sick"
	cooldown = COOLDOWN_STUN
	tier = 3

/datum/voice_of_god_command/vomit/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/carbon/target in listeners)
		target.vomit(lost_nutrition = (power_multiplier * 10), distance = power_multiplier)

/// This command silences the listeners. Thrice as effective is the user is a mime or curator.
/datum/voice_of_god_command/silence
	trigger = "shut\\s*up|silence|be\\s*silent|ssh|quiet|hush"
	cooldown = COOLDOWN_STUN
	tier = 2

/datum/voice_of_god_command/silence/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/carbon/target in listeners)
		target.adjust_silence(20 SECONDS * power_multiplier)

/// This command makes the listeners see others as corgis, carps, skellies etcetera etcetera.
/datum/voice_of_god_command/hallucinate
	trigger = "see\\s*the\\s*truth|hallucinate"

/datum/voice_of_god_command/hallucinate/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/target in listeners)
		new /datum/hallucination/delusion(target, TRUE, null,150 * power_multiplier,0)

/// This command wakes up the listeners.
/datum/voice_of_god_command/wake_up
	trigger = "wake\\s*up|awaken"
	cooldown = COOLDOWN_DAMAGE

/datum/voice_of_god_command/wake_up/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/target as anything in listeners)
		target.SetSleeping(0)

/// This command heals the listeners for 10 points of total damage.
/datum/voice_of_god_command/heal
	trigger = "live|heal|survive|mend|life|heroes\\s*never\\s*die"
	cooldown = COOLDOWN_DAMAGE

/datum/voice_of_god_command/heal/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/target as anything in listeners)
		target.heal_overall_damage(10 * power_multiplier, 10 * power_multiplier)

/// This command applies 15 points of brute damage to the listeners. There's subtle theological irony in this being more powerful than healing.
/datum/voice_of_god_command/brute
	trigger = "die|suffer|hurt|pain|death"
	cooldown = COOLDOWN_DAMAGE
	tier = 2

/datum/voice_of_god_command/brute/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/target as anything in listeners)
		target.apply_damage(15 * power_multiplier, def_zone = BODY_ZONE_CHEST)

/// This command makes carbon listeners bleed from a random body part.
/datum/voice_of_god_command/bleed
	trigger = "bleed|there\\s*will\\s*be\\s*blood"
	cooldown = COOLDOWN_DAMAGE
	tier = 2

/datum/voice_of_god_command/bleed/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/carbon/human/target in listeners)
		target.bleed_rate += (5 * power_multiplier)

/// This command sets the listeners ablaze.
/datum/voice_of_god_command/burn
	trigger = "burn|ignite"
	cooldown = COOLDOWN_DAMAGE
	tier = 2

/datum/voice_of_god_command/burn/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/target as anything in listeners)
		target.adjust_fire_stacks(1 * power_multiplier)
		target.IgniteMob()

/// This command heats the listeners up like boiling water.
/datum/voice_of_god_command/hot
	trigger = "heat|hot|hell"
	cooldown = COOLDOWN_DAMAGE
	tier = 2

/datum/voice_of_god_command/hot/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/target as anything in listeners)
		target.adjust_bodytemperature(50 * power_multiplier)

/// This command cools the listeners down like freezing water.
/datum/voice_of_god_command/cold
	trigger = "cold|chill|freeze"
	cooldown = COOLDOWN_DAMAGE
	tier = 2

/datum/voice_of_god_command/cold/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/target as anything in listeners)
		target.adjust_bodytemperature(-50 * power_multiplier)

/// This command throws the listeners away from the user.
/datum/voice_of_god_command/repulse
	trigger = "shoo|go\\s*away|leave\\s*me\\s*alone|begone|flee|fus\\s*ro\\s*dah|get\\s*away|repulse"
	cooldown = COOLDOWN_DAMAGE
	tier = 2

/datum/voice_of_god_command/repulse/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/target as anything in listeners)
		var/throwtarget = get_edge_target_turf(user, get_dir(user, get_step_away(target, user)))
		target.throw_at(throwtarget, 3 * power_multiplier, 1 * power_multiplier)

/// This command throws the listeners at the user.
/datum/voice_of_god_command/attract
	trigger = "come\\s*here|come\\s*to\\s*me|get\\s*over\\s*here|attract"
	cooldown = COOLDOWN_DAMAGE
	tier = 2

/datum/voice_of_god_command/attract/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/target as anything in listeners)
		target.throw_at(get_step_towards(user, target), 3 * power_multiplier, 1 * power_multiplier)

/// This command forces the listeners to say their true name (so masks and hoods won't help).
/// Basic and simple mobs who are forced to state their name and don't have one already will... reveal their actual one!
/datum/voice_of_god_command/who_are_you
	trigger = "who\\s*are\\s*you|say\\s*your\\s*name|state\\s*your\\s*name|identify"

/datum/voice_of_god_command/who_are_you/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	var/iteration = 1
	for(var/mob/living/target as anything in listeners)
		addtimer(CALLBACK(src, PROC_REF(state_name), target), 0.5 SECONDS * iteration)
		iteration++

///just states the target's name, but also includes the renaming funny.
/datum/voice_of_god_command/who_are_you/proc/state_name(mob/living/target)
	if(QDELETED(target))
		return
	target.say(target.real_name)

/// This command forces the listeners to say the user's name
/datum/voice_of_god_command/say_my_name
	trigger = "say\\s*my\\s*name|who\\s*am\\s*i"

/datum/voice_of_god_command/say_my_name/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	var/iteration = 1
	var/regex/smartass_regex = regex(@"^say my name[.!]*$")
	for(var/mob/living/target as anything in listeners)
		var/to_say = user.name
		// 0.1% chance to be a smartass
		if(findtext(lowertext(message), smartass_regex) && prob(0.1))
			to_say = "My name"
		addtimer(CALLBACK(target, TYPE_PROC_REF(/atom/movable, say), to_say), 0.5 SECONDS * iteration)
		iteration++

/// This command forces the listeners to say "Who's there?".
/datum/voice_of_god_command/knock_knock
	trigger = "knock\\s*knock"

/datum/voice_of_god_command/knock_knock/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	var/iteration = 1
	for(var/mob/living/target as anything in listeners)
		addtimer(CALLBACK(target, TYPE_PROC_REF(/atom/movable, say), "Who's there?"), 0.5 SECONDS * iteration)
		iteration++

/// This command forces the listeners to take step in a direction chosen by the user, otherwise a random cardinal one.
/datum/voice_of_god_command/move
	trigger = "move|walk"
	var/static/up_words = regex("up|north|fore")
	var/static/down_words = regex("down|south|aft")
	var/static/left_words = regex("left|west|port")
	var/static/right_words = regex("right|east|starboard")

/datum/voice_of_god_command/move/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	var/iteration = 1
	var/direction
	if(findtext(message, up_words))
		direction = NORTH
	else if(findtext(message, down_words))
		direction = SOUTH
	else if(findtext(message, left_words))
		direction = WEST
	else if(findtext(message, right_words))
		direction = EAST
	for(var/mob/living/target as anything in listeners)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_step), target, direction || pick(GLOB.cardinals)), 1 SECONDS * (iteration - 1))
		iteration++

/// This command forces the listeners to switch to walk intent.
/datum/voice_of_god_command/walk
	trigger = "slow\\s*down"

/datum/voice_of_god_command/walk/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/target as anything in listeners)
		if(target.m_intent != MOVE_INTENT_WALK)
			target.m_intent = MOVE_INTENT_WALK

/// This command forces the listeners to switch to run intent.
/datum/voice_of_god_command/run
	trigger = "run"
	is_regex = FALSE

/datum/voice_of_god_command/run/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/target as anything in listeners)
		if(target.m_intent != MOVE_INTENT_RUN)
			target.m_intent = MOVE_INTENT_RUN

/// This command turns the listeners' throw mode on.
/datum/voice_of_god_command/throw_catch
	trigger = "throw|catch"

/datum/voice_of_god_command/throw_catch/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/carbon/target in listeners)
		target.throw_mode_on()

/// This command forces the listeners to say a brain damage line.
/datum/voice_of_god_command/speak
	trigger = "speak|say\\s*something"

/datum/voice_of_god_command/speak/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	var/iteration = 1
	for(var/mob/living/target in listeners)
		addtimer(CALLBACK(target, TYPE_PROC_REF(/atom/movable, say), pick_list_replacements(BRAIN_DAMAGE_FILE, "brain_damage")), 0.5 SECONDS * iteration)
		iteration++

/// This command forces the listeners to get the fuck up, resetting all stuns.
/datum/voice_of_god_command/getup
	trigger = "get\\s*up"
	cooldown = COOLDOWN_DAMAGE

/datum/voice_of_god_command/getup/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/target as anything in listeners)
		target.set_resting(FALSE)
		target.SetAllImmobility(0)

/// This command forces each listener to buckle to a chair found on the same tile.
/datum/voice_of_god_command/sit
	trigger = "sit"
	is_regex = FALSE

/datum/voice_of_god_command/sit/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/target as anything in listeners)
		var/obj/structure/chair/chair = locate(/obj/structure/chair) in get_turf(target)
		chair?.buckle_mob(target)

/// This command forces each listener to unbuckle from whatever they are buckled to.
/datum/voice_of_god_command/stand
	trigger = "stand"
	is_regex = FALSE

/datum/voice_of_god_command/stand/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/target as anything in listeners)
		target.buckled?.unbuckle_mob(target)

/// This command forces the listener to do the jump emote 3/4 of the times or reply "HOW HIGH?!!".
/datum/voice_of_god_command/jump
	trigger = "jump"
	is_regex = FALSE

/datum/voice_of_god_command/jump/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	var/iteration = 1
	for(var/mob/living/target as anything in listeners)
		if(prob(25))
			addtimer(CALLBACK(target, TYPE_PROC_REF(/atom/movable, say), "HOW HIGH?!!"), 0.5 SECONDS * iteration)
		else
			addtimer(CALLBACK(target, TYPE_PROC_REF(/mob/living/, emote), "jump"), 0.5 SECONDS * iteration)
		iteration++

///This command spins the listeners 1800° degrees clockwise.
/datum/voice_of_god_command/multispin
	trigger = "like\\s*a\\s*record\\s*baby|right\\s*round"

/datum/voice_of_god_command/multispin/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	for(var/mob/living/target as anything in listeners)
		target.SpinAnimation(speed = 10, loops = 5)

/// Supertype of all those commands that make people emote and nothing else. Fuck copypasta.
/datum/voice_of_god_command/emote
	/// The emote to run.
	var/emote_name = "dance"

/datum/voice_of_god_command/emote/execute(list/listeners, mob/living/user, power_multiplier = 1, message)
	var/iteration = 1
	for(var/mob/living/target as anything in listeners)
		addtimer(CALLBACK(target, TYPE_PROC_REF(/mob/living/, emote), emote_name), 0.5 SECONDS * iteration)
		iteration++

/datum/voice_of_god_command/emote/flip
	trigger = "flip|rotate|revolve|roll|somersault"
	emote_name = "flip"

/datum/voice_of_god_command/emote/dance
	trigger = "dance"
	is_regex = FALSE

/datum/voice_of_god_command/emote/salute
	trigger = "salute"
	emote_name = "salute"
	is_regex = FALSE

/datum/voice_of_god_command/emote/play_dead
	trigger = "play\\s*dead"
	emote_name = "deathgasp"

/datum/voice_of_god_command/emote/clap
	trigger = "clap|applaud"
	emote_name = "clap"

#undef COOLDOWN_STUN
#undef COOLDOWN_DAMAGE
#undef COOLDOWN_NONE
