extends MultiplayerSpawner

func _spawn_custom(data: Variant):
	if data != TYPE_FLOAT:
		printerr(OS.get_process_id(), ": Error initilizing player.")
#		return null
	var p = replication[0].instantiate()
	p.add_to_group("net_id_"+str(data))
	p.set_multiplayer_authority(data)
	return p
