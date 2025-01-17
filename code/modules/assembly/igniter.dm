/obj/item/device/assembly/igniter
	name = "igniter"
	desc = "A small electronic device able to ignite combustable substances."
	icon_state = "igniter"
	starting_materials = list(MAT_IRON = 500, MAT_GLASS = 50)
	w_type = RECYK_ELECTRONIC
	origin_tech = Tc_MAGNETS + "=1"

	secured = 1
	wires = WIRE_RECEIVE

/obj/item/device/assembly/igniter/activate()
	if(!..())
		return 0//Cooldown check

	if(holder && istype(holder.loc,/obj/item/weapon/grenade/chem_grenade))
		var/obj/item/weapon/grenade/chem_grenade/grenade = holder.loc
		grenade.prime()
	else
		var/turf/location = get_turf(loc)
		if(location)
			var/surf = isturf(loc)?TRUE:FALSE
			location.hotspot_expose(1000,LARGE_FLAME,surf)

		spark(src)

		if (istype(src.loc,/obj/item/device/assembly_holder))
			if (istype(src.loc.loc, /obj/structure/reagent_dispensers/))
				var/obj/structure/reagent_dispensers/tank = src.loc.loc
				if (tank && tank.modded)
					tank.explode()

		return 1


/obj/item/device/assembly/igniter/attack_self(mob/user as mob)
	activate()
	add_fingerprint(user)
	return
