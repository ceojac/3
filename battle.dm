mob
	Bump(mob/m)
		if(!party)
		 ..()
		else
			switch(alert("Would you like to engage [m] in battle?",, "Yes", "No"))
				if("Yes")
					var/battle/btl = new
					battle = btl
					m.battle = btl
					verbs += typesof(/battle/verb)
					m.verbs += typesof(/battle/verb)
					btl.participants = list(src, m)
					btl.initialize()

				if("No") return

	ai
		battlecommitted = 1

	var
		battlecommitted
		battle/battle

		obj/battlemarker/marked

	Stat()
		if(battle)
			src << output("Phase: [battle.phase]", "phase")

battle
	var
		participants[]

		phase = "Issuing"

		victor

	verb
		commit()
			switch(alert("Are you sure you want to commit to this move?",, "Yes", "No"))
				if("Yes")
					if(!usr.marked)
						usr << "You need to select a move first."
						return
					else
						usr.battlecommitted = 1
						winset(usr, "commit", "is-disabled=true")

						var/numcomm
						for(var/mob/par in usr.battle.participants)
							if(par.battlecommitted)
								numcomm ++
						if(numcomm == usr.battle.participants.len)	// all of this will have to be put into a proc somewhere eventually so AIs
							usr.battle.execute()					// can use it too.

				if("No") return

	proc
		initialize()
			var/nums = 1

			for(var/mob/par in participants)
				var/parnum = nums
				nums++

				if(par.client)
					winset(par, "battlemap", "is-visible=true")
					var/obj/battleobj/g = new
					g.icon = 'grass.dmi'
					g.mouse_opacity = 0
					g.screen_loc = "battlemap:1,1 to 11,11"
					par.client.screen += g

					for(var/mob/p in participants)
						if(p.client) p.client.screen += g

				var/numunits = 0
				if(par.party)
					for(var/unit/u in par.party.units)
						numunits++

						var/obj/battleobj/o = new

						o.realunit = u
						u.battlescrnobjs += o
						o.battle = src

						o.icon = 'players.dmi'
						o.icon_state = "[u.name]"
						o.name = u.name

						u.battlex = round(11/2) - round(par.party.units.len/2) + numunits
						if(parnum == 1) u.battley = 11
						else u.battley = 1

						for(var/mob/p in participants)
							if(p.client)
								o.screen_loc = "battlemap:[u.battlex], [u.battley]"
								if(p == par)
									p.client.screen += o
								else
									var/obj/battleobj/o2 = new o.type
									u.battlescrnobjs += o2
									p.client.screen += o2
									o.twinobjs += o2
									o2.twinobjs += o

		execute()

			var/attacking[] = new
			var/rngattacking[] = new
			var/moving[] = new

			//marking phase

			phase = "Marking"

			for(var/mob/par in participants)
				if(par.marked)
					var/unit/unit = par.marked.parentunit
					var/obj/battlemarker/mrk = par.marked
					if(!istype(mrk, /obj/battlemarker/attack))
						moving += unit
						moving[unit] = mrk
					else
						var/obj/battlemarker/attack/atm = mrk
						if(unit.rng > 1)					// need to change this for distance instead of the rng variable
							rngattacking += unit
							rngattacking[unit] = atm.markedunit
						else
							attacking += unit
							attacking[unit] = atm.markedunit

					if(par.client)
						for(var/obj/battlemarker/m in par.client.screen)
							par.client.screen -= m

			//executing phase

			phase = "Executing"

			for(var/unit/unit in attacking)
				var/unit/atu = attacking[unit]
				if(locate(atu) in attacking && attacking[atu] != unit)
					attack(unit, atu)	// combat() allows atu to attack back, don't want atu to attack back if they are attacking someone else
				if(atu) combat(unit, atu)
				attacking -= unit	// so units don't engage in combat twice if they are both marked

			for(var/unit/unit in rngattacking)
				var/unit/atu = rngattacking[unit]
				var/ranged = (atu.battlex > unit.battlex + 1 || atu.battley > unit.battley + 1 || atu.battley < unit.battley - 1 || atu.battlex < unit.battlex - 1) ? 1 : 0
				attack(unit, atu, ranged)

			var/movinglocs[] = new

			for(var/unit/unit in moving)
				var/obj/battlemarker/mrk = moving[unit]
				var/scrnloc = "battlemap:[mrk.screenx], [mrk.screeny]"
				movinglocs += unit
				movinglocs[unit] = scrnloc

			for(var/unit/unit in movinglocs)
				var/unit/win
				var/conflicted
				for(var/unit/con in movinglocs)
					if(con == unit) continue
					else if(movinglocs[con] == movinglocs[unit])
						conflicted = 1
						win = combat(unit, con, 1)
						if(win != con)
							moving -= con
							movinglocs -= con	// so it will not enter the loop again

				if((!win && !conflicted) || (win && conflicted))
					var/scrnloc = movinglocs[unit]
					var/obj/battlemarker/mrk = moving[unit]
					for(var/obj/battleobj/o in unit.battlescrnobjs)
						o.screen_loc = scrnloc
					unit.battlex = mrk.screenx
					unit.battley = mrk.screeny
					participants << output("<b>[unit.party.leader]</b>'s <b>[unit]</b> has moved to <b>[unit.battlex]</b>, <b>[unit.battley]</b>.")

				else if(!win && conflicted)
					moving -= unit
					movinglocs -= unit	// so it will not enter the loop again


			reset()

		combat(unit/atkr, unit/defr, returnvictor = 0)
			var/adam = max(0, round(((atkr.atk/5) - (defr.def/5)) * atkr.amt + rand(-1*atkr.amt/5, atkr.amt/5)))
			var/ddam = max(0, round(((defr.atk/5) - (atkr.def/5)) * defr.amt + rand(-1*defr.amt/5, defr.amt/5)))

			defr.amt -= adam
			atkr.amt -= ddam

			var/adamtrue = defr.amt <= 0 ? adam + defr.amt : adam
			var/ddamtrue = atkr.amt <= 0 ? ddam + atkr.amt : ddam

			if(atkr.amt <= 0)
				participants << output("<b>[atkr.party.leader]</b>'s <b>[atkr]</b> has perished in battle.", "battleoutput")
				del atkr
			else
				participants << output("<b>[atkr.party.leader]</b>'s <b>[atkr]</b> received [ddamtrue] casualties from <b>[defr.party.leader]'s <b>[defr]</b>.", "battleoutput")
			if(defr.amt <= 0)
				participants << output("<b>[defr.party.leader]</b>'s <b>[defr]</b> has perished in battle.", "battleoutput")
				del defr
			else
				participants << output("<b>[defr.party.leader]</b>'s <b>[defr]</b> received [adamtrue] casualties from <b>[atkr.party.leader]'s <b>[atkr]</b>.", "battleoutput")

			if(returnvictor)
				if(defr && atkr)
					var/atktotal = atkr.amt/atkr.max
					var/deftotal = defr.amt/defr.max

					return atktotal != deftotal ? ((atktotal > deftotal) ? atkr : defr) : 0
				else if(defr) return defr
				else if(atkr) return atkr

		attack(unit/atkr, unit/defr, ranged = 0)
			var/adam = max(0, round((((atkr.atk + (ranged ? atkr.rng-defr.spd : 0))/5) - (defr.def/5)) * atkr.amt + rand(-atkr.amt/5, atkr.amt/5)))

			defr.amt -= adam

			var/adamtrue = defr.amt <= 0 ? adam + defr.amt : adam

			if(defr.amt <= 0)
				participants << output("<b>[defr.party.leader]</b>'s <b>[defr]</b> has perished in battle.", "battleoutput")
				del defr
			else
				participants << output("<b>[defr.party.leader]</b>'s <b>[defr]</b> received [adamtrue] casualties from <b>[atkr.party.leader]'s <b>[atkr]</b>.", "battleoutput")


		reset()
			var/mob/victor
			var/mob/loser
			for(var/mob/par in participants)
				if(par.party && !par.party.units) // par.party check is for debugging using partyless AI
					loser = par
			for(var/mob/par in participants)
				if(loser && loser != par)
					victor = par
					break

			for(var/mob/par in participants)
				par.marked = null
				if(par.client)	// mostly for debugging using ai
					par.battlecommitted = 0
					winset(usr, "commit", "is-disabled=false")
					for(var/obj/battleobj/o in par.client.screen)
						if(!o.realunit && o.icon != 'grass.dmi')
							del o
				if(victor)
					par.battle = null
					par.client.screen = list(null)
					winset(par, "battlemap", "is-visible=false")

			if(victor)
				world << "[victor] has defeated [loser]!"
				del src

			phase = "Issuing"

obj
	battleobj
		var
			unit/realunit
			battle/battle

			twinobjs[] = new

		Click()
			if(!realunit || (realunit && battle.phase != "Issuing") || realunit.party != usr.party) ..()

			else
				for(var/obj/battlemarker/b in usr.client.screen)
					usr.client.screen -= b

				var/unit/u = realunit
				var/us[] = realunit.party.units

				for(var/dirs = 1, dirs <= 4, dirs ++)
					var/no
					for(var/tiles = 1, tiles <= u.spd, tiles ++)
						var/scrnloc
						var/calc

						var/x
						var/y

						switch(dirs)

							if(1)
								calc = u.battlex + tiles
								if(calc <= 11 && calc > 0)
									scrnloc = "battlemap:[calc], [u.battley]"
									x = calc
									y = u.battley

							if(2)
								calc = u.battlex - tiles
								if(calc <= 11 && calc > 0)
									scrnloc = "battlemap:[calc], [u.battley]"
									x = calc
									y = u.battley

							if(3)
								calc = u.battley + tiles
								if(calc <= 11 && calc > 0)
									scrnloc = "battlemap:[u.battlex], [calc]"
									x = u.battlex
									y = calc

							if(4)
								calc = u.battley - tiles
								if(calc <= 11 && calc > 0)
									scrnloc = "battlemap:[u.battlex], [calc]"
									x = u.battlex
									y = calc

						for(var/unit/ua in us)
							if(scrnloc)
								for(var/obj/battlemarker/o in ua.battlescrnobjs)
									if(o.screen_loc == scrnloc)
										no = 1

						var/obj/battlemarker/m = new
						m.icon_state = "highlight"

						m.screen_loc = no ? null : scrnloc

						if(m.screen_loc)
							usr.client.screen += m
							m.parentunit = realunit
							m.screenx = x
							m.screeny = y

				for(var/obj/battleobj/b in usr.client.screen)
					if(!b.realunit)
						continue
					var/unit/bu = b.realunit
					if(bu.battlex >= u.battlex - u.rng && bu.battlex <= u.battlex + u.rng && bu.battley >= u.battley - u.rng && bu.battley <= u.battley + u.rng)
						if(bu.party != u.party)//bu != u) //for debugging with ai
							var/obj/battlemarker/attack/m = new

							m.screen_loc = "battlemap:[bu.battlex], [bu.battley]"
							usr.client.screen += m
							m.parentunit = realunit
							m.screenx = bu.battlex
							m.screeny = bu.battley
							m.markedunit = bu


	battlemarker
		icon = 'battleicons.dmi'

		var
			unit/parentunit
			unit/markedunit

			screenx
			screeny

		Click()
			for(var/obj/battlemarker/b in usr.client.screen)
				if(b.icon_state == "highlight1")
					b.icon_state = "highlight"
				if(b.icon_state == "marker1")
					b.icon_state = "marker"
			if(istype(src, /obj/battlemarker/attack))
				icon_state = "marker1"
			else
				icon_state = "highlight1"
			usr.marked = src

		attack
			icon_state = "marker"

unit
	var
		atk			// damage they do on offense
		spd			// amount of spaces they can move
		rng			// amount of spaces away they can attack
		def			// damage minimized on defense
		amt			// amount of troops in the unit
		max = 50	// max amount of troops in the unit

		name

		party/party

		battlex
		battley

		battlescrnobjs[] = new

	infantry
		name = "infantry"

		atk = 3
		spd = 1
		rng = 1
		def = 4

	archer
		name = "archer"

		atk = 2
		spd = 2
		rng = 3
		def = 1

	cavalry
		name = "cavalry"

		atk = 4
		spd = 3
		rng = 1
		def = 2