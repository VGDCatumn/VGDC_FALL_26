extends StaticBody2D


@export var can_take = 3
@export var downtime := 5
var HP = 2
var open := false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	HP = can_take
	$Downtime.wait_time = downtime

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_player_detecter_body_entered(body: Node2D) -> void:
	if body.is_in_group("PLAYER"):
		if open == false:
			HP -= 1
			$AnimationPlayer.play("Shake")
			if HP <= 0:
				$AnimationPlayer.play("Open")
				open = true
				$Downtime.start()
				await $AnimationPlayer.animation_finished
				$Left.disabled = true
				$Right.disabled = true


func _on_downtime_timeout() -> void:
	$AnimationPlayer.play("close")
	await $AnimationPlayer.animation_finished
	open = false
	$Left.disabled = false
	$Right.disabled = false
	HP = can_take
