extends Node2D
var cancel_other_gravity = false

func _on_moon_gravity_area_body_entered(body: Node2D):
	if body.is_in_group("PLAYER") and cancel_other_gravity == false:
		body.gravity = 600
		#gravity implement


func _on_moon_gravity_area_body_exited(body: Node2D):
	if body.is_in_group("PLAYER"):
		body.gravity = 1200



func _on_zero_gravity_area_body_entered(body: Node2D):
	if body.is_in_group("PLAYER") and cancel_other_gravity == false:
		body.gravity = 0
		



func _on_zero_gravity_area_body_exited(body: Node2D):
	if body.is_in_group("PLAYER"):
		body.gravity = 1200
		



func _on_super_gravity_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("PLAYER"):
		cancel_other_gravity = true
		body.gravity = 12000




func _on_super_gravity_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("PLAYER"):
		body.gravity = 1200
		cancel_other_gravity = false
