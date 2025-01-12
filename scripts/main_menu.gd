extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


# Signal function to handle pressing the Host button
func _on_host_button_pressed() -> void:
	print("The 'Start Game' button was pressed in the main menu.")
	GameMode.mode = "host"
	# Change scene to game scene
	get_tree().change_scene_to_file("res://scenes/game.tscn")


# Signal function to handle pressing the Join button
func _on_join_button_pressed() -> void:
	print("The 'Join Game' button was pressed in the main menu.")
	GameMode.mode = "join"
	# Change scene to game scene
	get_tree().change_scene_to_file("res://scenes/game.tscn")

# Signal function to handle pressing the exit button
func _on_exit_button_pressed() -> void:
	print("The 'Exit Game' button was pressed in the main menu.")
	# Exit the game
	get_tree().quit()
