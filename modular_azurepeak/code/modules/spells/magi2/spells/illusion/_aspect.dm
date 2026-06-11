// Illusion — minor aspect, port of Azure-Peak's `/datum/magic_aspect/illusion`.
//
// Upstream grants `/obj/effect/proc_holder/spell/invoked/invisibility`. ES already
// has the same spell at code/modules/spells/roguetown/acolyte/noc.dm:42 — the Noc
// acolyte's signature miracle. Magi 2 just registers a second route to the same
// spell here, so an Illusion-bound Magi gets it via the aspect system. The grant
// helpers in magic_aspect.dm dispatch on `ispath(spell_path, /obj/effect/proc_holder/spell)`
// to use mind.AddSpell instead of the Magi 2 spell_list path.
//
// No need to port the spell itself — the existing implementation is identical to
// what upstream wants. Duration scales with arcyne skill; recharge 30s; range 3.

/datum/magic_aspect/illusion
	name = "Illusion"
	latin_name = "Minor Aspectus Illusio"
	desc = "The art of weaving what is not there. A bound Illusion-mage can fade themselves \
		or another from sight for as long as their arcyne skill allows. Any attack or attempt \
		to cast breaks the veil."
	aspect_type = ASPECT_MINOR
	school_color = GLOW_COLOR_ILLUSION
	binding_chants = list(
		"Let me weave what is not there.",
		"Illusio, mihi adesse!",
	)
	unbinding_chants = list(
		"I unravel the veil I have spun.",
		"Illusio, me relinquere!",
	)
	fixed_spells = list(
		/obj/effect/proc_holder/spell/invoked/invisibility,
	)
