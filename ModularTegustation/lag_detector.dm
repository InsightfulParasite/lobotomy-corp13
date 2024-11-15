/obj/item/powered_gadget/detector_gadget
	name = "lag detector"
	desc = "."
	icon_state = "gadget2"

/obj/item/powered_gadget/detector_gadget/attack_self(mob/user)
	..()
	var/worldstarttime = 0
	var/worldstarttimeofday = 0
	if (!worldstarttime || worldstarttimeofday)
		worldstarttime = world.time
		worldstarttimeofday = world.timeofday
	var/tickdrift = (world.timeofday - worldstarttimeofday) - (world.time - worldstarttime)  / world.tick_lag
	to_chat(user, "Tick Drift: [round(tickdrift)] Missed ticks")

