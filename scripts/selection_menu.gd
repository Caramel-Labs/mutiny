extends HBoxContainer

# Array of ship data
var ships = [
	{"name": "Clipper", "health": 80, "speed": 20, "damage": 10},
	{"name": "Fireship", "health": 120, "speed": 15, "damage": 20},
	{"name": "Dreadnought", "health": 200, "speed": 10, "damage": 20},
	{"name": "Bombketch", "health": 120, "speed": 12, "damage": 30},
	{"name": "Schooner", "health": 100, "speed": 12, "damage": 18},
]

# Default ship index when the scene is loaded
var selected_ship_index: int = 0

# References to nodes
@onready var grid: GridContainer = $GridContainer
@onready var stats_container: VBoxContainer = $VBoxContainer/StatsContainer
@onready var confirm_button: Button = $VBoxContainer/ConfirmButton

func _ready() -> void:
	print("Initializing Ship Selection Scene...")

	# Set up ship buttons in the GridContainer
	print("Setting up ship buttons...")
	for i in range(ships.size()):
		var button = grid.get_child(i) as Button
		if button == null:
			push_error("Child at index %d is not a Button!" % i)
			continue
		button.text = ships[i]["name"]
		print("Button %d set to: %s" % [i, ships[i]["name"]])
		button.pressed.connect(_on_ship_button_pressed.bind(i))

	# Set default stats for the first ship
	_update_stats(selected_ship_index)

	# Connect the Confirm button's signal
	print("Connecting Confirm button signal...")
	confirm_button.pressed.connect(_on_confirm_pressed)

func _on_ship_button_pressed(ship_index: int) -> void:
	print("Ship button pressed. Selected ship index: %d" % ship_index)
	selected_ship_index = ship_index
	_update_stats(selected_ship_index)

func _update_stats(ship_index: int) -> void:
	print("Updating stats for ship index: %d" % ship_index)
	if ships.size() <= ship_index:
		push_error("Ship index %d is out of range!" % ship_index)
		return

	var ship = ships[ship_index]
	print("Selected ship data: %s" % str(ship))

	# Access the StatsContainer node and its children
	var stats_label = stats_container.get_node("StatsLabel")
	var stat1_label = stats_container.get_node("HealthLabel")
	var stat2_label = stats_container.get_node("SpeedLabel")
	var stat3_label = stats_container.get_node("DamageLabel")

	if stats_label == null or stat1_label == null or stat2_label == null or stat3_label == null:
		push_error("One or more stats labels are missing from StatsContainer!")
		return

	stats_label.text = "Stats for " + ship["name"]
	stat1_label.text = "Health: " + str(ship["health"])
	stat2_label.text = "Speed: " + str(ship["speed"])
	stat3_label.text = "Damage: " + str(ship["damage"])
	print("Stats updated successfully for: %s" % ship["name"])

func _on_confirm_pressed() -> void:
	GameMode.selected_ship_name = ships[selected_ship_index]["name"]
	print("Confirmed ship: %s" % GameMode.selected_ship_name)
	print("Game mode: %s" % GameMode.mode)
	# Change to the game scene directly
	get_tree().change_scene_to_file("res://scenes/game.tscn")
