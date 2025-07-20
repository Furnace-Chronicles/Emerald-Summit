
/obj/effect/proc_holder/spell/self/ghost_walk
	name = "Ghost Walk"
	desc = "Leave your body as a ghost. Recast it over your body to re-enter."
	school = "transmutation"
	spell_tier = 3
	cost = 4
	recharge_time = 2 MINUTES
	cooldown_min = 1 MINUTES
	clothes_req = FALSE
	human_req = TRUE
	stat_allowed = TRUE // allow casting while dead/ghost
	antimagic_allowed = FALSE
	overlay_state = "ghost1"
	refundable = TRUE
	associated_skill = /datum/skill/magic/arcane
	invocation = "Spiritus egredere!"
	invocation_type = "whisper"

/obj/effect/proc_holder/spell/self/ghost_walk/Click()
	if(usr && ishuman(usr))
		if(alert(usr, "Are you sure you want to leave your body as a ghost?", "Ghost Walk", "Yes", "No") != "Yes")
			return 1
	if(cast_check())
		choose_targets()
	return 1

/obj/effect/proc_holder/spell/self/ghost_walk/cast(list/targets, mob/user = usr)
	if(istype(user, /mob/dead/observer))
		// Ghost is recasting: try to re-enter their body if over it
		var/mob/dead/observer/G = user
		if(!G.can_reenter_corpse)
			to_chat(G, span_warning("You cannot re-enter your body."))
			revert_cast()
			return FALSE
		if(G.mind && G.mind.current && get_turf(G.mind.current) == get_turf(G))
			var/success = G.reenter_corpse()
			if(success)
				to_chat(G, span_notice("You return to your body!"))
				start_recharge()
				return TRUE
			else
				to_chat(G, span_warning("You cannot re-enter your body right now."))
				revert_cast()
				return FALSE
		else
			to_chat(G, span_warning("You must be over your body to re-enter it."))
			revert_cast()
			return FALSE
	else
		// Living caster: ghostize, keep spell
		if(!user.mind)
			to_chat(user, span_warning("You have no mind!"))
			revert_cast()
			return FALSE
		var/mob/dead/observer/ghost = user.ghostize(1)
		if(!ghost)
			to_chat(user, span_warning("Failed to leave your body."))
			revert_cast()
			return FALSE
		// Remove the spell from the old body
		for(var/obj/effect/proc_holder/spell/S in user.mind.spell_list)
			if(S.type == /obj/effect/proc_holder/spell/self/ghost_walk)
				user.mind.spell_list -= S
				qdel(S)
				break
		// Ensure ghost.mind is valid
		if(!ghost.mind)
			ghost.mind = user.mind
		// Add the spell to the ghost's mind and mob_spell_list
		var/obj/effect/proc_holder/spell/self/ghost_walk/newspell = new /obj/effect/proc_holder/spell/self/ghost_walk(ghost)
		newspell.Initialize()
		ghost.mind.AddSpell(newspell)
		ghost.mob_spell_list += newspell
		if(newspell.action)
			newspell.action.Grant(ghost)
		to_chat(ghost, span_notice("You leave your body as a ghost. Recast Ghost Walk over your body to return."))
		start_recharge()
		return TRUE 
