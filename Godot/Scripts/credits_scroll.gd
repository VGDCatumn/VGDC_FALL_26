extends Control

@export var scroll_speed: float = 40.0
@onready var scrollbar1 = $CreditsTitles.get_v_scroll_bar()
@onready var scrollbar2 = $CreditsNames.get_v_scroll_bar()
@onready var thanks_label = $ThanksForPlaying
var credits_toggled = false

func _ready():
	thanks_label.self_modulate.a = 0


func _process(delta: float):
	# Get the internal VScrollBar and increment its value
	if credits_toggled: 
		scrollbar1.value += scroll_speed * delta
		scrollbar2.value += scroll_speed * delta
		
	# Check to see if credits are done rolling
	if scrollbar1.value >= 5240:
		thanks_label.self_modulate.a += delta / 5
		
		


func _on_roll_credits_body_entered(body: Node2D) -> void:
	credits_toggled = true
