extends Area2D

@onready var player = $Moon_Ambience

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("PLAYER"):
		player.volume_db = -15
		


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("PLAYER"):
		player.volume_db = -80
