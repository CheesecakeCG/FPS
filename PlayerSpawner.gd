extends MultiplayerSpawner

func _spawn_custom(data: Variant) -> Object:
	data = int(data)
	print(OS.get_process_id(), ": initilizing player: ", data)

	var p = replication[0].instantiate()
	p.add_to_group("net_id_"+str(data))
	p.set_multiplayer_authority(data, true)

	
#	get_node(spawn_path).add_child(p, true)
	return p
