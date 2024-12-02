extends Node2D

@onready var hud: CanvasLayer = $"../HUD"
@onready var player: CharacterBody2D = $"../Player"
@onready var boss_1: CharacterBody2D = $"../Enemies/BOSS1"

var can_put_password = false
var password_menu = preload("res://cenas/password_menu.tscn")
var instancia_pm

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	instancia_pm = password_menu.instantiate()
	add_child(instancia_pm)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Interact") and can_put_password:
		#instancia_pm.putting_password = true
		instancia_pm.show_in_screen()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		can_put_password = true
		if !boss_1:
			hud.mostra_mensagem("Aperte 'I' para interagir com o interfone.", 2)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		can_put_password = false
