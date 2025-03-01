extends Button

var packet_name = ""  # Stores packet/website name
var is_malicious = false  # Determines if it's a malicious packet

func _ready():
	text = packet_name  # Set button text to packet name
	connect("pressed", Callable(self, "_on_packet_clicked"))  # Connect button click event

func _on_packet_clicked():
	var game = get_tree().get_first_node_in_group("firewall_game")  # Get main game node using groups

	if game:  # Ensure game node exists
		if is_malicious:
			queue_free()  # Remove malicious packet
			game.update_score(true)  # Increase score for blocking malicious traffic
		else:
			game.update_score(false)  # Increase CPU load for wrongly blocking a safe packet
