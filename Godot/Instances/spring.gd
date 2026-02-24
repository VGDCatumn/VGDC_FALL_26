extends Area2D

@export var spring_power := 1.2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass




func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("PLAYER"):
		$AnimationPlayer.play("boing")
		$AudioStreamPlayer.play()
		body.velocity.y = -abs(body.velocity.y) * spring_power
