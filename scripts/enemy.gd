extends CharacterBody2D

var SPEED = 100
const JUMP_FORCE = -300
var CHASE_RANGE = 150
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
var time_chasing = 0.0
var direction_delay_timer = 1.0
var sons_idle = ["res://sons/zombie_default_1.mp3", "res://sons/zombie_default_2.mp3", "res://sons/zombie_default_3.mp3", "res://sons/zombie_default_4.mp3", "res://sons/zombie_default_5.mp3", "res://sons/zombie_default_6.mp3"]
var sons_chase = ["res://sons/zombie_chase_1.mp3", "res://sons/zombie_chase_2.mp3", "res://sons/zombie_chase_3.mp3", "res://sons/zombie_chase_4.mp3", "res://sons/zombie_chase_5.mp3", "res://sons/zombie_chase_6.mp3", "res://sons/zombie_chase_7.mp3", "res://sons/zombie_chase_8.mp3", "res://sons/zombie_chase_9.mp3", "res://sons/zombie_chase_10.mp3", "res://sons/zombie_chase_11.mp3", "res://sons/zombie_chase_12.mp3", "res://sons/zombie_chase_13.mp3", "res://sons/zombie_chase_14.mp3", "res://sons/zombie_chase_15.mp3", "res://sons/zombie_chase_16.mp3", "res://sons/zombie_chase_17.mp3"]

@onready var player: CharacterBody2D = $"../../Player"
@onready var animation := $Sprite as AnimatedSprite2D
@onready var detector_right: RayCast2D = $detector_right
@onready var detector_left: RayCast2D = $detector_left
@onready var target: CharacterBody2D = $"../../Player"
@onready var audio_player: AudioStreamPlayer = $audio_player

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Calcula a distância para o jogador
	distance_to_player = global_position.distance_to(target.global_position)
	
	if distance_to_player <= CHASE_RANGE + 100 and distance_to_player > CHASE_RANGE:
		if !audio_player.playing:
			play_sound(sons_idle[randi() % sons_idle.size()], distance_to_player)
		
	if detector_right.is_colliding() or detector_left.is_colliding():
		if is_on_floor():
			velocity.y = -380  # Inicia o pulo para evitar o obstáculo

	# Muda para perseguição se o jogador estiver no alcance
	if distance_to_player <= CHASE_RANGE:
		CHASE_RANGE = 250
		if !audio_player.playing:
			play_sound(sons_chase[randi() % sons_chase.size()], distance_to_player)
		if target.global_position.x < global_position.x:
			await get_tree().create_timer(0.3).timeout
			direction = -1
		elif target.global_position.x > global_position.x:
			await get_tree().create_timer(0.3).timeout
			direction = 1
		is_running = true
	else:
		is_running = false
		velocity.x = 0  # Para o movimento quando fora do alcance de perseguição

	# Aplica a velocidade e direção do inimigo
	if is_running and not is_hurt and not is_attacking and not is_dead:
		velocity.x = direction * 300
		animation.scale.x = direction  # Atualiza a direção da animação

	move_and_slide()
	animations()

# Handle bullet hit
func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("bullets") && !is_hurt:
		CHASE_RANGE = 250
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

func play_sound(path, distancia_player):
	audio_player.stream = load(path)  # Carrega o som
	var volume = lerp(-15, 5, clamp(1 - distancia_player / 100, 0, 1))
	audio_player.volume_db = volume
	audio_player.play()
