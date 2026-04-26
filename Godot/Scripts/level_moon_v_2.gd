extends Node2D

@onready var audio : AudioStreamPlayer2D = $UFO/AudioStreamPlayer2D
@export var tractor_beam : Node2D
var in_tractor_beam : bool = false

var player : CharacterBody2D
var previous_gravity : float

func _process(delta):
	if in_tractor_beam:
		# move player towards center of tractor beam
		# this should feel "floaty"
		# this is really jank and needs to be changed
		var distance_vector = tractor_beam.global_position - player.global_position
		var direction = distance_vector.normalized()
		var distance = distance_vector.length()
		player.velocity += direction * 12
		player.velocity.y = lerpf(player.velocity.y, -500.0, delta)
		
		# play end credits song
		if (!audio.playing):
			audio.play()

# MOON GRAVITY
func _on_low_gravity_body_entered(body: Node2D) -> void:
	if body.is_in_group("PLAYER"):
		body.gravity *= 1.0 / 2.0

func _on_low_gravity_body_exited(body: Node2D) -> void:
	if body.is_in_group("PLAYER"):
		body.gravity *= 2.0


# EARTH GRAVITY / GRAVITY WELL
# This is not used in the level
func _on_regular_gravity_body_entered(body: Node2D) -> void:
	if body.is_in_group("PLAYER"):
		body.gravity *= 2.0

func _on_regular_gravity_body_exited(body: Node2D) -> void:
	if body.is_in_group("PLAYER"):
		body.gravity *= 1.0 / 2.0


# UFO TRACTOR BEAM
func _on_reverse_gravity_body_entered(body: Node2D) -> void:
	if body.is_in_group("PLAYER"):
		previous_gravity = body.gravity
		player = body
		in_tractor_beam = true
		body.gravity = 0


func _on_reverse_gravity_body_exited(body: Node2D) -> void:
	if body.is_in_group("PLAYER"):
		body.gravity = previous_gravity
		in_tractor_beam = false
