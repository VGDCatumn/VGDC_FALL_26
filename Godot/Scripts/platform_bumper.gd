extends Node2D

@export var rotateCounterclockwise : bool = true
var bumperSpeed : float = 8
var start_angle : float
var end_angle : float
var height : float
var rotational_velocity := 0
var swinging := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_angle = rotation
	
	if (rotateCounterclockwise):
		# end angle for left side bumper
		end_angle = start_angle - (PI * 1/3) # rotate counter clockwise 60 degrees
	else: 
		# end angle for right side bumper
		end_angle = start_angle + (PI * 1/3) # rotate clockwise 60 degrees

	print("Name: " + self.name)
	print("start_angle: " + str(rad_to_deg(start_angle)))
	print("end_angle: " + str(rad_to_deg(end_angle)))
	height = $StaticBody2D/CollisionShape2D.shape.radius

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# bumper logic
	if (Input.is_action_pressed("ui_accept")):
		activateBumper(delta)
		swinging = true
	else:
		deactivateBumper(delta)
		swinging = false

func activateBumper(delta):
	var old_rotation = rotation
	rotation = lerp_angle(rotation, end_angle, delta * bumperSpeed)
	rotational_velocity = (rotation - old_rotation) / delta
	
func deactivateBumper(delta):
	var old_rotation = rotation
	rotation = lerp_angle(rotation, start_angle, delta * bumperSpeed / 2)
	rotational_velocity = (rotation - old_rotation) / delta

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("PLAYER") and swinging:
		print("IN")
		print(str(body.velocity))
		print("REMOVING CAP")
		body.cap_velocity = false
		print("RV ", rotational_velocity)

		var angle_vector = Vector2(1,0).rotated(rotation) 
		var local_offset = body.global_position - self.global_position
		var projected_radius = angle_vector.dot(local_offset) * angle_vector
		var velocity_offset = Vector2(-rotational_velocity*projected_radius.y, rotational_velocity*projected_radius.x + 100)


		body.velocity = velocity_offset
		

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("PLAYER"):
		print("OUT")
		print("Success" if not body.cap_velocity else "FAIL")
		print(str(body.velocity))
