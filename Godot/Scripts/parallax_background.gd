extends Node2D

# reference to player
# as it stands, this player reference is HIGHLY DEPENDENT on the 
# organization of the level
@onready var player = get_parent().get_node("BallMan")



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# position.x = player.position.x
	pass
