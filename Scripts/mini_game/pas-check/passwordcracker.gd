extends Control

var letter_hash = {}
var correct_password = ""
var hashed_password = ""
var attempts = 3
var time_left = 60  # Set timer for 60 seconds
@onready var animated_sprite: AnimatedSprite2D = $computer_pwd_chk/AnimatedSprite2D
@onready var timer: Timer = $Timer  # Ensure there is a Timer node in the scene

# Load ❌ icon for wrong attempts
var wrong_icon = preload("res://icon.svg")  # Update the correct path
var wrong_icon = preload("res://assets/Props/keyboard_x_1.svg")  # Update path

var attempt_boxes = []

func _ready():
	generate_random_hashes()
	display_hashes()
	generate_meaningful_password()

	var hbox = $HBoxContainer  # Ensure HBoxContainer is correct
	if hbox:
		attempt_boxes = [hbox.get_node("Attempt1"), hbox.get_node("Attempt2"), hbox.get_node("Attempt3")]
	else:
		print("Error: HBoxContainer not found!")

	for box in attempt_boxes:
		box.visible = false  # Hide all attempt icons at start

	$PasswordInput.text_submitted.connect(_on_PasswordInput_text_submitted)

	timer.wait_time = time_left  # Set timer duration
	timer.start()  # Start the countdown
	timer.timeout.connect(_on_timer_timeout)  # Connect timeout signal

func generate_random_hashes():
	letter_hash.clear()
	var used_numbers = []

	for letter in "ABCDEFGHIJKLMNOPQRSTUVWXYZ":
		var random_number = randi_range(10, 99)
		while random_number in used_numbers:
			random_number = randi_range(10, 99)
		
		letter_hash[letter] = random_number
		used_numbers.append(random_number)

func display_hashes():
	var hash_text = "Letter - Hash:\n\n"
	var counter = 0

	for letter in letter_hash.keys():
		hash_text += letter + " = " + str(letter_hash[letter]) + "   "
		counter += 1
		if counter % 6 == 0:
			hash_text += "\n"

	$HashLabel.text = hash_text  

func generate_meaningful_password():
	var words = ["CODE", "PLAY", "HERO", "DATA", "LOVE", "SAFE", "WORLD", "HELLO", "GODOT"]
	var words = ["PASSWORD", "ADMIN", "LETMEIN", "DATA", "QWERTY", "SAFE", "WORLD", "HELLO", "GODOT", "TEAMJASN"]
	correct_password = words[randi() % words.size()]
	hashed_password = ""

	for letter in correct_password:
		hashed_password += str(letter_hash[letter])

	$TargetHashLabel.text = "Guess the word for: " + hashed_password

func _on_PasswordInput_text_submitted(user_input: String):
	user_input = user_input.to_upper()
	$PasswordInput.text = ""

	var user_hash = ""
	for letter in user_input:
		if letter in letter_hash:
			user_hash += str(letter_hash[letter])
		else:
			user_hash += "?"

	if user_hash == hashed_password:
		$FeedbackLabel.text = "✅ Correct! You cracked the code!"
		get_tree().change_scene_to_file("res://Scenes/Menus/you_won.tscn") 
		#await get_tree().create_timer(1).timeout  
		 
		timer.stop()  # Stop timer if correct
		await get_tree().create_timer(1).timeout
		get_tree().reload_current_scene()
	else:
		if attempts > 0:
			var wrong_index = 3 - attempts  
			if wrong_index < attempt_boxes.size():  # Check index validity
				attempt_boxes[wrong_index].texture = wrong_icon  
				attempt_boxes[wrong_index].visible = true  
		attempts -= 1
		
		if attempts > 0:
			$FeedbackLabel.text = "❌ Wrong! Attempts left: " + str(attempts)
		else:
			$FeedbackLabel.text = "❌ You lost! The word was: " + correct_password
			get_tree().change_scene_to_file("res://Scenes/Menus/game_over.tscn") 
			game_over()

func _on_timer_timeout():
	game_over()

func game_over():
	$FeedbackLabel.text = "❌ You lost! The word was: " + correct_password
