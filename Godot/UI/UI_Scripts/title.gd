extends Label

@export var rotation_speed : float = 0.05
@export var rotation_max : float = 0.1
var rotation_direction = 1 # either 1 or -1 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# change direction of rotation if it reaches max bounds
	if (rotation > rotation_max):
		rotation_direction = -1
	elif (rotation < -rotation_max):
		rotation_direction = 1
		
	# rotate title text
	rotation += rotation_direction * rotation_speed * delta
