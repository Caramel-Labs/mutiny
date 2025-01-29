extends Node

const PORT = 8080
const SERVER_IP = "127.0.0.1"
const MAX_CONNECTIONS = 6
var players = {}
var player_scenes = {
	"Clipper":preload("res://scenes/ships/Clipper.tscn"),
	"Bombketch":preload("res://scenes/ships/Bombketch.tscn"),
	"Dreadnought":preload("res://scenes/ships/Dreadnought.tscn"),
	"Schooner":preload("res://scenes/ships/Schooner.tscn"),
	"Fireship":preload("res://scenes/ships/Fireship.tscn"),	
}

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
	GameMode.player_ships[1] = GameMode.selected_ship_name
	add_player_to_game(1)
	#move this later to the _ready function for better structure 
	#multiplayer.peer_connected.connect(add_player_to_game)
	multiplayer.peer_disconnected.connect(del_player)

func join_game():
	print("Player joining server")	
	var client_peer = ENetMultiplayerPeer.new()
	var error = client_peer.create_client(SERVER_IP, PORT)
	if error:
		return error
	multiplayer.multiplayer_peer = client_peer
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	#remove_single_player()
	
func _on_connected_to_server():
	print("Connected to server!")
	rpc_id(1, "assign_ship", GameMode.selected_ship_name)
	
func add_player_to_game(id:int):	
	var ship_name = GameMode.player_ships.get(id, "Clipper")
	var player_scene = player_scenes.get(ship_name, null)
	
	if player_scene == null:
		push_error("Invalid ship selection: %s" % ship_name)
		return
	print("player %s spawned" %id)	
	var player_ship = player_scene.instantiate()
	player_ship.name = str(id)
	players_spawn_node.add_child(player_ship, true)
	print("Synchronizer exists: ", player_ship.has_node("MultiplayerSynchronizer"))

func remove_single_player():
	print("removing the single player")
	var player_to_remove = get_tree().get_current_scene().get_node("Ship")	
	player_to_remove.queue_free()
	
func del_player(id:int):
	print("player %s left the game" %id)
	if not players_spawn_node.has_node(str(id)):
		return
	players_spawn_node.get_node(str(id)).queue_free()	

@rpc("any_peer")	
func assign_ship(ship_name:String):
	var player_id = multiplayer.get_remote_sender_id() 
	GameMode.player_ships[player_id] = ship_name
	print("Received ship selection from Player %s: %s" % [player_id, ship_name])
	add_player_to_game(player_id)
