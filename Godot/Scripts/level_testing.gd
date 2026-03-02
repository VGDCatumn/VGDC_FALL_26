extends Node2D

# This script is named "level_testing.gd" but it is applied to other level files as well.

func _process(delta: float) -> void:
	
	# exit to main menu when ESC is pressed
	if Input.is_action_just_pressed("ui_cancel"): 
		get_tree().change_scene_to_file("res://UI/main_menu.tscn")
