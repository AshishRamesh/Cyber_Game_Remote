extends Node2D

@export var mute:bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
	if not mute:
		play_music()

func play_music():
	if not mute:
		$music.play() # Replace with function body.


func play_jump():
	if not mute:
		$jump.play() # Replace with function body.

func play_music_stop():
	if not mute:
		$music.stop() # Replace with function body.
