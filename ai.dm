mob
	verb
		cardinal(n as num)
			n |= 15
			usr << n

		get_z()
			usr << z
	ai
		icon = 'players.dmi'
		icon_state = "ai"

		var/settlement/destination



		Click()

			destination = input("Where shall I go?") as obj in world
			msg(usr, "Walking to [destination]", "output_ooc")
			follow_path(destination)


		proc
			follow_path(settlement/dest)
				var/vec = get_dir(src, dest)

				if(!istype(loc,/map/path))
					world << "nopath [src], [usr]"
					var/map/path/path
					for(var/i=1; i<=world.view; i++)
						world << i
						path = locate() in view(i,src)
						if(path)
							world << "path found at [path.x] [path.y]"
							walk_to(src, path)
							break

				world << "walking to [dest]"
				for(var/map/path/p in oview(1,src))
					if(vec == get_dir(src,dest))
						step_to(src, p)