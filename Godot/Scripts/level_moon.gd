extends Node2D
var cancel_other_gravity = false


func _on_moon_gravity_area_body_entered(body: Node2D):
	if body.is_in_group("PLAYER") and cancel_other_gravity == false:
		print("Moon Gravity Area Entered")
		body.gravity = 600
		print(body.gravity)
		#gravity implement


func _on_moon_gravity_area_body_exited(body: Node2D):
	if body.is_in_group("PLAYER"):
		print("Moon Gravity Area Exited")
		body.gravity = 1200
		print(body.gravity)



func _on_zero_gravity_area_body_entered(body: Node2D):
	if body.is_in_group("PLAYER") and cancel_other_gravity == false:
		print("Zero Gravity Area Entered")
		body.gravity = 0
		



func _on_zero_gravity_area_body_exited(body: Node2D):
	if body.is_in_group("PLAYER"):
		print("Zero Gravity Area Exited")
		body.gravity = 1200
		



func _on_super_gravity_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("PLAYER"):
		print("Super Gravity Area Entered")
		cancel_other_gravity = true
		body.gravity = 12000




func _on_super_gravity_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("PLAYER"):
		print("Super Gravity Area Exited")
		body.gravity = 1200
		cancel_other_gravity = false


func _on_reverse_gravity_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("PLAYER"):
		body.gravity = -300
		

func _on_reverse_gravity_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("PLAYER"):
		body.gravity = 600
