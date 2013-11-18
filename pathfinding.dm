pather

	var/path[]

	New()
		var/newworld[world.maxx][world.maxy]	// Creates a list with dimensions = to the world.
		path = newworld




	proc
		generate()
			for(var/map/path/p)
				path[p.x][p.y] = 1


		get_path(ax, ay, bx, by)
			var/start 	=	new/list("x" = ax, "y" = ay)	// Starting coordinates
			var/end		=	new/list("x" = bx, "y" = by)	// Ending coordinates (destination)
			var/potential[] = path							// Potential paths.  This will contain all the paths found.
			var/final[]										// Final Path from A to B

			/*	Idea for final path.  Saving them when the best path is found.  This will save long-term resources
				ie: Settal to Southshores.

				Without Saving

					Step 1, get_path() from Settal to Southshores
					Step 2, process best path, with however many failed potentials
					Step 3, finally find the final
					Step 4, direct unit along path

				With Saving

					Step 1, find_path() from Settal to Southshores. (see note)
					Step 2, if it exists, direct unit.
							If not, see 'Without Saving'

						note:
								Saving paths would save the starting coordinates, and then a list between them.
								find_path() would take in starting coordinates and return the path if found


				Idea for directing units: Sending a text string (or list?) of dirs to step in order to move from A to B.
				While they move, if they are distracted, they store their last coordinate on the path and last location
				in the string (or list?) and then walk_to() their coordinate to return following directions.

				Another idea is generating all of the path info from every location to every adjacent location, at startup.

			*/

			var/x,y		// x,y coords for the current location of the pathfinder

			x = ax
			y = ay

			if(path[x][y] == 1) // If the starting location is a path
								// We continue on and begin looking for our route!
				potential[x][y] = 1

				if(path[x+1][y] == 1)
					potential[x+1][y] = 1

				if(path[x-1][y] == 1)
					potential[x-1][y] = 1

				if(path[x][y+1] == 1)
					potential[x][y+1] = 1

				if(path[x][y-1] == 1)
					potential[x][y-1] = 1

				if(x == end["x"] && y == end["y"])

					// This is where we generate the final list based off of what we've found.

					return



	/*
		Layman's Terms.

			Step 1, Determine starting and ending location
			Step 2, Calculate a path from A to B
					This will be done by looping through a list of paths until the end is reached

					** Currently, this assumes they are connected by a path, but logic can be added
					to return that no path could be found, in which case the NPC could spit a bunch
					of debug info back to the server, so the developer can fix the problem.

			Step 3, once the path is found, generate the final list
					This will be done by removing uneccesary entities from the list.

					Algorithm?  Maybe this could be done automatically when one direction fails?

			Step 4, generate a string of dirs from A to B.