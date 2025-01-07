extends CharacterBody2D

const SPEED:float= 200.0
const ROTATION_SPEED:float = 5.0
const MAX_HEALTH:float = 100.0
const NUM_SHOTS: int = 3
const SHOT_SPREAD: float = 10.0

@export var cannonball_speed: float = 400.0
@export var reload_time: float = 2.0
@export var cannon_ball: PackedScene = preload("res://scenes/cannonBall.tscn")
@onready var multiplayer_synchronizer = $MultiplayerSynchronizer
@onready var camera = $Camera2D


var can_fire: bool = true

#cuz for some goddamn reason can't synchronize the native velocity 
@export var sync_velocity := Vector2.ZERO:
	set(value):
		sync_velocity = value
		velocity = value
		
@export var sync_health:float = MAX_HEALTH:
	set(value):
		sync_health = value
		if sync_health <= 0 :
			destroy_ship.rpc()
			
			
func _enter_tree() -> void:
	var peer_id  = str(name).to_int()
	set_multiplayer_authority(peer_id)
	if multiplayer_synchronizer: 
		multiplayer_synchronizer.set_multiplayer_authority(peer_id)
		print("authority set to", peer_id)
			

# Setting the timer explicitly because it can change for different weapons
func _ready():
	# Set up timer
	$ReloadTimer.wait_time = reload_time
	$ReloadTimer.one_shot = true
	sync_health = MAX_HEALTH
	if multiplayer.get_unique_id() == get_multiplayer_authority():
		camera.make_current()
	else:
		if camera.is_current():
			camera.enabled = false

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	
	# Move the ship forward in its current direction when the "W" key is pressed
	if Input.is_action_pressed("up"):
		# Calculate the forward direction based on the ship's rotation
		var forward_direction = Vector2(cos(rotation - PI / 2), sin(rotation - PI / 2))
		sync_velocity = forward_direction * SPEED

		# Rotate the ship left or right if "W" and "A" or "D" are pressed together
		if Input.is_action_pressed("left"):
			rotation -= ROTATION_SPEED * delta
		elif Input.is_action_pressed("right"):
			rotation += ROTATION_SPEED * delta
	else:
		# Stop the ship if the "W" key is not pressed
		sync_velocity = Vector2.ZERO
	
	velocity = sync_velocity
	move_and_slide()

	# Handle firing
	if Input.is_action_just_pressed("fire_left") and can_fire:
		fire_cannons.rpc("left")
	
	if Input.is_action_just_pressed("fire_right") and can_fire:
		fire_cannons.rpc("right")

@rpc("any_peer", "call_local")
func fire_cannons(side: String):
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
			request_spawn_cannonballs( spawn_position, direction)
		else:
			request_spawn_cannonballs.rpc_id(1, spawn_position, direction)	
	
	$FireSound.play()
	trigger_cooldown()
	
	
@rpc("any_peer")
func request_spawn_cannonballs(spawn_position: Vector2, direction: Vector2):
	if multiplayer.get_unique_id() != 1:
		return
	spawn_cannonballs.rpc(spawn_position, direction)
		
@rpc("any_peer", "call_local")
func spawn_cannonballs(spawn_position: Vector2, direction: Vector2):
	for i in range(NUM_SHOTS):
		var cannonBall_instance = cannon_ball.instantiate()
		cannonBall_instance.set_multiplayer_authority(1)
		
		cannonBall_instance.global_position = spawn_position
		cannonBall_instance.ignore_body = self
		
		var spread_angle = SHOT_SPREAD * (i - NUM_SHOTS / 2.0)
		var spread_direction = direction.rotated(deg_to_rad(spread_angle))
		cannonBall_instance.velocity = spread_direction.normalized() * cannonball_speed
		
		# Add to dedicated Cannonballs node
		get_tree().get_current_scene().get_node("Cannonballs").add_child(cannonBall_instance, true)	
	

@rpc("any_peer")
func request_damage(amount:float):
	
	if multiplayer.get_unique_id() != 1:
		return
	
	apply_damage.rpc(amount)	

@rpc("any_peer", "call_local")	
func apply_damage(amount:float):
	sync_health -= amount
	#print(sync_health, multiplayer.get_unique_id())

@rpc("any_peer", "call_local")
func destroy_ship():
	if not is_multiplayer_authority():
		return
	
	queue_free()	
	
func trigger_cooldown():
	can_fire = false
	$ReloadTimer.start()

func _on_reload_timer_timeout() -> void:
	can_fire = true
