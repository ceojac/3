var
	battletop[] = new
	battlebtm[] = new

world/New()
	..()
	for(var/i in 1 to 11)
		battletop += "battlemap:[i], 11"
		battlebtm += "battlemap:[i], 1"

mob
	Bump(mob/m)
		if(!istype(m, /mob) || !party || !m.party || !party.units || !m.party.units || battle || m.battle)
			..()
		else
			switch(alert("Would you like to engage [m] in battle?",, "Yes", "No"))
				if("Yes")
					if(battle || m.battle) return

					alert(m, "[src] has engaged you in battle!")

					var/battle/btl = new
					battle = btl
					m.battle = btl

					verbs += typesof(/battle/verb)
					m.verbs += typesof(/battle/verb)

					var/locs[] = list(loc, m.loc)
					for(var/map/map in locs)
						btl.envtypes += map

					btl.participants = list(src, m)
					btl.initiator = src
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
		turn = 1

		initiator

		victor

		retreating[] = new

		envtypes[] = new
		obstacles[] = new

	verb
		commit()
			switch(alert("Are you sure you want to commit to this move?",, "Yes", "No"))
				if("Yes")
					var/retreaters
					for(var/unit/u in usr.battle.retreating)
						if(u.party == usr.party)
							retreaters++

					if(!usr.marked && retreaters != usr.party.units.len)
						alert(usr, "You need to select a move first.")
						return
					else
						usr.battlecommitted = 1
						winset(usr, "commit", "is-disabled=true")

						for(var/obj/battlemarker/m in usr.client.screen)
							usr.client.screen -= m

						var/numcomm
						for(var/mob/par in usr.battle.participants)
							if(par.battlecommitted)
								numcomm ++
						if(numcomm == usr.battle.participants.len)	// all of this will have to be put into a proc somewhere eventually so AIs
							usr.battle.execute()					// can use it too.

		forfeit()
			switch(alert("Are you sure you want to forfeit? (Warning: you will lose units!)",, "Yes", "No"))
				if("Yes")
					var/enemyu = 0
					var/usru = 0
					var/usrm = 0
					for(var/mob/par in usr.battle.participants)
						par.battle = null
						par.client.screen = null
						winset(par, "battlemap", "is-visible=false")
						if(par != usr)
							for(var/unit/u in par.party.units)
								enemyu += u.amt
							spawn alert(par, "[usr] has forfeit the battle.")
					for(var/unit/u in usr.party.units)
						usru += u.amt
						usrm ++

					var/losses = 0
					if(!usrm) // no dividing by 0
						losses = round(usru/usrm * (enemyu / (usrm * 50) * 0.25))

					for(var/unit/u in usr.party.units)
						u.amt -= losses
						if(u.amt <= 0)
							u.die()

					alert(usr, "You have lost [losses] of each unit.")

					world << "[usr] has forfeit the battle!"

		compromise()
			switch(alert("Would you like to offer your opponent a compromise?",, "Yes", "No"))
				if("Yes")
					var/acptd = 1
					for(var/mob/par in usr.battle.participants - usr)
						switch(alert("[usr] has offered to compromise.",, "Decline", "Accept"))
							if("Accept")
								acptd ++

					if(acptd == usr.battle.participants.len)
						for(var/mob/par in usr.battle.participants)
							par.battle = null
							par.client.screen = null
							winset(par, "battlemap", "is-visible=false")
							alert(par, "The battle has settled on a compromise.")

					else
						alert(usr, "Your opponent has not accepted the compromise.")
						return

	proc
		initialize()
			var/ptlobsts[] = new

			if(locate(/map/forest) in envtypes)
				ptlobsts += /obj/battleobj/obstacle/forest
			if(locate(/map/hills) in envtypes)
				ptlobsts += /obj/battleobj/obstacle/hills

			if(ptlobsts.len)
				for(var/x in 1 to 11)
					for(var/y in 2 to 10)
						if(prob(15))
							var/coords[] = list(x, y)
							obstacles += coords
							obstacles[coords] = pick(ptlobsts)

			var/nums = 1

			for(var/mob/par in participants)
				var/parnum = nums
				nums++

				if(par.client)
					winset(par, "battlemap", "is-visible=true")
					var/obj/battlegrass/g = new

					par.client.screen += g

					for(var/list/coords in obstacles)
						var/x = coords[1]
						var/y = coords[2]

						var/envtype = text2path("[obstacles[coords]]")
						var/obj/battleobj/obstacle/o = new envtype

						o.screen_loc = "battlemap:[x], [y]"
						o.screenx = x
						o.screeny = y

						par.client.screen += o

				var/numunits = 0
				if(par.party)
					for(var/unit/u in par.party.units)
						numunits++

						var/obj/battleobj/unitobj/o = new

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
								if(p == par)
									o.screen_loc = "battlemap:[u.battlex], [u.battley]"
									p.client.screen += o
								else
									var/obj/battleobj/unitobj/o2 = new o.type

									o2.screen_loc = "battlemap:[u.battlex], [u.battley]"

									o2.realunit = u
									o2.battle = src

									o2.icon = 'players.dmi'
									o2.icon_state = "[u.name]"
									o2.name = u.name

									u.battlescrnobjs += o2
									p.client.screen += o2

		execute()

			var/attacking[] = new
			var/moving[] = new
			var/movinglocs[] = new

			//marking phase

			phase = "Marking"

			for(var/mob/par in participants)
				if(par.marked)
					var/unit/unit = par.marked.parentunit
					var/obj/battlemarker/mrk = par.marked

					if(!istype(mrk, /obj/battlemarker/attack) && !istype(mrk, /obj/battlemarker/retreat))
						moving += unit
						moving[unit] = mrk

					else if(istype(mrk, /obj/battlemarker/attack))
						var/obj/battlemarker/attack/atm = mrk
						attacking += unit
						attacking[unit] = atm.markedunit

					else if(istype(mrk, /obj/battlemarker/retreat))
						retreating += unit

					if(par.client)
						for(var/obj/battlemarker/m in par.client.screen)
							par.client.screen -= m

			//executing phase

			phase = "Executing"

			participants << output("<HR><center>Turn [turn]</center><HR>", "battleoutput")

			for(var/unit/unit in attacking)

				var/unit/atu = attacking[unit]
				if(!atu) continue
				var/ranged = (atu.battlex > unit.battlex + 1 || atu.battley > unit.battley + 1 || atu.battley < unit.battley - 1 || atu.battlex < unit.battlex - 1) ? 1 : 0
				if(ranged || (locate(atu) in attacking && attacking[atu] != unit))
					var/dist
					if(locate(atu) in moving)
						var/obj/battlemarker/m = moving[atu]
						dist = max(m.screenx - atu.battlex, atu.battlex - m.screenx, m.screeny - atu.battley, atu.battley - m.screeny)

					attack(unit, atu, ranged, dist)	// combat() allows atu to attack back, don't want atu to attack back if they are attacking someone else
				else
					combat(unit, atu)
					attacking -= atu	// so units don't engage in combat twice if they are both marked

			for(var/unit/unit in retreating)

				var/xs[] = new
				var/ys[] = new

				var/movex
				var/movey

				for(var/x = unit.spd, x > 0, x--)
					xs += ((unit.battlex + x) <= 11	) ? unit.battlex + x : null
					xs += ((unit.battlex - x) > 0	) ? unit.battlex - x : null

				for(var/y = unit.spd, y > 0, y--)
					ys += ((unit.battley + y) <= 11	) ? unit.battley + y : null
					ys += ((unit.battley - y) > 0	) ? unit.battley - y : null

				for(var/obj/battleobj/b in unit.party.leader.client.screen)
					if(istype(b, /obj/battleobj/unitobj))
						var/obj/battleobj/unitobj/o = b
						if(o.realunit.battley == unit.battley && locate(o.realunit.battlex) in xs)
							for(var/x in xs)
								if((o.realunit.battlex > unit.battlex && x >= o.realunit.battlex) || (o.realunit.battlex < unit.battlex && x <= o.realunit.battlex))
									xs -= x
						if(o.realunit.battlex == unit.battlex && locate(o.realunit.battley) in ys)
							for(var/y in ys)
								if((o.realunit.battley > unit.battley && y >= o.realunit.battley) || (o.realunit.battley < unit.battley && y <= o.realunit.battley))
									ys -= y

					else if(istype(b, /obj/battleobj/obstacle))
						var/obj/battleobj/obstacle/o = b
						if(o.screeny == unit.battley && locate(o.screenx) in xs)
							for(var/x in xs)
								if((o.screenx > unit.battlex && x >= o.screenx) || (o.screenx < unit.battlex && x <= o.screenx))
									xs -= x
						if(o.screenx == unit.battlex && locate(o.screeny) in ys)
							for(var/y in ys)
								if((o.screeny > unit.battley && y >= o.screeny) || (o.screeny < unit.battley && y <= o.screeny))
									ys -= y

				if(unit.party.leader == initiator && unit.battley != 11)
					if(ys.len && max(ys) > unit.battley)
						movey = max(ys)

					else if(xs.len)
						movex = pick(max(xs), min(xs))

					else if(max(ys) < unit.battley)
						movey = max(ys)

				else if(unit.battley != 1)
					if(ys.len && min(ys) < unit.battley)
						movey = min(ys)

					else if(xs.len)
						movex = pick(max(xs), min(xs))

					else if(min(ys) > unit.battley)
						movex = min(ys)

				if(movex || movey)
					if(movex) unit.battlex = movex
					else if(movey) unit.battley = movey

					for(var/obj/battleobj/o in unit.battlescrnobjs)
						o.screen_loc = "battlemap:[unit.battlex], [unit.battley]"

					participants << output("<b>[unit.party.leader]</b>'s <b>[unit]</b> has retreated to <b>[unit.battlex]</b>, <b>[unit.battley]</b>.", "battleoutput")

					movinglocs += unit
					movinglocs[unit] = "battlemap:[unit.battlex], [unit.battley]"

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
						if(con.party == unit.party) win = con
						else
							world << 1
							win = combat(unit, con, 1)
							if(win != con)
								moving -= con
								movinglocs -= con	// so it will not enter the loop again

				if(((win != unit && !conflicted) || (win == unit && conflicted)) && !locate(unit) in retreating)
					var/scrnloc = movinglocs[unit]
					var/obj/battlemarker/mrk = moving[unit]
					for(var/obj/battleobj/o in unit.battlescrnobjs)
						o.screen_loc = scrnloc
					unit.battlex = mrk.screenx
					unit.battley = mrk.screeny
					participants << output("<b>[unit.party.leader]</b>'s <b>[unit]</b> has moved to <b>[unit.battlex]</b>, <b>[unit.battley]</b>.", "battleoutput")

				else if(!win && conflicted)
					moving -= unit
					movinglocs -= unit	// so it will not enter the loop again

			reset()

		combat(unit/atkr, unit/defr, returnvictor = 0)
			var/adam = max(0, round(atkr.atk/5 * atkr.amt / defr.def + rand(-atkr.amt/5, atkr.amt/5)))
			var/ddam = max(0, round(defr.atk/5 * defr.amt / atkr.def + rand(-defr.amt/5, defr.amt/5)))

			defr.amt -= adam
			atkr.amt -= ddam

			var/adamtrue = defr.amt <= 0 ? adam + defr.amt : adam
			var/ddamtrue = atkr.amt <= 0 ? ddam + atkr.amt : ddam

			participants << output("<b>[atkr.party.leader]</b>'s <b>[atkr]</b> received [ddamtrue] casualties from <b>[defr.party.leader]'s <b>[defr]</b>.", "battleoutput")

			participants << output("<b>[defr.party.leader]</b>'s <b>[defr]</b> received [adamtrue] casualties from <b>[atkr.party.leader]'s <b>[atkr]</b>.", "battleoutput")

			if(atkr.amt < 1)
				participants << output("<b>[atkr.party.leader]</b>'s <b>[atkr]</b> has perished in battle.", "battleoutput")
				atkr.die()

			if(defr.amt < 1)
				participants << output("<b>[defr.party.leader]</b>'s <b>[defr]</b> has perished in battle.", "battleoutput")
				defr.die()

			if(returnvictor)
				if(defr && atkr)
					var/atktotal = atkr.amt/atkr.max
					var/deftotal = defr.amt/defr.max

					return atktotal != deftotal ? ((atktotal > deftotal) ? atkr : defr) : 0
				else if(defr) return defr
				else if(atkr) return atkr

		attack(unit/atkr, unit/defr, ranged = 0, dist)
			var/adam = max(0, round(atkr.atk/5 * atkr.amt / (defr.def + (ranged ? dist : 0)) + rand(-atkr.amt/5, atkr.amt/5)))

			defr.amt -= adam

			var/adamtrue = defr.amt <= 0 ? adam + defr.amt : adam

			if(defr.amt <= 0)
				participants << output("<b>[defr.party.leader]</b>'s <b>[defr]</b> has perished in battle.", "battleoutput")
				defr.die()
			else
				participants << output("<b>[defr.party.leader]</b>'s <b>[defr]</b> received [adamtrue] casualties from <b>[atkr.party.leader]'s <b>[atkr]</b>.", "battleoutput")


		reset()
			var/mob/victor
			var/mob/loser
			for(var/mob/par in participants)
				if(par.party && !par.party.units.len) // par.party check is for debugging using partyless AI
					loser = par
					world << loser
				else
					world << par.party.units.len
			for(var/mob/par in participants)
				if(loser && loser != par)
					victor = par
					world << victor
					break

			for(var/mob/par in participants)
				par.marked = null
				if(par.client)	// mostly for debugging using ai
					par.battlecommitted = 0
					winset(par, "commit", "is-disabled=false")
					for(var/obj/battleobj/unitobj/o in par.client.screen)
						if(!o.realunit && o.icon != 'grass.dmi')
							del o
				if(victor)
					par.battle = null
					par.client.screen = null
					winset(par, "battlemap", "is-visible=false")

			if(victor)
				world << "[victor] has defeated [loser]!"
				alert(victor, "A winner is you!")
				del src

			phase = "Issuing"
			turn ++

obj
	battlegrass
		icon = 'grass.dmi'
		mouse_opacity = 0
		screen_loc = "battlemap:1,1 to 11,11"
		layer = OBJ_LAYER - 0.54

	battleobj
		obstacle
			var
				screenx
				screeny

			forest
				icon = 'forest.dmi'

			hills
				icon = 'hills.dmi'

		unitobj
			var
				unit/realunit
				battle/battle

				twinobjs[] = new

			mouse_opacity = 2

			Click()
				if(!realunit || (realunit && battle.phase != "Issuing") || realunit.party != usr.party || usr.battlecommitted || locate(realunit) in battle.retreating) ..()

				else
					for(var/obj/battlemarker/b in usr.client.screen)
						usr.client.screen -= b

					var/unit/u = realunit

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

							for(var/obj/battleobj/o in usr.client.screen)
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

					for(var/obj/battleobj/unitobj/b in usr.client.screen)
						if(!b.realunit)
							continue
						var/unit/bu = b.realunit
						if(bu.battlex >= u.battlex - u.rng && bu.battlex <= u.battlex + u.rng && bu.battley >= u.battley - u.rng && bu.battley <= u.battley + u.rng)
							if(bu.party != u.party) //bu != u) //for debugging with ai
								var/obj/battlemarker/attack/m = new

								m.screen_loc = "battlemap:[bu.battlex], [bu.battley]"
								usr.client.screen += m
								m.parentunit = realunit
								m.screenx = bu.battlex
								m.screeny = bu.battley
								m.markedunit = bu

					if(battle.initiator == usr)
						for(var/scrnloc in battletop)
							var/no
							for(var/obj/battleobj/o in usr.client.screen)
								if(o.screen_loc == scrnloc)
									no = 1

							if(no) continue

							if(realunit.battley == 11) break

							var/obj/battlemarker/retreat/m = new

							m.dir = NORTH
							m.screen_loc = scrnloc
							m.screeny = 11
							usr.client.screen += m
							m.parentunit = realunit

					else
						for(var/scrnloc in battlebtm)
							var/no
							for(var/obj/battleobj/o in usr.client.screen)
								if(o.screen_loc == scrnloc)
									no = 1

							if(no) continue

							if(realunit.battley == 1) break

							var/obj/battlemarker/retreat/m = new

							m.dir = SOUTH
							m.screen_loc = scrnloc
							m.screeny = 1
							usr.client.screen += m
							m.parentunit = realunit

	battlemarker
		icon = 'battleicons.dmi'
		mouse_opacity = 2

		var
			unit/parentunit
			unit/markedunit

			screenx
			screeny

		Click()
			for(var/obj/battlemarker/b in usr.client.screen)
				if(b.icon_state == "highlight1") b.icon_state = "highlight"
				else if(b.icon_state == "marker1") b.icon_state = "marker"
				else if(b.icon_state == "arrow1") b.icon_state = "arrow"

			if(istype(src, /obj/battlemarker/attack))
				icon_state = "marker1"

			else if(istype(src, /obj/battlemarker/retreat))
				icon_state = "arrow1"

				if(screeny == 11)
					for(var/obj/battlemarker/retreat/m in usr.client.screen)
						if(m.screeny == 11)
							m.icon_state = "arrow1"

				else if(screeny == 1)
					for(var/obj/battlemarker/retreat/m in usr.client.screen)
						if(m.screeny == 1)
							m.icon_state = "arrow1"
			else
				icon_state = "highlight1"
			usr.marked = src

		name = "move"

		attack
			icon_state = "marker"
			name = "attack"

		retreat
			icon_state = "arrow"
			name = "retreat"

unit
	var
		atk			// damage they do on offense
		spd			// amount of spaces they can move
		rng			// amount of spaces away they can attack
		def			// damage minimized on defense
		amt			// amount of troops in the unit
		mor	= 100	// morale. this affects the independent action of the units
		max = 50	// max amount of troops in the unit

		name

		party/party

		battlex
		battley

		battlescrnobjs[] = new

	proc
		die()
			party.units -= src
			del src

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