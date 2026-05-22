extends Area2D

@onready var player = $Clouds_Ambience
@onready var player2 = $Clouds_Ambience2
@onready var player3 = $Clouds_Ambience3

#Player3 adjusted to -10 due to naturally being quieter.
func _on_body_entered(body: Node2D) -> void:

	if body.is_in_group("PLAYER"):
		player.volume_db = -15
		player.play()
		player3.volume_db = -10
		player2.volume_db = -15
		$Timer.start()
		


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("PLAYER"):
		player.volume_db = -80
		player2.volume_db = -80
		player3.volume_db = -80
		player3.stop()


func _on_timer_timeout() -> void:
	player3.play()
