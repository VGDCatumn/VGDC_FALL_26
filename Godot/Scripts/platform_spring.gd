extends Area2D

@export var spring_power := 1800
@export var clamp_timer := 3  #timer in secs before the velocity clamp is reapplied

var	prev_max_velocity	#stores current max_y_velocity set in ball_man
var player_ref: Node2D 

func _ready() -> void:
	$Timer.wait_time = clamp_timer
	$Timer.one_shot = true
	
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("PLAYER"):
		player_ref = body
		
		$AnimationPlayer.play("boing")
		$AudioStreamPlayer.play()
		
		prev_max_velocity = body.max_y_velocity #stores Player's current max y velocity 
		body.max_y_velocity = spring_power
		
		
		# get launch_direction by taking the UP vector of the spring
		var launch_direction = -transform.y
		body.velocity = launch_direction * spring_power
		
		# give player more air control
		body.has_aerial_movement = true
		$Timer.start()

#Once the timer runs out reapplies max y velocity (jump height) to player
func _on_timer_timeout() -> void:
	player_ref.max_y_velocity = prev_max_velocity
