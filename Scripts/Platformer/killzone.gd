extends Area2D
@onready var player: CharacterBody2D = $"../Player"

@onready var timer: Timer = $Timer
func _on_body_entered(body: Node2D) -> void:
	print("You died!")
	timer.start()


func _on_timer_timeout() -> void:
	get_tree().reload_current_scene()
	#if Global.player_position != null:
		#player.position = Global.player_position 
