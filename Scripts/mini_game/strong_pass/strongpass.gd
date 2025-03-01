extends Control

var required_length = 0
var time_left = 30
var conditions_met = {
	"length": false,
	"special_char": false,
	"number": false,
	"capital": false
}

@onready var password_input = $PasswordInput
@onready var caution_label = $CautionLabel
@onready var timer_label = $TimerLabel
@onready var feedback_label = $FeedbackLabel
@onready var submit_button = $SubmitButton
@onready var timer = $Timer

func _ready():
	required_length = randi_range(8, 12)
	update_caution_text()
	timer.start(time_left)
	timer_label.text = "Time Left: " + str(time_left)
	password_input.text_changed.connect(_on_password_input_text_changed)

func _process(delta):
	timer_label.text = "Time Left: " + str(int(timer.time_left))

func _on_password_input_text_changed(new_text):
	check_password(new_text)

func check_password(password):
	feedback_label.text = ""
	
	if !conditions_met["length"]:
		if password.length() == required_length:  # Enforce exact length
			conditions_met["length"] = true
		else:
			feedback_label.text = "❌ Password must be exactly " + str(required_length) + " characters long."
			return
	
	if !conditions_met["special_char"]:
		if has_special_char(password):
			conditions_met["special_char"] = true
		else:
			feedback_label.text = "❌ Password must contain at least one special character!"
			return

	if !conditions_met["number"]:
		if has_number(password):
			conditions_met["number"] = true
		else:
			feedback_label.text = "❌ Password must contain at least one number!"
			return

	if !conditions_met["capital"]:
		if has_capital_letter(password):
			conditions_met["capital"] = true
			feedback_label.text = "✅ Strong Password! You Win!"
			get_tree().change_scene_to_file("res://Scenes/WinScreen.tscn")
		else:
			feedback_label.text = "❌ Password must contain at least one capital letter!"
			return
	
	update_caution_text()

func update_caution_text():
	if !conditions_met["length"]:
		caution_label.text = "Your password must be exactly " + str(required_length) + " characters long."
	elif !conditions_met["special_char"]:
		caution_label.text = "Your password should include at least one special character."
	elif !conditions_met["number"]:
		caution_label.text = "Your password should include at least one number."
	elif !conditions_met["capital"]:
		caution_label.text = "Your password should include at least one capital letter."
	else:
		caution_label.text = "✅ Strong password created!"

func has_special_char(password):
	var regex = RegEx.new()
	regex.compile("[!@#$%^&*(),.?\":{}|<>]")  # Corrected the misplaced bracket
	return regex.search(password) != null


func has_number(password):
	var regex = RegEx.new()
	regex.compile("[0-9]")
	return regex.search(password) != null

func has_capital_letter(password):
	var regex = RegEx.new()
	regex.compile("[A-Z]")
	return regex.search(password) != null

func _on_Timer_timeout():
	feedback_label.text = "⏳ Time's up! You lost!"
	get_tree().change_scene_to_file("res://Scenes/GameOver.tscn")
