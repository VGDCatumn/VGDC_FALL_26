extends DirectionalLight2D

var insideChasm = true
@export var chasmBrightness = 0.75
@export var outsideBrightness = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (insideChasm):
		energy = lerpf(energy, chasmBrightness, delta)
	else:
		energy = lerpf(energy, outsideBrightness, delta)
	
	



func _on_trigger_chasm_lighting_body_entered(body: Node2D) -> void:
	if (body.is_in_group("PLAYER")):
		insideChasm = true


func _on_trigger_chasm_lighting_body_exited(body: Node2D) -> void:
	if (body.is_in_group("PLAYER")):
		insideChasm = false
