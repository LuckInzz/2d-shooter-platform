extends Area2D

@onready var player: CharacterBody2D = $"../../Player"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player.take_damage(1, Vector2.ZERO)
		player.is_hurt = true
		await get_tree().create_timer(.2).timeout
		player.die()
