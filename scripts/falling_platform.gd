extends AnimatableBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var velocity = Vector2.ZERO 
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_triggered = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_physics_process(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	position += velocity * delta
	
func has_collided_with():
	if !is_triggered:
		is_triggered = true
		animation_player.play("shake")
		velocity = Vector2.ZERO

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		has_collided_with()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	set_physics_process(true)
