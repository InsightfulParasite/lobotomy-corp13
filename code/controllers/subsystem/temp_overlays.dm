/*
* This is a subsystem for adding temporary overlays
* IE overlays that will remove themselves after a while
* without having to be manually removed by something.
* Requires overlays subsystem to function.
*/
SUBSYSTEM_DEF(temp_overlay)
	name = "Temporary Overlays"
	flags = SS_BACKGROUND
	// How many overlays can be applied within 1 seconds?
	wait = 1 SECONDS

	var/list/overlay_list = list()

// Go through the list and remove all overlays that have expired.
/datum/controller/subsystem/temp_overlay/fire()
	if(!overlay_list.len)
		return
	var/current_time = world.time
	for(var/i in overlay_list)
		var/delete_time = overlay_list[i]["decaytime"]
		var/atom/A = i
		if(!QDELETED(A))
			LAZYREMOVE(overlay_list, A)
			continue
		if(current_time >= delete_time)
			remove_temp_overlay(A, overlay_list[A]["tempover"])

// Add temp overlay and format it to the list.
/datum/controller/subsystem/temp_overlay/proc/add_temp_overlay(atom/thing_overlay, temporary_overlay, decay_time)
	thing_overlay.add_overlay(temporary_overlay)
	overlay_list += thing_overlay
	overlay_list[thing_overlay] = list("tempover" = temporary_overlay, "decaytime" = decay_time)

// Remove a temp overlay.
/datum/controller/subsystem/temp_overlay/proc/remove_temp_overlay(atom/thing_overlay, overlay_to_remove)
	thing_overlay.cut_overlay(overlay_to_remove)
	LAZYREMOVE(overlay_list, thing_overlay)

// I feel weird adding a atom proc here
/atom/proc/addTempOverlay(new_overlay, decay_time)
	SStemp_overlay.add_temp_overlay(src, new_overlay, decay_time)
