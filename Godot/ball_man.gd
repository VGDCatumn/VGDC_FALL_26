extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var prev_velocity : Vector2


func _physics_process(delta: float) -> void:
	# Add the gravity.
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	else:
		
		velocity += Vector2(cos(deg_to_rad(90 - rotation_degrees)) * 200, 
		sin(deg_to_rad(90 - rotation_degrees)) * -400)
	
	if is_on_wall():
		velocity.x = - prev_velocity.x
	if is_on_ceiling():
		velocity.y = - prev_velocity.y
	# Handle jump
	
	if Input.is_action_pressed("ui_right"):
		rotate(1 * delta)
	elif Input.is_action_pressed("ui_left"):
		rotate(-1 * delta)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if velocity.x != 0 and velocity.y != 0:
		prev_velocity = velocity
	move_and_slide()
	
