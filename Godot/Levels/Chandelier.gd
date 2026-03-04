extends RigidBody2D

@export var impulse_multiplier = .01


var in_vel = 0;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("PLAYER"):
		in_vel = body.velocity
		print("INVEL: "+str(in_vel))


func _on_collision_body_exited(body: Node2D) -> void:
	if body.is_in_group("PLAYER"):
		print("IMPULSE")		
		print("OUTVEL: "+str(body.velocity))
		var impulse = in_vel - body.velocity
		print("Impulse: " + str(impulse))
		apply_impulse(impulse*impulse_multiplier, body.position	)
