extends Node

const PlayerScene = preload("res://Gameplay/Player/player.tscn")

const def_server_ip : String = "localhost"
const def_server_port : int = 4242

func _ready():
	# Start the server if Godot is passed the "--server" argument,
	# and start a client otherwise.
	print(OS.get_process_id(), ': application started')
	if "--server" in OS.get_cmdline_args():
		start_network(true)
	DisplayServer.window_set_title(str(OS.get_process_id()))


func start_network(server: bool, server_ip : String = def_server_ip, server_port : int = def_server_port) -> int:
	var peer = ENetMultiplayerPeer.new()
	if server:
		multiplayer.peer_connected.connect(self.create_player)
		multiplayer.peer_disconnected.connect(self.destroy_player)
		
		var err = peer.create_server(server_port, 10)
		if err != OK:
			return err
		print(OS.get_process_id(), ': server started')
	else:
		var err = peer.create_client(server_ip, server_port)
		if err != OK:
			return err
	
	multiplayer.set_multiplayer_peer(peer)
	multiplayer.server_disconnected.connect(_on_disconnect)
	if server:
		create_player(1)
	return OK

func create_player(id):
	# Instantiate a new player for this client.
	$PlayerSpawner.spawn(id)

func destroy_player(id):
	# Delete this peer's nodes.
#	get_tree().get_node(str(id)).queue_free()
	print(OS.get_process_id(), ' Player left: ', str(id))
	for n in get_tree().get_nodes_in_group("net_id_"+str(id)): 
		n.queue_free()

func _on_disconnect():
	$"../Panel".show()

func _on_connect_button_pressed():
	var should_host : bool = $"../Panel/VBoxContainer/NetworkTabs".current_tab == 1
	var ip : String = $"../Panel/VBoxContainer/NetworkTabs/Connect/HBoxContainer/ServerLineEdit".text
	var port : int = def_server_port
	if should_host:
		port = $"../Panel/VBoxContainer/NetworkTabs/Host/PortLineEdit".text.to_int()
	else:
		port = $"../Panel/VBoxContainer/NetworkTabs/Connect/HBoxContainer/PortLineEdit".text.to_int()

	var err = start_network(should_host, ip, port)
	print(OS.get_process_id(), ': connecting...')
	if err != OK:
		print(OS.get_process_id(), ': connect failed... ', err)
		OS.alert("Failed to start networking, error code " + str(err), "Fail to connect!")
		return
	print(OS.get_process_id(), ': Connected! ID: ', multiplayer.get_unique_id())
	$"../Panel".hide()
