extends Control

var scene_name
@onready var player: CharacterBody2D = $Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_restart_pressed() -> void:
	if Global.fase_atual == 1:
		get_tree().change_scene_to_file("res://cenas/fase2.tscn")
		Global.reset_data()
	else:
		get_tree().change_scene_to_file("res://cenas/fase1.tscn")
		Global.reset_data()

func _on_quit_pressed() -> void:
	get_tree().quit()
