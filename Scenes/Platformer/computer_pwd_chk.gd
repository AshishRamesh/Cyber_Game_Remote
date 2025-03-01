extends  Area2D

var entered = false 

func _on_body_entered(body: Node2D) -> void:
	entered = true

func _on_body_exited(body: Node2D) -> void:
	entered = false
	
func _process(delta: float) -> void:
	if entered == true:
		if Input.is_action_just_pressed("ui_down"):
			print("hi1")
			get_tree().change_scene_to_file("res://Scenes/Mini_Games/pass-check/passwordcracker.tscn")
