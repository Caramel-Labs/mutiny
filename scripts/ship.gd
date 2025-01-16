extends CharacterBody2D

# Exported variables for customization
@export var speed: float = 200.0  # Default speed for base ships
@export var rotation_speed: float = 1.0
@export var max_health: float = 100.0
@export var num_shots: int = 3
@export var shot_spread: float = 10.0
@export var cannonball_speed: float = 400.0
@export var reload_time: float = 2.0
@export var cannon_ball: PackedScene = preload("res://scenes/cannonBall.tscn")

# Nodes for multiplayer and camera
@onready var multiplayer_synchronizer = $MultiplayerSynchronizer
@onready var camera = $Camera2D

# Internal variables
var can_fire: bool = true

@export var sync_velocity := Vector2.ZERO:
	set(value):
		sync_velocity = value
		velocity = value

@export var sync_health: float = max_health:
	set(value):
		sync_health = value
		if sync_health <= 0:
			destroy_ship.rpc()

func _enter_tree() -> void:
	var peer_id = str(name).to_int()
	set_multiplayer_authority(peer_id)
	if multiplayer_synchronizer:
		multiplayer_synchronizer.set_multiplayer_authority(peer_id)
		print("Authority set to", peer_id)

# Setting up variables and camera
func _ready() -> void:
	$ReloadTimer.wait_time = reload_time
	$ReloadTimer.one_shot = true
	sync_health = max_health
	if multiplayer.get_unique_id() == get_multiplayer_authority():
		camera.make_current()
	else:
		if camera.is_current():
			camera.enabled = false

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return

	handle_movement(delta)
	handle_firing()

# Virtual function for movement (can be overridden by child classes)
func handle_movement(delta: float) -> void:
	if Input.is_action_pressed("up"):
		var forward_direction = Vector2(cos(rotation - PI / 2), sin(rotation - PI / 2))
		sync_velocity = forward_direction * speed

		if Input.is_action_pressed("left"):
			rotation -= rotation_speed * delta
		elif Input.is_action_pressed("right"):
			rotation += rotation_speed * delta
	else:
		sync_velocity = Vector2.ZERO

	velocity = sync_velocity
	move_and_slide()

# Virtual function for firing (can be overridden by child classes)
func handle_firing() -> void:
	if Input.is_action_just_pressed("fire_left") and can_fire:
		fire_cannons.rpc("left")

	if Input.is_action_just_pressed("fire_right") and can_fire:
		fire_cannons.rpc("right")

# Function to handle cannon fire
@rpc("any_peer", "call_local")
func fire_cannons(side: String) -> void:
	if not can_fire:
		return

	var spawn_position: Vector2
	var direction: Vector2

	if side == "left":
		spawn_position = $Marker_left.global_position
		direction = -transform.x.normalized()
	else: # right
		spawn_position = $Marker_right.global_position
		direction = transform.x.normalized()

	if is_multiplayer_authority():
		if multiplayer.get_unique_id() == 1:
			request_spawn_cannonballs(spawn_position, direction)
		else:
			request_spawn_cannonballs.rpc_id(1, spawn_position, direction)

	$FireSound.play()
	trigger_cooldown()

@rpc("any_peer")
func request_spawn_cannonballs(spawn_position: Vector2, direction: Vector2) -> void:
	if multiplayer.get_unique_id() != 1:
		return
	spawn_cannonballs.rpc(spawn_position, direction)

@rpc("any_peer", "call_local")
func spawn_cannonballs(spawn_position: Vector2, direction: Vector2) -> void:
	for i in range(num_shots):
		var cannonball_instance = cannon_ball.instantiate()
		cannonball_instance.set_multiplayer_authority(1)

		cannonball_instance.global_position = spawn_position
		cannonball_instance.ignore_body = self

		var spread_angle = shot_spread * (i - num_shots / 2.0)
		var spread_direction = direction.rotated(deg_to_rad(spread_angle))
		cannonball_instance.velocity = spread_direction.normalized() * cannonball_speed

		get_tree().get_current_scene().get_node("Cannonballs").add_child(cannonball_instance, true)

# Function to handle damage
@rpc("any_peer")
func request_damage(amount: float) -> void:
	if multiplayer.get_unique_id() != 1:
		return
	apply_damage.rpc(amount)

@rpc("any_peer", "call_local")
func apply_damage(amount: float) -> void:
	sync_health -= amount

@rpc("any_peer", "call_local")
func destroy_ship() -> void:
	if not is_multiplayer_authority():
		return
	queue_free()

# Trigger a cooldown for firing
func trigger_cooldown() -> void:
	can_fire = false
	$ReloadTimer.start()

func _on_reload_timer_timeout() -> void:
	can_fire = true
