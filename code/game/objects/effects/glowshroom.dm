//separate dm since hydro is getting bloated already

/obj/effect/glowshroom
	name = "glowshroom"
	anchored = 1
	opacity = 0
	density = 0
	icon = 'icons/obj/lighting.dmi'
	icon_state = "glowshroomf"
	layer = BELOW_TABLE_LAYER
	mouse_opacity = 1
	var/endurance = 30
	var/potency = 30
	var/delay = 1200
	var/floor = 0
	var/yield = 3
	var/spreadChance = 40
	var/spreadIntoAdjacentChance = 60
	var/evolveChance = 2
	w_type=NOT_RECYCLABLE

/obj/effect/glowshroom/single
	spreadChance = 0

/obj/effect/glowshroom/New()
	..()
	dir = CalcDir()

	if(!floor)
		switch(dir) //offset to make it be on the wall rather than on the floor
			if(NORTH)
				pixel_y = WORLD_ICON_SIZE
			if(SOUTH)
				pixel_y = -WORLD_ICON_SIZE
			if(EAST)
				pixel_x = WORLD_ICON_SIZE
			if(WEST)
				pixel_x = -WORLD_ICON_SIZE
		icon_state = "glowshroom[rand(1,3)]"
	else //if on the floor, glowshroom on-floor sprite
		icon_state = "glowshroomf"

	spawn(0)//make sure the potency from the shroom that made us has transferred first
		set_light(round(potency/10))

	/*spawn(delay)
		Spread() - Methinks this is broken - N3X*/

/obj/effect/glowshroom/proc/Spread()
	//set background = 1
	var/spreaded = 1

	while(spreaded)
		spreaded = 0

		for(var/i=1,i<=yield,i++)
			if(prob(spreadChance))
				var/list/possibleLocs = list()
				var/spreadsIntoAdjacent = 0

				if(prob(spreadIntoAdjacentChance))
					spreadsIntoAdjacent = 1

				for(var/turf/unsimulated/floor/asteroid/earth in view(3,src))
					if(spreadsIntoAdjacent || !locate(/obj/effect/glowshroom) in view(1,earth))
						possibleLocs += earth

				if(!possibleLocs.len)
					break

				var/turf/newLoc = pick(possibleLocs)

				var/shroomCount = 0 //hacky
				var/placeCount = 1
				for(var/obj/effect/glowshroom/shroom in newLoc)
					shroomCount++
				for(var/wallDir in cardinal)
					var/turf/isWall = get_step(newLoc,wallDir)
					if(isWall.density)
						placeCount++
				if(shroomCount >= placeCount)
					continue

				var/obj/effect/glowshroom/child = new /obj/effect/glowshroom(newLoc)
				child.potency = potency
				child.yield = yield
				child.delay = delay
				child.endurance = endurance
				child.light_color = light_color

				spreaded++

		if(prob(evolveChance)) //very low chance to evolve on its own
			potency += rand(4,6)

		sleep(delay)

/obj/effect/glowshroom/proc/CalcDir(turf/location = loc)
	//set background = 1
	var/direction = 16

	for(var/wallDir in cardinal)
		var/turf/newTurf = get_step(location,wallDir)
		if(newTurf.density)
			direction |= wallDir

	for(var/obj/effect/glowshroom/shroom in location)
		if(shroom == src)
			continue
		if(shroom.floor) //special
			direction &= ~16
		else
			direction &= ~shroom.dir

	var/list/dirList = list()

	for(var/i=1,i<=16,i <<= 1)
		if(direction & i)
			dirList += i

	if(dirList.len)
		var/newDir = pick(dirList)
		if(newDir == 16)
			floor = 1
			newDir = 1
		return newDir

	floor = 1
	return 1

/obj/effect/glowshroom/attackby(var/obj/item/weapon/W, var/mob/user)
	if (istype(W))
		if(user.a_intent == I_HELP || W.force == 0)
			visible_message("<span class='warning'>\The [user] gently taps \the [src] with \the [W].</span>")
		else
			user.delayNextAttack(8)
			user.do_attack_animation(src, W)
			playsound(loc, 'sound/weapons/hivehand_empty.ogg', 50, 1)
			if (W.attack_verb)
				visible_message("<span class='warning'>\The [user] [pick(W.attack_verb)] \the [src] with \the [W].</span>")
			else
				visible_message("<span class='warning'>\The [user] hits \the [src] with \the [W].</span>")
			endurance -= W.force
			CheckEndurance()
			return
	..()

/obj/effect/glowshroom/attack_paw(var/mob/living/carbon/monkey/user)
	user.delayNextAttack(8)
	user.do_attack_animation(src, user)
	playsound(loc, 'sound/weapons/hivehand_empty.ogg', 50, 1)
	user.visible_message("<span class='danger'>[user.name] [user.attack_text] \the [src]!</span>", \
						"<span class='danger'>You strike at \the [src]!</span>")
	endurance -= user.get_unarmed_damage(src)
	CheckEndurance()

/obj/effect/glowshroom/attack_animal(var/mob/living/simple_animal/user)
	if(user.melee_damage_upper == 0)
		return
	user.delayNextAttack(8)
	user.do_attack_animation(src, user)
	playsound(loc, 'sound/weapons/hivehand_empty.ogg', 50, 1)
	user.visible_message("<span class='danger'>[user.name] [user.attacktext] \the [src]!</span>", \
						"<span class='danger'>You strike at \the [src]!</span>")
	endurance -= user.melee_damage_upper
	CheckEndurance()

/obj/effect/glowshroom/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				qdel(src)
				return
		if(3.0)
			if (prob(5))
				qdel(src)
				return
		else
	return

/obj/effect/glowshroom/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		endurance -= 5
		CheckEndurance()

/obj/effect/glowshroom/proc/CheckEndurance()
	if(endurance <= 0)
		qdel(src)
