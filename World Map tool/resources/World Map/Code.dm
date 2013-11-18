
map
	parent_type = /turf
	var/set_delay = 4
	Entered(mob/m)
		if(ismob(m)) m.delay = set_delay

	grass
		icon = 'World Map/grass.dmi'

	snow
		icon = 'World Map/snow.dmi'
		set_delay = 6

	hills
		icon = 'World Map/hills.dmi'
		set_delay = 6

	forest
		icon = 'World Map/forest.dmi'
		set_delay = 5

	palm
		icon = 'World Map/palmforest.dmi'
		set_delay = 5

	river
		icon = 'World Map/river.dmi'
		density = 1

	path
		icon = 'World Map/path.dmi'
		set_delay = 3.5

	ocean
		icon = 'World Map/ocean.dmi'
		density = 1

	mountain
		icon = 'World Map/mountains.dmi'
		density = 1
