extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GameMode.mode == "host":
		become_host()
	elif GameMode.mode == "join":
		join_as_player()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func become_host():
	MultiplayerManager.host_game()
	%Multiplayer.hide()
	

func join_as_player():
	MultiplayerManager.join_game()
	%Multiplayer.hide()
