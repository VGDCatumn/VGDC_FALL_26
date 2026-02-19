extends StaticBody2D

var torque := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	rotate(torque * delta)
	# print("total", torque * delta)
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("PLAYER"):
		var radius = -(body.position - position).length()
		print("right:", (radius * (body.velocity).length()) * 0.000007)
		torque += (radius * (body.velocity).length()) * 0.000007
		


func _on_left_body_entered(body: Node2D) -> void:
	if body.is_in_group("PLAYER"):
		var radius = (body.position - position).length()
		print("LEFT:", (radius * (body.prev_velocity).length()) * 0.000007)
		torque += (radius * (body.prev_velocity).length()) * 0.000007
