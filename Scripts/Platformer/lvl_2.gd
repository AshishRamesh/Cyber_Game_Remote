extends Node2D
@onready var player = $Player
func _ready():
	if Global.player_position != Vector2(0,0):
		player.position = Global.player_position 
