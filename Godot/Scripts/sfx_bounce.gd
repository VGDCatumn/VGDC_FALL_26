extends AudioStreamPlayer

### CATEGORIZE BOUNCE SFX

var bounce_soft_sounds = [
	preload("res://Audio/bounce-soft-1.mp3"),
	preload("res://Audio/bounce-soft-2.mp3"),
	preload("res://Audio/bounce-soft-3.mp3"),
	preload("res://Audio/bounce-soft-4.mp3")
]

var bounce_hard_sounds = [
	preload("res://Audio/bounce-hard-1.mp3"),
	preload("res://Audio/bounce-hard-2.mp3")
]

# Play bounce noise depending on magnitude of bounce velocity
# Maybe pitch noise based on y velocity? Future consideration - Ben
func _on_ball_man_send_bounce(velocity: Vector2) -> void:
	var magnitude = velocity.length()
	
	# soft bounce
	if (magnitude < 1600):
		# pick a random soft audio as the AudioPlayer stream
		self.stream = bounce_soft_sounds.pick_random() 
	# hard bounce
	else:
		self.stream = bounce_hard_sounds.pick_random() 
		
	# Play audio
	self.play()
