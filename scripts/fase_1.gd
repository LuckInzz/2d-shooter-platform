extends Node2D

@onready var background_sound: AudioStreamPlayer = $background_sound

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	background_sound.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
