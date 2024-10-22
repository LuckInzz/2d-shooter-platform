extends CharacterBody2D
class_name Pushables

const PUSH_SPEED = 300.0



func _physics_process(delta: float) -> void:
	# Add the gravity.
	velocity += get_gravity() * delta

	move_and_slide()
	
	velocity.x = 0
	
func push_box(direction):
	velocity.x = int(direction.x) * PUSH_SPEED
