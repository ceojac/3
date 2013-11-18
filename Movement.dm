client
	var
		vertical
		horizontal


	//  A quick funtion for checking if the
	//	client will accept movement input
	proc/can_move()
		var/mob/m = mob
		if(!(isturf(mob.loc))) .=0 // If the mob is not on a turf, can't move
		if(m.party && m.party.leader != m) .=0  // If the mob is in a party and not the leader, no move
		if(menu_open) .=0	// No movement if menu is open
		else .=1	// Allow movement if all checks pass

	verb
		key_down(k as text)
			if(can_move()) // If the mob can move, allow input
				switch(k)
					if("w")
						vertical = NORTH
					if("s")
						vertical = SOUTH
					if("d")
						horizontal = EAST
					if("a")
						horizontal = WEST
				mob.dir = vertical ^ horizontal
				Step()

		key_up(k as text)
			if(can_move()) // If the mob can move, allow input
				switch(k)
					if("w")
						vertical = 0
					if("s")
						vertical = 0
					if("d")
						horizontal = 0
					if("a")
						horizontal = 0

	proc
		Step()
			if(mob.can_step())
				step(mob,mob.dir)

		reset_keys()
			for(var/k in list("w","a","s","d"))
				call(src,/client/verb/key_up)(k)

mob/proc
	can_step()

		return 1