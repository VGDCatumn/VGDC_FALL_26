extends Node2D

var pointDirection : Vector2

func _on_ball_man_send_velocity_vector(position : Vector2, velocity: Vector2) -> void:
	point_arrow(position, velocity)
	scale_arrow(velocity)
	
func _on_bumper_send_bumper_vector(position: Vector2, direction: Vector2) -> void:
	point_arrow(position, direction)
	scale = Vector2(1,1)


func point_arrow(start_pos : Vector2, direction : Vector2):
	# add position and directional vector so origin of look_at is current position
	# direction vector is velocity in this case
	pointDirection = start_pos + direction
	
	# rotate the node to point in direction of directional vector
	look_at(pointDirection)
	
	# debugging prints
	# print("position: " + str(start_pos))
	# print("pointDirection: " + str(pointDirection))

func scale_arrow(vector : Vector2):
	var min_scale = 0.2
	var max_scale = 1
	var max_magnitude = 2500 		# vector magnitude required to reach max_scale
	
	# calculate the fraction that current magnitude is to max_magnitude
	# set that fraction (scaleFactor) as the scale of the arrow
	# bounded by scale of 0.2 to 1
	var magnitude = vector.length()
	var scaleFactor = magnitude / max_magnitude   
	scaleFactor = clampf(scaleFactor, min_scale, max_scale)
	scale = Vector2(scaleFactor, scaleFactor)


### MOVING ARROW DESIGN -- BEN NOTES
# move to position of player
# read in velocity vector
# look_at(position + velocity)
# scale with magnitude (normalize, clamp(size_min, size_max)

# should this be its own node in the scene?
	# should I use signals?
# should this be a child node of the player?
	# better, because player is instantied 

	
