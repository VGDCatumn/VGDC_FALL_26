extends Area2D

@export var spring_power := 1800

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("PLAYER"):
		$AnimationPlayer.play("boing")
		$AudioStreamPlayer.play()
		
		# get launch_direction by taking the UP vector of the spring
		var launch_direction = -transform.y
		body.velocity = launch_direction * spring_power
		
		# give player more air control
		body.has_aerial_movement = true
