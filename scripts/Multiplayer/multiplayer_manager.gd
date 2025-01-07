extends Node

const PORT = 8080
const SERVER_IP = "127.0.0.1"
const MAX_CONNECTIONS = 6
var players = {}
var player_scene = preload("res://scenes/ship.tscn")
var players_spawn_node

func host_game():
	print("multiplayer manager creating server")
	players_spawn_node  = get_tree().get_current_scene().get_node("Players")
	var server_peer = ENetMultiplayerPeer.new()
	var error = server_peer.create_server(PORT, MAX_CONNECTIONS)
	if error:
		return error
	multiplayer.multiplayer_peer = server_peer
	#remove_single_player()
	add_player_to_game(1)
	
	#move this later to the _ready function for better structure 
	multiplayer.peer_connected.connect(add_player_to_game)
	multiplayer.peer_disconnected.connect(del_player)

func join_game():
	print("Player joining server")	
	var client_peer = ENetMultiplayerPeer.new()
	var error = client_peer.create_client(SERVER_IP, PORT)
	if error:
		return error
	multiplayer.multiplayer_peer = client_peer
	#remove_single_player()
	
	
func add_player_to_game(id:int):
	print("player %s joined the game" %id)	
	var player_to_add = player_scene.instantiate()
	player_to_add.name = str(id)
	players_spawn_node.add_child(player_to_add, true)

func remove_single_player():
	print("removing the single player")
	var player_to_remove = get_tree().get_current_scene().get_node("Ship")	
	player_to_remove.queue_free()
	
func del_player(id:int):
	print("player %s left the game" %id)
	if not players_spawn_node.has_node(str(id)):
		return
	players_spawn_node.get_node(str(id)).queue_free()	
