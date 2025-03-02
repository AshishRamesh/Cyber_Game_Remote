extends Node2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var entered = false 
var done = false

func _on_body_entered(body: Node2D) -> void:
	entered = true

func _process(delta: float) -> void:
	if entered == true:
		if Input.is_action_just_pressed("ui_down"):
			print("Changing Scene")
			get_tree().change_scene_to_file("res://Scenes/Mini_Games/pass-check/passwordcracker.tscn")
			done = true
	if Global.player_position != Vector2(0,0) and done == true :
			print(done)
			animated_sprite.pause()
			animated_sprite.play("completed")
				
		
