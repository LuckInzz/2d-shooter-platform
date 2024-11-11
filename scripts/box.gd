extends CharacterBody2D
class_name Pushables

const PUSH_SPEED = 200.0
@onready var player: CharacterBody2D = $"."

func _physics_process(delta: float) -> void:
	# Add the gravity.
	velocity += get_gravity() * delta

	move_and_slide()
	
	velocity.x = 0
	
func push_box(direction):
	velocity.x = int(direction.x) * PUSH_SPEED


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.can_push_box = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.can_push_box = false
