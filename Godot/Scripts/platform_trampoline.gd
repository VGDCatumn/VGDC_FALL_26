extends StaticBody2D

@export var trampoline_power := 1.2
@export var bounce_limit := 3000 #max height you can gain from bouncing off trampoline
@export var clamp_timer := 3  #timer in secs before the velocity clamp is reapplied

# Placeholder values, determined on runtime
var	prev_max_velocity	
var player_ref: Node2D

func _ready() -> void:
	$Timer.wait_time = clamp_timer
	$Timer.one_shot = true 

func _on_detecter_body_entered(body: Node2D) -> void:
	if body.is_in_group("PLAYER"):
		# change player max_y_velocity on trampoline bounce, reset on timer
		prev_max_velocity = body.max_y_velocity 
		body.max_y_velocity = bounce_limit
		player_ref = body # player reference for timer to adjust max_y_velocity
		$Timer.start()

		# bounce player on trampoline
		var launch_direction = -transform.y # up direction
		var prev_vel = body.prev_velocity.y # player velocity
		body.velocity.y = 0
		body.velocity += launch_direction * (-prev_vel * trampoline_power)
		
		
		# give player more air control
		# body.has_aerial_movement = true
		
		$AnimationPlayer.play("trampoline_bounce")

#Once the timer runs out reapplies max y velocity (jump height) to player
func _on_timer_timeout() -> void:
	print("timeout ==========")
	print(prev_max_velocity)
	player_ref.max_y_velocity = prev_max_velocity
	
