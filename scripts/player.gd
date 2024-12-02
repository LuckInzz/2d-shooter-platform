extends CharacterBody2D

const BULLET = preload("res://cenas/bullet.tscn")
const PASSWORD_PAPER = preload("res://cenas/papel_senha.tscn")
const HUD = preload("res://cenas/hud.tscn")

var life = 100 
var enemy_damage = 20
var boss_damage = 20
var bullet_damage = 35
@export var SPEED = 150
@export var num_bullets = 20
var initial_bullets = 20
var total_bullets = 40
var JUMP_FORCE = -300.0
var is_jumping = false
var is_shooting = false
var is_crouched = false
var is_pushing = false
var is_dead = false
var is_hurt = false
var is_reloading = false
var is_holding_gun = true
var is_holding_medkit = false
var is_healing = false
var knockback_vector := Vector2.ZERO
var has_password_paper = false
var can_push_box = false
var instancia_pp
var instancia_hud
var itens =["gun","medkit"]
var index_itens = 0

@onready var hud: CanvasLayer = $"../HUD"
@onready var animation: AnimatedSprite2D = $Sprite
@onready var bullet_position: Marker2D = $bullet_position
@onready var shoot_cooldown: Timer = $shoot_cooldown
@onready var animation_timer: Timer = $animation_timer
@onready var single_shoot: AudioStreamPlayer = $single_shoot
@onready var carregando_pente: AudioStreamPlayer = $carregando_pente
@onready var tirando_pente: AudioStreamPlayer = $tirando_pente
@onready var automatic_shot: AudioStreamPlayer = $automatic_shot
@onready var health_bar: ProgressBar = $Control/health_bar
@onready var foot_steps_solid: AudioStreamPlayer = $foot_steps_solid
@onready var foot_steps_grass: AudioStreamPlayer = $foot_steps_grass
@onready var forest_sound: AudioStreamPlayer = $"../forest_sound"
@onready var hurt_sound_1: AudioStreamPlayer = $hurt_sounds/hurt_sound_1
@onready var hurt_sound_2: AudioStreamPlayer = $hurt_sounds/hurt_sound_2
@onready var hurt_sound_3: AudioStreamPlayer = $hurt_sounds/hurt_sound_3
@onready var player_sound_hurt: AudioStreamPlayer = $hurt_sounds/player_sound_hurt

var original_bullet_y = -24

func _ready() -> void:
	instancia_hud = HUD.instantiate()
	instancia_pp = PASSWORD_PAPER.instantiate()
	add_child(instancia_pp)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	var direction = 0
	if Input.is_key_pressed(KEY_A) and !is_reloading and !is_healing:
		direction = -1
		if Global.fase_atual == 2 and !foot_steps_solid.playing and !is_jumping:
			foot_steps_solid.play()
		elif Global.fase_atual == 1 and !foot_steps_grass.playing and !is_jumping:
			foot_steps_grass.play()
			
		if is_jumping:
			foot_steps_solid.stop()
			foot_steps_grass.stop()
			
		if sign(bullet_position.position.x) == 1:
			bullet_position.position.x *= -1
	elif Input.is_key_pressed(KEY_D) and !is_reloading and !is_healing:
		direction = 1 
		if Global.fase_atual == 2 and !foot_steps_solid.playing and !is_jumping:
			foot_steps_solid.play()
		elif Global.fase_atual == 1 and !foot_steps_grass.playing and !is_jumping:
			foot_steps_grass.play()
			
		if is_jumping:
			foot_steps_solid.stop()
			foot_steps_grass.stop()
			
		if sign(bullet_position.position.x) == -1:
			bullet_position.position.x *= -1
	else:
		foot_steps_solid.stop()
		foot_steps_grass.stop()
			
	if Input.is_key_pressed(KEY_I) and can_push_box:
		is_pushing = true
	else:
		is_pushing = false
	
	if Input.is_key_pressed(KEY_R) and Global.num_bullets < Global.initial_bullets and is_holding_gun:
		tirando_pente.play()
		carregando_pente.play()
		is_reloading = true
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and Global.num_bullets > 0 and is_holding_gun or Input.is_key_pressed(KEY_ENTER) and Global.num_bullets > 0 and is_holding_gun:
		if shoot_cooldown.is_stopped():
			is_shooting = true
			single_shoot.play()
			shoot_bullet()
	else:
		is_shooting = false
	
	#if Input.is_key_pressed(KEY_S) && is_on_floor():
		#is_crouched = true
	#else:
		#is_crouched = false
	
	#Handle Jump
	if Input.is_key_pressed(KEY_W) and is_on_floor() and is_on_floor() and !is_reloading || Input.is_key_pressed(KEY_SPACE) and is_on_floor() and is_on_floor() and !is_reloading:
		velocity.y = JUMP_FORCE
		is_jumping = true
	elif is_on_floor():
		is_jumping = false
		
	if direction != 0:
		velocity.x = direction * SPEED
		animation.scale.x = direction
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	if knockback_vector != Vector2.ZERO:
		velocity = knockback_vector
	
	if Input.is_key_pressed(KEY_P) and has_password_paper:
		instancia_pp.show_in_screen()
	
	if Input.is_action_just_pressed("ui_up"):
		index_itens += 1
		if index_itens + 1 > itens.size():
			index_itens = 0
		
		if itens[index_itens] =="gun":
			is_holding_medkit = false
			is_holding_gun = true
			hud.atualiza_HUD(is_holding_gun)
		else:
			is_holding_medkit = true
			is_holding_gun = false
			hud.atualiza_HUD(is_holding_gun)
	
	if Input.is_action_just_pressed("ui_down"):
		index_itens -= 1
		if index_itens < 0:
			index_itens = itens.size() - 1
		if itens[index_itens] =="gun":
			is_holding_medkit = false
			is_holding_gun = true
			hud.atualiza_HUD(is_holding_gun)
		else:
			is_holding_medkit = true
			is_holding_gun = false
			hud.atualiza_HUD(is_holding_gun)
	
	if Input.is_action_just_pressed("Interact") and is_holding_medkit and Global.num_medkits > 0 and Global.life < 100:
		is_healing = true
		heal()
	
	sounds()
	move_and_slide()
	apply_push_box()
	animations()
	
func apply_push_box():
	if can_push_box:
		for i in range(get_slide_collision_count()):
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			if collider is Pushables:
				if  Input.is_key_pressed(KEY_I):
					is_pushing = true
					if velocity.x == 0:
						collider.push_box(-collision.get_normal())
					else:
						collider.push_box(-collision.get_normal())
				else:
					is_pushing = false

func shoot_bullet():
	if Global.num_bullets > 0:
		var bullet_instance = BULLET.instantiate()
		Global.num_bullets -= 1 
		if sign(bullet_position.position.x) == 1:
			bullet_instance.set_direction(1)
		else:
			bullet_instance.set_direction(-1)
		
		add_sibling(bullet_instance)
		bullet_instance.global_position = bullet_position.global_position
		shoot_cooldown.start()
		if is_shooting && is_crouched:
			bullet_position.position.y = original_bullet_y + 9
		else:
			bullet_position.position.y = original_bullet_y

func reload_gun():
	var bullets_to_discard = Global.num_bullets
	Global.total_bullets += bullets_to_discard
	var bullets_needed = Global.initial_bullets
	if Global.total_bullets >= bullets_needed:
		Global.num_bullets = bullets_needed
		Global.total_bullets -= bullets_needed
	else:
		Global.num_bullets = Global.total_bullets
		Global.total_bullets = 0

func take_damage(amount: int, knockback_force := Vector2.ZERO, duration := 0.25):
	if not is_hurt and not is_dead:
		if knockback_force != Vector2.ZERO:
			knockback_vector = knockback_force
		
		var knockback_tween := get_tree().create_tween()
		knockback_tween.parallel().tween_property(self, "knockback_vector", Vector2.ZERO, duration)
		animation.modulate = Color(1,0,0,1)
		knockback_tween.parallel().tween_property(animation, "modulate", Color(1,1,1,1), duration)

		# Reduz a vida (você pode ter uma variável para o HP)
		Global.life -= amount
		if Global.life <= 0:
			die()

func die():
	if not is_dead:
		is_dead = true
		#animation.play("Die")
		#await animation.animation_finished
		#queue_free()  # Remove o personagem da cena
		hud.change_scene("res://cenas/telafinal.tscn")
	
func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies") and !body.is_dead:
		body.is_attacking = true
		await get_tree().create_timer(.2).timeout
		body.is_attacking = false
		
		var knockback = Vector2((global_position.x - body.global_position.x) * 15, 0)
		take_damage(enemy_damage, knockback)
		
		is_hurt = true
		print("Zumbi atingiu o player")
		
	if body.is_in_group("boss") and !body.is_dead:
		body.is_attacking = true
		body.boss_atack_sound.play()
		await get_tree().create_timer(.2).timeout
		var knockback = Vector2((global_position.x - body.global_position.x) * 15, 0)
		take_damage(boss_damage, knockback)
		is_hurt = true
		if Global.life>0:
			await get_tree().create_timer(.3).timeout
			take_damage(boss_damage, knockback)
			is_hurt = true
		body.is_attacking = false
		
	if body.is_in_group("bullet_boss"):
		body.queue_free()
		var knockback = Vector2((global_position.x - body.global_position.x) * 15, 0)
		take_damage(10, knockback)
		is_hurt = true

func heal():
	if Global.life + 50 > 100:
		Global.life = 100
		Global.num_medkits -= 1
	else:
		Global.life += 50
		Global.num_medkits -= 1
		

func animations():
	var state = "Idle"
	if !is_dead:
		if is_hurt:
			state = "Hurt"
		elif is_crouched && !is_shooting && velocity.x == 0:
			state = "Crouch"
		elif is_on_floor() && !is_shooting && !is_crouched && !is_pushing && velocity.x != 0 && !is_hurt && is_holding_gun:
			state = "Run"
		elif !is_on_floor() && !is_shooting && !is_crouched:
			state = "Jump"
		elif is_shooting && !is_crouched && Global.num_bullets > 0:
			if (is_on_floor() && velocity.x == 0 && velocity.y == 0):
				state = "Shoot_Standing"
			elif (velocity.y != 0):
				state = "Shoot_Jumping"
			elif (velocity.x != 0 && velocity.y == 0):
				state = "Shoot_Running"
		elif is_crouched && is_shooting && Global.num_bullets > 0:
			state = "Shoot_Crouching"
		elif is_pushing:
			if Input.is_key_pressed(KEY_D) || Input.is_key_pressed(KEY_A):
				state = "Pushing"
			else:
				state = "Pushing_Stand"
		elif is_reloading and !is_pushing and velocity.x == 0 and Global.num_bullets != Global.initial_bullets:
			state = "Reloading"
		elif !is_reloading and is_holding_gun:
			state = "Idle"
		elif is_holding_medkit and !is_healing and velocity.x == 0:
			state = "Healing_idle"
		elif is_holding_medkit and is_healing:
			state = "Healing"
		elif is_on_floor() && !is_shooting && !is_crouched && !is_pushing && velocity.x != 0 && !is_hurt && is_holding_medkit:
			state = "Running_medkit"
	if animation.name != state:
		animation.play(state)
		if state == "Reloading":
			await get_tree().create_timer(1).timeout
			reload_gun()
			is_reloading = false
		elif state == "Healing":
			await animation.animation_finished
			is_healing = false
		elif state == "Hurt":
			sound_hurt()
			await get_tree().create_timer(.2).timeout
			animation.stop()
			player_sound_hurt.stop()
			is_hurt = false

func sound_hurt():
	var rndi = randi_range(1,3)
	if rndi == 1 && !player_sound_hurt.playing:
		player_sound_hurt = hurt_sound_1
	elif rndi == 2 && !player_sound_hurt.playing:
		player_sound_hurt = hurt_sound_2
	elif rndi == 3 && !player_sound_hurt.playing:
		player_sound_hurt = hurt_sound_3
	
	if !player_sound_hurt.playing:
		player_sound_hurt.play()
		await player_sound_hurt.finished

func sounds():
	pass


func _on_fim_da_fase_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		hud.change_scene("res://cenas/fase1.tscn")
		Global.fase_atual = 2
		forest_sound.stop()
		
