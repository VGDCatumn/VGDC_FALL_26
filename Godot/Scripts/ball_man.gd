extends CharacterBody2D



var prev_velocity : Vector2
var gravity := 1200.0			# Gravity is 2x on a slam down
var bounce_multiplier := 0.85   	# Energy retained on bounce
var max_fall_speed := 2500.0 

# Variables created by Ben
var wall_bounce_multiplier = 0.5			# force to multiply by when collidiing with walls and ceiling 
var ceiling_bounce_multiplier = 0.25


func _physics_process(delta: float) -> void:
	
	# clamps X Velocity
	clamp_x_speed()
	
	if is_on_ceiling():
		# handle bounce collision with ceiling
		handle_ceiling_bounce(ceiling_bounce_multiplier)
		
	if is_on_wall():
		# handle bounce collisions with wall and ceiling
		handle_wall_bounce(wall_bounce_multiplier)
	
	if not is_on_floor():
		handle_fall(delta) # apply gravity and handle slam down
		#print("Not on ground")

		
	else:
		handle_floor_bounce() # bounce ball upwards and apply velocity based on rotation angle
		#print("I am on ground")
	
	# rotate player with left/right
	wobble_rotate(delta)

	 # Move character
	move_and_slide()
	
	

### CUSTOM MOVEMENT FUNCTIONS
func handle_fall(delta):
	#print("IS FALLING")
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
	prev_velocity.y = velocity.y
	
# Handle ball physics on ground collisions
func handle_floor_bounce():
	# Play bounce animation
	$AnimationPlayer.play("bounce_animation")
	$Boing.play()
	# Bounce player off the ground, based on their current speed
	velocity.y = -abs(prev_velocity.y) * 0.45
	
	# Cap upwards velocity to 500
	prev_velocity.y = min(velocity.y, 500)
		
	# Add velocity in direction of rotation, during a bounce
	# Velocity in the x direction is noticeably greater
	# --> this allows for more horizontal control
	# Added a min bounce cap rotation bounces, so if
	# you're facing sideways you don't gain infite momentum -Nick
	velocity.x += cos(PI/2 - rotation) * 800
	velocity.y += min(-300, sin(PI/2 - rotation) * -400)
	
	#records the velocity after a bounce
	prev_velocity = velocity
	
# Makes sure X speed is within bound
# Make to stop high velocity glitch
# But there might be a better way to solve it -Nick
func clamp_x_speed():
	#Bounds the speed of vertical bounds to be between the constants - Nick
	velocity.x = clamp(velocity.x, -1500, 1500)

# Handle bounces off walls 
# Edited make the ceiling bounce its own function - Nick
func handle_wall_bounce(ceiling_bounce_multiplier):
	# Record prev_velocity before a collision.
	# When collision occurs, engine sets velocity in that direction = 0
	# Manually set the velocity in the opposite direction with the prev_velocity
	
	# Sets X velocity that of previous collision
	# There were random cases where it velocity wasn't save
	# This aims to fix that - Nick
	velocity.x = prev_velocity.x
	
	#Causes x velocity to reverse when hitting a wall, then reduces by the constant
	velocity.x = -prev_velocity.x * wall_bounce_multiplier


# Handles bounces off the ceiling 
# There was talk off a head bonk mechanic idk if we're still doing that - Nick
func handle_ceiling_bounce(wall_bounce_multiplier):
	
	# Sets Y velocity that of previous collision
	velocity.y = prev_velocity.y
	
	# Plays ball bounce animation, but bounces on wrong side
	# needs to change to unqine animation
	$AnimationPlayer.play("Ceiling_animation")
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
# #Updated changed the end_angle_right/left from 1/2 to .4 (decreases how much play can tilt) - Nick
func wobble_rotate(delta):
	var start_angle = 0
	var end_angle_right = PI * .35
	var end_angle_left = PI * -.35
	
	if Input.is_action_pressed("ui_right"):
		rotation = lerp_angle(rotation, end_angle_right, delta * 2)
	elif Input.is_action_pressed("ui_left"):
		rotation = lerp_angle(rotation, end_angle_left, delta * 2)
	else:
		rotation = lerp_angle(rotation, start_angle, delta * 1)
	

# man enters collision 
func _on_person_body_entered(body: Node2D) -> void:
	
	
	# play ow audio
	if body.is_in_group("Physical"):
		$Ow.play()
