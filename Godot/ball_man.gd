extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		
		velocity += Vector2(cos(deg_to_rad(90 - rotation_degrees)) * 200, 
		sin(deg_to_rad(90 - rotation_degrees)) * -400)
		print(velocity.y)
	# Handle jump
	
	if Input.is_action_pressed("ui_right"):
		rotate(1 * delta)
	elif Input.is_action_pressed("ui_left"):
		rotate(-1 * delta)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	

	move_and_slide()
