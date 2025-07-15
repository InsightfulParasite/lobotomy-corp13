/obj/machinery/mineral/compressor
	name = "material compressor"
	desc = "A machine that compresses inputted materials."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "furnace"
	density = TRUE
	anchored = TRUE
	needs_item_input = TRUE
	var/list/materials = list(
		"lignite" = 0,
		)

/obj/machinery/mineral/compressor/pickup_item(datum/source, atom/movable/target, atom/oldLoc)
	. = ..()

	if(QDELETED(target))
		return
	if(istype(target, /obj/item/lignite) && materials["lignite"] < 25)
		qdel(target)
		materials["lignite"] += 1
		if(materials["lignite"] >= 5)
			materials["lignite"] -= 5
			var/obj/item/comp_carbon/C = new(src)
			unload_mineral(C)
