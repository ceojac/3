world
	fps = 25
	icon_size = 32

	view = 8

mob
	var
		delay = 4
		can_move = 1

	Move()
		if(can_move)
			..()
			can_move = 0; spawn(delay) can_move = 1
	//step_size = 8
	//bound_x = 8
	//bound_y = 3
	//bounds = "8x8"
	density = 1

	//proc/center_loc()
	//	step_x = 16
	//	step_y = 16


obj
	//step_size = 8
