extends StaticBody2D

@export var trampoline_power := 1.4
@export var bounce_limit := 4000 #max height you can gain from bouncing off trampoline
@export var clamp_timer := 3  #timer in secs before the velocity clamp is reapplied

var	prev_max_velocity	#stores current max_y_velocity set in ball_man
var player_ref: Node2D

@onready var area = $Detecter

 

func _ready() -> void:
	$Timer.wait_time = clamp_timer
	$Timer.one_shot = true 

func _on_detecter_body_entered(body: Node2D) -> void:
	if body.is_in_group("PLAYER"):
		player_ref = body
		
		prev_max_velocity = body.max_y_velocity #stores Player's current max y velocity 

		# gets velocity from player scirpt
		var prev_vel = body.prev_velocity.y
		
		# get launch_direction by taking the UP vector of the spring
		var launch_direction = -transform.y
		
		body.max_y_velocity = bounce_limit
		body.velocity = launch_direction * ((-prev_vel  * 0.8) * trampoline_power)
		
		# give player more air control
		body.has_aerial_movement = true
		
		$Timer.start()
		$AnimationPlayer.play("trampoline_bounce")

#Once the timer runs out reapplies max y velocity (jump height) to player
func _on_timer_timeout() -> void:
	print("timeout ==========")
	print(prev_max_velocity)
	player_ref.max_y_velocity = prev_max_velocity
	
