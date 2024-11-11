extends CharacterBody2D

const SPEED = 100
const JUMP_FORCE = -300
const CHASE_RANGE = 200
const BULLET = preload("res://cenas/bullet.tscn")
const PLAYER = preload("res://cenas/player.tscn")
var life = 100
var direction = 1
var is_running = false
var is_colliding = false  
var is_hurt = false
var is_attacking = false
var is_dead = false
var instancia_player
var distance_to_player

@onready var player: CharacterBody2D = $"../../Player"
@onready var animation := $Sprite as AnimatedSprite2D
@onready var detector_right: RayCast2D = $detector_right
@onready var detector_left: RayCast2D = $detector_left
@onready var target: CharacterBody2D = $"../../Player"

func _ready() -> void:
	instancia_player = PLAYER.instantiate()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Calcula a distância para o jogador
	distance_to_player = global_position.distance_to(target.global_position)

	if detector_right.is_colliding() or detector_left.is_colliding():
		if is_on_floor():
			velocity.y = JUMP_FORCE  # Inicia o pulo para evitar o obstáculo

	# Muda para perseguição se o jogador estiver no alcance
	if distance_to_player <= CHASE_RANGE:
		if target.global_position.x < global_position.x:
			direction = -1
		else:
			direction = 1
		is_running = true
	else:
		is_running = false
		velocity.x = 0  # Para o movimento quando fora do alcance de perseguição

	# Aplica a velocidade e direção do inimigo
	if is_running and not is_hurt and not is_attacking and not is_dead:
		velocity.x = direction * SPEED
		animation.scale.x = direction  # Atualiza a direção da animação

	move_and_slide()
	animations()

# Handle bullet hit
func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("bullets") && !is_hurt:
		is_colliding = true
		is_hurt = true
		life = life - player.bullet_damage
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
