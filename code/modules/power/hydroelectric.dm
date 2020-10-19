//Hydroelectric power by Sieghardt Meldurson. Please message me in case of issues.
//The Hydro Turbine itself
#define HYDRO_MAX_DIST 100
/obj/machinery/power/hydroelectric
	name = "hydroelectric turbine"
	desc = "A hydroelectric generator able to store water and then release it to generate electricity. This one seems to be integral to the structural integrity around and is attached directly to the dam's frame."
	icon = 'icons/obj/machines/thermoelectric.dmi'
	icon_state = "circ-unassembled"
	density = 1
	anchored = 1
	use_power = NO_POWER_USE
	idle_power_usage = 0
	active_power_usage = 0
	health = 10
	var/malfstate = 0
	var/id = 0
	var/powrate = 10
	var/trickleout = 2
	var/obj/machinery/power/hydroelectric_control/control = null

/obj/machinery/power/hydroelectric/drain_power()
	return -1

/obj/machinery/power/hydroelectric/update_icon()
	cut_overlays()
	if(!control)
		return
	if(malfstate != 0)
		add_overlay(image('icons/obj/machines/thermoelectric.dmi', icon_state = "circ-hot", layer = FLY_LAYER))
	else if (control.working == 1)
		add_overlay(image('icons/obj/machines/thermoelectric.dmi', icon_state = "circ-run", layer = FLY_LAYER))
	return

/obj/machinery/power/hydroelectric/proc/Malfunction()
	malfstate = rand(1,2)
	if(malfstate == 1)
		desc = "A hydroelectric generator able to store water and then release it to generate electricity. This one seems to be integral to the structural integrity around and is attached directly to the dam's frame. There is debris blocking this turbine."
	else
		desc = "A hydroelectric generator able to store water and then release it to generate electricity. This one seems to be integral to the structural integrity around and is attached directly to the dam's frame. The turbine appears to be stalling out."
	control.workingturbines = control.workingturbines - 1
	control.malfturbines = control.malfturbines + 1
	return

/obj/machinery/power/hydroelectric/attackby(obj/item/weapon/I, mob/user)
	var/list/usable_qualities = list(QUALITY_PRYING,QUALITY_PULSING)
	var/tool_type = I.get_tool_type(user, usable_qualities, src)
	if(tool_type == QUALITY_PRYING && malfstate == 1)
		if(I.use_tool(user, src, WORKTIME_NORMAL, tool_type, FAILCHANCE_EASY, required_stat = STAT_MEC))
			malfstate = 0
			desc = "A hydroelectric generator able to store water and then release it to generate electricity. This one seems to be integral to the structural integrity around and is attached directly to the dam's frame."
			user.visible_message("[user] pried the debris from the generator's turbine.", "You pry away the blocking debris and dump trash which was in the way.")
			new /obj/random/scrap/sparse_weighted(get_turf(user))
			control.workingturbines = control.workingturbines + 1
			control.malfturbines = control.malfturbines - 1
			return
	if(tool_type == QUALITY_PULSING && malfstate == 2)
		if(I.use_tool(user, src, WORKTIME_NORMAL, tool_type, FAILCHANCE_NORMAL, required_stat = STAT_MEC))
			malfstate = 0
			desc = "A hydroelectric generator able to store water and then release it to generate electricity. This one seems to be integral to the structural integrity around and is attached directly to the dam's frame."
			user.visible_message("[user] reset the generator's turbine.", "You reset the generator's turbine to its default working state.")
			control.workingturbines = control.workingturbines + 1
			control.malfturbines = control.malfturbines - 1
			return

/obj/machinery/power/hydroelectric/proc/set_control(var/obj/machinery/power/hydroelectric_control/HC)
	if(HC && (get_dist(src, HC) > HYDRO_MAX_DIST))
		return 0
	control = HC
	return 1

/obj/machinery/power/hydroelectric/proc/unset_control()
	if(control)
		control.connected_turbines.Remove(src)
	control = null

/obj/machinery/power/hydroelectric/Process()
	update_icon()
	if(malfstate != 0)
		return
	if(!control)
		return
	if(powernet)
		if(powernet == control.powernet)
			if(control.working == 1)
				if(control.waterheld <= 20)
					control.working = 0
					return
				var/sgen = powrate * 10000
				add_avail(sgen)
				control.gen += sgen
				control.waterheld = control.waterheld - trickleout

		else
			unset_control()

//The Hydro Turbine Controller
/obj/machinery/power/hydroelectric_control
	name = "hydroelectric turbine control"
	desc = "A hydroelectric turbine control console."
	anchored = 1
	density = 1
	use_power = IDLE_POWER_USE
	icon = 'icons/obj/computer.dmi'
	icon_state = "computer"
	idle_power_usage = 250
	var/light_range_on = 1.5
	var/light_power_on = 3
	var/id = 0
	var/waterheld = 0
	var/tricklein = 4
	var/watermax = 10000
	var/gen = 0
	var/lastgen = 0
	var/announced = 0
	var/tidechange = 0
	var/malfnumber = 0
	var/statusreport = "No Turbines Detected"
	var/working = 0
	var/workingturbines = 0
	var/malfturbines = 0
	var/obj/item/device/radio/radio
	var/list/connected_turbines = list()

/obj/machinery/power/hydroelectric_control/drain_power()
	return -1

/obj/machinery/power/hydroelectric_control/Initialize()
	. = ..()
	radio = new /obj/item/device/radio{channels=list("Engineering")}(src)
	assign_uid()

/obj/machinery/power/hydroelectric_control/Destroy()
	qdel(radio)
	. = ..()

/obj/machinery/power/hydroelectric_control/proc/search_for_connected()
	if(powernet)
		for(var/obj/machinery/power/M in powernet.nodes)
			if(istype(M, /obj/machinery/power/hydroelectric))
				var/obj/machinery/power/hydroelectric/S = M
				if(!S.control)
					S.set_control(src)
					connected_turbines |= S
					if(S.malfstate == 0)
						workingturbines = workingturbines + 1
					else
						malfturbines = malfturbines + 1

/obj/machinery/power/hydroelectric_control/update_icon()
	if(stat & BROKEN)
		icon_state = "broken"
		cut_overlays()
		return
	if(stat & NOPOWER)
		icon_state = "c_unpowered"
		cut_overlays()
		return
	icon_state = "computer"
	cut_overlays()
	add_overlay(image('icons/obj/computer.dmi', "solar_screen"))
	return

/obj/machinery/power/hydroelectric_control/Process()
	if(stat & BROKEN)
		return
	lastgen = gen
	gen = 0
	statusreport = "There are [workingturbines] turbines in a functional state and [malfturbines] malfunctioning."
	if(working == 0 && waterheld < 10000)
		tidechange = tidechange + 1
		announced = 0
		waterheld = waterheld + tricklein
		waterheld = CLAMP(waterheld, 0, 10000)
		if(tidechange == 100)
			tricklein = rand(4,9)
			if(malfnumber > rand(1,100))
				var/malftrigger = rand(1,workingturbines)
				connected_turbines[malftrigger].Malfunction()
				malfnumber = 0
		return

	if(waterheld >= 10000 && announced == 0)
		radio.autosay("The Hydroelectric Generator holding basin is now at maximum capacity.", "Hydroelectric Sensor", "Engineering")
		announced = 1

/obj/machinery/power/hydroelectric_control/power_change()
	..()
	update_icon()

/obj/machinery/power/hydroelectric_control/ui_interact(mob/user, ui_key = "hydroelectric", datum/nanoui/ui=null, force_open=NANOUI_FOCUS, var/datum/topic_state/state = GLOB.default_state)

	if(stat & BROKEN)
		return

	if(!user)
		return

	//UI data
	var/data[0]
	data["waterheld"] = round(100.0*waterheld/watermax, 0.1)
	data["hydrostatus"] = statusreport
	data["isOpen"] = working
	data["generated"] = lastgen

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "hydroelectric.tmpl", "Hydroelectric Control Panel", 540, 380)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()
		// auto update every Master Controller tick
		ui.set_auto_update(1)

/obj/machinery/power/hydroelectric_control/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["togglegate"])
		togglegate()

	if(href_list["detectturbines"])
		src.search_for_connected()

/obj/machinery/power/hydroelectric_control/proc/togglegate()
	working = !working
	malfnumber = malfnumber + 1

/obj/machinery/power/hydroelectric_control/attack_hand(mob/user)
	ui_interact(user)

/obj/item/weapon/paper/hydroworking
	name = "paper- 'Working the Hydroelectric Generator.'"
	info = "<h1>Hey there.</h1><p>We've installed a whole new way of making power, namely a hydroelectirc generator and it's as easy as they get to work with. \
	First thing first, click that button to detect the turbines, there should be ten of them. From that point onward it will be a waiting game. \
	The holding basin is pretty massive and the flowing power of the river can vary, so it may take a while for it to fill up. \
	You'll get a nifty notice over the radio communication channel once it's full. That would be the best time to open up the flood gates and start the turbines. \
	Water will start flowing and power will start being generated. Once it empties out it'll start filling back up on its own. \
	In the very rare case of a malfunction you'll have to suit up and head out to see what's wrong. You may have to use a multitool to \
	fix a stalled out engine or crowbar out some debris that gets stuck in. They'll have a red warning glow if malfunctioning. Good luck. -Sieghardt Meldurson.</p>"