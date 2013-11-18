/*

		TL;DR - If you get an error message while running the game, ctrl+f and search it, rather than running
		in DEBUG mode and tracking through the source.



		There are a series of error codes to make debugging a bit easier for us, even though DM does a lot for us.

		Rather than finding the code file we need to, then tracking down the right line that DM spits at us,
		we can just ctrl+f the error # and jump right to it.

		These messages also aren't only ran in debug mode, so in the event of a problem, we can track it
		without having to run the game in debug mode, which makes it (slightly) easier for slower machines.


		What codes are fun without syntax?  None.

		Here's the syntax, because I can!

		ABC

		A - The system
		BC - The unique error

		So, since system 5 is the chat system, and error 5// will be part of the chat system
		This makes things nice because if there are persistent errors in a certain system, the host
		can request players not use that system until it is fixed.  Granted, that's only useful for
		a non-essential system, but it's still a help and it makes things a little easier for
		the (what I'm guessing to be, programming skill-wise) intermediate and under modding community


		Example

		proc/omg_crash(mob/m)            ABC
			if(isturf(m))	CRASH("error 101: [m] is a turf")
			if(isobj(m))	CRASH("error 102: [m] is an obj")



		Basically the idea behind this system is to make everything easier to figure out for
		the people modifying the open source game.


*/