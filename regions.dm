/*

	Regions in Haz3

	Different regions will give different random events.

	Regions are divided into subregions

	region
		settal
			settal
			forest
			southshores
			desert

	different subregions will give different random events specific to that region and area within it

	For example, the forest region of settal will give events specific to the forest and settal
	such as a bandit encounter, while the settal proper region may have events that will be along the lines
	of an abandoned caravan or the like


	*/

region
	parent_type = /area
	var
		parent_region = "null parent"

	Entered(mob/m)
		if(ismob(m) && m.client)
			msg(m, "<i>Now entering [src] ([parent_region])</i>", "output_local")


	hdrozum
		settal
			parent_region = "Settal"
			settal
				name = "Settal"
			forest
				name = "The Great Forest"
			plains
				name = "The Plains"
			desert
				name = "The Dry Pass"
			coast
				name = "The Coast"



		elvial
			parent_region = "Elvial"

			coast
				name = "The Coast"
			hills
				name = "The Golden Hills"
			valley
				name = "The Valley of the Aels"


		nortal
			parent_region = "Nortal"
			nort
				name = "Nort"
			lartek
				name = "Lartek's Pass"