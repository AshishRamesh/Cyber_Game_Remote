extends Node2D

const speed = 60
var direction = 1

@onready var ray_cast_right: RayCast2D = $RayCast_right
@onready var ray_cast_left: RayCast2D = $RayCast_left

func _process(delta: float) -> void:
	if direction == 1 and ray_cast_right.is_colliding():
		direction = -1
	elif direction == -1 and ray_cast_left.is_colliding():
		direction = 1
	position.x += direction * speed * delta
