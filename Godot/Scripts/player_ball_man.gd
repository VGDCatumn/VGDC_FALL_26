extends CharacterBody2D

var prev_velocity : Vector2
var gravity := 1200.0			# Gravity is 2x on a slam down
var max_x_velocity := 1500.0
var max_y_velocity := 2500.0

# Define how much velocity is retained after a surface bounce
var floor_bounce_multiplier := 0.45 # this variable is very precise, +/- 0.05
var wall_bounce_multiplier := 0.50
var ceiling_bounce_multiplier := 0.15

# Auxillary movement variables
var has_wobble_rotation := true
var has_recovery_bounce := false
var has_aerial_movement := false
var aerial_velocity_given = 0 # track total change in x velocity from current jump
var start_fall_height := 0.0 # apex height of jump
var end_fall_height := 0.0
var last_fall_height := 0.0
var recovery_fall_threshold = 1000

# Developer Tool Varaibles 
var is_dev_mode_enabled : bool = false
signal update_stats (position: Vector2, velocity : Vector2, start_fall_height : float, end_fall_height : float) # pass to UI elements
signal send_velocity_vector (position : Vector2, velocity : Vector2) # send signal to directional arrow node
signal send_bounce (velocity : Vector2) # send signal to bounce audio player

func _physics_process(delta: float) -> void:
	# Toggle dev mode
	if Input.is_action_just_pressed("dev_mode"): is_dev_mode_enabled = !is_dev_mode_enabled
	
	# Apply appropriate movement mode
	if (is_dev_mode_enabled): dev_movement_mode(delta)
	else: regular_movement_mode(delta)
	
	draw_vector_arrow()
	draw_trail()
	emit_signal("update_stats", position, velocity, start_fall_height, end_fall_height) # send player stats to display on UI 

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

	# Draw an arrow from the player in the direction of velocity
func draw_vector_arrow():
	send_velocity_vector.emit(position, velocity)

# Draw a trail in world using player position
func draw_trail():
	# Retrieve reference to the Line2D node, which should be a child of the current level
	var trail = get_parent().get_node("Line2D") 
	if (trail == null): return # prevents error when scene does not contain trail
	var max_trail_points = 40 # Determine length of trail
	
	# Add new position to trail only when player has aerial movement
	if (has_aerial_movement): trail.add_point(position) 
	
	# Remove old points from trail (this is not frame independent)
	if trail.get_point_count() > max_trail_points or (!has_aerial_movement and trail.get_point_count() > 0): 
		trail.remove_point(0)

# apply regular player movement 
func regular_movement_mode(delta):
	if (has_wobble_rotation): wobble_rotate(delta) # rotate player with left/right
	else: manual_rotate(delta)
		
	prev_velocity = velocity # store previous velocity because collisions set velocity = 0
	clamp_velocity()
	move_and_slide() # Move character with built-in Godot collisions

	# Determine bounce category based off built-in Godot collision functions
	if is_on_floor(): handle_floor_bounce() # bounce ball upwards and apply velocity based on rotation angle
	if is_on_wall(): handle_wall_bounce() # handle bounce collisions with wall
	if is_on_ceiling(): handle_ceiling_bounce() # handle bounce collision with ceiling
	else: handle_fall(delta) # apply gravity and handle slam down
	
	# Give player horizontal movement at all times based on rotation
	handle_aerial_movement(delta)
	# Give player an opportunity to shoot up if they fall down a great distance
	# has_recovery_bounce is set in handle_fall
	if (has_recovery_bounce): handle_recovery_bounce()

### CUSTOM MOVEMENT FUNCTIONS

# Handles logic to apply velocity in the positive y direction (downwards)
func handle_fall(delta):
	# Increase velocity towards ground if not on floor
	velocity.y += gravity * delta
	
	# Slam down only when ball is already falling and user presses down
	if velocity.y >= 0 and Input.is_action_pressed("move_down"):
		slam_down(delta)
	
	# Record fall height variables
	if (position.y < start_fall_height):
		# store the hightest position (the apex) during a jump in start_fall_height
		start_fall_height = position.y
	end_fall_height = position.y 

# Increase downwards velocity when holding down 
func slam_down(delta):
	# Double the gravity applied to the ball 
	velocity.y += gravity * delta
	
	# increment the y down velocity of prev_velocity
	# this does not change any player velocity
	# it boosts the power of a bounce when slam_down is held
	prev_velocity = velocity + Vector2(0,100)
	
	# Play stretch animation
	if $AnimationPlayer.assigned_animation != "stretch":
		$AnimationPlayer.play("stretch")
	
# Handle ball physics on ground collisions
func handle_floor_bounce():	
	# Adjust x velocity based on floor normal
	# This fixes "speed ramping" but makes horizontal movement feel really bad
	# Leave this commented for future reference - Ben
	var floor_normal = get_floor_normal()
	velocity = prev_velocity.bounce(floor_normal) * floor_bounce_multiplier
	
	# Bounce player up (negative y), based on their speed right before the bounce
	# velocity.y += -abs(prev_velocity.y) * floor_bounce_multiplier
	
	# Add velocity in direction of rotation on a bounce
	# Velocity in the x direction is noticeably greater --> for more horizontal control
	velocity.x += cos(PI/2 - rotation) * 800
	velocity.y += sin(PI/2 - rotation) * -400
	
	# Store height of last fall
	var fall_height = end_fall_height - start_fall_height
	if (fall_height > 0): 
		last_fall_height = fall_height 
	start_fall_height = position.y # Reset jump height for auxillary functions
	
	has_aerial_movement = false # Reset aerial movement qualifier
	aerial_velocity_given = 0 # Reset aerial velocity given counter
	
	if (Input.is_action_pressed("move_down") and last_fall_height > recovery_fall_threshold): 
		has_recovery_bounce = true
	else:
		emit_signal("send_bounce", velocity) # send bounce info to Audio_Bounce node
	
	$AnimationPlayer.play("bounce_animation") # Play bounce animation
	print("Bouncing on floor")
	

func handle_wall_bounce():	
	# Invert x velocity to bounce away from wall
	# THIS IS STILL PRONE TO BUGS / NOT ENOUGH VELOCITY IN OPPOSITE DIRECITON - Ben 
	var wall_collision = get_last_slide_collision()
	var normal = wall_collision.get_normal()
	velocity = prev_velocity.bounce(normal) * wall_bounce_multiplier
	
	# Play animation based on what direction you bounce towards
	if(velocity.x > 0):
		# $AnimationPlayer.play("wall_bounce_animation_right")
		pass
	else:
		# $AnimationPlayer.play("wall_bounce_animation_left")
		pass
	
	emit_signal("send_bounce", velocity)
	print("Bouncing on wall")

func handle_ceiling_bounce():
	#Causes y velocity to reverse when hitting a ceiling, then reduces by the constant
	# velocity.y = -prev_velocity.y * ceiling_bounce_multiplier
	
	var collision = get_last_slide_collision()
	var normal = collision.get_normal()
	velocity = prev_velocity.bounce(normal) * ceiling_bounce_multiplier
	
	$AnimationPlayer.play("Ceiling_animation") # Plays ball bounce animation
	
	emit_signal("send_bounce", velocity)
	print("Bouncing on ceiling")

# Contrict max player velocity in x and y direction
func clamp_velocity():
	# Clamping velocity.x reduces possibility of "speed ramping" 
	velocity.x = clampf(velocity.x, -max_x_velocity, max_x_velocity)
	# Clamping velocity.y is required for pinball bumpers to work
	velocity.y = clampf(velocity.y, -max_y_velocity, max_y_velocity)

# WIP -- PRONE TO CHANGE -- VARIABLES NEED TWEAKING
# Apply velocity to the player on the x axis based on current rotation
# aerial_velocity_multipler = 0 --> no aerial movement
# aerial_velocity_multipler = 60 --> slight, imperceptible aerial movement
# aerial_velocity_multipler = 1200 --> major aerial movement
func handle_aerial_movement(delta):
	var aerial_velocity_multipler := 60.0 # Give player the slightest amount of aerial_movement
	var aerial_assistance := 0.0 # determines total change in x velocity
	# max amount in either +/- x direction that aerial assistance can give you
	var aerial_velocity_given_max := 300 
	
	# If player falls far enough, they gain aerial movement
	if (end_fall_height - start_fall_height > recovery_fall_threshold): has_aerial_movement = true
	# Give the player major aerial_movement
	if has_aerial_movement: aerial_velocity_multipler *= 20 
	# Ensure aerial velocity cap is not met 
	if (abs(aerial_velocity_given) < aerial_velocity_given_max):
		# Calculate change in x velocity based on player's current rotation
		aerial_assistance = cos(PI/2 - rotation) * aerial_velocity_multipler * delta
		
	velocity.x += aerial_assistance
	aerial_velocity_given += aerial_assistance
	
	# print("Aerial Assistance: " + str(aerial_assistance))
	# print("Aerial Assistance Given: " + str(aerial_velocity_given))
	
func handle_recovery_bounce():
	has_wobble_rotation = false
	velocity = Vector2.ZERO
	if (Input.is_action_just_released("move_down")):
		var launch_direction = -transform.y
		velocity = launch_direction * last_fall_height

		# Revert to normal movement
		has_wobble_rotation = true
		has_recovery_bounce = false
		$Audio_Concrete.stop()

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
	
	if Input.is_action_just_pressed("move_right") or Input.is_action_just_pressed("move_left") :
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
