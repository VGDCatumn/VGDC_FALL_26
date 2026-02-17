extends Node2D

@export var rotateCounterclockwise : bool = true
var bumperSpeed : float = 8
var start_angle : float
var end_angle : float


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
	print("start_angle: " + str(start_angle))
	print("end_angle: " + str(end_angle))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# flipper logic
	if (Input.is_action_pressed("ui_accept")):
		activateBumper(delta)
	else:
		deactivateBumper(delta)

func activateBumper(delta):
	rotation = lerp_angle(rotation, end_angle, delta * bumperSpeed)
	
func deactivateBumper(delta):
	rotation = lerp_angle(rotation, start_angle, delta * bumperSpeed / 2)
	


	

	
