extends Control

var letter_hash = {}  # Stores random hashes for each letter
var correct_password = ""  # The correct word
var hashed_password = ""  # The hash sequence of the word
var attempts = 3  # Player has 3 chances

# Runs when the game starts
func _ready():
	generate_random_hashes()
	display_hashes()
	generate_meaningful_password()

	# Connect the Enter key event for password input
	$PasswordInput.text_submitted.connect(_on_PasswordInput_text_submitted)

# Generates random hashes for all letters (A-Z)
func generate_random_hashes():
	letter_hash.clear()
	var used_numbers = []  # To prevent duplicate hashes

	for letter in "ABCDEFGHIJKLMNOPQRSTUVWXYZ":
		var random_number = randi_range(10, 99)  # Random 2-digit hash
		while random_number in used_numbers:  # Avoid duplicates
			random_number = randi_range(10, 99)
		
		letter_hash[letter] = random_number
		used_numbers.append(random_number)

# Displays letter-to-hash mappings on screen
func display_hashes():
	var hash_text = "Letter - Hash:\n"
	for letter in letter_hash.keys():
		hash_text += letter + " = " + str(letter_hash[letter]) + "\n"

	$HashLabel.text = hash_text  # Update label

# Picks a meaningful word and generates its hash
func generate_meaningful_password():
	var words = ["CODE", "PLAY", "HERO", "DATA", "LOVE", "SAFE", "WORLD", "HELLO", "GODOT"]
	correct_password = words[randi() % words.size()]
	hashed_password = ""  # Reset hash

	# Convert the selected word to its hash sequence
	for letter in correct_password:
		hashed_password += str(letter_hash[letter])

	# Display hash sequence
	$TargetHashLabel.text = "Guess the word for: " + hashed_password

# Function triggered when Enter key is pressed in PasswordInput
func _on_PasswordInput_text_submitted(user_input: String):
	user_input = user_input.to_upper()
	
	# Convert user input to hash
	var user_hash = ""
	for letter in user_input:
		if letter in letter_hash:
			user_hash += str(letter_hash[letter])
		else:
			user_hash += "?"  # Invalid letter

	# Get attempt boxes
	var attempt_boxes = [$Attempt1, $Attempt2, $Attempt3]

	# Check if the input matches the correct hash
	if user_hash == hashed_password:
		$FeedbackLabel.text = "✅ Correct! You cracked the code!"
		# Show green ticks for remaining attempts
		for i in range(3 - attempts, 3):
			attempt_boxes[i].texture = load("res://icon.png")  # ✅ Icon
	else:
		if attempts > 0:
			attempt_boxes[3 - attempts].texture = load("res://icon.png")  # ❌ Icon for wrong attempt
		attempts -= 1
		
		if attempts > 0:
			$FeedbackLabel.text = "❌ Wrong! Attempts left: " + str(attempts)
		else:
			$FeedbackLabel.text = "❌ You lost! The word was: " + correct_password
