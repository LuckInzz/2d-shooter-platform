extends CharacterBody2D

const SPEED = 3000.0
const CHASE_RANGE = 4.0
const BULLET = preload("res://cenas/bullet.tscn")
const PLAYER = preload("res://cenas/player.tscn")

var life = 5
var direction = 1
var is_running = false
var is_colliding = false  
var is_hurt = false
var is_attacking = false
var is_dead = false

@onready var animation := $Sprite as AnimatedSprite2D
@onready var detector_right: RayCast2D = $detector_right
@onready var detector_left: RayCast2D = $detector_left
@onready var target: CharacterBody2D = $"../../Player"


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if detector_right.is_colliding():
		direction *= -1
	elif detector_left.is_colliding():
		direction *= -1

	# Handle movement and animations.
	if !is_hurt and !is_attacking and !is_dead:
		velocity.x = direction * SPEED * delta
		animation.scale.x = direction
		if velocity.x != 0:
			is_running = true
	elif is_colliding:
		is_running = false
		velocity.x = 0

	move_and_slide()
	animations()

# Handle bullet hit
func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("bullets") && !is_hurt:
		is_colliding = true
		is_hurt = true
		life = life - 1
		velocity.x = 0
		print("Tiro atingiu o zumbi")
		if life <= 0:
			die()

# Handle player collision (attack)
func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.name == "player" and !is_hurt and !is_dead:
		is_colliding = true
		print("Player colidiu com o zumbi")

func _on_hitbox_body_exited(body: Node2D) -> void:
	if body.name == "player":
		is_colliding = false

func die() -> void:
	is_dead = true
	animation.play("Die")
	await animation.animation_finished
	queue_free()  # Remove o zumbi da cena
	print("Zumbi MORTO!")

func animations():
	if !is_dead:
		if is_running && !is_hurt && !is_attacking:
			animation.play("Run")
		elif is_attacking:
			animation.play("Atack")
		elif is_hurt && !is_attacking:
			animation.play("Hurt")
			await animation.animation_finished
			is_hurt = false
			is_colliding = false
		elif !is_hurt && !is_attacking:
			animation.play("Idle")
