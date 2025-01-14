/obj/structure/cult_legacy
	icon = 'icons/obj/cult.dmi'
	density = TRUE
	anchored = TRUE

/obj/structure/cult_legacy/cultify()
	return
/obj/structure/cult_legacy/clockworkify()
	return

/obj/structure/cult_legacy/talisman
	name = "Altar"
	desc = "A bloodstained altar dedicated to Nar-Sie."
	icon_state = "talismanaltar"

/obj/structure/cult_legacy/forge
	name = "Daemon forge"
	desc = "A forge used in crafting the unholy weapons used by the armies of Nar-Sie."
	icon_state = "forge"

/obj/structure/cult_legacy/tome
	name = "Desk"
	desc = "A desk covered in arcane manuscripts and tomes in unknown languages. Looking at the text makes your skin crawl."
	icon_state = "tomealtar"
	light_range = 2
	light_color = LIGHT_COLOR_RED

/obj/structure/cult_legacy/tome/attackby(obj/item/weapon/W as obj, mob/user as mob)
	user.drop_item(W, src.loc)
	return 1

//sprites for this no longer exist	-Pete
//(they were stolen from another game anyway)
/*
/obj/structure/cult_legacy/pillar
	name = "Pillar"
	desc = "This should not exist."
	icon_state = "pillar"
	icon = 'magic_pillar.dmi'
*/

/obj/effect/gateway
	name = "gateway"
	desc = "You're pretty sure that abyss is staring back."
	icon = 'icons/obj/cult.dmi'
	icon_state = "hole"
	anchored = 1.0
	plane = ABOVE_TURF_PLANE
	var/spawnable = null

/obj/effect/gateway/active
	luminosity=5
	light_color = LIGHT_COLOR_RED
	spawnable=list(
		/mob/living/simple_animal/hostile/scarybat,
		/mob/living/simple_animal/hostile/creature,
		/mob/living/simple_animal/hostile/faithless
	)

/obj/effect/gateway/active/cult
	luminosity=5
	light_color = LIGHT_COLOR_RED
	spawnable=list(
		/mob/living/simple_animal/hostile/scarybat/cult,
		/mob/living/simple_animal/hostile/creature/cult,
		/mob/living/simple_animal/hostile/faithless/cult,
		/obj/abstract/meatblob_spawner
	)

/obj/effect/gateway/active/cult/cultify()
	return

/obj/effect/gateway/active/New()
	flick("hole-appear", src)
	set_light(3)
	spawn(rand(30,60) SECONDS)
		var/t = pick(spawnable)
		new t(src.loc)
		flick("hole-die",src)
		spawn(6)
			qdel(src)

/*
/obj/effect/gateway/active/Crossed(var/atom/A)
	if(!istype(A, /mob/living))
		return

	var/mob/living/M = A

	if(M.stat != DEAD)
		if(M.monkeyizing)
			return


		if(islegacycultist(M))
			return
		if(!ishuman(M) && !isrobot(M))
			return

		M.monkeyizing = 1
		M.canmove = 0
		M.icon = null
		M.overlays.len = 0
		M.invisibility = 101

		if(iscarbon(M))
			var/mob/living/carbon/I = M
			I.dropBorers()//drop because new mob is simple_animal

		if(istype(M, /mob/living/silicon/robot))
			var/mob/living/silicon/robot/Robot = M
			if(Robot.mmi)
				QDEL_NULL(Robot.mmi)
		else
			for(var/obj/item/W in M)
				if(istype(W, /obj/item/weapon/implant))	//TODO: Carn. give implants a dropped() or something
					qdel(W)
					continue
				W.layer = initial(W.layer)
				W.forceMove(M.loc)
				W.dropped(M)

		var/mob/living/new_mob = new /mob/living/simple_animal/hostile/retaliate/cluwne(A.loc)
		new_mob.setGender(gender)
		new_mob.name = pick(clown_names)
		new_mob.real_name = new_mob.name
		new_mob.mutations += M_CLUMSY
		new_mob.mutations += M_FAT
		new_mob.setBrainLoss(100)


		new_mob.a_intent = I_HURT
		if(M.mind)
			M.mind.transfer_to(new_mob)
		else
			new_mob.key = M.key

		to_chat(new_mob, "<B>Your form morphs into that of a cluwne.</B>")
*/
