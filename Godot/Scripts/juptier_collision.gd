extends CollisionShape2D

# The purpose of this script is to disable the big planet collision shape, so the player
# can platform within the planet's collision when entering from the side.

func _on_area_2d_body_entered(body: Node2D) -> void:
	if (body.is_in_group("PLAYER")):
		self.set_deferred("disabled", true)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if (body.is_in_group("PLAYER")):
		self.set_deferred("disabled", false)
