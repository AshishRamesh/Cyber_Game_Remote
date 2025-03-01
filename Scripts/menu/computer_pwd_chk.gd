extends Node2D



func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_down"):
		print("Changing Scene")
<<<<<<< Updated upstream
		get_tree().change_scene_to_file("res://Scenes/Mini_Games/pass-check/passwordcracker.tscn")
=======
		get_tree().change_scene_to_file("res://Scenes/Mini_Games/pass-check/password_checker.tscn")
>>>>>>> Stashed changes
