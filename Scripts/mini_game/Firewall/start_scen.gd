extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func play_button() -> void:
	func _ready():	$StartButton.connect("pressed", _on_start_pressed)


func credit_button() -> void:
	pass #get_tree().change_scene_to_file()


func exit_button() -> void:
	get_tree().quit() # Replace with function body.
