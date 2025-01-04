extends Area2D


var touched = false

func _input(event):
	if event is InputEventScreenTouch:
		var distance = event.position.distance_to($ToggleBase.global_position)
		if not touched:
			if distance < $CollisionShape2D.shape.radius:
				touched = true
			else:
				$ToggleBase/ToggleTip.position = Vector2(0, 0)
				touched = false

func _process(delta):
	if touched:
		$ToggleBase/ToggleTip.global_position = get_global_mouse_position()
		# Clamp the small circle
		$ToggleBase/ToggleTip.position = $ToggleBase.position + ($ToggleBase/ToggleTip.position - $ToggleBase.position).limit_length($CollisionShape2D.shape.radius)
