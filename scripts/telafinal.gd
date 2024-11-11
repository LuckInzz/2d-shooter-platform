extends Control

var scene_name

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_restart_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/fase1.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
