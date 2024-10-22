extends CharacterBody2D

const BULLET = preload("res://cenas/bullet.tscn")

@export var life = 5
@export var SPEED = 150.0
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
var knockback_vector := Vector2.ZERO

@onready var animation: AnimatedSprite2D = $Sprite
@onready var bullet_position: Marker2D = $bullet_position
@onready var shoot_cooldown: Timer = $shoot_cooldown
@onready var gun_shoot_sound: AudioStreamPlayer = $gun_shoot_sound
@onready var animation_timer: Timer = $animation_timer

var original_bullet_y = -24

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	var direction = 0
	if(Input.is_key_pressed(KEY_A)):
		direction = -1
		if sign(bullet_position.position.x) == 1:
			bullet_position.position.x *= -1
	elif (Input.is_key_pressed(KEY_D)):
		direction = 1 
		if sign(bullet_position.position.x) == -1:
			bullet_position.position.x *= -1
			
	if Input.is_key_pressed(KEY_P):
		is_pushing = true
	else:
		is_pushing = false
	
	if Input.is_key_pressed(KEY_R) and num_bullets < initial_bullets:
		is_reloading = true
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and num_bullets > 0 or Input.is_key_pressed(KEY_ENTER) and num_bullets > 0:
		is_shooting = true
		if shoot_cooldown.is_stopped():
			shoot_bullet()
	else:
		is_shooting = false
	
	if Input.is_key_pressed(KEY_S) && is_on_floor():
		is_crouched = true
	else:
		is_crouched = false
	
	#Handle Jump
	if Input.is_key_pressed(KEY_W) and is_on_floor() and is_on_floor() || Input.is_key_pressed(KEY_SPACE) and is_on_floor() and is_on_floor():
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
		
	move_and_slide()
	apply_push_box()
	animations()
	
func apply_push_box():
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is Pushables:
			if  Input.is_key_pressed(KEY_P):
				is_pushing = true
				if velocity.x == 0:
					collider.push_box(-collision.get_normal())
				else:
					collider.push_box(-collision.get_normal())
			else:
				is_pushing = false

func shoot_bullet():
	if num_bullets > 0:
		var bullet_instance = BULLET.instantiate()
		num_bullets -= 1 
		if sign(bullet_position.position.x) == 1:
			bullet_instance.set_direction(1)
		else:
			bullet_instance.set_direction(-1)
		
		add_sibling(bullet_instance)
		bullet_instance.global_position = bullet_position.global_position
		shoot_cooldown.start()
		gun_shoot_sound.play()
		if is_shooting && is_crouched:
			bullet_position.position.y = original_bullet_y + 9
		else:
			bullet_position.position.y = original_bullet_y

func reload_gun():
	var bullets_to_discard = num_bullets
	total_bullets += bullets_to_discard
	var bullets_needed = initial_bullets
	if total_bullets >= bullets_needed:
		num_bullets = bullets_needed
		total_bullets -= bullets_needed
	else:
		num_bullets = total_bullets
		total_bullets = 0

func take_damage(amount: int, knockback_force := Vector2.ZERO, duration := 0.25):
	if not is_hurt and not is_dead:
		if knockback_force != Vector2.ZERO:
			knockback_vector = knockback_force
		
		var knockback_tween := get_tree().create_tween()
		knockback_tween.parallel().tween_property(self, "knockback_vector", Vector2.ZERO, duration)
		animation.modulate = Color(1,0,0,1)
		knockback_tween.parallel().tween_property(animation, "modulate", Color(1,1,1,1), duration)

		# Reduz a vida (você pode ter uma variável para o HP)
		life -= amount
		if life <= 0:
			die()

func die():
	if not is_dead:
		is_dead = true
		#animation.play("Die")
		#await animation.animation_finished
		#queue_free()  # Remove o personagem da cena
		get_tree().change_scene_to_file("res://cenas/telafinal.tscn")
	
func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies") and !is_dead:
		body.is_attacking = true
		await get_tree().create_timer(.2).timeout
		body.is_attacking = false
		
		var knockback = Vector2((global_position.x - body.global_position.x) * 15, 0)
		take_damage(1, knockback)
		
		is_hurt = true
		print("Zumbi atingiu o player")

func animations():
	var state = "Idle"
	if !is_dead:
		if is_hurt:
			state = "Hurt"
		elif is_crouched && !is_shooting && velocity.x == 0:
			state = "Crouch"
		elif is_on_floor() && !is_shooting && !is_crouched && !is_pushing && velocity.x != 0 && !is_hurt:
			state = "Run"
		elif !is_on_floor() && !is_shooting && !is_crouched:
			state = "Jump"
		elif is_shooting && !is_crouched && num_bullets > 0:
			if (is_on_floor() && velocity.x == 0 && velocity.y == 0):
				state = "Shoot_Standing"
			elif (velocity.y != 0):
				state = "Shoot_Jumping"
			elif (velocity.x != 0 && velocity.y == 0):
				state = "Shoot_Running"
		elif is_crouched && is_shooting && num_bullets > 0:
			state = "Shoot_Crouching"
		elif is_pushing:
			if Input.is_key_pressed(KEY_D) || Input.is_key_pressed(KEY_A):
				state = "Pushing"
			else:
				state = "Pushing_Stand"
		elif is_reloading and !is_pushing and velocity.x == 0 and num_bullets != initial_bullets:
			state = "Reloading"
		else:
			state = "Idle"
	if animation.name != state:
		animation.play(state)
		if state == "Reloading":
				await animation.animation_finished
				reload_gun()
				is_reloading = false
		elif state == "Hurt":
			await get_tree().create_timer(.2).timeout
			animation.stop()
			is_hurt = false	
