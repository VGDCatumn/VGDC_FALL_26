@tool
extends EditorScript

@export var scene_root_path: String = "Chasm"
@export var collision_container_path: String = "Platforms_Static"

func _run():
	var root = get_editor_interface().get_edited_scene_root()
	if not root:
		push_error("No scene open in editor")
		return

	var scene_root = root
	if root.name != scene_root_path:
		scene_root = root.get_node_or_null(scene_root_path)
	if not scene_root:
		push_error("Could not find scene_root: " + scene_root_path)
		return

	var collision_container = scene_root.get_node_or_null(collision_container_path)
	if not collision_container:
		collision_container = root.get_node_or_null(collision_container_path)
	if not collision_container:
		push_error("Could not find collision_container: " + collision_container_path)
		return

	var count = 0
	for child in collision_container.get_children():
		if child is CollisionShape2D and child.shape is RectangleShape2D:
			var rect_size = child.shape.size
			var occluder = LightOccluder2D.new()
			var poly = OccluderPolygon2D.new()
			var half = rect_size / 2
			poly.polygon = PackedVector2Array([
				Vector2(-half.x, -half.y),
				Vector2(half.x, -half.y),
				Vector2(half.x, half.y),
				Vector2(-half.x, half.y)
			])
			occluder.occluder = poly
			occluder.position = child.position
			occluder.rotation = child.rotation
			occluder.scale = child.scale
			occluder.name = child.name + "_Occluder"
			collision_container.add_child(occluder)
			occluder.owner = root
			count += 1
	print("Generated ", count, " occluders")
