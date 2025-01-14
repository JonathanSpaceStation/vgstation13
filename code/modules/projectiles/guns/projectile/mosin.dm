/obj/item/weapon/gun/projectile/mosin
	name = "mosin nagant"
	desc = "JOY OF HAVING MOSIN NAGANT RIFLE IS JOY THAT MONEY CANNOT AFFORD. "
	fire_sound = 'sound/weapons/mosin.ogg'
	icon = 'icons/obj/biggun.dmi'
	icon_state = "mosinlarge"
	item_state = null
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	max_shells = 5
	w_class = W_CLASS_LARGE
	force = 10
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BACK
	caliber = list(POINT762X55 = 1)
	origin_tech = Tc_COMBAT + "=4;" + Tc_MATERIALS + "=2"
	ammo_type ="/obj/item/ammo_casing/a762x55"
	var/recentpump = 0 // to prevent spammage
	var/pumped = 0
	var/obj/item/ammo_casing/current_shell = null
	recoil = 4

	gun_flags = 0

/obj/item/weapon/gun/projectile/mosin/isHandgun()
	return FALSE

/obj/item/weapon/gun/projectile/mosin/attack_self(mob/living/user as mob)
	if(recentpump)
		return
	pump(user)
	recentpump = 1
	spawn(10)
		recentpump = 0
	return

/obj/item/weapon/gun/projectile/mosin/process_chambered()
	if(in_chamber)
		return 1
	else if(current_shell && current_shell.BB)
		in_chamber = current_shell.BB //Load projectile into chamber.
		current_shell.BB.forceMove(src) //Set projectile loc to gun.
		current_shell.BB = null
		current_shell.update_icon()
		return 1
	return 0

/obj/item/weapon/gun/projectile/mosin/proc/pump(mob/M as mob)
	playsound(M, 'sound/weapons/mosinreload.ogg', 100, 1)
	pumped = 0
	if(current_shell)//We have a shell in the chamber
		current_shell.forceMove(get_turf(src))//Eject casing
		current_shell = null
		if(in_chamber)
			in_chamber = null
	if(!getAmmo())
		return 0
	var/obj/item/ammo_casing/AC = loaded[1] //load next casing.
	loaded -= AC //Remove casing from loaded list.
	current_shell = AC
	update_icon()	//I.E. fix the desc
	return 1

/obj/item/weapon/gun/projectile/mosin/attackby(var/obj/item/A as obj, mob/living/user as mob)
	..()
	if(istype(src, /obj/item/weapon/gun/projectile/mosin/obrez))
		return
	if(istype(A, /obj/item/tool/circular_saw) || istype(A, /obj/item/weapon/melee/energy) || istype(A, /obj/item/weapon/pickaxe/plasmacutter))
		to_chat(user, "<span class='notice'>You begin to shorten the barrel of \the [src].</span>")
		if(getAmmo())
			user.visible_message("<span class='danger'>Take the ammo out first.</span>", "<span class='danger'>You need to take the ammo out first.</span>")
			return
		if(do_after(user, src, 30))
			var/obj/item/weapon/gun/projectile/mosin/obrez/newObrez = new /obj/item/weapon/gun/projectile/mosin/obrez(get_turf(src))
			for(var/obj/item/ammo_casing/AC in newObrez.loaded)
				newObrez.loaded -= AC
			qdel(src)
			to_chat(user, "<span class='warning'>You shorten the barrel of \the [src]!</span>")
	return

/obj/item/weapon/gun/projectile/mosin/obrez
	name = "obrez"
	desc = "WHEN YOU SHOW OBREZ TO ENEMY, HE THINKS YOU ARE CRAZED LUNATIC, LIKE KRUSCHEV POUNDING SHOE ON DESK AND SHOUTING ANGRY PLAN TO BURY NATO IN DEEP GRAVE. YOU FIRE WITH FLAME BURSTING LIKE FIRE OF DRAGON, TWISTING BOLT LIKE MANIAC BETWEEN FIRINGS AND EJECTING EMPTY CASE AS BIG AS BEER CAN FROM ACTION."
	fire_sound = 'sound/weapons/obrez.ogg'
	icon = 'icons/obj/biggun.dmi'
	icon_state = "obrezlarge"
	item_state = null
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	w_class = W_CLASS_MEDIUM
	slot_flags = SLOT_BELT

/obj/item/weapon/gun/projectile/mosin/obrez/isHandgun()
	return TRUE //WHY NOT

/obj/item/weapon/gun/projectile/mosin/obrez/Fire(atom/target, mob/living/user, params, reflex = 0, struggle = 0, var/use_shooter_turf = FALSE)
	if(current_shell && current_shell.BB)
		//explosion(src.loc,-1,1,2)
		spark(user, 3, FALSE)

		var/turf/target_turf = get_turf(target)
		if(target_turf)
			var/turflist = getline(user, target)
			flame_turf(turflist)

		if(prob(15))
			if(user.drop_item(src))
				to_chat(user, "<span class='danger'>\The [src] flies out of your hands.</span>")
				user.take_organ_damage(0,10)
			else
				to_chat(user, "<span class='notice'>\The [src] almost flies out of your hands!</span>")
	..()

/obj/item/weapon/gun/projectile/mosin/obrez/proc/flame_turf(turflist)
	var/turf/T = turflist[2]
	var/turf/previousturf

	if(length(turflist)>1)
		previousturf = get_turf(src)
	if(previousturf && LinkBlocked(previousturf, T))
		return
	if(!T.density && !istype(T, /turf/space))
		new /obj/effect/fire(T) //add some fire as an effect because low intensity liquid fuel looks weak
		new /obj/effect/decal/cleanable/liquid_fuel(T, 0.1, get_dir(T.loc, T)) //spawn some fuel at the tur)
		T.hotspot_expose(500,MEDIUM_FLAME,1) //light it on fire
		previousturf = null

	for(var/mob/M in viewers(1, loc))
		if((M.client && M.machine == src))
			attack_self(M)
	return
