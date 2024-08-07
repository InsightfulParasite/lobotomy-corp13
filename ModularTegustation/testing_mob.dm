/mob/living/simple_animal/hostile/zeitgeist
	name = "zeitgeist"
	desc = ""
	icon = 'ModularTegustation/Teguicons/tegumobs.dmi'
	icon_state = "_ZAYIN"

/mob/living/simple_animal/hostile/zeitgeist/MoveToTarget(list/possible_targets)
	stop_automated_movement = 1
	/*Stop automated movement is only used for wander code.
		The two checks after this are if we dont have a
		target and if we are currently moving towards a
		target and they suddenly or are currently something
		we dont attack.*/
	if(!target)
		if(approaching_target)
			/* Approaching target means we are currently moving menacingly
				towards something. Otherwise we are just moving and if we
				are investigating a location we dont want to be told to stand still. */
			LoseTarget()
		return FALSE
	if(!CanAttack(target))
		LoseTarget()
		return FALSE
	// The target we currently have is in our view and we must decide if we move towards it more.
	if(target in possible_targets)
		var/turf/T = get_turf(src)
		if(target.z != T.z)
			//Target is not on our Z level. How? I dont know?
			LoseTarget()
			return FALSE
		var/target_distance = get_dist(targets_from,target)
		var/in_range = melee_reach > 1 ? target.Adjacent(targets_from) || (get_dist(src, target) <= melee_reach && (target in view(src, melee_reach))) : target.Adjacent(targets_from)
		if(ranged) //We ranged? Shoot at em
			if(!in_range && ranged_cooldown <= world.time)
				//But make sure they're not in range for a melee attack and our range attack is off cooldown
				OpenFire(target)

		//This is consideration for chargers. If you are not a charger you can skip this.
		if(charger && (target_distance > minimum_distance) && (target_distance <= charge_distance))
			//Attempt to close the distance with a charge.
			enter_charge(target)
			return TRUE

		if(!Process_Spacemove()) //Drifting
			walk(src,0)
			return TRUE
		if(retreat_distance != null)
			//If we have a retreat distance, check if we need to run from our target
			if(target_distance <= retreat_distance)
				//If target's closer than our retreat distance, run
				walk_away(src,target,retreat_distance,move_to_delay)
			else
				Goto(target,move_to_delay,minimum_distance)
				//Otherwise, get to our minimum distance so we chase them
		else
			Goto(target,move_to_delay,minimum_distance)

		//This is for attacking.
		if(target)
			if(targets_from && isturf(targets_from.loc) && in_range)
				//If they're next to us, attack
				MeleeAction()
			else
				if(rapid_melee > 1 && target_distance <= melee_queue_distance)
					MeleeAction(FALSE)
				in_melee = FALSE //If we're just preparing to strike do not enter sidestep mode
			return TRUE
		return FALSE

	//Smashing code
	if(environment_smash)
		if(target.loc != null && get_dist(targets_from, target.loc) <= vision_range) //We can't see our target, but he's in our vision range still
			if(ranged_ignores_vision && ranged_cooldown <= world.time) //we can't see our target... but we can fire at them!
				OpenFire(target)
			if((environment_smash & ENVIRONMENT_SMASH_WALLS) || (environment_smash & ENVIRONMENT_SMASH_RWALLS)) //If we're capable of smashing through walls, forget about vision completely after finding our target
				Goto(target,move_to_delay,minimum_distance)
				FindHidden()
				return TRUE
			else
				if(FindHidden())
					return TRUE
	LoseTarget()
	return FALSE

//Functionally this proc is a simplier version of the core code walk_to().
/mob/living/simple_animal/hostile/zeitgeist/Goto(target, delay, minimum_distance)
	if(target == src.target)
		approaching_target = TRUE
	else
		approaching_target = FALSE
	walk_towards(src, target, delay)
