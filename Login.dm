mob
	Login()
		..()
		icon = 'players.dmi'
		//bounds = "4,4"
		//bound_x = 14
		//bound_y = 14
		var/obj/start = locate(/obj/start)
		loc = start.loc
		world << "[src] joined"

	Logout()
		world << "[src] left"
		..()


obj/start