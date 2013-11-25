mob/verb/make_party()
	if(!party)	new /party(src)
	else src << "You are already in a party."

mob
	var party/party

	Logout()
		if(party)
			party.remove(src)
		..()

party
	var
		list/members = list()
		mob/leader

		units[] = new
		unitsmax = 5

	New(mob/m)
		join(m)

	Del()
		world << "disbanding party"
		for(var/mob/m in members)
			m.loc = leader.loc
		..()

	verb
		leave()
			set src in view(0)
			switch(input(usr, "leave party") in list("yes", "no"))
				if("yes")
					usr.party.remove(usr)

		view_members()
			set src in view(0)
			var/total_size
			var/mems_list = usr.party.members
			var/units = usr.party.units
			for(var/mem in mems_list)
				usr << "<b>[mem][usr.party.leader==mem?" (Leader)":""]</b>"
				total_size ++
			for(var/unit/unit in units)
				usr << "[unit.name] = [unit.amt]/[unit.max]"
				total_size ++

			usr << "TOTAL PARTY SIZE: [total_size]"


		invite()
			set src in view(0)
			var/mob/m = input("Invite whom?") as mob in view()-usr
			world << "[usr] invited [m] to party"
			if(usr == usr.party.leader || ask_leader(usr, "party [m]"))
				switch(input(m, "party invite [usr.party.leader]") in list("yes","no"))
					if("yes")
						world << "[m] yes party"
						if(m.party)
							m.party.leave(m)
						usr.party.join(m)
					if("no")
						world << "[m] no party"



	proc
		ask_leader(mob/m, what)
			switch(input(m, "[m] [what]") in list("yes", "no"))
				if("yes") return 1
			return 0

		join(mob/m)
			//if(!m.client) return
			m.verbs += typesof(/party/verb/)
			members += m
			m.party = src
			members << "[m] has joined the party"
			winset(m, "tab_chat", "tabs='+chat_party'")
			if(!check_leader())
				set_leader()
			if(m != leader)
				m.loc = leader


		remove(mob/m)
			m.verbs -= typesof(/party/verb/)
			members << "[m] has left the party"
			members -= m
			m.party = null
			winset(m, "tab_chat", "-chat_party")
			var/turf/L = leader.loc
			m.loc = L
			if(leader == m)
				set_leader()

			if(members.len < 1) del src

		check_leader()
			return leader==members[1]

		set_leader()
			leader = members[1]
			members << "[leader] is the new party leader"
			set_locs()

		set_locs()
			if(leader)
				for(var/mob/m in members-leader)
					m.loc = leader
