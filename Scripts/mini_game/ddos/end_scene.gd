extends Control

var final_score = 0  # This will be passed from the game scene

func _ready():
	var final_score = Global.final_score  # Get the stored score
	$ScoreLabel.text = "Final Score: " + str(final_score)
