extends Control

var is_winner = false  

func set_winner_status(won: bool):
	is_winner = won

func _ready():
	var result_label = get_node_or_null("ResultLabel")
	if result_label:
		var custom_font = load("res://your_font.tres")  # Replace with your actual font file
		result_label.add_theme_font_override("font", custom_font)

		if is_winner:
			result_label.text = "🎉 YOU WON! 🎉"
			result_label.add_theme_color_override("font_color", Color(0, 1, 0))  # Green
			get_tree().change_scene_to_file("res://Scenes/Menus/you_won.tscn")
		else:
			result_label.text = "❌ YOU LOST! ❌"
			result_label.add_theme_color_override("font_color", Color(1, 0, 0))  # Red
	else:
		print("Error: ResultLabel not found!")

func _input(event):
	if event.is_pressed():
		get_tree().change_scene_to_file("res://MainScene.tscn")  # Restart game
