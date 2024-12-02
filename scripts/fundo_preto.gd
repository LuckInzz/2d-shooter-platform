extends ColorRect

var threshold = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	material.set("shader_parameter/threshold", threshold)
