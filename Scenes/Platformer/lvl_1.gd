extends Node2D
@onready var player = $Player
@onready var ray_cast: RayCast2D = $Player/RayCast2D

func _ready():
	player.position = Global.player_position 
	if Global.player_position != Vector2(0,0) :
		player.position = Global.player_position 
	else:
		Global.mini_comp = false
	if ray_cast.is_colliding():
		player.position = Vector2(0,0) 
