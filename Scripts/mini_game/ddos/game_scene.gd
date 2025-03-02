extends Node2D

var website_names = ["google.com", "facebook.com", "amazon.com", "nasa.gov", "whatsapp.com", "linkedin.com"]
var malicious_websites = ["HTTP Request Flood", "ICMP Flood", "Botnet Spam", "SYN Flood", "Spoofed Traffic"]
var score = 0
var load_value = 0  # CPU Load (Acts as Player's Health)
var game_time = 40  # Game duration in seconds
var game_over_state = false  # Track if game is over

func _ready():
	game_over_state = false  

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

# ✅ Fixed update_timer() function
func update_timer():
	if game_over_state:
		return  

	game_time -= 1
	if game_time >= 0 and has_node("TimerLabel"):
		$TimerLabel.text = "Time: " + str(game_time)
	else:
		game_over("Time's Up!")

# ✅ Fixed _on_game_timer_timeout() function
func _on_game_timer_timeout():
	game_over("Time's Up!")

# ✅ Fixed update_cpu_load_display() function
func update_cpu_load_display():
	if has_node("CPULoadLabel"):
		$CPULoadLabel.text = "Server Damage: " + str(load_value) + "%"

	if has_node("LoadBar"):
		$LoadBar.value = load_value  

# ✅ Fixed spawn_websites() so packets are fully visible
func spawn_websites():
	if game_over_state:
		return  

	var website_scene = load("res://Scenes/Mini_Games/DDos/website.tscn")
	if website_scene is PackedScene:
		var website_instance = website_scene.instantiate()

		var spawn_attack = randi() % 2 == 0  

		if spawn_attack:
			website_instance.website_name = malicious_websites[randi() % malicious_websites.size()]  
			website_instance.is_malicious = true  
		else:
			website_instance.website_name = website_names[randi() % website_names.size()]  
			website_instance.is_malicious = website_instance.website_name in malicious_websites  

		# ✅ Fix: Ensure packets remain fully visible on the screen
		var screen_width = get_viewport_rect().size.x
		var packet_width = 100  # Adjust based on UI
		website_instance.position = Vector2(float(randi() % int(screen_width - packet_width)), -50)
 

		# ✅ Connect button clicks properly
		website_instance.connect("pressed", Callable(self, "_on_website_clicked").bind(website_instance))

		add_child(website_instance)  

		var tween = website_instance.create_tween()
		tween.tween_property(website_instance, "position", Vector2(website_instance.position.x, 600), randf_range(5.0, 8.0))

		await tween.finished
		if website_instance and website_instance.is_inside_tree():
			if website_instance.is_malicious:
				increase_cpu_load()
			website_instance.queue_free()

# ✅ Fixed _on_website_clicked() so websites disappear on click
func _on_website_clicked(website_instance):
	if game_over_state:
		return  

	if website_instance.is_malicious:
		update_score(true)  # Correct block
	else:
		update_score(false)  # Incorrect block

	website_instance.queue_free()  # Remove the clicked website

# ✅ Fixed update_score() to stop game when CPU load reaches 100%
func update_score(correct):
	if correct:
		score += 10
	else:
		load_value += 10  
	
	update_cpu_load_display()
	update_score_display()  # ✅ Added function to update the score label

	# Stop game immediately if CPU Load reaches 100%
	if load_value >= 100:
		load_value = 100  
		game_over("System Overload!")

# ✅ New function to update the score display
func update_score_display():
	if has_node("ScoreLabel"):
		$ScoreLabel.text = "Score: " + str(score)


# ✅ Fixed increase_cpu_load() to stop game immediately
func increase_cpu_load():
	if game_over_state:
		return  

	load_value += 20  
	update_cpu_load_display()

	# Stop game immediately if CPU Load reaches 100%
	if load_value >= 100:
		load_value = 100  
		game_over("System Overload!")

# ✅ Fixed game_over() to stop the game completely
func game_over(message):
	print(message + " Final Score: " + str(score))
	Global.final_score = score  
	
	game_over_state = true  

	# Stop all timers
	if has_node("GameTimer"):
		$GameTimer.stop()
	if has_node("SpawnTimer"):
		$SpawnTimer.stop()
	if has_node("CountdownTimer"):
		$CountdownTimer.stop()

	# Remove all remaining packets from screen
	for child in get_children():
		if child is Button:
			child.queue_free()

	# Change scene to Game Over or Victory screen
	await get_tree().process_frame  
	if load_value >= 100:  
		get_tree().change_scene_to_file("res://Scenes/Menus/game_over.tscn")  
	else:  
		get_tree().change_scene_to_file("res://Scenes/Menus/you_won.tscn")
