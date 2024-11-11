extends CanvasLayer

@onready var resume_btn: Button = $MarginContainer/HBoxContainer/VBoxContainer/resume_btn
@onready var player: CharacterBody2D = $"../Player"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false

func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().paused = true

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		visible = true
		resume_btn.grab_focus()

func _on_resume_btn_pressed() -> void:
	visible = false
	get_tree().paused = false

func _on_quit_btn_pressed() -> void:
	get_tree().quit()
