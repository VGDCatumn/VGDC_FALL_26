extends CanvasLayer

# Connect update_stats signal from player
func _ready() -> void:
	var player = get_parent().get_node("EBM")
	player.update_stats.connect(on_update_stats)

# Change Label text to reflect a stats update
func on_update_stats(position, velocity):
	$MarginContainer/Label.text = "Position: " + str(position.round()) + "\n"
	$MarginContainer/Label.text += "Velocity: " + str(velocity.round()) + "\n"
