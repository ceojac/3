
mob
	Login()
		..()
		client.start_creation()

client

	var creation/creation

	verb
		start_creation()
			set hidden = 1
			winset(src, "menu_child", "left=creation")
			winset(src, "menu_child", "is-visible=true")
			creation = new (src)

		finish_creation()
			set hidden = 1
			if(creation && !creation.finished)
				creation.finish()

		change_choice(item as text, direction as text)
			set hidden = 1
			if(creation && !creation.finished)
				creation.change_choice(item, text2num(direction))

creation
	proc
		finish()
			finished = 1
			winset(owner, "menu_child", "is-visible=false")

/*
	-------------------
	Le-Vars
	-------------------
*/

	var
		finished

		owner

		race
		gender
		heritage
		family
		aeliom
		earlylife
		vocation

/*
	-------------------
	Le-Choices, one big list.
	-------------------
*/

	var
		choices[] = list(

			"race"					=	list(
				"Human"				=	"You live off the fruits of the mainland and toil against the many dangers that meet you at every turn.",
				"Orc"				=	"You reside in the ancestral home of the Orcs, Eths'ten Jey, deep in the eastern jungles.  Your people are hunters by nature, and seldom leave their home."
			),

			"gender_human"			=	list(
				"Male"				=	", a strong and hearty member of society.  You work hard for the survival of your people.",
				"Female"			=	".  Your duties to your people are less strenuous than those of the men, but you do what you can to help the rest of your people get by."
			),

			"gender_orc"			=	list(
				"Male"				=	", a strong and hearty member of society.  You work hard for the survival of your people.",
				"Female"			=	", revered by the men of your clan.  You spend your days mothering the heirs to your clans legacy and giving spiritual guidance to your clan."
			),

			"heritage_human"		=	list(
				"Plainsman"			=	"Your family is descended from the ancient plainsmen.  Your ancestors were among the founders of Settal, the first settlement.  You were born with a love for the wind and wide open plains.",
				"Shoreman"			=	"Your family is descended from the peoples of the southern shoreline of the mainlands.  You were born with a love for the smell of salty ocean air and for the fish that it provides.",
				"Northern"			=	"Your family is descended from the wild clans of the north.  Your people have for long been revered throughout all the kingdoms as fierce warriors.  You were born with a high tolerance to the cold, and strong mountain lungs."
			),

			"heritage_orc"			=	list(
				"Warcry"			=	"Your lineage hails from the legendary Clan Warcry.  The original clan, it was once led by the great High-Chief Folchak Warcry, who ascended into Aeldom by the hands of Orcia.  Your clan can be distinguished by fierce fangs, jutting from their lower lips, and yellow-green skin.",
				"Windhowl"			=	"Your lineage hails from the mysterious Clan Windhowl.  Your kin are renowned hunters among the orc clans.  Stealth and cunning are two traits common among your kind.  Your clan can be distinguished by two horns on their foreheads, and their deep green skin.",
				"Stonehammer"		=	"Your lineage hails from the mighty Clan Stonehammer.  Your kin are the most fearsome warriors in all the land, and are known across the orc clans as being the defenders of the Sacred Forest.  Your clan can be distinguished by a large bone plate on their foreheads, and pale green skin."
			),

			"family_human"			=	list(
				"Peasantry"			=	"was that your family had toiled in peasantry as far back as anyone could remember.  They never had much and were always the first to lose when troubles came to the land.",
				"Wanderers"			=	"were the stories of the lands your family had travelled through.  They were always a nomadic bunch, travelling wherever they felt would be best for the time being, and moving on when they saw fit.",
				"Landowners"		=	"was your rich written family history that most didn’t have.  Your family was always privileged, having owned land for many generations.  Your family had always done right by the local lord and on occasion held dinners for others of similar status."
			),

			"family_orc"			=	list(
				"Hunters"			=	"cunning hunters.  Your kin were always sent for the most difficult hunts, being revered among the clan for trapping and killing the most prized trophies.",
				"Warriors"			=	"mighty warriors.  Your forefathers were called upon when the clan was facing times of war with neighboring clans or intrusions on the sacred forest from foreign forces.",
				"Spiritual"			=	"being in touch with the forces of nature.  The mothers of your bloodline were sought by orcs far and wide for spiritual guidance."
			),

			"aeliom_human"			=	list(
				"The High Family"	=	"The High Family of the Aels, comprised of Cicero, the High Hdroza (High King) of all the Aels, and his immediate family.  The members are as follows:  Cicero, Ael of Justice; Zor, Elder Brother of Cicero and Ael of Wisdom; Ayora, Daughter of Zor and Ael of Sea and Song; Chao, Son of Zor and Ael of Knowledge.",
				"The Dark Ones"		=	"The Dark Ones, worship of whom is frowned upon by many and outlawed completely in some areas, and as such must be kept secret.  The dark ones are Tich, the Betrayer and Ael of Lies and Deceit; Draolus, the Dark One and younger half brother to Cicero and Zor, the Ael of Fear; and Rith, the Ael of mischief.”"
			),

			"aeliom_orc"			=	list(
				"Folchak"			=	"Folchak, The Great Chief.  You call on him on your hunts to give you strength to slay your prey.  Folchak was once the chief of the great Clan Warcry in the earliest days of the orcs, and was so great a leader and warrior that Orcia ascended him to aeliom to forever be her husband and chief to all orcs.",
				"Orcia"				=	"Orcia, the Clan mother, Wife of Folchak.  You ask her to protect the home she made for your clan in the dawn of time.  She guided the first of the orcs from the dark times and brought them to the sacred forest in which they have lived since time immemorial.  All living things are a part of Orcia, and for that they are all a part of a sacred balance."
			),

			"earlylife"	= list(
				"Underachiever"		=	"you spent as much time as you could avoiding doing actual work.  You became quite the derball player during your long, hard, grueling days of slacking off and being anything but a value to society.",
				"Abused"			=	"you tried as you may, but could never live up to the expectations of those you were trying to help.  When you failed to do what they wanted you were subject to a variety of different acts of abuse.  You remember days of starvation as punishment for failures that weren’t necessarily your fault.",
				"Orphan"			=	"you took to petty theft and sleeping wherever you could find a dry place away from danger.  Having lost your parents at an early age you had to learn to fend for yourself in a world that seemed to spit you back out at every turn.",
				"Gifted"			=	"your true potential became apparent very quickly.  Tasks were given to you and you could do them without much difficulty.  You could find solutions for problems the other youths couldn’t, and excelled at everything you did. You were looked up to by your peers, and they always said you would do great things.",
				"Spiritual"			=	"you took to learning about the aels.  While the other youths would spend time working and playing, you would steal away to gaze at Aelea, the large ringed body in the sky, or ponder the tales told to you by the old ones."
			),

			"vocation_human" 		=	list(
				"Hunter"			=	"had become quite the hunter.  You scoured the wilderness near your home for food, becoming proficient at setting traps and ambushes to make ends meet.  You quickly mastered the arts of stealth and archery, and your skills as a tracker became invaluable to you.",
				"Soldiery"			=	"took to learning the skills of soldiery.  Through rigorous training you learned the use of sword, axe, shield, and spear, and gained the strength and endurance you needed to perform in battle.  The days were long, and the work was hard, and you learned to take advantage of every chance you had for rest, since you may not have another.",
				"Priest"			=	"devoted your life to the teachings of the Aels.  You stole away to the nearest sanctuary to study under the priests there, and learned to read and write in the common language.  You learned of the entire panthaeleon, and spent your days reading the legends of old and scrawling new knowledge brought to you by messengers from near and far."
			),

			"vocation_orc" 			=	list(
				"Hunter"			=	"had become quite the hunter.  You scoured the wilderness near your home for food, becoming proficient at setting traps and ambushes to make ends meet.  You quickly mastered the arts of stealth and archery, and your skills as a tracker became invaluable to you.",
				"Warrior"			=	"had grown strong and loyal.  Your prowess for battle had quickly been noticed by your chieftain, and he had put your skills to use defending your clan from the many threats that befell it.  You were trained brutally by the clans taskmaster in the use of the battle-axe and spear, and learned to defend yourself with a shield, and to withstand grueling pain when you were struck by an opponent.",
				"Shaman"			=	"devoted your life to the service of Folchak and Orcia under your clan-mother.  Through her guidance you learned to read the signs of nature and determine the will of the Aels from what you saw.  You were looked upon during hunts to see where Orcia wished you to kill, and in times of war to bless the warriors with the strength of Fol'chak."
			)
		)

	/*-------------------
	Le-Logic
	-------------------*/

	New(client/c)
		owner = c
		output_init()
		spawn(1)
			set_race("Human")

	proc
		output_init()
			if(finished) return

			var gender_text		=	{"<p>You are a <span id="gender"></span>&nbsp;<span id="race"></span><span id="gender_desc"></span>&nbsp;<span id="race_info"></span></p>"}
			var heritage_text	=	{"<p><span id="heritage"></span></p>"}
			var family_text		=	{"<p><span id="family_intro"></span><span id="family"></span></p>"}
			var earlylife_text	=	{"<p>You spent your childhood playing with other <span id="racial_baby"></span>, making messes, and causing a general ruckus. When you were old enough to begin helping out, <span id="earlylife"></span></p>"}
			var vocation_text	=	{"<p>Before you knew it, you were a young <span id="gender_man"></span>, and you <span id="vocation_desc"></span></p>"}
			var aeliom_text		=	{"<p><span id="aeliom_intro"></span><span id="aeliom"></span></p>"}
			owner << output(
				{"
				<script type="text/javascript">
					function replace(e, r)
					{
						document.getElementById(e).innerHTML=r;
					}
				</script>

				<center><h1>Your Story</h1></center>
					[gender_text]
					[heritage_text]
					[family_text]
					[aeliom_text]
					[earlylife_text]
					[vocation_text]
				"}, "bro_story")

		element_changed(difference)
			if(finished) return

			winset(owner, "la_[difference]", "text=\"[vars[difference]]\"")

			#define replace(e, r) owner << output({"[url_encode(e)];[url_encode(r)]"}, "bro_story:replace")
			switch(difference)
				if("gender")
					replace("gender", lowertext(gender))
					replace("gender_desc", choices["gender_[lowertext(race)]"][gender])
					var gender_man = "adult"
					switch(gender)
						if("Male")		gender_man = "man"
						if("Female")	gender_man = "woman"
					replace("gender_man", gender_man)

				if("race")
					replace("race", lowertext(race))
					replace("race_info", choices["race"][race])

					var racial_baby = "younglings"
					switch(race)
						if("Human")		racial_baby = "children"
						if("Orc")		racial_baby = "pups"

					replace("racial_baby", racial_baby)

				if("heritage")
					replace("heritage", choices["heritage_[lowertext(race)]"][heritage])

				if("family")
					var desc
					switch(race)
						if("Human")	desc = "The early years of your life were full of stories of your family and how they got to where they were then.  What you remembered most "
						if("Orc")	desc = "The tales of your clan history were told often to you as a child.  Your lineage was recognised most to the rest of the clan as "

					replace("family_intro", desc)
					replace("family", choices["family_[lowertext(race)]"][family])

				if("aeliom")
					var desc
					if(race == "Human")
						desc = "You still recognise and revere the other aelioms, but follow most fervently the teachings of "
					else if(race == "Orc")
						desc = "Although some in your clan see the other as their more favoured ael, you choose to worship "
					replace("aeliom_intro", desc)
					replace("aeliom", choices["aeliom_[lowertext(race)]"][aeliom])

				if("earlylife")
					replace("earlylife", choices["earlylife"][earlylife])

				if("vocation")
					replace("vocation_desc", choices["vocation_[lowertext(race)]"][vocation])
			#undef replace

		change_choice(item, direction)
			if(finished) return

			ASSERT(item in vars)
			ASSERT(direction == 1 || direction == -1)

			var i = item
			var race = lowertext(src.race)
			if(choices["[item]_[race]"])
				i = "[item]_[race]"

			choices[i] = cycled_list(choices[i], direction)
			vars[item] = choices[i][1]

			if(item == "race")
				set_race(vars[item])

			element_changed(item)

		set_race(r)
			if(finished) return

			race = r
			r = lowertext(r)

			gender		=	gender || "Male"
			heritage	=	choices["heritage_[r]"][1]
			family		=	choices["family_[r]"][1]
			aeliom		=	choices["aeliom_[r]"][1]
			vocation	=	choices["vocation_[r]"][1]
			earlylife	=	choices["earlylife"][1]

			for(var/v in list("race","gender","heritage","family","aeliom","vocation","earlylife"))
				element_changed(v)



proc
	cycled_list(l[], direction)
		var copy[] = l.Copy()
		switch(direction)
			if(1)
				var item = copy[1]
				var assoc = copy[item]
				copy -= item
				copy[item] = assoc

			if(-1)
				var item = copy[l.len]
				var assoc = copy[item]
				copy -= item
				copy.Insert(1, item)
				copy[item] = assoc

		return copy
