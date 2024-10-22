extends Node2D

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var area_2d: Area2D = $Area2D

var can_open = false
var is_open = false

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
	animation.play("fechando")

# Verifica a tecla de abrir o baú
func _process(delta: float) -> void:
	if can_open and Input.is_action_just_pressed("abrir_bau") and not is_open:
		abrir_bau()

# Função para abrir o baú
func abrir_bau():
	is_open = true
	animation.play("abrindo")
	print("ABRIU O BAU")
	is_open = false
