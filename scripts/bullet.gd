extends Area2D

var bullet_speed := 300
var direction := 1

func _process(delta):
	position.x += bullet_speed * direction * delta

func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free()
	
func set_direction(dir):
	direction = dir

func _on_area_entered(area):
	queue_free()
