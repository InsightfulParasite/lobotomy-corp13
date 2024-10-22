/mob/living/simple_animal/hostile/abnormality/kikimora
	name = "Kikimora"
	desc = "."
	icon = 'ModularTegustation/Teguicons/tegumobs.dmi'
	icon_state = "forsakenmurdererinert"
	icon_living = "forsakenmurdererinert"
	icon_dead = "forsakenmurdererdead"
	portrait = "forsaken_murderer"
	del_on_death = FALSE
	maxHealth = 1300
	health = 1300
	rapid_melee = 1
	melee_queue_distance = 2
	move_to_delay = 3
	damage_coeff = list(BRUTE = 1, RED_DAMAGE = 1, WHITE_DAMAGE = 1, BLACK_DAMAGE = 1.5, PALE_DAMAGE = 2)
	melee_damage_lower = 10
	melee_damage_upper = 18
	melee_damage_type = RED_DAMAGE
	can_breach = TRUE
	threat_level = TETH_LEVEL
	start_qliphoth = 1
	work_chances = list(
		ABNORMALITY_WORK_INSTINCT = list(60, 60, 50, 50, 50),
		ABNORMALITY_WORK_INSIGHT = list(40, 40, 30, 30, 30),
		ABNORMALITY_WORK_ATTACHMENT = list(50, 50, 40, 40, 40),
		ABNORMALITY_WORK_REPRESSION = list(30, 20, 0, -80, -80),
	)
	work_damage_amount = 6
	work_damage_type = RED_DAMAGE
	chem_type = /datum/reagent/abnormality/violence
	death_message = "falls over."
	wander = FALSE
	ego_list = list(
		/datum/ego_datum/weapon/regret,
		/datum/ego_datum/armor/regret,
	)
	gift_type =  /datum/ego_gifts/regret

/mob/living/simple_animal/hostile/abnormality/kikimora/BreachEffect(mob/living/carbon/human/user, breach_type) //causes breach?
	. = ..()

/mob/living/simple_animal/hostile/abnormality/kikimora/examine(mob/user)
	. = ..()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.apply_status_effect(/datum/status_effect/display/kikimora)
		to_chat(H, span_mind_control("You saw it."))

//Status Effect
/datum/status_effect/display/kikimora
	id = "kikimora"
	status_type = STATUS_EFFECT_UNIQUE
	duration = -1
	alert_type = null
	on_remove_on_mob_delete = TRUE
	display_name = "nope"
	var/words_per_say = 1
	var/static/spread_cooldown = 0
	var/spread_cooldown_delay = 5 SECONDS
	var/static/words_taken = list()

/datum/status_effect/display/kikimora/on_apply()
	. = ..()
	RegisterSignal(owner, COMSIG_MOB_SAY, PROC_REF(CorruptWords))
	RegisterSignal(owner, COMSIG_LIVING_STATUS_SLEEP, PROC_REF(Bedtime))

/datum/status_effect/display/kikimora/proc/Bedtime()
	SIGNAL_HANDLER

	qdel(src)

/datum/status_effect/display/kikimora/proc/CorruptWords(datum/source, list/speech_args)
	SIGNAL_HANDLER
	var/words_to_take = words_per_say
	var/words_said = 0

	var/message = speech_args[SPEECH_MESSAGE]
	var/list/split_message = splittext(message, " ") //List each word in the message
	for (var/i in 1 to length(split_message))
		if(findtext(split_message[i], "*") || findtext(split_message[i], ";") || findtext(split_message[i], ":") || findtext(split_message[i], "kiki") || findtext(split_message[i], "mora"))
			continue
		var/standardize_text = uppertext(split_message[i])
		if(standardize_text in words_taken)
			split_message[i] = pick("kiki", "mora")
			//Higher chance of spreading if the user said kiki or mora alot.
			words_said++
			continue
		if(prob(25) && words_to_take > 0)
			words_taken += standardize_text
			words_to_take--

	message = jointext(split_message, " ")
	speech_args[SPEECH_MESSAGE] = message

	//Infection Mechanic
	if(ishuman(owner))
		var/mob/living/carbon/human/L = owner
		if(spread_cooldown <= world.time)
			for(var/mob/living/carbon/human/H in hearers(7, L))
				if(prob(5 * words_said))
					H.apply_status_effect(/datum/status_effect/display/kikimora)
			spread_cooldown = world.time + spread_cooldown_delay
