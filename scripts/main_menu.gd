extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Signal function to handle pressing the start button
func _on_start_button_pressed() -> void:
	print("The 'Start Game' button was pressed in the main menu.")
	# Change scene to game scene
	get_tree().change_scene_to_file("res://scenes/ship_selection.tscn")


<<<<<<< Updated upstream
# Signal function to handle pressing the options button
func _on_options_button_pressed() -> void:
	print("The 'Options Game' button was pressed in the main menu.")
	pass # Replace with function body.

=======
# Signal function to handle pressing the Join button
func _on_join_button_pressed() -> void:
	print("The 'Join Game' button was pressed in the main menu.")
	GameMode.mode = "join"
	# Change scene to game scene
	get_tree().change_scene_to_file("res://scenes/ship_selection.tscn")
>>>>>>> Stashed changes

# Signal function to handle pressing the exit button
func _on_exit_button_pressed() -> void:
	print("The 'Exit Game' button was pressed in the main menu.")
	# Exit the game
	get_tree().quit()
