extends Node2D

var website_names = ["google.com", "facebook.com", "amazon.com", "gogle.com", "faceboook.com", "amaz0n.com"]
var malicious_websites = ["gogle.com", "faceboook.com", "amaz0n.com"]
var score = 0
var load_value = 0  # CPU Load (Acts as Player's Health)
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
		$SpawnTimer.connect("timeout", spawn_websites)
		$SpawnTimer.start()

	update_cpu_load_display()

func update_timer():
	if game_over_state:
		return  # Stop updating if game is over

	game_time -= 1
	if game_time >= 0 and has_node("TimerLabel"):
		$TimerLabel.text = "Time: " + str(game_time)
	else:
		game_over("Time's Up!")

func spawn_websites():
	if game_over_state:
		return  # Don't spawn websites after game over

	var website_scene = load("res://Scenes/Mini_Games/DDos/website.tscn")
	if website_scene is PackedScene:
		var website_instance = website_scene.instantiate()

		# Assign random website name
		website_instance.website_name = website_names[randi() % website_names.size()]
		website_instance.is_malicious = website_instance.website_name in malicious_websites

		# Set random position
		website_instance.position = Vector2(randi() % 800, -50)  # Random X, start above screen

		# Connect button press event
		website_instance.connect("pressed", Callable(self, "_on_website_clicked").bind(website_instance))

		add_child(website_instance)

		# Animate falling (slower speed)
		var tween = website_instance.create_tween()
		tween.tween_property(website_instance, "position", Vector2(website_instance.position.x, 600), randf_range(5.0, 8.0))

		# When the animation finishes, check if it's a malicious website and increase CPU load
		await tween.finished
		if website_instance:  # Check if the node still exists
			if website_instance.is_malicious:
				increase_cpu_load()  # Penalize the player if a malicious site is not clicked
			website_instance.queue_free()  # Remove the website

func _on_website_clicked(website_instance):
	if game_over_state:
		return  # Ignore clicks after game over

	if website_instance.is_malicious:
		update_score(true)  # Correct click (blocking malicious)
	else:
		update_score(false)  # Wrong click (blocking real site)

	website_instance.queue_free()  # Remove clicked website

func update_score(correct):
	if game_over_state:
		return  # Stop updating if game is over

	if correct:
		score += 10
	else:
		load_value += 10  # Increase CPU Load if wrong decision

	# Update Score Label
	if has_node("ScoreLabel"):
		$ScoreLabel.text = "Score: " + str(score)

	# Update CPU Load Display
	update_cpu_load_display()

	# Check if CPU Load (Health) is 100%
	if load_value >= 100:
		game_over("System Overload!")

func increase_cpu_load():
	if game_over_state:
		return  # Stop updating if game is over

	load_value += 10  # Increase CPU Load
	update_cpu_load_display()

	# Check if CPU Load (Health) is 100%
	if load_value >= 100:
		game_over("System Overload!")

func update_cpu_load_display():
	if has_node("CPULoadLabel"):
		$CPULoadLabel.text = "Health: " + str(load_value) + "%"  # Update CPU Load text

	if has_node("LoadBar"):
		$LoadBar.value = load_value  # Update progress bar

func _on_game_timer_timeout():
	game_over("Time's Up!")

func game_over(message):
	print(message + " Final Score: " + str(score))
	Global.final_score = score  # Store the final score in Global script
	# Load End Scene and Pass Score
	get_tree().change_scene_to_file("res://Scenes/Mini_Games/DDos/end_scene.tscn")

	game_over_state = true  # Stop game logic

	if has_node("GameTimer"):
		$GameTimer.stop()

	if has_node("SpawnTimer"):
		$SpawnTimer.stop()

	if has_node("CountdownTimer"):
		$CountdownTimer.stop()

	# Remove all falling websites
	for child in get_children():
		if child.name.begins_with("Website"):  # Assuming websites are named dynamically
			child.queue_free()
