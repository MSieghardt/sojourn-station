/*
 *	Everything derived from the common cardboard box.
 *	Basically everything except the original is a kit (starts full).
 *
 *	Contains:
 *		Empty box, starter boxes (survival/engineer),
 *		Latex glove and sterile mask boxes,
 *		Syringe, beaker, dna injector boxes,
 *		Blanks, flashbangs, and EMP grenade boxes,
 *		Tracking and chemical implant boxes,
 *		Prescription glasses and drinking glass boxes,
 *		Condiment bottle and silly cup boxes,
 *		Donkpocket and monkeycube boxes,
 *		ID and security PDA cart boxes,
 *		Handcuff, mousetrap, and pillbottle boxes,
 *		Snap-pops and matchboxes,
 *		Replacement light boxes,
 *		Blackshield uniform boxes.
 *
 *		For syndicate call-ins see uplink_kits.dm
 */

/obj/item/weapon/storage/box
	name = "box"
	desc = "It's just an ordinary box."
	icon = 'icons/obj/storage/boxes.dmi'
	icon_state = "box"
	item_state = "box"
	max_w_class = ITEM_SIZE_SMALL
	max_storage_space = DEFAULT_SMALL_STORAGE + 1
	var/foldable = /obj/item/stack/material/cardboard	//If set, can be folded (when empty) into the set object.
	var/illustration = "writing"
	contained_sprite = TRUE
	health = 20

/obj/item/weapon/storage/box/Initialize(mapload)
	. = ..()
	update_icon()

/obj/item/weapon/storage/box/update_icon()
	. = ..()
	if(illustration)
		cut_overlays()
		add_overlay(illustration)

/obj/item/weapon/storage/box/proc/damage(var/severity)
	health -= severity
	check_health()

/obj/item/weapon/storage/box/proc/check_health()
	if (health <= 0)
		spill()
		qdel(src)

/obj/item/weapon/storage/box/attack_generic(var/mob/user)
	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN*2)
	if (istype(user, /mob/living))
		var/mob/living/L = user
		var/damage = L.mob_size ? L.mob_size : MOB_MINISCULE

		if (!damage || damage <= 0)
			return

		user.do_attack_animation(src)

		var/toplay = pick(list('sound/effects/creatures/nibble1.ogg','sound/effects/creatures/nibble2.ogg'))
		playsound(loc, toplay, 50, 1, 2)
		shake_animation()
		spawn(5)
			if ((health-damage) <= 0)
				L.visible_message("<span class='danger'>[L] tears open \the [src], spilling its contents everywhere!</span>", "<span class='danger'>You tear open the [src], spilling its contents everywhere!</span>")
			damage(damage)
		..()

/obj/item/weapon/storage/box/attack_self(mob/user)
	if(..()) return

	//try to fold it.
	if(contents.len)
		to_chat(user, "<span class='warning'>You can't fold this box with items still inside!</span>")
		return

	if(!ispath(src.foldable))
		return

	// Close any open UI windows first
	close_all()

	// Now make the cardboard
	to_chat(user, SPAN_NOTICE("You fold [src] flat."))
	new src.foldable(get_turf(src))
	qdel(src)

/obj/item/weapon/storage/box/survival/populate_contents()
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/weapon/tank/emergency_oxygen(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector(src)
	new /obj/item/weapon/reagent_containers/food/snacks/mre(src)

/obj/item/weapon/storage/box/survival/extended/populate_contents()
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/weapon/tank/emergency_oxygen/engi(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector(src)
	new /obj/item/weapon/reagent_containers/food/snacks/mre(src)
	new /obj/item/device/lighting/glowstick/yellow(src)

/obj/item/weapon/storage/box/gloves
	name = "box of latex gloves"
	desc = "Contains white gloves."
	illustration = "latex"

/obj/item/weapon/storage/box/gloves/populate_contents()
	for(var/i in 1 to 7)
		new /obj/item/clothing/gloves/latex(src)

/obj/item/weapon/storage/box/masks
	name = "box of sterile masks"
	desc = "This box contains masks of sterility."
	illustration = "sterile"

/obj/item/weapon/storage/box/masks/populate_contents()
	for(var/i in 1 to 7)
		new /obj/item/clothing/mask/surgical(src)

/obj/item/weapon/storage/box/syringes
	name = "box of syringes"
	desc = "A box full of syringes."
	illustration = "syringe"
	use_to_pickup = TRUE // So we can pick up syringes quickly

/obj/item/weapon/storage/box/syringes/empty/populate_contents()
	return

/obj/item/weapon/storage/box/syringes/populate_contents()
	for(var/i in 1 to 7)
		new /obj/item/weapon/reagent_containers/syringe(src)

/obj/item/weapon/storage/box/syringegun
	name = "box of syringe gun cartridges"
	desc = "A box full of compressed gas cartridges."
	illustration = "syringe"

/obj/item/weapon/storage/box/syringegun/populate_contents()
	for(var/i in 1 to 7)
		new /obj/item/weapon/syringe_cartridge(src)

/obj/item/weapon/storage/box/beakers
	name = "box of beakers"
	illustration = "beaker"

/obj/item/weapon/storage/box/beakers/populate_contents()
	for(var/i in 1 to 7)
		new /obj/item/weapon/reagent_containers/glass/beaker(src)

/obj/item/weapon/storage/box/bottles
	name = "box of bottles"
	illustration = "beaker"

/obj/item/weapon/storage/box/bottles/populate_contents()
	for(var/i in 1 to 7)
		new /obj/item/weapon/reagent_containers/glass/bottle(src)

/obj/item/weapon/storage/box/bodybags
	name = "body bags"
	desc = "This box contains a number of body bags."
	illustration = "bodybags"

/obj/item/weapon/storage/box/bodybags/empty/populate_contents()
	return

/obj/item/weapon/storage/box/bodybags/populate_contents()
	for(var/i in 1 to 7)
		new /obj/item/bodybag(src)

/obj/item/weapon/storage/box/injectors
	name = "box of DNA injectors"
	desc = "This box contains injectors it seems."

/obj/item/weapon/storage/box/injectors/populate_contents()
	new /obj/item/weapon/dnainjector/h2m(src)
	new /obj/item/weapon/dnainjector/h2m(src)
	new /obj/item/weapon/dnainjector/h2m(src)
	new /obj/item/weapon/dnainjector/m2h(src)
	new /obj/item/weapon/dnainjector/m2h(src)
	new /obj/item/weapon/dnainjector/m2h(src)

/obj/item/weapon/storage/box/flashbangs
	name = "box of flashbangs"
	desc = "A box containing seven antipersonnel flashbang grenades.<br> WARNING: These devices are extremely dangerous and can cause blindness or deafness in repeated use."
	icon_state = "box_security"
	illustration = "flashbang"

/obj/item/weapon/storage/box/flashbangs/populate_contents()
	for(var/i in 1 to 7)
		new /obj/item/weapon/grenade/flashbang(src)

/obj/item/weapon/storage/box/teargas
	name = "box of pepper spray grenades"
	desc = "A box containing six tear gas grenades. A gas mask is printed on the label.<br> WARNING: Exposure carries risk of serious injury or death. Keep away from persons with lung conditions."
	icon_state = "box_security"
	illustration = "gas"

/obj/item/weapon/storage/box/teargas/populate_contents()
	for(var/i in 1 to 6)
		new /obj/item/weapon/grenade/chem_grenade/teargas(src)

/obj/item/weapon/storage/box/emps
	name = "box of EMP grenades"
	desc = "A box containing five military grade EMP grenades.<br> WARNING: Do not use near unshielded electronics or biomechanical augmentations, death or permanent paralysis may occur."
	icon_state = "box_security"
	illustration = "flashbang"

/obj/item/weapon/storage/box/emps/populate_contents()
	for(var/i in 1 to 5)
		new /obj/item/weapon/grenade/empgrenade(src)

/obj/item/weapon/storage/box/frag
	name = "box of fragmentation grenades"
	desc = "A box containing four fragmentation grenades. Designed for use on enemies in the open."
	icon_state = "box_security"
	illustration = "frag"

/obj/item/weapon/storage/box/frag/populate_contents()
	for(var/i in 1 to 4)
		new /obj/item/weapon/grenade/frag(src)

/obj/item/weapon/storage/box/incendiary
	name = "box of incendiary grenades"
	desc = "A box containing five incendiary grenades."
	icon_state = "box_security"
	illustration = "flashbang"

/obj/item/weapon/storage/box/incendiary/populate_contents()
	for(var/i in 1 to 5)
		new /obj/item/weapon/grenade/chem_grenade/incendiary(src)

/obj/item/weapon/storage/box/explosive
	name = "box of blast grenades"
	desc = "A box containing four blast grenades. Designed for assaulting strongpoints."
	icon_state = "box_security"
	illustration = "blast"

/obj/item/weapon/storage/box/explosive/populate_contents()
	for(var/i in 1 to 4)
		new /obj/item/weapon/grenade/explosive(src)


/obj/item/weapon/storage/box/smokes
	name = "box of smoke bombs"
	desc = "A box containing five smoke bombs."
	illustration = "flashbang"

/obj/item/weapon/storage/box/smokes/populate_contents()
	for(var/i in 1 to 5)
		new /obj/item/weapon/grenade/smokebomb(src)

/obj/item/weapon/storage/box/anti_photons
	name = "box of anti-photon grenades"
	desc = "A box containing five experimental photon disruption grenades."
	illustration = "flashbang"

/obj/item/weapon/storage/box/anti_photons/populate_contents()
	for(var/i in 1 to 5)
		new /obj/item/weapon/grenade/anti_photon(src)

/obj/item/weapon/storage/box/baton_rounds
	name = "box of baton rounds"
	desc = "A box containing six baton rounds. Designed to be fired from a grenade launcher."
	illustration = "flashbang"

/obj/item/weapon/storage/box/baton_rounds/populate_contents()
	for(var/i in 1 to 6)
		new  /obj/item/ammo_casing/grenade(src)

/obj/item/weapon/storage/box/flash_grenade_shells
	name = "box of flash grenade shells"
	desc = "A box containing six flash grenade shells. Designed to be fired from a grenade launcher."
	illustration = "flashbag"

/obj/item/weapon/storage/box/flash_grenade_shells/populate_contents()
	for(var/i in 1 to 6)
		new  /obj/item/ammo_casing/grenade/flash(src)

/obj/item/weapon/storage/box/emp_grenade_shells
	name = "box of EMP grenade shells"
	desc = "A box containing six EMP grenade shells. Designed to be fired from a grenade launcher."
	illustration = "flashbang"

/obj/item/weapon/storage/box/emp_grenade_shells/populate_contents()
	for(var/i in 1 to 6)
		new  /obj/item/ammo_casing/grenade/emp(src)

/obj/item/weapon/storage/box/frag_grenade_shells
	name = "box of frag grenade shells"
	desc = "A box containing six frag grenade shells. Designed to be fired from a grenade launcher."
	illustration = "flashbang"

/obj/item/weapon/storage/box/frag_grenade_shells/populate_contents()
	for(var/i in 1 to 6)
		new  /obj/item/ammo_casing/grenade/frag(src)

/obj/item/weapon/storage/box/blast_grenade_shells
	name = "box of blast grenade shells"
	desc = "A box containing six blast grenade shells. Designed to be fired from a grenade launcher."
	illustration = "flashbang"

/obj/item/weapon/storage/box/blast_grenade_shells/populate_contents()
	for(var/i in 1 to 6)
		new  /obj/item/ammo_casing/grenade/blast(src)

/obj/item/weapon/storage/box/trackimp
	name = "boxed tracking implant kit"
	desc = "Box full of scum-bag tracking utensils."
	illustration = "implant"

/obj/item/weapon/storage/box/trackimp/populate_contents()
	new /obj/item/weapon/implantcase/tracking(src)
	new /obj/item/weapon/implantcase/tracking(src)
	new /obj/item/weapon/implantcase/tracking(src)
	new /obj/item/weapon/implantcase/tracking(src)
	new /obj/item/weapon/implanter(src)
	new /obj/item/weapon/implantpad(src)
	new /obj/item/weapon/locator(src)

/obj/item/weapon/storage/box/chemimp
	name = "boxed chemical implant kit"
	desc = "Box of stuff used to implant chemicals."
	illustration = "implant"

/obj/item/weapon/storage/box/chemimp/populate_contents()
	new /obj/item/weapon/implantcase/chem(src)
	new /obj/item/weapon/implantcase/chem(src)
	new /obj/item/weapon/implantcase/chem(src)
	new /obj/item/weapon/implantcase/chem(src)
	new /obj/item/weapon/implantcase/chem(src)
	new /obj/item/weapon/implanter(src)
	new /obj/item/weapon/implantpad(src)



/obj/item/weapon/storage/box/rxglasses
	name = "box of prescription glasses"
	desc = "This box contains nerd glasses."
	illustration = "glasses"

/obj/item/weapon/storage/box/rxglasses/populate_contents()
	for(var/i in 1 to 7)
		new /obj/item/clothing/glasses/regular(src)

/obj/item/weapon/storage/box/drinkingglasses
	name = "box of drinking glasses"
	desc = "It has a picture of drinking glasses on it."

/obj/item/weapon/storage/box/drinkingglasses/populate_contents()
	for(var/i in 1 to 6)
		new /obj/item/weapon/reagent_containers/food/drinks/drinkingglass(src)

/obj/item/weapon/storage/box/cdeathalarm_kit
	name = "death alarm kit"
	desc = "Box of stuff used to implant death alarms."
	illustration = "implant"
	item_state = "syringe_kit"

/obj/item/weapon/storage/box/cdeathalarm_kit/populate_contents()
	new /obj/item/weapon/implanter(src)
	new /obj/item/weapon/implantcase/death_alarm(src)
	new /obj/item/weapon/implantcase/death_alarm(src)
	new /obj/item/weapon/implantcase/death_alarm(src)
	new /obj/item/weapon/implantcase/death_alarm(src)
	new /obj/item/weapon/implantcase/death_alarm(src)
	new /obj/item/weapon/implantcase/death_alarm(src)

/obj/item/weapon/storage/box/flares
	name = "box of flares"
	desc = "Box that contains some flares."
	icon_state = "box"
	illustration = "flare"

	New()
		..()
		new /obj/item/device/lighting/glowstick/flare(src)
		new /obj/item/device/lighting/glowstick/flare(src)
		new /obj/item/device/lighting/glowstick/flare(src)
		new /obj/item/device/lighting/glowstick/flare(src)
		new /obj/item/device/lighting/glowstick/flare(src)
		new /obj/item/device/lighting/glowstick/flare(src)
		new /obj/item/device/lighting/glowstick/flare(src)

/obj/item/weapon/storage/box/condimentbottles
	name = "box of condiment bottles"
	desc = "It has a large ketchup smear on it."

/obj/item/weapon/storage/box/condimentbottles/empty/populate_contents()
	return

/obj/item/weapon/storage/box/condimentbottles/populate_contents()
	for(var/i in 1 to 7)
		new /obj/item/weapon/reagent_containers/food/condiment(src)

/obj/item/weapon/storage/box/cups
	name = "box of paper cups"
	desc = "It has pictures of paper cups on the front."

/obj/item/weapon/storage/box/cups/populate_contents()
	for(var/i in 1 to 7)
		new /obj/item/weapon/reagent_containers/food/drinks/sillycup(src)

/obj/item/weapon/storage/box/donkpockets
	name = "box of donk-pockets"
	desc = "<B>Instructions:</B> <I>Heat in microwave. Product will cool if not eaten within seven minutes.</I>"
	icon_state = "box_donk_pocket"
	illustration = null

/obj/item/weapon/storage/box/donkpockets/populate_contents()
	for(var/i in 1 to 6)
		new /obj/item/weapon/reagent_containers/food/snacks/donkpocket(src)

/obj/item/weapon/storage/box/sinpockets
	name = "box of sin-pockets"
	desc = "<B>Instructions:</B> <I>Crush bottom of package to initiate chemical heating. Wait for 20 seconds before consumption. Product will cool if not eaten within seven minutes.</I>"
	icon_state = "box_donk_pocket"
	illustration = null

/obj/item/weapon/storage/box/sinpockets/populate_contents()
	for(var/i in 1 to 6)
		new /obj/item/weapon/reagent_containers/food/snacks/donkpocket/sinpocket(src)

/obj/item/weapon/storage/box/monkeycubes
	name = "monkey cube box"
	desc = "Drymate brand monkey cubes. Just add water!"
	icon = 'icons/obj/food.dmi'
	icon_state = "monkeycubebox"
	illustration = null
	can_hold = list(/obj/item/weapon/reagent_containers/food/snacks/monkeycube)

/obj/item/weapon/storage/box/monkeycubes/populate_contents()
	for(var/i in 1 to 5)
		new /obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped(src)

/obj/item/weapon/storage/box/ids
	name = "box of spare IDs"
	desc = "Has so many empty IDs."
	icon_state = "box_id"
	illustration = null

/obj/item/weapon/storage/box/ids/populate_contents()
	for(var/i in 1 to 7)
		new /obj/item/weapon/card/id(src)

/obj/item/weapon/storage/box/handcuffs
	name = "box of spare handcuffs"
	desc = "A box full of handcuffs."
	icon_state = "box_security"
	illustration = "handcuff"

/obj/item/weapon/storage/box/handcuffs/populate_contents()
	for(var/i in 1 to 7)
		new /obj/item/weapon/handcuffs(src)


/obj/item/weapon/storage/box/mousetraps
	name = "box of Pest-B-Gone mousetraps"
	desc = "<B><FONT color='red'>WARNING:</FONT></B> <I>Keep out of reach of children</I>."
	illustration = "mousetraps"

/obj/item/weapon/storage/box/mousetraps/populate_contents()
	for(var/i in 1 to 7)
		new /obj/item/device/assembly/mousetrap(src)

/obj/item/weapon/storage/box/pillbottles
	name = "box of pill bottles"
	desc = "It has pictures of pill bottles on its front."

/obj/item/weapon/storage/box/pillbottles/empty/populate_contents()
	return

/obj/item/weapon/storage/box/pillbottles/populate_contents()
	for(var/i in 1 to 7)
		new /obj/item/weapon/storage/pill_bottle(src)

/obj/item/weapon/storage/box/snappops
	name = "snap pop box"
	desc = "Eight wrappers of fun! Ages 8 and up. Not suitable for children."
	icon = 'icons/obj/toy.dmi'
	icon_state = "spbox"

/obj/item/weapon/storage/box/snappops/populate_contents()
	for(var/i in 1 to 8)
		new /obj/item/toy/junk/snappop(src)

/obj/item/weapon/storage/box/matches
	name = "matchbox"
	desc = "A small box of 'Space-Proof' premium matches."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "matchbox"
	item_state = "zippo"
	illustration = null
	w_class = ITEM_SIZE_TINY
	slot_flags = SLOT_BELT

/obj/item/weapon/storage/box/matches/populate_contents()
	for(var/i in 1 to 14)
		new /obj/item/weapon/flame/match(src)
	make_exact_fit()

/obj/item/weapon/storage/box/matches/attackby(obj/item/weapon/flame/match/W, mob/user)
	if(istype(W) && !W.lit && !W.burnt)
		playsound(src, 'sound/items/matchstrike.ogg', 20, 1, 1)
		W.lit = 1
		W.damtype = "burn"
		W.icon_state = "match_lit"
		W.tool_qualities = list(QUALITY_CAUTERIZING = 10)
		START_PROCESSING(SSobj, W)
	W.update_icon()
	return

/obj/item/weapon/storage/box/autoinjectors
	name = "box of injectors"
	desc = "Contains auto-injectors."
	illustration = "syringe"

/obj/item/weapon/storage/box/autoinjectors/populate_contents()
	for(var/i in 1 to 7)
		new /obj/item/weapon/reagent_containers/hypospray/autoinjector(src)

/obj/item/weapon/storage/box/lights
	name = "box of replacement bulbs"
	illustration = "light"
	desc = "This box is shaped on the inside so that only light tubes and bulbs fit."
	use_to_pickup = TRUE // for picking up broken bulbs, not that most people will try

/obj/item/weapon/storage/box/lights/bulbs/populate_contents()
	for(var/i in 1 to 21)
		new /obj/item/weapon/light/bulb(src)
	make_exact_fit()

/obj/item/weapon/storage/box/lights/tubes
	name = "box of replacement tubes"
	illustration = "lighttube"

/obj/item/weapon/storage/box/lights/tubes/populate_contents()
	for(var/i in 1 to 21)
		new /obj/item/weapon/light/tube(src)
	make_exact_fit()


/obj/item/weapon/storage/box/lights/mixed
	name = "box of replacement lights"
	illustration = "lightmixed"

/obj/item/weapon/storage/box/lights/mixed/empty/populate_contents()
	return

/obj/item/weapon/storage/box/lights/mixed/populate_contents()
	for(var/i in 1 to 14)
		new /obj/item/weapon/light/tube(src)
	for(var/i in 1 to 7)
		new /obj/item/weapon/light/bulb(src)
	make_exact_fit()

/obj/item/weapon/storage/box/data_disk
	name = "data disk box"
	illustration = "disk"

/obj/item/weapon/storage/box/data_disk/populate_contents()
	for(var/i in 1 to 7)
		new /obj/item/weapon/computer_hardware/hard_drive/portable(src)

/obj/item/weapon/storage/box/data_disk/basic
	name = "basic data disk box"
	illustration = "disk"

/obj/item/weapon/storage/box/data_disk/basic/populate_contents()
	for(var/i in 1 to 7)
		new /obj/item/weapon/computer_hardware/hard_drive/portable/basic(src)

/obj/item/weapon/storage/box/trooperuniform
	name = "Trooper/Corpsman Service and Dress Kit"
	desc = "Box that contained a bluespace sealed Blackshield Service Uniform and Dress Uniform. Once items are removed, they won't fit again."
	icon_state = "box"

	New()
		..()
		new /obj/item/clothing/under/rank/trooper/service(src)
		new /obj/item/clothing/suit/rank/trooper/service(src)
		new /obj/item/clothing/suit/rank/trooper/dress(src)
		new /obj/item/clothing/head/rank/trooperdress(src)
		new /obj/item/clothing/accessory/tie/navy(src)
		new /obj/item/clothing/shoes/laceup(src)

/obj/item/weapon/storage/box/sergeantuniform
	name = "Sergeant Service and Dress Kit"
	desc = "Box that contained a bluespace sealed Blackshield Service Uniform and Dress Uniform. Once items are removed, they won't fit again."
	icon_state = "box"

	New()
		..()
		new /obj/item/clothing/under/rank/armorer/service(src)
		new /obj/item/clothing/suit/rank/armorer/service(src)
		new /obj/item/clothing/suit/rank/armorer/dress(src)
		new /obj/item/clothing/head/rank/trooperdress(src)
		new /obj/item/clothing/accessory/tie/navy(src)
		new /obj/item/clothing/shoes/laceup(src)

/obj/item/weapon/storage/box/commanderuniform
	name = "Commander Service and Dress Kit"
	desc = "Box that contained a bluespace sealed Blackshield Service Uniform and Dress Uniform. Once items are removed, they won't fit again."
	icon_state = "box"

	New()
		..()
		new /obj/item/clothing/under/rank/commander/service(src)
		new /obj/item/clothing/suit/rank/commander/service(src)
		new /obj/item/clothing/suit/rank/commander/dress(src)
		new /obj/item/clothing/head/rank/commanderdress(src)
		new /obj/item/clothing/accessory/tie/navy(src)
		new /obj/item/clothing/shoes/laceup(src)

/obj/item/weapon/storage/box/blankranks
	name = "Box of Blank Ranks"
	desc = "A box full of solid red, ''blank'' Blackshield ranks, for distribution to volunteers and cadets."
	icon_state = "box"

	New()
		..()
		new /obj/item/clothing/accessory/ranks/blank(src)
		new /obj/item/clothing/accessory/ranks/blank(src)
		new /obj/item/clothing/accessory/ranks/blank(src)
		new /obj/item/clothing/accessory/ranks/blank(src)
		new /obj/item/clothing/accessory/ranks/blank(src)
		new /obj/item/clothing/accessory/ranks/blank(src)
		new /obj/item/clothing/accessory/ranks/blank(src)
