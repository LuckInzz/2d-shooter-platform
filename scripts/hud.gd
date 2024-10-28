extends Control

@onready var num_bullets: Label = $MarginContainer/HBoxContainer/num_bullets
@onready var total_bullets: Label = $MarginContainer/HBoxContainer/total_bullets
@onready var player: CharacterBody2D = $"../../Player"
@onready var num_bullets_plus: Label = $num_bullets_plus
@onready var bullet: TextureRect = $bullet
@onready var plus: Label = $plus


const bau = preload("res://cenas/bau.tscn")
var instancia_bau
var baus = []

func _ready() -> void:
	bullet.visible = false
	num_bullets_plus.visible = false
	plus.visible = false
	baus = get_tree().get_nodes_in_group("baus")
	
func _process(delta: float) -> void:
	num_bullets.text = str("%02d" % player.num_bullets)
	total_bullets.text = str("%02d" % player.total_bullets)
	
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
	
func mostrar_num_balas(num_bullets_plus_bau):
	bullet.visible = true
	num_bullets_plus.visible = true
	plus.visible = true
	num_bullets_plus.text = str("%02d" % num_bullets_plus_bau)
	await get_tree().create_timer(.10).timeout
	bullet.visible = false
	num_bullets_plus.visible = false
	plus.visible = false
