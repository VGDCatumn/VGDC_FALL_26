extends StaticBody2D

var torque := 0.0
@export var damping := 0.0
@export var rotation_mult := 1.0

# Called when the node enters the scene tree for the first time.S
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	rotate(torque * delta)
	rotation_degrees = clampf(rotation_degrees, -35, 35)
	if rotation_degrees == 35 or rotation_degrees == -35:
		torque = 0
		
	print(torque)
	torque = move_toward(torque, 0, damping * delta)
	# print("total", torque * delta)
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("PLAYER"):
		var radius = -(body.position - position).length()
		
		torque += (radius * (body.velocity).length()) * (0.000007 * rotation_mult)
		


func _on_left_body_entered(body: Node2D) -> void:
	if body.is_in_group("PLAYER"):
		var radius = (body.position - position).length()
		
		torque += (radius * (body.prev_velocity).length()) * (0.000007 * rotation_mult)
