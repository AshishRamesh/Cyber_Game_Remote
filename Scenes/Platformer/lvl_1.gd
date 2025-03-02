extends Node2D
@onready var player = $Player
func _ready():
	player.position = Global.player_position 
