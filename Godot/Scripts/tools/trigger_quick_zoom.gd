extends Area2D

@export var default_zoom = Vector2(0.50,0.50)
@export var area_zoom_out = Vector2(0.03, 0.03) # zoom out
var zoom_done = false

# signal passed to camera that will adjust the zoom 
signal enter_chasm_finale (is_inside : bool)



func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("PLAYER") and zoom_done == false:
		var camera = body.get_node("Camera2D")
		camera.target_zoom = area_zoom_out
		$Timer.start()
		await $Timer.timeout
		camera.target_zoom = default_zoom
		zoom_done = true
		
