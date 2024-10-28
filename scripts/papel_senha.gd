extends CanvasLayer

# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#visible = false
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_ESCAPE):
		_on_exit_button_pressed()

func show_in_screen():
	visible = true
	get_tree().paused = true
	print ("teste tela senha")

func _on_exit_button_pressed() -> void:
	visible = false
	get_tree().paused = false
