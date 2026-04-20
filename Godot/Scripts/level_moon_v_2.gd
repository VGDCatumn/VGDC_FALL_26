extends Node2D

# MOON GRAVITY
func _on_low_gravity_body_entered(body: Node2D) -> void:
	if body.is_in_group("PLAYER"):
		body.gravity *= 1.0 / 2.0


func _on_low_gravity_body_exited(body: Node2D) -> void:
	if body.is_in_group("PLAYER"):
		body.gravity *= 2.0


# EARTH GRAVITY / GRAVITY WELL
func _on_regular_gravity_body_entered(body: Node2D) -> void:
	if body.is_in_group("PLAYER"):
		body.gravity *= 2.0


func _on_regular_gravity_body_exited(body: Node2D) -> void:
	if body.is_in_group("PLAYER"):
		body.gravity *= 1.0 / 2.0


# UFO TRACTOR BEAM
func _on_reverse_gravity_body_entered(body: Node2D) -> void:
	if body.is_in_group("PLAYER"):
		body.gravity *= -1


func _on_reverse_gravity_body_exited(body: Node2D) -> void:
	if body.is_in_group("PLAYER"):
		body.gravity *= -1
