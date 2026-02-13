extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var prev_velocity : Vector2


var gravity := 1200.0			# Gravity is 2x on a slam down
var bounce_multiplier := 0.85   	# Energy retained on bounce
var max_fall_speed := 2500.0 
var max_bounce_speed := 100.0
var total_velocity := 0
var press_shift := false

# Variables created by Ben
var wall_bounce_multiplier = 0.7			# force to multiply by when collidiing with walls and ceiling 


func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		handle_fall(delta) # apply gravity and handle slam down

	else:
		handle_floor_bounce() # bounce ball upwards and apply velocity based on rotation angle
		
	# handle bounce collisions with wall and ceiling
	handle_wall_bounce(wall_bounce_multiplier)

	# rotate player with left/right
	wobble_rotate(delta)

	 # Move character
	move_and_slide()
	

### CUSTOM MOVEMENT FUNCTIONS
func handle_fall(delta):
	# increase velocity towards ground if not on floor
	velocity.y += gravity * delta
	
	# slam down only when ball is already falling and user presses down
	if velocity.y >= 0 and Input.is_action_pressed("ui_down"):
		slam_down(delta)
	
	# cap the max velocity in downwards y direction
	# This should be looked at some more -- Ben
	velocity.y = min(velocity.y, max_fall_speed)

# Increase downwards velocity when holding down 
func slam_down(delta):
	# play stretch animation
	if $AnimationPlayer.assigned_animation != "stretch":
		$AnimationPlayer.play("stretch")
	
	# double the gravity applied to the ball 
	velocity.y += gravity * delta
	
	# I'm not sure what this line does -- Ben
	# It seems to give the ball more bouncing power
	total_velocity = velocity.y 
	
# Handle ball physics on ground collisions
func handle_floor_bounce():
	# Play bounce animation
	$AnimationPlayer.play("bounce_animation")
	$Boing.play()
	# Bounce player off the ground, based on their current speed
	velocity.y = -abs(total_velocity) * 0.45
	
	# Cap upwards velocity to 500
	total_velocity = min(velocity.y, 500)
		
	# Add velocity in direction of rotation, during a bounce
	# Velocity in the x direction is noticeably greater
	# --> this allows for more horizontal control
	velocity.x += cos(PI/2 - rotation) * 800
	velocity.y += sin(PI/2 - rotation) * -400

# Handle bounces off walls and ceiling
func handle_wall_bounce(wall_bounce_multiplier):
	# Record prev_velocity before a collision.
	# When collision occurs, engine sets velocity in that direction = 0
	# Manually set the velocity in the opposite direction with the prev_velocity
	
	if velocity.x != 0:
		prev_velocity.x = velocity.x
	if velocity.y != 0:
		prev_velocity.y = velocity.y
	
	if is_on_wall():
		#Causes x velocity to reverse when hitting a wall, then reduces by the constant
		velocity.x = -prev_velocity.x * wall_bounce_multiplier
	if is_on_ceiling():
		#Causes y velocity to reverse when hitting a ceiling, then reduces by the constant
		velocity.y = -prev_velocity.y * wall_bounce_multiplier
		
# Manual rotation, use left/right to tilt player
func manual_rotate(delta):
	if Input.is_action_pressed("ui_right"):
		rotate(1 * delta)
	elif Input.is_action_pressed("ui_left"):
		rotate(-1 * delta)
	
	# play audio when manual rotating
	manual_rotate_sound(delta) 
	
func manual_rotate_sound(delta):
	# Play concrete_sliding audio only when player starts rotating
	# Volume level starts as 0, increases the longer you turn  
	
	var vol_increase_rate = 0.8; # 0.5 means increase volume by 50% each second 
	
	if Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("ui_left") :
		$AudioStreamPlayer2D.play()
		$AudioStreamPlayer2D.set_volume_linear(0);
		
	if Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_left"):
		var volume = $AudioStreamPlayer2D.get_volume_linear()
		volume += vol_increase_rate * delta
		volume = clampf(volume, 0, 1.5) # cap volume to be 0% to 150%
		$AudioStreamPlayer2D.set_volume_linear(volume)

	else: # no input actions, aka no rotation
		$AudioStreamPlayer2D.stop() # stop concrete_sliding audio when player doesn't turn
		$AudioStreamPlayer2D.set_volume_linear(0)
	

# Rotation replacement by Ben
# Player rotation will return to upright rotation if left/right direction are not held down
# The maximum amount of rotation is end_angle_right, and end_angle_left
# if these end angles go beyond PI/2, you might have the player rotate upsidedown 
func wobble_rotate(delta):
	var start_angle = 0
	var end_angle_right = PI * 1/2
	var end_angle_left = PI * -1/2
	
	if Input.is_action_pressed("ui_right"):
		rotation = lerp_angle(rotation, end_angle_right, delta * 2)
	elif Input.is_action_pressed("ui_left"):
		rotation = lerp_angle(rotation, end_angle_left, delta * 2)
	else:
		rotation = lerp_angle(rotation, start_angle, delta * 1)
	


func _on_person_body_entered(body: Node2D) -> void:
	if body.is_in_group("Physical"):
		$Ow.play()
