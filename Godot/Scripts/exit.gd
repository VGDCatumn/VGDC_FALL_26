extends Area2D

var recieved = false

signal sending (player_body: Node2D, offset: Vector2)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_entrance_sending(player_body: Node2D, offset: Vector2) -> void:
	recieved = true
	player_body.global_position = global_position+offset


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("PLAYER"):
		if not recieved:
			emit_signal("sending", body, body.global_position-global_position)
		else:
			recieved = false
