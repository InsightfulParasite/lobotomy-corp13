/obj/machinery/computer/agent_manager
	name = "agent manager"
	desc = "A machine that will page the agent with a simple command to work on a abnormality."
	density = TRUE
	resistance_flags = INDESTRUCTIBLE
	var/command_agent
	var/command_abno

/obj/machinery/computer/agent_manager/ui_interact(mob/user)
	. = ..()
	if(isliving(user))
		playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)
	var/dat
	dat += CommandUI()
	var/datum/browser/popup = new(user, "AgentCommand", "AgentCommand", 440, 640)
	popup.set_content(dat)
	popup.open()
	return

/*
* Topic proc recieves the button presses from CommandUI.
* <A href='byond://?src=[REF(src)];command_agent=[src]'>SEND_COMMAND</A>
* Is made of 3 parts. src=[REF(src)] is the machine that has the topic
* proc and decides what to do based on what they recieve.
* command_agent=[src] returns "command_agent" to Topic and contains a
* text variable of [src]. To access the text variable inside
* command_agent you'll need to check href_list["command_agent"].
* The final part of the button, >SEND_COMMAND</A> is the text displayed
* on the button. Using operators or simple one line functions you can
* have the text for the button change based on variables.
*/
/obj/machinery/computer/agent_manager/Topic(href, href_list)
	. = ..()
	if(.)
		return .
	if(ishuman(usr))
		usr.set_machine(src)
		add_fingerprint(usr)
		if(href_list["select_agent"])
			var/agent_select = locate(href_list["select_agent"]) in GLOB.player_list
			if(agent_select)
				command_agent = agent_select
			updateUsrDialog()
			return TRUE
		if(href_list["select_abno"])
			command_abno = href_list["select_abno"]
			updateUsrDialog()
			return TRUE

		//There is a threat of rapid spamming someone.
		if(href_list["command_agent"])
			if(command_agent)
				if(command_abno)
					CommandAgent(command_agent, command_abno)
				else
					to_chat(src, span_warning("ERROR ABNORMALITY DOESNT EXIST"))
			else
				to_chat(usr, span_warning("ERROR AGENT DOESNT EXIST"))
			updateUsrDialog()
			return TRUE

//Usually this code is in ui_interact proc but i like having it be its own thing so its easier to look at and edit.
/obj/machinery/computer/agent_manager/proc/CommandUI()
	. = "<tt><br>\
		|<A href='byond://?src=[REF(src)];command_agent=[src]'>SEND_COMMAND</A><br>\
		-----------------------<br>\
		|CURRENT_CONTAIN_ABNOS|<br>\
		-----------------------<br>\
		[ReturnAbnormalities()]<br>\
		-----------------------<br>\
		|CURRENT_LIVING_AGENTS|<br>\
		-----------------------<br>\
		[ReturnLivingAgents()]<br>\
		-----------------------<br>\
		</tt>"

//This proc creates a list of all the agents currently alive.
/obj/machinery/computer/agent_manager/proc/ReturnLivingAgents()
	for(var/mob/living/carbon/human/L in AllLivingAgents())
		if(L.client)
			. += "|<A href='byond://?src=[REF(src)];select_agent=[REF(L)]'>[command_agent == L ? "<b><u>[L]</u></b>" : "[L]"]</A>"

//Creates a list of all existing abnormalities
/obj/machinery/computer/agent_manager/proc/ReturnAbnormalities()
	for(var/mob/living/simple_animal/hostile/abnormality/A in GLOB.abnormality_mob_list)
		//Prevents tutorial abnormalities from showing up
		if(A.can_spawn)
			. += "|<A href='byond://?src=[REF(src)];select_abno=[A]'>[command_abno == A.name ? "<b><u>[A]</u></b>" : "[A]"]</A>"

//This is used to message the agent.
/obj/machinery/computer/agent_manager/proc/CommandAgent(mob/living/carbon/human/agent, selected_abnormality)
	to_chat(agent, span_syndradio("[agent] you are requested to work on [selected_abnormality]."))
