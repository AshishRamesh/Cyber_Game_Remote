extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_down"):
			get_tree().change_scene_to_file("res://Scenes/Mini_Games/DDos/game_scene.tscn")
