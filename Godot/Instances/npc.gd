extends Node2D

var player
var player_in_speakZone = false
var done_talking = true


func _process(delta):
	if (player_in_speakZone == true) and (done_talking == true):
		done_talking = false
		$Dialogue.start()	
		$Dialogue/Timer.start()
		print("HERE")
	


func _on_dialogue_dialogue_finished():
	$Dialogue/Timer.paused


	


func _on_speak_zone_body_entered(body):
	if body.is_in_group("PLAYER"):
		player = body
		player_in_speakZone = true
		print("in zone")
		
		


func _on_speak_zone_body_exited(body):
	if body.is_in_group("PLAYER"):
		player_in_speakZone = false
		done_talking = true
		
