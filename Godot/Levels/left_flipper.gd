extends StaticBody2D

var flipperSpeed = 8
var start_angle
var end_angle


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_angle = rotation
	end_angle = start_angle - (PI * 3/6)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	if (Input.is_action_pressed("ui_accept")):
		activateFlipper(delta)
	else:
		deactivateFlipper(delta)
		

func activateFlipper(delta):
	rotation = lerp_angle(rotation, end_angle, delta * flipperSpeed)
	
func deactivateFlipper(delta):
	rotation = lerp_angle(rotation, start_angle, delta * flipperSpeed / 2)
