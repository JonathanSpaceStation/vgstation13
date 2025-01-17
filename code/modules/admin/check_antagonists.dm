/datum/admins/proc/check_antagonists()
	if (!ticker || ticker.current_state < GAME_STATE_PLAYING)
		alert("The game hasn't started yet!")
		return

	var/dat = "<html><head><title>Round Status</title></head><body><h2>Round Status</h2>"

	dat += {"Current Game Mode: <B>[ticker.mode.name]</B><BR>
		Shift duration: <B>[getShiftDuration()]</B><BR>
		<A HREF='?src=\ref[src];emergency_shuttle_panel=1'><B>Emergency Shuttle Panel</B></A><BR>"}

	dat += "<a href='?src=\ref[src];delay_round_end=1'>[ticker.delay_end ? "End Round Normally" : "Delay Round End"]</a><br>"

	dat += ticker.mode.AdminPanelEntry()

	dat += "<h3><b>Factions</b></h3>"
	if(ticker.mode.factions.len)
		for(var/datum/faction/F in ticker.mode.factions)
			dat += F.AdminPanelEntry(src)
	else
		dat += "<i>No factions are currently active.</i>"
	dat += "<h3>Other Roles</h3>"
	if(ticker.mode.orphaned_roles.len)
		for(var/datum/role/R in ticker.mode.orphaned_roles)
			dat += R.AdminPanelEntry(TRUE,src)//show logos
			dat += "<br>"
	else
		dat += "<i>No orphaned roles are currently active.</i>"

	var/datum/gamemode/dynamic/dynamic_mode = ticker.mode
	if (istype(dynamic_mode))
		dat += "<h3><b>Previously executed rulesets:</b></h3>"
		for (var/previous_round in dynamic_mode.previously_executed_rules)
			switch(previous_round)
				if ("one_round_ago")
					dat += "<h4><b>Last Round:</b></h4>"
				if ("two_rounds_ago")
					dat += "<h4><b>Two Rounds ago:</b></h4>"
				if ("three_rounds_ago")
					dat += "<h4><b>Three Rounds ago:</b></h4>"
			for(var/previous_ruleset in dynamic_mode.previously_executed_rules[previous_round])
				var/datum/dynamic_ruleset/DR = previous_ruleset
				dat += "- [initial(DR.name)] <br/>"
			dat += "<br/>"

	dat += "</body></html>"
	usr << browse(dat, "window=roundstatus;size=700x500")
