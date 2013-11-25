setting
	parent_type = /obj
	var
		info	=	"null setting info"

	New()
		..()
		if(!(istype(src,/settlement)))
			world << "Random Event!"

settlement
	parent_type = /setting
	icon = 'World Map/settlements.dmi'

	signpost
		icon = 'World Map/path.dmi'
		icon_state = "sign"
		var
			north
			south
			east
			west

		Crossed(mob/m)
			if(ismob(m) && m.client)
				msg(m, "[directions()]", "output_local")

		proc/directions()
			.=""
			if(north)	.+= "North: [north]"
			if(south)	.+= "South: [south]"
			if(east)	.+= "East: [east]"
			if(west)	.+= "West: [west]"


	Crossed(mob/m)
		if(istype(m))
			m.Move(src)

	Entered(mob/enterer)
		..()

		for(var/mob/occupant in src)
			if(occupant.client)
				msg(occupant, "[enterer] has entered [src]", "output_local")

		if(enterer.client)
			enterer.client.enter_setting(enterer.client, src)
			//enterer.verbs += src.verbs

	Exited(mob/exiter)
		for(var/mob/occupant in src)
			if(occupant.client)
				msg(occupant, "[exiter] has left [src]", "output_local")
		//exiter.verbs -= src.verbs

	city
		verb
			recruit()
				set src in view(0)
				if(!usr.party)
					alert("You have no party to recruit to.")
					return

				var/types[] = new

				for(var/u in typesof(/unit) - /unit)
					new u
					types += u

				var/recruitstype = input("Recruit what type of units?") in types 	// need to change this sometime to select them by name instead of
																					// path, might need to use something other than input() (plus input
				var/num = input("How many would you like?") as num					// looks ugly)

				var/party/party = usr.party
				var/unit/recruits = new recruitstype

				var/mems[] = new

				for(var/unit/found in party.units)
					if(istype(found, recruits.type))
						world << "found"
						mems += found

				var/uamt
				for(var/u in party.units)
					if(u)
						uamt++

				if(mems.len >= 1 && uamt < party.unitsmax)
					world << "party units = [uamt]/[party.unitsmax]"
					switch(alert("Would you like to add a unit to your party or increase the amount of an existing unit?",, "Add", "Existing"))
						if("Add")
							if(uamt < party.unitsmax)
								party.units += recruits
								recruits.amt += num
								recruits.party = party
								if(recruits.amt > recruits.max) recruits.amt = recruits.max
								world << "[recruits] = [recruits.amt]"
						if("Existing")
							var/unit/mem = input("Which unit would you like to increase?") in mems	// why doesnt this line work!!!!!!!!!!!
							mem.amt += num
							if(mem.amt > mem.max) mem.amt = mem.max
							world << "[mem] = [mem.amt]"

				else if(uamt < party.unitsmax)
					party.units += recruits
					recruits.amt += num
					recruits.party = party
					if(recruits.amt > recruits.max) recruits.amt = recruits.max
					world << "[recruits] = [recruits.amt]"
				else
					world << "You cannot have any more units in your party."

	fort
	village
	dock

	hdrozum

		fort
			icon_state = "hdrozum_fort"
		city
			icon_state = "hdrozum_city"
			parent_type = /settlement/city
		village
			icon_state = "hdrozum_village"
		dock
			icon = 'World Map/dock.dmi'


	eret
		fort
			icon_state = "eret_fort"
		city
			icon_state = "eret_city"
		village
			icon_state = "eret_village"
		dock
			icon = 'World Map/dock.dmi'


	gal_cal
		fort
			icon_state = "galcal_fort"
		city
			icon_state = "galcal_city"
		village
			icon_state = "galcal_village"
		dock
			icon = 'World Map/dock.dmi'