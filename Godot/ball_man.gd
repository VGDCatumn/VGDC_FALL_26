extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var prev_velocity : Vector2


var gravity := 1200.0
var slam_force := 50.0        # Extra downward push when pressing down
var bounce_multiplier := 0.85   # Energy retained on bounce
var max_fall_speed := 2500.0
var max_bounce_speed := 100.0
var total_velocity := 0
var bounce_count := 0
var press_shift := false


func _physics_process(delta: float) -> void:
	
	# Add the gravity.
	
	if not is_on_floor():
		velocity.y += gravity * delta
		
		if velocity.y >= 0 and Input.is_action_pressed("ui_down") and bounce_count < 3:
			velocity.y += slam_force * delta
			total_velocity = velocity.y
		velocity.y = min(velocity.y, max_fall_speed)
		
		print(total_velocity)
		 

	else:
		$AnimationPlayer.play("bounce_animation")
		#Bounce effect
		if Input.is_action_pressed("ui_down") and bounce_count < 3 and !Input.is_key_pressed(KEY_SHIFT):
			velocity.y = -min(abs(total_velocity) * bounce_multiplier, max_bounce_speed)
			bounce_count += 1
			
		else:
			#If down is not pressed then bounce is reduced by 0.85 pre bSounce
			velocity.y = -abs(total_velocity) * 0.6
			bounce_count = 0
		
		
		#Resets velocity.y if it gets too low to the ground
		if !Input.is_key_pressed(KEY_SHIFT):
			if total_velocity < 400:
				total_velocity = 400
			else:
				total_velocity = min(400, velocity.y)
			
			
		velocity += Vector2(cos(deg_to_rad(90 - rotation_degrees)) * 200, 
		sin(deg_to_rad(90 - rotation_degrees)) * -400)
		print(velocity.y)
				
	if is_on_wall():
		velocity.x = -prev_velocity.x
	if is_on_ceiling():
		velocity.y = -prev_velocity.y
	# Handle jump
	
	if Input.is_action_pressed("ui_right"):
		rotate(1 * delta)
	elif Input.is_action_pressed("ui_left"):
		rotate(-1 * delta)
	
	if velocity.x != 0:
		prev_velocity.x = velocity.x
	if velocity.y != 0:
		prev_velocity.y = velocity.y

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	

	 # Move character
	move_and_slide()
	
