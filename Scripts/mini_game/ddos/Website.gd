extends Button

var website_name = ""  # Stores website name
var is_malicious = false  # Is it malicious?

func _ready():
	text = website_name  # Set text
	connect("pressed", _on_website_clicked)  # Connect button click event

func _on_website_clicked():
	var game = get_parent()  # Get the game node
	if is_malicious:
		queue_free()  # Remove website
		game.update_score(true)  # Increase score
	else:
		game.update_score(false)  # Increase load
