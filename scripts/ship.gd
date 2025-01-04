extends CharacterBody2D

const SPEED = 200.0  # Speed of the ship
const ROTATION_SPEED = 3.0  # Adjust rotation speed for smooth turning

const NUM_SHOTS :int = 3
const SHOT_SPREAD :float = 10.0
@export var cannonball_speed: float = 400.0
@export var reload_time: float = 2.0  # Reload time in seconds
var can_fire: bool = true
var cannon_ball = preload("res://scenes/cannonBall.tscn")

@export var player_id := 1:
	set(id):
		player_id = id

# Setting the timer explicitly because it can change for different weapons
func _ready():
	$ReloadTimer.wait_time = reload_time
	$ReloadTimer.one_shot = true

func _physics_process(delta: float) -> void:
	# Rotate the ship left or right using "A" and "D" keys
	if Input.is_action_pressed("left"):
		rotation -= ROTATION_SPEED * delta
	elif Input.is_action_pressed("right"):
		rotation += ROTATION_SPEED * delta

	# Move the ship forward in its current direction when the "W" key is pressed
	if Input.is_action_pressed("up"):
		# Calculate the forward direction based on the ship's rotation
		var forward_direction = Vector2(cos(rotation - PI / 2), sin(rotation - PI / 2))
		velocity = forward_direction * SPEED
	else:
		# Stop the ship if the "W" key is not pressed
		velocity = Vector2.ZERO

	move_and_slide()

	# Fire portside (left) cannons
	if Input.is_action_just_pressed("fire_left") and can_fire:	
		var spawn_position = $Marker_left.global_position
		var direction = -transform.x.normalized()
		fire_cannonball(spawn_position, direction)
		$FireSound.play()
		trigger_cooldown()

	# Fire starboard (right) cannons
	if Input.is_action_just_pressed("fire_right") and can_fire:
		var spawn_position = $Marker_right.global_position
		var direction = transform.x.normalized()
		fire_cannonball(spawn_position, direction)	
		$FireSound.play()
		trigger_cooldown()

func fire_cannonball(spawn_position: Vector2, direction: Vector2):	
	for i in range(NUM_SHOTS):
		var cannonBall_instance = cannon_ball.instantiate()
		cannonBall_instance.global_position = spawn_position
		cannonBall_instance.ignore_body = self
		# Adjust angle slightly for each shot in a spread pattern
		var spread_angle = SHOT_SPREAD * (i - NUM_SHOTS / 2.0)
		var spread_direction = direction.rotated(deg_to_rad(spread_angle))
		cannonBall_instance.velocity = spread_direction.normalized() * cannonball_speed
		get_tree().get_root().add_child(cannonBall_instance)

func trigger_cooldown():
	can_fire = false
	$ReloadTimer.start()

func _on_reload_timer_timeout() -> void:
	can_fire = true
