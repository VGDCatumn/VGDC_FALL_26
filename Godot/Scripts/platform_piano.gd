extends Node2D

@onready var audio : AudioStreamPlayer2D = $AudioStreamPlayer2D

func _on_piano_keys_body_entered(body: Node2D) -> void:
	audio.play()
