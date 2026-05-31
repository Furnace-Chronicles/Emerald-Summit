// Lesser Kinesis — minor aspect, port of Azure-Peak's `/datum/magic_aspect/lesser_kinesis`.
//
// All three spells already exist in ES as proc_holders:
//   - /obj/effect/proc_holder/spell/invoked/projectile/fetch (code/.../wizard/projectiles_single/fetch.dm)
//   - /obj/effect/proc_holder/spell/invoked/projectile/repel (code/.../wizard/projectiles_single/repel.dm)
//   - /obj/effect/proc_holder/spell/invoked/aerosolize (code/.../wizard/invoked_aoe/aerosolize.dm)
//
// The Magi 2 grant helpers dispatch on `ispath(spell_path, /obj/effect/proc_holder/spell)`
// to route these through mind.AddSpell instead of the Magi 2 spell_list path. No new
// spell code needed — Lesser Kinesis is purely a registration of the aspect.

/datum/magic_aspect/lesser_kinesis
	name = "Lesser Kinesis"
	latin_name = "Minor Aspectus Vis"
	desc = "The art of pushing and pulling at the threads of force. Bound Magi can fetch a single \
		object from across the field, or shove a single body away with arcyne weight. A minor \
		fraction of what a true Kinesist commands."
	aspect_type = ASPECT_MINOR
	school_color = GLOW_COLOR_KINESIS
	binding_chants = list(
		"Let me push and pull at the threads of force.",
		"Vis Minor, mihi adesse!",
	)
	unbinding_chants = list(
		"I release the threads of force.",
		"Vis Minor, me relinquere!",
	)
	fixed_spells = list(
		/obj/effect/proc_holder/spell/invoked/projectile/fetch,
		/obj/effect/proc_holder/spell/invoked/projectile/repel,
		/obj/effect/proc_holder/spell/invoked/aerosolize,
	)
