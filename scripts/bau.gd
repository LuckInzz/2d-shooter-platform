extends Node2D

const PLAYER = preload("res://cenas/player.tscn")

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var area_2d: Area2D = $Area2D
@onready var player: CharacterBody2D = $"../../Player"
@onready var bau: Node2D = $"."
@onready var hud: CanvasLayer = $"../../HUD"

var can_open = false
var is_open = false
var already_open = false
var num_bullets_plus = 0

func _ready() -> void:
	animation.play("fechado")

# Detecta quando o jogador entra na área do baú
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_open:
		can_open = true

# Detecta quando o jogador sai da área do baú
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		can_open = false

# Verifica a tecla de abrir o baú
func _process(delta: float) -> void:
	if can_open and Input.is_action_just_pressed("abrir_bau") and not is_open and !already_open:
		abrir_bau()
		#already_open = true
		await animation.animation_finished
		animation.play("fechando")
		
# Função para abrir o baú
func abrir_bau():
	is_open = true
	animation.play("abrindo")
	if !already_open:
		num_bullets_plus = randf_range(5, 12)
		#hud.mostrar_num_balas(num_bullets_plus)
		player.total_bullets += num_bullets_plus
	if bau.name == "bau_senha":
		player.has_password_paper = true
	#is_open = false
