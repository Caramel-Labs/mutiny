extends CharacterBody2D

const DETECTION_RADIUS = 500.0  # Proximity radius to detect the player
const FIRE_INTERVAL = 2.0  # Time interval between firing cannonballs
const BULLET_SPEED = 400.0
const NUM_SHOTS :int = 3
const SHOT_SPREAD :float = 10.0
@export var cannonball_speed: float = 400.0

var cannon_ball = preload("res://scenes/cannonBall.tscn")

var player_ship: CharacterBody2D  # Reference to the player ship
var fire_timer = 0.0  # Timer to control firing rate

func _ready() -> void:
	# Find the player ship in the scene
	player_ship = get_tree().get_current_scene().get_node_or_null("Ship")
	if player_ship == null:
		print("Player ship not found in the current scene")
	else:
		print("Player ship detected in the current scene")

func _physics_process(delta: float) -> void:
	if player_ship:
		# Check distance to the player ship
		var distance_to_player = global_position.distance_to(player_ship.global_position)
		if distance_to_player <= DETECTION_RADIUS:
			# If within detection radius, start firing
			fire_timer -= delta
			if fire_timer <= 0.0:
				fire_timer = FIRE_INTERVAL
				fire_cannons()

func fire_cannons() -> void:
	# Fire from the left cannon
	fire_cannonball($MarkerLeft.global_position, Vector2(-1, 0))

	# Fire from the right cannon
	fire_cannonball($MarkerRight.global_position, Vector2(1, 0))
	
	$FireSound.play()

func fire_cannonball(spawn_position: Vector2, direction: Vector2) -> void:
	for i in range(NUM_SHOTS):
		var cannonBall_instance = cannon_ball.instantiate()
		cannonBall_instance.global_position = spawn_position
		cannonBall_instance.ignore_body = self

		# Adjust angle slightly for each shot in a spread pattern
		var spread_angle = SHOT_SPREAD * (i - NUM_SHOTS / 2.0)
		var spread_direction = direction.rotated(deg_to_rad(spread_angle))
		
		cannonBall_instance.velocity = spread_direction.normalized() * cannonball_speed

		# Add the cannonball to the scene tree
		get_tree().get_root().add_child(cannonBall_instance)
		
