#define LILI_BEHAVIOR_MODE_STEAL 1
#define LILI_BEHAVIOR_MODE_RETURN 2
/mob/living/simple_animal/hostile/lillibag
	name = "lillibag"
	desc = "A large sack made of leather."
	icon = 'ModularTegustation/Teguicons/lilliputian.dmi'
	icon_state = "bag1"
	icon_living = "bag1"
	density = FALSE
	melee_damage_lower = 0
	melee_damage_upper = 0
	damage_coeff = list(BRUTE = 1, RED_DAMAGE = 2, WHITE_DAMAGE = 1, BLACK_DAMAGE = 1, PALE_DAMAGE = 1)
	stop_automated_movement_when_pulled = TRUE
	search_objects = FALSE
	mob_size = MOB_SIZE_SMALL
	del_on_death = TRUE
	faction = list("hostile")
	var/size = 1
	var/resources = 10
	var/list/followers = list()

/mob/living/simple_animal/hostile/lillibag/FindTarget()
	return FALSE

/mob/living/simple_animal/hostile/lillibag/update_icon_state()
	icon_state = "bag[size]"

/mob/living/simple_animal/hostile/lillibag/Life()
	. = ..()
	if(!.) // Dead
		return FALSE
	//If less than 5 followers and at least 10 resources, spawn a follower
	if(LAZYLEN(followers) < 5 && resources >= 10)
		var/mob/living/simple_animal/hostile/lilliputian/stealer = new(get_turf(src))
		resources -= 10
		stealer.home = src
		followers += stealer
	//If 20 items stolen call everyone back and escape.
	if((LAZYLEN(contents) >= 20))
		var/where_is_everyone = FALSE
		for(var/mob/living/L in followers)
			if(L.loc != src)
				where_is_everyone = TRUE
				break
		if(where_is_everyone)
			QDEL_IN(src, 2)

//Explode into consumed loot on death.
/mob/living/simple_animal/hostile/lillibag/death(gibbed)
	var/spew_turf = pick(get_adjacent_open_turfs(src))
	for(var/atom/movable/i in contents)
		i.forceMove(spew_turf)
	..()

//Put item in bag and calculate resource gain.
/mob/living/simple_animal/hostile/lillibag/proc/RecieveItem(atom/movable/thing)
	thing.forceMove(src)
	if(isliving(thing))
		resources += 10
	else
		resources += 1

	if(LAZYLEN(contents) >= 4)
		size = 2
	if(LAZYLEN(contents) >= 8)
		size = 3
	update_icon()

/mob/living/simple_animal/hostile/lilliputian
	name = "lilliputian"
	desc = "A small entity dressed in rags."
	icon = 'ModularTegustation/Teguicons/lilliputian.dmi'
	icon_state = "lilliputian"
	icon_living = "lilliputian"
	environment_smash = TRUE
	density = FALSE
	friendly_verb_continuous = "smacks"
	friendly_verb_simple = "smack"
	faction = list("hostile")
	melee_damage_lower = 0
	melee_damage_upper = 5
	damage_coeff = list(BRUTE = 1, RED_DAMAGE = 0.8, WHITE_DAMAGE = 1.2, BLACK_DAMAGE = 1.3, PALE_DAMAGE = 2)
	stop_automated_movement_when_pulled = TRUE
	search_objects = TRUE
	mob_size = MOB_SIZE_SMALL
	can_be_held = TRUE
	del_on_death = TRUE
	var/obj/item/held_item
	var/can_act = TRUE
	var/behavior_mode = LILI_BEHAVIOR_MODE_STEAL
	var/mob/living/simple_animal/hostile/lillibag/home

/mob/living/simple_animal/hostile/lilliputian/Move()
	if(!can_act)
		return FALSE
	..()

/mob/living/simple_animal/hostile/lilliputian/AttackingTarget()
	//If returning home just go inside.
	if(behavior_mode == LILI_BEHAVIOR_MODE_RETURN && target == home)
		forceMove(home)
		can_act = FALSE
		return

	if(isitem(target))
		return GrabItem(target)

	if(istype(home) && target == home)
		if(isliving(pulling))
			var/mob/living/H = pulling
			home.RecieveItem(H)
		if(held_item)
			home.RecieveItem(target)
			held_item = null
			cut_overlays()
		LoseAggro()
		return

	if(!home)
		if(istype(target,/obj/machinery/disposal/bin))
			var/obj/machinery/disposal/bin/B = target
			if(isliving(pulling))
				var/mob/living/H = pulling
				if(H.stat != CONSCIOUS)
					B.place_item_in_disposal(H, src)
			if(held_item)
				B.place_item_in_disposal(held_item, src)
				held_item = null
				cut_overlays()
			LoseAggro()
			return

	if(isliving(target))
		var/mob/living/L = target
		if(L) //If subject is in crit and is not being pulled by a ally, grab them.
			if(L.stat != CONSCIOUS && !istype(L.pulledby,/mob/living/simple_animal/hostile/lilliputian))
				start_pulling(target)
				LoseAggro()
				return
	return ..()

/mob/living/simple_animal/hostile/lilliputian/CanAttack(atom/the_target)
	//If behavior return, only target home.
	if(behavior_mode == LILI_BEHAVIOR_MODE_RETURN)
		if(the_target == home)
			return TRUE
		return FALSE

	if(isitem(the_target) && !held_item)
		return TRUE
	//If with loot or a body, bring it back to base.
	if((isliving(pulling) || held_item))
		if(!home)
			if(istype(the_target,/obj/machinery/disposal/bin))
				return TRUE
		else
			if(the_target == home)
				return TRUE
	//If living and your not pulling anything, and the subject is unconcious, grab em.
	if(isliving(the_target))
		var/mob/living/L = the_target
		if(L)
			if(pulling)
				return FALSE
			if(L.stat != CONSCIOUS && !istype(L.pulledby,/mob/living/simple_animal/hostile/lilliputian))
				return TRUE

	return ..()

/mob/living/simple_animal/hostile/lilliputian/death(gibbed)
	held_item.forceMove(get_turf(src))
	..()

//Grab the item and lift it 20 pixels above their head.
/mob/living/simple_animal/hostile/lilliputian/proc/GrabItem(atom/the_target)
	can_act = FALSE
	held_item = the_target
	held_item.forceMove(src)
	var/mutable_appearance/new_overlay = mutable_appearance(held_item.icon, held_item.icon_state)
	new_overlay.pixel_y = 20
	add_overlay(new_overlay)
	can_act = TRUE
	return
