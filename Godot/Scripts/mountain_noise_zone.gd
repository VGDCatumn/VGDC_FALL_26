extends Area2D


@onready var wind = $Mountain_Ambience
@onready var snowgrave = $mountain_random_1
@onready var jingle = $mountain_random_2
@onready var jingle2 = $mountian_random_3


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("PLAYER"):
		wind.volume_db = -15
		snowgrave.volume_db = -15
		jingle.volume_db = -15
		jingle2.volume_db = -15


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("PLAYER"):
		wind.volume_db = -80
		snowgrave.volume_db = -80
		jingle.volume_db = -80
		jingle2.volume_db = -80

		



func _on_timer_timeout() -> void:
	snowgrave.play()
	$Timer.start(randi_range(180, 300))
	
	


func _on_timer_2_timeout() -> void:
	var randint = randi_range(0, 3)
	if (randint <1):
		jingle.play()
	else:
		jingle2.play()
	$Timer2.start(randi_range(60, 90))
