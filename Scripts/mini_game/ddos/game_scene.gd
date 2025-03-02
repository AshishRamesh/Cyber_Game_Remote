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
		$CountdownTimer.connect("timeout", update_timer)  # ✅ This function is now defined below
		$CountdownTimer.start()

	if has_node("GameTimer"):
		$GameTimer.connect("timeout", _on_game_timer_timeout)  # ✅ This function is now defined below
		$GameTimer.start(game_time)

	if has_node("SpawnTimer"):
		$SpawnTimer.connect("timeout", spawn_websites)
		$SpawnTimer.start()

	update_cpu_load_display()  # ✅ This function is now defined below

# ✅ FIXED: Add the missing function "update_timer()"
func update_timer():
	if game_over_state:
		return  

	game_time -= 1
	if game_time >= 0 and has_node("TimerLabel"):
		$TimerLabel.text = "Time: " + str(game_time)
	else:
		game_over("Time's Up!")

# ✅ FIXED: Add the missing function "_on_game_timer_timeout()"
func _on_game_timer_timeout():
	game_over("Time's Up!")

# ✅ FIXED: Add the missing function "update_cpu_load_display()"
func update_cpu_load_display():
	if has_node("CPULoadLabel"):
		$CPULoadLabel.text = "Server Damage: " + str(load_value) + "%"

	if has_node("LoadBar"):
		$LoadBar.value = load_value  

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

		website_instance.position = Vector2(randi() % 800, -50)  

		if website_instance.has_signal("pressed"):
			website_instance.connect("pressed", Callable(self, "_on_website_clicked").bind(website_instance))

		add_child(website_instance)  

		var tween = website_instance.create_tween()
		tween.tween_property(website_instance, "position", Vector2(website_instance.position.x, 600), randf_range(5.0, 8.0))

		await tween.finished
		if website_instance and website_instance.is_inside_tree():
			if website_instance.is_malicious:
				increase_cpu_load()
			website_instance.queue_free()

func increase_cpu_load():
	if game_over_state:
		return  

	load_value += 20  
	update_cpu_load_display()

	if load_value >= 100:
		game_over("System Overload!")

func game_over(message):
	print(message + " Final Score: " + str(score))
	Global.final_score = score  
	
	game_over_state = true  

	if has_node("GameTimer"):
		$GameTimer.stop()
	if has_node("SpawnTimer"):
		$SpawnTimer.stop()
	if has_node("CountdownTimer"):
		$CountdownTimer.stop()

	for child in get_children():
		if child.name.begins_with("Website"):  
			child.queue_free()

	if get_tree():
		await get_tree().process_frame  
		if load_value >= 100:  
			get_tree().change_scene_to_file("res://Scenes/Menus/game_over.tscn")  
		else:  
			get_tree().change_scene_to_file("res://Scenes/Menus/you_won.tscn")  
