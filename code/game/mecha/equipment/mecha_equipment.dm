//TODO: Add critfail checks and reliability
//DO NOT ADD MECHA PARTS TO THE GAME WITH THE DEFAULT "SPRITE ME" SPRITE!
//I'm annoyed I even have to tell you this! SPRITE FIRST, then commit.

/obj/item/mecha_parts/mecha_equipment
	name = "mecha equipment"
	icon = 'icons/mecha/mecha_equipment.dmi'
	icon_state = "mecha_equip"
	force = 5
	origin_tech = Tc_MATERIALS + "=2"
	var/equip_cooldown = 0
	var/equip_ready = 1
	var/energy_drain = 0
	var/obj/mecha/chassis = null
	var/range = MELEE //bitflags
	reliability = 1000
	var/salvageable = 1
	var/is_activateable = TRUE
	var/spell/mech/linked_spell //Default action is to make the make it the active equipment


/obj/item/mecha_parts/mecha_equipment/proc/do_after_cooldown(target=1, delay_mult=1)
	sleep(equip_cooldown * delay_mult)
	set_ready_state(1)
	if(target && chassis)
		return 1
	return 0


/obj/item/mecha_parts/mecha_equipment/New()
	..()
	if(istype(loc,/obj/mecha))
		attach(loc)
	return

/obj/item/mecha_parts/mecha_equipment/proc/update_chassis_page()
	if(chassis)
		send_byjax(chassis.occupant,"exosuit.browser","eq_list",chassis.get_equipment_list())
		send_byjax(chassis.occupant,"exosuit.browser","equipment_menu",chassis.get_equipment_menu(),"dropdowns")
		return 1
	return

/obj/item/mecha_parts/mecha_equipment/proc/update_equip_info()
	if(chassis)
		send_byjax(chassis.occupant,"exosuit.browser","\ref[src]",get_equip_info())
		return 1
	return

/obj/item/mecha_parts/mecha_equipment/Destroy()//missiles detonating, teleporter creating singularity?
	if(chassis)
		chassis.equipment -= src
		listclearnulls(chassis.equipment)
		if(chassis.selected == src)
			chassis.selected = null
		src.update_chassis_page()
		chassis.occupant_message("<span class='red'>\The [src] is destroyed!</span>")
		chassis.log_append_to_last("[src] is destroyed.",1)
		QDEL_NULL(linked_spell)
		chassis.refresh_spells()
		if(istype(src, /obj/item/mecha_parts/mecha_equipment/weapon))
			chassis.occupant << sound('sound/mecha/weapdestr.ogg',volume=50)
		else
			chassis.occupant << sound('sound/mecha/critdestr.ogg',volume=50)
	..()

/obj/item/mecha_parts/mecha_equipment/proc/critfail()
	if(chassis)
		log_message("Critical failure",1)
	return

/obj/item/mecha_parts/mecha_equipment/proc/get_equip_info()
	if(!chassis)
		return
	return "<span style=\"color:[equip_ready?"#0f0":"#f00"];\">*</span>&nbsp;[chassis.selected==src?"<b>":"<a href='?src=\ref[chassis];select_equip=\ref[src]'>"][src.name][chassis.selected==src?"</b>":"</a>"]"

/obj/item/mecha_parts/mecha_equipment/proc/is_ranged()//add a distance restricted equipment. Why not?
	return (range&RANGED)

/obj/item/mecha_parts/mecha_equipment/proc/is_melee()
	return (range&MELEE)

/obj/item/mecha_parts/mecha_equipment/proc/action_checks(atom/target)
	if(!target)
		return 0
	if(!chassis)
		return 0
	if(!equip_ready)
		return 0
	if(crit_fail)
		return 0
	if(energy_drain && !chassis.has_charge(energy_drain))
		return 0
	return 1

/obj/item/mecha_parts/mecha_equipment/proc/action(atom/target)
	return

/obj/item/mecha_parts/mecha_equipment/proc/can_attach(obj/mecha/M as obj)
	if(istype(M))
		if(M.equipment.len<M.max_equip)
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/proc/attach(obj/mecha/M as obj)
	M.equipment += src
	chassis = M
	src.forceMove(M)
	M.log_message("[src] initialized.")
	if(!M.selected)
		M.selected = src
	src.update_chassis_page()
	if(is_activateable)
		linked_spell = new /spell/mech(M, src)
	M.refresh_spells()
	return

/obj/item/mecha_parts/mecha_equipment/proc/detach(atom/moveto=null)
	if(!moveto)
		moveto = get_turf(chassis)
	src.forceMove(moveto)
	chassis.equipment -= src
	if(chassis.selected == src)
		chassis.selected = null
	update_chassis_page()
	chassis.log_message("[src] removed from equipment.")
	QDEL_NULL(linked_spell)
	chassis.refresh_spells()
	chassis = null
	set_ready_state(1)
	return


/obj/item/mecha_parts/mecha_equipment/Topic(href,href_list)
	if(usr.incapacitated() || usr != chassis.occupant)
		return TRUE
//	testing("[src] topic")
	if(href_list["detach"])
		detach()
	return


/obj/item/mecha_parts/mecha_equipment/proc/set_ready_state(state)
	equip_ready = state
	if(chassis)
		send_byjax(chassis.occupant,"exosuit.browser","\ref[src]",src.get_equip_info())
	return

/obj/item/mecha_parts/mecha_equipment/proc/occupant_message(var/message, var/prevent_spam = FALSE)
	if(chassis)
		chassis.occupant_message("[bicon(src)] [message]", prevent_spam)

/obj/item/mecha_parts/mecha_equipment/proc/log_message(message)
	if(chassis)
		chassis.log_message("<i>[src]:</i> [message]")
	return

/obj/item/mecha_parts/mecha_equipment/proc/on_mech_step()
	return

/obj/item/mecha_parts/mecha_equipment/proc/on_mech_turn()
	return

/obj/item/mecha_parts/mecha_equipment/proc/activate()
	chassis.equip_module(src)

/obj/item/mecha_parts/mecha_equipment/proc/alt_action()
	return

/obj/item/mecha_parts/mecha_equipment/emp_act(severity)
	return
