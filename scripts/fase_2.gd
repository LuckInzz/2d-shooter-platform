extends Node2D

@onready var forest_sound: AudioStreamPlayer = $forest_sound

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	forest_sound.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
