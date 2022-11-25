/mob/living/simple_animal/hostile/A1
	name = "grabber"
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "mansus"
	icon_living = "mansus"
	del_on_death = TRUE
	mob_biotypes = MOB_SPIRIT
	invisibility = 26
	gender = NEUTER
	density = FALSE
	turns_per_move = 5
	health = 75
	maxHealth = 75
	speed = 5
	pass_flags = PASSTABLE | PASSMOB
	vision_range = 20
	aggro_vision_range = 20
	environment_smash = ENVIRONMENT_SMASH_NONE
	robust_searching = 1
	var/origin_portal
	var/grab_target

/mob/living/simple_animal/hostile/A1/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_STRONG_GRABBER, "initialize")

/mob/living/simple_animal/hostile/A1/AttackingTarget()
	if(pulling)
		Goto(origin_portal, 3, 0)
		return
	start_pulling(target)

/mob/living/simple_animal/hostile/A1/Life()
	. = ..()
	if(!origin_portal)
		qdel(src)
	if(pulling)
		Goto(origin_portal, 3, 0)

/mob/living/simple_animal/hostile/A1/PickTarget(list/Targets) // We attack corpses first if there are any
	var/list/highest_priority = list()
	var/list/lower_priority = list()
	for(var/mob/living/L in Targets)
		if(!CanAttack(L))
			continue
		if(L.has_status_effect(/datum/status_effect/A1))
			if(ishuman(L))
				highest_priority += L
			else
				lower_priority += L
		else
			lower_priority += L
	if(LAZYLEN(highest_priority))
		return pick(highest_priority)
	if(LAZYLEN(lower_priority))
		return pick(lower_priority)
	return ..()

/obj/structure/A1puddle
	name = "puddle"
	icon = 'icons/turf/mining.dmi'
	icon_state = "spring"
	color = "blue"
	invisibility = 26
	var/set_target
	var/servent

/obj/structure/A1puddle/Initialize()
	. = ..()
	var/mob/living/simple_animal/hostile/A1/minion = new(get_turf(src))
	minion.GiveTarget(set_target)
	minion.grab_target = set_target
	minion.origin_portal = src
	servent = minion
	for(var/obj/machinery/light/O in get_area(src))
		O.flicker()
	playsound(src, 'sound/effects/creak2.ogg', 20, TRUE)
	playsound(src, 'sound/effects/break_stone.ogg', 20, TRUE)
	playsound(src, 'sound/hallucinations/im_here2.ogg', 5, TRUE)

/obj/structure/A1puddle/Destroy()
	qdel(servent)
	playsound(src, 'sound/effects/whirthunk.ogg', 20, TRUE)
	playsound(src, 'sound/effects/impact_thunder.ogg', 20, TRUE)
	. = ..()

/obj/structure/A1puddle/Crossed(atom/movable/AM)
	. = ..()
	if(istype(AM, /mob/living/simple_animal/hostile/A1))
		var/mob/living/simple_animal/hostile/A1/A = AM
		var/mob/living/capture = A.pulling
		if(A.pulling == set_target)
			playsound(src, 'sound/effects/slosh.ogg', 20, TRUE)
			visible_message("<span class='warning'>[capture] sinks below as [src] begins to seal itself.</span>")
			qdel(A)
			qdel(capture)
			qdel(src)

/obj/item/A1item
	name = "A1"
	icon = 'ModularTegustation/Teguicons/teguitems.dmi'
	icon_state = "oddity7" //placeholder icon
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_POCKETS
	w_class = WEIGHT_CLASS_SMALL

/obj/item/A1item/equipped(mob/living/carbon/human/user)
	..() //also
	if(user.has_status_effect(/datum/status_effect/A1))
		qdel(src)
	user.apply_status_effect(/datum/status_effect/A1)

/datum/status_effect/A1
	id = "A1"
	duration = -1
	tick_interval = 20 SECONDS
//	alert_type = null
	var/currentpond

/datum/status_effect/A1/on_apply()
	owner.see_invisible = 26
	return ..()

/datum/status_effect/A1/tick()
	if(currentpond)
		qdel(currentpond)
	var/list/turf/possible_turfs = list()
	for(var/turf/T in view(25, owner))
		if(!T.density)
			possible_turfs += T
	var/turf/target_turf = pick(possible_turfs)
	var/obj/structure/A1puddle/pond = new(target_turf)
	pond.set_target = owner
	currentpond = pond

/datum/status_effect/A1/on_remove()
	owner.see_invisible = initial(owner.see_invisible)

