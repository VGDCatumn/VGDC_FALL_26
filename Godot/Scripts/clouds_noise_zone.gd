extends Area2D

@onready var player = $Clouds_Ambience
@onready var player2 = $Clouds_Ambience2

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("PLAYER"):
		player.volume_db = -25
		player2.volume_db = -15
		


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("PLAYER"):
		player.volume_db = -80
		player2.volume_db = -80
