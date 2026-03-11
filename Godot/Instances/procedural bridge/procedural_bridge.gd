extends Node2D

@export var anchor1 : StaticBody2D
@export var anchor2 : StaticBody2D
@export var plank_count : int = 1
@export var joint_softness : int = 1
@export var impulse_multiplier := 0.35


var plank := preload("res://Instances/procedural bridge/plank.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var start = anchor1.global_position
	var end = anchor2.global_position

	var bridge = end-start
	var spacing = bridge / (plank_count +1)

	var angle = bridge.angle()

	var prev = anchor1
	for i in range(plank_count):

		var pos = start + spacing * (i+1)

		var new_plank = plank.instantiate()
		self.add_child(new_plank)
		new_plank.global_position = pos
		new_plank.rotation = angle
		new_plank.impulse_multiplier = impulse_multiplier
		
		

		var joint = PinJoint2D.new()
		self.add_child(joint)
		joint.global_position = prev.global_position + (spacing/2)
		joint.softness = joint_softness
		joint.node_a = prev.get_path()
		joint.node_b = new_plank.get_path()

		prev = new_plank

	var last_joint = PinJoint2D.new()
	self.add_child(last_joint)
	last_joint.global_position = end - (spacing/2)
	last_joint.softness = joint_softness
	last_joint.node_a = prev.get_path()
	last_joint.node_b = anchor2.get_path()
	
	
		



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
