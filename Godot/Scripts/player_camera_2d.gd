extends Camera2D

@export var zoom_speed = 3.0  

@export var target_zoom = Vector2(0.5,0.5) # initialize with default zoom

func _process(delta):
	# Smoothly interpolate current zoom to target
	zoom = lerp(zoom, target_zoom, zoom_speed * delta)
