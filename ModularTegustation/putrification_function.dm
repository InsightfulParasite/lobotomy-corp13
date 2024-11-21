/*
* Corpses automatically reduce themselves
* to a putrified structure.
*/

/mob/living/simple_animal/Life()
	. = ..()
	if(staminaloss > 0)
		adjustStaminaLoss(-stamina_recovery, FALSE, TRUE)
