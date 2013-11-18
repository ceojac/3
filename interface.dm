client

	var
		menu_open
	verb
		close_menu_child()
			close_menu()

		open_menu_main()
			winset(src,,"menu_child.left=main_menu;\
						 menu_child.is-visible=true")
			menu_open = 1

		exit_setting()
			if(istype(mob.loc,/settlement/))
				mob.loc = mob.loc.loc
			close_menu()


	proc
		enter_setting(client/c, setting/s)
			if(!s) CRASH("error 201: no setting")
			winset(src,,{"	menu_child.left=setting;
						 	menu_child.is-visible=true;
						 	setting_info.text='[s.info]';
						 	setting_name.text='[s.name]'"})
			menu_open = 1

		close_menu()
			winset(src, "menu_child","is-visible=false")
			menu_open = 0