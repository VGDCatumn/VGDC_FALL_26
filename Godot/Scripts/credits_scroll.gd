extends RichTextLabel

@export var scroll_speed: float = 50.0

func _process(delta: float):
	# Get the internal VScrollBar and increment its value
	var scrollbar = get_v_scroll_bar()
	scrollbar.value += scroll_speed * delta
