/* For employment contracts */

/obj/item/paper/contract
	throw_range = 3
	throw_speed = 3
	var/signed = FALSE
	var/datum/mind/target
	item_flags = NOBLUDGEON

/obj/item/paper/contract/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/update_icon_blocker)

/obj/item/paper/contract/proc/update_text()
	return

/obj/item/paper/contract/employment
	icon_state = "paper_words"

/obj/item/paper/contract/employment/New(atom/loc, mob/living/nOwner)
	. = ..()
	if(!nOwner || !nOwner.mind)
		qdel(src)
		return -1
	target = nOwner.mind
	update_text()


/obj/item/paper/contract/employment/update_text()
	name = "paper- [target] employment contract"
	info = "<center>Conditions of Employment</center><BR><BR><BR><BR>This Agreement is made and entered into as of the date of last signature below, by and between [target], and Lobotomy Corporation.<BR> As per contract, [target] and their immediate family will be given housing within the L corp nest. In exchange for this garenteed housing the [target] will work as an employee in one of our designated branches.<BR><BR>Contractual obligations of Lobotomy Corp are null and void if said employee breaches the following rules.<BR>Disclose confidential information about their employers singularity.<BR>Disobey orders given by sephirot.<BR>Signed,<BR><i>[target]</i>"
