extends Area2D

@export var explosion: PackedScene
@export var max_distance: float = 500.0  # Distance in pixels before explosion
@export var explosion_duration: float = 1  # Seconds before explosion disappears
@export var velocity: Vector2 = Vector2.ZERO  # Movement direction and speed
var starting_position: Vector2
var distance_traveled: float = 0.0
var ignore_body: Node = null

func _ready():
	starting_position = global_position

func _physics_process(delta):
	# Move the cannonball
	global_position += velocity * delta

	# Calculate distance traveled
	distance_traveled = starting_position.distance_to(global_position)
	
	# Check if the cannonball has exceeded the max distance
	if distance_traveled >= max_distance:
		explode()

func explode():
	if explosion:
		# Instantiate and position the explosion
		var explosion_instance = explosion.instantiate()
		explosion_instance.global_position = global_position
		get_parent().add_child(explosion_instance)

		# Add a timer to remove the explosion after its duration
		var timer = Timer.new()
		timer.wait_time = explosion_duration
		timer.one_shot = true
		timer.timeout.connect(func() -> void: explosion_instance.queue_free())
		get_parent().add_child(timer)
		timer.start()

	# Remove the cannonball
	queue_free()

func _on_body_entered(body: Node) -> void:
	
	if body.has_method("request_damage") and body != ignore_body:
		body.request_damage.rpc(10.0)
		explode()
