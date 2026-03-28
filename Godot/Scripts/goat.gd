extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@export var buck_strength := 1
var state = 0
var init_pos: Vector2
var init_scale: Vector2
var side = -1
@onready var player = $"../BallMan"
#-1 = facing left
#1 = facing right

func _ready() -> void:
	init_pos = position

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	if state == 1:
		if side == -1:
			if $Nearby.is_colliding():
				
				velocity.x = 0
				state = 0
		else:
			if $Nearby_right.is_colliding():
				
				velocity.x = 0
				state = 0
	if player.position.x < position.x and side == 1:
		switch_side(-1)
	elif player.position.x > position.x and side == -1:
		switch_side(1)
	move_and_slide()

func _on_head_collision_body_entered(body: Node2D) -> void:
	if body.is_in_group("PLAYER"):
		$AnimationPlayer.play("Buck")
		var direction = position.direction_to(body.position + Vector2(141 * side,-47))
		body.velocity = direction * 1000 * buck_strength
	

func _on_buck_area_body_entered(body: Node2D) -> void:
	
	if state == 0:
		state = 1
		velocity.x = 0
		$AnimationPlayer.play("Charge")
		

func _on_buckline_body_entered(body: Node2D) -> void:
	if body.is_in_group("PLAYER"):
		if state == 1:
			
			velocity.x = 5000 * side
			
			
			
func switch_side(facing):
	if facing == -1:
		side = -1
		$HeadCollision/CollisionShape2D.disabled = false
		$HeadCollision/CollisionShape2D2.disabled = true
		
		$BuckArea/CollisionShape2D2.disabled = false
		$BuckArea/CollisionShape2D3.disabled = true
		
		$Buckline/CollisionShape2D.disabled = false
		$Buckline/CollisionShape2D2.disabled = true
		
		$Body.flip_h = false
		$Head.flip_h = false
	else:
		side = 1
		$HeadCollision/CollisionShape2D.disabled = true
		$HeadCollision/CollisionShape2D2.disabled = false
		
		$BuckArea/CollisionShape2D2.disabled = true
		$BuckArea/CollisionShape2D3.disabled = false
		
		$Buckline/CollisionShape2D.disabled = true
		$Buckline/CollisionShape2D2.disabled = false
		
		$Body.flip_h = true
		$Head.flip_h = true
