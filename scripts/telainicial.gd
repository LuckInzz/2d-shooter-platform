extends Control

@onready var initial_music: AudioStreamPlayer = $initial_music

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initial_music.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/fase2.tscn")

func _on_credits_pressed() -> void:
	pass # Replace with function body.

func _on_quit_pressed() -> void:
	get_tree().quit()
