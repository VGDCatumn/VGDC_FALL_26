extends Node2D

@onready var Portal1 = $Portal1
@onready var Portal2 = $Portal2
@onready var portal1_up = Portal1.global_transform.y * -1
@onready var portal2_up = Portal2.global_transform.y * -1
@onready var Portal1AudioEnter = $Portal1/AudioEnter
@onready var Portal1AudioExit = $Portal1/AudioEnter
@onready var Portal2AudioEnter = $Portal2/AudioEnter
@onready var Portal2AudioExit = $Portal2/AudioExit

var canTeleport = true

# TODO
# 


func _on_portal_1_body_entered(body: Node2D) -> void:
	if (body.is_in_group("PLAYER") and canTeleport) :
		# calcuate rotation of velocity
		var rotation_angle = portal1_up.angle_to(portal2_up)
		
		# play audio
		Portal1AudioEnter.play()
		
		# set new values
		canTeleport = false
		body.global_position = Portal2.global_position
		body.velocity = body.velocity.rotated(rotation_angle)

func _on_portal_1_body_exited(body: Node2D) -> void:
	canTeleport = true
	Portal1AudioExit.play()



func _on_portal_2_body_entered(body: Node2D) -> void:
	if (body.is_in_group("PLAYER") and canTeleport):
		# calcuate rotation of velocity
		var rotation_angle = portal2_up.angle_to(portal1_up)
		
		# play audio
		Portal2AudioEnter.play()
		
		# set new values
		canTeleport = false
		body.global_position = Portal1.global_position
		body.velocity = body.velocity.rotated(rotation_angle)


func _on_portal_2_body_exited(body: Node2D) -> void:
	canTeleport = true
	Portal2AudioExit.play()
	
