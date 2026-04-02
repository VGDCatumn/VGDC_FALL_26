extends Area2D

@export var spring_power := 1.4
@export var bounce_threshold := 2000

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("PLAYER"):
		
		# gets velocity from play scirpt
		var prev_vel = body.prev_velocity.y
		
		# get launch_direction by taking the UP vector of the spring
		var launch_direction = -transform.y
		body.velocity = launch_direction * (-prev_vel * spring_power)
		
		# give player more air control
		body.has_aerial_movement = true
	
