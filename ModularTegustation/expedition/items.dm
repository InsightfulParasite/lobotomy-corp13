
/*------------\
|Raw Resources|
\------------*/
/obj/item/lignite
	name = "lignite coal"
	desc = "A low grade form of coal that is usually formed by peat bogs."
	icon = 'icons/obj/mining.dmi'
	icon_state = "slag"
	grind_results = list(/datum/reagent/carbon = 20)

/obj/item/comp_carbon
	name = "compressed carbon"
	desc = "Self explanitory."
	icon = 'icons/obj/mining.dmi'
	icon_state = "ore"
	grind_results = list(/datum/reagent/carbon = 35)
