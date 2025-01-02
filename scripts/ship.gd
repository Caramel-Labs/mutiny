extends CharacterBody2D

const SPEED = 300.0
const ROTATION_SPEED = 5.0  # Speed at which the ship turns

func _physics_process(delta: float) -> void:
	# Get the input direction for movement (horizontal and vertical)
	var input_vector := Vector2.ZERO
	if Input.is_action_pressed("ui_up"):
		input_vector.y -= 1
	if Input.is_action_pressed("ui_down"):
		input_vector.y += 1
	if Input.is_action_pressed("ui_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("ui_right"):
		input_vector.x += 1

	# Normalize the direction to avoid faster diagonal movement
	input_vector = input_vector.normalized()

	# If there's any input, move the ship and rotate it to face the movement direction
	if input_vector != Vector2.ZERO:
		# Rotate the ship toward the movement direction (negative angle for correct orientation)
		rotation = input_vector.angle() + PI / 2

		# Set velocity to move in the desired direction
		velocity = input_vector * SPEED
	else:
		# Decelerate when there's no input
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)

	# Apply the movement
	move_and_slide()
