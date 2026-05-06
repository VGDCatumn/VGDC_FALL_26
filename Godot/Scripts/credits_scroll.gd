extends RichTextLabel

@export var scroll_speed: float = 40.0
@onready var scrollbar = get_v_scroll_bar()
var credits_toggled = false


func _process(delta: float):
	# Get the internal VScrollBar and increment its value
	if credits_toggled: 
		scrollbar.value += scroll_speed * delta


func _on_roll_credits_body_entered(body: Node2D) -> void:
	credits_toggled = true
