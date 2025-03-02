extends Area2D
@onready var player: CharacterBody2D = $"../Player"

@onready var timer: Timer = $Timer
func _on_body_entered(body: Node2D) -> void:
	print("You died!")
	timer.start()


func _on_timer_timeout() -> void:
	if Global.kill > 2:
		Global.player_position =  Vector2(0,0)
		get_tree().reload_current_scene()
		Global.kill = 0
	else :
		get_tree().reload_current_scene()
		Global.kill += 1
	#if Global.player_position != null:
		#player.position = Global.player_position 
