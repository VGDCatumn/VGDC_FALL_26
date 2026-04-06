extends CharacterBody2D

var gravity := 1200.0 # Gravity is 2x on a slam down
var max_x_velocity := 1500.0
var max_y_velocity := 2500.0
var min_y_bounce := 50
var cap_velocity := true

# Define how much velocity is retained after a surface bounce
var floor_bounce_multiplier := 0.50 # this variable is very precise, +/- 0.05
var wall_bounce_multiplier := 0.50
var ceiling_bounce_multiplier := 0.50

# Auxillary movement variables
var has_wobble_rotation := true

# Developer Tool Varaibles 
var is_dev_mode_enabled: bool = false

var last_collision: KinematicCollision2D = null


func _ready() -> void:
	floor_max_angle = deg_to_rad(45) # same as default
	velocity = Vector2.ZERO

func _physics_process(delta: float) -> void:
	# Toggle dev mode if tab is pressed
	if Input.is_action_just_pressed("dev_mode"): is_dev_mode_enabled = !is_dev_mode_enabled
	
	# Apply appropriate movement mode
	if (is_dev_mode_enabled): dev_movement_mode(delta)
	else: regular_movement_mode(delta)
	
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
	
	velocity = Vector2(0, 0) # reset velocity for exiting
	wobble_rotate(delta) # apply rotation, this is cosemetic it doesn't change movement
		

# apply regular player movement 
func regular_movement_mode(delta):
	if (has_wobble_rotation): wobble_rotate(delta) # rotate player with left/right
	else: manual_rotate(delta)
	
	clamp_velocity()

	last_collision = move_and_collide(velocity * delta)

	if last_collision:
		if last_bounce_on_floor():
			handle_floor_bounce()
		else:
			handle_non_floor_bounce()
	else: handle_fall(delta)
	
	print_bounce_info() # debugging tool to print bounce stats

### CUSTOM MOVEMENT FUNCTIONS

func last_bounce_on_floor():
	return last_collision.get_angle() <= floor_max_angle + 0.01

# Handles logic to apply velocity in the positive y direction (downwards)
# Called every frame that that player is not colliding with a surface
func handle_fall(delta):
	# Increase velocity towards ground if not on floor
	velocity.y += gravity * delta

	# Slam down only when ball is already falling and user presses down
	if velocity.y >= 0 and Input.is_action_pressed("move_down"):
		slam_down(delta)

# Increase downwards velocity when holding down 
func slam_down(delta):
	# Double the gravity applied to the ball 
	velocity.y += 2 * gravity * delta
	
# Handle ball physics on ground collisions
func handle_floor_bounce():
	velocity.y = - abs(velocity.y) * floor_bounce_multiplier + last_collision.get_collider_velocity().y
	
	# Add velocity in direction of rotation on a bounce
	# Velocity in the x direction is noticeably greater --> for more horizontal control
	velocity.x += cos(PI / 2 - rotation) * 800
	velocity.y += sin(PI / 2 - rotation) * -400

	emit_signal("send_bounce", velocity) # send bounce info to Audio_Bounce node
	$AnimationPlayer.play("bounce_animation") # Play bounce animation
	
func handle_non_floor_bounce():
	velocity = velocity.bounce(last_collision.get_normal()) * wall_bounce_multiplier
	emit_signal("send_bounce", velocity)

# Print bounce info to output
func print_bounce_info():
	var output
	if last_collision:
		if last_bounce_on_floor():
			output = "\nFLOOR BOUNCE"
		else:
			output = "\nWALL BOUNCE"
	else: return # end function if no bounce occurs
	output += "\n\tVelocity: " + str(velocity)
	print(output)

# Contrict max player velocity in x and y direction
func clamp_velocity():
	# Clamping velocity.x reduces possibility of "speed ramping" 
	velocity.x = clampf(velocity.x, -max_x_velocity, max_x_velocity)
	# Clamping velocity.y is required for pinball bumpers to work
	velocity.y = clampf(velocity.y, -max_y_velocity, max_y_velocity)

### ROTATION FUNCTIONS

# Manual rotation, use left/right to tilt player
func manual_rotate(delta):
	if Input.is_action_pressed("move_right"): rotate(1 * delta)
	elif Input.is_action_pressed("move_left"): rotate(-1 * delta)
	manual_rotate_sound(delta) # play audio when manual rotating

# Play concrete_sliding audio when player is rotating manually
# Volume level starts as 0, increases the longer you turn  
func manual_rotate_sound(delta):
	var vol_increase_rate = 0.8; # 0.5 means increase volume by 50% each second
	
	if Input.is_action_just_pressed("move_right") or Input.is_action_just_pressed("move_left"):
		$Audio_Concrete.play()
		$Audio_Concrete.set_volume_linear(0);
		
	if Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left"):
		var volume = $Audio_Concrete.get_volume_linear()
		volume += vol_increase_rate * delta
		volume = clampf(volume, 0, 1.5) # cap volume to be 0% to 150%
		$Audio_Concrete.set_volume_linear(volume)

	else: # no input actions, aka no rotation
		$Audio_Concrete.stop() # stop concrete_sliding audio when player doesn't turn
		$Audio_Concrete.set_volume_linear(0)
	

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
		# $Audio_Ow.play() # TURN OFF FOR DEMO
		pass
