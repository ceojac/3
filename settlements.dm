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
				var/recruits = input("Recruit what type of units?") in list("light infantry",
																	"heavy infantry",
																	"spear infantry",
																	"light ranged",
																	"heavy ranged",
																	"skirmishers",
																	"light cavalry",
																	"heavy cavalry",
																	"religious")
				var/num = input("How many [recruits] would you like?") as num
				var/list/mems = usr.party.members
				if(recruits in mems)
					mems[recruits] += num
				else
					mems += "[recruits]"
					mems[recruits] = num
				world << "[recruits] = [mems[recruits]]"
				usr.party.members = mems
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