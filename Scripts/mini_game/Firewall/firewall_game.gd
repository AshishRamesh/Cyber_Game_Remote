extends Node2D

var packet_names = [
	"source_ip: 192.168.1.10, request: GET /index.html, status: SAFE", 
	"source_ip: 157.240.22.35, request: Fetching data from API, status: API Request", 
	"source_ip: 192.168.1.100, request: GET /index.html, status: HTTP Request",
	"source_ip: 185.60.216.35, request: Establishing connection, status: TCP Handshake",
	"source_ip: 10.10.10.10, request: Secure shell connection, status: SSH Connection",
	"source_ip: 203.0.113.12, request: Uploading files, status: FTP Access"
]

var malicious_packets = [
	"source_ip: 199.200.1.1, request: Fake login page, status: Phishing Request", 
	"source_ip: 203.45.67.89, request: <script>alert('Hacked')</script>, status: XSS Attack",
	"source_ip: 150.25.36.78, request: Flooding packets, status: DDoS Flood",
	"source_ip: 220.15.25.5, request: Attempted logins: admin/root, status: Brute Force Attack"
]

var score = 0
var firewall_load = 0  # Firewall Load (Acts as Player's Health)
var game_time = 40  # Game duration in seconds
var game_over_state = false  # Track if game is over

func _ready():
	game_over_state = false  # Ensure game starts fresh

	if has_node("TimerLabel"):
		$TimerLabel.text = "Time: " + str(game_time)

	if has_node("CountdownTimer"):
		$CountdownTimer.connect("timeout", update_timer)
		$CountdownTimer.start()

	if has_node("GameTimer"):
		$GameTimer.connect("timeout", _on_game_timer_timeout)
		$GameTimer.start(game_time)

	if has_node("SpawnTimer"):
		$SpawnTimer.connect("timeout", spawn_packets)
		$SpawnTimer.start()

	update_firewall_display()

func update_timer():
	if game_over_state:
		return  

	game_time -= 1
	if game_time >= 0 and has_node("TimerLabel"):
		$TimerLabel.text = "Time: " + str(game_time)
	else:
		check_win_condition()

func spawn_packets():
	if game_over_state:
		return  

	var packet_scene = load("res://Scenes/Mini_Games/FirewallDefense/packet.tscn")
	if packet_scene is PackedScene:
		var packet_instance = packet_scene.instantiate()

		# Increase probability of spawning malicious packets (70% chance)
		var is_malicious = randi() % 10 < 7  # 70% chance for malicious
		if is_malicious:
			packet_instance.packet_name = malicious_packets[randi() % malicious_packets.size()]
			packet_instance.is_malicious = true
		else:
			packet_instance.packet_name = packet_names[randi() % packet_names.size()]
			packet_instance.is_malicious = false

		# Set random position
		packet_instance.position = Vector2(randi() % 800, -50)  

		# Connect button press event
		packet_instance.connect("pressed", Callable(self, "_on_packet_clicked").bind(packet_instance))

		add_child(packet_instance)

		# Animate falling (slower speed)
		var tween = packet_instance.create_tween()
		tween.tween_property(packet_instance, "position", Vector2(packet_instance.position.x, 600), randf_range(5.0, 8.0))

		# When the animation finishes, check if it's a malicious packet and increase firewall load
		await tween.finished
		if packet_instance:  
			if packet_instance.is_malicious:
				increase_firewall_load()  
			packet_instance.queue_free()

func _on_packet_clicked(packet_instance):
	if game_over_state:
		return  

	if packet_instance.is_malicious:
		update_score(true)  
	else:
		update_score(false)  

	packet_instance.queue_free()  

func update_score(correct):
	if game_over_state:
		return  

	if correct:
		score += 10
	else:
		firewall_load += 20  

	# Update Score Label
	if has_node("ScoreLabel"):
		$ScoreLabel.text = "Score: " + str(score)

	# Update Firewall Load Display
	update_firewall_display()

	# Check if Firewall Load is 100%
	if firewall_load >= 100:
		game_over("Firewall Breached!")

func increase_firewall_load():
	if game_over_state:
		return  

	firewall_load += 20  
	update_firewall_display()

	# Check if Firewall Load is 100%
	if firewall_load >= 100:
		game_over("Firewall Breached!")

func update_firewall_display():
	if has_node("CPULoadLabel"):
		$CPULoadLabel.text = "Health: " + str(firewall_load) + "%"  

	if has_node("LoadBar"):
		$LoadBar.value = firewall_load  

func _on_game_timer_timeout():
	check_win_condition()

func check_win_condition():
	if firewall_load < 100:
		game_won("Firewall Secured!")
	else:
		game_over("Firewall Breached!")

func game_won(message):
	print(message + " Final Score: " + str(score))
	Global.final_score = score  
	get_tree().change_scene_to_file("res://Scenes/Menus/you_won.tscn")
	game_over_state = true  

func game_over(message):
	print(message + " Final Score: " + str(score))
	Global.final_score = score  
	get_tree().change_scene_to_file("res://Scenes/Menus/game_over.tscn")
	game_over_state = true  

	if has_node("GameTimer"):
		$GameTimer.stop()

	if has_node("SpawnTimer"):
		$SpawnTimer.stop()

	if has_node("CountdownTimer"):
		$CountdownTimer.stop()

	# Remove all falling packets
	for child in get_children():
		if child.name.begins_with("Packet"):  
			child.queue_free()
