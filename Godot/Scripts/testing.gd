extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	# exit to main menu when ESC is pressed
	if Input.is_action_just_pressed("ui_cancel"): 
		get_tree().change_scene_to_file("res://UI/main_menu.tscn")
