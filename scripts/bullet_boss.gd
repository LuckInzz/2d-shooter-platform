extends CharacterBody2D

var move_speed := 250.0
var direction := 1
@onready var anim: AnimatedSprite2D = $anim

func _ready() -> void:
	anim.play("bone")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x += move_speed * direction * delta
	
func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free()

func set_direction(dir):
	direction = dir
	if dir < 0:
		$anim.flip_h = true
	else:
		$anim.flip_h = false
		
