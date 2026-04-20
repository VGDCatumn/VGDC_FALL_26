extends Node2D


@export var tractor_beam : Node2D
var player : CharacterBody2D
var in_tractor_beam : bool = false

func _process(delta):
	if in_tractor_beam:
		var distance_vector = tractor_beam.global_position - player.global_position
		var direction = distance_vector.normalized()
		var distance = distance_vector.length()
		player.velocity += direction * ((distance * 1.0/16.0 * delta) ** 5)

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
		body.gravity *= -1.0 / 2.0
		player = body
		in_tractor_beam = true


func _on_reverse_gravity_body_exited(body: Node2D) -> void:
	if body.is_in_group("PLAYER"):
		body.gravity *= -2.0
		in_tractor_beam = false
