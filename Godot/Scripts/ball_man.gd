extends CharacterBody2D

var prev_velocity : Vector2
var gravity := 1200.0			# Gravity is 2x on a slam down
var max_x_velocity := 1500.0
var max_y_velocity := 2500.0

# Define how much velocity is retained after a surface bounce
var floor_bounce_multiplier := 0.45 # this variable is very precise, +/- 0.05
var wall_bounce_multiplier := 0.50
var ceiling_bounce_multiplier := 0.15

# Developer Tool Varaibles 
var is_dev_mode_enabled : bool = false
signal send_velocity_vector (position : Vector2, velocity : Vector2) # send signal to directional arrow node
signal send_bounce (velocity : Vector2) # send signal to bounce audio player

func _physics_process(delta: float) -> void:
	# toggle dev mode
	if Input.is_action_just_pressed("dev_mode"):
		is_dev_mode_enabled = !is_dev_mode_enabled
		print("Developer Mode toggled")
	
	if (is_dev_mode_enabled):
		dev_movement_mode(delta)
	else:
		regular_movement_mode(delta)
		
	# for testing, this stays on always. 
	# eventually add way to toggle arrow later
	display_vector_arrow()

# dev tool to move omnidirectionally
func dev_movement_mode(delta):
	var move_speed = 1000 * delta
	
	# handle WASD movement to move omnidirectionally
	if Input.is_action_pressed("move_up"):
		position.y -= move_speed
	if Input.is_action_pressed("move_down"):
		position.y += move_speed
	if Input.is_action_pressed("move_left"):
		position.x -= move_speed
	if Input.is_action_pressed("move_right"):
		position.x += move_speed
	
	velocity = Vector2(0,0) # reset velocity for exiting 
	prev_velocity = Vector2(0,0)
	$AnimationPlayer.stop() # stop any animations
	wobble_rotate(delta) # apply rotation, this is cosemetic it doesn't change movement

func display_vector_arrow():
	send_velocity_vector.emit(position, velocity)

# apply regular player movement 
func regular_movement_mode(delta):
	wobble_rotate(delta) # rotate player with left/right
	prev_velocity = velocity # store previous velocity because collisions set velocity = 0
	move_and_slide() # Move character with built-in Godot collisions

	# Determine bounce category based off built-in Godot collision functions
	if is_on_floor(): handle_floor_bounce() # bounce ball upwards and apply velocity based on rotation angle
	if is_on_wall(): handle_wall_bounce() # handle bounce collisions with wall
	if is_on_ceiling(): handle_ceiling_bounce() # handle bounce collision with ceiling
	else: handle_fall(delta) # apply gravity and handle slam down
	
	clamp_velocity()

### CUSTOM MOVEMENT FUNCTIONS

# Handles logic to apply velocity in the positive y direction (downwards)
func handle_fall(delta):
	# increase velocity towards ground if not on floor
	velocity.y += gravity * delta
	
	# slam down only when ball is already falling and user presses down
	if velocity.y >= 0 and Input.is_action_pressed("move_down"):
		slam_down(delta)

# Increase downwards velocity when holding down 
func slam_down(delta):
	# Double the gravity applied to the ball 
	velocity.y += gravity * delta
	
	# Play stretch animation
	if $AnimationPlayer.assigned_animation != "stretch":
		$AnimationPlayer.play("stretch")
	
# Handle ball physics on ground collisions
func handle_floor_bounce():	
	# Adjust x velocity based on floor normal
	# This fixes "speed ramping" but makes horizontal movement feel really bad
	# Leave this commented for future reference - Ben
	# var floor_normal = get_floor_normal()
	# velocity.x = velocity.reflect(floor_normal).normalized().x
	
	# Bounce player up (negative y), based on their speed right before the bounce
	velocity.y += -abs(prev_velocity.y) * floor_bounce_multiplier
	
	# Add velocity in direction of rotation on a bounce
	# Velocity in the x direction is noticeably greater --> for more horizontal control
	velocity.x += cos(PI/2 - rotation) * 800
	velocity.y += sin(PI/2 - rotation) * -400
	
	# Play bounce animation
	$AnimationPlayer.play("bounce_animation")
	
	print("Bouncing on floor")

func handle_wall_bounce():	
	# Invert x velocity to bounce away from wall
	# THIS IS STILL PRONE TO BUGS / NOT ENOUGH VELOCITY IN OPPOSITE DIRECITON - Ben 
	velocity.x = -prev_velocity.x * wall_bounce_multiplier
	
	# Play animation based on what direction you bounce towards
	if(velocity.x > 0):
		$AnimationPlayer.play("wall_bounce_animation_right")
	else:
		$AnimationPlayer.play("wall_bounce_animation_left")
	
	print("Bouncing on wall")

func handle_ceiling_bounce():
	#Causes y velocity to reverse when hitting a ceiling, then reduces by the constant
	velocity.y = -prev_velocity.y * ceiling_bounce_multiplier
	
	$AnimationPlayer.play("Ceiling_animation") # Plays ball bounce animation
	
	print("Bouncing on ceiling")
	
func clamp_velocity():
	# Clamping velocity.x reduces possibility of "speed ramping" 
	velocity.x = clampf(velocity.x, -max_x_velocity, max_x_velocity)
	# Clamping velocity.y is required for pinball bumpers to work
	velocity.y = clampf(velocity.y, -max_y_velocity, max_y_velocity)

### ROTATION FUNCTIONS

# Manual rotation, use left/right to tilt player
func manual_rotate(delta):
	if Input.is_action_pressed("move_right"):
		rotate(1 * delta)
	elif Input.is_action_pressed("move_left"):
		rotate(-1 * delta)
	
	# play audio when manual rotating
	manual_rotate_sound(delta) 
	
func manual_rotate_sound(delta):
	# Play concrete_sliding audio only when player starts rotating
	# Volume level starts as 0, increases the longer you turn  
	
	var vol_increase_rate = 0.8; # 0.5 means increase volume by 50% each second 
	
	if Input.is_action_just_pressed("move_right") or Input.is_action_just_pressed("ui_left") :
		$AudioStreamPlayer2D.play()
		$AudioStreamPlayer2D.set_volume_linear(0);
		
	if Input.is_action_pressed("move_right") or Input.is_action_pressed("ui_left"):
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
	
	if Input.is_action_pressed("move_right"):
		rotation = lerp_angle(rotation, end_angle_right, delta * 2)
	elif Input.is_action_pressed("move_left"):
		rotation = lerp_angle(rotation, end_angle_left, delta * 2)
	else:
		rotation = lerp_angle(rotation, start_angle, delta * 1)

### MISCELLANEOUS FUNCTIONS

# man enters collision 
func _on_person_body_entered(body: Node2D) -> void:
	# play ow audio
	if body.is_in_group("Physical"):
		# $Ow.play() TURN OFF FOR DEMO
		pass
