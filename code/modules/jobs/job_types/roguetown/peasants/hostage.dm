/datum/job/roguetown/hostage
	title = "Hostage (Bandit)"
	flag = HOSTAGE
	department_flag = PEASANTS
	faction = "Station"
	total_positions = 2
	spawn_positions = 2

	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	tutorial = "You're too valuable to outright kill yet not a free person. You either messed up really bad or got very unlucky. Either way, the bandits have held you hostage until your ransom is paid, as if that would ever happen. Might as well start praying to whatever god you find solace in."

	outfit = /datum/outfit/job/roguetown/hostage
	bypass_jobban = TRUE
	display_order = JDO_HOSTAGE
	give_bank_account = 10
	min_pq = -14
	max_pq = null
	can_random = FALSE

	cmode_music = 'sound/music/combat_bum.ogg'

	advclass_cat_rolls = list(CTAG_HOSTAGE = 20)

/datum/outfit/job/roguetown/hostage/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!H) return
	neck = /obj/item/clothing/neck/roguetown/gorget/cursed_collar
	pants = /obj/item/clothing/under/roguetown/tights/black
	shirt = /obj/item/clothing/suit/roguetown/shirt/tunic/white

/datum/job/roguetown/hostage/after_spawn(mob/living/L, mob/M, latejoin = TRUE)
	. = ..()
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		H.advsetup = 1
		H.invisibility = INVISIBILITY_MAXIMUM
		H.become_blind("advsetup")

/datum/job/roguetown/hostage/special_check_latejoin(client/C)
	return FALSE
