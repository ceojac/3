mob
	New()
		..()
		if(client)
			local_chat = view()

	verb
		OOC(msg as text)
			for(var/client/c)
				msg(c, "<b>([usr.key]):</b> [html_encode(msg)]", "output_ooc")

		party_chat(msg as text)
			for(var/mob/m in usr.party.members)
				msg(m, "<b><i>[usr.name]</i></b>: [msg]", "output_party")

		local_chat(msg as text)
			for(var/mob/m in local_chat)
				if(m.client)
					msg(m, "<b>[usr.name]</b>: [html_encode(msg)]", "output_local")

	var
		list/local_chat = list()


proc
	msg(hearer, message, output)
		var/mob/m = ismob(hearer) ? hearer : null
		if(	isclient(hearer) ||\
			(m && m.client))
			hearer << output("[message]", "[output]")