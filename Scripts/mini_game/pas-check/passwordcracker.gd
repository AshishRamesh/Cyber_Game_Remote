extends Control

var letter_hash = {}  
var hash_letter = {}  
var correct_password = ""  
var hashed_password = ""  
var attempts = 3  

# Load attempt images (Ensure these files exist!)
var empty_texture = null  # No icon at the start
var correct_texture = preload("res://icon.svg") # Green ✅
var wrong_texture = preload("res://icon.svg") # Red ❌

var attempt_sprites = []  
var feedback_label = null  # Label for showing wrong/correct messages
var password_input = null  # Reference to input field

func _ready():
	generate_random_hashes()
	display_hashes()
	generate_meaningful_password()
	
	# Get attempt sprites inside FeedbackLabel
	feedback_label = get_node_or_null("FeedbackLabel")
	password_input = get_node_or_null("PasswordInput")  # Store input field reference

	if feedback_label:
		attempt_sprites = [
			feedback_label.get_node_or_null("Attempt1"),
			feedback_label.get_node_or_null("Attempt2"),
			feedback_label.get_node_or_null("Attempt3")
		]
		# Ensure all sprites exist before modifying them
		if attempt_sprites.all(func(s): return s != null):
			hide_feedback_sprites()  # Hide all attempt icons at start
		else:
			print("Error: Some attempt icons are missing!")
	else:
		print("Error: FeedbackLabel not found!")

	# Connect Enter key event
	if password_input:
		password_input.text_submitted.connect(_on_PasswordInput_text_submitted)
	else:
		print("Error: PasswordInput node not found!")

func generate_random_hashes():
	letter_hash.clear()
	hash_letter.clear()

	var available_numbers = []
	for i in range(1, 100, 2):
		available_numbers.append(i)
	available_numbers.shuffle()

	var index = 0
	for letter in "ABCDEFGHIJKLMNOPQRSTUVWXYZ":
		letter_hash[letter] = available_numbers[index]
		hash_letter[available_numbers[index]] = letter
		index += 1

func display_hashes():
	var hash_text = "Letter - Hash:\n"
	for letter in letter_hash.keys():
		hash_text += letter + " = " + str(letter_hash[letter]) + "\n"
	
	var hash_label = get_node_or_null("HashLabel")
	if hash_label:
		hash_label.text = hash_text
	else:
		print("Error: HashLabel not found!")

func generate_meaningful_password():
	var words = ["CODE", "PLAY", "HERO", "DATA", "LOVE", "SAFE", "GODOT", "SMART"]
	correct_password = words[randi() % words.size()]
	hashed_password = ""

	for letter in correct_password:
		hashed_password += str(letter_hash[letter])

	print("Correct word:", correct_password)
	print("Generated Hash:", hashed_password)

	var target_hash_label = get_node_or_null("TargetHashLabel")
	if target_hash_label:
		target_hash_label.text = "Guess the word for: " + hashed_password
	else:
		print("Error: TargetHashLabel not found!")

func hide_feedback_sprites():
	""" Hides all attempt icons when the game starts. """
	for sprite in attempt_sprites:
		if sprite:
			sprite.visible = false  # Hide all icons initially

func update_feedback_message(msg: String, color: Color):
	"""Updates the game screen feedback label."""
	if feedback_label:
		feedback_label.text = msg
		feedback_label.add_theme_color_override("font_color", color)
	else:
		print("Error: FeedbackLabel not found!")

func _on_PasswordInput_text_submitted(user_input: String):
	user_input = user_input.to_upper()

	# Clear input field after submission
	if password_input:
		password_input.text = ""

	# Convert input to hash
	var user_hash = ""
	for letter in user_input:
		if letter in letter_hash:
			user_hash += str(letter_hash[letter])
		else:
			user_hash += "?" 
	
	# If correct password:
	if user_hash == hashed_password:
		update_feedback_message("✅ Correct! You cracked the code!", Color(0, 1, 0))  # Green
		return  # Exit early since the user won

	# If incorrect:
	if attempts > 0:
		attempts -= 1  # Reduce attempts BEFORE indexing

		# Show the attempt icon **ONLY when wrong**
		var wrong_icon_index = 3 - attempts - 1  # Get the correct index
		if wrong_icon_index < attempt_sprites.size():
			var sprite = attempt_sprites[wrong_icon_index]
			if sprite:
				sprite.visible = true  # Show the icon
				sprite.texture = wrong_texture  # ❌ for wrong attempt

		update_feedback_message("❌ Wrong! Try Again.", Color(1, 0, 0))  # Red
		
		# If no attempts left, show loss message & reset game
		if attempts <= 0:
			update_feedback_message("❌ You lost! The word was: " + correct_password, Color(1, 0, 0))
			reset_game()

func reset_game():
	print("🔄 Resetting game...")
	attempts = 3  # Reset attempts
	generate_random_hashes()
	display_hashes()
	generate_meaningful_password()
	hide_feedback_sprites()  # Hide all icons at game restart
	update_feedback_message("🔄 New Game Started! Try Again.", Color(0, 0, 1))  # Blue 
