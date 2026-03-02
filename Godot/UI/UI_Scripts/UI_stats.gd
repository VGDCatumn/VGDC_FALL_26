extends CanvasLayer

# Connect update_stats signal from player
func _ready() -> void:
	var player = get_parent().get_node("BallMan")
	player.update_stats.connect(on_update_stats)

# Change Label text to reflect a stats update
func on_update_stats(position, velocity, start_fall_height, end_fall_height):
	var fall_height = end_fall_height - start_fall_height 
	$MarginContainer/Label.text = "Position: " + str(position.round()) + "\n"
	$MarginContainer/Label.text += "Velocity: " + str(velocity.round()) + "\n"
	$MarginContainer/Label.text += "Fall Height: " + str(int(fall_height)) + "\n"
