extends CharacterBody2D

const SPEED = 200.0  # Speed of the ship
const ROTATION_SPEED = 5.0  # Rotation speed of the ship

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

	# Apply movement
	move_and_slide()
