extends RigidBody2D

var impulse_multiplier := 0.35
var in_vel : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("PLAYER"):
		in_vel = body.prev_velocity
		print("INVEL: "+str(in_vel))


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("PLAYER"):
		print("IMPULSE")		
		print("OUTVEL: "+str(body.velocity))
		var impulse = in_vel - body.velocity
		print("Impulse: " + str(impulse))
		self.apply_impulse(impulse*impulse_multiplier, body.global_position - self.global_position	)
