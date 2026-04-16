extends Node2D


func _on_low_gravity_body_entered(body: Node2D) -> void:
	if body.is_in_group("PLAYER"):
		body.gravity *= 1.0 / 2.0


func _on_low_gravity_body_exited(body: Node2D) -> void:
	if body.is_in_group("PLAYER"):
		body.gravity *= 2.0


func _on_regular_gravity_body_entered(body: Node2D) -> void:
	if body.is_in_group("PLAYER"):
		body.gravity *= 2.0


func _on_regular_gravity_body_exited(body: Node2D) -> void:
	if body.is_in_group("PLAYER"):
		body.gravity *= 1.0 / 2.0
