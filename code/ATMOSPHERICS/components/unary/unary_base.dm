/obj/machinery/networked/atmos/unary
	dir = SOUTH
	initialize_directions = SOUTH
	layer = 2.45 // Cable says we're at 2.45, so we're at 2.45.  (old: TURF_LAYER+0.1)

	var/datum/gas_mixture/air_contents

	var/obj/machinery/networked/atmos/node

	New()
		..()
		initialize_directions = dir
		air_contents = new

		air_contents.volume = 200

	buildFrom(var/mob/usr,var/obj/item/pipe/pipe)
		dir = pipe.dir
		initialize_directions = pipe.get_pipe_dir()
		if (pipe.pipename)
			name = pipe.pipename
		var/turf/T = loc
		level = T.intact ? 2 : 1
		initialize()
		build_network()
		if (node)
			node.initialize()
			node.build_network()
		return 1

// Housekeeping and pipe network stuff below
	network_expand(datum/network/atmos/new_network, obj/machinery/networked/atmos/pipe/reference)
		if(reference == node)
			network = new_network

		if(new_network.normal_members.Find(src))
			return 0

		new_network.normal_members += src

		return null

	Destroy()
		loc = null

		if(node)
			node.disconnect(src)
			del(network)

		node = null

		..()

	initialize()
		if(node) return

		var/node_connect = dir

		for(var/obj/machinery/networked/atmos/target in get_step(src,node_connect))
			if(target.initialize_directions & get_dir(target,src))
				node = target
				break

		update_icon()

	build_network()
		if(!network && node)
			network = new /datum/network/atmos()
			network.normal_members += src
			network.build_network(node, src)


	return_network(obj/machinery/networked/atmos/reference)
		build_network()

		if(reference==node)
			return network

		return null

	reassign_network(datum/network/atmos/old_network, datum/network/atmos/new_network)
		if(network == old_network)
			network = new_network

		return 1

	return_network_air(datum/network/atmos/reference)
		var/list/results = list()

		if(network == reference)
			results += air_contents

		return results

	disconnect(obj/machinery/networked/atmos/reference)
		if(reference==node)
			del(network)
			node = null

		return null