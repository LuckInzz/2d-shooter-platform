extends Control

@onready var player: CharacterBody2D = $"../../Player"
@onready var num_bullets: Label = $MarginContainer/HBoxContainer/num_bullets
@onready var total_bullets: Label = $MarginContainer/HBoxContainer/total_bullets
@onready var num_bullets_plus: Label = $num_bullets_plus
@onready var bullet: TextureRect = $bullet
@onready var plus: Label = $plus
@onready var health_bar: ProgressBar = $health_bar


const ENEMY = preload("res://cenas/enemy.tscn")
const PLAYER = preload("res://cenas/player.tscn")
var instancia_bau
var instancia_player
var instancia_enemy
var baus = []

func _ready() -> void:
	instancia_player = PLAYER.instantiate()
	bullet.visible = false
	num_bullets_plus.visible = false
	plus.visible = false
	baus = get_tree().get_nodes_in_group("baus")
	health_bar.max_value = instancia_player.life
	
func _process(delta: float) -> void:
	num_bullets.text = str("%02d" % player.num_bullets)
	total_bullets.text = str("%02d" % player.total_bullets)
	health_bar.value = player.life
	
	for bau in baus:
		if bau.is_open:
			bullet.visible = true
			num_bullets_plus.visible = true
			plus.visible = true
			num_bullets_plus.text = str("%02d" % bau.num_bullets_plus)
			await get_tree().create_timer(3).timeout
			bau.is_open = false
			bau.already_open = true
			bullet.visible = false
			num_bullets_plus.visible = false
			plus.visible = false
