/datum/element/tipped_item
	element_flags = NONE

/datum/element/tipped_item/Attach(atom/movable/target, amount)
	. = ..()
	if(!ismovableatom(target))
		return ELEMENT_INCOMPATIBLE
	if(!target.reagents)
		target.create_reagents(2)
	RegisterSignal(target, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(target, COMSIG_ITEM_PRE_ATTACK, PROC_REF(check_dip))
	RegisterSignal(target, COMSIG_ITEM_ATTACKBY_SUCCESS, PROC_REF(try_inject))
	RegisterSignal(target, COMSIG_ITEM_ATTACKBY_BLOCKED, PROC_REF(blocked_inject))
	RegisterSignal(target, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(clean_dip))

/datum/element/tipped_item/Detach(datum/source, force)
	. = ..()
	UnregisterSignal(source, list(COMSIG_PARENT_EXAMINE, COMSIG_ITEM_PRE_ATTACK, COMSIG_ITEM_ATTACKBY_SUCCESS, COMSIG_ITEM_ATTACKBY_BLOCKED, COMSIG_COMPONENT_CLEAN_ACT))

/datum/element/tipped_item/proc/check_dip(obj/item/dipper, obj/item/reagent_containers/attacked_container, mob/living/attacker, params)
	SIGNAL_HANDLER

	if(!istype(attacked_container))
		return
	if(!(attacked_container.reagents.flags & DRAINABLE))
		return
	if(!attacked_container.reagents.total_volume)
		to_chat(attacker, span_warning("\The [attacked_container] is empty!"))
		return
	var/max_volume = HAS_TRAIT(attacker, TRAIT_LEGENDARY_ALCHEMIST) ? 2 : 1 // legendary alchemists get the ability to double their max volume
	if(dipper.reagents.total_volume >= max_volume) // don't let user attempt to double dip
		var/reagent_color = mix_color_from_reagents(dipper.reagents.reagent_list)
		to_chat(attacker, span_warning("\The [dipper] is already soaked with <font color=[reagent_color]>something</font>. Washing should clean the <font color=[reagent_color]>coating</font> off."))
		return

	INVOKE_ASYNC(src, PROC_REF(start_dipping), dipper, attacked_container, attacker)

/datum/element/tipped_item/proc/start_dipping(obj/item/dipper, obj/item/reagent_containers/attacked_container, mob/living/attacker, params)
	var/reagentlog = attacked_container.reagents
	var/dip = dipper.reagents.total_volume > 0 ? "double dip" : "dip"
	attacker.visible_message(span_danger("[attacker] is [dip]ping \the [dipper] in [attacked_container]!"), "You begin [dip]ping \the [dipper] in \the [attacked_container]...", vision_distance = 2)
	if(!do_after(attacker, 2 SECONDS, target = attacked_container))
		return
	attacked_container.reagents.trans_to(dipper, 1, transfered_by = attacker)
	attacker.visible_message(span_danger("[attacker] [dip]s \the [dipper] in \the [attacked_container]!"), "You finish [dip]ping \the [dipper] in \the [attacked_container]!", vision_distance = 2)
	log_combat(attacker, dipper, "poisoned", addition="with [reagentlog]")

/datum/element/tipped_item/proc/try_inject(obj/item/dipper, atom/target, mob/user, damage, damagetype = BRUTE, def_zone = null)
	if(isliving(target) && dipper.reagents.total_volume)
		var/bladec = user.used_intent.blade_class
		switch(bladec)
			if(BCLASS_BLUNT,BCLASS_PUNCH,BCLASS_BITE,BCLASS_LASHING,BCLASS_BURN,BCLASS_TWIST) // do not attempt to inject with these intents
				return
		if(HAS_TRAIT(target,TRAIT_NOMETABOLISM)) // do not bother infecting target if they cannot process reagents
			dipper.reagents.clear_reagents()
			return
		var/reagentlog2 = dipper.reagents
		log_combat(user, target, "poisoned", addition="with [reagentlog2]")
		dipper.reagents.trans_to(target, dipper.reagents.total_volume, transfered_by = user)

/datum/element/tipped_item/proc/blocked_inject(obj/item/dipper, atom/target, mob/user, damagetype = BRUTE, def_zone = null)
	if(isliving(target) && dipper.reagents.total_volume && prob(20)) // random chance of smearing our blade clean with their armor
		var/reagent_color = mix_color_from_reagents(dipper.reagents.reagent_list)
		to_chat(user, span_notice("\The [dipper] loses its <font color=[reagent_color]>coating</font>."))
		dipper.reagents.clear_reagents()

/datum/element/tipped_item/proc/on_examine(atom/movable/source, mob/user, list/examine_list)
	var/total_volume = source.reagents.total_volume
	if(total_volume)
		var/reagent_color = mix_color_from_reagents(source.reagents.reagent_list)
		var/dip = total_volume > 1 ? "double dip" : "dip"
		examine_list += span_red("Has been [dip]ped in <font color=[reagent_color]>something</font>!")

/datum/element/tipped_item/proc/clean_dip(datum/source, strength)
	if(strength < CLEAN_WEAK)
		return
	var/obj/item/dipper = source
	if(istype(dipper) && dipper.reagents.total_volume)
		dipper.reagents.clear_reagents()
