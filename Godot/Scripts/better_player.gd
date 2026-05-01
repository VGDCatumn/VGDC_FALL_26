"""
This implementation of the player utilizes the move_and_collide()
functionality instead of the move_and_slide()
This leads the following advantages and disadvantages:
	ADVANTAGES:
		- The biggest advantage is that we externalize the logic of the
		player on collisions. The most noticeable change is that this
		removes the need for a messy prev_velocity variable.
			- This comes down to the functionality of move_and_slide() vs
			move_and_collide(). 
				- move_and_slide() is a wrapper with an internal
				loop running multiple move_and_collide() functions giving a "slide"
				functionality. This is why after running move_and_slide() velocity was
				being set to zero or near zero.
				- The move_and_slide() moved the player into
				the ground and once it could no longer move_and_set_flags downward it moved the character the rest
				of the delta*velocity distance along the surface. As we are trying to bounce
				the character on collision rather than slide them, this functionality is 
				counterintuitive even though it is difficult to notice. 
				- By using move_and_collide() we move_and_set_flags the player without altering it's
				velocity and use the returned KinematicCollision2D to determine exactly how
				WE want to modify the velocity rather than letting the system assume we want
				to slide / come to a stop. without this assumption we can still know the velocity right before
				movement and use the collision to know if we need to bounce (reflect velocity),
				or if we keep going (do nothing to the velocity). 
					- see logic in handle_floor_bounce()/handle_non_floor_bounce()
		- By externalizing the collision logic we can fix small inconsistencies that stem from
		the systems attempts at sliding.
			- The most notable of these is that when the player would bounce into a non-floor ramp 
			the system assumes we will just want to slide up that ramp leading to a "rolling" up the hill
			rather than "bouncing" up it. By doing this logic ourselves we can know for example how far
			the player should have gone vs how far they went and if these values are far appart we can modify
			the bounce code to project the velocity in a new direction.
				- see handle_clipping() bellow
				- NOTE: this is also possible with move_and_slide() logic, however, because of the sliding
				the character would have already moved it's entire distance along the slope so by redirecting
				the bounce we either need to delay the bounce to the next physics tick or make two motions in
				one tick which could make the movement feel odd. Either of these solutions requires more complicated
				code than bellow while also acting as a bandaid rather than solving the core problem.
		- The final present advantage is that we can more easily affect how the player interacts
		with the world by guarenteeing only one collision per tick and also knowing exactly the exit velocity after
		that tick.
			- see handle_impulse() bellow
			- NOTE: this is also possible with move_and_slide() but again requires more complex logic
			and could act weird with the sliding/multiple-potential-collision functionality.
	DISADVANTEGS:
		- There is one primary disadvantage to this strategy and that is the loss of the move_and_slides() built
		in useful functions that we need to reimplement. These consist of:
			1) is_on_floor() + is_on_wall() + is_on_ceiling():
				move_and_slide() uses the collision normal of the last collision
				in it's loop to set a series of flags internal to the player allowing
				these functions to work. This means when using move_and_collide() we need
				to localize these flags using the KinematicCollision2D returned.
				- See set_flags() bellow
					- NOTE: Our set_flags() is actually much simpler because we don't really
					need to know if it's on the ceiling or the wall. We just need to know if
					it's on something and if that something is the floor. (2 flags instead of 3)
			2) snapping to surface:
				move_and_slide() does internal surface snapping in it's loop after each collision
				move_and_collide() does not
				- NOTE: KinematicCollision2D stores the exact distance of overlap along the collision
				normal so the matter of doing snapping ourselves is as simple as one line: 
				position += collision.get_normal() * collision.get_depth()
					- See snap_to_surface() bellow.
		- In the end the following three variables and two functions must be added:
			collision : KinematicCollision2D
			on_floor : bool
			on_surface : bool
			set_flags()
			snap_to_surface()		
"""

extends CharacterBody2D

var gravity := 1200.0 # Gravity is 2x on a slam down
var max_x_velocity := 1500.0
var max_y_velocity := 2500.0
var min_y_bounce := -100
var cap_velocity := true
var impulse_multiplier := 0.75


var collision: KinematicCollision2D = null # store the last collision
var on_floor := false # custom flag to replace is_on_floor()
var on_surface := false # custom summated flag to replace is_on_wall() is_on_ceiling()

# Define how much velocity is retained after a surface bounce
var floor_bounce_multiplier := 0.50 # this variable is very precise, +/- 0.05
var alt_bounce_multiplier := 0.50

# Auxillary movement variables
var has_wobble_rotation := true
var has_aerial_movement := false
var aerial_velocity_given = 0 # track total change in x velocity from current jump
var start_fall_height := 0.0 # apex height of jump
var end_fall_height := 0.0
var last_fall_height := 0.0
var recovery_fall_threshold = 1000

# Developer Tool Varaibles 
var is_dev_mode_enabled: bool = false
var debugging := true

signal update_stats(position: Vector2, velocity: Vector2, start_fall_height: float, end_fall_height: float) # pass to UI elements
signal send_bounce(velocity: Vector2) # send signal to bounce audio player


func _ready() -> void:
	floor_max_angle = deg_to_rad(45) # same as default
	collision_layer = 1 | (1 << 2)
	collision_mask = 1
	velocity = Vector2.ZERO


func _physics_process(delta: float) -> void:
	# Toggle dev mode if tab is pressed
	if Input.is_action_just_pressed("dev_mode"): is_dev_mode_enabled = !is_dev_mode_enabled
	
	# Apply appropriate movement mode
	if (is_dev_mode_enabled): dev_movement_mode(delta)
	else: regular_movement_mode(delta)

	emit_signal("update_stats", position, velocity, start_fall_height, end_fall_height)
	

# dev tool to move_and_set_flags omnidirectionally
func dev_movement_mode(delta):
	var move_speed = 1000 * delta
	
	# handle WASD movement to move_and_set_flags omnidirectionally
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
	
	if cap_velocity:
		clamp_velocity()
	
	# store the result of move_and_collide to set flags and alter velocity
	move_and_set_flags(delta)

	# if we would stop too soon (e.g. we hit a steep sloop that's not a wall)
	handle_clipping(delta)

	if on_surface: # if we hit something
		if on_floor: # if that something is a floor
			handle_floor_bounce()
		else:
			handle_non_floor_bounce() # combine redundant handle ceiling and handle wall
		handle_impulse() # allow for physics interaction
	else: handle_fall(delta)
	
	calculate_fall_height()
	if debugging: print_bounce_info()
	handle_aerial_movement(delta)


### CUSTOM MOVEMENT FUNCTIONS


func move_and_set_flags(delta):
	# Upward Snap
	snap_to_surface()

	# Move and get collision
	collision = move_and_collide(velocity * delta)

	# Set flags
	if collision:
		on_surface = true
		if collision.get_angle() <= floor_max_angle + 0.01:
			on_floor = true
		else:
			on_floor = false

		# Snap back along collision normal
		var offset = collision.get_normal().normalized() * collision.get_depth()
		if debugging:
			print("\nSNAPPING")
			print("\tOffset:\t", offset)
			print("\tOffset Dist:\t", offset.length())
		position += offset
	else:
		on_floor = false
		on_surface = false


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
	var y_reflected = - abs(velocity.y) * floor_bounce_multiplier
	var y_boost = sin(PI / 2 - rotation) * -400
	var platform_vel = collision.get_collider_velocity()
	# Make sure we bounce at least min_y_bounce + adjust for platform relativity
	velocity.y = min(y_reflected + y_boost, min_y_bounce) + platform_vel.y

	# Add velocity in direction of rotation on a bounce
	# Velocity in the x direction is noticeably greater --> for more horizontal control
	velocity.x += cos(PI / 2 - rotation) * 800
	emit_signal("send_bounce", velocity) # send bounce info to Audio_Bounce node
	$AnimationPlayer.play("bounce_animation") # Play bounce animation
	

func handle_non_floor_bounce():
	#just bounce accross normal
	velocity = velocity.bounce(collision.get_normal()) * alt_bounce_multiplier

	emit_signal("send_bounce", velocity)


func handle_impulse():
	var object = collision.get_collider()
	if object.is_class("RigidBody2D"):
		var obj_global_position = object.get("global_position")
		# reflect velocity to simulate conservation of momentum
		# tricky to emulate because our character technically has infinite momentum
		# var impulse = velocity.bounce(collision.get_normal()) * impulse_multiplier
		var impulse = - velocity * impulse_multiplier
		object.call("apply_impulse", impulse, global_position - obj_global_position)

# use collision normal & depth to snap to surface
func snap_to_surface():
	if on_surface:
		var offset = collision.get_normal().normalized() * collision.get_depth()
		if debugging:
			print("\nSNAPPING")
			print("\tOffset:\t", offset)
			print("\tOffset Dist:\t", offset.length())
		position += offset

# if character couldn't move_and_set_flags we override the bounce angle and move_and_set_flags at an increased angle
func handle_clipping(delta):
	if on_surface and collision.get_travel().length() < 1 and collision.get_remainder().length() > 20:
		var theta = sign(velocity.x) * collision.get_angle() * 0.95
		if debugging:
			print("\nCLIPPING")
			print("\tWanted to go:\t", (velocity * delta).length())
			print("\tWent:\t\t\t", collision.get_travel().length())
			print("\tRemainder:\t\t", collision.get_remainder().length())
			print("\tTheta (deg):\t\t", rad_to_deg(theta))
		var direction = Vector2.UP.rotated(theta)
		velocity = velocity.project(direction)
		if debugging:
			print("\tVelocity:\t\t", velocity)
			print("\tVelocity Angle (deg):\t", rad_to_deg((velocity.angle())))
		move_and_set_flags(delta)


# Print bounce info to output
func print_bounce_info():
	var output
	
	if on_floor:
		output = "\nFLOOR BOUNCE"
		# output += "\n\tTravel:\t" + str(collision.get_travel())
		# output += "\n\tRemainder:\t" + str(collision.get_remainder())
	elif on_surface:
		output = "\nWALL BOUNCE"
	else: return # end function if no bounce occurs
	output += "\n\tVelocity:\t" + str(velocity)
	output += "\n\tWent:\t" + str(collision.get_travel().length())
	output += "\n\tRemainder:\t" + str(collision.get_remainder().length())
	print(output)


# Contrict max player velocity in x and y direction
func clamp_velocity():
	# Clamping velocity.x reduces possibility of "speed ramping" 
	velocity.x = clampf(velocity.x, -max_x_velocity, max_x_velocity)
	# Clamping velocity.y is required for pinball bumpers to work
	velocity.y = clampf(velocity.y, -max_y_velocity, max_y_velocity)


## AERIAL

# WIP -- PRONE TO CHANGE -- VARIABLES NEED TWEAKING
# Give player x-axis velocity based on current rotation
# aerial_velocity_multipler = 0 --> no aerial movement
# aerial_velocity_multipler = 60 --> slight, imperceptible aerial movement
# aerial_velocity_multipler = 1200 --> major aerial movement
func handle_aerial_movement(delta):
	var aerial_velocity_multipler := 60.0 # Give player the slightest amount of aerial_movement
	var aerial_assistance := 0.0 # determines total change in x velocity
	# max amount in either +/- x direction that aerial assistance can give you
	var aerial_velocity_given_max := 1000
	
	# If player falls far enough, they gain aerial movement
	if (end_fall_height - start_fall_height > recovery_fall_threshold): has_aerial_movement = true
	# Give the player major aerial_movement
	if has_aerial_movement: aerial_velocity_multipler *= 20
	# Ensure aerial velocity cap is not met 
	if (abs(aerial_velocity_given) < aerial_velocity_given_max):
		# Calculate change in x velocity based on player's current rotation
		aerial_assistance = cos(PI / 2 - rotation) * aerial_velocity_multipler * delta
		
	velocity.x += aerial_assistance
	aerial_velocity_given += aerial_assistance
	
	if on_floor:
		has_aerial_movement = false # Reset aerial movement qualifier
		aerial_velocity_given = 0 # Reset aerial velocity given counter
	
	# print("Aerial Assistance: " + str(aerial_assistance))
	# print("Aerial Assistance Given: " + str(aerial_velocity_given))

		
# Record fall height variables
# start_fall_height = apex of jump (this gets reset when you hit the floor)
# end_fall_height = current y level
func calculate_fall_height():
	# Store start_fall_height and end_fall_height
	if (position.y < start_fall_height):
		start_fall_height = position.y
	end_fall_height = position.y
	
	# Store last_fall_height on floor bounce
	if on_floor:
		var fall_height = end_fall_height - start_fall_height
		if (fall_height > 0):
			last_fall_height = fall_height
		start_fall_height = position.y # Reset jump height

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
