extends CharacterBody2D

const SPEED = 200.0  # Speed of the ship
const ROTATION_SPEED = 5.0  # Rotation speed of the ship
const BULLET_SPEED  = 400.0
const NUM_SHOTS :int = 3
const SHOT_SPREAD :float = 10.0

var cannon_ball = preload("res://scenes/cannonBall.tscn")

func _physics_process(delta: float) -> void:
	# Rotate the ship to face the mouse, adjusting for its front orientation
	var mouse_position = get_global_mouse_position()
	rotation = (mouse_position - global_position).angle() + PI / 2

	# Move the ship forward in its current direction when the up arrow is pressed
	if Input.is_action_pressed("up"):
		# Calculate the forward direction based on the ship's rotation
		var forward_direction = Vector2(cos(rotation - PI / 2), sin(rotation - PI / 2))
		velocity = forward_direction * SPEED
	else:
		# Stop the ship if the up arrow is not pressed
		velocity = Vector2.ZERO
		
	#Fire the cannons
	if Input.is_action_just_pressed("fire_left"):	
		var spawn_position = $Marker_left.global_position
		var direction  = Vector2(-1,0)
		fire_cannonball(spawn_position, direction)
	
	if Input.is_action_just_pressed("fire_right"):
		var spawn_position = $Marker_right.global_position
		var direction  = Vector2(1,0)
		fire_cannonball(spawn_position, direction)	
		
func fire_cannonball(spawn_position: Vector2, direction: Vector2):	
	for i in range(NUM_SHOTS):
		var cannonBall_instance  = cannon_ball.instantiate()
		cannonBall_instance.global_position = spawn_position
		# Adjust angle slightly for each shot in a spread pattern
		var spread_angle = SHOT_SPREAD * ( i - NUM_SHOTS / 2.0)
		var spread_direction = direction.rotated(deg_to_rad(spread_angle))
		cannonBall_instance.linear_velocity = spread_direction * BULLET_SPEED
		get_tree().get_root().add_child(cannonBall_instance)

	# Apply movement
	move_and_slide()
