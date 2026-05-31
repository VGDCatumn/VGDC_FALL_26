extends Area2D

@onready var player = $Bridge_Ambience
@onready var player2 = $bridge_random_1

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("PLAYER"):
		player.volume_db = -15
		player2.volume_db = -15
		


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("PLAYER"):
		player.volume_db = -80
		player2.volume_db = -80
		


func _on_timer_timeout() -> void:
	player2.play()
	$Timer.start(randi_range(25, 40))
