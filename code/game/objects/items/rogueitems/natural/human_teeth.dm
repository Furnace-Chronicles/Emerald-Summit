/obj/item/natural/human_tooth
	name = "tooth"
	force = 0
	throwforce = 0
	embedding = list("embedded_pain_multiplier" = 0, "embed_chance" = 0, "embedded_fall_chance" = 100) //This shouldn't embed
	dropshrink = 0.2
	
/obj/item/natural/human_tooth/Initialize()
	. = ..()
	var/static/list/tooth_sprites = list(
		"tooth1",
		"tooth2",
		"tooth3"
		)
	icon_state = pick(tooth_sprites)

/obj/item/gold_tooth
	name = "gold tooth"
	desc = ""
	icon = 'icons/roguetown/items/misc.dmi'
	icon_state = "gtooth"
	force = 0
	throwforce = 0
	embedding = list("embedded_pain_multiplier" = 0, "embed_chance" = 0, "embedded_fall_chance" = 100) //This shouldn't embed
	dropshrink = 0.2

/mob/living/carbon/human/proc/lose_teeth(var/damage)
	var/lost_teeth = 0
	if(src.teeth == 0)
		return
	if(damage > 12 && damage < 20) //Small hits, no big deal
		lost_teeth = 1
	else if (damage >= 20) //The fun begins
		var/effective_damage = damage - 20
		lost_teeth += 1
		lost_teeth += round(effective_damage / 5)
	
	if(lost_teeth > 0)
		src.teeth -= lost_teeth
		src.recently_lost_teeth += lost_teeth
		if(src.gold_teeth > 0)
			src.flying_teeth(lost_teeth, gold = TRUE)
		else
			src.flying_teeth(lost_teeth)
		
		to_chat(src, span_warning("MY MOUTH HURTS!"))
		src.decay_lost_teeth()
		if(src.teeth < 12)
			if(src.client)
				src.cached_accent = src.client.prefs.char_accent
			src.char_accent = "Toothless accent"

/mob/living/carbon/human/proc/flying_teeth(var/amount, var/gold = FALSE)
	for(var/i, i < amount, i++)
		var/obj/item/T = null
		if(gold && (src.gold_teeth > 0))
			T = new /obj/item/gold_tooth(get_turf(src))
			src.gold_teeth--
		else
			T = new /obj/item/natural/human_tooth(get_turf(src))
		if(!T)
			return
		var/dir = pick(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
		var/turf/landing_point = get_step(get_turf(src), dir)
		T.throw_at(landing_point, throw_range , 99)
		playsound(src, pick('sound/combat/fracture/fracturewet (1).ogg', 'sound/combat/fracture/fracturewet (2).ogg', 'sound/combat/fracture/fracturewet (3).ogg'),
		 100)


/mob/living/carbon/human/proc/decay_lost_teeth()
	if(lost_teeth_decay)
		return
	
	lost_teeth_decay = TRUE

	while(recently_lost_teeth > 0)
		sleep(30 SECONDS)
		recently_lost_teeth--
		to_chat(src, span_warning("MY MOUTH HURTS!"))
	
	lost_teeth_decay = FALSE
	if(recently_lost_teeth > 0) //Final check
		spawn() decay_lost_teeth()

/mob/living/carbon/human/proc/remove_teeth(var/amount) //This is in case we want to make certain roles start off toothless
	if(src.teeth == 0)
		return
	
	if(amount > 32)
		amount = 32
	
	for(var/i, i < amount, i++)
		src.teeth--
		if(src.teeth == 0)
			break
	
	if(src.teeth < 12)
		if(src.client)
			src.cached_accent = src.client.prefs.char_accent
		src.char_accent = "Toothless accent"
	
