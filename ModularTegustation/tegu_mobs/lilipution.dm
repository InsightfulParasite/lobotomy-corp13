/mob/living/simple_animal/hostile/lilliputian
	name = "lilliputian"
	desc = "A small entity dressed in rags."
	icon = 'ModularTegustation/Teguicons/lilliputian.dmi'
	icon_state = "lilliputian"
	icon_living = "lilliputian"
	environment_smash = TRUE
	density = FALSE
	faction = list("hostile")
	friendly_verb_continuous = "smacks"
	friendly_verb_simple = "smack"
	mob_biotypes = MOB_ORGANIC
	melee_damage_lower = 0
	melee_damage_upper = 5
	damage_coeff = list(BRUTE = 1, RED_DAMAGE = 0.8, WHITE_DAMAGE = 1.2, BLACK_DAMAGE = 1.3, PALE_DAMAGE = 2)
	stop_automated_movement_when_pulled = TRUE
	search_objects = TRUE
	mob_size = MOB_SIZE_SMALL
	can_be_held = TRUE
	var/obj/item/held_item
	var/can_act = TRUE

/mob/living/simple_animal/hostile/lilliputian/Move()
	if(!can_act)
		return FALSE
	..()

/mob/living/simple_animal/hostile/lilliputian/AttackingTarget()
	if(isitem(target))
		return GrabItem(target)
	if(istype(target,/obj/machinery/disposal/bin))
		var/obj/machinery/disposal/bin/B = target
		if(isliving(pulling))
			var/mob/living/H = pulling
			H.gib()
			LoseAggro()
			return
		if(held_item)
			B.place_item_in_disposal(held_item, src)
			held_item = null
			cut_overlays()
			LoseAggro()
			return
	if(isliving(target))
		var/mob/living/L = target
		if(L)
			if(L.stat != CONSCIOUS && !istype(L.pulledby,/mob/living/simple_animal/hostile/lilliputian))
				start_pulling(target)
				LoseAggro()
				return
	return ..()

/mob/living/simple_animal/hostile/lilliputian/CanAttack(atom/the_target)
	if(isitem(the_target) && !held_item)
		return TRUE
	if((isliving(pulling) || held_item) && istype(the_target,/obj/machinery/disposal/bin))
		return TRUE
	if(isliving(the_target))
		var/mob/living/L = target
		if(L)
			if(pulling)
				return FALSE
			if(L.stat != CONSCIOUS && !istype(L.pulledby,/mob/living/simple_animal/hostile/lilliputian))
				return TRUE
	return ..()

/mob/living/simple_animal/hostile/lilliputian/proc/GrabItem(atom/the_target)
	can_act = FALSE
	held_item = the_target
	held_item.forceMove(src)
	var/mutable_appearance/new_overlay = mutable_appearance(held_item.icon, held_item.icon_state)
	new_overlay.pixel_y = 20
	add_overlay(new_overlay)
	can_act = TRUE
	return
