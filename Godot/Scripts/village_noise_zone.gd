extends Area2D

@onready var player = $Village_Ambience
@onready var crows = $village_random_1
@onready var villager = $village_random_2


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("PLAYER"):
		player.volume_db = -15
		crows.volume_db = -15
		villager.volume_db = -10
		


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("PLAYER"):
		player.volume_db = -80
		crows.volume_db = -80
		villager.volume_db = -80

func _on_timer_timeout() -> void:
	crows.play()
	$Timer.start(randi_range(10, 20))
	
	


func _on_timer_2_timeout() -> void:
	var randint = randi_range(0, 5)
	if (randint < 1):
		villager.play()
	$Timer2.start(randi_range(45, 90))
