extends CharacterBody2D

const PLAYER = preload("res://cenas/player.tscn")
const BULLET = preload("res://cenas/bullet.tscn")
const SPEED = 100.0
const JUMP_FORCE = -300
var CHASE_RANGE = 300
const JUMP_VELOCITY = -100.0
const BULLET_BOSS = preload("res://cenas/bullet_boss.tscn")
var life = 800
var damege = 20
var direction := -1
var is_running = false
var is_colliding = false  
var is_hurt = false
var is_attacking = false
var is_dead = false
var is_shoot = false
var distance_to_player
var n_bullet = 15

@onready var bullet_spawn_point: Marker2D = $bullet_spawn_point
@onready var animation := $Sprite as AnimatedSprite2D
@onready var player: CharacterBody2D = $"../../Player"
@onready var target: CharacterBody2D = $"../../Player"
@onready var life_bar: ProgressBar = $ProgressBar
@onready var bullet_cooldown: Timer = $bullet_cooldown
@onready var detector_left: RayCast2D = $detector_left
@onready var detector_right: RayCast2D = $detector_right
@onready var hud: CanvasLayer = $"../../HUD"
@onready var timer_boss_shoot: Timer = $timer_boss_shoot
@onready var boss_fight_sound: AudioStreamPlayer = $boss_fight_sound
@onready var death_boss_sound: AudioStreamPlayer = $death_boss_sound
@onready var boss_atack_sound: AudioStreamPlayer = $boss_atack_sound

func _ready() -> void:
	life_bar.value = life

func _physics_process(delta):
# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Calcula a distância para o jogador
	distance_to_player = global_position.distance_to(target.global_position)

	if detector_right.is_colliding() or detector_left.is_colliding():
		if is_on_floor():
			velocity.y = JUMP_FORCE  # Inicia o pulo para evitar o obstáculo

	# Muda para perseguição se o jogador estiver no alcance
	if distance_to_player < CHASE_RANGE:
		CHASE_RANGE = 500
		if target.global_position.x < global_position.x:
			direction = -1
			animation.flip_h = true
			is_running = true
			if sign(bullet_spawn_point.position.x) == 1:
				bullet_spawn_point.position.x *= -1
			#elif sign(bullet_spawn_point.position.x) == -1:
				#bullet_spawn_point.position.x *= -1
				
			if life > 0:
				velocity.x = direction * SPEED
				if !boss_fight_sound.playing:
					boss_fight_sound.play()
		else:
			direction = 1
			animation.flip_h = false
			is_running = true
			if sign(bullet_spawn_point.position.x) == -1:
				bullet_spawn_point.position.x *= -1
			#elif sign(bullet_spawn_point.position.x) == -1:
				#bullet_spawn_point.position.x *= -1
			
			if life > 0 && !is_hurt:
				velocity.x = direction * SPEED
	else:
		is_running = false
		velocity.x = 0  # Para o movimento quando fora do alcance de perseguição
	
	if life <= 400 && life > 300 && bullet_cooldown.is_stopped():
		is_shoot = true
	elif life <= 200 && is_dead == false && bullet_cooldown.is_stopped():
		is_shoot = true
	else:
		is_shoot = false
		
	# Aplica a velocidade e direção do inimigo
	#if is_running and not is_hurt and not is_attacking and not is_dead:
		#velocity.x = direction * SPEED
		#animation.scale.y = direction  # Atualiza a direção da animação

	move_and_slide()
	animations()
	
func shoot():
	spawm_bulley_boss()
	n_bullet -= 1

	# Handle player collision (attack)
func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.name == "player" and !is_hurt and !is_dead:
		is_colliding = true
		print("Player colidiu com o boss")
		
func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		is_attacking = true
		
func _on_hitbox_body_exited(body: Node2D) -> void:
	if body.name == "player":
		is_colliding = false
	
func animations():
	if !is_dead:
		if is_running && !is_hurt && !is_attacking && !is_shoot:
			animation.play("Run")
		elif is_attacking:
			animation.play("Atack")
		elif is_hurt && !is_attacking:
			animation.play("Hurt")
			await animation.animation_finished
			is_hurt = false
			is_colliding = false
		elif is_shoot:
			animation.play("Shoot")
			await animation.animation_finished
			shoot()
		elif !is_hurt && !is_attacking:
			animation.play("Idle")


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("bullets") && !is_hurt:
		is_colliding = true
		is_hurt = true
		life = life - player.bullet_damage
		life_bar.value = life
		velocity.x = 0
		if life <= 0:
			die()
			
func die() -> void:
	is_dead = true
	death_boss_sound.play()
	animation.play("Die")
	await animation.animation_finished
	boss_fight_sound.stop()
	queue_free()  # Remove o zumbi da cena
	hud.mostra_mensagem("Voce conseguiu um papel estranho, aperte P para abrir", 3)
	player.has_password_paper = true

func spawm_bulley_boss():
	var new_bullet_boss = BULLET_BOSS.instantiate()
	if sign(bullet_spawn_point.position.x) == 1:
		new_bullet_boss.set_direction(1)
	else:
		new_bullet_boss.set_direction(-1)
	add_sibling(new_bullet_boss)
	new_bullet_boss.global_position = bullet_spawn_point.global_position
	bullet_cooldown.start()
	
	
