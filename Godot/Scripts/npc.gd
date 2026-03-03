extends Node2D

var is_chatting = false

var player
var player_in_speakZone = false

func _on_speakZone_entered(body):
	if body.has_method("player"):
		player = body
		player_in_speakZone = true
		
func _on_speakZone_exited(body):
	if body.has_method("player"):
		player_in_speakZone = false
		
	
