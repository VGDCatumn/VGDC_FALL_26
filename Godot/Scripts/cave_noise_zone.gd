extends Area2D

@onready var player = $Cave_Ambience
@onready var player2 = $Random_1
@onready var player3 = $Random_2

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("PLAYER"):
		player.volume_db = -15
		player2.volume_db = -15
		player3.volume_db = -15
		


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("PLAYER"):
		player.volume_db = -80
		player2.volume_db = -80
		player3.volume_db = -80



func _on_timer_timeout() -> void:
	var randint = randi_range(0, 3)
	if (randint <1):
		player2.play()
	else:
		player3.play()
	
	$Timer.start(randi_range(60,150 ))
	
